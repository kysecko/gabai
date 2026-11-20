import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../models/conversation.dart';
import '../navigation/tab_state.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

//saved conversations you can reopen.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text('This will permanently remove this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final chat = ChatService.instance;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text(
          'History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: chat,
        builder: (context, _) {
          final items = chat.conversations;
          if (items.isEmpty) return const _EmptyHistory();

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) {
              final c = items[i];

              void continueChat() {
                chat.open(c.id);
                goToTab(AppTab.chat);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }

              Future<void> deleteChat() async {
                if (await _confirmDelete(context)) {
                  chat.delete(c.id);
                }
              }

              return Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) => chat.delete(c.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const HeroIcon(
                    HeroIcons.trash,
                    size: 22,
                    color: AppColors.danger,
                  ),
                ),
                child: _ConversationTile(
                  conversation: c,
                  isActive: chat.active?.id == c.id,
                  onContinue: continueChat,
                  onDelete: deleteChat,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isActive;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.onContinue,
    required this.onDelete,
  });

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    if (d.inDays < 7) return '${d.inDays} d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final count = conversation.messages.length;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isActive ? AppColors.primaryBorder : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const HeroIcon(
                  HeroIcons.chatBubbleLeftRight,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      conversation.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$count messages · ${_ago(conversation.updatedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Delete button: red gradient with red trash icon
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE5E5), Color(0xFFFFCCCC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete conversation',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const HeroIcon(
                    HeroIcons.trash,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Continue button: white background with black arrow
              IconButton(
                onPressed: onContinue,
                tooltip: 'Continue conversation',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                icon: const HeroIcon(
                  HeroIcons.arrowRight,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeroIcon(
              HeroIcons.clock,
              size: 48,
              color: AppColors.disabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No conversations yet',
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textStrong,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your past questions will appear here.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
