import 'package:sdk_pms/general_import.dart';

class NoScrollPhysics extends ScrollPhysics {
  ///  Vô hiệu hóa scroll hoàn toàn

  const NoScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  NoScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) => 0.0;

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => false;
}
