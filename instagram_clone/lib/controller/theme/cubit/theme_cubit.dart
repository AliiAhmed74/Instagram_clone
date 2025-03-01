import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadTheme();
  }

  static const String THEME_KEY = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(THEME_KEY);
    if (savedTheme != null) {
      emit(ThemeState(
        themeMode: savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      ));
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(THEME_KEY, newThemeMode == ThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: newThemeMode));
  }

  bool get isDarkMode => state.themeMode == ThemeMode.dark;
}