import 'package:sdk_pms/general_import.dart';

class AlwaysBounceScrollPhysics extends BouncingScrollPhysics {
  /// Luôn bật bounce kể cả khi không cần thiết

  const AlwaysBounceScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  AlwaysBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AlwaysBounceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
}
