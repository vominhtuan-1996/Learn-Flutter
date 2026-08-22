import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/app/localization/app_local_translate.dart';

class LanguageSwitchDemoScreen extends StatefulWidget {
  const LanguageSwitchDemoScreen({super.key});

  @override
  State<LanguageSwitchDemoScreen> createState() => _LanguageSwitchDemoScreenState();
}

class _LanguageSwitchDemoScreenState extends State<LanguageSwitchDemoScreen> {
  final _localization = FlutterLocalization.instance;

  static const _languages = [
    _LangOption('en', 'US', '🇺🇸', 'English'),
    _LangOption('vi', 'VN', '🇻🇳', 'Tiếng Việt'),
    _LangOption('km', 'KH', '🇰🇭', 'ខ្មែរ'),
    _LangOption('ja', 'JP', '🇯🇵', '日本語'),
  ];

  String get _currentCode => _localization.currentLocale?.languageCode ?? 'vi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Switch Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Language selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Language', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _languages.map((lang) {
                      final selected = _currentCode == lang.code;
                      return ChoiceChip(
                        label: Text('${lang.flag} ${lang.name}'),
                        selected: selected,
                        onSelected: (_) {
                          _localization.translate(lang.code);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Demo translations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Translations Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _Row('App Title', AppLocaleTranslate.title.getString(context)),
                  _Row('Login', AppLocaleTranslate.loginTitle.getString(context)),
                  _Row('Email', AppLocaleTranslate.emailLabel.getString(context)),
                  _Row('Password', AppLocaleTranslate.passwordLabel.getString(context)),
                  _Row('Forgot Password', AppLocaleTranslate.forgotPassword.getString(context)),
                  _Row('Save', AppLocaleTranslate.saveButton.getString(context)),
                  _Row('Cancel', AppLocaleTranslate.cancel.getString(context)),
                  _Row('Yes', AppLocaleTranslate.yes.getString(context)),
                  _Row('No', AppLocaleTranslate.no.getString(context)),
                  _Row('Success', AppLocaleTranslate.success.getString(context)),
                  _Row('Error', AppLocaleTranslate.error.getString(context)),
                  _Row('Loading', AppLocaleTranslate.loadingData.getString(context)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Full UI demo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('UI Demo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocaleTranslate.emailLabel.getString(context),
                      hintText: AppLocaleTranslate.emailHint.getString(context),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocaleTranslate.passwordLabel.getString(context),
                      hintText: AppLocaleTranslate.passwordHint.getString(context),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(AppLocaleTranslate.forgotPassword.getString(context)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {},
                    child: Text(AppLocaleTranslate.loginButton.getString(context)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(AppLocaleTranslate.cancel.getString(context)),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: Text(AppLocaleTranslate.confirm.getString(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.key_, this.value);
  final String key_;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(key_, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _LangOption {
  const _LangOption(this.code, this.countryCode, this.flag, this.name);
  final String code;
  final String countryCode;
  final String flag;
  final String name;
}
