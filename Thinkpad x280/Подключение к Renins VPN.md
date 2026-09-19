Клиент `AnyConnect` — это GUI-приложение, требующее библиотеки GTK и некоторые сетевые утилиты.

1. Установка зависимостей:
```bash
sudo apt update
sudo apt install libgtk2.0-0t64 libgtk-3-0t64 libwebkit2gtk-4.1-0 libjavascriptcoregtk-4.1-0 libcanberra-gtk-module libcanberra-gtk3-module libglib2.0-0t64 libpcsclite1 network-manager-openvpn-gnome vpnc-scripts
```
- `libgtk2.0-0t64 / libgtk-3-0t64` — графические тулкиты для отрисовки окон и элементов интерфейса AnyConnect.
- `libwebkit2gtk-4.1-0` — движок рендеринга веб-страниц, нужен для отображения окон аутентификации (логин/пароль, SAML).
- `libjavascriptcoregtk-4.1-0` — обработка JavaScript внутри WebKit-окон (обычно тянется вместе с webkit2gtk, но ставится явно ради ссылок).
- `libcanberra-gtk-module / libcanberra-gtk3-module` — модули для системных звуковых уведомлений (щелчки, сообщения).
- `libglib2.0-0t64` — низкоуровневая библиотека утилит, почти всё в Linux/GNOME-экосистеме зависит от неё.
- `libpcsclite1` — поддержка смарт-карт/считывателей (аппаратных токенов), если их нет — не критична, но установщик часто её требует.
- `network-manager-openvpn-gnome` — плагин NetworkManager для OpenVPN, может использоваться AnyConnect в режиме совместимости.
- `vpnc-scripts` — вспомогательные скрипты настройки сети при подключении/отключении VPN.

Больше половины зависимостей уже есть в системе lubuntu 24. Нужно доустановить:  `libcanberra-gtk-module`, `libcanberra-gtk3-module`, `network-manager-openvpn-gnome`, `vpnc-scripts`.

2. Запуск установщика:
```bash
cd ~/Загрузки
sudo sh ./vpnsetup.sh
```
_(заменить `vpnsetup.sh` на точное имя установочного файла `*.sh`)_

3. Проверка установки
Клиент установится в папку `/opt/cisco/anyconnect/`. Иконка должна появиться в меню `Lubuntu` (раздел «Internet»).

4. Настройка в `CiscoAnyConnect`: `Allow Local LAN Access` = true

5. Настройка в `Remmina`: `Advanced` -> `Security Protocol negotiation` = TLS Protocol Security (без этой настройки будет вечное соединение)