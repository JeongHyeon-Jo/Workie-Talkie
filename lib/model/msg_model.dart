class MsgModel {
  final int roomId;
  final int playerId;
  final String playerName;
  final String text;
  final DateTime created_at;

  MsgModel({
    required this.roomId,
    required this.playerId,
    required this.playerName,
    required this.text,
    required this.created_at,
  });

  factory MsgModel.fromJson(Map<String, dynamic> json) {
    return MsgModel(
      roomId: json['roomId'],
      playerId: json['playerId'],
      playerName: json['playerNmae'],
      text: json['text'],
      created_at: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'playerId': playerId,
      'playerName': playerName,
      'text': text,
      'createdAt': created_at.toIso8601String(),
    };
  }
}























/*class Message {
  final String roomId;
  final String text;
  final String playerId;
  final String playerName;

  Message({
    required this.roomId,
    required this.text,
    required this.playerId,
    required this.playerName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      roomId: json['roomId'],
      text: json['text'],
      playerId: json['playerId'],
      playerName: json['playerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'text': text,
      'playerId': playerId,
      'playerName': playerName,
    };
  }
}
*/
