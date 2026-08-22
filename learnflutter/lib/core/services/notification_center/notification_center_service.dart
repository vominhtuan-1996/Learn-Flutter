import 'package:notification_center/notification_center.dart';

///[SubscribeObserver] tại [initState]
/// example
/// NotificationCenterService.subscribeCenterNotification (
///     nameNotification: nameNotification,
///      callback: Function callback,
//   );

///[UnSubscribeObserver] tại [dispose]
//example :
/// NotificationCenterService.unsubscribeCenterNotification(
///  nameNotification: nameNotification,
///   );

/// [Postnotification] somewhere in application
/// example :
/// NotificationCenterService.pushCenterNotification(
///   nameNotification: nameNotification, data : dynamic (có hoặc không)
///    );
class NotificationCenterService {
  NotificationCenterService._();

  static void postCenterNotification({required String nameNotification, dynamic data}) {
    NotificationCenter().notify(nameNotification, data: data);
  }

  static void subscribeCenterNotification({required String nameNotification, required Function(dynamic) callback}) {
    // Wrap để handle cả trường hợp package gọi callback() không có arg (data=null).
    NotificationCenter().subscribe(nameNotification, ([dynamic data]) => callback(data));
  }

  static void unsubscribeCenterNotification({required String nameNotification}) {
    NotificationCenter().unsubscribe(nameNotification);
  }

  static void subscribeCenterNotificationPassingData({required String nameNotification, required Function callback}) {
    NotificationCenter().subscribe(nameNotification, (dynamic value) {
      print(value);
      callback(value);
    });
  }
}

///define name notification center
class ConstantsNotificationCenterName {
  static const String getCheckListComponent = "getCheckListComponent";
}
