import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const CustomTextField(
                          labelText: "Ph no / Acc no",
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: CustomTextField(
                                labelText: "Pass",
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300)
                                ),
                                child: const Icon(Icons.fingerprint, color: AppColors.primary),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: const Text("OR create a new Acc", style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 48),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent),
                  label: const Text("Customer Care AI"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
