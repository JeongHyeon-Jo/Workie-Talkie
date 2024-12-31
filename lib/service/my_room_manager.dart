import 'package:alarm_app/service/my_room_notifier.dart';
import 'package:alarm_app/model/room_model.dart';

class MyRoomManager {
  final MyRoomNotifier _roomNotifier = MyRoomNotifier();

  Future<void> manageRoom(RoomModel room) async {
    await _roomNotifier.scheduleRoomNotification(room);
  }

  Future<void> cancelRoomNotification(int roomId) async {
    await _roomNotifier.cancelRoomNotification(roomId);
  }
}
