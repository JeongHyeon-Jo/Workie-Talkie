import 'package:alarm_app/service/my_room_manager.dart';
import 'package:alarm_app/service/my_room_notifier.dart';
import 'package:alarm_app/widgets/infinite_scroll_mixin.dart';
import 'package:alarm_app/widgets/room_item.dart';
import 'package:flutter/material.dart';
import 'package:alarm_app/model/room_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_app/service/room_list_notifier.dart';
import 'package:provider/provider.dart';

class MyRoomPage extends StatefulWidget {
  final int? selectedTopicId;

  const MyRoomPage({super.key, this.selectedTopicId});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> with InfiniteScrollMixin {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<RoomNotifier>(context, listen: false).loadRoomsFromServer();
  }

  @override
  void onScroll() {
    if (!_isLoading) {
      _loadMoreRooms();
    }
  }

  void _loadMoreRooms() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<int?>(
        future: _getUserId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userId = snapshot.data;

          return _isLoading
              ? const Center(child: CircularProgressIndicator())  // 로딩 중
              : Consumer<RoomNotifier>(
                  builder: (context, roomNotifier, child) {
                    final myRooms = roomNotifier.rooms
                        .where((room) => room.playerId == userId)
                        .where((room) => widget.selectedTopicId == null || room.topicId == widget.selectedTopicId)
                        .toList();

                    if (myRooms.isEmpty) {
                      return const Center(child: Text('생성한 방이 없습니다.'));
                    }

                    return ListView.builder(
                      itemCount: myRooms.length,
                      itemBuilder: (context, index) {
                        final room = myRooms[index];
                        return RoomItem(room: room);
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
