import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class StatementModal extends StatefulWidget {
  final dynamic cardId;
  final dynamic accountId;
  final String? cusId;
  final String? last4;
  final String? cardType;

  const StatementModal({
    super.key,
    this.cardId,
    this.accountId,
    this.cusId,
    this.last4,
    this.cardType,
  });

  @override
  State<StatementModal> createState() => _StatementModalState();
}

class _StatementModalState extends State<StatementModal> {
  String selectedFY = 'FY 2024–25';
  String selectedFormat = 'PDF';
  DateTime? fromDate;
  DateTime? toDate;

  int _selectedAccountIndex = 0;
  final List<Map<String, String>> _accounts = const [
    {
      'name': 'Savings Account',
      'last4': '1234',
      'type': 'Savings',
      'number': '0012345678901234',
      'branch': 'Connaught Place, New Delhi',
      'ifsc': 'PSIB0000001',
    },
    {
      'name': 'Current Account',
      'last4': '7654',
      'type': 'Current',
      'number': '9876543210987654',
      'branch': 'Sector 17, Chandigarh',
      'ifsc': 'PSIB0000204',
    },
    {
      'name': 'Salary Account',
      'last4': '9988',
      'type': 'Salary',
      'number': '5544332211009988',
      'branch': 'Hitech City, Hyderabad',
      'ifsc': 'PSIB0000456',
    },
  ];

  bool _isAutoFetching = false;
  dynamic _cardId;
  String? _cusId;
  String? _last4;

  @override
  void initState() {
    super.initState();
    _cardId = widget.cardId;
    _cusId = widget.cusId;
    _last4 = widget.last4;

    if (_cardId == null) {
      _fetchPrimaryCard();
    }
  }

