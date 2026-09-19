# Firefox

ПОЛНЫЙ ГАЙД: Установка Firefox на Ubuntu 26.04 / Lubuntu 26.04 без Snap

## Вступление

Ubuntu 26.04 LTS («Resolute Raccoon», релиз — апрель 2026) и Lubuntu 26.04, как и предыдущие версии, по умолчанию устанавливают Firefox через **Snap**. Это по‑прежнему приводит к:

- Медленному первому запуску (распаковка squashfs-образа)
- Повышенному потреблению памяти
- Проблемам с интеграцией в лёгкое окружение LXQt

Этот гайд ставит **обычную deb-версию Firefox** из официального репозитория Mozilla и полностью блокирует Snap-версию.

**Важное отличие от версии для 24.04:** начиная с Ubuntu «Resolute» (26.04) / Debian «Trixie», Mozilla официально рекомендует **новый формат файла репозитория** (deb822, `.sources`) вместо старого однострочного `.list`. Также изменился рекомендуемый порядок блокировки Snap — сначала пины, потом удаление snap-пакета, а не наоборот. Ниже — исправленный порядок действий.

---

## Часть 1. Подготовка системы

### Шаг 1.1: Устанавливаем базовые утилиты

```bash
sudo apt update
sudo apt install curl ca-certificates wget -y
```

**Что сделали:** установили программы для скачивания файлов и корневые сертификаты для безопасных соединений.

### Шаг 1.2: Проверяем, есть ли уже Snap-версия Firefox

```bash
which firefox
snap list 2>/dev/null | grep firefox
```

Если видите путь `/snap/bin/firefox` или `firefox` в списке snap-пакетов — Snap-версия установлена. Мы заблокируем и удалим её в Части 3, **но в правильном порядке** (сначала пины — потом удаление).

> На Lubuntu Snap-версии Firefox иногда вообще нет из коробки — в этом случае просто пропустите шаги про `snap remove`.

---

## Часть 2. Добавляем репозиторий Mozilla

### Шаг 2.1: Создаём папку для ключей

Официальная инструкция Mozilla рекомендует создавать папку сразу с нужными правами:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

**Проверка:**

```bash
ls -ld /etc/apt/keyrings
```

Должно показать: `drwxr-xr-x 2 root root 4096 ...`

### Шаг 2.2: Скачиваем ключ подписи Mozilla

```bash
sudo curl -fsSLo /etc/apt/keyrings/packages.mozilla.org.asc https://packages.mozilla.org/apt/repo-signing-key.gpg
```

**Проверка файла:**

```bash
file /etc/apt/keyrings/packages.mozilla.org.asc
```

Ожидаемый вывод: `/etc/apt/keyrings/packages.mozilla.org.asc: OpenPGP Public Key`

### Шаг 2.3: Проверяем отпечаток ключа (новый шаг, рекомендован Mozilla)

Отпечаток должен совпадать с `35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`:

```bash
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc \
  | awk '/pub/{getline; gsub(/^ +| +$/,""); \
    if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") \
      print "\nОтпечаток совпадает ("$0").\n"; \
    else \
      print "\nПРОВЕРКА НЕ ПРОЙДЕНА: отпечаток ("$0") не совпадает с ожидаемым.\n"; }'
```

Если отпечаток не совпал — **не продолжайте**, скачайте ключ заново и проверьте, что curl ходит именно на `packages.mozilla.org` (не через подменяющий прокси/MITM).

### Шаг 2.4: Устанавливаем права на ключ

```bash
sudo chmod 644 /etc/apt/keyrings/packages.mozilla.org.asc
sudo chown root:root /etc/apt/keyrings/packages.mozilla.org.asc
```

### Шаг 2.5: Добавляем сам репозиторий

Для **Ubuntu 26.04 (Resolute) / Lubuntu 26.04** используйте новый deb822-формат:

```bash
sudo tee /etc/apt/sources.list.d/mozilla.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
```

> Если вы всё ещё держите где-то Ubuntu 24.04 / Lubuntu 24.04 (например, на ThinkPad до апгрейда) — там нужен старый однострочный формат:
>
> ```bash
> echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list
> ```
>
> Не создавайте оба файла одновременно на одной системе — apt подключит репозиторий дважды.

**Проверка:**

```bash
cat /etc/apt/sources.list.d/mozilla.sources
```

---

## Часть 3. Блокировка Snap (порядок важен!)

Официальная инструкция Mozilla теперь явно указывает: **сначала пины, потом `snap remove`**. Если удалить snap-пакет раньше, чем настроен pinning, apt/snapd может незаметно откатить всё обратно на snap при следующем обновлении.

