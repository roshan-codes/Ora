import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../models/world_clock_city.dart';
import '../../../data/local_storage/preferences_service.dart';

class WorldClockController extends ChangeNotifier {
  final PreferencesService _prefsService;

  List<WorldClockCity> _selectedCities = [];
  String _selectedCityId = 'mumbai'; // Selected card (Mumbai in reference design)
  Timer? _ticker;
  bool _isLoading = true;

  WorldClockController({PreferencesService? prefsService})
      : _prefsService = prefsService ?? PreferencesService.instance {
    _init();
  }

  List<WorldClockCity> get selectedCities => List.unmodifiable(_selectedCities);
  String get selectedCityId => _selectedCityId;
  bool get isLoading => _isLoading;

  WorldClockCity? get activeHeroCity {
    return _selectedCities.firstWhere(
      (c) => c.id == _selectedCityId,
      orElse: () => _selectedCities.isNotEmpty
          ? _selectedCities.first
          : const WorldClockCity(
              id: 'local',
              cityName: 'Local',
              countryName: 'Current Timezone',
              timezoneId: 'UTC',
            ),
    );
  }

  Future<void> _init() async {
    tz.initializeTimeZones();
    await _loadCities();

    // Live clock ticker
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  Future<void> _loadCities() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawList = await _prefsService.getCitiesRaw();
      if (rawList.isEmpty) {
        // Initial 3 cities from the reference screenshot
        _selectedCities = [
          const WorldClockCity(
            id: 'tokyo',
            cityName: 'Tokyo',
            countryName: 'Japan',
            timezoneId: 'Asia/Tokyo',
          ),
          const WorldClockCity(
            id: 'mumbai',
            cityName: 'Mumbai',
            countryName: 'India',
            timezoneId: 'Asia/Kolkata',
          ),
          const WorldClockCity(
            id: 'los_angeles',
            cityName: 'Los Angels',
            countryName: 'United States',
            timezoneId: 'America/Los_Angeles',
          ),
        ];
        _selectedCityId = 'mumbai';
        await _saveCities();
      } else {
        _selectedCities = rawList.map((m) => WorldClockCity.fromJson(m)).toList();
        if (_selectedCities.isNotEmpty &&
            !_selectedCities.any((c) => c.id == _selectedCityId)) {
          _selectedCityId = _selectedCities.first.id;
        }
      }
    } catch (e) {
      debugPrint('[WorldClockController] Error loading cities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCities() async {
    final raw = _selectedCities.map((c) => c.toJson()).toList();
    await _prefsService.saveCitiesRaw(raw);
  }

  Future<void> addCity(WorldClockCity city) async {
    if (_selectedCities.any((c) => c.id == city.id)) return;
    _selectedCities.add(city);
    notifyListeners();
    await _saveCities();
  }

  Future<void> removeCity(String id) async {
    _selectedCities.removeWhere((c) => c.id == id);
    if (_selectedCityId == id && _selectedCities.isNotEmpty) {
      _selectedCityId = _selectedCities.first.id;
    }
    notifyListeners();
    await _saveCities();
  }

  void selectCity(String id) {
    _selectedCityId = id;
    notifyListeners();
  }

  // Predefined catalog of major world cities for search
  static const List<WorldClockCity> allSearchableCities = [
    WorldClockCity(
      id: 'tokyo',
      cityName: 'Tokyo',
      countryName: 'Japan',
      timezoneId: 'Asia/Tokyo',
    ),
    WorldClockCity(
      id: 'mumbai',
      cityName: 'Mumbai',
      countryName: 'India',
      timezoneId: 'Asia/Kolkata',
    ),
    WorldClockCity(
      id: 'los_angeles',
      cityName: 'Los Angels',
      countryName: 'United States',
      timezoneId: 'America/Los_Angeles',
    ),
    WorldClockCity(
      id: 'london',
      cityName: 'London',
      countryName: 'United Kingdom',
      timezoneId: 'Europe/London',
    ),
    WorldClockCity(
      id: 'new_york',
      cityName: 'New York',
      countryName: 'United States',
      timezoneId: 'America/New_York',
    ),
    WorldClockCity(
      id: 'paris',
      cityName: 'Paris',
      countryName: 'France',
      timezoneId: 'Europe/Paris',
    ),
    WorldClockCity(
      id: 'sydney',
      cityName: 'Sydney',
      countryName: 'Australia',
      timezoneId: 'Australia/Sydney',
    ),
    WorldClockCity(
      id: 'dubai',
      cityName: 'Dubai',
      countryName: 'United Arab Emirates',
      timezoneId: 'Asia/Dubai',
    ),
    WorldClockCity(
      id: 'singapore',
      cityName: 'Singapore',
      countryName: 'Singapore',
      timezoneId: 'Asia/Singapore',
    ),
    WorldClockCity(
      id: 'berlin',
      cityName: 'Berlin',
      countryName: 'Germany',
      timezoneId: 'Europe/Berlin',
    ),
    WorldClockCity(
      id: 'toronto',
      cityName: 'Toronto',
      countryName: 'Canada',
      timezoneId: 'America/Toronto',
    ),
    WorldClockCity(
      id: 'seoul',
      cityName: 'Seoul',
      countryName: 'South Korea',
      timezoneId: 'Asia/Seoul',
    ),
    WorldClockCity(
      id: 'cairo',
      cityName: 'Cairo',
      countryName: 'Egypt',
      timezoneId: 'Africa/Cairo',
    ),
    WorldClockCity(
      id: 'sao_paulo',
      cityName: 'Sao Paulo',
      countryName: 'Brazil',
      timezoneId: 'America/Sao_Paulo',
    ),
  ];

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

