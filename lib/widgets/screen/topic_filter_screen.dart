import 'package:alarm_app/model/topic_model.dart';
import 'package:alarm_app/service/topic_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopicFilterScreen extends StatefulWidget {
  final int? selectedTopicId;
  final bool isDialog;
  const TopicFilterScreen({super.key, this.selectedTopicId, this.isDialog = false});

  @override
  State<TopicFilterScreen> createState() => _TopicFilterScreenState();
}

class _TopicFilterScreenState extends State<TopicFilterScreen> {
  int? selectedTopicId;
  String? selectedTopicName;
  List<TopicModel> topics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedTopicId = widget.selectedTopicId;
    _loadTopic();
  }

  Future<void> _loadTopic() async {
    setState(() {
      isLoading = true;
    });

    try {
      final TopicManager topicManager = TopicManager();
      final List<TopicModel> fetchedTopic = await topicManager.loadTopic();
      setState(() {
        topics = fetchedTopic;
        if (selectedTopicId != null) {
          selectedTopicName = topics.firstWhere((topic) => topic.id == selectedTopicId).name;
        }
      });
    } catch (e) {
      _showErrorDialog('주제를 불러오지 못했습니다: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주제 필터'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {'id': selectedTopicId, 'name': selectedTopicName});
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                children: topics.map((topic) {
                  return ChoiceChip(
                    label: Text(topic.name),
                    selected: selectedTopicId == topic.id,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedTopicId = selected ? topic.id : null;
                        selectedTopicName = selected ? topic.name : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
    );
  }

  //앱상에서 db연결 확인용, 추후에 스낵바로 변경?
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류 발생'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
