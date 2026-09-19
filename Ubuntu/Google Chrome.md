# Google Chrome

ПОЛНЫЙ ГАЙД: Установка Google Chrome на Ubuntu 26.04

Google не распространяет Chrome через Snap — только как `.deb`-пакет напрямую с сайта. Поэтому проблема snap тут не стоит: достаточно поставить официальный `.deb`.

## Шаги

1. Скачать пакет: `wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb`;
2. Установить: `sudo apt install ./google-chrome-stable_current_amd64.deb` - команда сама подтянет все зависимости;
3. Проверить установку: `google-chrome --version`;
4. Запустить: `google-chrome` или через меню приложений.

## Что происходит "под капотом"

- postinst-скрипт пакета сам добавляет репозиторий Google в `/etc/apt/sources.list.d/google-chrome.list`
- GPG-ключ Google кладётся автоматически в `/etc/apt/trusted.gpg.d/`
- Дальнейшие обновления Chrome приходят через обычный `sudo apt upgrade`

## Удаление (если понадобится)

```bash
sudo apt remove google-chrome-stable
sudo rm /etc/apt/sources.list.d/google-chrome.list
```

## Очистка

Скачанный `.deb`-файл после установки можно удалить:

```bash
rm google-chrome-stable_current_amd64.deb
```
