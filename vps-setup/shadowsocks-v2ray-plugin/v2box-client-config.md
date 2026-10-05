# Конфигурация клиента V2Box

Клиент для Shadowsocks-сервера с плагином `v2ray-plugin` (транспорт WebSocket, без TLS, порт 443).

## 1. Configs

Добавить новое подключение: `+` → `Add manual config` → `shadowsocks`.

| Поле      | Значение                 |
| --------- | ------------------------ |
| address   | `<SERVER_IP>`            |
| port      | `443`                    |
| password  | `<PASSWORD>`             |
| security  | `chacha20-ietf-poly1305` |
| network   | `ws`                     |
| head type | `---`                    |
| ws host   | `www.microsoft.com`      |
| ws path   | `/`                      |
| TLS       | `none`                   |

Значения `security`, `ws host` и `ws path` должны совпадать с [конфигурацией сервера](server-config.md#4-конфигурация).

## 2. Tunnel Settings

- **Per-app proxy**: включить и выбрать приложения из списка. Выбранные приложения идут через туннель напрямую, а с `Bypass Mode` наоборот.
- **Mux**: включить со значениями по умолчанию.
- **SOCKS5 UDP**: включить.

## 3. Route Settings

### Файлы баз

Используются наборы `geosite.dat` от проекта [roscomvpn-geosite](https://github.com/hydraponique/roscomvpn-geosite) и `geoip.dat` от проекта [roscomvpn-geoip](https://github.com/hydraponique/roscomvpn-geoip).

`Geo asset files` → `+` → `Add URL`:

| Файл          | Основная ссылка                                                                                  | Зеркало (jsDelivr)                                                                    |
| ------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `geosite.dat` | [GitHub](https://github.com/hydraponique/roscomvpn-geosite/releases/latest/download/geosite.dat) | [CDN](https://cdn.jsdelivr.net/gh/hydraponique/roscomvpn-geosite/release/geosite.dat) |
| `geoip.dat`   | [GitHub](https://github.com/hydraponique/roscomvpn-geoip/releases/latest/download/geoip.dat)     | [CDN](https://cdn.jsdelivr.net/gh/hydraponique/roscomvpn-geoip/release/geoip.dat)     |

Эти файлы необходимо периодически обновлять вручную.

### Правила маршрутизации

`Geo asset files` → `Rules` → `⋮` → `Import rulset from clipboard`: [routing-client-rules.json](routing-client-rules.json) - скопируйте содержимое файла в буфер обмена
`Geo asset files` → `Rules` → `domainStrategy` = `IPifNonMatch`

Логика правил (сверху вниз):

1. **Block** — реклама, телеметрия Windows, торренты.
2. **Geoip Direct** — локальные и «прямые» IP.
3. **Direct** — российские и whitelist-домены, сервисы Microsoft/Apple, игровые платформы, зоны `.ru`, `.kz`, `.su`, `.рф`.
4. **dns** — UDP-запросы к публичным DNS-серверам идут через прокси.
5. **Proxy** — Google Play, GitHub, YouTube, Telegram.

## 4. DNS Settings

`VPN DNS (только IPv4/v6)` = `77.88.8.8`

## Ссылки

- [Обсуждение настройки geosite для v2rayNG (4PDA)](https://4pda.to/forum/index.php?showtopic=1033788&st=3480#entry143004415)
- [Маршрутизация RoscomVPN](https://4pda.to/forum/index.php?showtopic=1033788&st=3480#entry143004415)
