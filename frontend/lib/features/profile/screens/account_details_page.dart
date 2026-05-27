import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class AccountInfo {
  final String holder;
  final String number;
  final String type;
  final String branch;
  final String ifsc;
  final String micr;
  final String openingDate;
  final String nomination;

  const AccountInfo({
    required this.holder,
    required this.number,
    required this.type,
    required this.branch,
    required this.ifsc,
    required this.micr,
    required this.openingDate,
    required this.nomination,
  });
}

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  int _selectedAccountIndex = 0;

  final List<AccountInfo> _accounts = const [
    AccountInfo(
      holder: 'Rajesh Kumar',
      number: '0012345678901234',
      type: 'Savings Account',
      branch: 'Connaught Place, New Delhi',
      ifsc: 'PSIB0000001',
      micr: '110023002',
      openingDate: '15 March 2019',
      nomination: 'Registered',
    ),
    AccountInfo(
      holder: 'Rajesh Kumar',
      number: '9876543210987654',
      type: 'Current Account',
      branch: 'Sector 17, Chandigarh',
      ifsc: 'PSIB0000204',
      micr: '160023005',
      openingDate: '22 September 2021',
      nomination: 'Registered',
    ),
    AccountInfo(
      holder: 'Rajesh Kumar',
      number: '5544332211009988',
      type: 'Salary Account',
      branch: 'Hitech City, Hyderabad',
      ifsc: 'PSIB0000456',
      micr: '500023012',
      openingDate: '10 January 2023',
      nomination: 'Not Registered',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedAccount = _accounts[_selectedAccountIndex];

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Account Details",
              icon: Icons.description_outlined,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kMid.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedAccountIndex,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: kForest),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            style: const TextStyle(
                              color: kForest,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Savings Account (•••• 1234)'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('Current Account (•••• 7654)'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('Salary Account (•••• 9988)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedAccountIndex = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      _buildDivider(),
                      _buildRow('Account Holder', selectedAccount.holder),
                      _buildDivider(),
                      _buildRow('Account Number', selectedAccount.number),
                      _buildDivider(),
                      _buildRow('Account Type', selectedAccount.type),
                      _buildDivider(),
                      _buildRow('Branch', selectedAccount.branch),
                      _buildDivider(),
                      _buildRow('IFSC Code', selectedAccount.ifsc),
                      _buildDivider(),
                      _buildRow('MICR Code', selectedAccount.micr),
                      _buildDivider(),
                      _buildRow('Opening Date', selectedAccount.openingDate),
                      _buildDivider(),
                      _buildRow('Nomination', selectedAccount.nomination),
                    ],
                  ),
                ),
              ),
            ),
            BottomNav(
              currentIndex: -1,
              onTap: (i) =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: kForest,
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: kSub.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}

