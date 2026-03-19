import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'config/routes.dart';

class CyCitizenshipApp extends StatelessWidget {
  const CyCitizenshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CyCitizenship',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
