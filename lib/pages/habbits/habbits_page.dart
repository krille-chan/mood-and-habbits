import 'package:flutter/material.dart';

class HabbitsPage extends StatelessWidget {
  const HabbitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Habbits'),
      ),
      body: const Placeholder(),
    );
  }
}
