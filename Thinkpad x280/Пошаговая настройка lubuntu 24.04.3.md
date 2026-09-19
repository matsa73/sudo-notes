1. **Масштаб** (очень мелкий текст на экране): `Preferences` → `LXQt Settings` → `Session Settings` → `Basic Settings` → `Scale Factory` = 1,50
2. **Touchpad** (taps, scrolling): `Preferences` → `LXQt Settings` → `Keyboard and Mouse` → `Mouse and Touchpad`
3. Русская раскладка клавиатуры
	* Добавить новый Layout: `Preferences` → `LXQt Settings` → `Keyboard and Mouse` → `Keyboard Layout` → `Add` (Varian = None)
	* Добавить виджет языка: Configure Panel → Widgets → Keyboard State Indicator 
4. Выставления программы по умолчанию для текстовых файлов: `Right Click` -> `Open With` -> `Other Applications` -> `Select the application` -> `Set selected application as default action of this file type` (checkbox)
5. [[Сканера отпечатков пальцев]]
6. [[Настройка и конфигурация Fn блока]]
7. [[Микрофон]]
8. [[Настройки TLP]]
9. [[Резервное копирование]]
10. [[Оптимизация под 8Гб RAM]]
11. [[Настройка GPU]]
12. [[Настройка LXImage-Qt]]
13. [[Настройка Redshift]]
14. [[Настройка VPN-клиента]]
15. [[Подключение к VPS по SSH-ключу#Настройка для удобства]]
16. [[Подключение к Renins VPN]]
### Базовый софт:

1.  `Featherpad`
```bash
sudo apt install featherpad
```
2. `GNU Midnight Commander`
```bash
sudo apt install mc
```
3. `Camera` - простое приложение для фото/видео
```bash
sudo apt install gnome-snapshot
```
4. `Sound Recorder` - просто приложение для быстрой записи голосовой заметку или звука с микрофона
```bash
sudo apt install gnome-sound-recorder
```
5. `Audacious` - аудиоплеер
```bash
sudo apt install audacious audacious-plugins
```
6. `Remmina` - RDP-клиент
```bash
sudo apt install remmina remmina-plugin-rdp
```
7. `GParted` - программа для управления дисками
```bash
sudo apt install gparted -y
```
7. [[Celluloid]] 
8. [[Firefox]]
9. [[Git]]
10. [[VS Code]]
11. [[PostgreSql + Dbeaver]]
### Быстрая очистка одной командой:

```bash
sudo apt-get clean && sudo apt-get autoclean && sudo apt autoremove -y
```
- **`sudo apt-get clean`** — удаляет **все** скачанные файлы пакетов (.deb) из кеша. Обычно это самый быстрый способ освободить много места.
- **`sudo apt-get autoclean`** — более «умная» версия. Она удаляет только те пакеты из кеша, которые больше нельзя скачать из репозиториев (устаревшие версии).
- **`sudo apt autoremove`** — находит и удаляет пакеты, которые были автоматически установлены как зависимости для других программ, но теперь больше не нужны. **Это полностью безопасно** и часто освобождает гигабайты.

---

[Документация Ubuntu](https://help.ubuntu.ru/wiki/%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F)
[Документация Lubuntu](https://help.ubuntu.ru/wiki/lubuntu/%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F) - обязательно посмотреть, что там описано про ПО!