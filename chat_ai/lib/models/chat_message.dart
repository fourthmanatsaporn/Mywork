// lib/models/chat_message.dart
import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        isError: json['isError'] ?? false,
      );
}
