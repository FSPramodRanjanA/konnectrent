import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:konnectrent/core/theme/app_theme.dart';

// Replace this URL with your hosted privacy policy before Play Store submission
const _privacyPolicyUrl =
    'https://fspamodranjana.github.io/konnectrent/privacy-policy';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        children: [
          _AppHeader(tt),
          const SizedBox(height: AppTheme.spaceLG),
          _DisclaimerCard(tt),
          const SizedBox(height: AppTheme.spaceMD),
          _LinksCard(tt),
          const SizedBox(height: AppTheme.spaceMD),
          _PrivacyCard(tt),
          const SizedBox(height: AppTheme.spaceLG),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader(this.tt);
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.home_work_outlined,
              color: Colors.white, size: 44,),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Text('KonnectRent', style: tt.headlineMedium),
        Text('Version 1.0.0', style: tt.bodyMedium),
        const SizedBox(height: AppTheme.spaceXS),
        Text(
          'Offline Rent vs Buy Calculator for India',
          style: tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard(this.tt);
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.accentAmber, size: 20,),
                const SizedBox(width: AppTheme.spaceXS),
                Text('Financial Disclaimer', style: tt.titleMedium),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              'KonnectRent is a financial calculator provided for general '
              'informational and educational purposes only. The calculations '
              'are estimates based on the inputs you provide and standard '
              'financial formulas.\n\n'
              'This app does not constitute financial advice, investment '
              'advice, or any other professional advice. Always consult a '
              'qualified financial advisor before making any property purchase '
              'or investment decision.',
              style: tt.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinksCard extends StatelessWidget {
  const _LinksCard(this.tt);
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.policy_outlined,
                color: AppTheme.primaryTeal,),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _launch(_privacyPolicyUrl, context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mail_outline,
                color: AppTheme.primaryTeal,),
            title: const Text('Contact / Feedback'),
            subtitle: const Text('pramodinfo2829@gmail.com'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _launch(
              'mailto:pramodinfo2829@gmail.com?subject=KonnectRent%20Feedback',
              context,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard(this.tt);
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data & Privacy', style: tt.titleMedium),
            const SizedBox(height: AppTheme.spaceSM),
            _BulletItem(
              tt,
              icon: Icons.storage_outlined,
              text: 'All your inputs and calculation history are stored '
                  'locally on your device only.',
            ),
            const SizedBox(height: AppTheme.spaceXS),
            _BulletItem(
              tt,
              icon: Icons.wifi_off,
              text:
                  'No personal data is sent to any server. The app works 100% offline.',
            ),
            const SizedBox(height: AppTheme.spaceXS),
            _BulletItem(
              tt,
              icon: Icons.ads_click,
              text:
                  'This app displays ads via Google AdMob. AdMob may use your '
                  'advertising ID to show relevant ads. See our Privacy Policy for details.',
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.tt, {required this.icon, required this.text});
  final TextTheme tt;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryTeal),
        const SizedBox(width: AppTheme.spaceXS),
        Expanded(child: Text(text, style: tt.bodyMedium)),
      ],
    );
  }
}
