import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/chart/model/pro_gress_data_model.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class SFPyramidChartPage extends StatefulWidget {
  const SFPyramidChartPage({super.key});

  @override
  State<SFPyramidChartPage> createState() => _SFPyramidChartPageState();
}

class _SFPyramidChartPageState extends State<SFPyramidChartPage> {
  late TooltipBehavior _tooltipBehavior;
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
            Text((data as SalesData).date.toString()).paddingOnly(bottom: DeviceDimension.padding / 2),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SfPyramidChart(
                  title: ChartTitle(text: 'Company Sales Funnel'),
                  legend: Legend(isVisible: true),
                  series: PyramidSeries<SalesData, num>(
                      dataSource: chartData,
                      xValueMapper: (SalesData data, _) => data.y1,
                      yValueMapper: (SalesData data, _) => data.y2,
                      textFieldMapper: (SalesData data, _) => data.conntry.toString(),
                      gapRatio: 0.05,
                      borderColor: Colors.white,
                      borderWidth: 2,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      // explodeIndex: 0,
                      explode: true),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _tooltipBehavior.hide();
              },
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SfFunnelChart(
                    title: ChartTitle(text: 'Funnel Chart Example'),
                    legend: Legend(isVisible: true),
                    series: FunnelSeries<SalesData, num>(
                      dataSource: chartData,
                      xValueMapper: (SalesData data, _) => data.y1,
                      yValueMapper: (SalesData data, _) => data.y2,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      explode: true, // Tùy chọn làm nổi bật một phần tử
                      gapRatio: 0.03, // Khoảng cách giữa các phần
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
