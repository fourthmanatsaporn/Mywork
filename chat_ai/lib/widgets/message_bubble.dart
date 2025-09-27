// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onCopy;
  const MessageBubble({super.key, required this.message, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bg = message.isError
        ? Colors.red.withOpacity(0.1)
        : isUser
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant;

    final align =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: InkWell(
                onLongPress: () => onCopy(message.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: message.isError
                          ? Colors.redAccent
                          : Colors.black12,
                    ),
                  ),
                  child: SelectableText(
                    message.text,
                    style: TextStyle(
                      color: message.isError
                          ? Colors.red.shade800
                          : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _timeLabel(message.timestamp),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  String _timeLabel(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
