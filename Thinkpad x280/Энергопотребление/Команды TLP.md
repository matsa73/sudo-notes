### Установка
```bash
sudo apt update
sudo apt install tlp tlp-rdw
```
- `tlp` — основной пакет.
- `tlp-rdw` — компонент для управления радиоинтерфейсами (Wi-Fi, Bluetooth) в зависимости от подключения к сети.
### Редактирование конфигов
```bash
# Основной конфиг TLP
sudo nano /etc/tlp.conf

# После изменений
sudo tlp start
```
### Управление сервисом
```bash
# Статус TLP
sudo systemctl status tlp

# Перезапустить TLP (после изменений конфига)
sudo tlp start
# или
sudo systemctl restart tlp
```
### Просмотр информации
```bash
sudo tlp-stat     # Общая статистика
sudo tlp-stat -b  # Информация о батарее
sudo tlp-stat -p  # Информация о процессоре
sudo tlp-stat -t  # Температура и вентиляторы
sudo tlp-stat -d  # Все устройства и их питание
```
### Управление порогами заряда
```bash
# Установить пороги (заряжать до 80%, начинать зарядку при 40%)
sudo tlp setcharge 60 90 BAT0
sudo tlp setcharge 60 90 BAT1

# Однократное отключение порогов для полной зарядки
sudo tlp fullcharge

# Отключить пороги
sudo tlp setcharge BAT0
sudo tlp setcharge BAT1
```