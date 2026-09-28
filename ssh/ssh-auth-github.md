# Подключение к GitHub

Разумно использовать **отдельный ключ** для GitHub, а не тот же, что для VPS: разные зоны доверия, ключ можно отозвать на GitHub независимо от доступа к серверам, плюс GitHub поддерживает **deploy keys** — ключи, привязанные к конкретному репозиторию (например, для CI/CD-сервера, которому не нужен доступ ко всему аккаунту).

## Linux/Windows

1. Сгенерировать ключ, с отдельным именем файла:

    ```bash
    ssh-keygen -t ed25519 -C "email@example.com" -f ~/.ssh/id_ed25519_github
    ```

2. Добавить в ssh-agent:

    ```bash
    ssh-add ~/.ssh/id_ed25519_github
    ```

3. Скопировать публичный ключ и добавить на GitHub:

    ```bash
    cat ~/.ssh/id_ed25519_github.pub
    ```

    → GitHub → **Settings → SSH and GPG keys → New SSH key** → вставить.

4. Добавить хост в `~/.ssh/config`:

    ```text
    Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519_github
        IdentitiesOnly yes
    ```

5. Проверить аутентификацию (не открывает шелл, GitHub не даёт интерактивный доступ — это ожидаемо):

    ```bash
    ssh -T git@github.com
    # Hi username! You've successfully authenticated, but GitHub does not provide shell access.
    ```

6. Клонировать репозиторий по SSH (не HTTPS):

    ```bash
    git clone git@github.com:username/repo.git
    ```

7. Перевести уже склонированный по HTTPS репозиторий на SSH:

    ```bash
    git remote set-url origin git@github.com:username/repo.git
    git remote -v   # проверить
    ```

## Несколько GitHub-аккаунтов (личный + рабочий)

Стандартная проблема: `Host github.com` может указывать только на один ключ. Решение — завести дополнительный алиас:

```text
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

Клонирование и `remote` для рабочих репозиториев — через алиас вместо `github.com`:

```bash
git clone git@github.com-work:org/repo.git
git remote set-url origin git@github.com-work:org/repo.git
```

Git не путает `github.com-work` с настоящим доменом — для git это просто условное имя хоста, которое SSH сам сопоставляет с `HostName` и нужным ключом из `config`.
