# WealthWise - Cybersecurity & Data Protection Manual

This manual contains the official security protocols, threat descriptions, customer defense strategies, and technical controls enforced by WealthWise to protect user data, systems, and communication channels. It serves as reference material for customer success agents, internal security teams, and the SAGE AI.

---

## Phishing, Smishing & Social Engineering

### SEC-001: Understanding and Identifying Phishing Attempts
Phishing is a cyberattack that uses spoofed emails, malicious websites, or direct messages designed to look like official communications from WealthWise. These messages try to trick users into sharing sensitive credentials, such as login passcodes, UPI PINs, or recovery keys. WealthWise will never send links asking you to enter your login credentials or PINs; all official web requests are hosted exclusively under the verified domain `WealthWise.com`.

### SEC-002: Smishing (SMS Phishing) Controls and Indicators
Smishing is a form of phishing that uses SMS text messages instead of email. Typically, these messages contain urgent warnings about suspended accounts, unauthorized transactions, or gift rewards, followed by a link to a fake login portal. WealthWise sends transactional SMS notifications only from registered headers (e.g., SW-BANK, SECWTH). If you receive an SMS from a standard 10-digit mobile number claiming to represent WealthWise, it is a smishing attempt.

### SEC-003: Social Engineering and Voice Phishing (Vishing) Defense
Vishing occurs when attackers call victims claiming to be WealthWise fraud investigators, relationship managers, or RBI representatives. They use high-pressure tactics to request OTPs, credit card numbers, or UPI PINs to "block a fraud transaction" or "update KYC". Customers must remember that WealthWise employees are strictly prohibited from requesting OTPs, passcodes, or PINs over phone calls. If asked, end the call immediately.

### SEC-004: SIM Swap Fraud and Detection Protocols
SIM swapping is a social engineering attack where fraudsters convince a telecom operator to port a victim's phone number to a SIM card they control. This allows them to intercept incoming OTPs and bypass SMS-based multi-factor authentication. WealthWise monitors SIM card serial numbers (ICCID) via network carriers where possible. A sudden loss of cell service alongside attempts to access your account will trigger a security hold.

---

## Multi-Factor Authentication (MFA) & Passwords

### SEC-005: Multi-Factor Authentication (MFA) Architecture
WealthWise implements a zero-trust multi-factor authentication framework. Accessing your account or initiating high-value transactions requires verification across three factors: Knowledge (passcode or PIN), Possession (device hardware token/registered SIM), and Inherence (biometric TouchID/FaceID fingerprint). This ensures that even if an attacker compromises a passcode via phishing, they cannot complete transactions without the physical device and biometrics.

### SEC-006: Password Strength and Hashing Standards
To prevent password guessing and dictionary attacks, WealthWise requires all login passcodes to be at least 8 characters long and contain a mix of uppercase and lowercase letters, numbers, and special characters. Passcodes are hashed using bcrypt with a high cost factor, making brute-force attempts on database records computationally infeasible. Passwords cannot contain common sequences or repeat personal details like usernames or birthdates.

### SEC-007: Biometric Encryption Keys and Secure Enclaves
Biometric authentication on WealthWise uses the iOS Secure Enclave and Android Keystore systems. During biometric enrollment, the app generates a cryptographic key pair inside the device's hardware enclave. Successful biometric scans release the private key to sign an authentication payload sent to our backend. WealthWise never receives, stores, or processes your actual biometric fingerprint or face scan.

---

## Device & Mobile Banking Security

### SEC-008: Operating System Security Patches
Using outdated mobile operating systems exposes your banking app to known security vulnerabilities. WealthWise requires Android devices to run version 10.0 or higher and iOS devices to run version 15.0 or higher. The app checks for the latest OS security patch level; if a critical kernel vulnerability is detected, the app displays a warning requesting an update before allowing access to wealth services.

### SEC-009: Public Wi-Fi Risks and Secure VPN usage
Accessing WealthWise over public Wi-Fi networks (e.g., at airports or cafes) exposes communications to man-in-the-middle (MITM) attacks, where attackers intercept or alter data packets. We recommend executing transactions using cellular data connections. If public Wi-Fi is necessary, users must connect through a reputable VPN utilizing modern protocols like WireGuard or OpenVPN to encrypt all app traffic.

### SEC-010: Malware and Overlay Attack Protections
Overlay attacks occur when malicious apps running on a device paint a transparent, fake login window over the WealthWise app to capture your credentials. WealthWise integrates security controls to detect when another application is drawing overlays. If detected, the app automatically blanks the screen, halts input processing, and prompts the user to uninstall the offending application.

---

## Data Protection & Privacy

### SEC-011: Data Encryption in Transit (TLS 1.3)
All communications between the WealthWise mobile application, desktop portals, and backend servers are secured using TLS 1.3 encryption. We disable outdated cryptographic protocols like SSLv3, TLS 1.0, and TLS 1.1 to protect against downgrade attacks. WealthWise enforces HTTPS-only connections and utilizes HTTP Strict Transport Security (HSTS) to prevent any unencrypted communication.

### SEC-012: Data Encryption at Rest (AES-256)
All sensitive customer databases, identity verification records, and transaction ledgers stored on WealthWise's cloud infrastructure are encrypted at rest using AES-256. Cryptographic keys are managed via hardware security modules (HSMs) with strict access control lists and automated rotation policies. This ensures that even in the event of a physical data storage breach, the data remains unreadable.

### SEC-013: Screen Security and Screenshot Blocking
To protect against screen recorders and shoulder surfing, WealthWise implements platform-level flag controls that block screen captures. On Android, the app sets `WindowManager.LayoutParams.FLAG_SECURE`, which blanks screenshots and video recordings of the app. On iOS, the app detects screen recording states and automatically hides sensitive portfolio and bank details behind a security screen.
