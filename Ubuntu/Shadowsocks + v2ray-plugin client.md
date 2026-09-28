# Установка и настройка shadowsocks-клиента с v2ray-plugin

## Шаг 1. Установка `shadowsocks-libev`

```bash
sudo apt install shadowsocks-libev -y
```

## Шаг 2. Установка `v2ray-plugin`

```bash
# Определение архитектуры системы (amd64 на большинстве десктопов)
ARCH=$(dpkg --print-architecture)

# Обращение к GitHub API для получения метаданных последнего релиза
TAG=$(curl -fsSL https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest \
  | grep -oP '"tag_name":\s*"\K[^"]+')

curl -fsSL -o /tmp/v2ray-plugin.tar.gz \
  "https://github.com/shadowsocks/v2ray-plugin/releases/download/${TAG}/v2ray-plugin-linux-${ARCH}-${TAG}.tar.gz"

mkdir -p /tmp/v2ray-plugin
tar -xzf /tmp/v2ray-plugin.tar.gz -C /tmp/v2ray-plugin

BIN=$(find /tmp/v2ray-plugin -maxdepth 1 -type f ! -iname "*.md" ! -iname "license*")
sudo install -m755 "$BIN" /usr/local/bin/v2ray-plugin

v2ray-plugin -version
```

## Шаг 3. Конфигурация клиента

Важно: это **один** файл со всеми параметрами — и подключения к серверу, и плагина. Называем его `local-config.json`, а не `config.json` — последнее имя занято дефолтным юнитом `shadowsocks-libev.service`, работающим в режиме **сервера**.

```bash
sudo nano /etc/shadowsocks-libev/local-config.json
```

```json
{
    "server": "ВАШ_СЕРВЕР",
    "server_port": 443,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "ВАШ_ПАРОЛЬ",
    "timeout": 20,
    "method": "chacha20-ietf-poly1305",
    "fast_open": true,
    "mode": "tcp_and_udp",
    "plugin": "v2ray-plugin",
    "plugin_opts": "websocket;host=www.microsoft.com;path=/;mux=0"
}
```

| Параметр | Значение | Описание |
| --- | --- | --- |
| `server` | `ВАШ_СЕРВЕР` | IPv4 или IPv6 адрес сервера |
| `server_port` | `443` | Порт сервера |
| `local_address` | `127.0.0.1` | Адрес SOCKS5-прокси |
| `local_port` | `1080` | Порт SOCKS5-прокси. Это не «стандартный порт Shadowsocks» — просто общепринятый порт для SOCKS-прокси вообще; можно указать любой свободный |
| `password` | `ВАШ_ПАРОЛЬ` | Пароль для подключения |
| `timeout` | `20` | Таймаут неактивного соединения |
| `method` | `chacha20-ietf-poly1305` | Метод шифрования |
| `fast_open` | `true` | Ускоренная установка TCP-соединений (см. предпосылку ниже) |
| `mode` | `tcp_and_udp` | Режим работы по TCP и UDP |
| `plugin` | `/usr/local/bin/v2ray-plugin` | Путь к бинарнику плагина из Шага 2 |
| `plugin_opts` | `websocket;host=bing.com;path=/search;mux=0` | Параметры обфускации (должны совпадать с настройками плагина на сервере) |

**Предпосылка для `fast_open`:** ядро должно поддерживать клиентский TCP Fast Open (`net.ipv4.tcp_fastopen` >= 1).

```bash
cat /proc/sys/net/ipv4/tcp_fastopen   # проверка

# если 0 — включить
echo 3 | sudo tee /proc/sys/net/ipv4/tcp_fastopen

# сделать постоянным
cat <<'EOF' | sudo tee /etc/sysctl.d/99-fastopen.conf
net.ipv4.tcp_fastopen = 3
EOF
sudo sysctl --system
```

Без этого `fast_open: true` в конфиге либо будет проигнорирован, либо приведёт к ошибке в логах `ss-local`.

## Шаг 4. Включение клиента как systemd-сервис

1. Отключить ненужный серверный юнит:

```bash
sudo systemctl disable --now shadowsocks-libev
```

2. Включить и запустить клиентский туннель:

```bash
sudo systemctl enable --now shadowsocks-libev-local@local-config.service
```

`enable` — автозапуск при загрузке ОС, `--now` — сразу же запустить, не дожидаясь перезагрузки. Теперь это обычный фоновый сервис — systemd сам поднимет его при старте ОС и перезапустит при падении.

3. Проверить статус и логи:

```bash
sudo systemctl status shadowsocks-libev-local@local-config.service
journalctl -u shadowsocks-libev-local@local-config.service -n 50
```

4. Проверить, что туннель реально работает:

```bash
curl -x socks5h://127.0.0.1:1080 https://ifconfig.me
```

IP в ответе должен быть IP-адресом VPS, а не локальным.

## Шаг 5. Установка и настройка локального HTTP-proxy

Некоторые программы (например, VS Code) не умеют работать с SOCKS5 напрямую. Решение — `privoxy`. Это лёгкая утилита-конвертер, которая поднимает локальный HTTP-прокси и перенаправляет трафик в SOCKS5. Она не создаёт отдельное соединение, а просто «переводит» протокол; ресурсов почти не потребляет.

1. Установка:

```bash
sudo apt install privoxy
```

2. Настройка:

```bash
# проверить адрес прослушивания — в пакете Debian/Ubuntu обычно уже активен по умолчанию
grep -n "listen-address" /etc/privoxy/config

# проверить, что нет конфликтующих правил форвардинга
grep -n "^forward" /etc/privoxy/config
```

Если `listen-address 127.0.0.1:8118` закомментирована (есть `#` в начале) — раскомментировать. Если уже активна — ничего не трогать.

Открыть конфиг и добавить в конец файла:

```bash
sudo nano /etc/privoxy/config
```

```
forward-socks5t / 127.0.0.1:1080 .
```

Порт — тот же, что указан в `local_port` конфига shadowsocks (в этом гайде — `1080`). `5t` вместо просто `5` — DNS-имена резолвятся через сам SOCKS5-туннель, а не локальным резолвером, что не даёт DNS-запросам утекать в обход прокси.

```bash
sudo systemctl restart privoxy
sudo systemctl enable privoxy
```

3. Проверка:

```bash
curl -x http://127.0.0.1:8118 https://ifconfig.me
```

IP должен совпасть с тем, что показывал `curl` через SOCKS5 (Шаг 4, пункт 4) — значит вся цепочка работает:

```text
Приложение (HTTP-запрос)
    → Privoxy — конвертирует HTTP в SOCKS5
    → SOCKS5-прокси (shadowsocks + v2ray-plugin клиент)
    → VPS-сервер (shadowsocks + v2ray-plugin сервер)
    → Интернет
```
