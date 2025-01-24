import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/app/app_box_decoration.dart';

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
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.primary),
                  ),
                  Text(
                    'primary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onPrimary),
                  ),
                  Text(
                    'onPrimary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.primaryContainer),
                  ),
                  Text(
                    'primaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onPrimaryContainer),
                  ),
                  Text(
                    'onPrimaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.secondary),
                  ),
                  Text(
                    'secondary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onSecondary),
                  ),
                  Text(
                    'onSecondary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.secondaryContainer),
                  ),
                  Text(
                    'secondaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onSecondaryContainer),
                  ),
                  Text(
                    'onSecondaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.tertiary),
                  ),
                  Text(
                    'tertiary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onTertiary),
                  ),
                  Text(
                    'onTertiary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.tertiaryContainer),
                  ),
                  Text(
                    'tertiaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onTertiaryContainer),
                  ),
                  Text(
                    'onTertiaryContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.error),
                  ),
                  Text(
                    'error',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onError),
                  ),
                  Text(
                    'onError',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.errorContainer),
                  ),
                  Text(
                    'errorContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onErrorContainer),
                  ),
                  Text(
                    'onErrorContainer',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.surface),
                  ),
                  Text(
                    'surface',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onSurface),
                  ),
                  Text(
                    'onSurface',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    'onSurfaceVariant',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.inversePrimary),
                  ),
                  Text(
                    'inversePrimary',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.inverseSurface),
                  ),
                  Text(
                    'inverseSurface',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.outline),
                  ),
                  Text(
                    'outline',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 60,
                    width: 60,
                    decoration: AppBoxDecoration.boxDecorationCircle(context.theme.colorScheme.outlineVariant),
                  ),
                  Text(
                    'outlineVariant',
                    style: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
