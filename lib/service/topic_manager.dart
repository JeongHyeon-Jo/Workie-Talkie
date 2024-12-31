import 'dart:convert';
import 'package:alarm_app/model/topic_model.dart';
import 'package:http/http.dart' as http;
import 'package:alarm_app/main.dart';

class TopicManager {
  Future<List<TopicModel>> loadTopic() async {
    final url = Uri.parse('$serverUrl/topic/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TopicModel.fromJson(json)).toList();
    } else {
      throw Exception('데이터 불러오기 실패 ${response.statusCode}');
    }
  }

  Future<TopicModel?> loadTopicByName(String name) async {
    final topic = await loadTopic();
    return topic.firstWhere((topic) => topic.name == name);
  }

  Future<TopicModel?> getTopicById(int topicId) async {
    final topics = await loadTopic();

    // 먼저 존재하는지 확인한 후 반환
    try {
      return topics.firstWhere((topic) => topic.id == topicId);
    } catch (e) {
      // 만약 찾지 못했을 경우 null을 반환
      return null;
    }
  }
}
