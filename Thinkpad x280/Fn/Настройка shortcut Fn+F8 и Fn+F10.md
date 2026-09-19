Суть настройки заключается в том, чтобы настроить отправку уведомлений при вкл/откл WiFi и Bluetooth. 

Этот способ отличается от алгоритма [[Настройка shortcut Fn+F4]], т.к. обработка этих клавиш происходит на более низком уровне - через ACPI (Advanced Configuration and Power Interface).

Поэтому вместо переназначения клавиш, можно "подписаться" на события от этих клавиш и показывать уведомления, когда они срабатывают. 
## Мониторинг через `acpid`

### Шаг 1. Подготовительный этап

1. Перед конфигурацией необходимо включить службу управления питанием `acpid` так, чтобы она запускалась при загрузке компьютера, и запустить её, чтобы она начала работать уже в текущем сеансе:
```bash
sudo systemctl enable acpid --now
```

2. Определение ACPI-события
```bash
acpi_listen
```

При нажатии Fn+F8 определилось событие: `button/wlan WLAN 00000080 00000000 K`
При нажатии Fn+F10 определилось событие: `ibm/hotkey LEN0268:00 00000080 00001314`
### Шаг 2. Конфигурация `acpi` и добавление скриптов по отправке уведомлений

Отправлять уведомления (`notify-send`) нужно через пользовательскую сессию D-Bus, а скрипты выполняются от root через `acpid`. Поэтому нужно указать правильную сессию D-Bus в правилах `acpid`.

1. Правило для отслеживания нажатий Fn+F8 (WiFi):
```bash
sudo nano /etc/acpi/events/fn-wifi
```

```text
event=button/wlan WLAN 00000080 00000000 K
action=sudo -u matsa DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /home/matsa/.local/bin/fn/toggle-wifi.sh
```

Добавить скрипт:
```bash
sudo nano ~/.local/bin/fn/toggle-wifi.sh
```

Содержимое скрипта:
```bash
#!/bin/bash
sleep 0.3

if rfkill list wifi | grep -q "Soft blocked: yes"; then
    notify-send -i network-wireless-disconnected \
                -t 1500 \
                -r 14730 \
                "WiFi Off"
else
    notify-send -i network-wireless-connected \
                -t 1500 \
                -r 14730 \
                "WiFi On"
fi
```

Сделать скрипт исполняемым:
```bash
sudo chmod +x ~/.local/bin/fn/toggle-wifi.sh
```

2. Правило для отслеживания нажатий Fn+F10 (Bluetooth):

```bash
sudo nano /etc/acpi/events/fn-bluetooth
```

```text
event=ibm/hotkey LEN0268:00 00000080 00001314
action=sudo -u matsa DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /home/matsa/.local/bin/fn/toggle-bluetooth.sh
```

Добавить скрипт:
```bash
sudo nano ~/.local/bin/fn/toggle-bluetooth.sh
```

Содержимое скрипта:
```bash
#!/bin/bash
sleep 0.3

if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    notify-send -i bluetooth-disabled \
                -t 1500 \
                -r 14731 \
                "Bluetooth Off"
else
    notify-send -i bluetooth-active \
                -t 1500 \
                -r 14731 \
                "Bluetooth On"
fi
```

Сделать скрипт исполняемым:
```bash
sudo chmod +x ~/.local/bin/fn/toggle-bluetooth.sh
```

3. Перезапуск `acpid`:
```bash
sudo systemctl restart acpid
```

4. Можно посмотреть статус `acpid`:
```bash
sudo systemctl status acpid
```
## Диагностика

1. Проверка работает ли отправка уведомлений от пользователя:
```bash
sudo -u matsa DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "Уведомление" "Сообщение"
```

2. Проверка доступных сервисов уведомлений (запуск команды под текущим пользователем!):
```bash
systemctl --user list-unit-files | grep -i notification

# какой процесс уведомлений запущен
ps aux | grep -i notification
```