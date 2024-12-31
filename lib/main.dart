import 'package:alarm_app/route.dart';
import 'package:alarm_app/service/device_info_manager.dart';
import 'package:alarm_app/service/local_notification_manager.dart';
import 'package:alarm_app/service/my_room_manager.dart';
import 'package:alarm_app/service/my_room_notifier.dart';
import 'package:alarm_app/service/topic_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_app/widgets/screen/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

String serverUrl = 'http://IP:3000';
String serverWsUrl = 'http://IP:3001/chat';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestNotificationPermissions();

  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  if (await Permission.notification.request().isGranted) {
    print("알림 권한이 부여되었습니다.");
  } else {
    print("알림 권한이 거부되었습니다.");
  }

  if (await Permission.scheduleExactAlarm.request().isGranted) {
    print("정확한 알람 권한이 부여되었습니다.");
  } else {
    print("정확한 알람 권한이 거부되었습니다.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context){
    return MaterialApp.router(
      theme: ThemeData(
        fontFamily: 'Schyler',
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
