import WidgetKit
import SwiftUI

private let appGroupId = "group.com.nada.nadaZikrakanm"

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 08) & 0xff) / 255.0,
            blue: Double((hex >> 00) & 0xff) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Theme Color Palettes (Synchronized with Flutter AppPalettes)

struct ThemeColors {
    let background: LinearGradient
    let cardBackground: Color
    let cardBorder: Color
    let primary: Color      // Gold / Accent color
    let secondary: Color    // Light / Cream text color
    let muted: Color        // Faint / Muted subtext
    let cellActiveBg: Color
    let isLight: Bool

    static func forTheme(_ key: String?) -> ThemeColors {
        switch key {
        case "obsidian":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x0A0D10), Color(hex: 0x12171C), Color(hex: 0x1B222A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFFD700).opacity(0.12),
                cardBorder: Color(hex: 0xFFD700).opacity(0.35),
                primary: Color(hex: 0xFFFFD700),
                secondary: Color(hex: 0xFAF9F6),
                muted: Color(hex: 0x9CA5B0),
                cellActiveBg: Color(hex: 0xFFFFD700).opacity(0.18),
                isLight: false
            )
        case "sunrise": // Golden Dawn (Daylight Amber & Cream)
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0xF5EFE4), Color(hex: 0xECE2CF), Color(hex: 0xDFD2BA)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x9A5B0B).opacity(0.12),
                cardBorder: Color(hex: 0x9A5B0B).opacity(0.30),
                primary: Color(hex: 0x9A5B0B),
                secondary: Color(hex: 0x1C140A), // Deep high-contrast text for daylight
                muted: Color(hex: 0x64513C),
                cellActiveBg: Color(hex: 0x9A5B0B).opacity(0.16),
                isLight: true
            )
        case "forest":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x081812), Color(hex: 0x102A20), Color(hex: 0x16382C)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x52B788).opacity(0.14),
                cardBorder: Color(hex: 0x52B788).opacity(0.35),
                primary: Color(hex: 0xD4AF37),
                secondary: Color(hex: 0xF2F7EF),
                muted: Color(hex: 0x8FA89B),
                cellActiveBg: Color(hex: 0xD4AF37).opacity(0.18),
                isLight: false
            )
        case "dusk":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x120C1D), Color(hex: 0x1B122C), Color(hex: 0x261A3E)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xC084FC).opacity(0.14),
                cardBorder: Color(hex: 0xC084FC).opacity(0.35),
                primary: Color(hex: 0xF6C86D),
                secondary: Color(hex: 0xF8F3FE),
                muted: Color(hex: 0xA592C0),
                cellActiveBg: Color(hex: 0xF6C86D).opacity(0.18),
                isLight: false
            )
        case "ocean":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x07111D), Color(hex: 0x0E1F34), Color(hex: 0x142B47)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x38BDF8).opacity(0.14),
                cardBorder: Color(hex: 0x38BDF8).opacity(0.35),
                primary: Color(hex: 0x38BDF8),
                secondary: Color(hex: 0xF0F7FF),
                muted: Color(hex: 0x7FAACF),
                cellActiveBg: Color(hex: 0x38BDF8).opacity(0.18),
                isLight: false
            )
        case "rose":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x180A12), Color(hex: 0x28101E), Color(hex: 0x36162A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFB7185).opacity(0.14),
                cardBorder: Color(hex: 0xFB7185).opacity(0.35),
                primary: Color(hex: 0xF6A97A),
                secondary: Color(hex: 0xFFF0F5),
                muted: Color(hex: 0xBA8F9F),
                cellActiveBg: Color(hex: 0xF6A97A).opacity(0.18),
                isLight: false
            )
        case "oled":
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x000000), Color(hex: 0x070707), Color(hex: 0x0F0F0F)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0xFFD700).opacity(0.10),
                cardBorder: Color(hex: 0xFFD700).opacity(0.35),
                primary: Color(hex: 0xFFFFD700),
                secondary: Color(hex: 0xFFFFFF),
                muted: Color(hex: 0xA0A0A0),
                cellActiveBg: Color(hex: 0xFFFFD700).opacity(0.18),
                isLight: false
            )
        default: // "nuri" / Kurdish Emerald Classic
            return ThemeColors(
                background: LinearGradient(
                    colors: [Color(hex: 0x07140E), Color(hex: 0x0D2A1C), Color(hex: 0x143826)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                cardBackground: Color(hex: 0x4DAE8C).opacity(0.14),
                cardBorder: Color(hex: 0x4DAE8C).opacity(0.35),
                primary: Color(hex: 0xD4AF37),
                secondary: Color(hex: 0xF7F2E7),
                muted: Color(hex: 0x98B8A4),
                cellActiveBg: Color(hex: 0xD4AF37).opacity(0.18),
                isLight: false
            )
        }
    }
}

// MARK: - Prayer Data Model

