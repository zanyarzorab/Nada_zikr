package com.nada.zikrakanm

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

data class WidgetThemeConfig(
    val rootBg: Int,
    val cardBg: Int,
    val activeCellBg: Int,
    val inactiveCellBg: Int,
    val primaryColor: Int,
    val secondaryColor: Int,
    val mutedColor: Int
)

class PrayerTimesWidgetProvider : AppWidgetProvider() {

    private val cellIds = mapOf(
        "fajr"    to R.id.widget_cell_fajr,
        "sunrise" to R.id.widget_cell_sunrise,
        "dhuhr"   to R.id.widget_cell_dhuhr,
        "asr"     to R.id.widget_cell_asr,
        "maghrib" to R.id.widget_cell_maghrib,
        "isha"    to R.id.widget_cell_isha,
    )

    private fun getThemeConfig(themeKey: String?): WidgetThemeConfig {
        return when (themeKey) {
            "obsidian" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_obsidian,
                cardBg = R.drawable.widget_card_bg_obsidian,
                activeCellBg = R.drawable.widget_active_obsidian,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFFFD700.toInt(),
                secondaryColor = 0xFFFAF9F6.toInt(),
                mutedColor = 0xB39CA5B0.toInt()
            )
            "sunrise" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_sunrise,
                cardBg = R.drawable.widget_card_bg_sunrise,
                activeCellBg = R.drawable.widget_active_sunrise,
                inactiveCellBg = R.drawable.widget_item_sunrise,
                primaryColor = 0xFF9A5B0B.toInt(),
                secondaryColor = 0xFF1C140A.toInt(),
                mutedColor = 0xB364513C.toInt()
            )
            "forest" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_forest,
                cardBg = R.drawable.widget_card_bg_forest,
                activeCellBg = R.drawable.widget_active_forest,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFD4AF37.toInt(),
                secondaryColor = 0xFFF2F7EF.toInt(),
                mutedColor = 0xB38FA89B.toInt()
            )
            "dusk" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_dusk,
                cardBg = R.drawable.widget_card_bg_dusk,
                activeCellBg = R.drawable.widget_active_dusk,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFF6C86D.toInt(),
                secondaryColor = 0xFFF8F3FE.toInt(),
                mutedColor = 0xB3A592C0.toInt()
            )
            "ocean" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_ocean,
                cardBg = R.drawable.widget_card_bg_ocean,
                activeCellBg = R.drawable.widget_active_ocean,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFF38BDF8.toInt(),
                secondaryColor = 0xFFF0F7FF.toInt(),
                mutedColor = 0xB37FAACF.toInt()
            )
            "rose" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_rose,
                cardBg = R.drawable.widget_card_bg_rose,
                activeCellBg = R.drawable.widget_active_rose,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFF6A97A.toInt(),
                secondaryColor = 0xFFFFF0F5.toInt(),
                mutedColor = 0xB3BA8F9F.toInt()
            )
            "oled" -> WidgetThemeConfig(
                rootBg = R.drawable.widget_bg_oled,
                cardBg = R.drawable.widget_card_bg_oled,
                activeCellBg = R.drawable.widget_active_oled,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFFFD700.toInt(),
                secondaryColor = 0xFFFFFFFF.toInt(),
                mutedColor = 0xB3A0A0A0.toInt()
            )
            else -> WidgetThemeConfig( // "nuri" / default
                rootBg = R.drawable.widget_bg_nuri,
                cardBg = R.drawable.widget_card_bg_nuri,
                activeCellBg = R.drawable.widget_active_nuri,
                inactiveCellBg = R.drawable.widget_item_bg,
                primaryColor = 0xFFD4AF37.toInt(),
                secondaryColor = 0xFFF7F2E7.toInt(),
                mutedColor = 0xB398B8A4.toInt()
            )
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateSingleWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        val lang              = widgetData.getString("lang", "ku") ?: "ku"
        val isKurdish         = lang == "ku"
        val isArabic          = lang == "ar"

        val defaultCity       = if (isKurdish) "کوردستان" else if (isArabic) "كردستان" else "Kurdistan"
        val defaultNextPrayer = if (isKurdish) "بانگی داهاتوو" else if (isArabic) "الصلاة القادمة" else "Next Prayer"
        val appTitle          = if (isKurdish || isArabic) "نەدا" else "Nada"

        val cityName          = widgetData.getString("city_name", defaultCity) ?: defaultCity
        val hijriDate         = widgetData.getString("hijri_date", "") ?: ""
        val nextPrayerName    = widgetData.getString("next_prayer_name", defaultNextPrayer) ?: defaultNextPrayer
        val nextPrayerTime    = widgetData.getString("next_prayer_time", "--:--") ?: "--:--"
        val nextPrayerRemaining = widgetData.getString("next_prayer_remaining", "") ?: ""
        val nextPrayerId      = widgetData.getString("next_prayer_id", "") ?: ""

        val themeKey          = widgetData.getString("theme_key", "nuri") ?: "nuri"
        val theme             = getThemeConfig(themeKey)

        val fajr    = widgetData.getString("fajr_time",    "--:--") ?: "--:--"
        val sunrise = widgetData.getString("sunrise_time", "--:--") ?: "--:--"
        val dhuhr   = widgetData.getString("dhuhr_time",   "--:--") ?: "--:--"
        val asr     = widgetData.getString("asr_time",     "--:--") ?: "--:--"
        val maghrib = widgetData.getString("maghrib_time", "--:--") ?: "--:--"
        val isha    = widgetData.getString("isha_time",    "--:--") ?: "--:--"

        val views = RemoteViews(context.packageName, R.layout.widget_prayer_times).apply {

            // Apply Theme Backgrounds
            setInt(R.id.widget_root, "setBackgroundResource", theme.rootBg)
            setInt(R.id.widget_next_card, "setBackgroundResource", theme.cardBg)

            // Header
            setTextViewText(R.id.widget_app_name,   appTitle)
            setTextColor(R.id.widget_app_name,      theme.primaryColor)

            setTextColor(R.id.widget_dot_separator, theme.mutedColor)

            setTextViewText(R.id.widget_city_name,  cityName)
            setTextColor(R.id.widget_city_name,     theme.secondaryColor)

            setTextViewText(R.id.widget_hijri_date, hijriDate)
            setTextColor(R.id.widget_hijri_date,    theme.mutedColor)

            // Next Prayer Highlight Card
            setTextViewText(R.id.widget_next_prayer_name,      nextPrayerName)
            setTextColor(R.id.widget_next_prayer_name,         theme.primaryColor)

            setTextViewText(R.id.widget_next_prayer_time,      nextPrayerTime)
            setTextColor(R.id.widget_next_prayer_time,         theme.primaryColor)

            setTextViewText(R.id.widget_next_prayer_remaining, nextPrayerRemaining)
            setTextColor(R.id.widget_next_prayer_remaining,    theme.secondaryColor)

            // Prayer Names (Clean, localized, no emojis)
            setTextViewText(R.id.widget_name_fajr,    if (isKurdish) "بەیانی" else if (isArabic) "الفجر" else "Fajr")
            setTextViewText(R.id.widget_name_sunrise, if (isKurdish) "خۆرهەڵات" else if (isArabic) "الشروق" else "Sunrise")
            setTextViewText(R.id.widget_name_dhuhr,   if (isKurdish) "نیوەڕۆ" else if (isArabic) "الظهر" else "Dhuhr")
            setTextViewText(R.id.widget_name_asr,     if (isKurdish) "عەسر" else if (isArabic) "العصر" else "Asr")
            setTextViewText(R.id.widget_name_maghrib, if (isKurdish) "شێوان" else if (isArabic) "المغرب" else "Maghrib")
            setTextViewText(R.id.widget_name_isha,    if (isKurdish) "خەوتنان" else if (isArabic) "العشاء" else "Isha")

            // Prayer Times
            setTextViewText(R.id.widget_time_fajr,    fajr)
            setTextViewText(R.id.widget_time_sunrise, sunrise)
            setTextViewText(R.id.widget_time_dhuhr,   dhuhr)
            setTextViewText(R.id.widget_time_asr,     asr)
            setTextViewText(R.id.widget_time_maghrib, maghrib)
            setTextViewText(R.id.widget_time_isha,    isha)

            // Active prayer cell highlight & themed text colors
            for ((prayerId, cellViewId) in cellIds) {
                val isActive = prayerId == nextPrayerId
                val bgRes = if (isActive) theme.activeCellBg else theme.inactiveCellBg
                setInt(cellViewId, "setBackgroundResource", bgRes)

                val timeViewId = when (prayerId) {
                    "fajr"    -> R.id.widget_time_fajr
                    "sunrise" -> R.id.widget_time_sunrise
                    "dhuhr"   -> R.id.widget_time_dhuhr
                    "asr"     -> R.id.widget_time_asr
                    "maghrib" -> R.id.widget_time_maghrib
                    "isha"    -> R.id.widget_time_isha
                    else      -> null
                }
                if (timeViewId != null) {
                    val color = if (isActive) theme.primaryColor else theme.secondaryColor
                    setTextColor(timeViewId, color)
                }

                val nameViewId = when (prayerId) {
                    "fajr"    -> R.id.widget_name_fajr
                    "sunrise" -> R.id.widget_name_sunrise
                    "dhuhr"   -> R.id.widget_name_dhuhr
                    "asr"     -> R.id.widget_name_asr
                    "maghrib" -> R.id.widget_name_maghrib
                    "isha"    -> R.id.widget_name_isha
                    else      -> null
                }
                if (nameViewId != null) {
                    val color = if (isActive) theme.primaryColor else theme.mutedColor
                    setTextColor(nameViewId, color)
                }
            }

            // Launch app on widget tap
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
    }
}
