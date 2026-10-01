import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Game Collection', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
              'Track the games you own, what you are playing and what you have finished.',
              style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Features', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Bullet(
              'Add games with platform, status (backlog/playing/completed) and rating'),
          const _Bullet('Filter by status and search by title'),
          const _Bullet(
              'Collection stats: totals per status and average rating'),
          const SizedBox(height: 16),
          Text('Privacy', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Everything runs on this device. The app has no account, '
            'analytics or network calls. Your data is saved locally on this '
            'device and removed when you uninstall the app.',
          ),
          const SizedBox(height: 16),
          Text('Made by Chaowalit Greepoke · bookchaowalit.com',
              style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
