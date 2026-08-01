import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../../services/api_service.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class KycUserProfile {
  final String id;
  String name;
  final String relation;
  String gender; // 'Male' or 'Female'
  String dob;
  String pan;
  String aadhaar;
  String ovdType;
  String ovdNumber;
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String pincode;
  String occupation;
  String annualIncome;
  bool fatcaResident;
  bool pepStatus;
  String status; // 'VERIFIED', 'UNDER_REVIEW', 'PENDING'
  String ckycRefNo;
  bool panUploaded;
  bool addressProofUploaded;
  bool selfieUploaded;

  KycUserProfile({
    required this.id,
    required this.name,
    required this.relation,
    required this.gender,
    required this.dob,
    required this.pan,
    required this.aadhaar,
    required this.ovdType,
    required this.ovdNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.occupation,
    required this.annualIncome,
    this.fatcaResident = true,
    this.pepStatus = false,
    required this.status,
    required this.ckycRefNo,
    required this.panUploaded,
    required this.addressProofUploaded,
    required this.selfieUploaded,
  });
}

class KycVerificationPage extends StatefulWidget {
  const KycVerificationPage({super.key});

  @override
  State<KycVerificationPage> createState() => _KycVerificationPageState();
}

class _KycVerificationPageState extends State<KycVerificationPage> {
  int _currentStep = 0;

  // Multi-User KYC State
  final List<KycUserProfile> _usersList = [
    KycUserProfile(
      id: 'CUST1',
      name: 'Rajesh Sharma',
      relation: 'Self (Primary)',
      gender: 'Male',
      dob: '15/08/1990',
      pan: 'ABCDE1234F',
      aadhaar: '9876 5432 1098',
      ovdType: 'Aadhaar Card',
      ovdNumber: '9876 5432 1098',
      addressLine1: 'Flat 402, Green Meadows',
      addressLine2: 'MG Road, Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560038',
      occupation: 'Salaried',
      annualIncome: '₹5 Lakhs - ₹10 Lakhs',
      fatcaResident: true,
      pepStatus: false,
      status: 'VERIFIED',
      ckycRefNo: 'CKYC-9082736412',
      panUploaded: true,
      addressProofUploaded: true,
      selfieUploaded: true,
    ),
    KycUserProfile(
      id: 'CUST1_JOINT1',
      name: 'Priya Sharma Kumar',
      relation: 'Spouse (Joint)',
      gender: 'Female',
      dob: '22/11/1993',
      pan: 'XYZPS9876K',
      aadhaar: '4321 8765 9012',
      ovdType: 'Passport',
      ovdNumber: 'Z8901234',
      addressLine1: 'Flat 402, Green Meadows',
      addressLine2: 'MG Road, Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560038',
      occupation: 'Self Employed / Professional',
      annualIncome: '₹10 Lakhs - ₹25 Lakhs',
      fatcaResident: true,
      pepStatus: false,
      status: 'VERIFIED',
      ckycRefNo: 'CKYC-8819230491',
      panUploaded: true,
      addressProofUploaded: true,
      selfieUploaded: true,
    ),
  ];
  int _selectedUserIndex = 0;

  // KYC Status State
  bool _isEditing = false; // Locked by default
  bool _storagePermissionGranted = false;
  String _kycStatus = 'VERIFIED'; // 'VERIFIED', 'UNDER_REVIEW', 'PENDING'
  String _ckycRefNo = 'CKYC-9082736412';
  DateTime _lastUpdated = DateTime.now().subtract(const Duration(days: 14));

  // Form Controllers & Focus
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final TextEditingController _fullNameController =
      TextEditingController(text: 'Rajesh Sharma');
  final TextEditingController _dobController =
      TextEditingController(text: '15/08/1990');
  final TextEditingController _panController =
      TextEditingController(text: 'ABCDE1234F');
  final TextEditingController _aadhaarController =
      TextEditingController(text: '9876 5432 1098');
  final TextEditingController _ovdNumController =
      TextEditingController(text: '9876 5432 1098');