### Шаг 3.1: Пин на приоритет пакетов Mozilla

```bash
sudo tee /etc/apt/preferences.d/mozilla > /dev/null << 'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
```

Это значит: «всё, что приходит с packages.mozilla.org, имеет наивысший приоритет».

### Шаг 3.2: Отдельный пин, запрещающий firefox из архива Ubuntu

Это тот самый пакет-пустышка, который в обычной Ubuntu тянет за собой snap:

```bash
sudo tee /etc/apt/preferences.d/mozilla-block-snap > /dev/null << 'EOF'
Package: firefox
Pin: release o=Ubuntu
Pin-Priority: -1
EOF
```

**Что означают цифры:**

- **-1** — полностью запрещает установку из этого источника
- **1000** — высший приоритет, apt выберет именно этот источник

### Шаг 3.3: Только теперь удаляем Snap-версию (если она есть)

```bash
snap list 2>/dev/null | grep firefox
sudo snap remove firefox 2>/dev/null
sudo apt remove firefox 2>/dev/null
sudo apt autoremove -y
```

---

## Часть 4. Установка Firefox

### Шаг 4.1: Обновляем списки пакетов

```bash
sudo apt update
```

В выводе должна появиться строка с `packages.mozilla.org` и **никаких ошибок** про ключи/подписи.

### Шаг 4.2: Проверяем, откуда будет ставиться Firefox

```bash
apt policy firefox
```

Ожидаемо увидеть что-то вроде:

```text
firefox:
  Installed: (none)
  Candidate: <версия из Mozilla>
  Version table:
     <версия из Mozilla> 1000
        500 https://packages.mozilla.org/apt mozilla/main amd64 Packages
     1:1snap1-... -1
        500 http://archive.ubuntu.com/ubuntu resolute/main amd64 Packages
```

Версия Mozilla должна иметь приоритет **1000**, версия Ubuntu — **-1**.

### Шаг 4.3: Устанавливаем Firefox

```bash
sudo apt install firefox -y
```

### Шаг 4.4: Проверяем установку

```bash
which firefox
```

Должно показать: `/usr/bin/firefox` (НЕ `/snap/bin/firefox`).
Запустите Firefox: `firefox`

---

## Часть 5. Проверка, что Snap побеждён

### Шаг 5.1: Проверяем версию в самом браузере

1. Откройте Firefox
2. Меню (три полоски) → Справка → О Firefox
3. **Правильно:** обычный номер версии, никаких упоминаний Snap
4. **Неправильно:** версия `esr` без вашего выбора или пометка «Установлен как snap»

### Шаг 5.2: Проверяем, не вернулся ли Snap

```bash
snap list 2>/dev/null | grep firefox
```

Команда не должна ничего выводить.

---

## Часть 6. Что делать, если Snap всё равно лезет

### Проблема: `apt update` показывает ошибки про ключи

Повторите шаги 2.2–2.4, проверьте отпечаток ключа (2.3).

### Проблема: при установке тянет Snap или пишет про snapd

Проверьте файлы приоритетов:

```bash
cat /etc/apt/preferences.d/mozilla
cat /etc/apt/preferences.d/mozilla-block-snap
```

Убедитесь, что в них именно те строки, что мы добавляли в Части 3.

### Проблема: `apt policy firefox` показывает, что Ubuntu-версия имеет приоритет выше 1000

Удалите все конфликтующие файлы приоритетов и создайте наши заново:

```bash
sudo rm -f /etc/apt/preferences.d/firefox*
sudo rm -f /etc/apt/preferences.d/mozilla*
# и заново выполните шаги 3.1 и 3.2
```

### Крайний случай: если совсем не получается с репозиторием

Скачайте официальный tarball с сайта Mozilla — это гарантированно не Snap и не требует root:

```bash
cd /tmp
wget -O firefox.tar.xz "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=ru"
tar -xJf firefox.tar.xz -C ~/
~/firefox/firefox
```

Актуальная страница загрузок: `https://www.firefox.com/browsers/desktop/linux/` — там же можно выбрать конкретный канал (Beta, Nightly, Developer, ESR).

---

## Часть 7. Полезные команды для диагностики

```bash
# Откуда система собирается брать Firefox?
apt policy firefox

# Какие ключи добавлены в APT?
ls -la /etc/apt/keyrings/

# Какие репозитории Firefox подключены?
ls -la /etc/apt/sources.list.d/ | grep -i mozilla
cat /etc/apt/sources.list.d/mozilla.sources 2>/dev/null

# Какие правила приоритетов стоят?
cat /etc/apt/preferences.d/*

# Есть ли Snap в системе?
snap list 2>/dev/null
```

