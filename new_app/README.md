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

## API Endpoints (SStats.net)

- **GET /Games/list** - Список матчей с фильтрами
  - `?leagueid=123` - ID лиги
  - `?from=2024-01-01&to=2024-01-31` - Диапазон дат
  - `?teamid=456` - ID команды
  
- **GET /Leagues** - Список всех лиг с сезонами

- **GET /Games/glicko/{id}** - Детали матча с Glicko рейтингом

- **GET /Games/season-table** - Турнирная таблица
  - `?league=123&year=2024`

- **GET /Teams/list** - Список команд
  - `?Name=...&Country=...`

## Функциональность

### Основные требования (20 баллов)

- **Главный экран**: Список матчей на ближайшие 2 дня с датой, временем, командами, лигой и страной
- **Экран поиска**: Фильтрация матчей по лиге и временному периоду (день/неделя/месяц)
- **Кнопка "Архив"**: Просмотр завершенных матчей выбранной лиги

### Дополнительные функции

| Функция | Баллы | Статус |
|---------|-------|--------|
| Иконки страны, клуба, лиги | +5 | ✅ |
| Регистрация и авторизация | +3 | ✅ |
| Уведомления об ошибках сети | +2 | ✅ |
| Кэширование последних 10 матчей | +10 | ✅ |
| Список команд с фильтрацией | +3 | ✅ |
| Экран команды (турнирная таблица) | +5 | ✅ |
| Коэффициенты на матч | +3 | ✅ |
| Фильтр по команде | +2 | ✅ |

**Итого: 53 балла**

## Используемые пакеты

- **provider** - управление состоянием
- **http** - HTTP запросы
- **shared_preferences** - локальное хранилище
- **cached_network_image** - кэширование изображений
- **intl** - форматирование дат
- **connectivity_plus** - проверка сети

## Авторизация

Авторизация в приложении локальная (всегда успешная). Данные пользователя сохраняются в SharedPreferences.

## Кэширование

При отсутствии сети приложение показывает последние 10 кэшированных матчей с уведомлением о том, что данные взяты из кэша.

## Сборка для релиза

### Android APK

```bash
flutter build apk --release --dart-define=API_KEY=your_api_key
```

APK будет создан в `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release --dart-define=API_KEY=your_api_key
```

### iOS

```bash
flutter build ios --release --dart-define=API_KEY=your_api_key
```

## Поддерживаемые платформы

- Android 5.0+ (API 21+)
- iOS 12.0+
- Web (Chrome, Safari, Firefox, Edge)

## Лицензия

MIT License
