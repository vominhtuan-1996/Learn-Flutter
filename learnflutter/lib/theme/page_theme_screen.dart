import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/extension/extension_context.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.secondary,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onSecondary,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.secondaryContainer,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onSecondaryContainer,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.tertiary,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onTertiary,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.tertiaryContainer,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onTertiaryContainer,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                margin: const EdgeInsets.only(left: 8, right: 8),
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
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.surface,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onSurface,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.inversePrimary,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.inverseSurface,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.outline,
          ),
          Container(
            height: 100,
            width: context.mediaQuery.size.width,
            color: context.theme.colorScheme.outlineVariant,
          ),
        ],
      ))),
    );
  }
}
