import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themeSettings),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(l10n.themeModeLabel),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      themeProvider.setThemeMode(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
                    DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),

              Text(l10n.themeStyleLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              RadioListTile<AppThemeStyle>(
                title: Text(l10n.material),
                value: AppThemeStyle.material,
                groupValue: themeProvider.themeStyle,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeStyle(value);
                },
              ),
              RadioListTile<AppThemeStyle>(
                title: Text(l10n.minimalist),
                value: AppThemeStyle.nothing,
                groupValue: themeProvider.themeStyle,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeStyle(value);
                },
              ),
              const Divider(),
              if (themeProvider.themeStyle == AppThemeStyle.material) ...[
                const SizedBox(height: 16),
                Text(l10n.colorTheme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                    Colors.red,
                    Colors.teal,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        themeProvider.setSeedColor(color);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: themeProvider.seedColor == color
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
