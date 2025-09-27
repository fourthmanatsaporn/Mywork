// lib/services/ai_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// โครงสร้างข้อความส่งเข้า API
typedef ChatMsg = Map<String, String>; // { role: user/assistant/system, content: ... }

class AIService {
  AIService();

  // อ่านค่าจาก .env แบบปลอดภัย (ไม่โยน error ถ้ายังไม่ init)
  String _env(String key, {String? or}) =>
      dotenv.maybeGet(key) ?? or ?? '';

  // ผู้ให้บริการหลัก/สำรอง
  late final String _primary =
      _env('AI_PROVIDER_PRIMARY', or: _env('AI_PROVIDER', or: 'openai')).toLowerCase();
  late final String _secondary = _env('AI_PROVIDER_SECONDARY', or: 'groq').toLowerCase();

  // ตั้ง timeout รวมต่อคำขอ (กันรอค้าง)
  static const Duration _timeout = Duration(seconds: 35);

  /// เรียกใช้งาน: ส่งข้อความทั้งหมด (history) -> ได้คำตอบ (String)
  Future<String> chat({required List<ChatMsg> messages}) async {
    try {
      return await _callProvider(_primary, messages);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Primary provider (`$_primary`) failed: $e -> trying `$_secondary`...');
      }
      return await _callProvider(_secondary, messages);
    }
  }

  Future<String> _callProvider(String provider, List<ChatMsg> messages) {
    switch (provider) {
      case 'openai':
        return _callOpenAI(messages);
      case 'groq':
        return _callGroq(messages);
      case 'openrouter':
        return _callOpenRouter(messages);
      default:
        // fallback เป็น OpenAI
        return _callOpenAI(messages);
    }
  }

  // ---------------- OpenAI ----------------
  Future<String> _callOpenAI(List<ChatMsg> messages) async {
    final apiKey = _env('OPENAI_API_KEY');
    if (apiKey.isEmpty) _fail('OPENAI_API_KEY is missing');

    final baseUrl = _env('OPENAI_BASE_URL', or: 'https://api.openai.com/v1').trim();
    final model = _env('OPENAI_MODEL', or: 'gpt-4o-mini').trim();
    final org = _env('OPENAI_ORG');
    final project = _env('OPENAI_PROJECT');

    final uri = Uri.parse('$baseUrl/chat/completions');
    final payload = _messagesPayload(messages);

    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      if (org.isNotEmpty) 'OpenAI-Organization': org,
      if (project.isNotEmpty) 'OpenAI-Project': project,
    };

    final res = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'model': model,
            'messages': payload,
            'temperature': _readNum(_env('TEMPERATURE', or: '0.7')) ?? 0.7,
            'max_tokens': _readInt(_env('MAX_TOKENS', or: '1024')) ?? 1024,
          }),
        )
        .timeout(_timeout);

    return _handleResponse(res, providerName: 'OpenAI');
  }

  // ---------------- Groq ----------------
  Future<String> _callGroq(List<ChatMsg> messages) async {
    final apiKey = _env('GROQ_API_KEY');
    if (apiKey.isEmpty) _fail('GROQ_API_KEY is missing');

    final baseUrl = _env('GROQ_BASE_URL', or: 'https://api.groq.com/openai/v1').trim();
    final model = _env('GROQ_MODEL', or: 'llama-3.1-8b-instant').trim();

    final uri = Uri.parse('$baseUrl/chat/completions');
    final payload = _messagesPayload(messages);

    final res = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': payload,
            'temperature': _readNum(_env('TEMPERATURE', or: '0.6')) ?? 0.6,
            'max_tokens': _readInt(_env('MAX_TOKENS', or: '1024')) ?? 1024,
          }),
        )
        .timeout(_timeout);

    return _handleResponse(res, providerName: 'Groq');
  }

  // ---------------- OpenRouter ----------------
  Future<String> _callOpenRouter(List<ChatMsg> messages) async {
    final apiKey = _env('OPENROUTER_API_KEY');
    if (apiKey.isEmpty) _fail('OPENROUTER_API_KEY is missing');

    final baseUrl = _env('OPENROUTER_BASE_URL', or: 'https://openrouter.ai/api/v1').trim();
    final model = _env('OPENROUTER_MODEL', or: 'meta-llama/llama-3.1-8b-instruct').trim();
    final site = _env('OPENROUTER_SITE');
    final app = _env('OPENROUTER_APP');

    final uri = Uri.parse('$baseUrl/chat/completions');
    final payload = _messagesPayload(messages);

    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      if (site.isNotEmpty) 'HTTP-Referer': site,
      if (app.isNotEmpty) 'X-Title': app,
    };

    final res = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'model': model,
            'messages': payload,
            'temperature': _readNum(_env('TEMPERATURE', or: '0.7')) ?? 0.7,
            'max_tokens': _readInt(_env('MAX_TOKENS', or: '1024')) ?? 1024,
          }),
        )
        .timeout(_timeout);

    return _handleResponse(res, providerName: 'OpenRouter');
  }

  // ---------------- Helpers ----------------
  List<Map<String, String>> _messagesPayload(List<ChatMsg> messages) {
    return messages.map((m) {
      final role = m['role'] ?? 'user';
      final content = m['content'] ?? '';
      return {'role': role, 'content': content};
    }).toList();
  }

  String _handleResponse(http.Response res, {required String providerName}) {
    try {
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final choices = body['choices'] as List<dynamic>?;

        if (choices == null || choices.isEmpty) {
          throw Exception('$providerName returned no choices');
        }

        final msg = choices.first['message'];
        final content = (msg is Map && msg['content'] is String) ? msg['content'] as String : null;

        if (content == null || content.trim().isEmpty) {
          throw Exception('$providerName returned empty content');
        }
        return content.trim();
      }

      // แปลง error เนื้อ ๆ ให้อ่านง่าย
      final reason = _shorten(res.body);
      throw Exception('$providerName ${res.statusCode} • $reason');
    } on FormatException catch (_) {
      // JSON parse ผิดรูป
      throw Exception('$providerName response parse error: ${_shorten(res.body)}');
    } on SocketException catch (e) {
      throw Exception('$providerName network error: $e');
    } on HttpException catch (e) {
      throw Exception('$providerName http error: $e');
    }
  }

  int? _readInt(String? s) => s == null ? null : int.tryParse(s.trim());
  num? _readNum(String? s) => s == null ? null : num.tryParse(s.trim());

  Never _fail(String message) => throw Exception(message);

  String _shorten(String s, {int max = 240}) {
    s = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }
}
