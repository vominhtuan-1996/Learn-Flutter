import 'package:sdk_pms/general_import.dart';

class ReversedScrollPhysics extends ScrollPhysics {
  ///  Cuộn ngược lại so với direction gốc
  const ReversedScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  ReversedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ReversedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return -super.applyPhysicsToUserOffset(position, offset);
  }
}
