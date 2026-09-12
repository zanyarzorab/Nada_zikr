import WidgetKit
import SwiftUI

private let appGroupId = "group.com.nada.nadaZikrakanm"

// MARK: - Prayer Data Model

struct PrayerEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let hijriDate: String

    // Next upcoming prayer
    let nextPrayerName: String
    let nextPrayerTime: String
    /// Unix epoch seconds of the next prayer time.
    /// Flutter writes this so Swift can compute an always-accurate countdown at render time.
    let nextPrayerTimestamp: Double
    let nextPrayerId: String

    // All 6 prayer times
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String

    let isKurdish: Bool
    let isArabic: Bool

    // MARK: - Live Countdown (always accurate — computed fresh at every SwiftUI render)
    /// Never stale: calculates remaining time from Date() at the moment SwiftUI draws this view.
    var liveRemainingText: String {
        guard nextPrayerTimestamp > 0 else { return "" }
        let target = Date(timeIntervalSince1970: nextPrayerTimestamp)
        let diff = target.timeIntervalSince(Date())
        if diff <= 0 {
            return isKurdish ? "کاتی بانگە" : (isArabic ? "حان وقت الأذان" : "Prayer Time")
        }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours > 0 {
            return isKurdish
                ? "\(hours) کاتژمێر و \(minutes) خولەک ماوە"
                : (isArabic ? "باقي \(hours) ساعة و \(minutes) دقيقة" : "in \(hours)h \(minutes)m")
        } else {
            return isKurdish
                ? "\(minutes) خولەک ماوە"
                : (isArabic ? "باقي \(minutes) دقيقة" : "in \(minutes) mins")
        }
    }
}

// MARK: - Helpers

private struct PrayerSlot: Identifiable {
    let id: String
    let nameKu: String
    let nameAr: String
    let nameEn: String
    let time: String
    var isNext: Bool = false
}

// MARK: - Timeline Provider

struct PrayerTimelineProvider: TimelineProvider {

    private func readString(_ prefs: UserDefaults?, keys: [String], fallback: String) -> String {
        for key in keys {
            if let value = prefs?.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !value.isEmpty, value != "--:--" {
                return value
            }
        }
        return fallback
    }

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            cityName: "هەولێر",
            hijriDate: "١٤ سەفەر ١٤٤٨",
            nextPrayerName: "بانگی عەسر",
            nextPrayerTime: "03:45 PM",
            // 25 minutes from now so liveRemainingText shows a real countdown in Xcode previews
            nextPrayerTimestamp: Date().addingTimeInterval(25 * 60).timeIntervalSince1970,
            nextPrayerId: "asr",
            fajr: "04:12 AM",
            sunrise: "05:38 AM",
            dhuhr: "12:15 PM",
            asr: "03:45 PM",
            maghrib: "06:50 PM",
            isha: "08:15 PM",
            isKurdish: true,
            isArabic: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        completion(fetchCurrentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        let entry = fetchCurrentEntry()
        let now = Date()
        // Wake exactly at the next prayer boundary so "active prayer" switches instantly.
        // Fall back to 15-min poll when the prayer is far away or already past.
        let prayerDate = Date(timeIntervalSince1970: entry.nextPrayerTimestamp)
        let fifteenMin = now.addingTimeInterval(900)
        let nextUpdate: Date
        if prayerDate > now && prayerDate < fifteenMin {
            nextUpdate = prayerDate  // imminent prayer — refresh exactly at the boundary
        } else {
            nextUpdate = fifteenMin  // standard 15-min safety poll
        }
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchCurrentEntry() -> PrayerEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        let lang = prefs?.string(forKey: "lang") ?? "ku"
        let isKurdish = lang == "ku"
        let isArabic  = lang == "ar"

        let defaultCity       = isKurdish ? "کوردستان" : (isArabic ? "كردستان" : "Kurdistan")
        let defaultNextPrayer = isKurdish ? "بانگی داهاتوو" : (isArabic ? "الصلاة القادمة" : "Next Prayer")

        let cityName       = readString(prefs, keys: ["city_name"], fallback: defaultCity)
        let hijriDate      = readString(prefs, keys: ["hijri_date"], fallback: "")
        let nextPrayerName = readString(prefs, keys: ["next_prayer_name", "selected_prayer_name"], fallback: defaultNextPrayer)
        let nextPrayerTime = readString(prefs, keys: ["next_prayer_time", "selected_prayer_time"], fallback: "--:--")
        let nextPrayerId   = prefs?.string(forKey: "next_prayer_id") ?? "fajr"

        // Raw Unix timestamp from Flutter — used to compute live countdown at render time
        let nextPrayerTimestamp = prefs?.double(forKey: "next_prayer_timestamp") ?? 0

        let fajr    = readString(prefs, keys: ["fajr_time"],    fallback: "--:--")
        let sunrise = readString(prefs, keys: ["sunrise_time"], fallback: "--:--")
        let dhuhr   = readString(prefs, keys: ["dhuhr_time"],   fallback: "--:--")
        let asr     = readString(prefs, keys: ["asr_time"],     fallback: "--:--")
        let maghrib = readString(prefs, keys: ["maghrib_time"], fallback: "--:--")
        let isha    = readString(prefs, keys: ["isha_time"],     fallback: "--:--")

        return PrayerEntry(
            date: Date(),
            cityName: cityName,
            hijriDate: hijriDate,
            nextPrayerName: nextPrayerName,
            nextPrayerTime: nextPrayerTime,
            nextPrayerTimestamp: nextPrayerTimestamp,
            nextPrayerId: nextPrayerId,
            fajr: fajr,
            sunrise: sunrise,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha,
            isKurdish: isKurdish,
            isArabic: isArabic
        )
    }
}

