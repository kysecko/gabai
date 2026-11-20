import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'app.dart';
import 'services/chat_service.dart';

const _geminiKey = String.fromEnvironment('GEMINI_API_KEY');
const _openRouterKey = String.fromEnvironment('OPENROUTER_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_geminiKey.isEmpty) {
    throw StateError(
      'GEMINI_API_KEY missing. Run with:\n'
      'flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE',
    );
  }

  if (_openRouterKey.isEmpty) {
    debugPrint(
      '[Gabai] OPENROUTER_API_KEY not set, fallback disabled. '
      'Add --dart-define=OPENROUTER_API_KEY=YOUR_KEY_HERE',
    );
  }

  Gemini.init(apiKey: _geminiKey);

  await ChatService.instance.load();
  runApp(const GabAIApp());
}