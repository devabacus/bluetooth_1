# Инициализация и настройка
git init                                             # gitinit - Инициализация нового репозитория
git config --global user.name "Ваше Имя"            # gituser - Настройка имени пользователя
git config --global user.email "ваш.email@example.com" # gitemail - Настройка email

# Основные операции
git status                                           # gitst - Проверка состояния репозитория
git add .                                            # gitaa - Добавить все файлы в индекс
git add имя_файла                                    # gitadd - Добавить конкретный файл в индекс
git commit -m "Описание коммита"                     # gitcmt - Создать коммит с сообщением
git commit -am "Описание коммита"                    # gitcmta - Добавить все изменения и создать коммит

# Работа с удаленными репозиториями
git clone https://github.com/пользователь/репозиторий.git  # gitcl - Клонировать репозиторий
git remote add origin https://github.com/пользователь/репозиторий.git  # gitrema - Добавить удаленный репозиторий
git remote -v                                         # gitremv - Посмотреть список удаленных репозиториев
git push -u origin main                              # gitpushf - Отправить изменения в удаленный репозиторий (первый раз)
git push                                             # gitpush - Отправить изменения (последующие разы)
git pull                                             # gitpull - Получить и слить изменения из удаленного репозитория
git fetch                                            # gitf - Получить изменения без слияния

# Работа с ветками
git branch                                           # gitbls - Показать список веток
git branch имя_ветки                                 # gitbc - Создать новую ветку
git checkout имя_ветки                               # gitbco - Переключиться на ветку
git checkout -b имя_ветки                            # gitbch - Создать и переключиться на новую ветку
git merge имя_ветки                                  # gitbm - Слить указанную ветку с текущей
git branch -d имя_ветки                              # gitbd - Удалить ветку (если она слита)
git branch -D имя_ветки                              # gitbrD - Принудительно удалить ветку

# История и разница
git log                                              # gitlog - Просмотр истории коммитов
git log --oneline                                    # gitlogo - Краткий просмотр истории (одна строка на коммит)
git log --graph --oneline --all                      # gitlogg - Графическое отображение истории всех веток
git diff                                             # gitd - Показать изменения в рабочей директории
git diff --staged                                    # gitds - Показать изменения в индексе
git diff коммит1 коммит2                             # gitdc - Показать разницу между двумя коммитами

# Отмена изменений
git restore имя_файла                                # gitr - Отменить изменения в файле (Git 2.23+)
git restore --staged имя_файла                       # gitrs - Убрать файл из индекса (Git 2.23+)
git reset HEAD имя_файла                             # gitreset - Убрать файл из индекса (старый синтаксис)
git reset --hard HEAD                                # gitresethard - Отменить все изменения и вернуться к последнему коммиту
git revert коммит_id                                 # gitrevert - Создать новый коммит, отменяющий указанный

# Работа со стеком изменений
git stash                                            # gitstash - Сохранить текущие изменения во временном хранилище
git stash list                                       # gitstashl - Показать список сохраненных изменений
git stash apply                                      # gitsasha - Применить последние сохраненные изменения (не удаляя их из стека)
git stash pop                                        # gitsashp - Применить и удалить последние сохраненные изменения
git stash drop                                       # gitsashd - Удалить последние сохраненные изменения

# Продвинутые команды
git tag имя_тега                                     # gittag - Создать тег для текущего коммита
git tag -a имя_тега -m "Описание тега"               # gittga - Создать аннотированный тег
git push origin имя_тега                             # gittgpush - Отправить тег в удаленный репозиторий
git push --tags                                      # gittgspush - Отправить все теги в удаленный репозиторий
git rebase ветка                                     # gitrebase - Перебазировать текущую ветку на указанную
git cherry-pick коммит_id                            # gitcp - Применить изменения из указанного коммита