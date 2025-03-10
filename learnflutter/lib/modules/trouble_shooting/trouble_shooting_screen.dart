import 'package:flutter/material.dart';
import 'package:learnflutter/app/app_colors.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/bottom_sheet/page/bottom_sheet.dart';
import 'package:learnflutter/component/scroll_physics/nobounce_scroll_physics.dart';
import 'package:learnflutter/component/search_bar/page/search_bar_builder.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

class TroubleShootingScreen extends StatefulWidget {
  const TroubleShootingScreen({super.key});

  @override
  State<TroubleShootingScreen> createState() => _TroubleShootingScreenState();
}

class _TroubleShootingScreenState extends State<TroubleShootingScreen> {
  double sizeIcon = DeviceDimension.defaultSize(50);
  final PageController _pageController = PageController();
  int indexPage = 0;
  final TextEditingController colorController = TextEditingController();
  SearchController searchControler = SearchController();

  bool visibleSearch = true;
  bool visibleInfrasType = false;

  List infrasTypes = ['PON', 'Ngầm', 'ADSL', 'FTTH'];
  List fillters = ['Hạ tầng', 'Khách hàng', 'Tuyến trục'];
  String? selectedDropdowmMenu = 'Hạ tầng';

  int radius = 100;

  Future<List<dynamic>> fetchSuggestions(String query) async {
    // Thực hiện yêu cầu đến API tìm kiếm sản phẩm
    // For demonstration, returning a dummy list
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return List<String>.generate(infrasTypes.length, (index) => '${infrasTypes[index]} for $query');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BaseLoading(
          appBar: AppBar(
            title: const Text('Trouble Shooting'),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                    (index) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                indexPage = index;
                                _pageController.animateToPage(indexPage, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                              });
                            },
                            child: Container(
                              width: sizeIcon,
                              height: sizeIcon,
                              margin: EdgeInsets.all(DeviceDimension.padding / 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(sizeIcon / 2),
                                color: index == indexPage ? Colors.deepOrangeAccent : Colors.grey,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (index != 3)
                            Container(
                              width: sizeIcon,
                              height: 1,
                              color: Colors.deepOrangeAccent,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: NoBounceScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs())).clamp(0.0, 1.0);
                        }
                        return Container(
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                          child: Transform(
                            transform: Matrix4.identity()
                              ..scale(value)
                              ..rotateY(value * 0.2),
                            child: Container(
                              color: Colors.primaries[index % Colors.primaries.length],
                              child: Center(
                                child: Text(
                                  'Page ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  onPageChanged: (value) {
                    setState(() {
                      indexPage = value;
                    });
                  },
                  itemCount: 4,
                ),
              )
            ],
          ),
        ),
        Positioned(
          left: DeviceDimension.padding / 2,
          top: DeviceDimension.padding * 6,
          right: DeviceDimension.padding / 2,
          // height: 220,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(DeviceDimension.padding / 2),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 160,
                          child: DropdownMenu<String>(
                            selectedTrailingIcon: Icon(
                              Icons.expand_less_rounded,
                              color: AppColors.primary,
                            ),
                            trailingIcon: Icon(
                              Icons.expand_more_rounded,
                              color: AppColors.primary,
                            ),
                            menuStyle: MenuStyle(
                                elevation: WidgetStateProperty.resolveWith(
                                  (states) => 0,
                                ),
                                padding: WidgetStateProperty.resolveWith(
                                  (states) => EdgeInsets.zero,
                                ),
                                backgroundColor: WidgetStateColor.resolveWith(
                                  (states) {
                                    return Colors.white;
                                  },
                                ),
                                shape: WidgetStateProperty.resolveWith(
                                  (states) {
                                    return RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: AppColors.grey,
                                        width: 0.3,
                                      ),
                                    );
                                  },
                                )),
                            initialSelection: selectedDropdowmMenu,
                            controller: colorController,
                            inputDecorationTheme: InputDecorationTheme(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                            ),
                            // requestFocusOnTap is enabled/disabled by platforms when it is null.
                            // On mobile platforms, this is false by default. Setting this to true will
                            // trigger focus request on the text field and virtual keyboard will appear
                            // afterward. On desktop platforms however, this defaults to true.
                            requestFocusOnTap: false,
                            // label: const Text('Color'),
                            onSelected: (String? value) {
                              setState(() {
                                selectedDropdowmMenu = value;
                              });
                            },

