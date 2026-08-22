import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/screens/notifications_screen.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../../services/security_service.dart';
import '../../../core/utils/security_validator.dart';
import '../../../core/services/panic_mode_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../services/local_db_service.dart';
import '../../../providers/auth_provider.dart';

const primaryGreen = kForest;
const lightGreen = kAccent;

//////////////////// DUMMY DATA ////////////////////

const List<String> allBanks = [
  "State Bank of India (SBI)",
  "HDFC Bank",
  "ICICI Bank",
  "Axis Bank",
  "Punjab National Bank",
  "Bank of Baroda",
  "Canara Bank",
  "Union Bank of India",
  "Bank of India",
  "Kotak Mahindra Bank",
];

const List<String> transferPurposes = [
  "Rent",
  "Medical",
  "Education",
  "Family Support",
  "Investment",
  "Loan Repayment",
  "Utilities",
  "Other",
];

List<String> userAccounts = [
  "Savings - 1234567890",
  "Current - 9876543210",
  "Salary - 5566778899",
  "Joint Account - 1122334455",
  "Investment - 9988776655",
  "Overdraft - 1020304050",
  "Tax Saver - 4455667788",
  "Child Savings - 3344556677",
];

List<String> upiContacts = ["rahul@upi", "amit@upi", "priya@upi"];

void _handleGlobalHomeTap(BuildContext context) {
  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
}

void _handleGlobalBottomNavTap(BuildContext context, int i) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/home',
    (route) => false,
    arguments: {'index': i},
  );
}

Future<void> _handleGlobalLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Logout',
        style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to log out of your secure session?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: kSub)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

//////////////////// DYNAMIC COLOR UTILS ////////////////////

Color? getDynamicAmountColor(String amountStr) {
  final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
  if (amount <= 1000) return null;
  if (amount <= 5000) {
    return Color.lerp(
      const Color(0xFF2E7D5B),
      Colors.amber.shade700,
      (amount - 1000) / 4000,
    );
  } else if (amount <= 20000) {
    return Color.lerp(
      Colors.amber.shade700,
      Colors.red.shade700,
      (amount - 5000) / 15000,
    );
  } else if (amount <= 50000) {
    return Color.lerp(
      Colors.red.shade700,
      const Color(0xFF800020),
      (amount - 20000) / 30000,
    );
  } else {
    return const Color(0xFF800020);
  }
}

