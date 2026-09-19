## Проблема

На ноутбуках Lenovo ThinkPad серии X280 аппаратная комбинация **Fn+F11** (обычно обозначена значком клавиатуры) не генерирует X-события и не определяется в `xev`. Это делает невозможным назначение шортката стандартными средствами графического окружения (`LXQt`), так как `xev` не видит нажатие клавиши. Следовательно, GUI настройки шорткатов не может её захватить, и поэтому единственный способ отследить нажатие — через систему ACPI (`acpid`).
## Решение

Использован двухступенчатый подход:
1. **Перехват ACPI-события** через `acpid`
2. **Эмуляция X-события** с помощью `xdotool`
3. **Назначение шортката** в `LXQt` на эмулируемую клавишу
## Реализация

1. Определение ACPI-события
```bash
acpi_listen
```

При нажатии Fn+F11 определилось событие: `ibm/hotkey LEN0268:00 00000080 00001315`

2. Добавить скрипт эмуляции клавиши
```bash
sudo nano ~/.local/bin/fn/emulate-XF86MenuKB-key.sh
```

Содержимое скрипта:
```bash
#!/bin/bash
xdotool key XF86MenuKB
```

Сделать скрипт исполняемым:
```bash
sudo chmod +x ~/.local/bin/fn/emulate-XF86MenuKB-key.sh
```

3. Настройка `acpid`
```bash
sudo nano /etc/acpi/events/fn-keyboard
```

```text
event=ibm/hotkey LEN0268:00 00000080 00001315
action=sudo -u matsa DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /home/matsa/.local/bin/fn/emulate-XF86MenuKB-key.sh
```

4. Перезапуск `acpid`
```bash
sudo systemctl restart acpid
```

5. Проверка эмуляции
```bash
# Запустить xev и нажать Fn+F11
xev
# Должно появиться событие для XF86MenuKB
```

6. Настройка шортката в `LXQt`

Конфигурация shortcut `LXQt`: `LXQt Configuration Center` → `Shortcut Keys` → `Add`:
- `Shortcut`: XF86MenuKB (нажать Fn+F11)
- `Description`: Open LXQt Keyboard and Mouse Settings
- `Command`: `lxqt-config-input`