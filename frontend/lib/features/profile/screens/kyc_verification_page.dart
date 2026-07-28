import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';

class KycVerificationPage extends StatefulWidget {
  const KycVerificationPage({super.key});

  @override
  State<KycVerificationPage> createState() => _KycVerificationPageState();
}

class _KycVerificationPageState extends State<KycVerificationPage> {
  bool _isSubmitting = false;
  bool _isCompleted = false;

  // Allowed Re-KYC Fields
  final TextEditingController _legalNameController = TextEditingController(text: 'Rajesh Kumar');
  final TextEditingController _contactController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _emailController = TextEditingController(text: 'rajesh.kumar@example.com');
  final TextEditingController _addressController = TextEditingController(text: 'Flat 402, Green Avenue, CP, New Delhi');
  final TextEditingController _passwordController = TextEditingController();

  String _maritalStatus = 'Single';
  String _taxStatus = 'Resident Individual (FATCA Compliant)';
  bool _obscurePassword = true;
  String? _passwordError;

  // Document Upload States (PoI, PoA, Signature, Live Photo)
  String? _uploadedPoiDocName;
  String? _uploadedPoaDocName;
  String? _uploadedSignatureDocName;
  String? _uploadedLivePhotoName;

  @override
  void dispose() {
    _legalNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitVerification() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _passwordError = 'Login password is required to update KYC');
      return;
    }

    setState(() => _passwordError = null);
    _showOtpVerificationDialog();
  }

  // 1. Security OTP Verification Dialog
  void _showOtpVerificationDialog() {
    final TextEditingController otpController = TextEditingController();
    String? otpError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: kForest, size: 26),
              SizedBox(width: 10),
              Text(
                'Security OTP Verification',
                style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A 6-digit OTP has been sent to your registered mobile number (+91 98765 *****).\n\nPlease enter the OTP to authorize Re-KYC changes:',
                style: TextStyle(color: kSub, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  letterSpacing: 8,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kForest,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  errorText: otpError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kForest, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: kSub, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                final otp = otpController.text.trim();
                if (otp.length < 6) {
                  setDialogState(() {
                    otpError = 'Please enter valid 6-digit OTP';
                  });
                  return;
                }
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP Verified successfully! Proceed to upload required documents.'),
                    backgroundColor: kForest,
                  ),
                );
                _showDocumentUploadBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kForest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Verify OTP & Continue',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Document Upload Bottom Sheet for PoI, PoA, Signature Proof, and Live Photo
  void _showDocumentUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bool allDocsUploaded = _uploadedPoiDocName != null &&
              _uploadedPoaDocName != null &&
              _uploadedSignatureDocName != null &&
              _uploadedLivePhotoName != null;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: kSub.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload_file_rounded, color: kForest, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Official Proof Documents',
                              style: TextStyle(
                                color: kForest,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'PoI, PoA, Signature Proof & Live Photo required for Re-KYC',
                              style: TextStyle(color: kSub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1. Proof of Identity (PoI)
                  _buildUploadDocTile(
                    title: 'Proof of Identity (PoI)',
                    subtitle: 'PAN Card / Passport / Voter ID / Driving License',
                    uploadedFileName: _uploadedPoiDocName,
                    onPick: () {
                      _promptDocumentPickerAndPermission(
                        proofCategoryTitle: 'Proof of Identity (PoI)',
                        availableDocTypes: ['PAN Card', 'Passport', 'Voter ID Card', 'Driving License'],
                        onDocumentSelected: (type, fileName) {
                          setModalState(() => _uploadedPoiDocName = '$type ($fileName)');
                          setState(() {});
                        },
                      );
                    },
                  ),

                  // 2. Proof of Address (PoA)
                  _buildUploadDocTile(
                    title: 'Proof of Address (PoA)',
                    subtitle: 'Aadhaar Card / Passport / Utility Bill',
                    uploadedFileName: _uploadedPoaDocName,
                    onPick: () {
                      _promptDocumentPickerAndPermission(
                        proofCategoryTitle: 'Proof of Address (PoA)',
                        availableDocTypes: ['Aadhaar Card', 'Passport', 'Electricity / Water Bill', 'Rent Agreement'],
                        onDocumentSelected: (type, fileName) {
                          setModalState(() => _uploadedPoaDocName = '$type ($fileName)');
                          setState(() {});
                        },
                      );
                    },
                  ),

                  // 3. Signature Proof
                  _buildUploadDocTile(
                    title: 'Signature Proof',
                    subtitle: 'Scanned signature specimen on white paper',
                    uploadedFileName: _uploadedSignatureDocName,
                    onPick: () {
                      _promptDocumentPickerAndPermission(
                        proofCategoryTitle: 'Signature Specimen',
                        availableDocTypes: ['Scanned Signature Specimen', 'Bank Verification Stamp Signature'],
                        onDocumentSelected: (type, fileName) {
                          setModalState(() => _uploadedSignatureDocName = '$type ($fileName)');
                          setState(() {});
                        },
                      );
                    },
                  ),

                  // 4. Live Photograph
                  _buildUploadDocTile(
                    title: 'Live Photograph',
                    subtitle: 'Camera live selfie with clear background',
                    uploadedFileName: _uploadedLivePhotoName,
                    onPick: () {
                      _startLiveCameraSelfieWorkflow((fileName) {
                        setModalState(() => _uploadedLivePhotoName = 'Live Selfie ($fileName)');
                        setState(() {});
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: !allDocsUploaded || _isSubmitting
                          ? null
                          : () async {
                              Navigator.pop(modalCtx);
                              setState(() => _isSubmitting = true);
                              await Future.delayed(const Duration(seconds: 2));
                              if (mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                  _isCompleted = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PoI, PoA, Signature & Live Photo submitted for verification!'),
                                    backgroundColor: kForest,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kForest,
                        disabledBackgroundColor: kSub.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              allDocsUploaded
                                  ? 'Final Submit Official Documents'
                                  : 'Upload All 4 Required Proofs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Document Selection & Storage Permission Dialog
  void _promptDocumentPickerAndPermission({
    required String proofCategoryTitle,
    required List<String> availableDocTypes,
    required Function(String docType, String fileName) onDocumentSelected,
  }) {
    showDialog(
      context: context,
      builder: (pickerCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.folder_shared_outlined, color: kForest, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Select $proofCategoryTitle',
                style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Which official document would you like to attach?',
              style: TextStyle(color: kSub, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...availableDocTypes.map(
              (docType) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: kCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSub.withOpacity(0.2)),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file_outlined, color: kForest),
                  title: Text(
                    docType,
                    style: const TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: kSub, size: 20),
                  onTap: () {
                    Navigator.pop(pickerCtx);
                    _requestFileAccessPermissionAndPick(
                      selectedType: docType,
                      onApproved: (fileName) => onDocumentSelected(docType, fileName),
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

  void _requestFileAccessPermissionAndPick({
    required String selectedType,
    required Function(String fileName) onApproved,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (permCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: kForest, size: 26),
            SizedBox(width: 10),
            Text(
              'Storage & File Access',
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'WealthWise requests permission to access your local device storage to attach "$selectedType" for bank Re-KYC compliance.\n\nDo you grant permission to access local files?',
          style: const TextStyle(color: kSub, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(permCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File access permission denied. Attachment cancelled.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Deny', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(permCtx);
              final String cleanName = selectedType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
              final String mockFileName = '${cleanName}_Doc.pdf';
              onApproved(mockFileName);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permission Granted! Attached: $mockFileName'),
                  backgroundColor: kForest,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kForest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Allow & Attach File',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Live Camera Selfie Workflow with Permission and Guidelines
  void _startLiveCameraSelfieWorkflow(Function(String fileName) onPhotoCaptured) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (permCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: kForest, size: 26),
            SizedBox(width: 10),
            Text(
              'Camera Permission Request',
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'WealthWise requires camera access to capture a live selfie for biometric identity verification.\n\nDo you grant permission to use the device camera?',
          style: TextStyle(color: kSub, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(permCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera permission denied. Live photo is required.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Deny', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(permCtx);
              _showLivePhotoGuidelinesModal(onPhotoCaptured);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kForest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Allow Camera Access',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLivePhotoGuidelinesModal(Function(String fileName) onPhotoCaptured) {
    showDialog(
      context: context,
      builder: (guideCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: kForest, size: 24),
            SizedBox(width: 10),
            Text(
              'Live Photo Guidelines',
              style: TextStyle(color: kForest, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please follow these guidelines for successful face verification:',
                style: TextStyle(color: kSub, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DO: Plain / Clear Background', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Stand against a solid plain wall with good lighting.', style: TextStyle(color: kSub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.red, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DON\'T: Crowded / Busy Background', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Avoid people, furniture, or cluttered objects behind you.', style: TextStyle(color: kSub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.red, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DON\'T: Sunglasses or Caps', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Face must be clearly visible without shadows or headgear.', style: TextStyle(color: kSub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(guideCtx);
              _openLiveCameraViewport(onPhotoCaptured);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kForest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openLiveCameraViewport(Function(String fileName) onPhotoCaptured) {
    bool isBackgroundClear = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (camCtx) => StatefulBuilder(
        builder: (context, setCamState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.black,
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Selfie Camera',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(Icons.videocam_rounded, color: Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 260,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isBackgroundClear ? Colors.greenAccent : Colors.redAccent,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Active Hardware Camera Stream
                      MobileScanner(
                        fit: BoxFit.cover,
                        controller: MobileScannerController(
                          facing: CameraFacing.front,
                          detectionSpeed: DetectionSpeed.noDuplicates,
                        ),
                      ),

                      // Face Oval Frame Overlay
                      Container(
                        width: 170,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isBackgroundClear ? Colors.greenAccent : Colors.redAccent,
                            width: 2,
                          ),
                        ),
                      ),

                      // Background Quality Indicator Banner
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isBackgroundClear
                                ? Colors.green.withOpacity(0.9)
                                : Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isBackgroundClear ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isBackgroundClear
                                      ? 'Background Clear & Optimal'
                                      : 'Background Not Clear or Crowded',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  setCamState(() {
                    isBackgroundClear = !isBackgroundClear;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBackgroundClear ? Icons.toggle_on : Icons.toggle_off,
                        color: isBackgroundClear ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBackgroundClear ? 'Simulating: Plain Wall' : 'Simulating: Crowded Room',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(camCtx),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!isBackgroundClear) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot capture: Background is not clear or crowded! Please stand against a plain wall.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(camCtx);
                      onPhotoCaptured('Live_Selfie_ClearBG.jpg');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Live Selfie captured successfully with clear background!'),
                          backgroundColor: kForest,
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera, color: Colors.black),
                    label: const Text('Capture Photo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(String title, String subtitle, String docId, IconData icon, bool verified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kForest, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  docId,
                  style: const TextStyle(
                    color: kMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
          _buildStatusChip(
            verified ? 'Verified' : 'Pending',
            verified ? Colors.green : Colors.orange,
            verified ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDocTile({
    required String title,
    required String subtitle,
    required String? uploadedFileName,
    required VoidCallback onPick,
  }) {
    final bool isUploaded = uploadedFileName != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded ? Colors.green.withOpacity(0.5) : kSub.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.task_alt_rounded : Icons.cloud_upload_outlined,
            color: isUploaded ? Colors.green : kForest,
            size: 26,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUploaded ? 'Attached: $uploadedFileName' : subtitle,
                  style: TextStyle(
                    color: isUploaded ? Colors.green : kSub,
                    fontSize: 12,
                    fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(
              foregroundColor: isUploaded ? Colors.green : kForest,
            ),
            child: Text(isUploaded ? 'Change' : 'Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text(
          'KYC Verification',
          style: TextStyle(color: kForest, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kCard,
        iconTheme: const IconThemeData(color: kForest),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kForest, Color(0xFF1E3A2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kForest.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KYC Status',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      _buildStatusChip(
                        _isCompleted ? 'Fully Verified' : 'CKYC Verified',
                        _isCompleted ? Colors.lightGreenAccent : kAccent,
                        Icons.verified_user_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Full KYC Compliance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your Central KYC (CKYC) registry details are active and compliant with SEBI & RBI regulations.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Verified Identifiers',
              style: TextStyle(
                color: kForest,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDocCard(
              'PAN Card Verification',
              'Income Tax Department',
              'ABCDE1234F',
              Icons.badge_outlined,
              true,
            ),
            _buildDocCard(
              'Aadhaar e-KYC',
              'UIDAI Verification via OTP',
              'XXXX XXXX 1098',
              Icons.fingerprint_rounded,
              true,
            ),
            _buildDocCard(
              'Bank Account Verification',
              'Penny drop verification complete',
              'A/C: 501009823412',
              Icons.account_balance_rounded,
              true,
            ),
            _buildDocCard(
              'Video KYC (V-KYC)',
              'Live face recognition & Geo-tag',
              'Completed on 12 Jan 2026',
              Icons.videocam_outlined,
              true,
            ),

            const SizedBox(height: 24),

            // Optional Re-KYC Expansion / Toggle Section
            Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kForest.withOpacity(0.15)),
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: kForest, size: 22),
                ),
                title: const Text(
                  'Update / Re-KYC Details (Optional)',
                  style: TextStyle(
                    color: kForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Tap to open and edit your details for fresh re-verification',
                  style: TextStyle(color: kSub, fontSize: 12),
                ),
                childrenPadding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Update allowed regulatory details for Re-KYC:',
                    style: TextStyle(color: kSub, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // 1. Legal Name
                  TextField(
                    controller: _legalNameController,
                    decoration: InputDecoration(
                      labelText: 'Legal Name (As per PAN/Aadhaar)',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Contact Number
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.phone_outlined, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Email Address
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.email_outlined, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Residential Address
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Residential Address',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.home_outlined, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Marital Status Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _maritalStatus,
                    decoration: InputDecoration(
                      labelText: 'Marital Status',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.favorite_outline_rounded, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Single', child: Text('Single')),
                      DropdownMenuItem(value: 'Married', child: Text('Married')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _maritalStatus = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // 6. Tax Status & FATCA Declaration Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _taxStatus,
                    decoration: InputDecoration(
                      labelText: 'Tax Status / FATCA Declaration',
                      labelStyle: const TextStyle(color: kSub),
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: kForest),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Resident Individual (FATCA Compliant)',
                        child: Text('Resident Individual (FATCA)'),
                      ),
                      DropdownMenuItem(
                        value: 'NRI / Tax Resident Outside India',
                        child: Text('NRI / Foreign Tax Resident'),
                      ),
                      DropdownMenuItem(
                        value: 'Sole Proprietor',
                        child: Text('Sole Proprietor'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _taxStatus = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password Authentication Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Account Login Password *',
                      labelStyle: const TextStyle(color: kSub),
                      errorText: _passwordError,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: kForest),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: kSub,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kForest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isCompleted ? 'Re-KYC Submitted Successfully' : 'Authenticate & Submit Re-KYC',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
