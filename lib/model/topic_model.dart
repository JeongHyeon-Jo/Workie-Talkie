class TopicModel {
  final int id;
  final String name;
  final DateTime created_at;
  final DateTime updated_at;

  TopicModel(
      {required this.id,
        required this.name,
        required this.created_at,
        required this.updated_at});

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      name: json['name'],
      created_at: DateTime.parse(json['createdAt']),
      updated_at: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': created_at.toIso8601String(),
      'updatedAt': created_at.toIso8601String(),
    };
  }
}