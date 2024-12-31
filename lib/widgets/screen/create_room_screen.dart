import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_app/service/device_info_manager.dart';
import 'package:alarm_app/service/topic_manager.dart';
import 'package:alarm_app/widgets/screen/topic_filter_screen.dart';
import 'package:alarm_app/model/topic_model.dart';
import 'package:alarm_app/main.dart';
import 'package:alarm_app/service/my_room_manager.dart';
import 'package:alarm_app/model/room_model.dart';


class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  String? selectedTopicName;
  int? selectedTopicId;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String roomName = '';
  bool isLoading = false;

  Future<void> _saveRoomToDatabase() async {
    setState(() {
      isLoading = true;  // 로딩 시작
    });

    try {
      final DateTime startTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final DateTime endTime = startTime.add(const Duration(hours: 1));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 ID를 찾을 수 없습니다. 다시 로그인 해주세요.')),
        );
        setState(() {
          isLoading = false;
        });
        return; // 방 생성 중단
      }

      // 방 생성 서버 요청
      final response = await _createRoomOnServer(
        name: roomName,
        startTime: startTime.toIso8601String(),
        endTime: endTime.toIso8601String(),
        topicId: selectedTopicId ?? 1,
        playerId: userId,
      );

      if (response) {
        final newRoom = RoomModel(
          id: (DateTime.now().millisecondsSinceEpoch % 2147483647),
          roomName: roomName,
          startTime: startTime,
          endTime: endTime,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          playerId: userId,
          topicId: (selectedTopicId ?? 1),
        );

        //방 생성 후 MyRoomManager를 통해 알림 예약
        final MyRoomManager myRoomManager = MyRoomManager();
        await myRoomManager.manageRoom(newRoom);

        Navigator.pop(context, {
          'id': newRoom.id,
          'roomName': newRoom.roomName,
          'startTime': newRoom.startTime,
          'endTime': newRoom.endTime,
          'createdAt': newRoom.createdAt,
          'updatedAt': newRoom.updatedAt,
          'playerId': newRoom.playerId,
          'topicId': newRoom.topicId,
        });
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('방 생성에 실패했습니다. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;  // 로딩 종료
      });
    }
  }

  Future<bool> _createRoomOnServer({
    required String name,
    required String startTime,
    required String endTime,
    required int topicId,
    required int playerId,
  }) async {
    final url = Uri.parse('$serverUrl/room/create');

    final body = jsonEncode({
      'roomName': name,
      'startTime': startTime,
      'endTime': endTime,
      'topicId': topicId,
      'playerId': playerId,
    });

    print('전송된 데이터: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['success'] == false) {
        print('방 생성 실패: ${responseBody['message'] ?? '알 수 없는 오류'}, ${response.statusCode}');
        return false;
      }

      print('방 생성 성공: ${response.body}, ${response.statusCode}');
      return true;
    } else {
      print('방 생성 실패: ${response.body}, ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isLoading ? null : _saveRoomToDatabase,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('방 이름'),
              TextField(
                onChanged: (value) {
                  roomName = value;
                },
                decoration: InputDecoration(
                  hintText: '방 이름',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('주제 선택'),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final selectedTopic = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: TopicFilterScreen(
                          selectedTopicId: selectedTopicId,
                          isDialog: true,
                        ),
                      );
                    },
                  );

                  if (selectedTopic != null) {
                    setState(() {
                      selectedTopicId = selectedTopic['id'];
                      selectedTopicName = selectedTopic['name'];
                    });
                  }
                },
                child: Text(selectedTopicName ?? '선택하기'),
              ),
              const SizedBox(height: 20),
              const Text('날짜 선택'),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
              ),
              const SizedBox(height: 20),
              const Text('시간 선택'),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: Text('${selectedTime.format(context)}'),
              ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
