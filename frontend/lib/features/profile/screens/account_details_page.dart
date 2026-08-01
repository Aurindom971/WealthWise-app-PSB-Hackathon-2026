import 'package:flutter/material.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../widgets/kyc_prompt_dialog.dart';
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

  final List<AccountInfo> _accounts = [
    AccountInfo(
      holder: 'Rajesh Sharma',
      number: '0012345678901234',
      type: 'Savings Account',
      branch: 'Connaught Place, New Delhi',
      ifsc: 'PSIB0000001',
      micr: '110023002',
      openingDate: '15 March 2019',
      nomination: 'Registered',
    ),
    AccountInfo(
      holder: 'Rajesh Sharma',
      number: '9876543210987654',
      type: 'Current Account',
      branch: 'Sector 17, Chandigarh',
      ifsc: 'PSIB0000204',
      micr: '160023005',
      openingDate: '22 September 2021',
      nomination: 'Registered',
    ),
    AccountInfo(
      holder: 'Rajesh Sharma',
      number: '5544332211009988',
      type: 'Salary Account',
      branch: 'Hitech City, Hyderabad',
      ifsc: 'PSIB0000456',
      micr: '500023012',
      openingDate: '10 January 2023',
      nomination: 'Not Registered',
    ),
  ];

  void _showDeleteAccountPasswordDialog() {
    final TextEditingController pwdController = TextEditingController();
    bool obscurePwd = true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: kSub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Bank Account (${_accounts[_selectedAccountIndex].type})',
                style: const TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Security Authentication Required: Enter your account password / PIN to authorize deleting this bank account profile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kSub, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pwdController,
                obscureText: obscurePwd,
                style: const TextStyle(color: kForest, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Account Password / PIN *',
                  hintText: 'Enter password',
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: kForest),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePwd ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: kSub,
                    ),
                    onPressed: () => setModalState(() => obscurePwd = !obscurePwd),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kSub),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: kSub, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (pwdController.text.trim().isEmpty) {
                          setModalState(() => errorText = 'Password is required');
                          return;
                        }
                        final deletedName = _accounts[_selectedAccountIndex].type;
                        Navigator.pop(ctx);
                        setState(() {
                          _accounts.removeAt(_selectedAccountIndex);
                          if (_selectedAccountIndex >= _accounts.length && _accounts.isNotEmpty) {
                            _selectedAccountIndex = _accounts.length - 1;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Row(
                              children: [
                                const Icon(Icons.delete_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Text('$deletedName Deleted Successfully'),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Confirm & Delete',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                child: Column(
                  children: [
                    Container(
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
                            decoration: BoxDecoration(
                              color: kCream.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedAccountIndex,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: kForest),
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 20),
                            label: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _showDeleteAccountPasswordDialog,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kForest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Add New Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              showKycPromptDialog(context, actionTitle: 'add a new bank account or user');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
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

