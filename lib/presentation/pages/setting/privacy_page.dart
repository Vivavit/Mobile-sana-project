import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  static const route = '/privacy';
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Privacy Policy – CAMSME',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'Welcome to CAMSME, an inventory management app designed to help businesses manage products, '
            'track stock, and organize sales data efficiently.\n\n'
            'Your privacy is important to us, and we are committed to protecting your personal information.',
          ),
          SizedBox(height: 16),
          _SectionTitle('1. Information We Collect'),
          _Bullet('Account Information: name, email address, and password.'),
          _Bullet(
            'Business Information: product details, pricing, and stock data you input.',
          ),
          _Bullet(
            'Device Information: device type, OS, and usage data to improve performance.',
          ),
          _Bullet('Optional Data: any info you choose to share with support.'),
          SizedBox(height: 16),
          _SectionTitle('2. How We Use Your Information'),
          _Bullet('Provide and improve our inventory management services.'),
          _Bullet('Secure your account and prevent unauthorized access.'),
          _Bullet('Communicate updates, features, or technical issues.'),
          _Bullet('Analyze app usage to enhance performance and usability.'),
          SizedBox(height: 16),
          _SectionTitle('3. How We Protect Your Data'),
          Text(
            'We use industry-standard security measures, including encryption and authentication tools, to protect your information. However, please note that no system is 100% secure.',
          ),
          SizedBox(height: 16),
          _SectionTitle('4. Sharing of Information'),
          Text('We do nor sell or rent your data to third parties'),
          _Bullet('Required by law or legal process.'),
          _Bullet(
            'Needed to provide essential third-party services (e.g., hosting, analytics), under strict confidentiality agreements.',
          ),
          SizedBox(height: 16),
          _SectionTitle('5. Your Rights'),
          Text('You have the right to:'),
          _Bullet('Access, update, or delete your account information.'),
          _Bullet('Request a copy of your stored data.'),
          _Bullet('Withdraw consent at any time by deleting your account.'),
          _SectionTitle('6. Data Retention'),
          Text(
            'We retain your information only as long as necessary to provide our services or comply with legal obligations.',
          ),
          _SectionTitle('7.Update to this policy'),
          Text(
            'We may update this Privacy Policy from time to time. Any changes will be posted within the app or on our website.',
          ),
          _SectionTitle('8. Contact Us'),
          Text(
            'If you have questions about this Privacy Policy, please contact us at: 📧 support@camsme.app',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w700));
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
