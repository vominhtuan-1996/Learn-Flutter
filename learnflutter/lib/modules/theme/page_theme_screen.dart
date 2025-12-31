import 'package:flutter/material.dart';
import 'package:learnflutter/component/routes/argument_screen_model.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/theme_token/colors_token.dart';
import 'package:learnflutter/core/theme_token/extension_theme.dart';
import 'package:learnflutter/modules/color_picker/color_picker.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';

class TestThemeScreen extends StatefulWidget {
  const TestThemeScreen({super.key});
  @override
  State<TestThemeScreen> createState() => TestThemeScreenState();
}

class TestThemeScreenState extends State<TestThemeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final colorSchemeItems = <ColorSchemeItem>[
    ColorSchemeItem(
      label: 'primary',
      getColor: (c) => c.primary,
      copyWith: (t, v) => t.copyWith(primary: v),
    ),
    ColorSchemeItem(
      label: 'onPrimary',
      getColor: (c) => c.onPrimary,
      copyWith: (t, v) => t.copyWith(onPrimary: v),
    ),
    ColorSchemeItem(
      label: 'secondary',
      getColor: (c) => c.secondary,
      copyWith: (t, v) => t.copyWith(secondary: v),
    ),
    ColorSchemeItem(
      label: 'background',
      getColor: (c) => c.background,
      copyWith: (t, v) => t.copyWith(background: v),
    ),
    ColorSchemeItem(
      label: 'surface',
      getColor: (c) => c.surface,
      copyWith: (t, v) => t.copyWith(surface: v),
    ),
    ColorSchemeItem(
      label: 'error',
      getColor: (c) => c.error,
      copyWith: (t, v) => t.copyWith(error: v),
    ),
    ColorSchemeItem(
      label: 'onBackground',
      getColor: (c) => c.onBackground,
      copyWith: (t, v) => t.copyWith(onBackground: v),
    ),
    ColorSchemeItem(
      label: 'onSurface',
      getColor: (c) => c.onSurface,
      copyWith: (t, v) => t.copyWith(onSurface: v),
    ),
  ];

  final List<TextThemeItem> textThemeItems = [
    TextThemeItem(
      title: 'Display Large Text Theme',
      selector: (textTheme) {
        return textTheme.displayLarge;
      },
      role: TextRole.displayLarge,
    ),
    TextThemeItem(
      title: 'Display Medium Text Theme',
      selector: (textTheme) => textTheme.displayMedium,
      role: TextRole.displayMedium,
    ),
    TextThemeItem(
      title: 'Display Small Text Theme',
      selector: (textTheme) => textTheme.displaySmall,
      role: TextRole.displaySmall,
    ),
    TextThemeItem(
      title: 'Headline Large Text Theme',
      selector: (textTheme) => textTheme.headlineLarge,
      role: TextRole.headlineLarge,
    ),
    TextThemeItem(
      title: 'Headline Medium Text Theme',
      selector: (textTheme) => textTheme.headlineMedium,
      role: TextRole.headlineMedium,
    ),
    TextThemeItem(
      title: 'Headline Small Text Theme',
      selector: (textTheme) => textTheme.headlineSmall,
      role: TextRole.headlineSmall,
    ),
    TextThemeItem(
      title: 'Title Large Text Theme',
      selector: (textTheme) => textTheme.titleLarge,
      role: TextRole.titleLarge,
    ),
    TextThemeItem(
      title: 'Title Medium Text Theme',
      selector: (textTheme) => textTheme.titleMedium,
      role: TextRole.titleMedium,
    ),
    TextThemeItem(
      title: 'Title Small Text Theme',
      selector: (t) => t.titleSmall,
      role: TextRole.titleSmall,
    ),
    TextThemeItem(
      title: 'Body Large Text Theme',
      selector: (t) => t.bodyLarge,
      role: TextRole.bodyLarge,
    ),
    TextThemeItem(
      title: 'Body Medium Text Theme',
      selector: (t) => t.bodyMedium,
      role: TextRole.bodyMedium,
    ),
    TextThemeItem(
      title: 'Body Small Text Theme',
      selector: (t) => t.bodySmall,
      role: TextRole.bodySmall,
    ),
    TextThemeItem(
      title: 'Label Large Text Theme',
      selector: (t) => t.labelLarge,
      role: TextRole.labelLarge,
    ),
    TextThemeItem(
      title: 'Label Medium Text Theme',
      selector: (t) => t.labelMedium,
      role: TextRole.labelMedium,
    ),
    TextThemeItem(
      title: 'Label Small Text Theme',
      selector: (t) => t.labelSmall,
      role: TextRole.labelSmall,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme colorScheme',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SwitchListTile(
                title: Text(
                  'Light Mode / Dark Mode',
                  style: context.textTheme.bodyMedium,
                ),
                value: getThemeBloc(context).state.tokens.isLight,
                onChanged: (value) {
                  getThemeBloc(context).toggleBrightness(value);
                },
              ),
              Column(
                children: colorSchemeItems.map((item) => ColorItemRow(item: item)).toList(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: textThemeItems.map((item) {
                  final style = item.selector(context.theme.textTheme);
                  return TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.settingTextThemeScreen,
                        arguments: ArgumentsScreenModel(
                          data: {
                            'style': style,
                            'role': item.role,
                          },
                          title: item.title,
                        ),
                      );
                    },
                    child: Text(
                      item.title,
                      style: style,
                    ),
                  );
                }).toList(),
              ),
              TextButton(
                onPressed: () {
                  getThemeBloc(context).resetTheme();
                },
                child: Text('Reset Theme'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextThemeItem {
  final String title;
  final TextStyle? Function(TextTheme textTheme) selector;
  final TextRole? role;

  const TextThemeItem({
    required this.title,
    required this.selector,
    required this.role,
  });
}

class ColorSchemeItem {
  final String label;
  final Color Function(ColorScheme) getColor;
  final ColorTokens Function(ColorTokens, Color) copyWith;

  const ColorSchemeItem({
    required this.label,
    required this.getColor,
    required this.copyWith,
  });
}

class ColorItemRow extends StatelessWidget {
  final ColorSchemeItem item;

  const ColorItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = item.getColor(theme.colorScheme);

    return Row(
      children: [
        GestureDetector(
          onTap: () => _openPicker(context, color),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 60,
            width: 60,
            decoration: AppBoxDecoration.boxDecorationCircle(color),
          ),
        ),
        Text(
          item.label,
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context, Color initial) {
    DialogUtils.showBasicDialog(
      context: context,
      title: 'Color Value',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleColorPicker(
            initialColor: initial,
            thumbRadius: 10,
            colorListener: (value) {
              getThemeBloc(context).updateColors(
                item.copyWith(
                  getThemeBloc(context).state.tokens.colors,
                  value,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          BarColorPicker(
            initialColor: initial,
            cornerRadius: 10,
            pickMode: PickMode.Grey,
            colorListener: (value) {
              getThemeBloc(context).updateColors(
                item.copyWith(
                  getThemeBloc(context).state.tokens.colors,
                  value,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          BarColorPicker(
            initialColor: initial,
            cornerRadius: 10,
            pickMode: PickMode.Color,
            colorListener: (value) {
              getThemeBloc(context).updateColors(
                item.copyWith(
                  getThemeBloc(context).state.tokens.colors,
                  value,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
