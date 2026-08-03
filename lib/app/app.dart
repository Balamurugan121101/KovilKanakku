import 'package:flutter/material.dart';
import 'package:temple/app/router.dart';
import 'package:temple/app/theme.dart';

class KovilKanakku extends StatelessWidget {
  const KovilKanakku({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kovil Kanakku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter
    );
  }
}