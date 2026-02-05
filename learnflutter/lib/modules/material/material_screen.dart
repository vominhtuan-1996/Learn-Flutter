import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_textstyle.dart';
import 'package:learnflutter/component/routes/argument_screen_model.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/component/search_module/search_list_bottom_sheet.dart';

/// Lớp RouterMaterialModel định nghĩa cấu trúc dữ liệu cho một thành phần trong danh sách Material.
class RouterMaterialModel {
  RouterMaterialModel(this.title, this.router, this.description);

  final String title;
  final String description;
  final String router;
}

/// Trang MaterialScreen hiển thị danh sách tất cả các thành phần Material có sẵn trong ứng dụng.
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});
  @override
  State<MaterialScreen> createState() => MaterialScreenState();
}

class MaterialScreenState extends State<MaterialScreen>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  /// Danh sách các kết quả đã được chọn và xác nhận từ Bottom Sheet.
  List<RadioItemModel> confirmedResults = [];

  /// Dữ liệu mẫu ban đầu để hiển thị trong danh sách của Bottom Sheet.
  final List<RadioItemModel> dummyInitialData = [
    RadioItemModel(id: '1', title: 'Mục có sẵn 1'),
    RadioItemModel(id: '2', title: 'Mục có sẵn 2'),
  ];

  /// Danh sách các thành phần Material sẽ được hiển thị trên giao diện.
  List components = [
    RouterMaterialModel(
      'Badges',
      Routes.materialBadge,
      'Badges are used to convey dynamic information, such as a count or status. A badge can include text, labels, or numbers. ',
    ),
    RouterMaterialModel(
      'Bottom app bars',
      Routes.materialBottomAppbar,
      'Bottom app bars display navigation and key actions at the bottom of a screen.',
    ),
    RouterMaterialModel(
      'Bottom sheets',
      Routes.materialBottomSheet,
      'Bottom sheets are surfaces containing supplementary content, anchored to the bottom of the screen.',
    ),
    RouterMaterialModel(
      'Buttons',
      Routes.materialButton,
      'Buttons help people take actions, such as sending an email, sharing a document, or liking a comment.',
    ),
    RouterMaterialModel(
      'Cards',
      Routes.materialCard,
      'Cards are versatile containers, holding anything from images to headlines, supporting text, buttons, lists, and other components.',
    ),
    RouterMaterialModel(
      'Carousel',
      Routes.materialCarousel,
      'Carousels contains a collection of items that can be scrolled on and off the screen.',
    ),
    RouterMaterialModel(
      'Checkboxes',
      Routes.materialCheckbox,
      'Checkboxes allow users to select one or more items from a set and can be used to turn an option on or off. They’re a kind of selection control that helps users make a choice from a set of options.',
    ),
    RouterMaterialModel(
      'Chips',
      Routes.materialChip,
      'Chips help people enter information, make selections, filter content, or trigger actions.',
    ),
    RouterMaterialModel(
      'Date picker',
      Routes.materialDatePicker,
      'Date pickers let users select a date, or a range of dates.',
    ),
    RouterMaterialModel(
      'Dialogs',
      Routes.materialDialog,
      'Dialogs provide important prompts in a user flow. They can require an action, communicate information for making decisions, or help users accomplish a focused task.',
    ),
    RouterMaterialModel(
      'Dividers',
      Routes.materialDivider,
      'A divider is a thin line used to group content in lists and layouts.',
    ),
    RouterMaterialModel(
      'Floating action buttons (FAB)',
      Routes.materialFloatingButton,
      'FABs help people take primary actions. They’re used to represent the most important action on a screen.',
    ),
    RouterMaterialModel(
      'Icon buttons',
      Routes.materialIConButton,
      'Icon buttons help people take supplementary actions with a single tap.',
    ),
    RouterMaterialModel(
      'Lists',
      Routes.materialLists,
      'Lists are continuous, vertical indexes of text and images.',
    ),
    RouterMaterialModel(
      'Menus',
      Routes.materialMenu,
      'Menus display a list of choices on a temporary surface. They appear when users interact with a button, action, or other control.\n For Android the target minimum is always 48dp minimum.',
    ),
    RouterMaterialModel(
      'Navigation bars',
      Routes.datetimePickerScreen,
      'Navigation bars offer a persistent, convenient way to switch between primary destinations in an app. 3-5 destinations is the recommended range.',
    ),
    RouterMaterialModel(
      'Navigation drawer',
      Routes.materialNavigationDrawer,
      'Navigation drawers provide access to destinations in your app.',
    ),
    RouterMaterialModel(
      'Navigation rail',
      Routes.materialNavigationRail,
      'Navigation rails provide access to primary destinations in your app, particularly in tablet and desktop screens.',
    ),
    RouterMaterialModel(
      'Progress indicators',
      Routes.materialProgressIndicators,
      'Progress indicators inform users about the status of ongoing processes, such as loading an app, submitting a form, or saving updates. They communicate an app’s state and indicate available actions, such as whether users can navigate away from the current screen.',
    ),
    RouterMaterialModel(
      'Radio buttons',
      Routes.materialRadioButton,
      'Radio buttons allow users to select one option from a set. They’re a selection control that often appears when users are asked to make decisions or select a choice from options.',
    ),
    RouterMaterialModel(
      'Search',
      Routes.materialSearchBar,
      'Search allows users to enter a keyword or phrase and get relevant information. It’s an alternative to other forms of navigation.',
    ),
    RouterMaterialModel(
      'Segmented buttons: outlined',
      Routes.datetimePickerScreen,
      'Segmented buttons help people select options, switch views, and sort elements. ',
    ),
    RouterMaterialModel(
      'Side Sheets',
      Routes.materialSideSheetScreen,
      'Side sheets are surfaces containing supplementary content or actions to support tasks as part of a flow. They are typically anchored on the right edge of larger screens like tablets and desktops.',
    ),
    RouterMaterialModel(
      'Sliders',
      Routes.materialSlider,
      'Sliders allow users to make selections from a range of values.',
    ),
    RouterMaterialModel(
      'Snackbars',
      Routes.materialSnackbar,
      'Snackbars provide brief messages about app processes at the bottom of the screen.',
    ),
    RouterMaterialModel(
      'Switch',
      Routes.materialSwitch,
      'Switches toggle the state of a single item on or off.',
    ),
    RouterMaterialModel(
      'Tabs',
      Routes.materialSegmentedScreen,
      'Tabs organize and support navigation between groups of related content at the same level of hierarchy.',
    ),
    RouterMaterialModel(
      'Text fields',
      Routes.materialTextField,
      'Text fields allow users to enter text into a UI. They typically appear in forms and dialogs.',
    ),
    RouterMaterialModel(
      'Time picker',
      Routes.materialTimePicker,
      'Time pickers help users select and set a specific time.',
    ),
    RouterMaterialModel(
      'Tooltips',
      Routes.datetimePickerScreen,
      'Tooltips are informative, specific, and action-oriented text labels that provide contextual support',
    ),
    RouterMaterialModel(
      'Top app bars',
      Routes.datetimePickerScreen,
      'Top app bars display information and actions at the top of a screen, such as the page title and shortcuts to actions.',
    ),
  ];
  bool light = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Hàm mở Bottom Sheet chứa danh sách lựa chọn và tính năng tìm kiếm.
  /// Nó hỗ trợ cả hai chế độ chọn đơn (single) và chọn nhiều (multi).
  void _openSearchOptions(RadioType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchListBottomSheet(
        type: type,
        initialData: dummyInitialData.map((e) {
          // Khôi phục trạng thái đã chọn dựa trên các kết quả đã xác nhận trước đó.
          e.isSelected =
              confirmedResults.any((confirmed) => confirmed.id == e.id);
          return e;
        }).toList(),
        onConfirm: (results) {
          setState(() {
            confirmedResults = results;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: Text('Components', style: context.textTheme.headlineMedium),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần chức năng mới: Nút mở Bottom Sheet Tìm kiếm & Lựa chọn.
            Padding(
              padding: EdgeInsets.all(DeviceDimension.padding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module Search Workflow:',
                    style: context.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openSearchOptions(RadioType.single),
                          child: const Text('Mở Bottom Sheet (Single)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openSearchOptions(RadioType.multi),
                          child: const Text('Mở Bottom Sheet (Multi)'),
                        ),
                      ),
                    ],
                  ),
                  if (confirmedResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                        'Đã xác nhận: ${confirmedResults.map((e) => e.title).join(", ")}'),
                  ],
                ],
              ),
            ),
            const Divider(),
            ...List.generate(
              components.length,
              (index) {
                RouterMaterialModel model = components[index];
                return MaterialButton3(
                  backgoundColor: AppColors.white,
                  borderColor: AppColors.white,
                  borderRadius: DeviceDimension.padding,
                  shadowColor: AppColors.grey,
                  shadowOffset: Offset.zero,
                  onTap: () async {
                    Navigator.of(context).pushNamed(model.router,
                        arguments:
                            ArgumentsScreenModel(title: '', data: model));
                  },
                  suffixIcon: Icons.arrow_forward_outlined,
                  suffixColor: AppColors.black,
                  type: MaterialButtonType.commonbutton,
                  lableText: model.title,
                  textAlign: TextAlign.left,
                  labelTextStyle: context.textTheme.bodyLarge?.underlined(
                    color: context.colorScheme.error,
                    distance: 1,
                    thickness: 4,
                    style: TextDecorationStyle.solid,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
