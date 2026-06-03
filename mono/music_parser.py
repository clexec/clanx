#!/usr/bin/env python3
"""
music_parser.py — Массовый сборщик метаданных треков через iTunes Search API.
Собирает популярные западные и русские треки, сохраняет в SQLite + JSON для импорта в приложение.

Использует asyncio + aiohttp для параллельных запросов (100+ конкурентных сессий).
"""

import asyncio
import aiohttp
import sqlite3
import json
import os
import re
import time
import hashlib
from dataclasses import dataclass, asdict
from typing import Optional


# ─── Конфигурация ─────────────────────────────────────────────────────────────

DB_PATH     = "music_catalog.db"
JSON_PATH   = "music_catalog.json"
CONCURRENCY = 100          # число параллельных HTTP-запросов
REQUEST_DELAY = 0.05       # задержка между пачками (сек)

# iTunes Search API
ITUNES_BASE = "https://itunes.apple.com/search"
ITUNES_LOOKUP = "https://itunes.apple.com/lookup"

# ─── Запросы: западные артисты ────────────────────────────────────────────────

WESTERN_ARTISTS = [
    "The Weeknd", "Drake", "Taylor Swift", "Ed Sheeran", "Billie Eilish",
    "Post Malone", "Ariana Grande", "Dua Lipa", "Harry Styles", "Olivia Rodrigo",
    "Bad Bunny", "Justin Bieber", "Kendrick Lamar", "Bruno Mars", "Adele",
    "Eminem", "Rihanna", "Beyonce", "Lady Gaga", "Coldplay",
    "Imagine Dragons", "Maroon 5", "The Chainsmokers", "Calvin Harris",
    "Marshmello", "Travis Scott", "J. Cole", "Nicki Minaj", "Cardi B",
    "SZA", "Lana Del Rey", "The 1975", "Arctic Monkeys", "Radiohead",
    "Pink Floyd", "Queen", "Michael Jackson", "Elvis Presley", "Bob Dylan",
    "Led Zeppelin", "Nirvana", "Metallica", "AC/DC", "Red Hot Chili Peppers",
    "Linkin Park", "Green Day", "Foo Fighters", "Twenty One Pilots",
    "Fall Out Boy", "Panic! At The Disco", "My Chemical Romance",
    "David Bowie", "Prince", "Stevie Wonder", "Elton John", "Frank Sinatra",
    "Amy Winehouse", "Adele", "Sam Smith", "Shawn Mendes", "Charlie Puth",
    "Sia", "Katy Perry", "Selena Gomez", "Miley Cyrus", "Demi Lovato",
    "Nick Jonas", "Jonas Brothers", "One Direction", "Zayn", "Niall Horan",
    "Liam Payne", "Louis Tomlinson", "5 Seconds of Summer",
    "Halsey", "Troye Sivan", "Bazzi", "Khalid", "H.E.R.",
    "Anderson .Paak", "Frank Ocean", "Tyler The Creator", "Mac Miller",
    "Juice WRLD", "XXXTentacion", "Lil Uzi Vert", "Lil Baby", "Gunna",
    "Young Thug", "Future", "Migos", "21 Savage", "A$AP Rocky",
    "Childish Gambino", "Logic", "NF", "Joyner Lucas",
    "Tones and I", "Jawsh 685", "Joel Corry", "Glass Animals",
    "Portugal. The Man", "Hozier", "James Bay", "Sam Fender",
    "Lewis Capaldi", "Tom Grennan", "Dermot Kennedy",
    "Kygo", "Alan Walker", "Martin Garrix", "Tiesto", "Avicii",
    "David Guetta", "Steve Aoki", "Diplo", "Skrillex", "Deadmau5",
    "Flume", "Disclosure", "Bonobo", "ODESZA", "Tycho",
    "Bob Marley", "Damian Marley", "Sean Paul", "Shaggy",
    "Rammstein", "Nightwish", "Evanescence", "Within Temptation",
    "BTS", "BLACKPINK", "EXO", "Stray Kids", "TWICE",
    "Shakira", "Jennifer Lopez", "Daddy Yankee", "J Balvin", "Ozuna",
    "Maluma", "Becky G", "Karol G", "Natti Natasha", "Anitta",
    "Stromae", "Angele", "Daft Punk", "Justice", "M83",
    "Gorillaz", "Blur", "Oasis", "The Smiths", "Joy Division",
    "New Order", "Depeche Mode", "The Cure", "Bauhaus",
    "Tame Impala", "Mac DeMarco", "Rex Orange County", "Clairo",
    "Phoebe Bridgers", "boygenius", "Soccer Mommy", "Big Thief",
    "Mitski", "japanese breakfast", "Snail Mail", "Faye Webster",
    "Men I Trust", "Still Woozy", "Surfaces", "Quinn XCII",
    "Jeremy Zucker", "Cavetown", "Novo Amor", "Aurora",
    "Birdy", "Passenger", "James Arthur", "Calum Scott",
]

