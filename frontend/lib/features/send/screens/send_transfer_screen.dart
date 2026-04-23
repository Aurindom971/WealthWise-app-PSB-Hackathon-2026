import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../home/screens/notifications_screen.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../../services/security_service.dart';
import '../../../core/utils/security_validator.dart';

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
        onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
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
                  onHomeTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onLogoutTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kCream,
        bottomNavigationBar: BottomNav(
          currentIndex: -1,
          onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
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
                  onHomeTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onLogoutTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onNotificationTap: () => showNotifications(context),
                ),
              ),
              LoanHeader(
                title: "Bank Transfer",
                subtitle: "Send Money",
                icon: Icons.swap_horiz,
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
                                  // Auto-fill FROM Mock Data
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
                  _showSecurityLockToast(context, message: 'Online Transactions are currently blocked by Smart Lock.');
                  return;
                }
                
                if (fromAccount == null || toBank == null || transferPurpose == null ||
                    (transferPurpose == "Other" && _otherPurposeController.text.trim().isEmpty) ||
                    _toAccountController.text.trim().isEmpty || _toIfscController.text.trim().isEmpty ||
                    _toNomineeController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all compulsory details!"), backgroundColor: Colors.red));
                  return;
                }

                // 2. Sanitize and Validate
                final sanitizedRecipient = SecurityValidator.sanitize(_toNomineeController.text);
                final sanitizedAccount = SecurityValidator.sanitize(_toAccountController.text);
                final sanitizedIFSC = SecurityValidator.sanitize(_toIfscController.text).toUpperCase();
                final rawAmount = _amountController.text.replaceAll(',', '');

                if (!SecurityValidator.isValidAmount(rawAmount)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid amount entered.")));
                  return;
                }

                if (!SecurityValidator.isValidAccountNumber(sanitizedAccount)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid account number format.")));
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SECURITY: Payload rejected.")));
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
          onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
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
                  onHomeTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onLogoutTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
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

  @override
  void initState() {
    super.initState();
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
          "Allow Secure Wealth to access your contacts to easily find and pay your friends?",
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kCream,
        bottomNavigationBar: BottomNav(
          currentIndex: -1,
          onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
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
                  onHomeTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onLogoutTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
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
                            MaterialPageRoute(builder: (_) => const QRScreen()),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  borderSide: const BorderSide(color: kForest),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Amount (₹)",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 12,
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
                                  borderSide: const BorderSide(color: kForest),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                              Text(
                                "UPI CONTACTS",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: Scrollbar(
                                  controller: _contactsScrollController,
                                  thickness: 4,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: _contactsScrollController,
                                    itemCount: _mockContacts.length,
                                    itemBuilder: (context, index) {
                                      final contact = _mockContacts[index];
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
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.grey.shade100
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
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
                                                    contact["name"]![0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    contact["name"]!,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    contact["upi"]!,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
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
                      const SizedBox(height: 32),
                      // Pay Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kForest, kMid],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kForest.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await SecurityService.isUpiLockActive()) {
                              _showSecurityLockToast(context, message: 'UPI Payments are currently blocked by Smart Lock.');
                              return;
                            }
                            if (_amountController.text.trim().isEmpty || _upiIdController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter UPI ID and Amount"), backgroundColor: Colors.red));
                              return;
                            }

                            // 2. Sanitize and Validate
                            final sanitizedUpi = SecurityValidator.sanitize(_upiIdController.text);
                            final rawAmount = _amountController.text.replaceAll(',', '');

                            if (!SecurityValidator.isValidAmount(rawAmount)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid amount entered.")));
                              return;
                            }

                            // 3. Payload Check
                            final payload = {
                              "upi_id": sanitizedUpi,
                              "amount": rawAmount,
                            };

                            if (!SecurityValidator.inspectPayload(payload)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SECURITY: Payload rejected.")));
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PinScreen(
                                  recipientName: sanitizedUpi.isNotEmpty ? sanitizedUpi.split('@').first.toUpperCase() : "VERIFIED PERSON",
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
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
            ],
          ),
        ),
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
          "Allow Secure Wealth to take pictures and record video to scan QR codes?",
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
        onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
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

    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: -1,
        onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
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
                        children: List.generate(4, (_) => box(context)),
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
                              ? "Balance: ${_isBalanceVisible ? '₹1,45,000.50' : '******'}"
                              : "Check Balance",
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          gradient: const LinearGradient(
                            colors: [kForest, kMid],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kForest.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
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
          ],
        ),
      ),
    );
  }

  Widget box(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 60,
      height: 65,
      child: TextField(
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
          if (value.isNotEmpty) FocusScope.of(context).nextFocus();
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
        onTap: (i) => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
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