// MARK: - Color Palette

private let colorGold   = Color(red: 0.90, green: 0.72, blue: 0.29)
private let colorCream  = Color(red: 0.95, green: 0.91, blue: 0.82)
private let colorBg1    = Color(red: 0.04, green: 0.12, blue: 0.08)
private let colorBg2    = Color(red: 0.08, green: 0.18, blue: 0.12)
private let bgGradient  = LinearGradient(
    gradient: Gradient(colors: [colorBg1, colorBg2]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// MARK: - Shared Row View

private struct PrayerRow: View {
    let name: String
    let time: String
    let isNext: Bool

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 11, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? colorGold : colorCream.opacity(0.80))
            Spacer()
            Text(time)
                .font(.system(size: 11, weight: isNext ? .bold : .regular, design: .monospaced))
                .foregroundColor(isNext ? colorGold : colorCream)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3.5)
        .background(isNext ? colorGold.opacity(0.18) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - Widget Entry View

struct PrayerTimesWidgetEntryView: View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    private func prayerSlots() -> [PrayerSlot] {
        [
            PrayerSlot(id: "fajr",    nameKu: "بەیانی",   nameAr: "الفجر",   nameEn: "Fajr",    time: entry.fajr,    isNext: entry.nextPrayerId == "fajr"),
            PrayerSlot(id: "sunrise", nameKu: "خۆرهەڵات", nameAr: "الشروق",  nameEn: "Sunrise", time: entry.sunrise, isNext: entry.nextPrayerId == "sunrise"),
            PrayerSlot(id: "dhuhr",   nameKu: "نیوەڕۆ",   nameAr: "الظهر",   nameEn: "Dhuhr",   time: entry.dhuhr,   isNext: entry.nextPrayerId == "dhuhr"),
            PrayerSlot(id: "asr",     nameKu: "عەسر",     nameAr: "العصر",   nameEn: "Asr",     time: entry.asr,     isNext: entry.nextPrayerId == "asr"),
            PrayerSlot(id: "maghrib", nameKu: "شێوان",    nameAr: "المغرب",  nameEn: "Maghrib", time: entry.maghrib, isNext: entry.nextPrayerId == "maghrib"),
            PrayerSlot(id: "isha",    nameKu: "خەوتنان",  nameAr: "العشاء",  nameEn: "Isha",    time: entry.isha,    isNext: entry.nextPrayerId == "isha"),
        ]
    }

    private func prayerName(_ slot: PrayerSlot) -> String {
        if entry.isKurdish { return slot.nameKu }
        if entry.isArabic  { return slot.nameAr }
        return slot.nameEn
    }

    private var appTitle: String {
        (entry.isKurdish || entry.isArabic) ? "نەدا" : "Nada"
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget.widgetBackground(bgGradient)
        case .systemMedium:
            mediumWidget.widgetBackground(bgGradient)
        case .systemLarge:
            largeWidget.widgetBackground(bgGradient)
        default:
            if #available(iOSApplicationExtension 16.0, *) {
                switch family {
                case .accessoryRectangular:
                    lockScreenRectangular.widgetBackground(Color.clear)
                case .accessoryInline:
                    lockScreenInline.widgetBackground(Color.clear)
                case .accessoryCircular:
                    lockScreenCircular.widgetBackground(Color.clear)
                default:
                    smallWidget.widgetBackground(bgGradient)
                }
            } else {
                smallWidget.widgetBackground(bgGradient)
            }
        }
    }

    // MARK: - Small Widget (Clean, Simple, Elegant)
    var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text(appTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(colorGold)
                Spacer()
                Text(entry.cityName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(colorCream.opacity(0.80))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Next Prayer Info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.nextPrayerName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colorGold)
                    .lineLimit(1)

                Text(entry.nextPrayerTime)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(colorCream)
                    .minimumScaleFactor(0.75)
            }

            if !entry.liveRemainingText.isEmpty {
                Text(entry.liveRemainingText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(colorGold)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(colorGold.opacity(0.16))
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)

            // Hijri Date
            if !entry.hijriDate.isEmpty {
                Text(entry.hijriDate)
                    .font(.system(size: 9))
                    .foregroundColor(colorCream.opacity(0.55))
                    .lineLimit(1)
            }
        }
        .padding(14)
    }

    // MARK: - Medium Widget (Balanced 2-Column: Hero + 6 Prayers)
    var mediumWidget: some View {
        HStack(spacing: 12) {

            // Left: Next Prayer
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(appTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(colorGold)
                    Text("• \(entry.cityName)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(colorCream.opacity(0.80))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(entry.nextPrayerName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colorGold)

                Text(entry.nextPrayerTime)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(colorCream)
                    .minimumScaleFactor(0.7)

                if !entry.liveRemainingText.isEmpty {
                    Text(entry.liveRemainingText)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(colorGold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(colorGold.opacity(0.16))
                        .clipShape(Capsule())
                }

                Spacer(minLength: 0)

                if !entry.hijriDate.isEmpty {
                    Text(entry.hijriDate)
                        .font(.system(size: 9))
                        .foregroundColor(colorCream.opacity(0.55))
                }
            }
            .frame(maxWidth: 130, alignment: .leading)

            // Divider
            Rectangle()
                .fill(colorGold.opacity(0.20))
                .frame(width: 0.75)
                .padding(.vertical, 4)

            // Right: 6 Prayers
            VStack(spacing: 3) {
                let slots = prayerSlots()
                ForEach(slots) { slot in
                    PrayerRow(
                        name: prayerName(slot),
                        time: slot.time,
                        isNext: slot.isNext
                    )
                }
            }
        }
        .padding(12)
    }

    // MARK: - Large Widget (Spacious, Clean)
    var largeWidget: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colorGold)
                    Text(entry.cityName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colorCream.opacity(0.80))
                }
                Spacer()
                if !entry.hijriDate.isEmpty {
                    Text(entry.hijriDate)
                        .font(.system(size: 11))
                        .foregroundColor(colorCream.opacity(0.60))
                }
            }
            .padding(.bottom, 12)

            // Hero Next Prayer Banner
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.nextPrayerName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(colorGold)
                    if !entry.liveRemainingText.isEmpty {
                        Text(entry.liveRemainingText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(colorCream.opacity(0.85))
                    }
                }
                Spacer()
                Text(entry.nextPrayerTime)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(colorGold)
            }
            .padding(12)
            .background(colorGold.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.bottom, 12)

            // Prayer List
            let slots = prayerSlots()
            VStack(spacing: 5) {
                ForEach(slots) { slot in
                    PrayerRow(
                        name: prayerName(slot),
                        time: slot.time,
                        isNext: slot.isNext
                    )
                    .padding(.vertical, 1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
    }

    // MARK: - Lock Screen Widgets (iOS 16+, No Emojis)

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenRectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(entry.cityName)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Text(entry.nextPrayerName)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(entry.nextPrayerTime)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                Spacer()
                if !entry.liveRemainingText.isEmpty {
                    Text(entry.liveRemainingText)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenInline: some View {
        Text("\(entry.nextPrayerName): \(entry.nextPrayerTime)")
    }

    @available(iOSApplicationExtension 16.0, *)
    var lockScreenCircular: some View {
        VStack(spacing: 1) {
            Text(entry.nextPrayerName)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(entry.nextPrayerTime.components(separatedBy: " ").first ?? entry.nextPrayerTime)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - iOS 17+ Container Background & Margin Support

extension View {
    @ViewBuilder
    func widgetBackground<V: View>(_ backgroundView: V) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            background(backgroundView)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

// MARK: - Widget Entry Point

@main
struct PrayerTimesWidget: Widget {
    let kind: String = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("نەدا • کاتەکانی بانگ")
        .description("شەونمی ئارامی بۆ دڵەکان — پیشاندانی کاتەکانی بانگ و یادی خوا")
        .supportedFamilies(supportedFamiliesList)
        .contentMarginsDisabledIfAvailable()
    }

    private var supportedFamiliesList: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall, .systemMedium, .systemLarge,
                .accessoryRectangular, .accessoryInline, .accessoryCircular
            ]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
}
