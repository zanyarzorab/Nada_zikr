# Implementation Plan - Prayer Module & Enhanced Statistics

This plan outlines the steps to implement the **Prayer** module (Prayer Times & Qibla) and enhance the **Statistics** module to include Quran reading progress, fulfilling the vision of the "Nûrî" app as a comprehensive spiritual companion.

## User Review Required

> [!IMPORTANT]
> The Prayer module will require **Location Permissions** if the user chooses GPS mode. We should ensure the `AndroidManifest.xml` and `Info.plist` are updated if not already done.
> The Qibla feature requires a compass/magnetometer sensor on the device.

## Proposed Changes

### 1. Prayer Module (UI & Integration)

We will build the UI for the prayer times and Qibla, leveraging the existing `PrayerRepository` and `QiblaCalculator`.

#### [NEW] [prayer_screen.dart](file:///C:/Users/zanay/F/lib/screens/prayer_screen.dart)
*   Implement a beautiful dashboard showing today's prayer times.
*   Display a live countdown to the next prayer.
*   Show the Hijri date using `HijriDateInfo`.
*   Include a "Qibla Finder" button.
*   Add settings for City Selection and Calculation Methods.

#### [NEW] [qibla_screen.dart](file:///C:/Users/zanay/F/lib/screens/qibla_screen.dart)
*   Implement a visual compass for Qibla direction.
*   Use `QiblaCalculator` and `Geolocator` to determine the angle.

#### [MODIFY] [home_screen.dart](file:///C:/Users/zanay/F/lib/screens/home_screen.dart)
*   Update the "DAILY PATH" and "QUICK ACCESS" sections to link to the new Prayer screen.
*   Show the next prayer time on the home dashboard.

---

### 2. Statistics Module Enhancement

Currently, statistics focus on Dhikr. We will add Quran reading progress tracking.

#### [MODIFY] [storage_service.dart](file:///C:/Users/zanay/F/lib/services/storage_service.dart)
*   Add methods to track and retrieve Quran progress (e.g., `incrementAyahsRead`, `markSurahCompleted`).
*   Store these metrics in the Hive `statistics` box.

#### [MODIFY] [quran_screen.dart](file:///C:/Users/zanay/F/lib/screens/quran_screen.dart)
*   Update `SurahReadingScreen` to log ayahs read as the user scrolls or plays audio.

#### [MODIFY] [statistics_screen.dart](file:///C:/Users/zanay/F/lib/screens/statistics_screen.dart)
*   Add a new section for "Quran Progress".
*   Display total Ayahs read and Surahs completed.
*   Include Quran-related milestones/badges (e.g., "First Surah", "Half Quran").

---

### 3. Localization

#### [MODIFY] [en.json](file:///C:/Users/zanay/F/assets/lang/en.json) / [ku.json](file:///C:/Users/zanay/F/assets/lang/ku.json) / [ar.json](file:///C:/Users/zanay/F/assets/lang/ar.json)
*   Add strings for Prayer names, Qibla, Hijri months, and Quran statistics labels.

## Verification Plan

### Automated Tests
*   Verify `PrayerRepository.getPrayerScheduleForDate` returns correct times for a known city (e.g., Erbil).
*   Test `HijriDateInfo.fromGregorian` against a standard Hijri calendar.

### Manual Verification
*   Open the new Prayer screen and verify times match the current location/city.
*   Check the Qibla compass (requires physical device or simulator with sensor support).
*   Read a few ayahs in the Quran screen and verify the count increases in the Statistics screen.
