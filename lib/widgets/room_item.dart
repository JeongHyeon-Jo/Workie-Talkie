import 'dart:async';
import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/service/my_room_manager.dart';
import 'package:alarm_app/service/topic_manager.dart';
import 'package:alarm_app/model/topic_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:alarm_app/service/room_list_notifier.dart';

class RoomItem extends StatefulWidget {
  final RoomModel room;
  const RoomItem({super.key, required this.room});

  @override
  State<RoomItem> createState() => _RoomItemState();
}

class _RoomItemState extends State<RoomItem> {
  // 토픽 모델 리스트
  List<TopicModel> topic = [];
  // 기본 변수
  String bookBtn = "예약";
  bool _isbooked = false;
  DateTime now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTopic();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        now = DateTime.now().toUtc();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTopic() async {
    try {
      final TopicManager topicManager = TopicManager();
      final List<TopicModel> fetchedTopic = await topicManager.loadTopic();
      setState(() {
        topic = fetchedTopic;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주제를 불러오지 못했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room.endTime.isBefore(now)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 400,
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("주제: ${widget.room.topicId}"),
            ],
          ),
          Text("방이름: ${widget.room.roomName}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (now.isBefore(widget.room.startTime))
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isbooked = !_isbooked;
                          bookBtn = _isbooked ? "예약 취소" : "예약";
                        });
                      },
                      child: Text(
                        bookBtn,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).push('/chat', extra: {
                          "roomId": widget.room.id,
                          "roomName": widget.room.roomName,
                        });
                      },
                      child: const Text(
                        "참여",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Colors.blue,
                      ),
                    ),
            ],
          ),
          Text("시작: ${widget.room.startTime}"),
          Text("종료: ${widget.room.endTime}"),
        ],
      ),
    );
  }
}
