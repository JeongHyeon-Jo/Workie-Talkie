import 'package:alarm_app/widgets/page/my_room_page.dart';
import 'package:alarm_app/widgets/page/room_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm_app/service/room_list_notifier.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int? selectedTopicId;
  String? selectedTopicName;

  void _applyFilter(int? topicId, String? topicName) {
    setState(() {
      selectedTopicId = topicId;
      selectedTopicName = topicName;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomNotifier(),  // RoomNotifier를 Provider로 제공
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('방 목록'),
          actions: [
            IconButton(
              iconSize: 25,
              icon: Icon(
                selectedTopicId != null ? Icons.filter_alt_outlined : Icons.filter_alt,
              ),
              onPressed: () async {
                final result = await GoRouter.of(context).push<Map<String, dynamic>>('/filter');

                // 주제 필터가 선택되었는지 확인
                if (result != null) {
                  _applyFilter(result['id'], result['name']);
                }
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [
            RoomListPage(selectedTopicId: selectedTopicId),
            MyRoomPage(selectedTopicId: selectedTopicId),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) {
            setState(() {
              _index = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'My Room',
            ),
          ],
        ),
      ),
    );
  }
}
