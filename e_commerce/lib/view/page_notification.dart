import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: const Text(
          'Aucune notification pour le moment.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
