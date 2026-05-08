# vs_code_config

Личный профиль Visual Studio Code: настройки, горячие клавиши, сниппеты и список расширений.

Снимок собран после восстановления профиля 7 мая 2026. В конфиг входят тема `2077`, настройки Vim, автосохранение, Go/Python/C++/Java/PHP/Remote/Jupyter-расширения и остальные расширения, которые были установлены в профиле.

## Что где лежит

- `config/settings.json` - пользовательские настройки VS Code.
- `config/keybindings.json` - пользовательские горячие клавиши.
- `snippets/` - пользовательские snippets.
- `extensions/extensions.txt` - список расширений для установки через VS Code CLI.
- `scripts/install.ps1` - скрипт установки профиля на Windows.
- `profiles/daniil-vscode.code-profile` - готовый экспорт профиля для импорта через UI VS Code.

## Импорт через VS Code

Это самый удобный вариант для другого компьютера.

1. Скачай файл `profiles/daniil-vscode.code-profile` из репозитория.
2. Открой VS Code.
3. Нажми `Ctrl+Shift+P`.
4. Запусти команду `Profiles: Import Profile...`.
5. Выбери скачанный файл `daniil-vscode.code-profile`.
6. В окне импорта оставь включенными `Settings`, `Keyboard Shortcuts`, `Snippets` и `Extensions`.
7. Нажми `Create` / `Import`.

Если VS Code спросит, ставить ли расширения, подтверди установку. После импорта лучше перезапустить VS Code.

## Установка на Windows

1. Закрой VS Code.
2. Склонируй репозиторий:

```powershell
git clone git@github.com:daniil-novel/vs_code_config.git
cd vs_code_config
```

3. Запусти установку:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\install.ps1
```

Скрипт сначала создаст бэкап текущего профиля на рабочем столе, затем скопирует настройки и поставит расширения из `extensions/extensions.txt`.

## Только расширения

```powershell
.\scripts\install.ps1 -ExtensionsOnly
```

## Только настройки

```powershell
.\scripts\install.ps1 -SkipExtensions
```

## Ручная установка

Настройки VS Code на Windows лежат здесь:

```text
%APPDATA%\Code\User
```

Можно вручную скопировать:

- `config/settings.json` -> `%APPDATA%\Code\User\settings.json`
- `config/keybindings.json` -> `%APPDATA%\Code\User\keybindings.json`
- `snippets/*` -> `%APPDATA%\Code\User\snippets\`

Расширения можно поставить так:

```powershell
Get-Content .\extensions\extensions.txt | ForEach-Object { code --install-extension $_ }
```

## Обновление снимка

После изменения профиля локально:

```powershell
Copy-Item "$env:APPDATA\Code\User\settings.json" .\config\settings.json -Force
Copy-Item "$env:APPDATA\Code\User\keybindings.json" .\config\keybindings.json -Force
Copy-Item "$env:APPDATA\Code\User\snippets\*" .\snippets\ -Force
code --list-extensions | Sort-Object | Set-Content .\extensions\extensions.txt
git add .
git commit -m "update vscode profile"
git push
```

## Важно про Settings Sync

Если VS Code Settings Sync спросит, чью версию оставить после установки, выбирай локальную версию. Иначе облачный дефолтный профиль может снова перетереть восстановленный конфиг.
