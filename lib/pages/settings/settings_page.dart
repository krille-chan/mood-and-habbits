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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          DynamicColorBuilder(
            builder: (light, dark) {
              final systemColor =
                  Theme.of(context).brightness == Brightness.light
                      ? light?.primary
                      : dark?.primary;
              return GridView.builder(
                shrinkWrap: true,
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
                          ? context.l10n.systemTheme
                          : '#${color.value.toRadixString(16).toUpperCase()}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => state.appState.setThemeColor(color),
                        child: Material(
                          color: color,
                          elevation: 6,
                          borderRadius: BorderRadius.circular(8),
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
        ],
      ),
    );
  }
}
