
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;

import '../models/legal_source.dart';

class GabaiResponse {
  final String text;
  final List<LegalSource> sources;
  const GabaiResponse(this.text, [this.sources = const []]);
}

class ChatTurn {
  final bool isUser;
  final String text;
  const ChatTurn({required this.isUser, required this.text});
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const _openRouterKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static const _openRouterModels = [
    'meta-llama/llama-3.3-70b-instruct:free',
    'meta-llama/llama-3.3-70b-instruct',
  ];

  static const _geminiModels = [
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  static const _attemptsPerModel = 2;
  static const _maxHistoryTurns = 6;
  static const _maxHistoryChars = 1500;

  static const _systemPrompt = '''
You are Gabai, a friendly AI legal information assistant for Philippine law. Help people understand their legal rights, options, and next steps, even if they are unfamiliar with legal terms.

TONE: Simple, respectful, empathetic, neutral. Use English, Filipino, Taglish, or the user's language/dialect when possible (Cebuano, Ilocano, Hiligaynon, Waray, Kapampangan, Pangasinan, Bikol). Never shame or intimidate.

RESPONSE FORMAT: always use these exact headers, each on its own line:

[LEGAL ISSUE]
1-2 sentences stating the user's concern. If key facts are missing, ask one clarifying question and still provide useful general info.

[APPLICABLE LAWS]
- Cite relevant Philippine laws by official name and number.
- Include only laws you can identify with reasonable confidence. If unsure, say so. Do not guess or pad the list.

[ANALYSIS]
1. What This Means: Explain the situation in everyday language.
2. How the Law Applies: Apply the laws to the facts. Distinguish facts from assumptions.
3. Possible Outcomes: Rights, responsibilities, defenses, liabilities. Never guarantee a result.
4. What You Can Do: Numbered, practical next steps.
5. Important Details: Missing facts, evidence, deadlines, exceptions.

[RECOMMENDATIONS]
Short summary. Suggest a Philippine lawyer, the PAO, or the proper agency when helpful.

[DISCLAIMER]
This is general legal information, not legal advice. For advice specific to your situation, consult a qualified Philippine lawyer.

---SOURCES---
Output only a valid JSON array of the laws and official resources you actually cited:
[
  {"title": "Official name", "citation": "Republic Act No. XXXX or agency name", "type": "Statute"}
]
Use "Official Resource" for agencies. If none cited, output exactly: []

CORE RULES
- Philippine law only.
- Never invent laws, article numbers, cases, penalties, deadlines, procedures, quotes, or sources. If you cannot verify something, say so.
- Distinguish general information from conclusions that depend on the user's facts.
- Never guarantee outcomes; do not assume an accusation means guilt.
- Do not encourage illegal acts, intimidation, evidence destruction, or evasion.
- Never ask for passwords, credentials, or unnecessary sensitive data.
- If the user is in danger, prioritize safety and emergency services.
- If a deadline may apply, tell them to verify promptly with the court, agency, or a lawyer.

CONVERSATION
- Treat follow-ups as the same conversation unless the topic clearly changes.
- Reuse known facts; do not ask the user to repeat themselves. If the user corrects a fact, update the analysis. If your earlier answer was wrong, correct it clearly.
- Keep follow-up replies focused, but still keep the required headers and the ---SOURCES--- block.
- If asked for a simpler explanation, use everyday words and a short example.

IDENTITY
- If asked who created you, say: "I was created by Echo as part of a school project."
- Never claim to be a lawyer, government official, or human professional.

STYLE
- Short sentences, plain words, no filler.
- No markdown headings, bold text, or decorative formatting beyond the section headers.
- Do not add sections beyond those above.

SOURCES AND LANGUAGE
- Every law in [APPLICABLE LAWS] must be in the JSON, and vice versa.
- JSON must be valid: double-quoted keys and values, no comments, no trailing commas.
- Place the ---SOURCES--- block only after [DISCLAIMER]. Output nothing after the JSON array.
- Match the user's language, but keep section headers in English so the app can parse them. Keep official law names and RA/PD/EO numbers accurate.
''';

  Future<GabaiResponse> ask(
    String question, {
    List<ChatTurn> history = const [],
  }) async {
    final recent = _prepareHistory(history);

    final gemini = await _tryGemini(question, recent);
    if (gemini != null) return gemini;

    debugPrint('[Gabai] Gemini unavailable. Trying OpenRouter...');

    final router = await _tryOpenRouter(question, recent);
    if (router != null) return router;

    return const GabaiResponse(
      'Sorry, I am currently unavailable. '
      'Please wait a minute and try again.',
    );
  }

  List<ChatTurn> _prepareHistory(List<ChatTurn> history) {
    var recent = history.length > _maxHistoryTurns
        ? history.sublist(history.length - _maxHistoryTurns)
        : List<ChatTurn>.from(history);

    while (recent.isNotEmpty && !recent.first.isUser) {
      recent = recent.sublist(1);
    }

    return recent.map((t) {
      var text = t.text;
      final i = text.indexOf('---SOURCES---');
      if (i != -1) text = text.substring(0, i);
      text = text.trim();
      if (text.length > _maxHistoryChars) {
        text = '${text.substring(0, _maxHistoryChars)}...';
      }
      return ChatTurn(isUser: t.isUser, text: text);
    }).toList();
  }

  Future<GabaiResponse?> _tryGemini(
    String question,
    List<ChatTurn> history,
  ) async {
    final contents = <Content>[
      Content(role: 'user', parts: [Part.text(_systemPrompt)]),
      Content(role: 'model', parts: [Part.text('Understood.')]),
      for (final t in history)
        Content(
          role: t.isUser ? 'user' : 'model',
          parts: [Part.text(t.text)],
        ),
      Content(role: 'user', parts: [Part.text(question)]),
    ];

    for (final model in _geminiModels) {
      for (int attempt = 0; attempt < _attemptsPerModel; attempt++) {
        try {
          final res = await Gemini.instance
              .chat(contents, modelName: model)
              .timeout(const Duration(seconds: 45));

          final raw = res?.output?.trim();
          if (raw == null || raw.isEmpty) break;
          return _parse(raw);
        } catch (e) {
          final msg = e.toString();
          debugPrint('[Gabai] $model attempt ${attempt + 1} failed');

          if (msg.contains('429')) break;
          if (msg.contains('400') ||
              msg.contains('401') ||
              msg.contains('403')) {
            return null;
          }

          if (attempt < _attemptsPerModel - 1) {
            await Future.delayed(const Duration(milliseconds: 1500));
          }
        }
      }
    }
    return null;
  }

  Future<GabaiResponse?> _tryOpenRouter(
    String question,
    List<ChatTurn> history,
  ) async {
    if (_openRouterKey.isEmpty) {
      debugPrint('[Gabai] OPENROUTER_API_KEY not set. Skipping fallback.');
      return null;
    }
 
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      for (final t in history)
        {'role': t.isUser ? 'user' : 'assistant', 'content': t.text},
      {'role': 'user', 'content': question},
    ];

    for (final model in _openRouterModels) {
      try {
        final response = await http
            .post(
              Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
              headers: {
                'Authorization': 'Bearer $_openRouterKey',
                'Content-Type': 'application/json',
                'HTTP-Referer': 'https://gabai.app',
                'X-Title': 'Gabai Legal Assistant',
              },
              body: jsonEncode({'model': model, 'messages': messages}),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content =
              data['choices']?[0]?['message']?['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            return _parse(content.trim());
          }
        }

        debugPrint('[Gabai] OpenRouter $model failed: ${response.statusCode}');
      } catch (e) {
        debugPrint('[Gabai] OpenRouter $model exception: $e');
      }
    }
    return null;
  }

