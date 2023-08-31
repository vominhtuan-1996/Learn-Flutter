// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

part of tie_picker;

class CalendarOverlay extends StateWidget<CalendarOverlayController> {
  final DateTime? date;
  final CalendarMode mode;

  const CalendarOverlay({
    Key? key,
    required this.date,
    required this.mode,
  }) : super(key: key);

  @override
  CalendarOverlayController createState() => CalendarOverlayController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: radius8,
          topRight: radius8,
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: radius8,
              topRight: radius8,
            ),
          ),
          constraints: BoxConstraints(minHeight: context.h * .5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RxWidget<CalendarMode>(
                notifier: state.calendarMode,
                builder: (ctx, calendarMode) {
                  return GestureDetector(
                    onTap: state.onTapTitle,
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          child: RxWidget<String>(
                            notifier: state.title,
                            builder: (ctx, title) => Center(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                style: context.s1,
                              ),
                            ),
                          ),
                        ),
                        Icon(Icons.expand_more_outlined)
                      ],
                    ).paddingSymmetric(horizontal: 6.0),
                  );
                },
              ),
              RxWidget<CalendarMode>(
                notifier: state.calendarMode,
                builder: (ctx, calendarMode) => buildLayoutCalender(calendarMode),
              ),
              Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      width: 60,
                      color: Colors.orange,
                      child: Center(child: Text('Cancle')),
                    ),
                    Container(
                      height: 40,
                      width: 60,
                      color: Colors.red,
                      child: Center(child: Text('OK')),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLayoutCalender(CalendarMode calendarMode) {
  dynamic build;
  switch (calendarMode) {
    case CalendarMode.day:
      build = const DayPicker();
      break;
    case CalendarMode.month:
      build = const MonthPicker();
      break;
    case CalendarMode.year:
      build = const YearPicker();
      break;
    default:
  }
  return build;
}
