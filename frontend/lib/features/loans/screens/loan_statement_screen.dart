import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../widgets/loan_header.dart';

class LoanStatementScreen extends StatefulWidget {
  final String loanType;
  final String loanId;
  final VoidCallback onBack;

  const LoanStatementScreen({
    super.key,
    required this.loanType,
    required this.loanId,
    required this.onBack,
  });

  @override
  State<LoanStatementScreen> createState() => _LoanStatementScreenState();
}

class _LoanStatementScreenState extends State<LoanStatementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _loanInfo;
  List<dynamic> _schedule = [];
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchStatementData();
  }

  Future<void> _fetchStatementData() async {
    try {
      final response = await _supabase.rpc(
        'get_loan_statement_details',
        params: {'p_loan_id': widget.loanId},
      );

      if (response != null) {
        setState(() {
          _loanInfo = response['loan_info'];
          _schedule = (response['schedule'] ?? []).reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching loan statement: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(dynamic value) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return format.format(value ?? 0);
  }

  String _formatDate(String dateStr, {bool short = false}) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat(short ? 'MMM yyyy' : 'd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (_loanInfo == null) return;

    final info = _loanInfo!;
    final paidCount = info['emis_paid'] ?? 0;
    final totalCount = info['total_emis'] ?? 1;
    final progress = (paidCount / totalCount).toDouble();
    final principalPaid =
        (info['disbursed_amount'] ?? 0) - (info['outstanding_amount'] ?? 0);
    final totalPaid = paidCount * (info['emi_amount'] ?? 0);
    final interestPaid = (totalPaid - principalPaid).isNegative
        ? 0.0
        : (totalPaid - principalPaid);

    // Load Unicode-compatible font for ₹ symbol
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1F7A5A'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SecureWealth',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Loan Statement',
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
              widget.loanType,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Loan ID: ${widget.loanId}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Loan Details
            _pdfDetailRow(
              'Principal Amount',
              _formatCurrency(info['principal_amount']),
            ),
            _pdfDetailRow(
              'Outstanding Amount',
              _formatCurrency(info['outstanding_amount']),
            ),
            _pdfDetailRow('Monthly EMI', _formatCurrency(info['emi_amount'])),
            _pdfDetailRow('Interest Rate', '${info['interest_rate']}% p.a.'),
            _pdfDetailRow('Tenure', '${info['tenure_months']} months'),
            _pdfDetailRow(
              'Disbursed Amount',
              _formatCurrency(info['disbursed_amount']),
            ),
            _pdfDetailRow(
              'Start Date',
              _formatDate(info['start_date'] ?? '', short: true),
            ),
            _pdfDetailRow(
              'Next Due Date',
              _formatDate(info['next_due_date'] ?? ''),
            ),
            _pdfDetailRow('EMIs Paid', '$paidCount of $totalCount'),
            _pdfDetailRow('Status', 'On Time'),

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Repayment Summary
            pw.Text(
              'Repayment Summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            _pdfDetailRow('Principal Paid', _formatCurrency(principalPaid)),
            _pdfDetailRow('Interest Paid', _formatCurrency(interestPaid)),
            _pdfDetailRow('EMIs Remaining', '${totalCount - paidCount}'),
            _pdfDetailRow('Progress', '${(progress * 100).toInt()}%'),

            pw.SizedBox(height: 8),
            pw.Container(
              height: 12,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey200,
              ),
              child: pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Container(
                  width: (450 * progress).toDouble(),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    color: PdfColor.fromHex('#245C3F'),
                  ),
                ),
              ),
            ),

            // EMI Schedule
            if (_schedule.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Text(
                'EMI Schedule',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: [
                  'Due Date',
                  'Principal',
                  'Interest',
                  'Balance',
                  'Status',
                ],
                data: _schedule
                    .map(
                      (item) => [
                        _formatDate(item['due_date'] ?? '', short: true),
                        _formatCurrency(item['principal_component']),
                        _formatCurrency(item['interest_component']),
                        _formatCurrency(item['remaining_balance']),
                        (item['status'] ?? 'pending')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase() +
                            (item['status'] ?? 'pending').toString().substring(
                              1,
                            ),
                      ],
                    )
                    .toList(),
              ),
            ],

            pw.SizedBox(height: 32),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'This is a system-generated document from SecureWealth. '
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

    final pdfBytes = await pdf.save();
    final cleanLoanId = widget.loanId.replaceAll('-', '_');
    final fileName = 'Loan_Statement_${cleanLoanId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    try {
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        debugPrint('Loan statement saved to: ${file.path}');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        debugPrint('Loan statement saved to: ${file.path}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statement saved to Downloads/$fileName'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F5D3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade800,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  static pw.Widget _pdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kCream,
        body: const Center(child: CircularProgressIndicator(color: kMid)),
      );
    }

    if (_loanInfo == null) {
      return Scaffold(
        backgroundColor: kCream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: kSub),
              const SizedBox(height: 16),
              const Text(
                'Statement not found',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final paidCount = _loanInfo!['emis_paid'] ?? 0;
    final totalCount = _loanInfo!['total_emis'] ?? 1;
    final emiAmount = _loanInfo!['emi_amount'] ?? 0;

    final progress = (paidCount / totalCount).toDouble();
    final remainingEmis = totalCount - paidCount;

    // Principal Paid = Disbursed - Outstanding
    final principalPaid =
        (_loanInfo!['disbursed_amount'] ?? 0) -
        (_loanInfo!['outstanding_amount'] ?? 0);

    // Total Paid = EMIs Paid * EMI Amount
    final totalPaid = paidCount * emiAmount;
    final interestPaid = (totalPaid - principalPaid).isNegative
        ? 0.0
        : (totalPaid - principalPaid);

    return Column(
      children: [
        LoanHeader(
          title: 'Loan Statement',
          subtitle: widget.loanType,
          icon: Icons.file_download_outlined,
          actionLabel: 'Download',
          onBack: widget.onBack,
          onIconTap: () => _generateAndSharePdf(),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        label: 'Outstanding',
                        value: _formatCurrency(
                          _loanInfo!['outstanding_amount'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryBox(
                        label: 'Monthly EMI',
                        value: _formatCurrency(_loanInfo!['emi_amount']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Repayment Progress Card
                const _SectionHeader(title: 'Repayment Progress'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$paidCount of $totalCount EMIs paid',
                            style: const TextStyle(
                              color: Color(0xFF1F5D3A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: kInk,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFF2F0EB),
                          color: const Color(0xFF1F5D3A),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniSummary(
                              label: 'Principal Paid',
                              value: _formatCurrency(principalPaid),
                            ),
                          ),
                          Expanded(
                            child: _MiniSummary(
                              label: 'Interest Paid',
                              value: _formatCurrency(interestPaid),
                            ),
                          ),
                          Expanded(
                            child: _MiniSummary(
                              label: 'EMIs Left',
                              value: remainingEmis.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Loan Details Card
                const _SectionHeader(title: 'Loan Details'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Principal Amount',
                        value: _formatCurrency(_loanInfo!['principal_amount']),
                      ),
                      _DetailRow(
                        label: 'Interest Rate',
                        value: '${_loanInfo!['interest_rate']}% p.a.',
                      ),
                      _DetailRow(
                        label: 'Tenure',
                        value: '${_loanInfo!['tenure_months']} months',
                      ),
                      _DetailRow(
                        label: 'Disbursed',
                        value: _formatCurrency(_loanInfo!['disbursed_amount']),
                      ),
                      _DetailRow(
                        label: 'Start Date',
                        value: _formatDate(
                          _loanInfo!['start_date'],
                          short: true,
                        ),
                      ),
                      _DetailRow(
                        label: 'Next Due Date',
                        value: _formatDate(_loanInfo!['next_due_date']),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // EMI Schedule Section
                const _SectionHeader(title: 'EMI Schedule'),
                if (_schedule.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "No schedule available",
                        style: TextStyle(color: kSub),
                      ),
                    ),
                  )
                else
                  ..._schedule.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isLast = entry.key == _schedule.length - 1;
                    return _ScheduleItem(
                      date: _formatDate(item['due_date'], short: true),
                      principal: _formatCurrency(item['principal_component']),
                      interest: _formatCurrency(item['interest_component']),
                      balance: _formatCurrency(item['remaining_balance']),
                      status:
                          item['status'][0].toUpperCase() +
                          item['status'].substring(1),
                      isLast: isLast,
                    );
                  }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kInk,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: kInk,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final String value;
  const _MiniSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kSub,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: kInk,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: kInk,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String date;
  final String principal;
  final String interest;
  final String balance;
  final String status;
  final bool isLast;

  const _ScheduleItem({
    required this.date,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.status,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    final bool isPending = status.toLowerCase() == 'pending';
    final Color statusColor = isPending
        ? const Color(0xFFFFA940)
        : const Color(0xFF1F5D3A);
    final Color statusBg = isPending
        ? const Color(0xFFFFF7E6)
        : const Color(0xFFEAF6F0);
    final IconData statusIcon = isPending
        ? Icons.access_time_filled_rounded
        : Icons.check;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 14),
              ),
              const SizedBox(width: 12),
              Text(
                date,
                style: const TextStyle(
                  color: kInk,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniScheduleBox(label: 'Principal', value: principal),
              _MiniScheduleBox(label: 'Interest', value: interest),
              _MiniScheduleBox(label: 'Balance', value: balance, isEnd: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniScheduleBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isEnd;
  const _MiniScheduleBox({
    required this.label,
    required this.value,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kSub,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: kInk,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
