import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/modules/map/map_screen.dart';
import 'package:learnflutter/modules/material/component/material_side_sheet/material_side_sheet.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class ChartScreen extends StatefulWidget {
  ChartScreen({super.key});
  @override
  State<ChartScreen> createState() => ChartScreenState();
}

class ChartScreenState extends State<ChartScreen> {
  late TooltipBehavior _tooltipBehavior;
  late List<_PieData> pieData;
  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        return Container(height: 200, width: 200, child: Text('hihi1231231231231'));
      },
      color: Colors.white,
      duration: 30000000,
    );
    pieData = [
      _PieData('test', 2000),
      _PieData('test1', 2001),
      _PieData('test2', 2002),
      _PieData('test3', 2003),
      _PieData('test4', 2004),
      _PieData('test5', 2005),
      _PieData('test6', 2006),
      _PieData('test7', 2007),
      _PieData('test8', 2008),
    ];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        appBar: AppBar(
          title: Text(
            "Flutter chart",
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showModalSideSheet(
                    context,
                    body: Container(
                      width: context.mediaQuery.size.width / 2,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    direction: DirectionSideSheet.right,
                    alignment: Alignment.bottomRight,
                    // Required
                    header: '',
                    barrierDismissible: true,
                    addBackIconButton: false,
                    addCloseIconButton: true,
                    addActions: true,
                    addDivider: true,
                    confirmActionTitle: 'Update',
                    cancelActionTitle: 'Cancel',
                    confirmActionOnPressed: () {
                      Navigator.pop(context);
                      debugPrint('on confirm action');
                    },
                    cancelActionOnPressed: () {
                      Navigator.pop(context);
                      debugPrint('on cancel event');
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                    closeButtonTooltip: 'Close',
                    backButtonTooltip: 'Back',
                    onDismiss: () {
                      debugPrint('on dismiss event');
                    },
                    onClose: () {
                      Navigator.pop(context);
                      debugPrint('on close event');
                    },
                    footerBuilder: (context) {
                      return Container();
                    },
                  );
                },
                icon: Icon(Icons.filter_list_alt))
          ],
        ),
        isLoading: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.sfCartesianChartPage,
                  );
                },
                child: Text(
                  'SfCartesianChart',
                ),
              ).padding(
                EdgeInsets.symmetric(
                  vertical: DeviceDimension.padding / 2,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.sfSparkBarChartPage,
                  );
                },
                child: Text(
                  'sfSparkBarChartPage',
                ),
              ).padding(
                EdgeInsets.symmetric(
                  vertical: DeviceDimension.padding / 2,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.sfCircularChartPage,
                  );
                },
                child: Text(
                  'SfCircularChart',
                ),
              ).padding(
                EdgeInsets.symmetric(
                  vertical: DeviceDimension.padding / 2,
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.sfPyramidChartPage,
                  );
                },
                child: Text(
                  'SfPyramidChart',
                ),
              ).padding(
                EdgeInsets.symmetric(
                  vertical: DeviceDimension.padding / 2,
                ),
              ),

              SfSparkLineChart(
                data: [1, 3, 2, 5, 4],
                color: Colors.blue,
                width: 2,
                marker: SparkChartMarker(
                  displayMode: SparkChartMarkerDisplayMode.all,
                  color: Colors.red,
                  borderWidth: 2,
                  size: 20,
                ),
                trackball: SparkChartTrackball(
                  activationMode: SparkChartActivationMode.tap,
                ),
                highPointColor: Colors.green,
                lowPointColor: Colors.red,
                firstPointColor: Colors.orange,
                lastPointColor: Colors.purple,
              ),
              SfPyramidChart(
                title: ChartTitle(text: 'Cơ cấu doanh thu'),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: PyramidSeries<_PieData, String>(
                  dataSource: pieData,
                  xValueMapper: (_PieData data, _) => data.xData,
                  yValueMapper: (_PieData data, _) => data.yData,
                  gapRatio: 0.05,
                  explode: true,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ),

              // SfPyramidChart(
              //   title: const ChartTitle(text: 'SfPyramidChart'),
              //   legend: const Legend(isVisible: true),
              //   palette: const [
              //     AppColors.backButtonColor,
              //     AppColors.yellowBackground,
              //     AppColors.primary,
              //     AppColors.red,
              //     AppColors.white,
              //   ],
              //   series: PyramidSeries<_PieData, String>(
              //     explode: true,
              //     explodeIndex: 0,
              //     dataSource: pieData,
              //     xValueMapper: (_PieData data, _) => data.xData,
              //     yValueMapper: (_PieData data, _) => data.yData,
              //     dataLabelSettings: const DataLabelSettings(isVisible: true),
              //   ),
              // ),
              SfFunnelChart(
                title: const ChartTitle(text: 'SfFunnelChart'),
                legend: const Legend(isVisible: true),
                series: FunnelSeries<_PieData, String>(
                  explode: true,
                  explodeIndex: 0,
                  dataSource: pieData,
                  xValueMapper: (_PieData data, _) => data.xData,
                  yValueMapper: (_PieData data, _) => data.yData,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ),
              SfSparkAreaChart(
                axisLineColor: Colors.red,
                color: Colors.red,
                data: const <double>[
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                  1,
                  5,
                  -6,
                  0,
                  1,
                  -2,
                  7,
                  -7,
                  -4,
                  -10,
                  13,
                  -6,
                  7,
                  5,
                  11,
                  5,
                  3,
                ],
              ),
              SfSparkAreaChart(
                data: const <double>[1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11, 5, 3],
              ),
              // SfSparkBarChart(
              //   labelDisplayMode: SparkChartLabelDisplayMode.last,
              //   axisLineColor: Colors.white,
              //   color: Colors.yellow,
              //   data: const <double>[1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3],
              //   axisLineDashArray: [2, 2],
              //   highPointColor: Colors.red,
              //   lowPointColor: Colors.blue,
              // ),
              SfSparkWinLossChart(
                data: const <double>[1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11, 5, 3],
              ),
              SfCircularChart(
                title: const ChartTitle(text: 'Sales by sales person'),
                legend: const Legend(isVisible: true),
                series: <CircularSeries<_PieData, String>>[
                  DoughnutSeries<_PieData, String>(
                    explode: true,
                    explodeIndex: 0,
                    dataSource: pieData,
                    xValueMapper: (_PieData data, _) => data.xData,
                    yValueMapper: (_PieData data, _) => data.yData,
                    dataLabelMapper: (_PieData data, _) => data.text,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _tooltipBehavior.hide();
                },
                child: SfCircularChart(
                  title: const ChartTitle(text: 'Sales by sales person'),
                  legend: const Legend(isVisible: true, alignment: ChartAlignment.near),
                  series: <CircularSeries>[
                    PieSeries<_PieData, String>(
                      explode: true,
                      explodeIndex: 1,
                      dataSource: pieData,
                      xValueMapper: (_PieData data, _) => data.xData,
                      yValueMapper: (_PieData data, _) => data.yData,
                      dataLabelMapper: (_PieData data, _) => data.text,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      enableTooltip: true,
                    ),
                  ],
                  tooltipBehavior: _tooltipBehavior,
                ),
              ),
            ],
          ),
        ));
  }
}

