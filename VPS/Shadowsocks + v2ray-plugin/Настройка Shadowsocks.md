# Настройка Shadowsocks

## Конфигурация

```bash
# Открыть конфигурационный файл
sudo nano /etc/shadowsocks-libev/config.json
```

```json
{
    "server": ["0.0.0.0"],
    "server_port": 443,
    "password": "пароль",
    "timeout": 60,
    "method": "chacha20-ietf-poly1305",
    "nameserver": "1.1.1.1",
    "fast_open": true,
    "mode": "tcp_and_udp"
}
```

Расшифровка параметров:

| Параметр      | Значение                 | Описание                                                                |
| ------------- | ------------------------ | ----------------------------------------------------------------------- |
| `server`      | `["0.0.0.0"]`            | Слушать только IPv4                                                     |
| `server_port` | `443`                    | Порт для подключений (HTTPS)                                            |
| `password`    | пароль                   | Пароль для подключения                                                  |
| `timeout`     | `60`                     | Время в секундах, после которого сервер разрывает неактивное соединение |
| `method`      | `chacha20-ietf-poly1305` | Метод шифрования                                                        |
| `nameserver`  | `1.1.1.1`                | DNS-сервер (CloudFlare)                                                 |
| `fast_open`   | `true`                   | Ускорения установки TCP-соединений                                      |
| `mode`        | `tcp_and_udp`            | Режим работы прокси-сервера (TCP и UDP)                                 |

### Настройка `fast_open` на Ubuntu

Ускорения установки TCP-соединений (TCP Fast Open)

```bash
# Проверка поддержки ядром
cat /proc/sys/net/ipv4/tcp_fastopen

# Должно быть значение >= 1. Если 0, исправить
echo 3 | sudo tee /proc/sys/net/ipv4/tcp_fastopen

# сделать постоянным
cat <<'EOF' | sudo tee /etc/sysctl.d/99-fastopen.conf
net.ipv4.tcp_fastopen = 3
EOF
sudo sysctl --system
```
