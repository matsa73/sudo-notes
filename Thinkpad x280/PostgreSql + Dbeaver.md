### Часть 1: Установка PostgreSQL

Установка из официальных репозиториев Ubuntu:

1.  Открыть терминал (Ctrl+Alt+T).
2.  Обновить список пакетов и установить PostgreSQL:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```
*   `postgresql` — это сам сервер баз данных.
*   `postgresql-contrib` — набор дополнительных полезных утилит.

3.  Проверить статус сервера:
```bash
sudo systemctl status postgresql
```
Отобразится `active (exited)` или `active (running)`. Для выхода из просмотра статуса нажмите `q`.

4.  Настройка пароля для пользователя `postgres` (суперпользователь БД):

По умолчанию создаётся системный пользователь `postgres`. Необходимо задать ему пароль для базы данных:
```bash
sudo -u postgres psql
```

В открывшейся командной строке SQL ввести:
```sql
ALTER USER postgres WITH PASSWORD 'новый_пароль';
```
Завершить работу с PostgreSQL командой `\q`.

### Часть 2: Установка DBeaver через официальный репозиторий

1.  Добавить GPG-ключ и репозиторий DBeaver:
```bash
# Скачать и установить ключ
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg

# Добавить репозиторий
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
```

2.  Обновить кэш и установить DBeaver:
```bash
sudo apt update
sudo apt install dbeaver-ce
```