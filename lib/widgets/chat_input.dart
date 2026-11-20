import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (widget.enabled) widget.onSend();
                  },
                  style: AppText.body.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppText.body.copyWith(
                      fontSize: 15,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 49, 49, 49),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: widget.enabled ? widget.onSend : null,
                tooltip: 'Send',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.disabled,
                  fixedSize: const Size(48, 48),
                ),
                icon: const HeroIcon(
                  HeroIcons.paperAirplane,
                  style: HeroIconStyle.solid,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Note: ',
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                  TextSpan(
                    text:
                        'gab.ai offers general info—always consult a lawyer for legal advice.',
                    style: AppText.caption.copyWith(color: AppColors.textHint),
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
