// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:learnflutter/app/app_text_style.dart';
import 'package:learnflutter/modules/form_validation/manager/form_validation_manager.dart';
import 'package:learnflutter/app/app_colors.dart';

class FormValidationWidget extends StatelessWidget {
  const FormValidationWidget(
      {super.key, required this.listenable, required this.enable, required this.content, required this.title, required this.required, this.titleStyle, required this.keyListenable});
  final bool enable;
  final Widget content;
  final String title;
  final bool required;
  final TextStyle? titleStyle;
  final FormValidationManager listenable;
  final String keyListenable;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.only(bottom: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: titleStyle ?? AppTextStyles.themeBodyMedium.copyWith(color: AppColors.second_03),
                        ),
                        TextSpan(
                          text: required ? ' *' : "",
                          style: AppTextStyles.themeBodyMedium.copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                  content,
                  Visibility(
                    visible: listenable.getError(keyListenable) != null && required,
                    child: Container(
                        padding: EdgeInsets.only(top: 8),
                        width: double.infinity,
                        child: Text(
                          listenable.getError(keyListenable).toString(),
                          textAlign: TextAlign.left,
                          style: AppTextStyles.themeBodySmall.copyWith(color: AppColors.primary),
                        )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
