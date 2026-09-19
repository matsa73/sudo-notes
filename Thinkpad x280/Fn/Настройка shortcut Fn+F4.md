Суть настройки заключается в том, чтобы назначить на shortcut выполнение скрипта, который выполняет вкл/откл микрофона и отправку уведомлений на рабочий стол.
### Шаг 1. Проверка установленных пакетов

1. Проверка `PulseAudio`:
```bash
pactl info
```

2. Проверка отключения микрофона командой:
```bash
pactl set-source-mute @DEFAULT_SOURCE@ toggle
```

После этой команды микрофон должен отключиться или включиться. Проверить это можно в настройках звука, открыв UI утилиты `PulseAudio Volume Control`.

3. Проверка `notify-send`:
```bash
notify-send --version
```

3. Отправка тестового уведомления:
```bash
notify-send -t 2000 "Тест" "Уведомление работает!"
```

### Шаг 2. Скрипт вкл/выкл микрофона с отправкой уведомления

```bash
sudo nano ~/.local/bin/fn/toggle-microphone.sh
```

Содержимое скрипта:
```bash
#!/bin/bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle

MUTE_STATUS=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
LEVEL=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1)

if [ "$MUTE_STATUS" = "yes" ]; then
    TEXT="Volume: ${LEVEL}(muted)"
    ICON="microphone-sensitivity-muted"
else
    TEXT="Volume: ${LEVEL}"
    ICON="microphone-sensitivity-high"
fi

notify-send -i $ICON \
            -t 1500 \
            -r 14728 \
            -h int:value:$(echo $LEVEL | tr -d '%') \
            "$TEXT"
```

Сделать скрипт исполняемым:
```bash
sudo chmod +x ~/.local/bin/fn/toggle-microphone.sh
```
### Шаг 3. Настройка сочетания клавиш в `LXQt`:

Конфигурация shortcut `LXQt`: `LXQt Configuration Center` → `Shortcut Keys` → `Add`:
- `Shortcut`: XF86AudioMicMute
- `Description`: Mute/unmute microphone volume
- `Command`: `/home/matsa/.local/bin/fn/toggle-microphone.sh`

**Что тут происходит:**
- Когда микрофон включен: показывает `Volume: 45%`
- Когда микрофон выключен: показывает `Volume: 45%(muted)`
- Иконка меняется в зависимости от статуса
- Прогресс-бар показывает уровень громкости микрофона
- Параметр `-h string:synchronous:volume` заставляет уведомление вести себя как стандартное уведомление громкости (обновлять существующее, а не создавать новое)
