# Football Matches App

Мобильное приложение для отображения информации о футбольных матчах. Данные предоставляются через API SStats.net.

## Требования

- Flutter SDK 3.10.8 или выше
- Dart SDK 3.0 или выше
- Android Studio или VS Code с Flutter плагином
- Для iOS: macOS с Xcode 14+

## Установка и запуск

### 1. Клонирование репозитория

```bash
git clone <URL_репозитория>
cd new_app
```

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Настройка API ключа

API ключ передается через переменную окружения. Есть два способа:

**Способ 1: Через flutter run**
```bash
flutter run --dart-define=API_KEY=your_api_key
```

**Способ 2: Через export (Unix/macOS)**
```bash
export API_KEY=your_api_key
flutter run --dart-define=API_KEY=$API_KEY
```

**Способ 3: Для сборки**
```bash
flutter build apk --dart-define=API_KEY=your_api_key
flutter build ios --dart-define=API_KEY=your_api_key
```

### 4. Запуск приложения

#### Android

```bash
# Убедитесь, что эмулятор запущен или устройство подключено
flutter run --dart-define=API_KEY=your_api_key
```

#### iOS (только macOS)

```bash
cd ios && pod install && cd ..
flutter run --dart-define=API_KEY=your_api_key
```

#### Web

```bash
flutter run -d chrome --dart-define=API_KEY=your_api_key
```

## Структура проекта

```
lib/
├── main.dart                 # Точка входа приложения
├── config/
│   ├── api_config.dart       # Конфигурация API (ключ из env)
│   ├── app_theme.dart        # Тема приложения
│   └── routes.dart           # Маршруты навигации
├── models/
│   ├── match.dart            # Модели матча, команды, коэффициентов
│   ├── league.dart           # Модель лиги и сезона
│   ├── team.dart             # Модель команды и турнирной таблицы
│   └── user.dart             # Модель пользователя
├── services/
│   ├── api_service.dart      # HTTP клиент для SStats.net API
│   ├── cache_service.dart    # Сервис кэширования
│   └── auth_service.dart     # Сервис авторизации
├── providers/
│   ├── auth_provider.dart    # Провайдер авторизации
│   ├── matches_provider.dart # Провайдер матчей
│   ├── leagues_provider.dart # Провайдер лиг
│   └── teams_provider.dart   # Провайдер команд
├── screens/
│   ├── splash_screen.dart    # Экран загрузки
│   ├── main_navigation_screen.dart # Главный экран навигации
│   ├── auth/                 # Экраны авторизации
│   ├── home/                 # Главный экран (матчи)
│   ├── search/               # Поиск и архив матчей
│   ├── match/                # Детали матча
│   ├── teams/                # Команды и турнирная таблица
│   └── profile/              # Профиль пользователя
└── widgets/                  # Переиспользуемые виджеты
```


