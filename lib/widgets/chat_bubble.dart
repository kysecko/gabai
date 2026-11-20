import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import 'gabai_logo.dart';
import 'source_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.85;
    return message.isUser
        ? _UserBubble(text: message.text, maxWidth: maxWidth)
        : _AiBubble(message: message, maxWidth: maxWidth);
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  const _UserBubble({required this.text, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(text,
              style: AppText.body.copyWith(color: AppColors.white, fontSize: 15)),
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final ChatMessage message;
  final double maxWidth;
  const _AiBubble({required this.message, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GabaiLogo(size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text('gab.ai',
                    style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.textStrong)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.soft,
              ),
              child: _StructuredText(text: message.text),
            ),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Relevant laws and sources',
                  style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.sm),
              for (final s in message.sources)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SourceCard(source: s),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown while waiting for the AI reply.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('gab.ai is thinking…',
                style: AppText.bodySmall.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
class _StructuredText extends StatelessWidget {
  final String text;
  const _StructuredText({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _renderBlock(block),
          ),
      ],
    );
  }

  Widget _renderBlock(String block) {
    final lines = block.split('\n');
    if (lines.isEmpty) return const SizedBox.shrink();

    final first = lines.first.trim();
    final isHeader = first.startsWith('[') && first.endsWith(']');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              first,
              style: AppText.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              first,
              style: AppText.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
        for (final line in lines.skip(1))
          if (line.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                style: AppText.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
      ],
    );
  }
}