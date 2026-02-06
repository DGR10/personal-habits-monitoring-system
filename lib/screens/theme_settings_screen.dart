import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme Mode'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      themeProvider.setThemeMode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),

              const Text('Theme Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              RadioListTile<AppThemeStyle>(
                title: const Text('Material'),
                value: AppThemeStyle.material,
                groupValue: themeProvider.themeStyle,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeStyle(value);
                },
              ),
              RadioListTile<AppThemeStyle>(
                title: const Text('Nothing (Minimalist)'),
                value: AppThemeStyle.nothing,
                groupValue: themeProvider.themeStyle,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeStyle(value);
                },
              ),
              const Divider(),
              if (themeProvider.themeStyle == AppThemeStyle.material) ...[
                const SizedBox(height: 16),
                const Text('Color Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
