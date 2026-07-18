import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/otp_confirmation_screen.dart';
import '../../../services/local_db_service.dart';

class SettingsModal extends StatefulWidget {
  final int cardId;
  final bool initialDomestic;
  final bool initialDomesticEnabled;
  final bool initialInternationalEnabled;
  final double initialAtm;
  final double initialMerchant;
  final double initialTap;
  final double initialOnline;
  final double initialUpi;
  final String last4;
  final Future<void> Function()? onSaved;

  const SettingsModal({
    super.key,
    required this.cardId,
    this.initialDomestic = true,
    this.initialDomesticEnabled = true,
    this.initialInternationalEnabled = false,
    this.initialAtm = 0.25,
    this.initialMerchant = 0.2,
    this.initialTap = 0.33,
    this.initialOnline = 0.4,
    this.initialUpi = 1.0,
    required this.last4,
    this.onSaved,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool isDomestic;
  late bool isDomesticActive;
  late bool isInternationalActive;
  late double atmValue;
  late double merchantValue;
  late double tapValue;
  late double onlineValue;
  late double upiValue;

  @override
  void initState() {
    super.initState();
    isDomestic = widget.initialDomestic;
    isDomesticActive = widget.initialDomesticEnabled;
    isInternationalActive = widget.initialInternationalEnabled;
    atmValue = widget.initialAtm;
    merchantValue = widget.initialMerchant;
    tapValue = widget.initialTap;
    onlineValue = widget.initialOnline;
    upiValue = widget.initialUpi;
    _loadUpiLimit();
  }

  Future<void> _loadUpiLimit() async {
    final settings = await LocalDbService.getSettings('upi_limit_setting');
    if (settings != null && settings['upi_slider'] != null) {
      if (mounted) {
        setState(() => upiValue = (settings['upi_slider'] as num).toDouble());
      }
    }
  }

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _formatAmount(double value, double max) {
    return formatter.format((value * max).toInt());
  }

  Future<void> _saveSettings() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.rpc('update_card_settings', params: {
        'id_card': widget.cardId,
        'is_dom_on': isDomesticActive,
        'is_intl_on': isInternationalActive,
        'lim_atm': (atmValue * 100000).toInt(),
        'lim_merch': (merchantValue * 500000).toInt(),
        'lim_tap': (tapValue * 15000).toInt(),
        'lim_online': (onlineValue * 500000).toInt(),
      });

      // Persist UPI limit locally
      await LocalDbService.saveSettings('upi_limit_setting', {
        'upi_slider': upiValue,
        'upi_max_amount': (upiValue * 100000).toInt(),
      });

      if (mounted) {
        await widget.onSaved?.call(); // Wait for data to refresh in parent
        if (mounted) {
          Navigator.pop(context); // Close settings AFTER refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card settings updated!'),
              backgroundColor: Color(0xFF2E7D5B),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
            'Savings · •••• •••• ${widget.last4}',
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
                        color: isDomestic ? const Color(0xFF2E7D5B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isDomestic ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D5B).withValues(alpha: 0.3),
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
                        color: !isDomestic ? const Color(0xFF2E7D5B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: !isDomestic ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D5B).withValues(alpha: 0.3),
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
          
          // Return the toggle to the "Page" level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (isDomestic ? isDomesticActive : isInternationalActive) 
                ? const Color(0xFFDCF0E5).withValues(alpha: 0.5)
                : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable ${isDomestic ? 'Domestic' : 'International'} Transactions',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: (isDomestic ? isDomesticActive : isInternationalActive) 
                      ? const Color(0xFF1A1A1A) 
                      : Colors.red.shade900,
                  ),
                ),
                Switch.adaptive(
                  value: isDomestic ? isDomesticActive : isInternationalActive,
                  activeColor: const Color(0xFF2E7D5B),
                  onChanged: (val) {
                    setState(() {
                      if (isDomestic) {
                        isDomesticActive = val;
                      } else {
                        isInternationalActive = val;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
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
                _buildSliderItem(
                  'UPI Payments',
                  'Max ₹1,00,000/day',
                  _formatAmount(upiValue, 100000),
                  upiValue,
                  Icons.account_balance_outlined,
                  (val) => setState(() => upiValue = val),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D5B),
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

  Widget _buildToggleItem(String title, String subtitle, bool isActive, Function(bool) onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCF0E5).withValues(alpha: 0.3) : Colors.red.shade50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Colors.transparent : Colors.red.shade100),
      ),
      child: SwitchListTile.adaptive(
        secondary: Icon(icon, color: isActive ? const Color(0xFF1F5D3A) : Colors.red, size: 22),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? const Color(0xFF1A1A1A) : Colors.red.shade900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
        ),
        value: isActive,
        activeColor: const Color(0xFF2E7D5B),
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
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
            color: Colors.black.withValues(alpha: 0.02),
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
                  color: const Color(0xFF2E7D5B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF2E7D5B),
              inactiveTrackColor: const Color(0xFFE8F5E9),
              thumbColor: Colors.white,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 5),
              overlayColor: const Color(0xFF2E7D5B).withValues(alpha: 0.1),
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
