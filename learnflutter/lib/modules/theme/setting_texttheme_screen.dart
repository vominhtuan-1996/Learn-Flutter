import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/theme_token/extension_theme.dart';
import 'package:learnflutter/core/theme_token/text_token.dart';
import 'package:learnflutter/modules/color_picker/color_picker.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

class SettingTextThemeScreen extends StatefulWidget {
  const SettingTextThemeScreen({super.key, required this.role});
  final TextRole role;

  @override
  State<SettingTextThemeScreen> createState() => _SettingTextThemeScreenState();
}

class _SettingTextThemeScreenState extends State<SettingTextThemeScreen> {
  String selectedStyle = 'displayLarge';
  // define co tôi khoảng 20 item

  final fonts = [
    'Roboto',
    'Inter',
    'Poppins',
    'Montserrat',
    'Lato',
    'Open Sans',
    'Noto Sans',
    'Nunito',
    'Raleway',
    'Merriweather',
    'Roboto Slab',
    'Source Sans Pro',
    'Ubuntu',
    'Oswald',
    'PT Sans',
    'Fira Sans',
    'Playfair Display',
    'Rubik',
    'Quicksand',
    'Work Sans',
    'Bebas Neue',
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = getThemeBloc(context);
    final token = bloc.state.tokens.texts.getByRole(widget.role);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Text style selector

            const SizedBox(height: 16),

            /// Font size
            Text('Size: ${bloc.state.tokens.texts.getByRole(widget.role).size.toStringAsFixed(0)}'),
            Slider(
              min: 10,
              max: 60,
              value: token.size,
              onChanged: (v) {
                final updated = token.copyWith(size: v);

                bloc.updateTextTokens(
                  bloc.state.tokens.texts.update(widget.role, updated),
                );
              },
            ),

            const SizedBox(height: 16),

            /// Font Weight
            Text('Weight: ${token.weight}'),
            _FontWeightSelector(
              selectedWeight: token.weight,
              onChanged: (weight) {
                final updated = token.copyWith(weight: weight);
                bloc.updateTextTokens(
                  bloc.state.tokens.texts.update(widget.role, updated),
                );
              },
            ),

            const SizedBox(height: 16),

            /// Color picker
            Row(
              children: [
                const Text('Color'),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    DialogUtils.showBasicDialog(
                      context: context,
                      title: 'Color Value',
                      contentWidget: CircleColorPicker(
                        initialColor: bloc.state.tokens.texts.getByRole(widget.role).color ??
                            context.theme.colorScheme.onBackground,
                        thumbRadius: 10,
                        colorListener: (Color value) {
                          final updated = token.copyWith(color: value);

                          bloc.updateTextTokens(
                            bloc.state.tokens.texts.update(widget.role, updated),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close')),
                      ],
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(
                        bloc.state.tokens.texts.getByRole(widget.role).color ??
                            context.theme.colorScheme.onBackground),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // dropdown for font family
            DropdownButton<String>(
              value: token.fontFamily.split('_').first,
              items: fonts.map((String font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: Text(
                    font,
                    style: buildGoogleFont(TextToken(
                      fontFamily: font,
                      size: token.size,
                      weight: token.weight,
                      color: token.color,
                    )),
                  ),
                );
              }).toList(),
              onChanged: (String? newFont) {
                if (newFont != null) {
                  final updated = token.copyWith(fontFamily: '${newFont}_${token.weight.index}');
                  bloc.updateTextTokens(
                    bloc.state.tokens.texts.update(widget.role, updated),
                  );
                }
              },
            ),
            // / Preview
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.remove_red_eye),
              iconAlignment: IconAlignment.start,
              label: Text(
                'Live Preview Text',
                style: buildGoogleFont(bloc.state.tokens.texts.getByRole(widget.role)),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  TextStyle buildGoogleFont(TextToken token) {
    return GoogleFonts.getFont(
      token.fontFamily.split('_').first,
      fontSize: token.size,
      fontWeight: token.weight,
      color: token.color ?? context.theme.colorScheme.onBackground,
    );
  }
}

/// Widget để chọn FontWeight
class _FontWeightSelector extends StatelessWidget {
  final FontWeight selectedWeight;
  final ValueChanged<FontWeight> onChanged;

  const _FontWeightSelector({
    required this.selectedWeight,
    required this.onChanged,
  });

  static const _weightOptions = <String, FontWeight>{
    'Thin (100)': FontWeight.w100,
    'ExtraLight (200)': FontWeight.w200,
    'Light (300)': FontWeight.w300,
    'Regular (400)': FontWeight.w400,
    'Medium (500)': FontWeight.w500,
    'SemiBold (600)': FontWeight.w600,
    'Bold (700)': FontWeight.w700,
    'ExtraBold (800)': FontWeight.w800,
    'Black (900)': FontWeight.w900,
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButton<FontWeight>(
      isExpanded: true,
      value: selectedWeight,
      onChanged: (weight) {
        if (weight != null) onChanged(weight);
      },
      items: _weightOptions.entries.map((e) {
        return DropdownMenuItem<FontWeight>(
          value: e.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key),
              Text(
                'Aa',
                style: TextStyle(fontWeight: e.value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