struct PrayerEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let hijriDate: String

    // Next upcoming prayer
    let nextPrayerName: String
    let nextPrayerTime: String
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
    let themeKey: String

    // MARK: - Live Countdown (always accurate — computed fresh at every SwiftUI render)
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
            nextPrayerTimestamp: Date().addingTimeInterval(25 * 60).timeIntervalSince1970,
            nextPrayerId: "asr",
            fajr: "04:12",
            sunrise: "05:38",
            dhuhr: "12:15",
            asr: "03:45",
            maghrib: "06:50",
            isha: "08:15",
            isKurdish: true,
            isArabic: false,
            themeKey: "nuri"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        completion(fetchCurrentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        let entry = fetchCurrentEntry()
        let now = Date()
        let prayerDate = Date(timeIntervalSince1970: entry.nextPrayerTimestamp)
        let fifteenMin = now.addingTimeInterval(900)
        let nextUpdate: Date
        if prayerDate > now && prayerDate < fifteenMin {
            nextUpdate = prayerDate
        } else {
            nextUpdate = fifteenMin
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
        let nextPrayerTimestamp = prefs?.double(forKey: "next_prayer_timestamp") ?? 0

        let fajr    = readString(prefs, keys: ["fajr_time"],    fallback: "--:--")
        let sunrise = readString(prefs, keys: ["sunrise_time"], fallback: "--:--")
        let dhuhr   = readString(prefs, keys: ["dhuhr_time"],   fallback: "--:--")
        let asr     = readString(prefs, keys: ["asr_time"],     fallback: "--:--")
        let maghrib = readString(prefs, keys: ["maghrib_time"], fallback: "--:--")
        let isha    = readString(prefs, keys: ["isha_time"],     fallback: "--:--")

        let themeKey = prefs?.string(forKey: "theme_key") ?? "nuri"

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
            isArabic: isArabic,
            themeKey: themeKey
        )
    }
}

// MARK: - Shared Row View

private struct PrayerRow: View {
    let name: String
    let time: String
    let isNext: Bool
    let textColor: Color
    let activeColor: Color
    let activeBg: Color

    /// Guarantees clean, non-wrapping time display (e.g. '04:12')
    private var cleanTime: String {
        let parts = time.components(separatedBy: " ")
        return parts.first ?? time
    }

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 11, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? activeColor : textColor.opacity(0.85))
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(cleanTime)
                .font(.system(size: 11, weight: isNext ? .bold : .regular, design: .monospaced))
                .foregroundColor(isNext ? activeColor : textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3.5)
        .background(isNext ? activeBg : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - Widget Entry View

struct PrayerTimesWidgetEntryView: View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    private var theme: ThemeColors {
        ThemeColors.forTheme(entry.themeKey)
    }

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
            smallWidget.widgetBackground(theme.background)
        case .systemMedium:
            mediumWidget.widgetBackground(theme.background)
        case .systemLarge:
            largeWidget.widgetBackground(theme.background)
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
                    smallWidget.widgetBackground(theme.background)
                }
            } else {
                smallWidget.widgetBackground(theme.background)
            }
        }
    }

    // MARK: - Small Widget (Clean, Simple, Themed)
    var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text(appTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(theme.primary)
                Spacer()
                Text(entry.cityName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.secondary.opacity(0.80))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Next Prayer Info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.nextPrayerName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.primary)
                    .lineLimit(1)

                Text(entry.nextPrayerTime)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.secondary)
                    .minimumScaleFactor(0.75)
            }

            if !entry.liveRemainingText.isEmpty {
                Text(entry.liveRemainingText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)

            // Hijri Date
            if !entry.hijriDate.isEmpty {
                Text(entry.hijriDate)
                    .font(.system(size: 9))
                    .foregroundColor(theme.muted)
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
                        .foregroundColor(theme.primary)
                    Text("• \(entry.cityName)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.secondary.opacity(0.80))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(entry.nextPrayerName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.primary)

                Text(entry.nextPrayerTime)
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !entry.liveRemainingText.isEmpty {
                    Text(entry.liveRemainingText)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(theme.cardBackground)
                        .clipShape(Capsule())
                }

                Spacer(minLength: 0)

                if !entry.hijriDate.isEmpty {
                    Text(entry.hijriDate)
                        .font(.system(size: 9))
                        .foregroundColor(theme.muted)
                }
            }
            .frame(maxWidth: 130, alignment: .leading)

            // Divider
            Rectangle()
                .fill(theme.primary.opacity(0.20))
                .frame(width: 0.75)
                .padding(.vertical, 4)

            // Right: 6 Prayers
            VStack(spacing: 3) {
                let slots = prayerSlots()
                ForEach(slots) { slot in
                    PrayerRow(
                        name: prayerName(slot),
                        time: slot.time,
                        isNext: slot.isNext,
                        textColor: theme.secondary,
                        activeColor: theme.primary,
                        activeBg: theme.cellActiveBg
                    )
                }
            }
        }
        .padding(12)
    }

    // MARK: - Large Widget (Spacious, Clean, Themed)
    var largeWidget: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.primary)
                    Text(entry.cityName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.secondary.opacity(0.80))
                }
                Spacer()
                if !entry.hijriDate.isEmpty {
                    Text(entry.hijriDate)
                        .font(.system(size: 11))
                        .foregroundColor(theme.muted)
                }
            }
            .padding(.bottom, 12)

            // Hero Next Prayer Banner
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.nextPrayerName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.primary)
                    if !entry.liveRemainingText.isEmpty {
                        Text(entry.liveRemainingText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.secondary.opacity(0.85))
                    }
                }
                Spacer()
                Text(entry.nextPrayerTime)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.primary)
            }
            .padding(12)
            .background(theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(theme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.bottom, 12)

            // Prayer List
            let slots = prayerSlots()
            VStack(spacing: 5) {
                ForEach(slots) { slot in
                    PrayerRow(
                        name: prayerName(slot),
                        time: slot.time,
                        isNext: slot.isNext,
                        textColor: theme.secondary,
                        activeColor: theme.primary,
                        activeBg: theme.cellActiveBg
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
                    .lineLimit(1)
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
