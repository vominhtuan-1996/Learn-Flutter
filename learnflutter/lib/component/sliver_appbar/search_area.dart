import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/component/sliver_appbar/icon_img_button.dart';

class SearchArea extends StatefulWidget {
  SearchArea({
    super.key,
    required this.appBarContentWidth,
    required this.appBarSpace,
    required this.iconBgrColor,
  });
  @override
  State<SearchArea> createState() => _SearchAreaState();
  final double appBarContentWidth;
  final SizedBox appBarSpace;
  final Color iconBgrColor;
}

class _SearchAreaState extends State<SearchArea> {
  TextEditingController _controllerTextField = TextEditingController();
  bool isSearch = false;
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
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 48,
          width: widget.appBarContentWidth - IconImgButton.tapTargetSize - widget.appBarSpace.width! * 3 - 4,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: widget.iconBgrColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: initUITextField(),
        ),
      ],
    );
  }

  TextField initUITextField() {
    return TextField(
      controller: _controllerTextField,
      autofocus: false,
      style: const TextStyle(
        fontSize: 14, //fontSizeSearchView,
        color: const Color(0xFFFDA758),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        prefixIcon: Image.asset(loadImageWithImageName('ic_search_organe', TypeImage.png)),
        suffixIcon: _controllerTextField.text.isNotEmpty ? initUISuffixIconSearchView() : null,
        hintText: "Tìm kiếm chức năng",
        hintStyle: textStyleManrope(const Color(0xFFFDA758).withOpacity(0.5), 14, FontWeight.normal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      onChanged: ((value) {
        // FillterSearchViewWithText(value);
      }),
    );
  }

  GestureDetector initUISuffixIconSearchView() {
    return GestureDetector(
        onTap: () {
          setState(() {
            isSearch = false;
            _controllerTextField.clear();
          });
        },
        child: const Icon(
          Icons.close,
          color: Color(0xFFFDA758),
        ));
  }
}
