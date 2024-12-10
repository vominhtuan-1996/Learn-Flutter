import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/core/input_formatter/input_formatter.dart';
import 'package:learnflutter/core/regex/regex.dart';
import 'package:learnflutter/custom_widget/custom_textfield.dart';
import 'package:learnflutter/helpper/datetime_format/datetime_format.dart';
import 'package:learnflutter/modules/material/component/material_textfield/material_textfield.dart';
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

  Color focusedBorderColor(int index) {
    Color colors = Colors.red;
    switch (index) {
      case 0:
        colors = Colors.blue;
        break;
      case 1:
        colors = Colors.yellow;
        break;
      case 2:
        colors = Colors.pink;
        break;
      case 3:
        colors = Colors.amber;
        break;
      default:
    }
    return colors;
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
            TextEditingController controller = TextEditingController();
            return MaterialTextField(
              hintText: hintText(index),
              keyboardType: keyboardType(index),
              onChanged: (value) {},
              inputFormatters: textInputFormatter(index),
              focusedBorderColor: focusedBorderColor(index),
              decorationBorderColor: Colors.amberAccent,
              controller: controller,
            );
          },
        )),
      ),
    );
  }
}
