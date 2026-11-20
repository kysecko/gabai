import 'package:flutter/material.dart';

import '../navigation/tab_state.dart';
import 'chat_screen.dart';
import 'history_screen.dart';

/// Hosts the bottom navigation: Chat and History.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  // Order must match the AppTab enum.
  static const _pages = <Widget>[ChatScreen(), HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    // Hide the bar while typing so it doesn't float above the keyboard.

    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (_, index, __) => Scaffold(
        body: IndexedStack(index: index, children: _pages),
      ),
    );
  }
}
