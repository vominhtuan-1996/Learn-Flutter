import 'package:flutter/material.dart';
import 'package:learnflutter/modules/form_validation/manager/form_validation_manager.dart';
import 'package:learnflutter/modules/form_validation/widget/form_validation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FormValidationDemo(),
    );
  }
}

class FormValidationDemo2 extends StatefulWidget {
  const FormValidationDemo2({super.key});
  @override
  State<FormValidationDemo2> createState() => FormValidationDemo2State();
}

class FormValidationDemo2State extends State<FormValidationDemo2> {
  final FormValidationManager validationManager = FormValidationManager();
  List? listImage = [];
  @override
  void initState() {
    List.generate(
      5,
      (index) {
        listImage?.add(1);
      },
    );
    validationManager.addField(
      'email',
      (value) {
        if (value == null) {
          return 'Invalid email';
        }
        return (value as String).isNotEmpty && value.contains('@') ? null : 'Invalid email';
      },
    );
    validationManager.addField(
      'password',
      (value) {
        if (value == null) {
          return 'Password too short';
        }
        return (value as String).isNotEmpty && value.length > 6 ? null : 'Password too short';
      },
    );
    validationManager.addField(
      'age',
      (value) {
        if (value == null) {
          return 'chưa đủ tuổi';
        }
        return (value as String).isNotEmpty && value as int > 18 ? null : 'chưa đủ tuổi';
      },
    );

    validationManager.addField(
      'male',
      (value) {
        if (value == null) {
          return 'không có giới tính phù hợp';
        }
        return (value as String).isNotEmpty && value == "Nam" || value == "Nữ" ? null : 'không có giới tính phù hợp';
      },
    );
    validationManager.addField(
      'accImaes',
      (value) {
        if (value == null) {
          return 'Vui lòng nhập đủ thông';
        }
        bool isTrue = true;
        for (var element in value) {
          if (element.require == true) {
            if (!element.isPathFileNotEmpty() && element.isLinkOrKeyEmpty()) {
              isTrue = false;
              break;
            }
          }
        }
        return isTrue ? null : 'Vui lòng nhập đủ thông';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation Demo 2'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('email', value);
                  },
                ),
                title: 'Email',
                required: true,
                keyListenable: "email",
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('password', value);
                  },
                ),
                title: "Password",
                keyListenable: 'password',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('age', value);
                  },
                ),
                title: "Age",
                keyListenable: 'age',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('male', value);
                  },
                ),
                title: "Male",
                keyListenable: 'male',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('accImaes', listImage);
                  },
                ),
                title: "accImaes",
                keyListenable: 'accImaes',
                required: true,
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: validationManager,
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: () {
                      if (validationManager.validate()) {
                        // _submitForm();
                      }
                    },
                    child: const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormValidationDemo extends StatelessWidget {
  final FormValidationManager validationManager = FormValidationManager();
  List? listImage = [];
  List? listSelected = [];
  FormValidationDemo({super.key}) {
    List.generate(
      5,
      (index) {
        listSelected?.add(1);
      },
    );
    List.generate(
      5,
      (index) {
        listImage?.add(
          1,
        );
      },
    );
    validationManager.addField(
      'email',
      (value) {
        if (value == null) {
          return 'Invalid email';
        }
        return (value as String).isNotEmpty && value.contains('@') ? null : 'Invalid email';
      },
    );
    validationManager.addField(
      'password',
      (value) {
        if (value == null) {
          return 'Password too short';
        }
        return (value as String).isNotEmpty && value.length > 6 ? null : 'Password too short';
      },
    );
    validationManager.addField(
      'age',
      (value) {
        if (value == null) {
          return 'chưa đủ tuổi';
        }
        return (value as String).isNotEmpty && value as int > 18 ? null : 'chưa đủ tuổi';
      },
    );

    validationManager.addField(
      'male',
      (value) {
        if (value == null) {
          return 'không có giới tính phù hợp';
        }
        return (value as String).isNotEmpty && value == "Nam" || value == "Nữ" ? null : 'không có giới tính phù hợp';
      },
    );
    validationManager.addField(
      'accImaes',
      (value) {
        if (value == null) {
          return 'Vui lòng nhập đủ thông';
        }
        bool isTrue = true;
        for (var element in value) {
          if (element.require == true) {
            if (!element.isPathFileNotEmpty() && element.isLinkOrKeyEmpty()) {
              isTrue = false;
              break;
            }
          }
        }
        return isTrue ? null : 'Vui lòng nhập đủ thông';
      },
    );
    validationManager.addField(
      'selected',
      (value) {
        if (value == null) {
          return 'Vui lòng chonj';
        }
        bool isTrue = false;
        for (var element in listSelected ?? []) {
          if (element.id == value.id) {
            isTrue = true;
            break;
          }
        }
        return isTrue ? null : 'Vui lòng chonj';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('email', value);
                  },
                ),
                title: 'Email',
                required: true,
                keyListenable: "email",
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('password', value);
                  },
                ),
                title: "Password",
                keyListenable: 'password',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('age', value);
                  },
                ),
                title: "Age",
                keyListenable: 'age',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('male', value);
                  },
                ),
                title: "Male",
                keyListenable: 'male',
                required: true,
              ),
              FormValidationWidget(
                listenable: validationManager,
                enable: true,
                content: TextFormField(
                  onChanged: (value) {
                    validationManager.updateField('accImaes', listImage);
                  },
                ),
                title: "accImaes",
                keyListenable: 'accImaes',
                required: true,
              ),
              FormValidationWidget(
                  listenable: validationManager,
                  enable: true,
                  content: TextFormField(
                    onChanged: (value) {
                      validationManager.updateField('selected', 1);
                    },
                  ),
                  title: "selected",
                  required: true,
                  keyListenable: 'selected'),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: validationManager,
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: () {
                      if (validationManager.validate()) {
                        _submitForm();
                      }
                    },
                    child: const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Do something when the form is submitted
  }
}
