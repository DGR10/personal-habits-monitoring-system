import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: ListView(
        children: [
          // System Default option removed as per user request
          RadioListTile<String>(
            title: Text(l10n.english),
            value: 'en',
            groupValue: currentLocale?.languageCode ?? 'en', // Fallback to en if system is en, but logic handled in provider mostly
            onChanged: (value) {
              localeProvider.setLocale(const Locale('en'));
            },
            selected: currentLocale?.languageCode == 'en',
          ),
          RadioListTile<String>(
            title: Text(l10n.spanish),
            value: 'es',
            groupValue: currentLocale?.languageCode,
            onChanged: (value) {
              localeProvider.setLocale(const Locale('es'));
            },
            selected: currentLocale?.languageCode == 'es',
          ),
        ],
      ),
    );
  }
}
