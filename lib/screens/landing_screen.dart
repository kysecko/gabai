import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'main_shell.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset('assets/landing.png', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppText.display.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        fontSize: 28,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Rekalgera',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'gab.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 39, 2, 173),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            fontFamily: 'Rekalgera',
                          ),
                        ),
                        TextSpan(
                          text: 'ai',
                          style: TextStyle(
                            color: Color.fromARGB(255, 39, 2, 173),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            fontFamily: 'Rekalgera',
                          ),
                        ),
                        TextSpan(
                          text: '.👋',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Legal questions? We\'ve got you. gabai helps you understand Philippine law in a way that\'s easy, clear, and stress-free.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainShell()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),

                      child: const SizedBox(
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's Get Started",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
