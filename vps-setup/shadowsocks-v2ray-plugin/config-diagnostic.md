# Проверка работоспособности

На сервере:

```bash
sudo systemctl status shadowsocks-libev                 # active (running)
sudo ss -tlnp 'sport = :443'                            # LISTEN, процесс v2ray-plugin
sudo ss -tlnp                                           # все слушающие порты: снаружи должны быть только sshd и v2ray-plugin
sudo journalctl -u shadowsocks-libev -n 20 --no-pager   # проверка логов
```

Публично на 443 слушает `v2ray-plugin`. `ss-server` при этом занимает локальный порт на `127.0.0.1`, это нормально.

С клиента:

```bash
# Windows (PowerShell)
Test-NetConnection -ComputerName <SERVER_IP> -Port 443   # TcpTestSucceeded : True

# Linux / macOS
nc -vz <SERVER_IP> 443
```

## Диагностика проблем

### Сервис не запускается

Проверка конфигурации:

```bash
python3 -m json.tool /etc/shadowsocks-libev/config.json > /dev/null && echo "JSON OK"
ls -l /etc/shadowsocks-libev/config.json   # ожидается: -rw-r--r-- root root
```

Ошибка `Invalid config path` может означать, что сервис не может прочитать файл конфигурации - проверить права на него.

Запуск вручную в режиме отладки:

```bash
sudo systemctl stop shadowsocks-libev                              # иначе порт 443 будет занят
sudo /usr/bin/ss-server -c /etc/shadowsocks-libev/config.json -v   # остановка: Ctrl+C
sudo systemctl start shadowsocks-libev                             # вернуть сервис после отладки
```

Вручную `ss-server` запускается от root, а сервис — от своего пользователя. Если вручную всё работает, а через `systemctl` нет, надо искать проблему в правах доступа.

### Порт 443 недоступен снаружи

Если на сервере порт слушается, а с клиента `nc -vz` не проходит, необходимо проверить облачный файрвол в панели управления провайдера VPS.

### Плагин не работает

```bash
which v2ray-plugin                                       # /usr/local/bin/v2ray-plugin
ls -l /usr/local/bin/v2ray-plugin                        # ожидается: -rwxr-xr-x
v2ray-plugin -version

# От какого пользователя запускается сервис
systemctl cat shadowsocks-libev | grep -iE '^(user|group)'

# Запуск плагина от имени этого пользователя (подставьте значение User из юнита)
sudo -u nobody v2ray-plugin -version
```

### Клиент не подключается

1. Порт 443 доступен снаружи;
2. Пароль, метод шифрования, `host` и `path` совпадают на сервере и на клиенте;
3. В серверных `plugin_opts` стоит `mux=0`;
4. Если схема работала и внезапно перестала, смените `host` (см. список проверенных значений) на сервере и на клиенте;
5. Попробовать подключиться из другой сети или через другого оператора.

## 📌 Полезные команды

### Управление сервисом

```bash
sudo systemctl status shadowsocks-libev    # статус
sudo systemctl restart shadowsocks-libev   # перезапуск
sudo systemctl stop shadowsocks-libev      # остановка
sudo systemctl start shadowsocks-libev     # запуск
```

### Просмотр логов

```bash
sudo journalctl -u shadowsocks-libev -f                        # в реальном времени
sudo journalctl -u shadowsocks-libev -n 50                     # последние 50 строк
sudo journalctl -u shadowsocks-libev --since "5 minutes ago"   # за последние 5 минут
```
