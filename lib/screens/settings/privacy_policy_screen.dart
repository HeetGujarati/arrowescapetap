import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/audio_manager.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        AudioManager.instance.playClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Privacy Policy',
                        style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.25)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text('LEGAL',
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: Colors.white.withValues(alpha: 0.85))),
                            ),
                            const SizedBox(height: 14),
                            Text('Privacy Policy',
                                style: GoogleFonts.nunito(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(
                                'Arrow Escape · Puzzle Game by Zenlio Technologies',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.65))),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.15)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text('Last updated: August 2026',
                                  style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.white
                                          .withValues(alpha: 0.6))),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Overview
                      _PolicySection(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primary,
                        title: 'Overview',
                        children: [
                          _PolicyText(
                            'Arrow Escape ("we", "us", or "our") is a casual puzzle game developed by Zenlio Technologies. This Privacy Policy explains what information is collected when you play Arrow Escape and how it is used.',
                          ),
                          const SizedBox(height: 8),
                          _PolicyText(
                            'We take your privacy seriously. We do not sell your personal data. By playing Arrow Escape you agree to the practices described in this policy.',
                          ),
                          const SizedBox(height: 12),
                          _PolicyInfoBox(
                            'Package ID: ${AppConstants.packageId}  ·  Platform: Android (Google Play)',
                          ),
                        ],
                      ),

                      // Data We Collect
                      _PolicySection(
                        icon: Icons.storage_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'Data We Collect',
                        children: [
                          _PolicyText(
                            'Arrow Escape itself does not collect, store, or transmit any personally identifiable information (PII). All game progress is stored locally on your device only.',
                            hasBoldParts: true,
                          ),
                          const SizedBox(height: 12),
                          _PolicyListItem(
                              'Game progress, level completion, and scores — stored locally'),
                          _PolicyListItem(
                              'Audio and haptic settings — stored locally on your device'),
                          _PolicyListItem(
                              'Daily play streak — stored locally on your device'),
                          const SizedBox(height: 10),
                          _PolicyText(
                            'Our advertising partners may collect certain data to serve relevant ads. See the Advertising section below.',
                          ),
                        ],
                      ),

                      // Analytics
                      _PolicySection(
                        icon: Icons.analytics_outlined,
                        iconColor: AppColors.primary,
                        title: 'Analytics',
                        children: [
                          _PolicyText(
                            'We use Firebase Analytics and Firebase Crashlytics to understand how players interact with the game and to identify and fix crashes. These services may collect:',
                          ),
                          const SizedBox(height: 12),
                          _PolicyListItem(
                              'App usage data (screens visited, features used)'),
                          _PolicyListItem(
                              'Device information (model, OS version)'),
                          _PolicyListItem(
                              'Crash logs and performance data'),
                          const SizedBox(height: 10),
                          _PolicyText(
                            'This data is anonymised and used solely to improve the game experience. No personally identifiable information is collected through analytics.',
                          ),
                          const SizedBox(height: 10),
                          _PolicyLinkItem(
                            label: 'Firebase Privacy Policy',
                            url: 'https://firebase.google.com/support/privacy',
                          ),
                        ],
                      ),

                      // Advertising
                      _PolicySection(
                        icon: Icons.campaign_outlined,
                        iconColor: AppColors.primaryLight,
                        title: 'Advertising & Third-Party SDKs',
                        children: [
                          _PolicyText(
                            'Arrow Escape is a free game supported by ads. The following ad networks may collect data to show relevant advertisements. Each operates under their own privacy policy.',
                          ),
                          const SizedBox(height: 14),

                          // AdMob
                          _AdPartnerCard(
                            initial: 'G',
                            color: const Color(0xFFF9AB00),
                            name: 'Google AdMob',
                            description:
                                'May collect device identifiers, IP address, and usage data to serve targeted ads.',
                            policyUrl:
                                'https://policies.google.com/privacy',
                          ),
                          const SizedBox(height: 10),

                          // Unity
                          _AdPartnerCard(
                            initial: 'U',
                            color: AppColors.primaryDark,
                            name: 'Unity Ads',
                            description:
                                'May collect device identifiers, gameplay data, and ad interaction data.',
                            policyUrl:
                                'https://unity.com/legal/privacy-policy',
                          ),

                          const SizedBox(height: 14),
                          _PolicyInfoBox(
                            'You can opt out of personalised ads via Android Settings → Privacy → Ads → Opt out of Ads Personalisation.',
                          ),
                        ],
                      ),

                      // Children's Privacy
                      _PolicySection(
                        icon: Icons.child_care_rounded,
                        iconColor: AppColors.primary,
                        title: "Children's Privacy",
                        children: [
                          _PolicyText(
                            'Arrow Escape is not directed at children under the age of 13. We do not knowingly collect personal information from children. Our ad partners are configured to serve non-personalised ads appropriate for a general audience.',
                          ),
                          const SizedBox(height: 8),
                          _PolicyText(
                            'If you are a parent or guardian and believe your child has provided us with personal information, please contact us so we can take appropriate action.',
                          ),
                        ],
                      ),

                      // App Permissions
                      _PolicySection(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'App Permissions',
                        children: [
                          _PolicyText(
                            'Arrow Escape requests only the following Android permissions:',
                          ),
                          const SizedBox(height: 12),
                          _PolicyListItem(
                              'INTERNET — Required to load advertisements and send analytics/crash data'),
                          _PolicyListItem(
                              'ACCESS_NETWORK_STATE — Allows SDKs to check connectivity before loading ads'),
                          const SizedBox(height: 10),
                          Text(
                            'No other permissions (camera, microphone, location, contacts, storage) are requested.',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.textMuted),
                          ),
                        ],
                      ),

                      // Data Sharing
                      _PolicySection(
                        icon: Icons.share_outlined,
                        iconColor: AppColors.primary,
                        title: 'Data Sharing',
                        children: [
                          _PolicyText(
                            'We do not sell, rent, or trade your personal information to any third party. Data may be shared only with:',
                          ),
                          const SizedBox(height: 12),
                          _PolicyListItem(
                              'Ad network partners (AdMob, Unity) solely to serve advertisements'),
                          _PolicyListItem(
                              'Firebase services for analytics and crash reporting'),
                          _PolicyListItem(
                              'Google Play Services for app distribution'),
                        ],
                      ),

                      // Your Rights
                      _PolicySection(
                        icon: Icons.gavel_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'Your Rights & Choices',
                        children: [
                          _PolicyListItem(
                              'Reset your Advertising ID via Android Settings → Privacy → Ads'),
                          _PolicyListItem(
                              'Opt out of personalised advertising via Android Ads settings'),
                          _PolicyListItem(
                              'Delete all local game data by uninstalling the app'),
                          _PolicyListItem(
                              'Contact us for information about data collected by our ad partners'),
                        ],
                      ),

                      // Changes to Policy
                      _PolicySection(
                        icon: Icons.update_rounded,
                        iconColor: AppColors.primary,
                        title: 'Changes to This Policy',
                        children: [
                          _PolicyText(
                            'We may update this Privacy Policy from time to time. Any changes will be reflected in this screen with an updated revision date. Continued use of Arrow Escape after changes constitutes acceptance of the updated policy.',
                          ),
                        ],
                      ),

                      // Contact Us
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('Contact Us',
                                style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            Text(
                              'Questions about this Privacy Policy? We are happy to help.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'support@zenliotechnologies.com',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            '© 2026 Zenlio Technologies  ·  Arrow Escape',
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _PolicySection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  final String text;
  final bool hasBoldParts;

  const _PolicyText(this.text, {this.hasBoldParts = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
          fontSize: 14,
          height: 1.6,
          color: AppColors.textSecondary),
    );
  }
}

class _PolicyListItem extends StatelessWidget {
  final String text;

  const _PolicyListItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _PolicyInfoBox extends StatelessWidget {
  final String text;

  const _PolicyInfoBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }
}

class _PolicyLinkItem extends StatelessWidget {
  final String label;
  final String url;

  const _PolicyLinkItem({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text('$label →',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      ],
    );
  }
}

class _AdPartnerCard extends StatelessWidget {
  final String initial;
  final Color color;
  final String name;
  final String description;
  final String policyUrl;

  const _AdPartnerCard({
    required this.initial,
    required this.color,
    required this.name,
    required this.description,
    required this.policyUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(initial,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(description,
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 5),
                Text('View Privacy Policy →',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
