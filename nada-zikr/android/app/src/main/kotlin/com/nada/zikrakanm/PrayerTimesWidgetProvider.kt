package com.nada.zikrakanm

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerTimesWidgetProvider : AppWidgetProvider() {

    private val cellIds = mapOf(
        "fajr"    to R.id.widget_cell_fajr,
        "sunrise" to R.id.widget_cell_sunrise,
        "dhuhr"   to R.id.widget_cell_dhuhr,
        "asr"     to R.id.widget_cell_asr,
        "maghrib" to R.id.widget_cell_maghrib,
        "isha"    to R.id.widget_cell_isha,
    )

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

        val fajr    = widgetData.getString("fajr_time",    "--:--") ?: "--:--"
        val sunrise = widgetData.getString("sunrise_time", "--:--") ?: "--:--"
        val dhuhr   = widgetData.getString("dhuhr_time",   "--:--") ?: "--:--"
        val asr     = widgetData.getString("asr_time",     "--:--") ?: "--:--"
        val maghrib = widgetData.getString("maghrib_time", "--:--") ?: "--:--"
        val isha    = widgetData.getString("isha_time",    "--:--") ?: "--:--"

        val views = RemoteViews(context.packageName, R.layout.widget_prayer_times).apply {

            // Header
            setTextViewText(R.id.widget_app_name,   appTitle)
            setTextViewText(R.id.widget_city_name,  cityName)
            setTextViewText(R.id.widget_hijri_date, hijriDate)

            // Next Prayer Highlight
            setTextViewText(R.id.widget_next_prayer_name,      nextPrayerName)
            setTextViewText(R.id.widget_next_prayer_time,      nextPrayerTime)
            setTextViewText(R.id.widget_next_prayer_remaining, nextPrayerRemaining)

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

            // Active prayer cell highlight
            for ((prayerId, cellViewId) in cellIds) {
                val isActive = prayerId == nextPrayerId
                val bgRes = if (isActive) R.drawable.widget_active_item_bg else R.drawable.widget_item_bg
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
                    val color = if (isActive) 0xFFE5B84B.toInt() else 0xFFF3E8D2.toInt()
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
                    val color = if (isActive) 0xFFE5B84B.toInt() else 0xB3F3E8D2.toInt()
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
