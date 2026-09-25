import 'package:flutter/widgets.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads localizations outside the widget tree (services, notifications).
Future<AppLocalizations> loadAppL10n() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(AppConstants.localeKey) ?? 'id';
  return AppLocalizations.delegate.load(Locale(code));
}
