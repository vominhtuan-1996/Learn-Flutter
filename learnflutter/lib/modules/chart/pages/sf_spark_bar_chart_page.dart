import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class SFSparkBarChartPage extends StatefulWidget {
  const SFSparkBarChartPage({super.key});

  @override
  State<SFSparkBarChartPage> createState() => _SFSparkBarChartPageState();
}

class _SFSparkBarChartPageState extends State<SFSparkBarChartPage> {
  late TooltipBehavior _tooltipBehavior;
  List<double> getDefaultData() {
    return <double>[100, 50, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3, 1, 5, 1, 0, 1, 3, 7, 6, 4, 10, 13, 6, 7, 5, 11, 5, 3];
  }

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
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _tooltipBehavior.hide();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SfSparkBarChart(
            data: getDefaultData(),
            color: Colors.blue,
            negativePointColor: Colors.grey,
            // trackColor: Colors.grey.withOpacity(0.2),
            // axisLineVisible: true,
            axisLineColor: Colors.black,
            axisLineWidth: 1,
            firstPointColor: Colors.green,
            lastPointColor: Colors.orange,
            highPointColor: Colors.purple,
            lowPointColor: Colors.red,
            labelDisplayMode: SparkChartLabelDisplayMode.none,
          ),
        ),
      ),
    );
  }
}
