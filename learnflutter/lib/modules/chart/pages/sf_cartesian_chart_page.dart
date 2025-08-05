import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/chart/model/chart_data.dart';
import 'package:learnflutter/modules/chart/model/sales_data_model.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SFCartesianChartPage extends StatefulWidget {
  const SFCartesianChartPage({super.key});

  @override
  State<SFCartesianChartPage> createState() => _SFCartesianChartPageState();
}

class _SFCartesianChartPageState extends State<SFCartesianChartPage> {
  late TooltipBehavior _tooltipBehavior;
  List<LineSeries<SalesData, num>> getDefaultData() {
    const bool isDataLabelVisible = true, isMarkerVisible = true, isTooltipVisible = true;
    double? lineWidth, markerWidth, markerHeight;
    markerWidth = 6;
    final List<SalesData> chartData = <SalesData>[
      SalesData(DateTime(2005, 0, 1), 'India', 2005, 21, 28, 680, 760),
      SalesData(DateTime(2006, 0, 1), 'China', 2006, 24, 44, 550, 880),
      SalesData(DateTime(2007, 0, 1), 'USA', 2007, 36, 48, 440, 788),
      SalesData(DateTime(2008, 0, 1), 'Japan', 2008, 38, 50, 350, 560),
      SalesData(DateTime(2009, 0, 1), 'Russia', 2009, 54, 66, 444, 566),
      SalesData(DateTime(2010, 0, 1), 'France', 2010, 57, 78, 780, 650),
      SalesData(DateTime(2011, 0, 1), 'Germany', 2011, 70, 84, 450, 800)
    ];
    return <LineSeries<SalesData, num>>[
      LineSeries<SalesData, num>(
        enableTooltip: true,
        dataSource: chartData,
        xValueMapper: (SalesData sales, _) => sales.y,
        yValueMapper: (SalesData sales, _) => sales.y1,
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
          isVisible: isMarkerVisible,
          height: markerWidth ?? 6,
          width: markerHeight ?? 6,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          borderColor: const Color.fromARGB(255, 200, 67, 58),
        ),
        dataLabelSettings: const DataLabelSettings(
          isVisible: isDataLabelVisible,
          labelAlignment: ChartDataLabelAlignment.auto,
        ),
      ),
      LineSeries<SalesData, num>(
          enableTooltip: isTooltipVisible,
          dataSource: chartData,
          width: lineWidth ?? 2,
          xValueMapper: (SalesData sales, _) => sales.y,
          yValueMapper: (SalesData sales, _) => sales.y2,
          markerSettings: MarkerSettings(isVisible: isMarkerVisible, height: markerWidth ?? 6, width: markerHeight ?? 6, shape: DataMarkerType.circle, borderWidth: 3, borderColor: Colors.black),
          dataLabelSettings: const DataLabelSettings(isVisible: isDataLabelVisible, labelAlignment: ChartDataLabelAlignment.auto)),
      LineSeries<SalesData, num>(
          enableTooltip: true,
          dataSource: chartData,
          xValueMapper: (SalesData sales, _) => sales.y,
          yValueMapper: (SalesData sales, _) => sales.y3,
          width: lineWidth ?? 2,
          markerSettings: MarkerSettings(isVisible: isMarkerVisible, height: markerWidth ?? 6, width: markerHeight ?? 6, shape: DataMarkerType.circle, borderWidth: 3, borderColor: Colors.red),
          dataLabelSettings: const DataLabelSettings(isVisible: isDataLabelVisible, labelAlignment: ChartDataLabelAlignment.auto)),
      LineSeries<SalesData, num>(
          enableTooltip: isTooltipVisible,
          dataSource: chartData,
          width: lineWidth ?? 2,
          xValueMapper: (SalesData sales, _) => sales.y,
          yValueMapper: (SalesData sales, _) => sales.y4,
          markerSettings: MarkerSettings(isVisible: isMarkerVisible, height: markerWidth ?? 6, width: markerHeight ?? 6, shape: DataMarkerType.circle, borderWidth: 3, borderColor: Colors.black),
          dataLabelSettings: const DataLabelSettings(isVisible: isDataLabelVisible, labelAlignment: ChartDataLabelAlignment.auto)),
    ];
  }

  final List<ChartData> chartDataFastLineSeries = List.generate(
    1000, // Số lượng lớn dữ liệu
    (index) => ChartData(index.toDouble(), (index % 100).toDouble()),
  );

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
              child: SfCartesianChart(
                onLegendTapped: (legendTapArgs) {},
                primaryXAxis: CategoryAxis(
                  isVisible: true,
                ),
                legend: Legend(
                  isVisible: true,
                  legendItemBuilder: (legendText, series, point, seriesIndex) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: series?.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${point.x}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
                series: getDefaultData(),
                tooltipBehavior: _tooltipBehavior,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _tooltipBehavior.hide();
              },
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(),
                primaryYAxis: NumericAxis(),
                title: ChartTitle(text: 'Fast Line Chart Example'),
                series: [
                  FastLineSeries<ChartData, double>(
                    dataSource: chartDataFastLineSeries,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.blue,
                    width: 2,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



// @override
//     Widget build(BuildContext context) {
//         final List<SalesData> chartData = [
//             SalesData(2010, 35),
//             SalesData(2011, 28),
//             SalesData(2012, 34),
//             SalesData(2013, 32),
//             SalesData(2014, 40)
//         ];
//         return Scaffold(
//             body: Center(
//                 child: Container(
//                     child: SfCartesianChart(
//                         primaryXAxis: DateTimeAxis(),
//                         series: <CartesianSeries>[
//                             // Renders line chart
//                             LineSeries<SalesData, DateTime>(
//                                 dataSource: chartData,
//                                 xValueMapper: (SalesData sales, _) => sales.year,
//                                 yValueMapper: (SalesData sales, _) => sales.sales
//                             )
//                         ]
//                     )
//                 )
//             )
//         );
//     }
//  
//     class SalesData {
//         SalesData(this.year, this.sales);
//         final DateTime year;
//         final double sales;
//     }