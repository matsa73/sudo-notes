# Shadowsocks + v2ray-plugin

Установка и настройка осуществляются на ОС Ubuntu 22.04

## Настройка VPS

1. Подключение к VPS-серверу через терминал:

    ```bash
    ssh root@server_ip
    ```

    Ввести `yes` при первом подключении, а затем ввести пароль (символы не отображаются при вводе).

2. Обновление системы:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

3. [[Подключение к VPS по SSH-ключу]]

4. Установка `Shadowsocks-libev`

    ```bash
    sudo apt install shadowsocks-libev -y
    ```

5. [[Настройка Shadowsocks]]
6. Установка `v2ray-plugin`

    ```bash
    #!/bin/bash

    # Определение архитектуры системы
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

7. [[Настройка v2ray-plugin]]
8. [[Настройка брандмауэра]]
9. Перезапуск сервиса

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart shadowsocks-libev
    sudo systemctl enable shadowsocks-libev # автозапуск
    ```
