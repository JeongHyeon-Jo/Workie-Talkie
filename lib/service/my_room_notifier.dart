import 'dart:convert';

import 'package:alarm_app/main.dart';
import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/service/local_notification_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyRoomNotifier extends ChangeNotifier {
  final LocalNotificationManager _notificationManager = LocalNotificationManager();

  Future<void> scheduleRoomNotification(RoomModel room) async {
    await _notificationManager.scheduleNotification(
      room.id, //방 id로 알림 id
      '${room.roomName} 채팅이 시작되었어요',
      '채팅에 참여해보세요',
      room.startTime,
    );

    print('알림 정보 ${room.roomName}, ${room.startTime}');
  }

  Future<void> cancelRoomNotification(int roomId) async {
    await _notificationManager.cancelNotification(roomId);
  }
}

