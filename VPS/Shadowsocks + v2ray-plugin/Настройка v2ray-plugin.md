# Настройка v2ray-plugin

## Конфигурация

В конец конфигурационного файла необходимо добавить две строчки:

```bash
sudo nano /etc/shadowsocks-libev/config.json
```

```json
{
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;host=www.microsoft.com;path=/;mux=0"
}
```

⚠️ Параметр `mux` в `v2ray-plugin` на сервере должен быть отключён для корректной работы плагина в режиме WebSocket, чтобы избежать конфликтов.

Список проверенных доменов (`host`):

- ✅`www.microsoft.com`
- ✅`www.bing.com`
- ❓`login.live.com`
- ✅`www.icloud.com`
- ✅`www.cloudflare.com`