---

## Часть 8. Настройка аппаратного ускорения видео

1. В адресной строке введите `about:config`, подтвердите, что будете осторожны.
2. Прежде чем что-то менять, откройте `about:support` и посмотрите поле **Compositing** в разделе «Функции возможностей» (Graphics Features) — если там уже написано `WebRender`, аппаратное ускорение композитинга и так включено по умолчанию, и часть настроек ниже можно не трогать.
3. Если декодирование видео не аппаратное (проверяется там же, поле про video decoding), можно донастроить следующие параметры:

| Параметр                                       | Значение   | Назначение                                                                               |
| ---------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------- |
| `media.ffmpeg.vaapi.enabled`                   | `true`     | Включает использование VA-API через FFmpeg для аппаратного декодирования видео.          |
| `media.ffvpx.enabled`                          | `false`    | Отключает встроенный декодер FFmpeg Firefox (ffvpx).                                     |
| `media.navigator.mediadatadecoder_vpx_enabled` | `true`     | Аппаратное декодирование для кодеков VP8 и VP9.                                          |
| `media.rdd-ffmpeg.enabled`                     | `true`     | Изоляция FFmpeg в отдельном процессе RDD (Remote Data Decoder).                          |
| `media.rdd-vpx.enabled`                        | `false`    | Аналогично, но специально для декодеров VP8/VP9.                                         |
| `widget.dmabuf.force-enabled`                  | `true`     | Принудительно включает использование DMA-BUF.                                            |
| `gfx.webrender.all`                            | `true`     | Включает WebRender для всего контента.                                                   |
| `gfx.webrender.enabled`                        | `true`     | Явно включает WebRender как активный композитор.                                         |
| `layers.acceleration.force-enabled`            | `true`     | Принудительно включает аппаратное ускорение слоёв.                                       |
| `media.hardware-video-decoding.force-enabled`  | `true`     | Принудительно включает аппаратное декодирование, игнорируя проверки совместимости.       |
| `media.hardware-video-decoding.enabled`        | `true`     | Базовый включатель аппаратного декодирования видео.                                      |

Если параметра нет в списке — его нужно создать вручную (кнопка добавления новой строки).

1. **Полностью перезапустите Firefox**, чтобы изменения вступили в силу.

> Эти конкретные имена параметров в Firefox исторически стабильны, но в новых версиях часть аппаратного декодирования на Linux/VA‑API включена по умолчанию — поэтому шаг 2 (проверка через `about:support`) стоит делать в первую очередь, чтобы не включать вслепую то, что уже работает.

---

## Часть 9. Настройка плагина OpenH264 Video Codec

Видео форматов mpeg4/mp4 может не загружаться из-за отсутствия плагина OpenH264.

Типичная ошибка: ⚠️ OpenH264 provided by Cisco Systems, Inc will be installed shortly.

Варианты решения:

1. **Установить системные кодеки**

```bash
sudo apt update && sudo apt install ubuntu-restricted-extras -y
```

После установки **обязательно перезапустите Firefox**.
2. **Временно отключить «Только HTTPS»**
Иногда плагин не может установиться из-за сертификата сервера Cisco:

- Перейдите в `about:preferences#privacy`
- Раздел Privacy & Security → HTTPS-Only Mode
- Временно выберите «Don't enable HTTPS-Only Mode»
- Вернитесь в `about:addons` → Plugins и переустановите плагин
- После установки верните HTTPS-Only Mode обратно

3. **Использовать VPN**, если сервер Cisco заблокирован на уровне провайдера.

Если возникает проблема с перемоткой такого видео — обязательно включите `media.rdd-ffmpeg.enabled` из Части 8.

---

## Часть 10. Проксирование трафика через FoxyProxy

1. Отключите ручное управление DNS в `about:config`, установив `network.proxy.socks_remote_dns` = `false` — это отдаёт управление DNS расширению через прокси, чтобы DNS-запросы не утекали в обход прокси (что ломает доступ к сайтам, заблокированным по IP/DNS у провайдера).
2. Используйте **строгие шаблоны с указанием протокола и слэша**: `*://*имя_домена/*`, чтобы чётко ограничить домен.
3. Не забывайте добавлять поддомены CDN, с которых сайт может тянуть контент — иначе часть ресурсов не пройдёт через прокси.