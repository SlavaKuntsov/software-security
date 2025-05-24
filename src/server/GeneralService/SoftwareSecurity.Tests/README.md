# Юнит-тестирование в SoftwareSecurity

## Описание

Этот проект содержит юнит-тесты для приложения SoftwareSecurity, охватывающие функциональность чата и другие компоненты системы.

## Структура тестов

Тесты организованы по следующим категориям:

- **Controllers** - тесты для контроллеров API
- **Handlers** - тесты для обработчиков команд и запросов
  - **Auth** - тесты для аутентификации
  - **Tokens** - тесты для работы с токенами
  - **ChatServiceTests** - тесты для сервиса чата
  - **ChatHubTests** - тесты для SignalR хаба чата
  - **ChatRepositoryTests** - тесты для репозитория чата

## Запуск тестов

### Запуск через Visual Studio

1. Откройте решение SoftwareSecurity.sln
2. Откройте Test Explorer (Test > Test Explorer)
3. Нажмите "Run All Tests"

### Запуск через командную строку

```bash
dotnet test SoftwareSecurity.Tests/SoftwareSecurity.Tests.csproj
```

## Проверка покрытия кода

Для проверки покрытия кода используется coverlet и reportgenerator.

### Windows

```bash
.\run-tests-with-coverage.bat
```

### Linux/macOS

```bash
chmod +x run-tests-with-coverage.sh
./run-tests-with-coverage.sh
```

После выполнения скрипта отчет о покрытии будет сгенерирован в директории `SoftwareSecurity.Tests/TestResults/CoverageReport` и автоматически открыт в браузере.

## Цель покрытия

Целевое покрытие кода тестами - не менее 80%. Текущие тесты охватывают основные компоненты системы:

- Сервисы чата
- Контроллеры API
- SignalR хабы
- Репозитории данных

## Добавление новых тестов

При добавлении новой функциональности в систему, необходимо также добавлять соответствующие тесты, следуя существующей структуре и шаблонам. 