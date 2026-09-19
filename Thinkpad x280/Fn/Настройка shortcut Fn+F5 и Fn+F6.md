Стандартные сочетания клавиш `LXQt` (Fn+F5/F6) изменяют яркость слишком маленькими шагами. Требуется настройка шага 10% с уведомлением.
### Шаг 1. Проверка установленных пакетов

1. Проверка `brightnessctl`
```bash
brightnessctl --version
```

2. Проверка уменьшнеия/увеличения яркости командой:
```bash
brightnessctl set 30%-
brightnessctl set 30%+
```

3. Проверка `notify-send`:
```bash
notify-send --version
```

4. Отправка тестового уведомления:
```bash
notify-send -t 2000 "Тест" "Уведомление работает!"
```
### Шаг 2. Скрипт управления яркостью

```bash
sudo nano ~/.local/bin/fn/set-brightness.sh
```

Содержимое скрипта:
```bash
#!/bin/bash

STEP=10
BRIGHTNESS_CMD="brightnessctl"
ICON="display-brightness"

case "$1" in
    up)
        $BRIGHTNESS_CMD set ${STEP}%+ > /dev/null
        ;;
    down)
        $BRIGHTNESS_CMD set ${STEP}%- > /dev/null
        ;;
    *)
        exit 1
        ;;
esac

current_brightness=$($BRIGHTNESS_CMD | grep -oP '\d+%' | head -1 | tr -d '%')

notify-send \
    -i "$ICON" \
    -t 1500 \
    -r 14729 \
    "Brightness: ${current_brightness}%"
```

Сделать скрипт исполняемым:
```bash
sudo chmod +x ~/.local/bin/fn/set-brightness.sh
```
### Шаг 3. Настройка сочетания клавиш в `LXQt`:

Конфигурация shortcut `LXQt`: `LXQt Configuration Center` → `Shortcut Keys` → `Add`:
- `Shortcut`: XF86MonBrightnessUp/XF86MonBrightnessDown
- `Description`: ☼ ↑ / ☼ ↓
- `Command`:
```text
/home/matsa/.local/bin/fn/set-brightness.sh up → для XF86MonBrightnessUp
/home/matsa/.local/bin/fn/set-brightness.sh down → для XF86MonBrightnessDown
```

Не забыть указать **параметры** скрипта!