# ─── Запросы: русские артисты ─────────────────────────────────────────────────

RUSSIAN_ARTISTS = [
    "Morgenshtern", "Face", "Хаски", "Оксимирон",
    "Скриптонит", "GONE.Fludd", "Boulevard Depo", "Pharaoh",
    "Гуф", "Баста", "Noize MC", "Птаха", "Kizaru",
    "Lil Morty", "Lizer", "Niletto", "Элджей", "Feduk",
    "JONY", "Ислам Итляшев", "Artik & Asti", "Zivert",
    "Kristina Si", "Леша Свик", "Rauf & Faik",
    "Бурито", "Instasamka", "Клава Кока", "Maruv",
    "Время и Стекло", "Макс Корж", "Ляпис Трубецкой",
    "Земфля", "Земфира", "Би-2", "Сплин", "Ария",
    "Кино", "Гражданская оборона", "Нейромонах Феофан",
    "Монатик", "Potap i Nastya", "MOZGI",
    "Ivan Dorn", "Алина Гросу", "Надя Дорофеева",
    "The Hardkiss", "Okean Elzy", "Boombox",
    "Тимати", "L'One", "Егор Крид", "Хабиб",
    "Мот", "Джиган", "Тони Раут", "Смоки Мо",
    "Miyagi & Эндшпиль", "Andy Panda", "Ramil",
    "Gravi", "Slava Marlow", "THRILL PILL",
    "103", "ОУ74", "SALUKI", "OBLADAET",
    "Lida", "Хлеб", "Монеточка",
    "Cream Soda", "Найк Борзов", "Каста",
    "25/17", "Нервы", "Animal ДжаZ",
    "Shortparis", "СБПЧ", "ГШ", "Pompeya",
    "IC3PEAK", "Kate NV", "Kedr Livanskiy",
    "Стас Михайлов", "Григорий Лепс", "Дима Билан",
    "Ани Лорак", "Сергей Лазарев", "Бьянка",
    "МакSим", "Нюша", "Полина Гагарина",
    "Ёлка", "Loboda", "Потап", "Наталя Могилевская",
    "ВВ", "Бременские Музыканты", "Дорн",
    "Иван Дорн", "Антитела", "Без Обмежень",
]

# Популярные запросы (жанры / хиты) для расширенного поиска
GENRE_QUERIES = [
    "top hits 2024", "pop hits 2023", "rap hits 2024",
    "electronic music 2024", "indie hits 2024",
    "rock classics", "80s hits", "90s hits", "2000s hits",
    "rnb hits 2024", "latin hits 2024",
    "русские хиты 2024", "русский рэп 2024",
    "russian pop 2024", "ukraine hits",
    "hip hop classics", "trap music", "drill music",
    "sad songs playlist", "workout music", "chill vibes",
    "summer hits 2024", "winter playlist", "night drive music",
    "coffee shop music", "study music", "lofi hip hop",
    "jazz classics", "soul music", "funk hits",
    "country hits 2024", "alternative rock 2024",
    "metal classics", "punk rock", "emo classics",
    "korean pop 2024", "japanese music", "french pop",
    "afrobeats 2024", "reggaeton 2024", "cumbia hits",
    "bollywood hits", "turkish pop 2024",
]


# ─── Модель данных ─────────────────────────────────────────────────────────────

