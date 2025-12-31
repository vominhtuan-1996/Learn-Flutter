import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/chart/model/pro_gress_data_model.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SFCircularChartPage extends StatefulWidget {
  const SFCircularChartPage({super.key});

  @override
  State<SFCircularChartPage> createState() => _SFCircularChartPageState();
}

class _SFCircularChartPageState extends State<SFCircularChartPage> {
  late TooltipBehavior _tooltipBehavior;
  late TooltipBehavior _tooltipProgrsssBehavior;
  final List<SalesData> chartData = <SalesData>[
    SalesData(DateTime(2005, 0, 1), 'India', 2005, 21, 28, 680, 760),
    SalesData(DateTime(2006, 0, 1), 'China', 2006, 24, 44, 550, 880),
    SalesData(DateTime(2007, 0, 1), 'USA', 2007, 36, 48, 440, 788),
    SalesData(DateTime(2008, 0, 1), 'Japan', 2008, 38, 50, 350, 560),
    SalesData(DateTime(2009, 0, 1), 'Russia', 2009, 54, 66, 444, 566),
    SalesData(DateTime(2010, 0, 1), 'France', 2010, 57, 78, 780, 650),
    SalesData(DateTime(2011, 0, 1), 'Germany', 2011, 70, 84, 450, 800)
  ];

  final List<ProgressData> chartProgressData = [
    ProgressData('Công việc A', 75),
    ProgressData('Công việc B', 50),
    ProgressData('Công việc C', 90),
    ProgressData('Công việc D', 10),
    ProgressData('Công việc E', 40),
    ProgressData('Công việc F', 20),
    ProgressData('Công việc G', 30),
  ];

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((data as SalesData).date.toString())
                .paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).conntry.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).y.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
            Text(data.y1.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).y2.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).y3.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).y4.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
          ],
        );
      },
      color: Colors.white,
      duration: 30000000,
    );
    _tooltipProgrsssBehavior = TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((data as ProgressData).task.toString())
                .paddingOnly(bottom: DeviceDimension.padding / 2),
            Text((data).percent.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
          ],
        );
      },
      color: Colors.white,
      duration: 30000000,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _tooltipBehavior.hide();
              },
              child: SfCircularChart(
                title: ChartTitle(text: 'Doanh số bán hàng'),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipBehavior,
                series: <CircularSeries>[
                  PieSeries<SalesData, num>(
                      explode: true,
                      explodeIndex: 0,
                      dataSource: chartData,
                      xValueMapper: (SalesData data, _) => data.y1,
                      yValueMapper: (SalesData data, _) => data.y2,
                      // dataLabelMapper: (SalesData data, _) => data.y.toString(),
                      dataLabelSettings: const DataLabelSettings(isVisible: true)),
                  // PieSeries<SalesData, num>(
                  //   dataSource: chartData,
                  //   xValueMapper: (SalesData data, _) => data.y1,
                  //   yValueMapper: (SalesData data, _) => data.y2,
                  //   dataLabelSettings: DataLabelSettings(isVisible: true),
                  // )
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _tooltipBehavior.hide();
              },
              child: SfCircularChart(
                title: ChartTitle(text: 'Doanh số bán hàng 2'),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipBehavior,
                series: <CircularSeries>[
                  DoughnutSeries<SalesData, num>(
                      explode: true,
                      explodeIndex: 0,
                      dataSource: chartData,
                      xValueMapper: (SalesData data, _) => data.y1,
                      yValueMapper: (SalesData data, _) => data.y2,
                      // dataLabelMapper: (SalesData data, _) => data.y.toString(),
                      dataLabelSettings: const DataLabelSettings(isVisible: true)),
                  // PieSeries<SalesData, num>(
                  //   dataSource: chartData,
                  //   xValueMapper: (SalesData data, _) => data.y1,
                  //   yValueMapper: (SalesData data, _) => data.y2,
                  //   dataLabelSettings: DataLabelSettings(isVisible: true),
                  // )
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _tooltipProgrsssBehavior.hide();
              },
              child: SfCircularChart(
                title: ChartTitle(text: 'Doanh số bán hàng 3'),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipProgrsssBehavior,
                series: <CircularSeries>[
                  RadialBarSeries<ProgressData, String>(
                    dataSource: chartProgressData,
                    xValueMapper: (ProgressData data, _) => data.task,
                    yValueMapper: (ProgressData data, _) => data.percent,
                    maximumValue: 100,
                    radius: '90%',
                    innerRadius: '30%',
                    gap: '10%',
                    cornerStyle: CornerStyle.bothCurve,
                    trackColor: Colors.grey.withOpacity(0.2),
                    // dataLabelSettings: DataLabelSettings(isVisible: true),
                    animationDuration: 300,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
