import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

import 'package:mood_n_habbits/config/theme.dart';
import 'package:mood_n_habbits/pages/settings/settings_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class SettingsPage extends StatelessWidget {
  final SettingsPageState state;
  const SettingsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    const colorPickerSize = 32.0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              context.l10n.setColorTheme,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SegmentedButton<ThemeMode>(
              selected: {
                state.appState.theme.value.themeMode ?? ThemeMode.system,
              },
              onSelectionChanged: (selected) =>
                  state.appState.setThemeMode(selected.single),
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(context.l10n.light),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(context.l10n.dark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(context.l10n.system),
                  icon: const Icon(Icons.auto_mode_outlined),
                ),
              ],
            ),
          ),
          DynamicColorBuilder(
            builder: (light, dark) {
              final systemColor =
                  Theme.of(context).brightness == Brightness.light
                      ? light?.primary
                      : dark?.primary;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 64,
                ),
                itemCount: customColors.length,
                itemBuilder: (context, i) {
                  final color =
                      customColors[i] ?? systemColor ?? Colors.lightBlueAccent;
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Tooltip(
                      message: customColors[i] == null
                          ? context.l10n.system
                          : '#${color.value.toRadixString(16).toUpperCase()}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32.0),
                        onTap: () => state.appState.setThemeColor(color),
                        child: Material(
                          color: color,
                          elevation: 1,
                          borderRadius: BorderRadius.circular(32.0),
                          child: SizedBox(
                            width: colorPickerSize,
                            height: colorPickerSize,
                            child: state.appState.theme.value.primaryColor
                                        ?.value ==
                                    color.value
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Divider(color: theme.colorScheme.surfaceContainer),
          ListTile(
            title: Text(
              context.l10n.appDataSettings,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(context.l10n.importData),
            leading: const Icon(Icons.upload_outlined),
            onTap: () => state.importAppData(context),
          ),
          ListTile(
            title: Text(context.l10n.exportData),
            leading: const Icon(Icons.download_outlined),
            onTap: () => state.exportAppData(context),
          ),
          ListTile(
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
            title: Text(context.l10n.resetData),
            leading: const Icon(Icons.delete_forever_outlined),
            onTap: () => state.deleteAppData(context),
          ),
        ],
      ),
    );
  }
}
