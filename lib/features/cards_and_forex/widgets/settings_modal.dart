import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../screens/otp_confirmation_screen.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool isDomestic = true;
  double atmValue = 0.25;
  double merchantValue = 0.2;
  double tapValue = 0.33;
  double onlineValue = 0.4;

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _formatAmount(double value, double max) {
    return formatter.format((value * max).toInt());
  }

  void _saveSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          title: 'Confirm Limits',
          onVerified: () {
            // Logic after verification
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card Settings',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Savings · •••• •••• 4821',
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          
          // Custom Toggle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF0E5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isDomestic = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDomestic ? const Color(0xFF2ECC71) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isDomestic ? [
                          BoxShadow(
                            color: const Color(0xFF2ECC71).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: Text(
                          'Domestic',
                          style: GoogleFonts.inter(
                            color: isDomestic ? Colors.white : const Color(0xFF1F5D3A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isDomestic = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isDomestic ? const Color(0xFF2ECC71) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: !isDomestic ? [
                          BoxShadow(
                            color: const Color(0xFF2ECC71).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: Text(
                          'International',
                          style: GoogleFonts.inter(
                            color: !isDomestic ? Colors.white : const Color(0xFF1F5D3A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSliderItem(
                  'ATM Withdrawal',
                  'Max ₹1,00,000/day',
                  _formatAmount(atmValue, 100000),
                  atmValue,
                  Icons.account_balance_wallet_outlined,
                  (val) => setState(() => atmValue = val),
                ),
                _buildSliderItem(
                  'Merchant Outlet',
                  'Max ₹5,00,000/day',
                  _formatAmount(merchantValue, 500000),
                  merchantValue,
                  Icons.storefront_outlined,
                  (val) => setState(() => merchantValue = val),
                ),
                _buildSliderItem(
                  'Contactless / Tap',
                  'Max ₹15,000/day',
                  _formatAmount(tapValue, 15000),
                  tapValue,
                  Icons.contactless_outlined,
                  (val) => setState(() => tapValue = val),
                ),
                _buildSliderItem(
                  'Online / E-commerce',
                  'Max ₹5,00,000/day',
                  _formatAmount(onlineValue, 500000),
                  onlineValue,
                  Icons.language_rounded,
                  (val) => setState(() => onlineValue = val),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Limits',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(String title, String subtitle, String amount, double value, IconData icon, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCF0E5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1F5D3A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF2ECC71),
              inactiveTrackColor: const Color(0xFFE8F5E9),
              thumbColor: Colors.white,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 5),
              overlayColor: const Color(0xFF2ECC71).withOpacity(0.1),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
