import 'package:flutter/material.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Checklist')),
      body: const Center(child: Text('Application Checklist')),
    );
  }
}
