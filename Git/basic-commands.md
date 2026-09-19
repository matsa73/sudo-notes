1. Клонирование репозитория:
   - Использование HTTPS: `git clone <https://github.com/><имя-пользователя>/<имя-репозитория>.git`
   - Использование SSH: `git clone <git@github.com>:<имя-пользователя>/<имя-репозитория>.git`

2. Перенос коммита:
   - Переключитесь на целевую ветку: `git checkout <target-branch>`
   - Выполнить cherry-pick: `git cherry-pick <hash-commit>`
   - Перенос нескольких коммитов: `git cherry-pick a1b2c3d e4f5g6h`
   - Перенос диапазона коммитов: `git cherry-pick <start-hash^..end-hash>`

3. Многострочный коммит:

   - через редактор: `git commit`
   - несколько флагов `-m`: `git commit -m "Краткое описание" -m "Подробное описание исправления 1" -m "Вторая строка подробностей."` - Каждый `-m` создаёт новый абзац
   - heredoc в bash:

      ```bash
      git commit -F- <<EOF
      Краткое описание

      Подробное описание изменений`.
      Вторая строка подробностей.

      Closes #123
      EOF
      ```

tags: [git, gitbash, console]
