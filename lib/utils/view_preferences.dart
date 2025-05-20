import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewPreferences {
  static const String _viewModeKey = 'view_mode';

  // Save the current view mode preference
  static Future<void> saveViewMode(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewModeKey, isGridView);
  }

  // Get the saved view mode preference
  static Future<bool> getViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to list view if no preference is saved
    return prefs.getBool(_viewModeKey) ?? false;
  }
}