@dataclass
class TrackRecord:
    id: str
    title: str
    artist_name: str
    album_title: str
    genre: str
    duration_ms: int
    artwork_url: Optional[str]
    preview_url: Optional[str]
    itunes_id: int
    artist_id: int
    album_id: int
    release_year: str
    is_explicit: bool

    @classmethod
    def from_itunes(cls, item: dict) -> Optional["TrackRecord"]:
        try:
            track_id = str(item.get("trackId", item.get("collectionId", "")))
            if not track_id:
                return None
            uid = hashlib.md5(f"{item.get('trackName','')}{item.get('artistName','')}".encode()).hexdigest()[:16]
            return cls(
                id=uid,
                title=item.get("trackName") or item.get("collectionName", "Unknown"),
                artist_name=item.get("artistName", "Unknown Artist"),
                album_title=item.get("collectionName", ""),
                genre=item.get("primaryGenreName", ""),
                duration_ms=item.get("trackTimeMillis", 0),
                artwork_url=(item.get("artworkUrl100") or "").replace("100x100bb", "600x600bb"),
                preview_url=item.get("previewUrl"),
                itunes_id=item.get("trackId", 0),
                artist_id=item.get("artistId", 0),
                album_id=item.get("collectionId", 0),
                release_year=(item.get("releaseDate") or "")[:4],
                is_explicit=item.get("trackExplicitness") == "explicit",
            )
        except Exception:
            return None


# ─── HTTP ─────────────────────────────────────────────────────────────────────

async def itunes_search(
    session: aiohttp.ClientSession,
    term: str,
    entity: str = "song",
    limit: int = 50,
    country: str = "US",
) -> list[dict]:
    params = {
        "term": term,
        "entity": entity,
        "limit": limit,
        "country": country,
        "media": "music",
    }
    try:
        async with session.get(ITUNES_BASE, params=params, timeout=aiohttp.ClientTimeout(total=15)) as r:
            if r.status == 200:
                data = await r.json(content_type=None)
                return data.get("results", [])
    except Exception as e:
        print(f"  [WARN] iTunes search '{term}': {e}")
    return []


async def itunes_search_ru(
    session: aiohttp.ClientSession,
    term: str,
    limit: int = 50,
) -> list[dict]:
    """Поиск в русском регионе."""
    return await itunes_search(session, term, limit=limit, country="RU")


# ─── База данных ──────────────────────────────────────────────────────────────

def init_db(conn: sqlite3.Connection):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS tracks (
            id           TEXT PRIMARY KEY,
            title        TEXT NOT NULL,
            artist_name  TEXT NOT NULL,
            album_title  TEXT,
            genre        TEXT,
            duration_ms  INTEGER,
            artwork_url  TEXT,
            preview_url  TEXT,
            itunes_id    INTEGER,
            artist_id    INTEGER,
            album_id     INTEGER,
            release_year TEXT,
            is_explicit  INTEGER,
            inserted_at  INTEGER DEFAULT (strftime('%s','now'))
        )
    """)
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist ON tracks(artist_name)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_title  ON tracks(title)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_genre  ON tracks(genre)")
    conn.commit()


def insert_tracks(conn: sqlite3.Connection, tracks: list[TrackRecord]) -> int:
    inserted = 0
    for t in tracks:
        try:
            conn.execute(
                """INSERT OR IGNORE INTO tracks
                   (id,title,artist_name,album_title,genre,duration_ms,
                    artwork_url,preview_url,itunes_id,artist_id,album_id,release_year,is_explicit)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (t.id, t.title, t.artist_name, t.album_title, t.genre, t.duration_ms,
                 t.artwork_url, t.preview_url, t.itunes_id, t.artist_id, t.album_id,
                 t.release_year, int(t.is_explicit)),
            )
            if conn.execute("SELECT changes()").fetchone()[0] > 0:
                inserted += 1
        except Exception:
            pass
    conn.commit()
    return inserted


# ─── Основной сборщик ─────────────────────────────────────────────────────────

async def collect_artist(
    session: aiohttp.ClientSession,
    conn: sqlite3.Connection,
    semaphore: asyncio.Semaphore,
    artist: str,
    region: str = "US",
) -> int:
    async with semaphore:
        results = await itunes_search(session, artist, limit=50, country=region)
        tracks = [TrackRecord.from_itunes(r) for r in results if r.get("kind") == "song"]
        tracks = [t for t in tracks if t is not None]
        count = insert_tracks(conn, tracks)
        if count:
            print(f"  ✓ {artist:<40} +{count} треков")
        return count