                            dropdownMenuEntries: fillters.map<DropdownMenuEntry<String>>(
                              (dynamic value) {
                                // Update the parameter type to dynamic
                                return DropdownMenuEntry<String>(
                                  value: value,
                                  label: value,
                                  enabled: true,
                                  trailingIcon: value == selectedDropdowmMenu
                                      ? Icon(
                                          Icons.check,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: VerticalDivider(
                            width: 10,
                            thickness: 1.2,
                            indent: DeviceDimension.padding / 4,
                            endIndent: DeviceDimension.padding / 4,
                            color: Colors.grey,
                          ),
                        ),
                        MetarialRadioButton.single(
                          enable: true,
                          data: [
                            RadioItemModel(
                              title: "Tên hạ tầng",
                              id: "1",
                              isSelected: true,
                            ),
                            RadioItemModel(
                              title: "Bán kính",
                              id: "2",
                              isSelected: false,
                            ),
                          ],
                          onChangeValue: (value) {
                            if (value?.id == "1") {
                              setState(() {
                                visibleInfrasType = false;
                                visibleSearch = true;
                              });
                            } else {
                              setState(() {
                                visibleInfrasType = true;
                                visibleSearch = false;
                              });
                            }
                          },
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Visibility(
                    visible: visibleInfrasType,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            infrasTypes.length,
                            (index) {
                              return TextButton(
                                  onPressed: () {
                                    print('Click');
                                  },
                                  child: Text(
                                    infrasTypes[index],
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ));
                            },
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AbsorbPointer(
                              absorbing: radius == 100,
                              child: IconButton(
                                  onPressed: () {
                                    if (radius == 100) {
                                      return;
                                    }
                                    setState(() {
                                      radius -= 100;
                                      // radius - 100
                                    });
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    color: radius != 100 ? AppColors.primary : AppColors.grey,
                                  )),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(radius.toString())),
                            AbsorbPointer(
                              absorbing: radius == 1000,
                              child: IconButton(
                                  onPressed: () {
                                    if (radius == 1000) {
                                      return;
                                    }
                                    setState(() {
                                      radius += 100;
                                      // = radius + 100;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: radius != 1000 ? AppColors.primary : AppColors.grey,
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    maintainState: true,
                    visible: visibleSearch,
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      direction: Axis.horizontal,
                      children: [
                        SearchBarBuilder(
                          viewConstraints: BoxConstraints(
                            maxHeight: 300,
                            maxWidth: context.mediaQuery.size.width - 100,
                          ),
                          searchController: searchControler,
                          childBuilder: (context, data) {
                            return ListTile(
                              title: Text(data),
                            );
                          },
                          onTapChildBuilder: (value) {
                            print(value);
                          },
                          getSuggestions: fetchSuggestions,
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                        SizedBox(
                          width: DeviceDimension.padding / 4,
                        ),
                        IconButton(
                          color: Colors.red,
                          onPressed: () {},
                          icon: Icon(
                            Icons.search,
                            size: 34,
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) {
                                return AppColors.yellowBackground;
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              DialogUtils.showFullDialog(
                  context: context,
                  contentWidget: Container(
                    height: context.mediaQuery.size.height * 0.8,
                    width: context.mediaQuery.size.width - DeviceDimension.padding,
                    // color: Colors.red,
                  ));
            },
            child: Container(
              height: 280,
              color: Colors.blue,
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              );
                            },
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) {
                              return AppColors.lightGrey;
                            },
                          ),
                        ),
                        onPressed: () {},
                        child: SizedBox(
                          height: DeviceDimension.defaultSize(60),
                          width: context.mediaQuery.size.width / 2 - DeviceDimension.padding * 2,
                          child: Center(
                            child: Text(
                              'Degree',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              );
                            },
                          ),
                          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.red.withOpacity(0.5); // Feedback color when pressed
                              }
                              return null; // Default color
                            },
                          ),
                          enableFeedback: true,
                        ),
                        onPressed: () {},
                        child: SizedBox(
                          height: DeviceDimension.defaultSize(60),
                          width: context.mediaQuery.size.width / 2 - DeviceDimension.padding * 2,
                          child: Center(
                            child: Text('Agree',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
