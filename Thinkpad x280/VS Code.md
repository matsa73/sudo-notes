### Шаг 1: Установка VS Code

Лучше всего ставить официальную сборку от Microsoft, чтобы не было проблем с обновлениями и подписью ключей.

Откройте терминал и выполните команды по очереди:
```bash
# 1. Установите необходимые пакеты для добавления репозитория
sudo apt update
sudo apt install wget gpg

# 2. Добавьте ключ и репозиторий Microsoft
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# 3. Установите VS Code
sudo apt update
sudo apt install code
```

```bash
# Обновить индекс пакетов и поставить зависимости
sudo apt update
sudo apt install -y wget gpg

# Добавить GPG-ключ Microsoft
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm packages.microsoft.gpg

# Добавить репозиторий
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.sources.list

# Установить
sudo apt update
sudo apt install -y code
```

### Шаг 2: Базовая настройка .NET и C# в Linux

Акцент на работу с .NET через терминал — это один из главных навыков.

**Установка .NET SDK 8:**
1. Установить необходимые утилиты:
```bash
sudo apt update
sudo apt install wget gpg
```

2. Добавить ключ и репозиторий .NET (для Ubuntu 22.04, т.к. он совместим):
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/dotnet-sdk.list'
rm -f packages.microsoft.gpg
```

3. Установить `.NET SDK 8`:
На этом этапе важно помнить про потенциальную проблему с библиотекой `libicu` в Ubuntu 24.04.

```bash
sudo apt update
sudo apt install dotnet-sdk-8.0
```

Если была получена ошибка о неудовлетворённой зависимости `libicu` или `libicu72`, то сначала необходимо исправить зависимости, временно добавив репозиторий Ubuntu 22.04:
```bash
echo "deb http://archive.ubuntu.com/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/libicu-jammy.list
sudo tee /etc/apt/preferences.d/libicu <<EOF
Package: libicu*
Pin: release n=jammy
Pin-Priority: 100
EOF
sudo apt update
sudo apt install dotnet-sdk-8.0
```

4. Проверка установки:
```bash
dotnet --version
```

### Шаг 3: Настройка HTTP-proxy

1. Открыть VS Code и нажмите `Ctrl + Shift + P`.
2. Выберать **Preferences: Open User Settings (JSON)**.
3. Добавить в файл следующие строки (указать порт `privoxy`):
```json
{
    "http.proxy": "http://127.0.0.1:8118", 
    "http.proxyStrictSSL": false,
    "http.proxySupport": "on"
}
```
4. Проверка: В VS Code открыть вкладку **Output** (Вид -> Выходные данные) и переключиться на выпадающий список `GitHub Copilot`. Попробовать задать вопрос чату — в логах не должно быть ошибок `ECONNREFUSED` или `Failed to establish a socket connection`.
### Шаг 3: Расширения

0. Foam — это open-source аналог обсидиановских вики-ссылок и графа заметок прямо поверх обычных .md файлов в git-репозитории, без всякой подписки
1. **LeetCode** (автор: LeetCode) — позволит решать задачи прямо в редакторе, не открывая браузер. Расходует минимум ресурсов.
2. Roo Code - AI-агент с глубочайшей нативной интеграцией OpenRouter
3. **C# Dev Kit** (автор: Microsoft)
4. **EditorConfig**
5. SQLite Viewer
6. VSCode icons
7. ESLint
8. Prettier - Code formatter
#### Шаг 3.1: Настройка расширения LeetCode (важно)

Расширение LeetCode для VS Code требует установленный Node.js. Оно использует Node для запуска фонового процесса `leetcode-cli`, который и выполняет всю работу: загружает задачи, отправляет решения на проверку.

1. Подключить репозиторий и установить Node.js:
```bash
# Сначала скачиваем и запускаем скрипт для подключения репозитория NodeSource,
# который содержит свежие версии Node.js.
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Теперь устанавливаем Node.js. Вместе с ним автоматически установится и npm.
sudo apt install -y nodejs

node -v # v20.x.x
npm -v # 10.x.x
```

2. После установки расширения LeetCode слева появится новая иконка (символ LeetCode).
3. Нажмите на неё и выберите **Sign In**. Проще всего войти через cookie или GitHub.
4. После входа откроется дерево задач. При первом открытии задачи расширение спросит, в какой папке сохранять файлы. Укажите удобную вам, например `~/leetcode/`.
#### Шаг 3.2: Настройка расширения Roo Code

**Roo Code** — это AI-агент в VS Code (сам пишет код, работает с файлами и терминалом). **OpenRouter / RouterAI** — агрегаторы, дающие доступ к десяткам нейросетей по API.

1. **Ключ:** Получь API-ключ в личном кабинете **OpenRouter** ([openrouter.ai/keys](https://openrouter.ai/keys)).
2. **Провайдер:** В Roo Code открыть настройки (⚙️), создать профиль и выберать провайдера **OpenRouter**.
3. **Подключение:** Вставить скопированный ключ. Модели прогрузятся автоматически.
4. **Выбор:** В выпадающем списке выберите нужную LLM (например, MiniMax M2.5 для кода).

**Главный лайфхак:** Создать 3-4 отдельных профиля ("Кодинг", "Диалог", "Хардкор") и закрепить их. Переключаться между разными моделями под задачу можно будет в 1 клик.

**Важно**: Оплата OpenRouter из России не производится, но можно это сделать через [ggsel.net](https://ggsel.net/)
### Важный совет по управлению ресурсами

На 8 ГБ ОЗУ главное — не открывать одновременно десятки расширений и вкладок в браузере. Для алгоритмических задач связка **VS Code (с C# Dev Kit) + Терминал** будет использовать около 1,5–2 ГБ ОЗУ, что оставляет много свободной памяти.
