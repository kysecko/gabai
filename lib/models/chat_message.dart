import 'legal_source.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime time;
  final List<LegalSource> sources;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.sources = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'time': time.toIso8601String(),
        'sources': sources.map((s) => s.toJson()).toList(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        text: j['text'] as String,
        isUser: j['isUser'] as bool,
        time: DateTime.parse(j['time'] as String),
        sources: (j['sources'] as List? ?? [])
            .map((s) => LegalSource.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
