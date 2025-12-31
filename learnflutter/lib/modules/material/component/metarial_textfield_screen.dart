import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialTextFieldScreen extends StatefulWidget {
  const MaterialTextFieldScreen({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialTextFieldScreen> createState() => _MaterialTextFieldScreenState();
}

class _MaterialTextFieldScreenState extends State<MaterialTextFieldScreen>
    with ComponentMaterialDetail {
  late TextEditingController _textFieldController;
  @override
  void initState() {
    _textFieldController = TextEditingController();
    _textFieldController.addListener(
      () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textFieldController,
                  enabled: true,
                  buildCounter: (context,
                      {required currentLength, required isFocused, required maxLength}) {
                    return Text(
                      '$currentLength/$maxLength ký tự',
                      semanticsLabel: 'character count',
                    );
                  },
                  maxLength: 10000,
                  decoration: InputDecoration(
                    helperText:
                        'Reloaded 1 of 2275 libraries in 2,537ms (compile: 20 ms, reload: 1441 ms, reassemble: 992 ms).Reloaded 1 of 2275 libraries in 2,537ms (compile: 20 ms, reload: 1441 ms, reassemble: 992 ms).',
                    labelText: 'Nhập công suất',
                    hintText: 'Nhập công suất',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _textFieldController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _textFieldController.clear();
                              });
                            },
                            child: const Icon(
                              Icons.close_sharp,
                            ),
                          )
                        : null,
                  ),
                  // maxLines: 1,
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textFieldController,
                  enabled: false,
                  buildCounter: (context,
                      {required currentLength, required isFocused, required maxLength}) {
                    return Text(
                      '$currentLength/$maxLength ký tự',
                      semanticsLabel: 'character count',
                    );
                  },
                  maxLength: 10000,
                  decoration: InputDecoration(
                    helperText:
                        'Reloaded 1 of 2275 libraries in 2,537ms (compile: 20 ms, reload: 1441 ms, reassemble: 992 ms).Reloaded 1 of 2275 libraries in 2,537ms (compile: 20 ms, reload: 1441 ms, reassemble: 992 ms).',
                    labelText: 'Nhập công suất',
                    hintText: 'Nhập công suất',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _textFieldController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _textFieldController.clear();
                              });
                            },
                            child: const Icon(
                              Icons.close_sharp,
                            ),
                          )
                        : null,
                  ),
                  // maxLines: 1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
