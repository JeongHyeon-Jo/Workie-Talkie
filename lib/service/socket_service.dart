import 'package:alarm_app/main.dart';
import 'package:alarm_app/model/room_model.dart';
import 'package:alarm_app/model/user_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  late String playerId;
  Function(Map<String, dynamic>)? onMessageReceived;

  void init(UserModel user) {
    socket = IO.io(
      serverWsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'playerId': user.playerId})
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.on('msg', (data) {
      print('Received message: $data');
      if (onMessageReceived != null) {
        onMessageReceived!(data); // 콜백 호출
      }
    });


    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });

    socket.on('userList', (data) {
      print('User List: ${data['userList']}');
    });
  }

  void sendMessage(int roomId, String msg, String playerId) {
    socket.emit('msg', {'roomId': roomId, 'msg': msg, 'playerId': playerId});
  }

  void joinRoom(int roomId, String playerId) {
    socket.emit('join', {'roomId': roomId, 'playerId': playerId});
  }

  void exitRoom(int roomId) {
    socket.emit('exit', {'roomId': roomId});
  }

  void getUserList(int roomId) {
    socket.emit('getUserList', roomId);
  }

  void disponse() {
    socket.dispose();
  }
}
