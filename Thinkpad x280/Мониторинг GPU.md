Утилита для отслеживания загруженности GPU - `intel-gpu-tools`.

1. Установка:
```bash
sudo apt install intel-gpu-tools
```

2. Добавление в меню "Start" (в раздел System Tools)
- Вручную создать `intel_gpu_top.desktop`:
```bash
sudo nano /usr/share/applications/intel_gpu_top.desktop
```
```text
[Desktop Entry]
Type=Application
Version=1.0
Name=Intel GPU Monitor
Comment=Monitor Intel GPU usage
Icon=utilities-terminal
Exec=sudo intel_gpu_top
Terminal=true
Categories=System;Monitor;ConsoleOnly;
Keywords=system;process;task
StartupNotify=true
```

- Сделать файл исполняемым:
```bash
sudo chmod +x /usr/share/applications/intel_gpu_top.desktop
```

- Обновить кеш меню (**важно**):
```bash
sudo update-desktop-database
```