import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  ChatService._();
  static final ChatService instance = ChatService._();

  static const _storageKey = 'gabai_conversations_v1';

  final List<Conversation> _conversations = [];
  Conversation? _active;
  String? _typingId;

  Conversation? get active => _active;

  List<ChatMessage> get messages => _active?.messages ?? const [];

  bool get hasStartedChat => messages.isNotEmpty;

  bool get isTyping => _typingId != null && _typingId == _active?.id;
  bool get isBusy => _typingId != null;

  /// Newest first.
  List<Conversation> get conversations {
    final list = [..._conversations];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  void startNewChat() {
    _active = null;
    notifyListeners();
  }

  void open(String id) {
    for (final c in _conversations) {
      if (c.id == id) {
        _active = c;
        notifyListeners();
        return;
      }
    }
  }

  Future<void> delete(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    if (_active?.id == id) _active = null;
    notifyListeners();
    await _save();
  }

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || isBusy) return;

    final now = DateTime.now();
    var convo = _active;
    if (convo == null) {
      convo = Conversation(
        id: now.microsecondsSinceEpoch.toString(),
        title:
            question.length > 60 ? '${question.substring(0, 60)}…' : question,
        createdAt: now,
        updatedAt: now,
      );
      _conversations.add(convo);
      _active = convo;
    }

    // Build history BEFORE adding the new question, skipping failed replies.
    final history = convo.messages
        .where((m) => !m.text.startsWith('Sorry, something went wrong'))
        .map((m) => ChatTurn(isUser: m.isUser, text: m.text))
        .toList();

    convo.messages.add(ChatMessage(
      id: '${now.microsecondsSinceEpoch}u',
      text: question,
      isUser: true,
      time: now,
    ));
    convo.updatedAt = now;
    _typingId = convo.id;
    notifyListeners();
    await _save();

    ChatMessage reply;
    try {
      final res = await ApiService.instance.ask(question, history: history);
      reply = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}a',
        text: res.text,
        isUser: false,
        time: DateTime.now(),
        sources: res.sources,
      );
    } catch (_) {
      reply = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}e',
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        time: DateTime.now(),
      );
    }

    convo.messages.add(reply);
    convo.updatedAt = reply.time;
    _typingId = null;
    notifyListeners();
    await _save();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _conversations
        ..clear()
        ..addAll(
          list.map((c) => Conversation.fromJson(c as Map<String, dynamic>)),
        );
    } catch (_) {
      _conversations.clear();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_conversations.map((c) => c.toJson()).toList()),
    );
  }
}