async def collect_query(
    session: aiohttp.ClientSession,
    conn: sqlite3.Connection,
    semaphore: asyncio.Semaphore,
    query: str,
    region: str = "US",
) -> int:
    async with semaphore:
        results = await itunes_search(session, query, limit=50, country=region)
        tracks = [TrackRecord.from_itunes(r) for r in results if r.get("kind") == "song"]
        tracks = [t for t in tracks if t is not None]
        count = insert_tracks(conn, tracks)
        if count:
            print(f"  ✓ [{query[:35]:<35}] +{count}")
        return count


async def main():
    conn = sqlite3.connect(DB_PATH)
    init_db(conn)

    semaphore = asyncio.Semaphore(CONCURRENCY)

    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                      "AppleWebKit/537.36 (KHTML, like Gecko) "
                      "Chrome/125.0.0.0 Safari/537.36",
        "Accept": "application/json",
    }

    connector = aiohttp.TCPConnector(limit=CONCURRENCY, ssl=False)
    timeout   = aiohttp.ClientTimeout(total=30, connect=10)

    async with aiohttp.ClientSession(headers=headers, connector=connector, timeout=timeout) as session:

        # ── Западные артисты (US регион) ───────────────────────────────────
        print(f"\n{'─'*60}")
        print(f"  Западные артисты ({len(WESTERN_ARTISTS)})")
        print(f"{'─'*60}")
        tasks = [
            collect_artist(session, conn, semaphore, artist, "US")
            for artist in WESTERN_ARTISTS
        ]
        results_w = await asyncio.gather(*tasks)
        print(f"  → Добавлено: {sum(results_w)} треков")

        await asyncio.sleep(REQUEST_DELAY * 2)

        # ── Русские артисты (RU регион) ────────────────────────────────────
        print(f"\n{'─'*60}")
        print(f"  Русские/СНГ артисты ({len(RUSSIAN_ARTISTS)})")
        print(f"{'─'*60}")
        tasks = [
            collect_artist(session, conn, semaphore, artist, "RU")
            for artist in RUSSIAN_ARTISTS
        ]
        results_r = await asyncio.gather(*tasks)
        print(f"  → Добавлено: {sum(results_r)} треков")

        await asyncio.sleep(REQUEST_DELAY * 2)

        # ── Русские артисты в US (для расширенного охвата) ─────────────────
        print(f"\n{'─'*60}")
        print("  Русские артисты (US регион — дополнительно)")
        print(f"{'─'*60}")
        tasks = [
            collect_artist(session, conn, semaphore, artist, "US")
            for artist in RUSSIAN_ARTISTS[:40]
        ]
        results_ru2 = await asyncio.gather(*tasks)
        print(f"  → Добавлено: {sum(results_ru2)} треков")

        await asyncio.sleep(REQUEST_DELAY * 2)

        # ── Жанровые/топовые запросы ───────────────────────────────────────
        print(f"\n{'─'*60}")
        print(f"  Жанровые запросы ({len(GENRE_QUERIES)})")
        print(f"{'─'*60}")
        tasks = [
            collect_query(session, conn, semaphore, query)
            for query in GENRE_QUERIES
        ]
        results_g = await asyncio.gather(*tasks)
        print(f"  → Добавлено: {sum(results_g)} треков")

        await asyncio.sleep(REQUEST_DELAY * 2)

        # ── Расширенный поиск — топ чартов по странам ─────────────────────
        print(f"\n{'─'*60}")
        print("  Топ-чарты по странам")
        print(f"{'─'*60}")
        countries = ["US", "GB", "AU", "CA", "DE", "FR", "RU", "JP", "KR", "BR", "MX", "IN"]
        top_terms = ["top songs", "top hits", "best songs", "popular music"]
        chart_tasks = []
        for country in countries:
            for term in top_terms:
                chart_tasks.append(collect_query(session, conn, semaphore, term, country))
        results_c = await asyncio.gather(*chart_tasks)
        print(f"  → Добавлено: {sum(results_c)} треков")

        await asyncio.sleep(REQUEST_DELAY * 2)

        # ── Дополнительные западные артисты ───────────────────────────────
        extra_artists = [
            "The Beatles", "Rolling Stones", "The Doors", "Jimi Hendrix",
            "Janis Joplin", "Fleetwood Mac", "Eagles", "ABBA", "Bee Gees",
            "Donna Summer", "Diana Ross", "Marvin Gaye", "Al Green",
            "James Brown", "Aretha Franklin", "Ray Charles",
            "Miles Davis", "John Coltrane", "Duke Ellington",
            "Frank Zappa", "Captain Beefheart", "Tom Waits",
            "Nick Cave", "PJ Harvey", "Bjork", "Portishead",
            "Massive Attack", "Tricky", "Trip Hop",
            "Chemical Brothers", "Prodigy", "Aphex Twin",
            "Four Tet", "Jamie xx", "Nicolas Jaar",
            "James Blake", "Bon Iver", "Justin Vernon",
            "Fleet Foxes", "Sufjan Stevens", "Iron & Wine",
            "Norah Jones", "Diana Krall", "Michael Buble",
            "John Mayer", "Jack Johnson", "Jason Mraz",
            "Gavin DeGraw", "Rob Thomas", "Matchbox Twenty",
            "Dashboard Confessional", "Taking Back Sunday",
            "Brand New", "Thursday", "Saosin", "Hawthorne Heights",
            "Silverstein", "Underoath", "Asking Alexandria",
            "Bring Me The Horizon", "Parkway Drive",
            "Of Mice & Men", "A Day To Remember",
            "Neck Deep", "Real Friends", "The Story So Far",
            "Tigers Jaw", "Modern Baseball", "The Wonder Years",
            "Citizen", "Turnover", "Movements", "Title Fight",
            "Touche Amore", "La Dispute", "Seahaven",
            "Defeater", "Have Mercy", "Moose Blood",
        ]
        print(f"\n{'─'*60}")
        print(f"  Дополнительные западные артисты ({len(extra_artists)})")
        print(f"{'─'*60}")
        tasks = [
            collect_artist(session, conn, semaphore, artist, "US")
            for artist in extra_artists
        ]
        results_e = await asyncio.gather(*tasks)
        print(f"  → Добавлено: {sum(results_e)} треков")

        # ── Итог ───────────────────────────────────────────────────────────
        total = conn.execute("SELECT COUNT(*) FROM tracks").fetchone()[0]
        unique_artists = conn.execute("SELECT COUNT(DISTINCT artist_name) FROM tracks").fetchone()[0]
        unique_genres  = conn.execute("SELECT COUNT(DISTINCT genre) FROM tracks").fetchone()[0]

        print(f"\n{'═'*60}")
        print(f"  ИТОГО в базе:")
        print(f"    Треков:   {total:,}")
        print(f"    Артистов: {unique_artists:,}")
        print(f"    Жанров:   {unique_genres:,}")
        print(f"{'═'*60}")

        # ── Экспорт в JSON для импорта в приложение ────────────────────────
        rows = conn.execute(
            "SELECT id,title,artist_name,album_title,genre,duration_ms,"
            "artwork_url,preview_url,release_year,is_explicit "
            "FROM tracks ORDER BY RANDOM() LIMIT 10000"
        ).fetchall()

        track_list = []
        for row in rows:
            track_list.append({
                "id":          row[0],
                "title":       row[1],
                "artistName":  row[2],
                "albumTitle":  row[3] or "",
                "genre":       row[4] or "",
                "durationMs":  row[5] or 0,
                "artworkUrl":  row[6] or "",
                "previewUrl":  row[7] or "",
                "releaseYear": row[8] or "",
                "isExplicit":  bool(row[9]),
            })

        with open(JSON_PATH, "w", encoding="utf-8") as f:
            json.dump({"tracks": track_list}, f, ensure_ascii=False, indent=2)

        print(f"\n  ✓ База: {DB_PATH}")
        print(f"  ✓ JSON: {JSON_PATH} ({len(track_list):,} треков для импорта в приложение)")
        print()

    conn.close()


if __name__ == "__main__":
    import sys
    # Проверяем зависимости
    try:
        import aiohttp
    except ImportError:
        print("Установи зависимости: pip install aiohttp")
        sys.exit(1)

    start = time.time()
    asyncio.run(main())
    elapsed = time.time() - start
    print(f"  Время выполнения: {elapsed:.1f}с")