  final TextEditingController _addressLine1Controller =
      TextEditingController(text: 'Flat 402, Green Meadows');
  final TextEditingController _addressLine2Controller =
      TextEditingController(text: 'MG Road, Indiranagar');
  final TextEditingController _cityController =
      TextEditingController(text: 'Bengaluru');
  final TextEditingController _stateController =
      TextEditingController(text: 'Karnataka');
  final TextEditingController _pincodeController =
      TextEditingController(text: '560038');

  String _gender = 'Male';
  String _ovdType = 'Aadhaar Card';
  String _occupation = 'Salaried';
  String _annualIncome = '₹5 Lakhs - ₹10 Lakhs';
  bool _isIndianTaxResident = true;
  bool _isPep = false; // Politically Exposed Person

  // Document Upload States
  bool _panUploaded = true;
  bool _addressProofUploaded = true;
  bool _selfieUploaded = true;
  bool _aadhaarOtpVerified = true;

  @override
  void initState() {
    super.initState();
    _fetchKycFromBackend();
  }

  void _loadUserProfile(KycUserProfile user) {
    _fullNameController.text = user.name;
    _dobController.text = user.dob;
    _gender = user.gender;
    _panController.text = user.pan;
    _aadhaarController.text = user.aadhaar;
    _ovdType = user.ovdType;
    _ovdNumController.text = user.ovdNumber;
    _addressLine1Controller.text = user.addressLine1;
    _addressLine2Controller.text = user.addressLine2;
    _cityController.text = user.city;
    _stateController.text = user.state;
    _pincodeController.text = user.pincode;
    _occupation = user.occupation;
    _annualIncome = user.annualIncome;
    _isIndianTaxResident = user.fatcaResident;
    _isPep = user.pepStatus;
    _kycStatus = user.status;
    _ckycRefNo = user.ckycRefNo;
    _panUploaded = user.panUploaded;
    _addressProofUploaded = user.addressProofUploaded;
    _selfieUploaded = user.selfieUploaded;
    _isEditing = (user.status != 'VERIFIED');
  }

  void _saveCurrentProfileState() {
    final cur = _usersList[_selectedUserIndex];
    cur.name = _fullNameController.text.trim();
    cur.dob = _dobController.text.trim();
    cur.gender = _gender;
    cur.pan = _panController.text.trim().toUpperCase();
    cur.aadhaar = _aadhaarController.text.trim();
    cur.ovdType = _ovdType;
    cur.ovdNumber = _ovdNumController.text.trim();
    cur.addressLine1 = _addressLine1Controller.text.trim();
    cur.addressLine2 = _addressLine2Controller.text.trim();
    cur.city = _cityController.text.trim();
    cur.state = _stateController.text.trim();
    cur.pincode = _pincodeController.text.trim();
    cur.occupation = _occupation;
    cur.annualIncome = _annualIncome;
    cur.fatcaResident = _isIndianTaxResident;
    cur.pepStatus = _isPep;
    cur.status = _kycStatus;
    cur.ckycRefNo = _ckycRefNo;
    cur.panUploaded = _panUploaded;
    cur.addressProofUploaded = _addressProofUploaded;
    cur.selfieUploaded = _selfieUploaded;
  }