class _PieData {
  _PieData(this.xData, this.yData);
  final String xData;
  final num yData;
  String? text;
}

List<LineSeries<SalesData, num>> getDefaultData() {
  const bool isDataLabelVisible = true, isMarkerVisible = true, isTooltipVisible = true;
  double? lineWidth, markerWidth, markerHeight;
  final List<SalesData> chartData = <SalesData>[
    SalesData(DateTime(2005, 0, 1), 'India', 1.5, 21, 28, 680, 760),
    SalesData(DateTime(2006, 0, 1), 'China', 2.2, 24, 44, 550, 880),
    SalesData(DateTime(2007, 0, 1), 'USA', 3.32, 36, 48, 440, 788),
    SalesData(DateTime(2008, 0, 1), 'Japan', 4.56, 38, 50, 350, 560),
    SalesData(DateTime(2009, 0, 1), 'Russia', 5.87, 54, 66, 444, 566),
    SalesData(DateTime(2010, 0, 1), 'France', 6.8, 57, 78, 780, 650),
    SalesData(DateTime(2011, 0, 1), 'Germany', 8.5, 70, 84, 450, 800)
  ];
  return <LineSeries<SalesData, num>>[
    LineSeries<SalesData, num>(
        enableTooltip: true,
        dataSource: chartData,
        xValueMapper: (SalesData sales, _) => sales.y,
        yValueMapper: (SalesData sales, _) => sales.y4,
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(isVisible: isMarkerVisible, height: markerWidth ?? 4, width: markerHeight ?? 4, shape: DataMarkerType.circle, borderWidth: 3, borderColor: Colors.red),
        dataLabelSettings: const DataLabelSettings(isVisible: isDataLabelVisible, labelAlignment: ChartDataLabelAlignment.auto)),
    LineSeries<SalesData, num>(
        enableTooltip: isTooltipVisible,
        dataSource: chartData,
        width: lineWidth ?? 2,
        xValueMapper: (SalesData sales, _) => sales.y,
        yValueMapper: (SalesData sales, _) => sales.y3,
        markerSettings: MarkerSettings(isVisible: isMarkerVisible, height: markerWidth ?? 4, width: markerHeight ?? 4, shape: DataMarkerType.circle, borderWidth: 3, borderColor: Colors.black),
        dataLabelSettings: const DataLabelSettings(isVisible: isDataLabelVisible, labelAlignment: ChartDataLabelAlignment.auto))
  ];
}
