import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  static const _primary = Color(0xFF1F5D3A);
  static const _primaryLight = Color(0xFF2E7D5B);

  @override
  Widget build(BuildContext context) {
    final rules = <_Rule>[
      _Rule(Icons.vpn_key_rounded, "Never Share Your PIN / OTP",
          "Bank officials will NEVER ask for your PIN, password, CVV or OTP — over call, SMS, email or in person."),
      _Rule(Icons.visibility_off_rounded, "Beware of Phishing Links",
          "Do not click suspicious links claiming to be from PSB. Always type psbindia.com directly in your browser."),
      _Rule(Icons.warning_amber_rounded, "Report Fraud Immediately",
          "If you suspect unauthorised activity, call 1800-419-8300 or dial 1930 (National Cyber Helpline) right away."),
      _Rule(Icons.wifi_off_rounded, "Avoid Public Wi-Fi",
          "Never log in to your account on public/unsecured Wi-Fi networks. Use mobile data or a trusted connection."),
      _Rule(Icons.smartphone_rounded, "Keep Your App Updated",
          "Always install the latest version of the PSB app from official stores. Enable screen lock on your device."),
      _Rule(Icons.verified_user_rounded, "Verify Before You Transact",
          "Double-check beneficiary details before transferring money. Once sent, transfers are usually irreversible."),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F1),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_primary, _primaryLight]),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Safety Rules",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text("Your security is our priority",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // BODY
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  // Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_primary, _primaryLight]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield_rounded,
                            color: Colors.white, size: 32),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Stay Safe, Stay Secure",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 4),
                              Text(
                                  "Follow these guidelines to protect your account",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...rules.map((r) => _RuleCard(rule: r)),
                  const SizedBox(height: 8),
                  // Cyber helpline
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tel:1930')),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CYBER FRAUD HELPLINE",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red.shade800,
                                  letterSpacing: 0.6)),
                          const SizedBox(height: 4),
                          Text("1930",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.shade800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rule {
  final IconData icon;
  final String title;
  final String text;
  _Rule(this.icon, this.title, this.text);
}

class _RuleCard extends StatelessWidget {
  final _Rule rule;
  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F5D3A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(rule.icon,
                color: const Color(0xFF1F5D3A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(rule.text,
                    style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}