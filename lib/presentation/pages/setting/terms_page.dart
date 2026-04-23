import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  static const route = '/terms';
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Terms & Conditions – CAMSME',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          _Section(
            '1. Acceptance of Terms',
            'By creating an account or using CAMSME, you agree to these Terms and all applicable laws.',
          ),
          _Section(
            '2. Use of the App',
            'CAMSMe allows you to record, track, and manage inventory data. You agree not to use the app for illegal or unauthorized purposes, upload harmful content, or attempt to hack or reverse engineer the app.',
          ),
          _Section(
            '3. Account Responsibility',
            'You are responsible for maintaining the confidentiality of your account and password, and for all activity under your account.',
          ),
          _Section(
            '4. Intellectual Property',
            'All content, trademarks, and features within CAMSME are owned by us. You may not copy, distribute, or reuse any part of the app without written permission.',
          ),
          _Section(
            '5. Limitation of Liability',
            'CAMSME is provided"as is."We do not guarantee that the app will be error-free or uninterrupted.We are not liable for any loss damage resulting from your use or inability to use the app.',
          ),
          _Section(
            '6. Termination',
            'We reserve the right suspend or terminate your access if you violate these terms or misuse the service.',
          ),
          _Section(
            '7. Changes to Terms',
            'We may update these Terms & Conditions at any time. Continued use of CAMSME means you accept any updated terms.',
          ),
          _Section(
            '8. Contact',
            'If you hace puestion about this Privacy Policy.please contact us at: 📧 support@camsme.app',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