    GabaiResponse _parse(String raw) {
    var text = raw.trim();
    String? jsonPart;

    text = text.replaceAll(RegExp(r'```(?:json)?'), '').trim();

    final markerRe = RegExp(
      r'(?:-{3,}\s*)?\bSOURCES?\b\s*(?:-{3,}|:)?',
      caseSensitive: false,
    );
    final markerMatch = markerRe.allMatches(text).lastOrNull;

    if (markerMatch != null) {
      final after = text.substring(markerMatch.end).trim();
      if (after.startsWith('[')) {
        jsonPart = after;
        text = text.substring(0, markerMatch.start).trim();
      }
    }

    if (jsonPart == null) {
      final tailRe = RegExp(r'(\[\s*\{[\s\S]*\}\s*\]|\[\s*\])\s*$');
      final m = tailRe.firstMatch(text);
      if (m != null) {
        jsonPart = m.group(1);
        text = text.substring(0, m.start).trim();
      }
    }

    text = text.replaceAll(RegExp(r'(\s*-{3,}\s*)+$'), '').trim();

    final sources = <LegalSource>[];
    if (jsonPart != null) {
      try {
        final decoded = jsonDecode(jsonPart) as List;
        for (final item in decoded) {
          final map = item as Map<String, dynamic>;
          sources.add(
            LegalSource(
              title: (map['title'] ?? '').toString(),
              citation: (map['citation'] ?? '').toString(),
              type: (map['type'] ?? 'Statute').toString(),
            ),
          );
        }
      } catch (_) {
      }
    }

    return GabaiResponse(text, sources);
  }

}
