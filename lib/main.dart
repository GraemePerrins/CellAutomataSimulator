import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/screens/ca_studio_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CaStudioApp());
}

class CaStudioApp extends StatelessWidget {
  const CaStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cellular Automata Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CaStudioMainScreen(),
    );
  }
}
