# Настройка серверной части shadowsocks + v2ray-plugin

Схема: `shadowsocks-libev` (`ss-server`) + `v2ray-plugin` в режиме WebSocket поверх **обычного HTTP на порту 443** (без TLS).

## Как это работает и на что рассчитано

- Трафик внутри шифруется самим Shadowsocks (AEAD, `chacha20-ietf-poly1305`). Содержимое защищено.
- Снаружи виден открытый HTTP/WebSocket-запрос. Заголовок `Host` подменяется на «разрешённый» домен (`host=...`).
- TLS здесь не используется намеренно: валидный сертификат на чужой домен получить нельзя, а собственный домен не нужен.
- Ограничение: схема не защищает от активных проб. Если фильтрация усилится, первым делом необходимо сменить `host` (см. список ниже).

## 1. Подготовка

1. Подключение к VPS по ssh-ключу (см. ssh-auth-vps)
2. Обновление системы:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

## 2. Установка `shadowsocks-libev`

```bash
sudo apt install shadowsocks-libev -y
```

## 3. Установка `v2ray-plugin`

Скрипт: [v2ray-plugin-setup.sh](v2ray-plugin-setup.sh)

```bash
chmod +x v2ray-plugin-setup.sh       # права на выполнение скрипта
./v2ray-plugin-setup.sh              # установка версии по умолчанию (v1.3.2)
TAG=v1.3.2 ./v2ray-plugin-setup.sh   # установка указанной версии
```

Скрипт печатает SHA-256 бинарника: его можно сохранить, чтобы сверять при обновлениях.

## 4. Конфигурация

Пример конфигурационного файла: [config.json](config.json)

```bash
sudo nano /etc/shadowsocks-libev/config.json
```

| Параметр      | Значение                                     | Описание                                                                |
| ------------- | -------------------------------------------- | ----------------------------------------------------------------------- |
| `server`      | `["0.0.0.0"]`                                | Слушать только IPv4                                                     |
| `server_port` | `443`                                        | Порт для подключений                                                    |
| `password`    | `<PASSWORD>`                                 | Пароль для подключения                                                  |
| `timeout`     | `60`                                         | Время в секундах, после которого сервер разрывает неактивное соединение |
| `method`      | `chacha20-ietf-poly1305`                     | Метод шифрования                                                        |
| `nameserver`  | `1.1.1.1`                                    | DNS-сервер (Cloudflare)                                                 |
| `mode`        | `tcp_only`                                   | Режим работы прокси-сервера (только TCP)                                |
| `plugin`      | `v2ray-plugin`                               | Путь к бинарнику плагина                                                |
| `plugin_opts` | `server;host=www.microsoft.com;path=/;mux=0` | Параметры плагина: серверный режим, подменяемый `Host`, путь, mux       |

### Порт 443

Порт **443 обязателен**: проверено, что на других портах схема не работает вообще. Сервис занимает его благодаря `CAP_NET_BIND_SERVICE` в юните пакета, дополнительных действий не требуется.

### Про UDP

`v2ray-plugin` в режиме WebSocket переносит только TCP. Поэтому в конфиге `tcp_only`.

### Проверенные значения `host`

- ✅ <www.microsoft.com>
- ✅ <www.bing.com>
- ❓ <login.live.com>
- ✅ <www.icloud.com>
- ✅ <www.cloudflare.com>

### Про `mux`

На практике: при `mux=1` в серверных `plugin_opts` схема **не работает вообще**, даже когда `mux` был включён на клиенте.

## 5. Запуск сервиса

```bash
sudo systemctl enable --now shadowsocks-libev   # автозапуск
sudo systemctl restart shadowsocks-libev        # рестарт (после изменения конфига)
```