  Future<void> _fetchPrimaryCard() async {
    setState(() => _isAutoFetching = true);
    try {
      final supabase = Supabase.instance.client;
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) return;

      final response = await supabase.rpc(
        'get_cards_data',
        params: {'user_email': userEmail},
      );

      if (response != null &&
          response['cards'] != null &&
          (response['cards'] as List).isNotEmpty) {
        final primary = response['cards'][0];
        setState(() {
          _cardId = primary['card_id'];
          _cusId = primary['cus_id'];
          _last4 = primary['masked_number'].toString().split(' ').last;
        });
      }
    } catch (e) {
      debugPrint('Error auto-fetching card: $e');
    } finally {
      if (mounted) setState(() => _isAutoFetching = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D5B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F5D3A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTimeRange _getFYRange(String fyLabel) {
    // Standard Indian FY: April 1 to March 31
    if (fyLabel == 'FY 2024–25') {
      return DateTimeRange(
        start: DateTime(2024, 4, 1),
        end: DateTime(2025, 3, 31),
      );
    } else if (fyLabel == 'FY 2023–24') {
      return DateTimeRange(
        start: DateTime(2023, 4, 1),
        end: DateTime(2024, 3, 31),
      );
    } else {
      return DateTimeRange(
        start: DateTime(2022, 4, 1),
        end: DateTime(2023, 3, 31),
      );
    }
  }

  Future<void> _handleDownload() async {
    // Determine the actual date range
    DateTime start;
    DateTime end;

    if (fromDate != null && toDate != null) {
      start = fromDate!;
      end = toDate!;
    } else {
      final range = _getFYRange(selectedFY);
      start = range.start;
      end = range.end;
    }

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2E7D5B)),
              const SizedBox(height: 20),
              Text(
                'Generating $selectedFormat...',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final supabase = Supabase.instance.client;
      List transactions = [];

      if (_selectedAccountIndex == 0) {
        // Try DB fetch if details are available
        if (_cusId != null && _cardId != null) {
          try {
            final response = await supabase.rpc(
              'get_statement_transactions',
              params: {
                'p_cus_id': _cusId,
                'p_card_id': _cardId,
                'p_from_date': start.toIso8601String(),
                'p_to_date': end.toIso8601String(),
              },
            );
            transactions = response ?? [];
          } catch (e) {
            debugPrint('Error fetching db transactions: $e');
          }
        }
        
        // Fallback to mock savings transactions if DB returned nothing
        if (transactions.isEmpty) {
          transactions = [
            {
              'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
              'counterparty_name': 'Aman Sharma',
              'category': 'Transfer',
              'amount': 2000,
              'status': 'Success'
            },
            {
              'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'counterparty_name': 'Starbucks Coffee',
              'category': 'Food & Drinks',
              'amount': 350,
              'status': 'Success'
            },
            {
              'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
              'counterparty_name': 'HDFC Mutual Fund',
              'category': 'Investment',
              'amount': 5000,
              'status': 'Success'
            },
          ];
        }
      } else if (_selectedAccountIndex == 1) {
        // Current Account mock transactions
        transactions = [
          {
            'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'counterparty_name': 'Vendor A Services',
            'category': 'Business',
            'amount': 15000,
            'status': 'Success'
          },
          {
            'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
            'counterparty_name': 'Client Payment Co',
            'category': 'Income',
            'amount': 45000,
            'status': 'Success'
          },
          {
            'created_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
            'counterparty_name': 'Office Rent Ltd',
            'category': 'Rent',
            'amount': 25000,
            'status': 'Success'
          },
        ];
      } else {
        // Salary Account mock transactions
        transactions = [
          {
            'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
            'counterparty_name': 'TechCorp Salary',
            'category': 'Salary',
            'amount': 85000,
            'status': 'Success'
          },
          {
            'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            'counterparty_name': 'Supermarket Mall',
            'category': 'Groceries',
            'amount': 3200,
            'status': 'Success'
          },
          {
            'created_at': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
            'counterparty_name': 'Power Grid Corp',
            'category': 'Bills',
            'amount': 1850,
            'status': 'Success'
          },
        ];
      }

      String fileExt = selectedFormat == 'PDF' ? 'pdf' : 'csv';
      final accType = _accounts[_selectedAccountIndex]['type']?.toLowerCase() ?? 'account';
      final accLast4 = (_selectedAccountIndex == 0 && _last4 != null) ? _last4 : (_accounts[_selectedAccountIndex]['last4'] ?? 'xxxx');
      String fileName =
          'Statement_${accType}_${accLast4}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      String filePath = '';

      if (selectedFormat == 'PDF') {
        filePath = await _generatePDF(transactions, fileName, start, end);
      } else {
        filePath = await _generateCSV(transactions, fileName);
      }

      if (mounted) Navigator.pop(context); // Close progress dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$selectedFormat saved to Downloads/$fileName'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F5D3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate statement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _generatePDF(
    List txs,
    String fileName,
    DateTime start,
    DateTime end,
  ) async {
    // Load local font for standard chars + custom green color
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final primaryGreen = PdfColor.fromHex('#1F7A5A');

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    final df = DateFormat('dd MMM yyyy');
    final selectedAcc = _accounts[_selectedAccountIndex];
    final displayTitle = '${selectedAcc['name']} Statement';
    final accLast4 = (_selectedAccountIndex == 0 && _last4 != null) ? _last4 : (selectedAcc['last4'] ?? '----');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryGreen,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'WealthWise',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Account Statement',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context ctx) {
          return [
            pw.SizedBox(height: 20),
            pw.Text(
              displayTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Account Number: **** **** **** $accLast4',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Branch: ${selectedAcc['branch']}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'IFSC Code: ${selectedAcc['ifsc']}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Period: ${df.format(start)} to ${df.format(end)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellPadding: const pw.EdgeInsets.all(8),
              headers: ['Date', 'Counterparty', 'Category', 'Amount'],
              data: txs.map((t) {
                final date = DateTime.parse(t['created_at']).toLocal();
                return [
                  df.format(date),
                  t['counterparty_name'] ?? 'Unknown',
                  t['category'] ?? 'General',
                  '₹ ${t['amount']}',
                ];
              }).toList(),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {3: pw.Alignment.centerRight},
            ),

            pw.SizedBox(height: 32),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'This is a system-generated document from WealthWise. '
                'For any queries, please contact your branch or call our helpline.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (Platform.isAndroid) {
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      } catch (e) {
        debugPrint('Public download failed: $e');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Use printing as share fallback for iOS or failed direct writes
    await Printing.sharePdf(bytes: bytes, filename: fileName);

    return file.path;
  }

  Future<String> _generateCSV(List txs, String fileName) async {
    StringBuffer buffer = StringBuffer();
    final df = DateFormat('dd MMM yyyy');

    // Add Branded Title Row
    final selectedAcc = _accounts[_selectedAccountIndex];
    final title = '${selectedAcc['name']} Statement';
    final accLast4 = (_selectedAccountIndex == 0 && _last4 != null) ? _last4 : (selectedAcc['last4'] ?? '----');
    buffer.writeln('$title for Account No. **** $accLast4');
    buffer.writeln('Branch: ${selectedAcc['branch']}, IFSC Code: ${selectedAcc['ifsc']}');
    buffer.writeln(); // Empty row for spacing

    buffer.writeln('Date,Counterparty,Category,Amount,Status');

    for (var t in txs) {
      final date = DateTime.parse(t['created_at']).toLocal();
      buffer.writeln(
        '${df.format(date)},${t['counterparty_name']},${t['category']},${t['amount']},${t['status']}',
      );
    }

    final csvString = buffer.toString();

    if (Platform.isAndroid) {
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsString(csvString);
        return file.path;
      } catch (e) {
        debugPrint('Public download failed: $e');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvString);
    return file.path;
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
                      'Download Statement',
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
                if (_isAutoFetching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D5B),
                      ),
                    ),
                  )
                else ...[
                  Text(
                    '${_accounts[_selectedAccountIndex]['type']} · •••• •••• ${(_selectedAccountIndex == 0 && _last4 != null) ? _last4 : _accounts[_selectedAccountIndex]['last4']}',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Account',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedAccountIndex,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D5B)),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(_accounts.length, (i) {
                          final acc = _accounts[i];
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text('${acc['name']} (•••• ${acc['last4']})'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedAccountIndex = val;
                              _last4 = _accounts[val]['last4'];
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Financial Year',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFYTag('FY 2024–25'),
                      const SizedBox(width: 8),
                      _buildFYTag('FY 2023–24'),
                      const SizedBox(width: 8),
                      _buildFYTag('FY 2022–23'),
                    ],
                  ),

                  const SizedBox(height: 28),
                  Text(
                    'Or select date range',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          'From date',
                          fromDate,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePickerField(
                          'To date',
                          toDate,
                          () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  Text(
                    'Format',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormatOption(
                          'PDF',
                          Icons.picture_as_pdf_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFormatOption(
                          'Excel',
                          Icons.table_view_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFormatOption(
                          'CSV',
                          Icons.list_alt_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D5B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.file_download_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Download Statement',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFYTag(String label) {
    bool isSelected = selectedFY == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFY = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCF0E5) : const Color(0xFFF5F7F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D5B).withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF1F5D3A) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    String hint,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Text(
              date != null ? _formatDate(date) : hint,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(String label, IconData icon) {
    bool isSelected = selectedFormat == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFormat = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D5B) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D5B).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF1F5D3A),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : const Color(0xFF1F5D3A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
