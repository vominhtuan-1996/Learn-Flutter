import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/app/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});
  @override
  State<ChartScreen> createState() => ChartScreenState();
}

class ChartScreenState extends State<ChartScreen> {
  late TooltipBehavior _tooltipBehavior;
  late List<_PieData> pieData;
  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
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
        isLoading: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SfCartesianChart(
                title: const ChartTitle(text: 'Flutter Chart'),
                legend: const Legend(isVisible: true),
                series: getDefaultData(),
                tooltipBehavior: _tooltipBehavior,
              ),
              SfCircularChart(
                title: const ChartTitle(text: 'Sales by sales person'),
                legend: const Legend(isVisible: true),
                series: <PieSeries<_PieData, String>>[
                  PieSeries<_PieData, String>(
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
              SfSparkLineChart(
                data: const <double>[1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11, 5, 3],
              ),
              SfPyramidChart(
                title: const ChartTitle(text: 'SfPyramidChart'),
                legend: const Legend(isVisible: true),
                palette: const [
                  AppColors.backButtonColor,
                  AppColors.yellowBackground,
                  AppColors.primary,
                  AppColors.red,
                  AppColors.white,
                ],
                series: PyramidSeries<_PieData, String>(
                  explode: true,
                  explodeIndex: 0,
                  dataSource: pieData,
                  xValueMapper: (_PieData data, _) => data.xData,
                  yValueMapper: (_PieData data, _) => data.yData,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ),
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
              SfSparkBarChart(
                labelDisplayMode: SparkChartLabelDisplayMode.last,
                axisLineColor: Colors.white,
                color: Colors.yellow,
                data: const <double>[1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3],
              ),
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
              SfCircularChart(
                title: const ChartTitle(text: 'Sales by sales person'),
                legend: const Legend(isVisible: true),
                series: <CircularSeries>[
                  PieSeries<_PieData, String>(
                    explode: true,
                    explodeIndex: 1,
                    dataSource: pieData,
                    xValueMapper: (_PieData data, _) => data.xData,
                    yValueMapper: (_PieData data, _) => data.yData,
                    dataLabelMapper: (_PieData data, _) => data.text,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
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
