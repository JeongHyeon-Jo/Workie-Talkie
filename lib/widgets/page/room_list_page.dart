import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/service/my_room_manager.dart';
import 'package:alarm_app/service/my_room_notifier.dart';
import 'package:alarm_app/service/room_list_notifier.dart';
import 'package:alarm_app/widgets/infinite_scroll_mixin.dart';
import 'package:alarm_app/widgets/room_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/widgets/room_item.dart';
import 'package:alarm_app/widgets/screen/create_room_screen.dart';
import 'package:provider/provider.dart';

class RoomListPage extends StatefulWidget {
  final int? selectedTopicId;

  const RoomListPage({super.key, this.selectedTopicId});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> with InfiniteScrollMixin {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<RoomNotifier>(context, listen: false).loadRoomsFromServer();
  }

  Future<void> _refreshRooms() async {
    // 방 목록 새로고침 (서버에서 다시 불러오기)
    await Provider.of<RoomNotifier>(context, listen: false).loadRoomsFromServer();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())  // 로딩 중 표시
          : RefreshIndicator(
              onRefresh: _refreshRooms,  // 새로고침 시 호출
              child: Consumer<RoomNotifier>(
                builder: (context, roomNotifier, child) {
                  final filteredRooms = widget.selectedTopicId == null
                      ? roomNotifier.rooms
                      : roomNotifier.rooms.where((room) => room.topicId == widget.selectedTopicId).toList();

                  if (filteredRooms.isEmpty) {
                    return const Center(child: Text('방이 없습니다.'));
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return RoomItem(room: room);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await GoRouter.of(context).push<Map<String, dynamic>>('/create');

          if (result != null) {
            final newRoom = RoomModel(
              id: result['id'],
              roomName: result['roomName'],
              startTime: result['startTime'],
              endTime: result['endTime'],
              createdAt: result['createdAt'],
              updatedAt: result['updatedAt'],
              playerId: result['playerId'],
              topicId: result['topicId'],
            );

            Provider.of<RoomNotifier>(context, listen: false).addRoom(newRoom);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
