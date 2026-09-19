# Настройка v2ray-plugin

## Конфигурация

В конец конфигурационного файла необходимо добавить две строчки:

```bash
sudo nano /etc/shadowsocks-libev/config.json
```

```json
{
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;host=max.ru;path=/;mux=0"
}
```

⚠️ Есть несовместимость `Mux` в `v2ray-plugin` на сервере и в `V2Box`. Поэтому на сервере `Mux` отключён. Но в `V2Box` можно в настройках самого приложения включить `Mux`:

- `mux_concurrency` = 4 или 8
- `xudpProxyUDP443` = allow

Список проверенных доменов (`host`):

- ❌ [icloud.com](https://icloud.com/)
- ❌ [bing.com](https://bing.com/)
- ❌ [microsoft.com](https://microsoft.com/)
- ❌ [live.com](https://live.com/)
- ❌ [Cloudflare.com](https://cloudflare.com/)
- ❌ [cloudfront.com](https://cloudfront.com/)
- ✅ [max.ru](https://max.ru/)
