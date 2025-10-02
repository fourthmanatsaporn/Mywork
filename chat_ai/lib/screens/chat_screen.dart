// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';        // <— ต้องมี
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../widgets/message_bubble.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIService _ai = AIService();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _busy = false;

  // เก็บประวัติข้อความแบบง่าย ๆ
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'สวัสดี! วันนี้อยากถามอะไรดีคะ!:', isUser: false),
  ];

  // แปลงประวัติให้เป็นรูปแบบ API (role/content)
  List<Map<String, String>> _toProviderMessages() {
    final systemPrompt = dotenv.env['SYSTEM_PROMPT'];
    final list = <Map<String, String>>[];
    if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
      list.add({'role': 'system', 'content': systemPrompt.trim()});
    }
    for (final m in _messages) {
      list.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      });
    }
    return list;
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      _input.clear();
    });

    try {
      final reply = await _ai.chat(messages: _toProviderMessages());
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'เกิดข้อผิดพลาด: $e',
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() => _busy = false);
      await Future.delayed(const Duration(milliseconds: 60));
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(ChatMessage(text: 'เริ่มใหม่ได้เลย ✨', isUser: false));
    });
  }

  void _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คัดลอกข้อความแล้ว')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = dotenv.env['AI_PROVIDER_PRIMARY'] ?? 'openai';
    return Scaffold(
      appBar: AppBar(
        title: Text('Fourth ChatAI (${provider.toUpperCase()})'),
        actions: [
          IconButton(
            tooltip: 'ล้างแชท',
            onPressed: _busy ? null : _clearChat,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => MessageBubble(
                message: _messages[i],
                onCopy: _copyText,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _busy ? null : _send,
                    icon: _busy
                        ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: const Text('ส่ง'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
