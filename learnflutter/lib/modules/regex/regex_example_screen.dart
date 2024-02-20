import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/core/input_formatter/input_formatter.dart';
import 'package:learnflutter/core/regex/regex.dart';
import 'package:learnflutter/custom_widget/custom_textfield.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class RegexExampleScreen extends StatefulWidget {
  const RegexExampleScreen({super.key});
  @override
  State<RegexExampleScreen> createState() => RegexExampleScreenState();
}

class RegexExampleScreenState extends State<RegexExampleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String hintText(int index) {
    String result = '';
    switch (index) {
      case 0:
        result = 'RegexEmail';
        break;
      case 1:
        result = 'Regex Phone Number';
        break;
      case 2:
        result = 'Replace';
        break;
      case 3:
        result = 'Format datetime dd/mm/yyyy';
        break;
      default:
    }
    return result;
  }

  List<TextInputFormatter> textInputFormatter(int index) {
    List<TextInputFormatter> temp = [];
    switch (index) {
      case 0:
        temp = InputFormattersHelper.inputFormatterTextValidationEmail();
        break;
      case 1:
        temp = InputFormattersHelper.inputFormatterPhoneNumbber();
        break;
      case 2:
        temp = InputFormattersHelper.inputFormatteReplace(from: ',', replace: '.', limitLength: 10);
        break;
      case 3:
        temp = InputFormattersHelper.inputFormatteDate();
        break;
      default:
    }
    return temp;
  }

  TextInputType keyboardType(int index) {
    TextInputType temp = TextInputType.text;
    switch (index) {
      case 0:
        temp = TextInputType.text;
        break;
      case 1:
        temp = TextInputType.phone;
        break;
      case 2:
        temp = const TextInputType.numberWithOptions(decimal: true, signed: false);
        break;
      case 3:
        temp = const TextInputType.numberWithOptions(decimal: true, signed: true);
        break;
      default:
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: SingleChildScrollView(
        child: Column(
            children: List.generate(
          20,
          (index) {
            return Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: AppBoxDecoration.boxDecorationGreyBorder,
                child: CustomTextField(
                  hintText: hintText(index),
                  hintStyle: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  secureText: false,
                  textAlign: TextAlign.left,
                  keyboardType: keyboardType(index),
                  borderRadius: 14,
                  textCapitalization: TextCapitalization.none,
                  isShowCounterText: false,
                  onTextChange: (value) {},
                  inputFormatters: textInputFormatter(index),
                ),
              ),
            );
          },
        )),
      ),
    );
  }
}
