// tạo 1 màn hình profile tiêu chuẩn cho ứng dụng
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/app_text_style.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingThemeCubit, SettingThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: context.textTheme.headlineMedium,
            ),
            backgroundColor: context.theme.appBarTheme.backgroundColor,
            iconTheme: context.theme.iconTheme,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(context, state),
                const SizedBox(height: 24.0),
                _buildProfileInfo(context, state),
                const SizedBox(height: 24.0),
                _buildActions(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, SettingThemeState state) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.person,
            size: 80,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'John Doe',
          style: context.textTheme.headlineSmall?.copyWith(),
        ),
        const SizedBox(height: 8.0),
        Text(
          ' ',
          style: context.textTheme.bodyMedium?.copyWith(),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, SettingThemeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email:',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          '   ',
          style: context.textTheme.bodyMedium?.copyWith(),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Phone:',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          '   ',
          style: context.textTheme.bodyMedium?.copyWith(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, SettingThemeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions:',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            // handle edit profile
          },
          child: const Text('Edit Profile'),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            // handle logout
          },
          child: const Text('Logout'),
        ),
        OutlinedButton.icon(
          label: const Text('Settings Theme'),
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.pageThemeScreen);
          },
        ),
      ],
    );
  }
}