Widget buildDynamicEdgeHue(Color? dynamicColor) {
  if (dynamicColor == null) return const SizedBox.shrink();

  const topBottomSize = 42.0;
  const sideSize = 35.0; // left/right strip width
  final hue = dynamicColor.withValues(
    alpha: 0.22,
  ); // much lighter – no dark shadow feel

  return Positioned.fill(
    child: IgnorePointer(
      child: Stack(
        children: [
          // Top edge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topBottomSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [hue, Colors.transparent],
                ),
              ),
            ),
          ),
          // Bottom edge
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: topBottomSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [hue, Colors.transparent],
                ),
              ),
            ),
          ),
          // Left edge – half the width
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: sideSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [hue, Colors.transparent],
                ),
              ),
            ),
          ),
          // Right edge – half the width
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: sideSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [hue, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildRiskyWarning(String amountStr) {
  final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
  if (amount <= 20000) return const SizedBox.shrink();
  return const Expanded(
    child: Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text(
        "* this transaction will require biometric verification",
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

void showTransactionRiskLegend(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Transaction Risk Levels',
        style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem(
            const Color(0xFF2E7D5B),
            'Green',
            'safe transaction',
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            Colors.amber.shade700,
            'Amber',
            'moderate risk transaction',
          ),
          const SizedBox(height: 12),
          _buildLegendItem(Colors.red.shade700, 'Red', 'risky transaction'),
          const SizedBox(height: 12),
          _buildLegendItem(
            const Color(0xFF800020),
            'Wine Red',
            'high risk transaction',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Close',
            style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

Widget _buildLegendItem(Color color, String label, String description) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                text: '$label = ',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              TextSpan(
                text: description,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

//////////////////// MAIN SCREEN ////////////////////

class SendTransferScreen extends StatelessWidget {
  const SendTransferScreen({super.key});

  Widget _buildOptionRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget screen, {
    Future<bool> Function()? lockCheck,
    String? lockMessage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            height: 1.3,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: kForest.withValues(alpha: 0.3),
          size: 16,
        ),
        onTap: () async {
          if (lockCheck != null && await lockCheck()) {
            _showSecurityLockToast(context, message: lockMessage);
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream, // Extremely light grey/mint background
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => _handleGlobalBottomNavTap(context, i),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Unified Global Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: TopBar(
                  onHomeTap: () => _handleGlobalHomeTap(context),
                  onLogoutTap: () => _handleGlobalLogout(context),
                  onNotificationTap: () => showNotifications(context),
                ),
              ),

              // New Send Money Tab (LoanHeader Style)
              LoanHeader(
                title: "",
                subtitle: "Send Money",
                icon: Icons.send_rounded,
                onBack: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),

              // Option Menu Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildOptionRow(
                      context,
                      "Bank to Bank Transfer",
                      "Transfer funds to any bank\naccount",
                      Icons.swap_horiz,
                      const BankTransferScreen(),
                      lockCheck: SecurityService.isOnlineLockActive,
                      lockMessage:
                          'Online Transactions are currently blocked by Smart Lock.',
                    ),
                    _buildOptionRow(
                      context,
                      "Self Transfer",
                      "Transfer between your own\naccounts",
                      Icons.sync,
                      const SelfTransferScreen(),
                      lockCheck: SecurityService.isOnlineLockActive,
                      lockMessage:
                          'Online Transactions are currently blocked by Smart Lock.',
                    ),
                    _buildOptionRow(
                      context,
                      "UPI Pays",
                      "Pay via UPI ID or QR code",
                      Icons.phone_android,
                      const UpiScreen(),
                      lockCheck: SecurityService.isUpiLockActive,
                      lockMessage:
                          'UPI Payments are currently blocked by Smart Lock.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// DROPDOWN & INPUT FIELDS ////////////////////

Widget dropdownField(
  String hint,
  List<String> items,
  String? value,
  Function(String?) onChanged,
) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: primaryGreen),
    ),
    child: DropdownButton<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      underline: const SizedBox(),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Center(child: Text(e)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );
}

Widget inputField(
  String hint, {
  TextEditingController? controller,
  int? maxLength,
  List<TextInputFormatter>? inputFormatters,
  Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      keyboardType: hint.toLowerCase().contains("amount")
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

//////////////////// CUSTOM FORM FIELDS ////////////////////

class SearchableDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final Function(String) onChanged;
  final bool showSearch;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.showSearch = true,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final GlobalKey _key = GlobalKey();

  void _showDropdown() {
    if (_key.currentContext != null) {
      FocusScope.of(_key.currentContext!).unfocus();
    }
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return _DropdownDialog(
          offset: offset,
          size: size,
          items: widget.items,
          showSearch: widget.showSearch,
          onSelected: (val) {
            widget.onChanged(val);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          key: _key,
          onTap: _showDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? widget.hint,
                    style: TextStyle(
                      color: widget.value == null
                          ? Colors.grey.shade500
                          : Colors.black87,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownDialog extends StatefulWidget {
  final Offset offset;
  final Size size;
  final List<String> items;
  final Function(String) onSelected;
  final bool showSearch;

  const _DropdownDialog({
    required this.offset,
    required this.size,
    required this.items,
    required this.onSelected,
    required this.showSearch,
  });

  @override
  State<_DropdownDialog> createState() => _DropdownDialogState();
}

class _DropdownDialogState extends State<_DropdownDialog> {
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((e) => e.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final mediaQuery = MediaQuery.of(context);
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double screenHeight = mediaQuery.size.height;

    double dropdownHeight = 280.0;
    double topPos = widget.offset.dy + widget.size.height + 4;

    // Adjust position and height dynamically so everything fits in screen and is scrollable
    if (topPos + dropdownHeight > screenHeight - keyboardHeight - 20) {
      double spaceBelow = screenHeight - keyboardHeight - topPos - 20;
      double spaceAbove = widget.offset.dy - mediaQuery.padding.top - 20;

      if (spaceAbove > spaceBelow && spaceAbove > 150) {
        // Show above
        topPos = widget.offset.dy - dropdownHeight - 4;
        if (topPos < mediaQuery.padding.top + 20) {
          topPos = mediaQuery.padding.top + 20;
          dropdownHeight = widget.offset.dy - topPos - 4;
        }
      } else {
        // Show below but shrink
        dropdownHeight = spaceBelow > 150 ? spaceBelow : 150;
        if (keyboardHeight > 0 && spaceBelow < 100) {
          // Move it up if keyboard is too tall
          topPos = screenHeight - keyboardHeight - dropdownHeight - 20;
          if (topPos < mediaQuery.padding.top + 20) {
            topPos = mediaQuery.padding.top + 20;
          }
        }
      }
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.transparent),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: widget.offset.dx,
          top: topPos,
          width: widget.size.width,
          child: Material(
            color: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: dropdownHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSearch)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  Flexible(
                    child: Scrollbar(
                      controller: _scrollController,
                      thickness: 4,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => widget.onSelected(filtered[index]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: widget.showSearch
                                  ? Text(
                                      filtered[index],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Rajesh Kumar",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          filtered[index],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget customBankInput(
  String label,
  String hint, {
  bool isNumber = false,
  bool enabled = true,
  TextEditingController? controller,
  int? maxLength,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: [
            if (isNumber) FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            if (label.toLowerCase().contains("name"))
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    ),
  );
}

//////////////////// BANK TRANSFER ////////////////////

class BankTransferScreen extends StatefulWidget {
  final String? toAccount;
  final String? toIfsc;
  final String? toNominee;
  final String? amount;
  final String? toBank;
  final String? purpose;
  final String? otherPurpose;
  final String? fromAccount;

  const BankTransferScreen({
    super.key,
    this.toAccount,
    this.toIfsc,
    this.toNominee,
    this.amount,
    this.toBank,
    this.purpose,
    this.otherPurpose,
    this.fromAccount,
  });

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  String? fromAccount;
  String? toBank;
  String? transferPurpose;

  final TextEditingController _fromAccController = TextEditingController();
  final TextEditingController _fromIfscController = TextEditingController();
  final TextEditingController _fromNomineeController = TextEditingController();

  final TextEditingController _toAccountController = TextEditingController();
  final TextEditingController _toIfscController = TextEditingController();
  final TextEditingController _toNomineeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otherPurposeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    if (widget.toAccount != null) _toAccountController.text = widget.toAccount!;
    if (widget.toIfsc != null) _toIfscController.text = widget.toIfsc!;
    if (widget.toNominee != null) _toNomineeController.text = widget.toNominee!;
    if (widget.amount != null) _amountController.text = widget.amount!;
    if (widget.toBank != null) toBank = widget.toBank!;
    if (widget.purpose != null) transferPurpose = widget.purpose!;
    if (widget.otherPurpose != null)
      _otherPurposeController.text = widget.otherPurpose!;
    if (widget.fromAccount != null) {
      fromAccount = widget.fromAccount;
      _fromAccController.text = widget.fromAccount!.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      _fromIfscController.text = "PSIB0001234";
      _fromNomineeController.text = "Rajesh Kumar";
    }
  }

  @override
  void dispose() {
    _fromAccController.dispose();
    _fromIfscController.dispose();
    _fromNomineeController.dispose();
    _toAccountController.dispose();
    _toIfscController.dispose();
    _toNomineeController.dispose();
    _amountController.dispose();
    _otherPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamicColor = getDynamicAmountColor(_amountController.text);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kCream,
        bottomNavigationBar: BottomNav(
          currentIndex: -1,
          onTap: (i) => _handleGlobalBottomNavTap(context, i),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: TopBar(
                      onHomeTap: () => _handleGlobalHomeTap(context),
                      onLogoutTap: () => _handleGlobalLogout(context),
                      onNotificationTap: () => showNotifications(context),
                    ),
                  ),
                  LoanHeader(
                    title: "Bank Transfer",
                    subtitle: "Send Money",
                    icon: Icons.swap_horiz,
                    onBack: () => Navigator.pop(context),
                    onInfoTap: () => showTransactionRiskLegend(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // FROM Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: kAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "FROM:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SearchableDropdown(
                                  label: "Select Account",
                                  hint: "Select PSB Account",
                                  items: userAccounts,
                                  value: fromAccount,
                                  showSearch: false,
                                  onChanged: (val) {
                                    setState(() {
                                      fromAccount = val;
                                      // Auto-fill FROM Mock Data
                                      _fromAccController.text = val.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      );
                                      _fromIfscController.text = "PSIB0001234";
                                      _fromNomineeController.text =
                                          "Rajesh Kumar";
                                    });
                                  },
                                ),
                                customBankInput(
                                  "Account No.",
                                  "Account Number",
                                  enabled: false,
                                  controller: _fromAccController,
                                ),
                                customBankInput(
                                  "IFSC Code",
                                  "e.g. PSIB0000001",
                                  enabled: false,
                                  controller: _fromIfscController,
                                ),
                                customBankInput(
                                  "Nominee Name",
                                  "Account Holder Name",
                                  enabled: false,
                                  controller: _fromNomineeController,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TO Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: kMid,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "TO:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SearchableDropdown(
                                  label: "Select Bank",
                                  hint: "Search and select bank",
                                  items: allBanks,
                                  value: toBank,
                                  showSearch: true,
                                  onChanged: (val) {
                                    setState(() {
                                      toBank = val;
                                    });
                                  },
                                ),
                                customBankInput(
                                  "Account No.",
                                  "Recipient Account Number",
                                  isNumber: true,
                                  controller: _toAccountController,
                                  maxLength: 16,
                                ),
                                customBankInput(
                                  "IFSC Code",
                                  "e.g. SBIN0001234",
                                  controller: _toIfscController,
                                  maxLength: 11,
                                ),
                                customBankInput(
                                  "Nominee Name",
                                  "Recipient Name",
                                  controller: _toNomineeController,
                                  maxLength: 50,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // PURPOSE Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: kForest,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "PURPOSE:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SearchableDropdown(
                                  label: "Select Purpose",
                                  hint: "Search and select purpose",
                                  items: transferPurposes,
                                  value: transferPurpose,
                                  showSearch: true,
                                  onChanged: (val) {
                                    setState(() {
                                      transferPurpose = val;
                                      if (val != "Other") {
                                        _otherPurposeController.clear();
                                      }
                                    });
                                  },
                                ),
                                if (transferPurpose == "Other")
                                  customBankInput(
                                    "Specify Purpose",
                                    "Enter your reason",
                                    controller: _otherPurposeController,
                                    maxLength: 100,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // AMOUNT Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: kAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "AMOUNT",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    buildRiskyWarning(_amountController.text),
                                  ],
                                ),
                                customBankInput(
                                  "Enter Amount (₹)",
                                  "0.00",
                                  isNumber: true,
                                  controller: _amountController,
                                  maxLength: 12,
                                ),
                              ],
                            ),
                          ), // closes Container
                        ],
                      ),
                    ),
                  ),
                ], // closes Column children
              ), // closes Column
              buildDynamicEdgeHue(dynamicColor),
            ], // closes Stack children
          ), // closes Stack
        ), // closes SafeArea
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dynamicColor != null
                    ? [dynamicColor, dynamicColor.withValues(alpha: 0.8)]
                    : [kForest, kMid],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (dynamicColor ?? kForest).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (await SecurityService.isOnlineLockActive()) {
                  _showSecurityLockToast(
                    context,
                    message:
                        'Online Transactions are currently blocked by Smart Lock.',
                  );
                  return;
                }

                if (fromAccount == null ||
                    toBank == null ||
                    transferPurpose == null ||
                    (transferPurpose == "Other" &&
                        _otherPurposeController.text.trim().isEmpty) ||
                    _toAccountController.text.trim().isEmpty ||
                    _toIfscController.text.trim().isEmpty ||
                    _toNomineeController.text.trim().isEmpty ||
                    _amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all compulsory details!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 2. Sanitize and Validate
                final sanitizedRecipient = SecurityValidator.sanitize(
                  _toNomineeController.text,
                );
                final sanitizedAccount = SecurityValidator.sanitize(
                  _toAccountController.text,
                );
                final sanitizedIFSC = SecurityValidator.sanitize(
                  _toIfscController.text,
                ).toUpperCase();
                final rawAmount = _amountController.text.replaceAll(',', '');

                if (!SecurityValidator.isValidAmount(rawAmount)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid amount entered.")),
                  );
                  return;
                }

                if (!SecurityValidator.isValidAccountNumber(sanitizedAccount)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid account number format."),
                    ),
                  );
                  return;
                }

                // 3. Payload Check
                final payload = {
                  "from": fromAccount,
                  "to": sanitizedAccount,
                  "ifsc": sanitizedIFSC,
                  "recipient": sanitizedRecipient,
                  "amount": rawAmount,
                  "purpose": transferPurpose,
                };

                if (!SecurityValidator.inspectPayload(payload)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("SECURITY: Payload rejected."),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PinScreen(
                      recipientName: sanitizedRecipient,
                      amount: rawAmount,
                    ),
                  ),
                );
              },
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////// SELF TRANSFER ////////////////////

class SelfTransferScreen extends StatefulWidget {
  const SelfTransferScreen({super.key});

  @override
  State<SelfTransferScreen> createState() => _SelfTransferScreenState();
}

class _SelfTransferScreenState extends State<SelfTransferScreen> {
  String? fromAccount;
  String? toAccount;
  String? transferPurpose;

  final TextEditingController _fromAccController = TextEditingController();
  final TextEditingController _fromIfscController = TextEditingController();
  final TextEditingController _fromNomineeController = TextEditingController();

  final TextEditingController _toAccController = TextEditingController();
  final TextEditingController _toIfscController = TextEditingController();
  final TextEditingController _toNomineeController = TextEditingController();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otherPurposeController = TextEditingController();

  @override
  void dispose() {
    _fromAccController.dispose();
    _fromIfscController.dispose();
    _fromNomineeController.dispose();
    _toAccController.dispose();
    _toIfscController.dispose();
    _toNomineeController.dispose();
    _amountController.dispose();
    _otherPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kCream,
        bottomNavigationBar: BottomNav(
          currentIndex: -1,
          onTap: (i) => _handleGlobalBottomNavTap(context, i),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: TopBar(
                  onHomeTap: () => _handleGlobalHomeTap(context),
                  onLogoutTap: () => _handleGlobalLogout(context),
                  onNotificationTap: () => showNotifications(context),
                ),
              ),
              LoanHeader(
                title: "Self Transfer",
                subtitle: "Send Money",
                icon: Icons.sync,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // FROM Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: kAccent,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "FROM:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SearchableDropdown(
                              label: "Select Account",
                              hint: "Select PSB Account",
                              items: userAccounts,
                              value: fromAccount,
                              showSearch: false,
                              onChanged: (val) {
                                setState(() {
                                  fromAccount = val;
                                  if (toAccount == val) {
                                    toAccount = null;
                                    _toAccController.clear();
                                    _toIfscController.clear();
                                    _toNomineeController.clear();
                                  }
                                  _fromAccController.text = val.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  _fromIfscController.text = "PSIB0001234";
                                  _fromNomineeController.text = "Rajesh Kumar";
                                });
                              },
                            ),
                            customBankInput(
                              "Account No.",
                              "Account Number",
                              enabled: false,
                              controller: _fromAccController,
                            ),
                            customBankInput(
                              "IFSC Code",
                              "e.g. PSIB0000001",
                              enabled: false,
                              controller: _fromIfscController,
                            ),
                            customBankInput(
                              "Nominee Name",
                              "Account Holder Name",
                              enabled: false,
                              controller: _fromNomineeController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TO Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 10, color: kMid),
                                const SizedBox(width: 8),
                                const Text(
                                  "TO:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SearchableDropdown(
                              label: "Select Account",
                              hint: "Select Your Account",
                              items: userAccounts
                                  .where((acc) => acc != fromAccount)
                                  .toList(),
                              value: toAccount,
                              showSearch: false,
                              onChanged: (val) {
                                setState(() {
                                  toAccount = val;
                                  // For self transfer, the TO account is automatically filled too!
                                  _toAccController.text = val.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  _toIfscController.text = "PSIB0001234";
                                  _toNomineeController.text = "Rajesh Kumar";
                                });
                              },
                            ),
                            customBankInput(
                              "Account No.",
                              "Recipient Account Number",
                              isNumber: true,
                              enabled: false,
                              controller: _toAccController,
                            ),
                            customBankInput(
                              "IFSC Code",
                              "e.g. PSIB0001234",
                              enabled: false,
                              controller: _toIfscController,
                            ),
                            customBankInput(
                              "Nominee Name",
                              "Recipient Name",
                              enabled: false,
                              controller: _toNomineeController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PURPOSE Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: kForest,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "PURPOSE:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SearchableDropdown(
                              label: "Select Purpose",
                              hint: "Search and select purpose",
                              items: transferPurposes,
                              value: transferPurpose,
                              showSearch: true,
                              onChanged: (val) {
                                setState(() {
                                  transferPurpose = val;
                                  if (val != "Other") {
                                    _otherPurposeController.clear();
                                  }
                                });
                              },
                            ),
                            if (transferPurpose == "Other")
                              customBankInput(
                                "Specify Purpose",
                                "Enter your reason",
                                controller: _otherPurposeController,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // AMOUNT Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: kAccent,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "AMOUNT",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            customBankInput(
                              "Enter Amount (₹)",
                              "0.00",
                              isNumber: true,
                              controller: _amountController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kForest, kMid],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kForest.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (await SecurityService.isOnlineLockActive()) {
                  _showSecurityLockToast(
                    context,
                    message:
                        'Online Transactions are currently blocked by Smart Lock.',
                  );
                  return;
                }
                if (fromAccount == null ||
                    toAccount == null ||
                    transferPurpose == null ||
                    (transferPurpose == "Other" &&
                        _otherPurposeController.text.trim().isEmpty) ||
                    _toAccController.text.trim().isEmpty ||
                    _amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all compulsory details!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (fromAccount == toAccount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Cannot transfer from and to the same account!",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PinScreen(
                      recipientName: _toNomineeController.text,
                      amount: _amountController.text,
                    ),
                  ),
                );
              },
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////// UPI ////////////////////

bool globalContactsPermissionGranted = false;
bool globalCameraPermissionGranted = false;

void showMyQrCode(BuildContext context) {
  final String myUpiId =
      "aurindom@psb"; // Random string per user instruction or dummy
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "My QR Code",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Scan to pay me",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: "upi://pay?pa=$myUpiId&pn=User&cu=INR",
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black87,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "My UPI ID",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  myUpiId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: myUpiId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("UPI ID copied to clipboard"),
                        backgroundColor: kForest,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, color: kForest, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}

class UpiScreen extends StatefulWidget {
  final String? prefilledUpiId;
  final String? prefilledAmount;

  const UpiScreen({super.key, this.prefilledUpiId, this.prefilledAmount});

  @override
  State<UpiScreen> createState() => _UpiScreenState();
}

class _UpiScreenState extends State<UpiScreen> {
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final ScrollController _contactsScrollController = ScrollController();

  Map<String, String> _contactTags = {};
  String _selectedSection = "All";
  List<String> _sections = ["All", "Favourites", "Family"];

  Future<void> _loadTags() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tagged_contacts.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> decoded = json.decode(content);
        setState(() {
          if (decoded.containsKey('tags')) {
            _contactTags = decoded['tags'].cast<String, String>();
          } else {
            _contactTags = decoded.cast<String, String>();
          }
          if (decoded.containsKey('sections')) {
            _sections = decoded['sections'].cast<String>();
            if (!_sections.contains("All")) _sections.insert(0, "All");
            if (!_sections.contains("Favourites")) _sections.add("Favourites");
            if (!_sections.contains("Family")) _sections.add("Family");
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  Future<void> _saveTags() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tagged_contacts.json');
      await file.writeAsString(
        json.encode({'tags': _contactTags, 'sections': _sections}),
      );
    } catch (e) {
      debugPrint("Error saving tags: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _loadTags();
    if (widget.prefilledUpiId != null) {
      _upiIdController.text = widget.prefilledUpiId!;
    }
    if (widget.prefilledAmount != null) {
      _amountController.text = widget.prefilledAmount!;
    }
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _contactsScrollController.dispose();
    super.dispose();
  }

  bool _showContacts = globalContactsPermissionGranted;

  final List<Map<String, String>> _mockContacts = [
    {"name": "Aman Gupta", "upi": "aman@ybl"},
    {"name": "Neha Verma", "upi": "neha.verma@paytm"},
    {"name": "Suresh Patel", "upi": "suresh123@oksbi"},
    {"name": "Pooja Trivedi", "upi": "pooja.t@ybl"},
    {"name": "Rahul Deshmukh", "upi": "rahul.d@oksbi"},
    {"name": "Kavita Rao", "upi": "kavita.rao@paytm"},
    {"name": "Vikram Singh", "upi": "vikram.s@oksbi"},
    {"name": "Ananya Sharma", "upi": "ananya@ybl"},
    {"name": "Rohan Mehta", "upi": "rohan.m@paytm"},
    {"name": "Sneha Reddy", "upi": "sneha.r@oksbi"},
    {"name": "Arjun Nair", "upi": "arjun.n@ybl"},
    {"name": "Deepa Joshi", "upi": "deepa.j@paytm"},
  ];

  void _requestContactsPermission() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Permission Required",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Allow WealthWise to access your contacts to easily find and pay your friends?",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Deny", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                globalContactsPermissionGranted = true;
                _showContacts = true;
              });
            },
            child: const Text(
              "Allow",
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagContactDialog() {
    String? selectedContactUpi = _mockContacts.first['upi'];
    String selectedTag = "Favourite";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                "Tag Contact",
                style: TextStyle(fontWeight: FontWeight.bold, color: kForest),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Contact:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: selectedContactUpi,
                    isExpanded: true,
                    items: _mockContacts.map((contact) {
                      return DropdownMenuItem<String>(
                        value: contact['upi'],
                        child: Text("${contact['name']} (${contact['upi']})"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedContactUpi = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tag As:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: selectedTag,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "Favourite",
                        child: Text("Favourite"),
                      ),
                      DropdownMenuItem(value: "Family", child: Text("Family")),
                      DropdownMenuItem(
                        value: "None",
                        child: Text("Remove Tag"),
                      ),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedTag = val!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedContactUpi != null) {
                      setState(() {
                        if (selectedTag == "None") {
                          _contactTags.remove(selectedContactUpi);
                        } else {
                          _contactTags[selectedContactUpi!] = selectedTag;
                        }
                      });
                      _saveTags();
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kForest),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNewSectionDialog() {
    final TextEditingController sectionNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Create New List",
            style: TextStyle(fontWeight: FontWeight.bold, color: kForest),
          ),
          content: TextField(
            controller: sectionNameController,
            decoration: const InputDecoration(
              hintText: "Enter list name (e.g. Work, Friends)",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = sectionNameController.text.trim();
                if (name.isNotEmpty) {
                  if (!_sections.contains(name)) {
                    setState(() {
                      _sections.add(name);
                      _selectedSection = name;
                    });
                    _saveTags();
                  }
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kForest),
              child: const Text(
                "Create",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showManageContactsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 280),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          height: 20,
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        ..._mockContacts.map((contact) {
          final String currentTag = _contactTags[contact["upi"]] ?? "";
          final isTagged =
              (currentTag == _selectedSection) ||
              (_selectedSection == "Favourites" && currentTag == "Favourite") ||
              (_selectedSection == "Family" && currentTag == "Family");
          return PopupMenuItem<String>(
            value: contact["upi"],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${contact["name"]} (${contact["upi"]})",
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isTagged)
                  const Icon(Icons.check_circle, color: kForest, size: 18)
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                    size: 18,
                  ),
              ],
            ),
          );
        }),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          final String currentTag = _contactTags[value] ?? "";
          final isTagged =
              (currentTag == _selectedSection) ||
              (_selectedSection == "Favourites" && currentTag == "Favourite") ||
              (_selectedSection == "Family" && currentTag == "Family");
          if (isTagged) {
            _contactTags.remove(value);
          } else {
            // Save the canonical tag. For Favourite/Family, map to the singular form used by the existing dialog
            if (_selectedSection == "Favourites") {
              _contactTags[value] = "Favourite";
            } else {
              _contactTags[value] = _selectedSection;
            }
          }
        });
        _saveTags();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamicColor = getDynamicAmountColor(_amountController.text);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kCream,
        bottomNavigationBar: BottomNav(
          currentIndex: -1,
          onTap: (i) => _handleGlobalBottomNavTap(context, i),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: TopBar(
                      onHomeTap: () => _handleGlobalHomeTap(context),
                      onLogoutTap: () => _handleGlobalLogout(context),
                      onNotificationTap: () => showNotifications(context),
                    ),
                  ),

                  LoanHeader(
                    title: "UPI Pays",
                    subtitle: "Send Money",
                    icon: Icons.qr_code_2,
                    actionLabel: "My QR",
                    onBack: () => Navigator.pop(context),
                    onIconTap: () => showMyQrCode(context),
                    onInfoTap: () => showTransactionRiskLegend(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // QR Scanner Entry
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QRScreen(),
                                ),
                              );
                              if (result != null && result is String) {
                                setState(() {
                                  _upiIdController.text = result;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: kForest,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Scan QR",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Scan QR code to pay",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Input Form
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "UPI ID",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _upiIdController,
                                  maxLength: 50,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "example@ybl",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: kForest,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text(
                                      "Amount (₹)",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    buildRiskyWarning(_amountController.text),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _amountController,
                                  focusNode: _amountFocusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 12,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "0.00",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: kForest,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Contacts Section
                          if (!_showContacts)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _requestContactsPermission,
                                icon: const Icon(
                                  Icons.people_outline,
                                  color: kForest,
                                ),
                                label: const Text(
                                  "Show UPI Contacts",
                                  style: TextStyle(
                                    color: kForest,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "UPI CONTACTS",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ..._sections.map((section) {
                                          final isSelected =
                                              _selectedSection == section;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: ChoiceChip(
                                              label: Text(
                                                section,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                if (selected) {
                                                  setState(() {
                                                    _selectedSection = section;
                                                  });
                                                }
                                              },
                                              selectedColor: kForest,
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              checkmarkColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              side: BorderSide(
                                                color: isSelected
                                                    ? kForest
                                                    : Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: kForest,
                                            size: 20,
                                          ),
                                          onPressed: _showAddNewSectionDialog,
                                          tooltip: "Add New List",
                                          constraints: const BoxConstraints(),
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade50,
                                            padding: const EdgeInsets.all(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 300,
                                    child: Scrollbar(
                                      controller: _contactsScrollController,
                                      thickness: 4,
                                      thumbVisibility: true,
                                      child: Builder(
                                        builder: (context) {
                                          final filteredContacts = _mockContacts
                                              .where((contact) {
                                                if (_selectedSection == "All")
                                                  return true;
                                                final tag =
                                                    _contactTags[contact["upi"]];
                                                if (tag == _selectedSection)
                                                  return true;
                                                if (_selectedSection ==
                                                        "Favourites" &&
                                                    tag == "Favourite")
                                                  return true;
                                                if (_selectedSection ==
                                                        "Family" &&
                                                    tag == "Family")
                                                  return true;
                                                return false;
                                              })
                                              .toList();

                                          if (filteredContacts.isEmpty) {
                                            return Center(
                                              child: Text(
                                                "No contacts in $_selectedSection",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }

                                          return ListView.builder(
                                            controller:
                                                _contactsScrollController,
                                            itemCount: filteredContacts.length,
                                            itemBuilder: (context, index) {
                                              final contact =
                                                  filteredContacts[index];
                                              final isSelected =
                                                  _upiIdController.text ==
                                                  contact["upi"];
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _upiIdController.text =
                                                        contact["upi"]!;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    bottom: 10,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.grey.shade100
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.grey.shade300
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 45,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  kMid,
                                                                  kForest,
                                                                ],
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                              ),
                                                            ),
                                                        child: Center(
                                                          child: Text(
                                                            contact["name"]![0]
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    contact["name"]!,
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                if (_contactTags
                                                                    .containsKey(
                                                                      contact["upi"],
                                                                    )) ...[
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          _contactTags[contact["upi"]] ==
                                                                              "Favourite"
                                                                          ? Colors.orange.shade50
                                                                          : _contactTags[contact["upi"]] ==
                                                                                "Family"
                                                                          ? Colors.blue.shade50
                                                                          : Colors.green.shade50,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            6,
                                                                          ),
                                                                      border: Border.all(
                                                                        color:
                                                                            _contactTags[contact["upi"]] ==
                                                                                "Favourite"
                                                                            ? Colors.orange.shade300
                                                                            : _contactTags[contact["upi"]] ==
                                                                                  "Family"
                                                                            ? Colors.blue.shade300
                                                                            : Colors.green.shade300,
                                                                        width:
                                                                            0.5,
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      _contactTags[contact["upi"]]!,
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            _contactTags[contact["upi"]] ==
                                                                                "Favourite"
                                                                            ? Colors.orange.shade700
                                                                            : _contactTags[contact["upi"]] ==
                                                                                  "Family"
                                                                            ? Colors.blue.shade700
                                                                            : Colors.green.shade700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              contact["upi"]!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_selectedSection != "All") ...[
                                    const SizedBox(height: 12),
                                    Builder(
                                      builder: (btnCtx) {
                                        return Align(
                                          alignment: Alignment.center,
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ManageSectionScreen(
                                                    sectionName:
                                                        _selectedSection,
                                                    sections: _sections,
                                                    contactTags: _contactTags,
                                                    mockContacts: _mockContacts,
                                                    onUpdate:
                                                        (
                                                          updatedTags,
                                                          updatedSections,
                                                          currentSection,
                                                        ) {
                                                          setState(() {
                                                            _contactTags =
                                                                updatedTags;
                                                            _sections =
                                                                updatedSections;
                                                            _selectedSection =
                                                                currentSection;
                                                          });
                                                          _saveTags();
                                                        },
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.settings,
                                              size: 16,
                                              color: kForest,
                                            ),
                                            label: const Text(
                                              "Manage",
                                              style: TextStyle(
                                                color: kForest,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              side: const BorderSide(
                                                color: kForest,
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 32),
                          // Pay Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: dynamicColor != null
                                    ? [
                                        dynamicColor,
                                        dynamicColor.withValues(alpha: 0.8),
                                      ]
                                    : [kForest, kMid],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (dynamicColor ?? kForest).withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (await SecurityService.isUpiLockActive()) {
                                  _showSecurityLockToast(
                                    context,
                                    message:
                                        'UPI Payments are currently blocked by Smart Lock.',
                                  );
                                  return;
                                }
                                if (_amountController.text.trim().isEmpty ||
                                    _upiIdController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter UPI ID and Amount",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // 2. Sanitize and Validate
                                final sanitizedUpi = SecurityValidator.sanitize(
                                  _upiIdController.text,
                                );
                                final rawAmount = _amountController.text
                                    .replaceAll(',', '');

                                // Check daily UPI limit (user-configurable via Card Settings)
                                // Scope by cus_id so each customer has independent limits
                                final currentCusId = AuthProvider.instance.currentUser?['cus_id'] ?? 'default';
                                final todayStr = DateTime.now().toIso8601String().substring(0, 10);
                                final dailySettings = await LocalDbService.getSettings('upi_daily_limit_$currentCusId') ?? {};
                                final dailyTotal = (dailySettings[todayStr] as num?)?.toDouble() ?? 0.0;
                                final currentAmount = double.tryParse(rawAmount) ?? 0.0;

                                // Read configured max from Card Settings slider (default 1 Lakh)
                                final upiLimitSettings = await LocalDbService.getSettings('upi_limit_setting_$currentCusId');
                                final upiMaxLimit = (upiLimitSettings != null && upiLimitSettings['upi_max_amount'] != null)
                                    ? (upiLimitSettings['upi_max_amount'] as num).toDouble()
                                    : 100000.0;

                                if (dailyTotal + currentAmount > upiMaxLimit) {
                                  final remaining = (upiMaxLimit - dailyTotal).clamp(0, upiMaxLimit);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Daily UPI limit exceeded! Max ₹${upiMaxLimit.toStringAsFixed(0)}/day. Remaining: ₹${remaining.toStringAsFixed(0)}",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (!SecurityValidator.isValidAmount(
                                  rawAmount,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid amount entered."),
                                    ),
                                  );
                                  return;
                                }

                                // 3. Payload Check
                                final payload = {
                                  "upi_id": sanitizedUpi,
                                  "amount": rawAmount,
                                };

                                if (!SecurityValidator.inspectPayload(
                                  payload,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "SECURITY: Payload rejected.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PinScreen(
                                      recipientName: sanitizedUpi.isNotEmpty
                                          ? sanitizedUpi
                                                .split('@')
                                                .first
                                                .toUpperCase()
                                          : "VERIFIED PERSON",
                                      upiId: sanitizedUpi,
                                      amount: rawAmount,
                                      isUpi: true,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _amountController.text.isEmpty
                                    ? "Pay ₹0.00"
                                    : "Pay ₹${_amountController.text}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ], // closes Column children
              ), // closes Column
              buildDynamicEdgeHue(dynamicColor),
            ], // closes Stack children
          ), // closes Stack
        ), // closes SafeArea
      ),
    );
  }
}

//////////////////// QR ////////////////////

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool _permissionGranted = globalCameraPermissionGranted;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    if (!_permissionGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestCameraPermission();
      });
    }
  }

  void _requestCameraPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Camera Permission Required",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Allow WealthWise to take pictures and record video to scan QR codes?",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Deny", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                globalCameraPermissionGranted = true;
                _permissionGranted = true;
              });
            },
            child: const Text(
              "Allow",
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => _handleGlobalBottomNavTap(context, i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () => _handleGlobalHomeTap(context),
                onLogoutTap: () => _handleGlobalLogout(context),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "Scan QR Code",
              subtitle: "UPI Pays",
              icon: Icons.qr_code_2,
              actionLabel: "My QR",
              onBack: () => Navigator.pop(context),
              onIconTap: () => showMyQrCode(context),
            ),
            Expanded(
              child: _permissionGranted
                  ? Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 400, // Slightly reduced to fit other elements
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.grey.shade900,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: MobileScanner(
                                  onDetect: (capture) {
                                    if (_isScanned) return;
                                    final List<Barcode> barcodes =
                                        capture.barcodes;
                                    if (barcodes.isNotEmpty &&
                                        barcodes.first.rawValue != null) {
                                      _isScanned = true;
                                      if (!mounted) return;
                                      Navigator.pop(
                                        context,
                                        barcodes.first.rawValue,
                                      );
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green.shade500,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Point your camera at the QR code",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Enter UPI ID manually instead",
                            style: TextStyle(
                              color: kForest,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: kForest,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: kForest),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////// PIN ////////////////////

class PinScreen extends StatefulWidget {
  final String? recipientName;
  final String? amount;
  final String? upiId;
  final bool isUpi;
  const PinScreen({
    super.key,
    this.recipientName,
    this.amount,
    this.upiId,
    this.isUpi = false,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  bool _isBalanceUnlocked = false;
  bool _isBalanceVisible = false;
  final TextEditingController _pinController = TextEditingController();
  final List<TextEditingController> _digitControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    _pinController.dispose();
    for (var c in _digitControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Check Balance",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _pinController,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter 4-digit PIN",
              counterText: "",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text.length == 4) {
                  setState(() {
                    _isBalanceUnlocked = true;
                    _isBalanceVisible = true;
                  });
                  _pinController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid 4-digit PIN"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kForest),
              child: const Text(
                "Verify",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipientName = widget.recipientName;
    final amount = widget.amount;
    final upiId = widget.upiId;
    final isUpi = widget.isUpi;

    final dynamicColor = getDynamicAmountColor(amount ?? "");

    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => _handleGlobalBottomNavTap(context, i),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: TopBar(
                    onHomeTap: () => _handleGlobalHomeTap(context),
                    onLogoutTap: () => _handleGlobalLogout(context),
                    onNotificationTap: () => showNotifications(context),
                  ),
                ),
                LoanHeader(
                  title: "Enter PIN",
                  subtitle: "Secure Payment",
                  icon: Icons.lock_outline_rounded,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Payment Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Paying to",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  recipientName ?? "Recipient",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (isUpi && upiId != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      upiId,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kForest.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "₹$amount",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: kForest,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          const Text(
                            "ENTER 4-DIGIT PIN",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black54,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => box(context, index),
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextButton.icon(
                            onPressed: _showPinDialog,
                            icon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                            ),
                            label: Text(
                              _isBalanceUnlocked
                                  ? "Balance: ${_isBalanceVisible ? (PanicModeService.instance.isPanicMode ? '₹7,900.00' : '₹1,45,000.50') : '******'}"
                                  : "Check Balance",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: kMid,
                              backgroundColor: kMid.withValues(alpha: 0.05),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: dynamicColor != null
                                    ? [
                                        dynamicColor,
                                        dynamicColor.withValues(alpha: 0.8),
                                      ]
                                    : [kForest, kMid],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (dynamicColor ?? kForest).withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final enteredPin = _digitControllers
                                    .map((c) => c.text)
                                    .join();
                                if (enteredPin.length < 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter the 4-digit UPI PIN to proceed",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (PanicModeService.instance.isPanicMode) {
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please contact the bank",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(20),
                                    ),
                                  );
                                  return;
                                }

                                final parsedAmount = double.tryParse((amount ?? "").replaceAll(',', '')) ?? 0.0;
                                final hasFingerprint = await BiometricService.instance.hasEnrolledFingerprint();
                                final isBioEnabled = await BiometricService.instance.isBiometricPaymentEnabled();

                                if (parsedAmount > 20000 && hasFingerprint && isBioEnabled) {
                                  final bioSuccess = await BiometricService.instance.authenticate(
                                    reason: "Biometric verification required for transfer above ₹20,000",
                                  );
                                  if (!bioSuccess) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("payment was unsucessful please try again"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }

                                if (isUpi) {
                                  final currentCusId = AuthProvider.instance.currentUser?['cus_id'] ?? 'default';
                                  final todayStr = DateTime.now().toIso8601String().substring(0, 10);
                                  final settings = await LocalDbService.getSettings('upi_daily_limit_$currentCusId') ?? {};
                                  final dailyTotal = (settings[todayStr] as num?)?.toDouble() ?? 0.0;
                                  final currentAmount = double.tryParse(amount ?? "") ?? 0.0;
                                  settings[todayStr] = dailyTotal + currentAmount;
                                  await LocalDbService.saveSettings('upi_daily_limit_$currentCusId', settings);
                                }

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SuccessScreen(
                                      recipientName: recipientName,
                                      isUpi: isUpi,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Confirm & Pay",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ], // closes Column children
            ), // closes Column
            buildDynamicEdgeHue(dynamicColor),
          ], // closes Stack children
        ), // closes Stack
      ), // closes SafeArea
    );
  }

  Widget box(BuildContext context, int i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 60,
      height: 65,
      child: TextField(
        controller: _digitControllers[i],
        focusNode: _focusNodes[i],
        keyboardType: TextInputType.number,
        obscureText: true,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryGreen, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (i < 3) {
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            } else {
              _focusNodes[i].unfocus();
            }
          } else {
            if (i > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            }
          }
        },
      ),
    );
  }
}

//////////////////// SUCCESS ////////////////////

class SuccessScreen extends StatelessWidget {
  final String? recipientName;
  final bool isUpi;
  final String txnId;

  SuccessScreen({super.key, this.recipientName, this.isUpi = false})
    : txnId = "TXN${DateTime.now().millisecondsSinceEpoch}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => _handleGlobalBottomNavTap(context, i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () => _handleGlobalHomeTap(context),
                onLogoutTap: () => _handleGlobalLogout(context),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "Success",
              subtitle: "Payment Summary",
              icon: Icons.check_circle_outline,
              onBack: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccent.withValues(alpha: 0.05), kCream],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const PremiumSuccessAnimation(),
                                const SizedBox(height: 48),
                                const Text(
                                  "Payment Successful!",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isUpi
                                      ? "Paid to ${recipientName ?? 'ghosh23abheek'} via UPI ID\n${recipientName ?? 'ghosh23abheek@gmail.com'}"
                                      : "Paid to ${recipientName ?? 'Recipient'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Transaction ID",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            txnId,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 24),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: txnId),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Transaction ID Copied!",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: kForest.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.copy,
                                            size: 18,
                                            color: kForest,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 48),
                                Container(
                                  width: 200,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [kForest, kMid],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kForest.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.popUntil(
                                        context,
                                        (route) => route.isFirst,
                                      );
                                    },
                                    child: const Text(
                                      "Back to Home",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumSuccessAnimation extends StatefulWidget {
  const PremiumSuccessAnimation({super.key});

  @override
  State<PremiumSuccessAnimation> createState() =>
      _PremiumSuccessAnimationState();
}

class _PremiumSuccessAnimationState extends State<PremiumSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kForest, kMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kForest.withValues(alpha: 0.3),
                  blurRadius: 15 * _scaleAnimation.value,
                  spreadRadius: 2 * _scaleAnimation.value,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 60),
            ),
          ),
        );
      },
    );
  }
}

void _showSecurityLockToast(BuildContext context, {String? message}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message ?? 'Account Locked: Night Lock or Global Freeze is active.',
      ),
      backgroundColor: Colors.red.shade800,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
      duration: const Duration(seconds: 1),
    ),
  );
}

