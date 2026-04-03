import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'package:securewealth_twin/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPassword = true;
  bool isObscure = true; // 👈 for eye toggle

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = AuthService();

  void handleLogin() async {
    final error = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (error == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F1),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1F5D3A),
                    Color(0xFF2E7D5B),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.account_balance,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text("Punjab & Sind Bank",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text("Welcome Back",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text("Sign in to your account securely",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PHONE / ACCOUNT NUMBER",
                      style: TextStyle(fontSize: 10, color: Colors.black54)),
                  const SizedBox(height: 4),

                  CustomTextField(
                    hintText: "Enter your account number",
                    prefixIcon: Icons.person_outline,
                    controller: emailController,
                  ),

                  const SizedBox(height: 12),

                  const Text("AUTHENTICATION METHOD",
                      style: TextStyle(fontSize: 10, color: Colors.black54)),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPassword = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isPassword
                                  ? const Color(0xFF1F5D3A)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text("Password",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isPassword
                                        ? Colors.white
                                        : Colors.black54)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPassword = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isPassword
                                  ? const Color(0xFF1F5D3A)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text("PIN",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: !isPassword
                                        ? Colors.white
                                        : Colors.black54)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (isPassword)
                    CustomTextField(
                      hintText: "Enter password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: isObscure,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (index) => Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: index < 3
                                ? const Color(0xFF1F5D3A)
                                : Colors.transparent,
                            border: Border.all(color: Colors.grey),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F5D3A),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Sign in",
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Column(children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.black54),
                    SizedBox(height: 2),
                    Text("Locate Us", style: TextStyle(fontSize: 10)),
                  ]),
                  Column(children: [
                    Icon(Icons.call_outlined,
                        size: 16, color: Colors.black54),
                    SizedBox(height: 2),
                    Text("Call Us", style: TextStyle(fontSize: 10)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}