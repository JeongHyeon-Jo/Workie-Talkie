import 'package:alarm_app/widgets/screen/chat_screen.dart';
import 'package:alarm_app/widgets/page/my_room_page.dart';
import 'package:alarm_app/widgets/page/room_list_page.dart';
import 'package:alarm_app/widgets/screen/create_room_screen.dart';
import 'package:alarm_app/widgets/screen/home_screen.dart';
import 'package:alarm_app/widgets/screen/topic_filter_screen.dart';
import 'package:alarm_app/widgets/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/login',
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => Login(),
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
		    return ChatScreen(
          roomId: (state.extra as Map<String, dynamic>)["roomId"],
          roomName: (state.extra as Map<String, dynamic>)["roomName"],
          // super.key, required this.roomId, required this.roomName
        );
	},
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => CreateRoomScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/filter',
      builder: (context, state) => TopicFilterScreen(),
    ),
  ],
);