class ManageSectionScreen extends StatefulWidget {
  final String sectionName;
  final List<String> sections;
  final Map<String, String> contactTags;
  final List<Map<String, String>> mockContacts;
  final Function(
    Map<String, String> updatedTags,
    List<String> updatedSections,
    String currentSection,
  )
  onUpdate;

  const ManageSectionScreen({
    super.key,
    required this.sectionName,
    required this.sections,
    required this.contactTags,
    required this.mockContacts,
    required this.onUpdate,
  });

  @override
  State<ManageSectionScreen> createState() => _ManageSectionScreenState();
}

class _ManageSectionScreenState extends State<ManageSectionScreen> {
  late Map<String, String> _localTags;
  late List<String> _localSections;
  late String _currentSectionName;

  @override
  void initState() {
    super.initState();
    _localTags = Map<String, String>.from(widget.contactTags);
    _localSections = List<String>.from(widget.sections);
    _currentSectionName = widget.sectionName;
  }

  void _triggerUpdate() {
    widget.onUpdate(_localTags, _localSections, _currentSectionName);
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _currentSectionName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Rename List",
          style: TextStyle(fontWeight: FontWeight.bold, color: kForest),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != _currentSectionName) {
                setState(() {
                  final idx = _localSections.indexOf(_currentSectionName);
                  if (idx != -1) {
                    _localSections[idx] = newName;
                  }
                  _localTags.forEach((upi, tag) {
                    if (tag == _currentSectionName ||
                        (_currentSectionName == "Favourites" &&
                            tag == "Favourite") ||
                        (_currentSectionName == "Family" && tag == "Family")) {
                      _localTags[upi] = newName;
                    }
                  });
                  _currentSectionName = newName;
                });
                _triggerUpdate();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kForest),
            child: const Text("Rename", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Delete List?",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          "Are you sure you want to delete '$_currentSectionName'? All tagged contacts will be untagged.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _localSections.remove(_currentSectionName);
                _localTags.removeWhere(
                  (upi, tag) =>
                      tag == _currentSectionName ||
                      (_currentSectionName == "Favourites" &&
                          tag == "Favourite") ||
                      (_currentSectionName == "Family" && tag == "Family"),
                );
                _currentSectionName = "All";
              });
              _triggerUpdate();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddContactsDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final availableContacts = widget.mockContacts.where((contact) {
          final String tag = _localTags[contact["upi"]] ?? "";
          final isMember =
              (tag == _currentSectionName) ||
              (_currentSectionName == "Favourites" && tag == "Favourite") ||
              (_currentSectionName == "Family" && tag == "Family");
          return !isMember;
        }).toList();

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 300,
            constraints: const BoxConstraints(maxHeight: 350),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Select Contact to Add",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kForest,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                if (availableContacts.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "All contacts are already added.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableContacts.length,
                        itemBuilder: (context, index) {
                          final contact = availableContacts[index];
                          return ListTile(
                            title: Text(
                              contact["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(contact["upi"]!),
                            onTap: () {
                              setState(() {
                                if (_currentSectionName == "Favourites") {
                                  _localTags[contact["upi"]!] = "Favourite";
                                } else if (_currentSectionName == "Family") {
                                  _localTags[contact["upi"]!] = "Family";
                                } else {
                                  _localTags[contact["upi"]!] =
                                      _currentSectionName;
                                }
                              });
                              _triggerUpdate();
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.mockContacts.where((contact) {
      final String tag = _localTags[contact["upi"]] ?? "";
      return (tag == _currentSectionName) ||
          (_currentSectionName == "Favourites" && tag == "Favourite") ||
          (_currentSectionName == "Family" && tag == "Family");
    }).toList();

    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => _handleGlobalBottomNavTap(context, i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () => _handleGlobalHomeTap(context),
                onLogoutTap: () => _handleGlobalLogout(context),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kMid.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: kForest.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kMid.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: kMid,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "MANAGE LIST",
                          style: TextStyle(
                            color: kAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentSectionName,
                          style: const TextStyle(
                            color: kForest,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showRenameDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kMid.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: kMid,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showDeleteConfirmDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Included",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _showAddContactsDropdown(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: kForest,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "Add contacts",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final contact = members[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [kMid, kForest],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      contact["name"]![0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact["name"]!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        contact["upi"]!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _localTags.remove(contact["upi"]);
                                    });
                                    _triggerUpdate();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
