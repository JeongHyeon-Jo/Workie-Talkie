import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alarm_app/service/device_info_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alarm_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _idController = TextEditingController();

  Future<int> _generatePlayerId() async {
    String deviceUUID = await InfoManager.getDeviceUUID();
    // uuid를 해시 값으로 변경후 절대값으로 변환하여 고유한 id 생성
    int playerId = deviceUUID.hashCode.abs();
    return playerId;
  }

  Future<void> _login() async {
    String name = _idController.text.toString();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이름을 입력하세요.")),
      );
      return;
    }

    try {
      int playerId = await _generatePlayerId();
      String deviceUUID = await InfoManager.getDeviceUUID();

      // 서버로 요청 보내기
      final response = await http.post(
        Uri.parse('$serverUrl/player'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid': deviceUUID,
          'name': name,
          'player_id': playerId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 서버 응답에서 할당된 사용자 id 추출
        int userId = data['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userId);
        await prefs.setString('user_name', name);

        GoRouter.of(context).go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 실패")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('로그인'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 180),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('이름'),
              Container(
                padding: EdgeInsets.only(left: 20),
                margin: EdgeInsets.only(left: 15),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                width: 300,
                height: 50,
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '이름을 입력하시오',
                    hintStyle: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  controller: _idController,
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _login,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
