# imanikurd-prayer

Prayer times calculation, Kurdistan cities database, and Qibla direction utilities. Part of the `imanikurd` toolkit.

## Installation

```bash
npm install imanikurd-prayer
```

## Features

- **Kurdistan Cities**: Coordinates and lookup for key Kurdish cities.
- **Prayer Times**: Complete daily/monthly prayer times database and scheduler helper.
- **Qibla calculation**: Accurate Kaaba distance and bearing calculation.

## Usage

```typescript
import { getPrayerTimes, calculateQibla } from "imanikurd-prayer";

// Get prayer times for Erbil on a specific date
const times = getPrayerTimes("erbil", "2026-06-19");
console.log(times); // Fagr, Sunrise, Dhuhr, Asr, Maghrib, Isha

// Calculate Qibla bearing from coordinates
const qibla = calculateQibla(36.1912, 44.0092); // Erbil coordinates
console.log(qibla.bearing); // bearing angle to Kaaba
```
