import 'package:flutter/foundation.dart';

enum AppTab { chat, history }

final ValueNotifier<int> tabIndex = ValueNotifier<int>(AppTab.chat.index);

void goToTab(AppTab tab) => tabIndex.value = tab.index;
