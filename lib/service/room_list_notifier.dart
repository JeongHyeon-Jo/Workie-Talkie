import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/main.dart';

class RoomNotifier extends ChangeNotifier {
  List<RoomModel> _rooms = [];

  List<RoomModel> get rooms => _rooms; // 방 목록 Getter

  // 서버에서 방 목록 불러오기
  Future<void> loadRoomsFromServer({
    String? topicId,
    int? limit,
    int? cursorId,
  }) async {
    final body = {
      'topicId': topicId,
      'limit': limit ?? 5, // limit을 설정 (기본값 5)
      'cursorId': cursorId, // 커서 ID 추가
    };

  final response = await http.post(
    Uri.parse('$serverUrl/room/list'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

    print('서버 응답 상태코드: ${response.statusCode}');
    print('서버 응답 본문: ${response.body}');
    print('전송된 데이터: ${jsonEncode(body)}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data['rooms'] is List) {
        _rooms = (data['rooms'] as List)
            .map<RoomModel>((json) => RoomModel.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Invalid data format: ${data.runtimeType}');
      }
    } else {
      throw Exception(
          'Response status: ${response.statusCode}, Response body: ${response.body}, Request URL: $serverUrl/room/list');
    }
  }

  // 방 추가하기
  void addRoom(RoomModel room) {
    _rooms.add(room);
    notifyListeners(); // 방 추가 후 화면 업데이트
  }

  // 방 삭제하기
  void removeRoom(RoomModel room) {
    _rooms.remove(room);
    notifyListeners(); // 방 삭제 후 화면 업데이트
  }

  // 특정 ID로 방 삭제하기
  void removeRoomById(String roomId) {
    _rooms.removeWhere((room) => room.id == roomId);
    notifyListeners();
  }

  // 방 목록 비우기
  void clearRooms() {
    _rooms.clear();
    notifyListeners(); // 목록 비운 후 화면 업데이트
  }
}
