# Настройка VPN через локальный прокси

## Шаг 1. [[Shadowsocks + v2ray-plugin client]]

## Шаг 2. Управление локальным прокси через панель инструментов

### Индикатор статуса и кнопка запуска на панели

Виджет **"Custom Command"** в `LXQt` может отображать текст или иконку на панели и выполнять действия по клику.

1. Создать скрипт-переключатель:

```bash
sudo nano ~/.local/bin/fn/toggle-ss-http-proxy.sh
```

```bash
#!/bin/bash
start_proxy() {
    # Запуск ss-local
    sudo ss-local -c /etc/shadowsocks-libev/local-config.json &
    
    # Дать время на запуск ss-local
    sleep 0.5
    
    # Проверить, запустился ли ss-local
    if ! pgrep -x "ss-local" > /dev/null; then
        notify-send -i dialog-error \
            -t 1500 \
            -r 34798 \
            "Proxy SOCKS5" \
            "Start Error!"
        return 1
    fi
    
    # Запуск Privoxy
    sudo systemctl start privoxy
    
    # Дать время на запуск Privoxy
    sleep 0.5
    
    # Проверить, запустился ли Privoxy
    if pgrep -x "privoxy" > /dev/null; then
        notify-send -i network-vpn \
            -t 1500 \
            -r 34798 \
            "Proxy" \
            "ON"
    else
        # Если Privoxy не запустился, остановить ss-local
        sudo pkill -x "ss-local"
        notify-send -i dialog-error \
            -t 1500 \
            -r 34798 \
            "Proxy HTTP" \
            "Start Error!"
        return 1
    fi
}

stop_proxy() {
    # Останавить оба процесса
    sudo pkill -x "ss-local"
    sudo systemctl stop privoxy
    
    notify-send -i network-vpn \
        -t 1500 \
        -r 34798 \
        "Proxy" \
        "OFF"
}

# Основная логика
if pgrep -x "ss-local" > /dev/null || pgrep -x "privoxy" > /dev/null; then
    stop_proxy
else
    start_proxy
fi

```

2. Сделать скрипт исполняемым:

```bash
sudo chmod +x ~/.local/bin/fn/toggle-ss-http-proxy.sh
```

3. Добавить виджет `Custom Command` на панель:

- В поле **Command**: `pgrep -x ss-local > /dev/null && pgrep -x privoxy > /dev/null && echo ON || echo OFF`;
- `Run with "bash -c"` = true
- Поставить галочку **Repeat command after** и задать интервал обновления состояния в 1 секунд, чтобы виджет всегда показывал актуальный статус.
- **Icon**: выберать подходящую иконку (`/usr/share/icons/Papirus/22x22/devices/network-vpn.svg`);
- **Text**: %1 (виджет будет показывать "ON" или "OFF" вместе с иконкой);
- (-) **Mouse Commands** -> **Click**: `bash -c "pkexec /usr/local/bin/toggle-ss-proxy.sh"`;

### Ярлык в меню "Start"

1. Создать файл `.desktop`:

```bash
sudo nano /usr/share/applications/toggle-ss-http-proxy.desktop
```

```ini
[Desktop Entry]
Version=1.0
Name=SOCKS5 and HTTP Proxy
Comment=Запустить или остановить Shadowsocks и Http прокси
Exec=pkexec /home/matsa/.local/bin/fn/toggle-ss-proxy.sh
Icon=preferences-system-network
Terminal=false
Type=Application
Categories=Network;
```

2. Сохранить файл. После этого ярлык появится в меню `Start` в разделе `Internet`

Обновить кеш меню (**важно**): `sudo update-desktop-database`

### Настройка запуска от клавиши XF86Favorites

1. Конфигурация shortcut `LXQt`: `LXQt Configuration Center` → `Shortcut Keys` → `Add`:

- `Shortcut`: XF86Favorites
- `Description`: Start/stop shadowsocks local proxy
- `Command`: `/home/matsa/.local/bin/fn/toggle-ss-http-proxy.sh`

**Есть нюанс**: глобальный шорткат в `LXQt` выполнит команду от вашего текущего пользователя, _но без терминала_. Следовательно, скрипту **неоткуда будет взять пароль для sudo**, и он просто зависнет в фоне, ожидая ввода. Этого легко избежать — нужно разрешить выполнять конкретные команды `ss-local` и `pkill` без пароля через `sudoers`.

2. Создайте файл с правилами:

```bash
sudo visudo -f /etc/sudoers.d/toggle-ss-proxy
```

```text
matsa ALL=(root) NOPASSWD: /usr/bin/pkill -x ss-local
matsa ALL=(root) NOPASSWD: /usr/bin/systemctl stop privoxy

matsa ALL=(root) NOPASSWD: /usr/bin/ss-local -c /etc/shadowsocks-libev/local-config.json
matsa ALL=(root) NOPASSWD: /usr/bin/systemctl start privoxy
```

3. Сохранить файл и закрыть редактор. Теперь команды из скрипта смогут отрабатывать без пароля, и шорткат будет работать мгновенно.
4. Добавить вызовы команд, которые проверяют всю цепочку Шага 3

### Проверка

1. Быстрая проверка SOCKS5

```bash
systemctl is-active shadowsocks-libev-local@tunnel.service
sudo systemctl status shadowsocks-libev-local@tunnel.service
journalctl -u shadowsocks-libev-local@tunnel.service -n 50
curl -x socks5h://127.0.0.1:1080 https://ifconfig.me
```

2. Быстрая проверка HTTP-прокси (`privoxy`)

```bash
# Через curl с явным указанием прокси
curl --proxy http://127.0.0.1:8118 -I https://github.com
```

Если видите `HTTP/2 200` или `HTTP/1.1 200 OK` — HTTP-прокси работает.

```bash
# Проверить, какой IP видят сайты (должен быть IP вашего VPS)
curl --proxy http://127.0.0.1:8118 https://ifconfig.me
```

3. Проверка всей цепочки разом

```bash
# HTTP-прокси → SOCKS5 → VPS → Интернет
curl --proxy http://127.0.0.1:8118 https://httpbin.org/ip
```

Должен вернуть IP вашего VPS-сервера, не ваш домашний.
