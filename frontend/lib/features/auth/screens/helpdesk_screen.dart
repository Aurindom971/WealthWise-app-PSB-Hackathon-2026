import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  static const _primary = Color(0xFF1F5D3A);
  static const _primaryLight = Color(0xFF2E7D5B);

  Future<void> _launch(BuildContext context, String uri) async {
    final ok = await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final channels = <_Channel>[
      _Channel(Icons.phone_in_talk_rounded, 'Toll-Free (24×7)', '1800-419-8300', 'tel:18004198300'),
      _Channel(Icons.support_agent_rounded, 'Customer Care', '1800-221-908', 'tel:1800221908'),
      _Channel(Icons.email_rounded, 'Email Support', 'customercare@psb.co.in', 'mailto:customercare@psb.co.in'),
      _Channel(Icons.chat_rounded, 'WhatsApp Banking', '+91-7039035156', 'https://wa.me/917039035156'),
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        Text("Help Desk",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text("We're here to help — 24×7",
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
                  ...channels.map((c) => _ChannelCard(
                        channel: c,
                        onTap: () => _launch(context, c.uri),
                      )),
                  const SizedBox(height: 8),
                  // Branch Hours
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time_rounded,
                                size: 18, color: _primary),
                            SizedBox(width: 8),
                            Text("Branch Hours",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _primary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Mon – Fri: 10:00 AM – 4:00 PM\n"
                          "Saturday (1st, 3rd, 5th): 10:00 AM – 2:00 PM\n"
                          "Sunday & Public Holidays: Closed",
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Head Office
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: _primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Head Office",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 4),
                              Text(
                                "Bank House, 21, Rajendra Place,\nNew Delhi – 110008, India",
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _Channel {
  final IconData icon;
  final String title;
  final String value;
  final String uri;
  _Channel(this.icon, this.title, this.value, this.uri);
}

class _ChannelCard extends StatelessWidget {
  final _Channel channel;
  final VoidCallback onTap;
  const _ChannelCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F5D3A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(channel.icon,
                      color: const Color(0xFF1F5D3A), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channel.title.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                              letterSpacing: 0.6)),
                      const SizedBox(height: 4),
                      Text(channel.value,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}