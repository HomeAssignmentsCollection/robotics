# 🤖 Автоматическое Версионирование

## 📋 Обзор

В проекте настроено автоматическое версионирование через GitHub Actions. Есть несколько способов управления версиями:

## 🚀 Способы изменения версии

### 1. **Автоматическое (при каждом push в main)**

**Workflow:** `.github/workflows/auto-version.yml`

**Как работает:**
- При каждом push в ветку `main` автоматически увеличивается patch версия
- Исключения: изменения в файле `VERSION` и самом workflow
- Создается Git тег и GitHub Release
- Запускается основной CI/CD pipeline

**Пример:**
```bash
# Текущая версия: 1.0.2
git push origin main
# Результат: версия автоматически станет 1.0.3
```

### 2. **Ручное через GitHub Actions**

**Workflow:** `.github/workflows/manual-version.yml`

**Как использовать:**
1. Перейти в GitHub → Actions
2. Выбрать "Manual Version Management"
3. Нажать "Run workflow"
4. Выбрать тип версии:
   - `patch` - 1.0.2 → 1.0.3
   - `minor` - 1.0.2 → 1.1.0
   - `major` - 1.0.2 → 2.0.0
5. Опционально указать кастомную версию

### 3. **Локальное управление**

**Скрипт:** `scripts/version.sh`

```bash
# Показать текущую версию
./scripts/version.sh get

# Увеличить patch версию
./scripts/version.sh bump patch

# Увеличить minor версию
./scripts/version.sh bump minor

# Увеличить major версию
./scripts/version.sh bump major

# Создать релиз
./scripts/version.sh release
```

## 🔄 Процесс автоматического версионирования

### Шаг 1: Auto Version Workflow
```yaml
# .github/workflows/auto-version.yml
on:
  push:
    branches: [ main ]
    paths-ignore:
      - 'VERSION'  # Исключаем изменения в VERSION
```

### Шаг 2: Увеличение версии
```bash
# Получить текущую версию
CURRENT_VERSION=$(./scripts/version.sh get)

# Увеличить patch версию
NEW_VERSION=$(./scripts/version.sh bump patch)

# Закоммитить изменения
git add VERSION
git commit -m "chore: auto bump version to $NEW_VERSION [skip ci]"
git push origin main
```

### Шаг 3: Создание тега и релиза
```bash
# Создать Git тег
git tag -a "v$VERSION" -m "Auto release version $VERSION"
git push origin "v$VERSION"

# Создать GitHub Release
# (автоматически через actions/create-release@v1)
```

### Шаг 4: Основной CI/CD Pipeline
```yaml
# .github/workflows/ci-cd.yml
# Запускается после изменения версии
jobs:
  - version-management  # Читает новую версию
  - test               # Тестирование
  - build-and-push     # Сборка и загрузка в ECR
  - deploy             # Развертывание в ECS
  - notify-deployment  # Уведомление о завершении
```

## 📊 Структура версий

### Семантическое версионирование
```
MAJOR.MINOR.PATCH
   1  .  0  .  2
```

- **MAJOR** - несовместимые изменения API
- **MINOR** - новая функциональность (обратная совместимость)
- **PATCH** - исправления багов (обратная совместимость)

### Примеры
```bash
1.0.2 → 1.0.3  # patch
1.0.2 → 1.1.0  # minor
1.0.2 → 2.0.0  # major
```

## 🔧 Настройка

### Переменные окружения
```bash
# В приложении
APP_VERSION = os.getenv('APP_VERSION', '1.0.2')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.datetime.now().isoformat())
VCS_REF = os.getenv('VCS_REF', 'latest')
```

### Docker build arguments
```dockerfile
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

ENV APP_VERSION=$APP_VERSION \
    BUILD_DATE=$BUILD_DATE \
    VCS_REF=$VCS_REF
```

### GitHub Actions
```yaml
docker build -f docker/Dockerfile \
  --build-arg APP_VERSION=$VERSION \
  --build-arg BUILD_DATE=$BUILD_DATE \
  --build-arg VCS_REF=$GIT_COMMIT \
  -t devops-cicd-demo:$VERSION .
```

## 🎯 Рекомендации

### Для разработки
1. **Обычные изменения:** Просто push в main → автоматическое увеличение patch версии
2. **Новые функции:** Использовать manual workflow → minor версия
3. **Критические изменения:** Использовать manual workflow → major версия

### Для релизов
1. **Автоматические:** Каждый push в main создает новый релиз
2. **Ручные:** Использовать manual workflow для контроля
3. **Кастомные:** Указать точную версию в manual workflow

## 🔍 Мониторинг

### Проверка версии в приложении
```bash
curl http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/ | jq .
```

### Проверка тегов
```bash
git tag -l
git log --oneline --decorate
```

### Проверка GitHub Releases
- GitHub → Releases
- Автоматически создаются при каждом изменении версии

## 🚨 Исключения

### Что НЕ запускает auto-version:
- Изменения в файле `VERSION`
- Изменения в `.github/workflows/auto-version.yml`
- Push в другие ветки (не main)

### Что запускает auto-version:
- Любые изменения в коде
- Изменения в документации
- Изменения в конфигурации
- Push в ветку main

## 📝 Логи

### Auto Version Workflow
```
🔄 Auto bumping patch version...
Current version: 1.0.2
New version: 1.0.3
✅ Version bumped to 1.0.3
🏷️ Creating git tag v1.0.3...
✅ Git tag v1.0.3 created
```

### Main CI/CD Pipeline
```
📋 Version Information:
  Version: 1.0.3
  Build Metadata: 20250728.142530.abc123
  Git Commit: abc123
  Git Branch: main
```

---

**Автоматическое версионирование готово к использованию! 🚀** 