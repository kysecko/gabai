import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/faq_card.dart';
import '../models/faq.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chat = ChatService.instance;
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<Faq> _faqs = const [
    Faq(
      icon: HeroIcons.briefcase,
      title: 'Employee rights',
      subtitle: 'Know your workplace rights',
      question: 'What are my rights as an employee?',
    ),
    Faq(
      icon: HeroIcons.shieldCheck,
      title: 'Data privacy',
      subtitle: 'Protect your personal data',
      question: 'How does the law protect my personal data?',
    ),
    Faq(
      icon: HeroIcons.documentText,
      title: 'Valid contracts',
      subtitle: 'Understand agreements',
      question: 'What makes a contract valid in the Philippines?',
    ),
    Faq(
      icon: HeroIcons.users,
      title: 'Family law',
      subtitle: 'Learn about legal separation',
      question: 'How does legal separation work in the Philippines?',
    ),
    Faq(
      icon: HeroIcons.shoppingBag,
      title: 'Consumer rights',
      subtitle: 'Know your rights as a buyer',
      question:
          'What can I do if a seller refuses a refund for a defective product?',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chat.addListener(_scrollToEnd);
  }

  @override
  void dispose() {
    _chat.removeListener(_scrollToEnd);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    _chat.send(text);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chat,
      builder: (context, _) {
        final started = _chat.hasStartedChat;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: const Color.fromARGB(255, 243, 243, 243),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.transparent,
                shape: CircleBorder(
                  side: BorderSide(color: AppColors.border, width: 1),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: started ? _chat.startNewChat : null,
                  child: Center(
                    child: SvgPicture.asset(
                      started
                          ? 'assets/chat-add-active.svg'
                          : 'assets/chat-add.svg',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    style: AppText.heading,
                    children: [
                      TextSpan(
                        text: 'gab.',
                        style: TextStyle(
                          color: Color(0xFF2702AD),
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFamily: 'Rekalgera',
                        ),
                      ),
                      TextSpan(
                        text: 'ai',
                        style: TextStyle(
                          color: Color(0xFF2702AD),
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFamily: 'Rekalgera',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.transparent,
                  shape: CircleBorder(
                    side: BorderSide(color: AppColors.border, width: 1),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.of(context).pushNamed('/history');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Image(
                        image: AssetImage('assets/history.png'),
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: started ? _buildConversation() : _buildWelcome()),
              ChatInput(
                controller: _controller,
                hint: started ? 'Continue asking...' : 'Type your question...',
                enabled: !_chat.isBusy,
                onSend: _send,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcome() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          "Hello! How can I help?",
          style: AppText.heading.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Facing a problem or legal concern? I’m here to help you understand your options under Philippine law.',
          style: AppText.body.copyWith(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Frequently Asked Questions',
          style: AppText.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            fontFamily: 'Manrope',
          ),
        ),
        SizedBox(height: 16),

        // FAQ Cards
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < _faqs.length; i++) ...[
              FaqCard(
                icon: _faqs[i].icon,
                title: _faqs[i].title,
                subtitle: _faqs[i].subtitle,
                onTap: () => _chat.send(_faqs[i].question),
              ),
              if (i != _faqs.length - 1) const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildConversation() {
    final messages = _chat.messages;
    final typing = _chat.isTyping;

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: messages.length + (typing ? 1 : 0) + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              'Your conversation',
              style: AppText.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          );
        }
        final idx = i - 1;
        if (idx == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: TypingBubble(),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: ChatBubble(message: messages[idx]),
        );
      },
    );
  }
}
