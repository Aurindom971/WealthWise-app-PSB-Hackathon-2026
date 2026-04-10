import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForexModal extends StatefulWidget {
  const ForexModal({super.key});

  @override
  State<ForexModal> createState() => _ForexModalState();
}

class _ForexModalState extends State<ForexModal> {
  String fromCurrency = 'US USD';
  String toCurrency = 'IN INR';
  String fromValue = '100';
  String toValue = '8312.00 INR';

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Currency',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCurrencyOption('US USD', isFrom),
            _buildCurrencyOption('IN INR', isFrom),
            _buildCurrencyOption('EU EUR', isFrom),
            _buildCurrencyOption('GB GBP', isFrom),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, bool isFrom) {
    return ListTile(
      title: Text(code, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() {
          if (isFrom) {
            fromCurrency = code;
          } else {
            toCurrency = code;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forex & Exchange',
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
            'Convert currencies at live rates',
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          
          // Live rate banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 USD',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F5D3A),
                  ),
                ),
                const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2ECC71)),
                Text(
                  '83.1200 INR',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _buildCurrencyInput(
            label: 'From',
            currencyCode: fromCurrency,
            value: fromValue,
            isPrimary: true,
            onCurrencyTap: () => _showCurrencyPicker(true),
          ),
          const SizedBox(height: 20),
          _buildCurrencyInput(
            label: 'To',
            currencyCode: toCurrency,
            value: toValue,
            isPrimary: false,
            onCurrencyTap: () => _showCurrencyPicker(false),
          ),
          
          const SizedBox(height: 36),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              child: Text(
                'Convert Currency',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    required String currencyCode,
    required String value,
    required bool isPrimary,
    required VoidCallback onCurrencyTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: onCurrencyTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF0E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      currencyCode,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F5D3A),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF1F5D3A)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isPrimary ? Colors.black87 : const Color(0xFF2ECC71),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
