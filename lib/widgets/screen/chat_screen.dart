import 'package:alarm_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:alarm_app/service/socket_service.dart';
import 'package:alarm_app/service/device_info_manager.dart';
import 'package:alarm_app/model/msg_model.dart';
import 'package:http/http.dart' as http;
import 'package:alarm_app/main.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late final SocketService _socketService = SocketService();
  List<Map<String, dynamic>> messages = [];
  final _controller = TextEditingController();
  late String _currentPlayerName;

  var _userEnterMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userName = await InfoManager.getStoredUserName();
    _currentPlayerName = userName!;

    _socketService.init(UserModel(playerId: _currentPlayerName));

    _socketService.joinRoom(widget.roomId, _currentPlayerName);

    _socketService.onMessageReceived = (data) {
      setState(() {
        messages.insert(0, data); // 메시지를 리스트에 추가
      });
    };
  }

  void _sendMessage() {
    final messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      final message = {
        'playerId': _currentPlayerName,
        'msg': messageText,
      };

      _socketService.sendMessage(widget.roomId, messageText, _currentPlayerName);

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _socketService.exitRoom(widget.roomId);
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['playerId'] == _currentPlayerName;
                print('message: $message');

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Padding( 
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          message['playerId'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(12.0),
                              topLeft: const Radius.circular(12.0),
                              bottomRight: isMe
                                  ? const Radius.circular(0.0)
                                  : const Radius.circular(12.0),
                              bottomLeft: isMe
                                  ? const Radius.circular(12.0)
                                  : const Radius.circular(0.0),
                            ),
                          ),
                          child: Text(
                            message['msg'],
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              reverse: true,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Send a message...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _userEnterMessage = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _userEnterMessage.trim().isEmpty ? null : _sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
