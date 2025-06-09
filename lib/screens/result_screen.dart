import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Game Over!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('Winner: Player 1', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main_menu');
              },
              child: const Text('Return to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
