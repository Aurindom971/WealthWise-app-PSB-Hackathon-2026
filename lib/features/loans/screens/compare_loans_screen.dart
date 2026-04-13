import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/loan_header.dart';
import 'apply_loan_screen.dart';

class CompareLoansScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String) onApply;
  const CompareLoansScreen({super.key, required this.onBack, required this.onApply});

  @override
  State<CompareLoansScreen> createState() => _CompareLoansScreenState();
}

class _CompareLoansScreenState extends State<CompareLoansScreen> {
  final List<String> _allLoanTypes = ['Personal Loan', 'Home Loan', 'Education Loan', 'Car Loan'];
  final List<String> _selectedTypes = ['Personal Loan', 'Home Loan'];

  void _toggleSelection(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        if (_selectedTypes.length > 1) {
          _selectedTypes.remove(type);
        }
      } else {
        if (_selectedTypes.length < 3) {
          _selectedTypes.add(type);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoanHeader(
          title: 'Compare Loans',
          subtitle: 'Best rates and terms',
          icon: Icons.compare_arrows_rounded,
          onBack: widget.onBack,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.compare_arrows, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compare Loans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Find the best option for you',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select up to 3 loan types to compare',
                  style: TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildSelectionChips(),
                const SizedBox(height: 32),
                _buildComparisonTable(),
                const SizedBox(height: 40),
                const Text(
                  'Which loan is best for you?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kInk),
                ),
                const SizedBox(height: 16),
                ..._allLoanTypes.map((type) => _buildRecommendationCard(type)),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSelectionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allLoanTypes.map((type) {
        final isSelected = _selectedTypes.contains(type);
        return GestureDetector(
          onTap: () => _toggleSelection(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? kMid : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? kMid : const Color(0xFFDEDBD2)),
              boxShadow: isSelected
                  ? [BoxShadow(color: kMid.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : kSub,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAF5F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 16,
            columnSpacing: 24,
            headingRowHeight: 50,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 48,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF5F0)),
            border: TableBorder(
              horizontalInside: BorderSide(color: const Color(0xFFF2F0EB), width: 1),
              verticalInside: BorderSide(color: const Color(0xFFF2F0EB).withValues(alpha: 0.5), width: 1),
            ),
            columns: [
              const DataColumn(label: Text('Feature', style: TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.bold))),
              ..._selectedTypes.map((type) => DataColumn(
                label: Text(
                  type.replaceAll(' Loan', ''),
                  style: const TextStyle(color: Color(0xFF1F7A5A), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              )),
            ],
            rows: [
              _buildDataRow('Interest Rate', (type) => _getLoanData(type).interestRate),
              _buildDataRow('Max Amount', (type) => _getLoanData(type).maxAmount),
              _buildDataRow('Tenure', (type) => _getLoanData(type).tenure),
              _buildDataRow('Processing Fee', (type) => _getLoanData(type).fee),
              _buildDataRow('Prepayment', (type) => _getLoanData(type).prepayment),
              _buildDataRow('Collateral', (type) => _getLoanData(type).collateral),
              _buildDataRow('Approval Time', (type) => _getLoanData(type).approvalTime),
              _buildDataRow('EMI (₹5L, 5yr)', (type) => _getLoanData(type).estEmi),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String feature, String Function(String) getValue) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(color: kSub, fontSize: 12))),
        ..._selectedTypes.map((type) => DataCell(
          Text(
            getValue(type),
            style: const TextStyle(color: kInk, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  Widget _buildRecommendationCard(String type) {
    final data = _getLoanData(type);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2F0EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kMid)),
          const SizedBox(height: 6),
          Text(data.recommendation, style: const TextStyle(fontSize: 13, color: kSub, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A47),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('Apply for $type', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  _LoanComparisonData _getLoanData(String type) {
    switch (type) {
      case 'Personal Loan':
        return _LoanComparisonData(
          interestRate: '10.5%',
          maxAmount: '₹15 Lakh',
          tenure: '1-5 yrs',
          fee: '1-2%',
          prepayment: 'Yes (after 6mo)',
          collateral: 'No',
          approvalTime: '24 hrs',
          estEmi: '₹8,850',
          recommendation: 'Best for quick funds without collateral. Ideal for emergencies, weddings, or travel.',
        );
      case 'Home Loan':
        return _LoanComparisonData(
          interestRate: '8.5%',
          maxAmount: '₹1 Cr',
          tenure: '5-30 yrs',
          fee: '0.5-1%',
          prepayment: 'Yes',
          collateral: 'Yes',
          approvalTime: '7-10 days',
          estEmi: '₹7,689',
          recommendation: 'Best for purchasing property with the lowest interest rates and longest tenure.',
        );
      case 'Education Loan':
        return _LoanComparisonData(
          interestRate: '9.0%',
          maxAmount: '₹20 Lakh',
          tenure: '5-15 yrs',
          fee: '0%',
          prepayment: 'Yes',
          collateral: 'Upto 7.5L No',
          approvalTime: '5-7 days',
          estEmi: '₹8,052',
          recommendation: 'Ideal for financing higher studies with moratorium period and tax benefits.',
        );
      case 'Car Loan':
        return _LoanComparisonData(
          interestRate: '9.5%',
          maxAmount: '₹15 Lakh',
          tenure: '1-7 yrs',
          fee: '0.5%',
          prepayment: 'Yes',
          collateral: 'Yes',
          approvalTime: '48 hrs',
          estEmi: '₹8,350',
          recommendation: 'Best for your dream vehicle with quick processing and minimal documentation.',
        );
      default:
        return _LoanComparisonData(
          interestRate: '-', maxAmount: '-', tenure: '-', fee: '-', prepayment: '-', collateral: '-', approvalTime: '-', estEmi: '-', recommendation: '',
        );
    }
  }
}

class _LoanComparisonData {
  final String interestRate;
  final String maxAmount;
  final String tenure;
  final String fee;
  final String prepayment;
  final String collateral;
  final String approvalTime;
  final String estEmi;
  final String recommendation;

  _LoanComparisonData({
    required this.interestRate,
    required this.maxAmount,
    required this.tenure,
    required this.fee,
    required this.prepayment,
    required this.collateral,
    required this.approvalTime,
    required this.estEmi,
    required this.recommendation,
  });
}
