# Monk — полноразмерное воспроизведение

Добавлены источники звука: YouTube (основной) + Яндекс.Музыка (опция).
iTunes остаётся для метаданных и обложек, аудиопоток теперь полный, а не 30-сек превью.

## Подключение пакетов в Xcode

1. File → Add Package Dependencies → Add Local…
2. Выбрать `Packages/YouTubeKit` → добавить продукт `YouTubeKit` к таргету `Monk`.
3. File → Add Package Dependencies → Add Local…
4. Выбрать `Packages/YMAPI` → добавить продукт `YMAPI` к таргету `Monk`.

Или через URL: `https://github.com/b5i/YouTubeKit` и `https://github.com/p0rterB/YM-API`.

## Новые файлы

`Monk/Services/Stream/`
- MusicSource.swift
- StreamResolving.swift
- YouTubeStreamResolver.swift
- YandexMusicClient.swift
- YandexStreamResolver.swift
- PlaybackStreamProvider.swift

## Изменено

- AudioPlayerService.play(track:) резолвит поток асинхронно через PlaybackStreamProvider.
- Config.swift: добавлен PlaybackConfig.

## Яндекс (опционально)

Заполнить в `Config.swift`:
```
static let yandexToken = "<oauth token>"
static let yandexUserID = <uid>
```
Пустой токен — Яндекс пропускается, играет YouTube. Нужна активная подписка Яндекс.Плюс.

YouTube работает без ключей и токенов.
