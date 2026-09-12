import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_repository.dart';
import '../services/prayer_widget_service.dart';
import '../services/storage_service.dart';
import 'app_theme.dart';
import 'kurdistan_flag_widget.dart';

/// Hierarchical Country & City Selector Sheet.
class LocationSelectorSheet extends StatefulWidget {
  final String locale;
  final VoidCallback onLocationSelected;

  const LocationSelectorSheet({
    Key? key,
    required this.locale,
    required this.onLocationSelected,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String locale,
    required VoidCallback onLocationSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectorSheet(
        locale: locale,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  late String _currentMode;
  late String _currentCityId;
  bool _isGpsLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _currentMode = StorageService.getPrayerLocationMode();
    _currentCityId = StorageService.getPrayerSelectedCity();

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectGps() async {
    setState(() => _isGpsLoading = true);
    final locRes = await LocationService.getCurrentLocation(forceGps: true);
    setState(() => _isGpsLoading = false);

    if (!locRes.isGpsSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locRes.errorMessage ?? 'دەسەڵاتی جوگرافیا (GPS) ڕێگەنەدراوە. شوێن خەمڵێنرا بۆ ${locRes.nearestCity.nameKu}.',
            style: AppTheme.kurdishText(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: AppColors.gold,
        ),
      );
    }
    await StorageService.savePrayerLocationMode('gps');
    await StorageService.savePrayerSelectedCity(locRes.nearestCity.id);
    await NotificationService.rescheduleUpcomingPrayerAzans();
    await PrayerWidgetService.updateWidgets();
    widget.onLocationSelected();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _selectCity(WorldCity city) async {
    LocationService.invalidateCache();
    await StorageService.savePrayerLocationMode('preset');
    await StorageService.savePrayerSelectedCity(city.id);
    await NotificationService.rescheduleUpcomingPrayerAzans();
    await PrayerWidgetService.updateWidgets();
    widget.onLocationSelected();
    if (mounted) Navigator.pop(context);
  }

  List<WorldCity> get _filteredCities {
    if (_searchQuery.isEmpty) return [];
    return WorldCitiesCatalog.allCities.where((city) {
      final ku = city.nameKu.toLowerCase();
      final ar = city.nameAr.toLowerCase();
      final en = city.nameEn.toLowerCase();
      final countryKu = city.countryKu.toLowerCase();
      final countryEn = city.countryEn.toLowerCase();
      return ku.contains(_searchQuery) ||
          ar.contains(_searchQuery) ||
          en.contains(_searchQuery) ||
          countryKu.contains(_searchQuery) ||
          countryEn.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isKurdish = widget.locale == 'ku';
    final isRtl = widget.locale == 'ku' || widget.locale == 'ar';

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isKurdish ? 'شوێن و شار هەڵبژێرە' : 'Select Location & City',
                  style: AppTheme.kurdishTitle(fontSize: 20, color: AppColors.gold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: AppTheme.englishText(color: AppColors.cream, fontSize: 14),
              decoration: InputDecoration(
                hintText: isKurdish ? 'گەڕان بۆ شاری دڵخواز...' : 'Search city or country...',
                hintStyle: AppTheme.kurdishText(fontSize: 13, color: AppColors.faintText),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: AppColors.faintText),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.panelColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.panelBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),

          const Divider(color: Colors.white10, height: 16),

          Expanded(
            child: _searchQuery.isNotEmpty ? _buildSearchResultsList(isKurdish) : _buildHierarchicalList(isKurdish),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSearchResultsList(bool isKurdish) {
    final results = _filteredCities;
    if (results.isEmpty) {
      return Center(
        child: Text(
          isKurdish ? 'هیچ شارێک نەدۆزرایەوە.' : 'No city found.',
          style: AppTheme.kurdishText(fontSize: 14, color: AppColors.faintText),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final city = results[index];
        final isSelected = _currentMode == 'preset' && _currentCityId == city.id;
        return _buildCityTile(city, isSelected, isKurdish);
      },
    );
  }

  Widget _buildHierarchicalList(bool isKurdish) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        // Pinned Top: GPS Option
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _currentMode == 'gps' ? AppColors.gold.withValues(alpha: 0.16) : AppColors.panelColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _currentMode == 'gps' ? AppColors.gold.withValues(alpha: 0.5) : AppColors.panelBorderColor,
              width: 1.5,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: Icon(Icons.my_location_rounded, color: AppColors.gold, size: 22),
            ),
            title: Text(
              isKurdish ? 'دیاریکردنی شوێن بە جی پی ئێس (GPS)' : 'Live GPS Auto Detect',
              style: AppTheme.kurdishText(
                fontSize: 14,
                color: _currentMode == 'gps' ? AppColors.gold : AppColors.cream,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isKurdish ? 'کاتی بانگ بەپێی شوێنی وورد و ڕاستەوخۆت حیساب دەکرێت' : 'Exact local coordinates via GPS',
              style: AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText),
            ),
            trailing: _isGpsLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  )
                : (_currentMode == 'gps' ? Icon(Icons.check_circle_rounded, color: AppColors.gold) : null),
            onTap: _selectGps,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Text(
            isKurdish ? 'هەڵبژاردنی شار بەپێی وڵات:' : 'Select city by country:',
            style: AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold),
          ),
        ),

        // Country Accordions
        ...WorldCitiesCatalog.countryGroups.map((group) => _buildCountryAccordion(group, isKurdish)),
      ],
    );
  }

  Widget _buildCountryAccordion(CountryGroup group, bool isKurdish) {
    final countryName = group.displayName(widget.locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.panelBorderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.faintText,
          leading: group.id == 'kurdistan'
              ? const KurdistanFlagWidget(width: 28, height: 19, borderRadius: 4)
              : Text(group.flag, style: const TextStyle(fontSize: 22)),
          title: Text(
            countryName,
            style: AppTheme.kurdishText(
              fontSize: 14,
              color: AppColors.cream,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${group.cities.length} ${isKurdish ? "شار" : "cities"}',
            style: AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText),
          ),
          children: group.cities.map((city) {
            final isSelected = _currentMode == 'preset' && _currentCityId == city.id;
            return _buildCityTile(city, isSelected, isKurdish);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCityTile(WorldCity city, bool isSelected, bool isKurdish) {
    final isKurdistan = city.countryEn == 'Kurdistan';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.gold.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? AppColors.gold : AppColors.mutedText,
          size: 20,
        ),
        title: Row(
          children: [
            if (isKurdistan) ...[
              const KurdistanFlagWidget(width: 18, height: 12, borderRadius: 2),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                city.displayName(widget.locale),
                style: AppTheme.kurdishText(
                  fontSize: 14,
                  color: isSelected ? AppColors.gold : AppColors.cream,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                '${city.displayCountry(widget.locale)} • ${city.timezoneAbbreviation()} (UTC${city.utcOffsetStandard >= 0 ? "+${city.utcOffsetStandard.toInt()}" : city.utcOffsetStandard.toInt()}) • Lat: ${city.latitude.toStringAsFixed(1)}, Lon: ${city.longitude.toStringAsFixed(1)}',
                style: AppTheme.englishText(fontSize: 10, color: AppColors.faintText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (city.datasetKey != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isKurdish ? 'فەرمی' : (widget.locale == 'ar' ? 'رسمي' : 'Official'),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () => _selectCity(city),
      ),
    );
  }
}