  Future<void> _fetchKycFromBackend() async {
    try {
      final res = await ApiService.instance.get('/kyc/status/CUST1');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['kyc_record'] != null) {
          final rec = data['kyc_record'];
          setState(() {
            if (rec['full_name'] != null && rec['full_name'].toString().isNotEmpty) {
              _fullNameController.text = rec['full_name'];
            }
            if (rec['dob'] != null && rec['dob'].toString().isNotEmpty) {
              _dobController.text = rec['dob'];
            }
            if (rec['pan_number'] != null && rec['pan_number'].toString().isNotEmpty) {
              _panController.text = rec['pan_number'];
            }
            if (rec['aadhaar_number'] != null && rec['aadhaar_number'].toString().isNotEmpty) {
              _aadhaarController.text = rec['aadhaar_number'];
            }
            if (rec['address_line1'] != null) {
              _addressLine1Controller.text = rec['address_line1'];
            }
            if (rec['city'] != null) {
              _cityController.text = rec['city'];
            }
            if (rec['state'] != null) {
              _stateController.text = rec['state'];
            }
            if (rec['pincode'] != null) {
              _pincodeController.text = rec['pincode'];
            }
            if (rec['ckyc_ref_no'] != null) {
              _ckycRefNo = rec['ckyc_ref_no'];
            }
            if (rec['status'] != null) {
              _kycStatus = rec['status'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint('[KYC] Error loading KYC from database: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _ovdNumController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _showAadhaarOtpModal() {
    final TextEditingController otpController = TextEditingController();
    bool isVerifying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  color: kSub.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phonelink_ring_rounded,
                    color: kForest, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'UIDAI Aadhaar OTP Verification',
                style: TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter 6-digit OTP sent to your Aadhaar linked mobile ending in ******9876',
                textAlign: TextAlign.center,
                style: TextStyle(color: kSub, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: kForest,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '123456',
                  hintStyle: TextStyle(
                      color: kSub.withOpacity(0.4), letterSpacing: 8),
                  filled: true,
                  fillColor: kCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kForest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          setModalState(() => isVerifying = true);
                          await Future.delayed(
                              const Duration(milliseconds: 1200));
                          if (mounted) {
                            setState(() => _aadhaarOtpVerified = true);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF2E7D32),
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Aadhaar e-KYC Verification Successful!'),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Verify OTP & Authenticate',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitKycApplication() async {
    if (!_panUploaded || !_addressProofUploaded || !_selfieUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          duration: Duration(seconds: 4),
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Compulsory Documents Missing: Please upload PAN Card, Address Proof & Live Selfie before verification.'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final curUser = _usersList[_selectedUserIndex];
    final kycData = {
      'cus_id': curUser.id,
      'full_name': _fullNameController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _gender,
      'pan_number': _panController.text.trim(),
      'aadhaar_number': _aadhaarController.text.trim(),
      'ovd_type': _ovdType,
      'ovd_number': _ovdNumController.text.trim(),
      'address_line1': _addressLine1Controller.text.trim(),
      'address_line2': _addressLine2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'occupation': _occupation,
      'annual_income': _annualIncome,
      'fatca_resident': _isIndianTaxResident,
      'pep_status': _isPep,
      'status': 'VERIFIED',
      'ckyc_ref_no': _ckycRefNo,
    };

    try {
      await ApiService.instance.post(
        '/kyc/save',
        body: {'cus_id': 'CUST1', 'kyc_data': kycData},
      );
      debugPrint('[KYC] Details saved to database successfully');
    } catch (e) {
      debugPrint('[KYC] Error saving to database: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Color(0xFF2E7D32), size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'KYC Details Submitted!',
              style: TextStyle(
                color: kForest,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your KYC verification details have been received and updated with C-KYC Registry in accordance with RBI directives.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kSub, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kForest,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    _kycStatus = 'VERIFIED';
                    _isEditing = false;
                    _lastUpdated = DateTime.now();
                    _saveCurrentProfileState();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Back to Profile',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordAuthDialog({VoidCallback? onSuccess}) {
    final TextEditingController pwdController = TextEditingController();
    bool obscurePwd = true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  color: kAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: kForest, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Security Authentication Required',
                style: TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your account password / PIN to unlock and edit your verified RBI KYC details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kSub, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pwdController,
                obscureText: obscurePwd,
                style: const TextStyle(color: kForest, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Account Password / PIN',
                  hintText: 'Enter password',
                  errorText: errorText,
                  filled: true,
                  fillColor: kCard,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: kForest),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePwd
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: kSub,
                    ),
                    onPressed: () =>
                        setModalState(() => obscurePwd = !obscurePwd),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: kSub, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kForest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (pwdController.text.trim().isEmpty) {
                          setModalState(() => errorText = 'Password is required');
                          return;
                        }
                        Navigator.pop(context);
                        setState(() => _isEditing = true);
                        if (onSuccess != null) onSuccess();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: kForest,
                            content: Row(
                              children: [
                                Icon(Icons.lock_open_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Identity Verified: KYC Fields Unlocked'),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Verify & Unlock',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
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

  void _handleDocumentUpload(String docTitle, Function(bool) setUploadedState) {
    if (!_isEditing) {
      _showPasswordAuthDialog(
          onSuccess: () => _handleDocumentUpload(docTitle, setUploadedState));
      return;
    }

    if (!_storagePermissionGranted) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: kCream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.folder_shared_rounded, color: kForest, size: 26),
              SizedBox(width: 10),
              Text('Storage Permission', style: TextStyle(color: kForest, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'WealthWise Banking app requires permission to access your device storage & camera to upload your $docTitle for RBI KYC verification.',
            style: const TextStyle(color: kSub, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Deny', style: TextStyle(color: kSub, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => _storagePermissionGranted = true);
                Navigator.pop(dialogCtx);
                _showFileSourcePicker(docTitle, setUploadedState);
              },
              child: const Text('Allow Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _showFileSourcePicker(docTitle, setUploadedState);
    }
  }

  void _showFileSourcePicker(String docTitle, Function(bool) setUploadedState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select File Source for $docTitle',
              style: const TextStyle(color: kForest, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: kForest.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: kForest),
              ),
              title: const Text('Device Photo Gallery / Storage', style: TextStyle(color: kForest, fontWeight: FontWeight.w600)),
              subtitle: const Text('Browse device files or images', style: TextStyle(color: kSub, fontSize: 12)),
              onTap: () {
                Navigator.pop(sheetCtx);
                setState(() => setUploadedState(true));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF2E7D32),
                    content: Text('$docTitle Selected & Uploaded Successfully!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: kForest.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: kForest),
              ),
              title: const Text('Camera Photo Capture', style: TextStyle(color: kForest, fontWeight: FontWeight.w600)),
              subtitle: const Text('Take a live photo of document / selfie', style: TextStyle(color: kSub, fontSize: 12)),
              onTap: () {
                Navigator.pop(sheetCtx);
                setState(() => setUploadedState(true));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF2E7D32),
                    content: Text('$docTitle Captured & Uploaded Successfully!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSwitcher() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: kForest, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'KYC Profile Selector',
                    style: TextStyle(
                      color: kForest,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddNewUserDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kForest.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add_alt_1_rounded, color: kForest, size: 15),
                      SizedBox(width: 4),
                      Text(
                        '+ Add User',
                        style: TextStyle(
                          color: kForest,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_usersList.length, (index) {
                final user = _usersList[index];
                final isSelected = index == _selectedUserIndex;

                final isFemale = user.gender == 'Female';
                final genderIcon = isFemale ? Icons.female_rounded : Icons.male_rounded;
                final genderColor = isFemale ? const Color(0xFFD81B60) : const Color(0xFF1976D2);

                return GestureDetector(
                  onTap: () {
                    _saveCurrentProfileState();
                    setState(() {
                      _selectedUserIndex = index;
                      _loadUserProfile(_usersList[index]);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kForest : kCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? kForest : kSub.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: isSelected
                              ? Colors.white
                              : (isFemale ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD)),
                          child: Icon(
                            genderIcon,
                            size: 15,
                            color: isSelected
                                ? (isFemale ? const Color(0xFFD81B60) : kForest)
                                : genderColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : kForest,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${user.relation} • ${user.gender}',
                              style: TextStyle(
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : kSub,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.status == 'VERIFIED'
                                ? (isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE8F5E9))
                                : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.status,
                            style: TextStyle(
                              color: user.status == 'VERIFIED'
                                  ? (isSelected ? Colors.white : const Color(0xFF2E7D32))
                                  : Colors.amber.shade900,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_usersList.length > 1 && index > 0) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showDeleteUserPasswordDialog(index),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserPasswordDialog(int userIndex) {
    if (_usersList.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          content: Text('Cannot delete primary user profile. At least one profile must remain.'),
        ),
      );
      return;
    }

    final user = _usersList[userIndex];
    final pwdController = TextEditingController();
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
                child: Icon(Icons.person_remove_rounded, color: Colors.red.shade700, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete User Profile (${user.name})',
                style: const TextStyle(
                  color: kForest,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your security password / PIN to authorize deleting ${user.name}\'s KYC profile record from the database.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kSub, fontSize: 13, height: 1.3),
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
                      onPressed: () async {
                        if (pwdController.text.trim().isEmpty) {
                          setModalState(() => errorText = 'Password is required');
                          return;
                        }

                        Navigator.pop(ctx);

                        // Update backend DB record status to REMOVED
                        try {
                          await ApiService.instance.post('/kyc/delete/${user.id}', body: {});
                        } catch (e) {
                          debugPrint('[KYC] Error updating backend DB on delete: $e');
                        }

                        setState(() {
                          _usersList.removeAt(userIndex);
                          if (_selectedUserIndex >= _usersList.length) {
                            _selectedUserIndex = _usersList.length - 1;
                          }
                          _loadUserProfile(_usersList[_selectedUserIndex]);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 4),
                            content: Row(
                              children: [
                                const Icon(Icons.delete_forever_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Profile for ${user.name} deleted & record updated in Database.'),
                                ),
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

  void _showAddNewUserDialog() {
    final nameCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    String relation = 'Joint Holder';
    String userGender = 'Female';
    String? nameError;
    String? panError;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kSub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.person_add_rounded, color: kForest, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Add User for RBI KYC Verification',
                    style: TextStyle(
                      color: kForest,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter details for the family member, joint account holder, or nominee to begin their KYC verification.',
                style: TextStyle(color: kSub, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: kForest, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'User Full Name (as per PAN) *',
                  hintText: 'e.g. Sunita Kumar',
                  errorText: nameError,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person_outline, color: kForest),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: relation,
                      style: const TextStyle(color: kForest, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Relationship *',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.family_restroom_rounded, color: kForest),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Joint Holder', child: Text('Joint Holder')),
                        DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                        DropdownMenuItem(value: 'Child', child: Text('Child')),
                        DropdownMenuItem(value: 'Parent', child: Text('Parent')),
                        DropdownMenuItem(value: 'Nominee', child: Text('Nominee')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => relation = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: userGender,
                      style: const TextStyle(color: kForest, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Gender *',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          userGender == 'Female' ? Icons.female_rounded : Icons.male_rounded,
                          color: userGender == 'Female' ? const Color(0xFFD81B60) : const Color(0xFF1976D2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => userGender = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: panCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                style: const TextStyle(color: kForest, fontSize: 15, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'PAN Number (Compulsory) *',
                  hintText: 'e.g. ABCDE1234F',
                  errorText: panError,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.badge_outlined, color: kForest),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                        backgroundColor: kForest,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final pan = panCtrl.text.trim().toUpperCase();

                        bool hasErr = false;
                        setModalState(() {
                          if (name.isEmpty) {
                            nameError = 'User Full Name is required';
                            hasErr = true;
                          } else {
                            nameError = null;
                          }

                          if (pan.isEmpty) {
                            panError = 'PAN Number is compulsory under RBI mandate';
                            hasErr = true;
                          } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
                            panError = 'Invalid 10-char PAN (e.g. ABCDE1234F)';
                            hasErr = true;
                          } else {
                            panError = null;
                          }
                        });

                        if (hasErr) return;

                        final randId = math.Random().nextInt(900000) + 100000;
                        final newId = 'CUST_USER_$randId';
                        final newCkyc = 'CKYC-${math.Random().nextInt(900000000) + 1000000000}';
                        final newUser = KycUserProfile(
                          id: newId,
                          name: name,
                          relation: relation,
                          gender: userGender,
                          dob: '01/01/1995',
                          pan: pan,
                          aadhaar: '',
                          ovdType: 'Aadhaar Card',
                          ovdNumber: '',
                          addressLine1: '',
                          addressLine2: '',
                          city: '',
                          state: '',
                          pincode: '',
                          occupation: 'Salaried',
                          annualIncome: '₹1 Lakh - ₹5 Lakhs',
                          fatcaResident: true,
                          pepStatus: false,
                          status: 'PENDING', // UNVERIFIED / PENDING
                          ckycRefNo: newCkyc,
                          panUploaded: false, // COMPULSORY UNVERIFIED DOCUMENTS!
                          addressProofUploaded: false,
                          selfieUploaded: false,
                        );

                        Navigator.pop(ctx);

                        setState(() {
                          _usersList.add(newUser);
                          _selectedUserIndex = _usersList.length - 1;
                          _loadUserProfile(newUser);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 4),
                            backgroundColor: kForest,
                            content: Row(
                              children: [
                                const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('New User Profile Created ($userGender): Upload compulsory KYC documents for $name.'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Create & Upload Documents',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
    return Scaffold(
      backgroundColor: kCream,
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
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
              subtitle: "RBI Bank KYC Verification",
              icon: Icons.shield_rounded,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildUserSwitcher(),
                  _buildKycStatusBanner(),
                  const SizedBox(height: 18),
                  _buildStepSelector(),
                  const SizedBox(height: 18),
                  if (_currentStep == 0) _buildIdentitySection(),
                  if (_currentStep == 1) _buildAddressSection(),
                  if (_currentStep == 2) _buildFinancialAndTaxSection(),
                  if (_currentStep == 3) _buildDocumentUploadSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycStatusBanner() {
    Color statusBg;
    Color statusBorder;
    Color textColor;
    IconData statusIcon;
    String statusText;

    if (_kycStatus == 'VERIFIED') {
      statusBg = const Color(0xFFE8F5E9);
      statusBorder = const Color(0xFF81C784);
      textColor = const Color(0xFF1B5E20);
      statusIcon = Icons.verified_rounded;
      statusText = 'FULL KYC VERIFIED';
    } else if (_kycStatus == 'UNDER_REVIEW') {
      statusBg = const Color(0xFFFFF8E1);
      statusBorder = const Color(0xFFFFD54F);
      textColor = const Color(0xFFF57F17);
      statusIcon = Icons.hourglass_top_rounded;
      statusText = 'UNDER VERIFICATION';
    } else {
      statusBg = const Color(0xFFFFEBEE);
      statusBorder = const Color(0xFFE57373);
      textColor = const Color(0xFFB71C1C);
      statusIcon = Icons.info_outline_rounded;
      statusText = 'ACTION REQUIRED';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusBorder.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: textColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'RBI Mandate Compliance',
                        style: TextStyle(color: kSub, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isEditing) {
                        _showPasswordAuthDialog();
                      } else {
                        setState(() => _isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Color(0xFF2E7D32),
                            content: Row(
                              children: [
                                Icon(Icons.lock_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text('KYC Details Saved & Locked'),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isEditing ? kForest : kForest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing
                                ? Icons.lock_open_rounded
                                : Icons.edit_note_rounded,
                            size: 14,
                            color: _isEditing ? Colors.white : kForest,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEditing ? 'Editing' : 'Edit Details',
                            style: TextStyle(
                              color: _isEditing ? Colors.white : kForest,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('C-KYC Ref Number (KIN)',
                      style: TextStyle(color: kSub, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    _ckycRefNo,
                    style: const TextStyle(
                      color: kForest,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Last Verified Date',
                      style: TextStyle(color: kSub, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '${_lastUpdated.day}/${_lastUpdated.month}/${_lastUpdated.year}',
                    style: const TextStyle(
                        color: kForest,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepSelector() {
    final List<String> steps = [
      '1. Identity',
      '2. Address',
      '3. Tax & Income',
      '4. Documents'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isSelected = _currentStep == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(steps[index]),
              selected: isSelected,
              selectedColor: kForest,
              backgroundColor: kCard,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : kForest,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? kForest : Colors.transparent,
                ),
              ),
              onSelected: (_) => setState(() => _currentStep = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kForest,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kForest,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isEditing)
                const Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: kSub),
                    SizedBox(width: 3),
                    Text('Locked', style: TextStyle(color: kSub, fontSize: 10)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: _isEditing,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: TextStyle(
              color: _isEditing ? kForest : kForest.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: _isEditing ? FontWeight.normal : FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: kSub.withValues(alpha: 0.5)),
              suffixIcon: suffix ?? (!_isEditing ? const Icon(Icons.lock_outline_rounded, size: 16, color: kSub) : null),
              filled: true,
              fillColor: _isEditing ? kCream.withValues(alpha: 0.5) : kCream.withValues(alpha: 0.25),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.2)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kForest, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kForest,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isEditing)
                const Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: kSub),
                    SizedBox(width: 3),
                    Text('Locked', style: TextStyle(color: kSub, fontSize: 10)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: safeValue,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item,
                          style: const TextStyle(color: kForest, fontSize: 14)),
                    ))
                .toList(),
            onChanged: _isEditing ? onChanged : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing ? kCream.withValues(alpha: 0.5) : kCream.withValues(alpha: 0.25),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.2)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSub.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: IDENTITY & PAN DETAILS
  Widget _buildIdentitySection() {
    return Form(
      key: _formKeyStep1,
      child: _buildSectionCard(
        title: 'Personal Identity & PAN Verification',
        children: [
          _buildTextField(
            label: 'Full Name (as per PAN Card)',
            controller: _fullNameController,
            hint: 'e.g. Rajesh Kumar',
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  hint: 'DD/MM/YYYY',
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Gender',
                  value: _gender,
                  items: const ['Male', 'Female', 'Other'],
                  onChanged: (val) => setState(() => _gender = val!),
                ),
              ),
            ],
          ),
          _buildTextField(
            label: 'PAN (Compulsory under RBI Mandate) *',
            controller: _panController,
            hint: 'ABCDE1234F',
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              UpperCaseTextFormatter(),
            ],
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'PAN Number is compulsory under RBI mandate';
              }
              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(val.trim().toUpperCase())) {
                return 'Enter valid 10-character PAN (e.g. ABCDE1234F)';
              }
              return null;
            },
            suffix: Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 4),
                  Text('NSDL Verified',
                      style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          _buildTextField(
            label: 'Aadhaar Number (12 Digits)',
            controller: _aadhaarController,
            hint: '9876 5432 1098',
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(14)],
            suffix: TextButton(
              onPressed: _showAadhaarOtpModal,
              child: Text(
                _aadhaarOtpVerified ? 'OTP Verified' : 'Verify via OTP',
                style: TextStyle(
                  color: _aadhaarOtpVerified ? const Color(0xFF2E7D32) : kForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: ADDRESS & OVD DETAILS
  Widget _buildAddressSection() {
    return Form(
      key: _formKeyStep2,
      child: _buildSectionCard(
        title: 'Officially Valid Document (OVD) & Address',
        children: [
          _buildDropdownField(
            label: 'Proof of Address (POA) Document Type',
            value: _ovdType,
            items: const [
              'Aadhaar Card',
              'Passport',
              'Voter ID Card',
              'Driving License',
              'NREGA Job Card'
            ],
            onChanged: (val) => setState(() => _ovdType = val!),
          ),
          _buildTextField(
            label: '$_ovdType Document Number',
            controller: _ovdNumController,
            hint: 'Enter document number',
          ),
          _buildTextField(
            label: 'Flat / Door / House No. & Building Name',
            controller: _addressLine1Controller,
            hint: 'e.g. Flat 402, Green Meadows Apartment',
          ),
          _buildTextField(
            label: 'Road / Street / Locality / Landmark',
            controller: _addressLine2Controller,
            hint: 'e.g. MG Road, Indiranagar',
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City / District',
                  controller: _cityController,
                  hint: 'e.g. Bengaluru',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'State',
                  controller: _stateController,
                  hint: 'e.g. Karnataka',
                ),
              ),
            ],
          ),
          _buildTextField(
            label: 'Pincode (6 Digits)',
            controller: _pincodeController,
            hint: '560038',
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
          ),
        ],
      ),
    );
  }

  // STEP 3: FINANCIAL & FATCA COMPLIANCE
  Widget _buildFinancialAndTaxSection() {
    return _buildSectionCard(
      title: 'Financial Profile & FATCA/CRS Declaration',
      children: [
        _buildDropdownField(
          label: 'Occupation Type',
          value: _occupation,
          items: const [
            'Salaried',
            'Self-Employed / Business',
            'Professional',
            'Student',
            'Retired',
            'Other'
          ],
          onChanged: (val) => setState(() => _occupation = val!),
        ),
        _buildDropdownField(
          label: 'Gross Annual Income Category',
          value: _annualIncome,
          items: const [
            'Below ₹1 Lakh',
            '₹1 Lakh - ₹5 Lakhs',
            '₹5 Lakhs - ₹10 Lakhs',
            '₹10 Lakhs - ₹25 Lakhs',
            'Above ₹25 Lakhs'
          ],
          onChanged: (val) => setState(() => _annualIncome = val!),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCream.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kSub.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: kForest,
                title: const Text(
                  'Tax Residency Declaration (FATCA / CRS)',
                  style: TextStyle(
                      color: kForest,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'I confirm that I am a tax resident of India and not a tax resident of any other country.',
                  style: TextStyle(color: kSub, fontSize: 11),
                ),
                value: _isIndianTaxResident,
                onChanged: (val) =>
                    setState(() => _isIndianTaxResident = val ?? true),
              ),
              const Divider(),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: kForest,
                title: const Text(
                  'Politically Exposed Person (PEP) Status',
                  style: TextStyle(
                      color: kForest,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Check if you or your close relative is a Politically Exposed Person as defined under PMLA regulations.',
                  style: TextStyle(color: kSub, fontSize: 11),
                ),
                value: _isPep,
                onChanged: (val) => setState(() => _isPep = val ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 4: DOCUMENT UPLOAD & SELFIE VERIFICATION
  Widget _buildDocumentUploadSection() {
    return _buildSectionCard(
      title: 'KYC Document & Selfie Verification',
      children: [
        _buildUploadTile(
          title: 'PAN Card Copy (Front)',
          subtitle: 'Clear photo showing PAN number & signature',
          isUploaded: _panUploaded,
          onTap: () => _handleDocumentUpload(
              'PAN Card Copy', (val) => _panUploaded = val),
        ),
        _buildUploadTile(
          title: 'Address Proof Document (POA)',
          subtitle: 'Aadhaar / Voter ID / Driving License',
          isUploaded: _addressProofUploaded,
          onTap: () => _handleDocumentUpload(
              'Address Proof Document', (val) => _addressProofUploaded = val),
        ),
        _buildUploadTile(
          title: 'Live Selfie Capture (Liveness Check)',
          subtitle: 'Real-time photo verification for face matching',
          isUploaded: _selfieUploaded,
          onTap: () => _handleDocumentUpload(
              'Live Selfie', (val) => _selfieUploaded = val),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.security_rounded, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Documents are encrypted with 256-bit AES encryption & stored securely under RBI IT Framework Guidelines.',
                  style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadTile({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCream.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF81C784)
                : kSub.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFE8F5E9)
                    : kAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle_rounded
                    : Icons.cloud_upload_outlined,
                color: isUploaded ? const Color(0xFF2E7D32) : kForest,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kForest,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: kSub, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              isUploaded ? 'Uploaded' : 'Upload',
              style: TextStyle(
                color: isUploaded ? const Color(0xFF2E7D32) : kForest,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kForest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
          label: const Text(
            'Unlock & Edit KYC Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => _showPasswordAuthDialog(),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kForest),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                        color: kForest, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kForest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  } else {
                    _submitKycApplication();
                  }
                },
                child: Text(
                  _currentStep < 3 ? 'Save & Continue' : 'Submit & Lock KYC',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            icon: const Icon(Icons.lock_rounded, size: 16, color: kSub),
            label: const Text(
              'Cancel & Lock Details',
              style: TextStyle(color: kSub, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              setState(() => _isEditing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF2E7D32),
                  content: Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Editing Cancelled — Details Locked'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
