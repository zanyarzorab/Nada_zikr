# imanikurd

[![npm version](https://img.shields.io/npm/v/imanikurd.svg)](https://www.npmjs.com/package/imanikurd)
[![CI](https://github.com/Abdulla090/imanikurd/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdulla090/imanikurd/actions)
[![license](https://img.shields.io/npm/l/imanikurd.svg)](https://github.com/Abdulla090/imanikurd/blob/main/LICENSE)

Complete Islamic toolkit for the Kurdish community. Install anywhere with npm and access the full Quran, prayer times, Qibla, dhikr, hadith, tafsir, and more.

```bash
npm install imanikurd
```

## Features

- **Complete Quran** — All 6236 ayahs across 114 surahs with Arabic Uthmani text, juz, and page numbers
- **13 Kurdish Tafsirs** — Rebar, Asan, Puxta, Raman, Hazhar, Zhian, Sanahi, Maisar, Tawhid, Roshn, Runahi, Mokhtasar, Krd
- **Qibla** — Calculate direction to Kaaba from any coordinates
- **Prayer Times** — Accurate times for Kurdistan cities (Hawler, Slemani, Duhok, Kirkuk, and more)
- **Dhikr / Azkar** — Morning, evening, and occasion-based remembrances in Kurdish
- **Hadith** — Authentic hadiths translated to Kurdish
- **99 Names of Allah** — Asma ul Husna with Kurdish and English meanings
- **Companions & Seerah** — Biographies of the Prophet and Sahabah
- **Audio Recitations** — URLs for 10 reciters including Kurdish reciter Peshawa Qadir

## Quick Start

```javascript
import {
  getSurahs,
  getSurahAyahs,
  getAyah,
  getFullQuran,
  calculateQibla,
  getPrayerTimes,
  getNextPrayer,
  getDhikrCategories,
  getDhikrByCategory,
  getTafsirForAyah,
  getHadiths,
  getNamesOfAllah,
  getRecitationUrl,
} from "imanikurd";

// Full Quran — all 6236 ayahs
const allAyahs = getFullQuran();
console.log(`Total ayahs: ${allAyahs.length}`); // 6236

// Get Surah Al-Fatiha
const fatiha = getSurahAyahs(1);
console.log(fatiha[0].text); // بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ

// Single ayah
const ayah = getAyah(2, 255); // Ayat al-Kursi

// All 114 surahs
const surahs = getSurahs();

// Qibla direction from Erbil
const qibla = calculateQibla(36.19, 44.01);
console.log(`Qibla: ${qibla}°`);

// Prayer times for Slemani today
const times = getPrayerTimes("Slemani");
console.log(times); // { Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha }

// Next prayer
const next = getNextPrayer("Hawler");

// Kurdish Tafsir
const tafsir = getTafsirForAyah("rebar", 1, 1);

// Dhikr categories and items
const categories = getDhikrCategories();
const morningDhikr = getDhikrByCategory(1);

// Hadith & Names of Allah
const hadiths = getHadiths();
const names = getNamesOfAllah();

// Audio recitation URL
const audioUrl = getRecitationUrl("peshawa", 1);
```

## CommonJS

```javascript
const { getFullQuran, calculateQibla, getPrayerTimes } = require("imanikurd");

const quran = getFullQuran();
const qibla = calculateQibla(36.19, 44.01);
const times = getPrayerTimes("Duhok");
```

## Universal / Browser Support

All APIs have **Asynchronous** equivalents ending in `Async` (e.g. `getSurahsAsync()`, `getPrayerTimesAsync()`). These async APIs work in both **Node.js** (non-blocking file reads) and **Browser environments** (fetches data on-demand).

### 1. Browser Configuration

Since browser apps don't have filesystem access, the package loads data from a CDN (unpkg) by default. You can customize the base URL or set a custom data loader:

```javascript
import { setBaseUrl, getSurahsAsync } from "imanikurd";

// Option A: Point to your own asset folder or CDN
setBaseUrl("https://mycdn.com/imanikurd/data");

// Option B: Set a custom data loader (e.g. dynamic imports or local fetch)
import { setDataLoader } from "imanikurd";
setDataLoader(async (filename) => {
  const response = await fetch(`/data/${filename}`);
  return response.json();
});

// Load data asynchronously
const surahs = await getSurahsAsync();
```

### 2. Direct JSON Imports (Recommended for small bundles)

For client-side apps, you can import individual JSON datasets directly to save network requests:

```javascript
import quran from "imanikurd/data/quran.json";
import dhikr from "imanikurd/data/dhikr.json";
```

## API Reference

### Quran

| Function | Description |
|----------|-------------|
| `getSurahs()` | All 114 surahs with metadata |
| `getSurah(n)` | Single surah by number |
| `getSurahAyahs(n)` | All ayahs in a surah |
| `getAyah(surah, ayah)` | Single ayah |
| `getFullQuran()` | All 6236 ayahs |
| `getJuzAyahs(juz)` | Ayahs in a juz (1-30) |
| `getPageAyahs(page)` | Ayahs on a mushaf page |
| `searchQuran(query)` | Search Arabic text |

### Tafsir

| Function | Description |
|----------|-------------|
| `getTafsirOptions()` | List of 13 tafsirs |
| `getTafsir(id)` | Full tafsir dataset |
| `getTafsirForAyah(id, surah, ayah)` | Tafsir for one ayah |
| `getTafsirForSurah(id, surah)` | All tafsir for a surah |
| `searchTafsir(id, query)` | Search tafsir text |

### Qibla

| Function | Description |
|----------|-------------|
| `calculateQibla(lat, lng)` | Direction in degrees (0-360) |
| `getQibla({ lat, lng })` | Full result with coordinates |
| `isFacingQibla(heading, lat, lng)` | Check compass alignment |
| `getDistanceToKaaba(lat, lng)` | Distance in km |

### Prayer Times

| Function | Description |
|----------|-------------|
| `getPrayerCities()` | Available city keys |
| `getPrayerTimes(city, date?)` | Daily prayer times |
| `getMonthlyPrayerTimes(city, month, year?)` | Full month schedule |
| `getNextPrayer(city)` | Next upcoming prayer |
| `getPrayerTimesByLocation(lat, lng)` | Auto-detect city |

### Dhikr

| Function | Description |
|----------|-------------|
| `getDhikrCategories()` | All categories |
| `getDhikrItems()` | All dhikr items |
| `getDhikrByCategory(id)` | Items in a category |
| `searchDhikr(query)` | Search Arabic/Kurdish |

## Data Sources

Data extracted from the Noor Database v2, with prayer times calibrated for Kurdistan Region cities.

## License

MIT — For educational, spiritual, and religious purposes.
