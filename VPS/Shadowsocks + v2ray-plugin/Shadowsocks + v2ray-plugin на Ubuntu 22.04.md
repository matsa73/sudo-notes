# Shadowsocks + v2ray-plugin

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
    
    ARCH=$(dpkg --print-architecture)   # определение архитектуры системы - amd64 

    TAG=$(curl -fsSL https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest \ # обращение к GitHub API для получения метаданных последнего релиза в виде JSON
      | grep -oP '"tag_name":\s*"\K[^"]+') # поиск значения поля 'tag_name' (например, 'v1.3.2') - версия последнего релиза

    curl -fsSL -o /tmp/v2ray-plugin.tar.gz \
      "https://github.com/shadowsocks/v2ray-plugin/releases/download/${TAG}/v2ray-plugin-linux-${ARCH}-${TAG}.tar.gz"

    mkdir -p /tmp/v2ray-plugin
    tar -xzf /tmp/v2ray-plugin.tar.gz -C /tmp/v2ray-plugin

    BIN=$(find /tmp/v2ray-plugin -maxdepth 1 -type f ! -iname "*.md" ! -iname "license*")
    sudo install -m755 "$BIN" /usr/local/bin/v2ray-plugin

    v2ray-plugin -version
    ```

7. [[Настройка v2ray-plugin]]
8. Дополнительная оптимизация сети

    ```bash
    # Увеличиваем буферы для лучшей производительности
    echo "net.core.rmem_max = 134217728" | sudo tee -a /etc/sysctl.conf
    echo "net.core.wmem_max = 134217728" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_rmem = 4096 87380 134217728" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_wmem = 4096 65536 134217728" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" | sudo tee -a /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    ```

9. Перезапуск сервиса

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart shadowsocks-libev
    sudo systemctl enable shadowsocks-libev # автозапуск
    ```

10. [[Настройка брандмауэра]]
