import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/forex_service.dart';

class ForexModal extends StatefulWidget {
  const ForexModal({super.key});

  @override
  State<ForexModal> createState() => _ForexModalState();
}

class _ForexModalState extends State<ForexModal> {
  final ForexService _forexService = ForexService();
  final TextEditingController _amountController = TextEditingController(text: '100');
  
  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  Map<String, dynamic>? _rates;
  bool _isLoading = true;
  String _toValue = '0.00';
  double _currentRate = 83.12;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _amountController.addListener(_updateConversion);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    try {
      final data = await _forexService.getLatestRates(fromCurrency);
      setState(() {
        _rates = data;
        _isLoading = false;
        _updateConversion();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch live rates. Using offline data.')),
        );
      }
    }
  }

  void _updateConversion() {
    if (_rates == null) return;
    
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final Map<String, dynamic> rateMap = _rates!['rates'];
    _currentRate = (rateMap[toCurrency] ?? 1.0).toDouble();
    
    setState(() {
      _toValue = (amount * _currentRate).toStringAsFixed(2);
    });
  }

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
            _buildCurrencyOption('USD', 'US Dollar', isFrom),
            _buildCurrencyOption('INR', 'Indian Rupee', isFrom),
            _buildCurrencyOption('EUR', 'Euro', isFrom),
            _buildCurrencyOption('GBP', 'British Pound', isFrom),
            _buildCurrencyOption('JPY', 'Japanese Yen', isFrom),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, bool isFrom) {
    return ListTile(
      title: Text(code, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      subtitle: Text(name, style: GoogleFonts.inter(fontSize: 12)),
      onTap: () {
        setState(() {
          if (isFrom) {
            fromCurrency = code;
            _fetchRates();
          } else {
            toCurrency = code;
            _updateConversion();
          }
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                    border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 $fromCurrency',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F5D3A),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2ECC71)),
                        )
                      else
                        const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2ECC71)),
                      Text(
                        '${_currentRate.toStringAsFixed(4)} $toCurrency',
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
                  isPrimary: true,
                  onCurrencyTap: () => _showCurrencyPicker(true),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCurrencyInput(
                  label: 'To',
                  currencyCode: toCurrency,
                  isPrimary: false,
                  onCurrencyTap: () => _showCurrencyPicker(false),
                  child: Text(
                    '$_toValue $toCurrency',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2ECC71),
                    ),
                  ),
                ),
                
                const SizedBox(height: 36),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    required String currencyCode,
    required bool isPrimary,
    required VoidCallback onCurrencyTap,
    required Widget child,
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
                child: child,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
