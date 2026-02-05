import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('preferred_language') ?? 'en';
    _locale = Locale(savedLocale);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'hi'].contains(locale.languageCode)) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', locale.languageCode);
    
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('hi'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}
