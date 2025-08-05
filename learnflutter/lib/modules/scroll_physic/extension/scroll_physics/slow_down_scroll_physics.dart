import 'package:sdk_pms/general_import.dart';

class SlowDownScrollPhysics extends ScrollPhysics {
  final double factor;

  /// Làm cho scroll chậm hơn (giảm tốc độ khi cuộn)
  const SlowDownScrollPhysics({this.factor = 3.0, ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowDownScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowDownScrollPhysics(factor: factor, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset / factor);
  }
}
