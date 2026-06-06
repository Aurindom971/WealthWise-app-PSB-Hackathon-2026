# Secure Wealth - Fraud Policies & Risk Methodology

This document details the fraud detection algorithms, behavioral policies, risk metrics, and anomaly detection guidelines implemented in Secure Wealth's transaction monitoring engine. It serves as primary documentation for security audits, data science models, and SAGE AI search indices.

---

## Velocity Attacks

### POL-001: Definition and Detection of Transaction Velocity Anomalies
Transaction velocity refers to the speed and frequency of transaction attempts initiated from a single user account or card token within a compressed timeframe. Secure Wealth's monitoring engine continuously tracks velocity metrics across multiple intervals (e.g., 60 seconds, 10 minutes, 24 hours). A sudden burst of high-frequency debit attempts or payment checks, particularly for identical or rounded amounts, indicates a automated brute-force attack or card-testing scheme and triggers an automatic block.

### POL-002: Card-Testing Velocity Thresholds
Card testing occurs when bad actors use automated scripts to test stolen card numbers against merchants with low security controls to identify active cards. Secure Wealth flags card-testing velocity when an account experiences more than three card-not-present (CNP) validation failures or small debit attempts (under ₹100) within 5 minutes. Upon triggering this threshold, the card is immediately suspended, and the cardholder is notified to replace the credentials.

### POL-003: Login and OTP Velocity Thresholds
To prevent brute-force attacks on login credentials and secure transaction authorizations, Secure Wealth enforces velocity caps on access attempts. An account is locked for 30 minutes after five consecutive failed password or biometric entry attempts within a 15-minute window. Similarly, a maximum of three One-Time Passwords (OTPs) can be requested for a single transaction or login session; exceeding this triggers a block on the channel for 2 hours.

---

## Device Mismatch & Biometric Anomalies

### POL-004: Device Fingerprinting and Token Management
Every mobile device accessing Secure Wealth is assigned a unique hardware fingerprint using metrics such as CPU architecture, OS kernel versions, screen resolution, local locale, and hardware identifiers (IMEI/UUID). This fingerprint is cryptographically tied to the user's active session token. If an API request is received with a valid session token but from a device exhibiting a different device fingerprint, the transaction is blocked and a re-authentication flow is enforced.

### POL-005: Dual Device Session Policies
Secure Wealth permits only one active mobile device session per user account at any given time. If a login attempt is completed successfully on Device B, the active session token and biometric bindings on Device A are instantly invalidated. A push notification is dispatched to Device A reporting the new login, and any subsequent transaction requested from Device A is denied until device re-binding is completed.

### POL-006: Device Health and Rooting/Jailbreak Detection
Secure Wealth runs active integrity checks during startup to identify rooted Android devices or jailbroken iOS devices. Rooted environments bypass sandbox security controls, exposing encryption keys and transaction payloads to potential malware. Out of security policy compliance, the Secure Wealth app refuses to initialize on compromised operating systems, requiring the user to run the app on a stock, secure OS version.

---

## Geolocation Anomalies & Impossible Travel

### POL-007: Geolocation IP and GPS Cross-Referencing
Secure Wealth captures the user's network IP address and device-level GPS coordinates during high-risk transactions. The monitoring engine cross-references these two geolocation points to ensure they align. If a transaction IP resolves to a server in Mumbai but the device GPS reports coordinates in Delhi, the transaction is flagged for potential proxy/VPN routing or manual account manipulation.

### POL-008: Impossible Travel Detection Logic
Impossible travel detection checks the geographic distance and time elapsed between consecutive transactions on a single account. If Transaction A occurs in Kolkata and Transaction B is initiated 30 minutes later from London, the system calculates that the required travel velocity exceeds commercial flight limits. The system flags this as an impossible travel anomaly, blocks Transaction B, and triggers an account lock.

### POL-009: Suspicious VPN and Tor Exit Node Access
Transactions routed through public virtual private networks (VPNs), hosting providers, or Tor exit nodes are flagged as high-risk. While VPNs are common for general privacy, using them to execute financial transfers obscures geolocation tracking. Secure Wealth requires all high-value transfers (above ₹50,000) to be completed over direct mobile network connections or verified home/office ISP connections, bypassing anonymizer networks.

---

## Account Takeover (ATO) Prevention

### POL-010: Behavior-Based Anomaly Detection (Bio-Behavioral Profiling)
Secure Wealth's advanced fraud engine builds an anonymous profile of user interaction patterns, including keystroke dynamics, device angle tilt, scroll speed, and navigation sequences. During high-risk actions (e.g., adding a beneficiary or initiating a transfer), if the interaction patterns deviate significantly from the baseline behavior profile, SAGE prompts for step-up multi-factor authentication (MFA).

### POL-011: High-Risk Profile Changes and Cooling-Off Periods
Modifying critical account parameters—such as changing passwords, updating emails, or linking new devices—marks the account as highly sensitive. To prevent fraud syndicates from draining accounts immediately after an takeover, Secure Wealth enforces a 24-hour cooling-off period. During this period, UPI, IMPS, and external transfers are capped at a maximum of ₹10,000 per day.

### POL-012: Beneficiary Addition Cooling-Off Controls
When a user adds a new beneficiary for NEFT/RTGS/IMPS transfers, the system triggers a 4-hour security lock during which no transfers can be routed to the new account. After this window, the transfer limit to that beneficiary is restricted to ₹50,000 for the first 24 hours. This allows the user to review notifications and report unauthorized beneficiary additions before funds are lost.

---

## Synthetic Identity & Application Fraud

### POL-013: Aadhaar-PAN Biometric De-duplication
Synthetic identity fraud involves creating fake profiles using a mix of real and fabricated details. Secure Wealth integrates directly with government databases (UIDAI and NSDL) to match Aadhaar biometric hashes and PAN linkages. If a photograph or Aadhaar key has already been registered to another user profile under a different name, the system halts onboarding and routes the application to manual fraud review.

### POL-014: Credit Bureau Verification during Onboarding
During account onboarding, Secure Wealth queries credit bureaus (CIBIL/Experian) to verify the applicant's credit history profile. If the applicant's credit file is empty, or exhibits patterns of sudden multiple loan applications alongside a newly registered phone number (less than 90 days active), the risk engine flags the user for potential mule account activity.

---

## Risk Scoring & Transaction Monitoring

### POL-015: Dynamic Transaction Risk Score Calculation
Every transaction processed by Secure Wealth is analyzed in real-time by an AI classifier to generate a risk score ranging from 0 to 100. The score incorporates device parameters, user behavior history, transaction amount, recipient VPA reputation, geolocation, and current time. Transactions scoring below 30 are approved automatically; scores 30-70 require MFA verification; scores above 70 are blocked and routed for analyst review.

### POL-016: Recipient Account Reputation Scoring
Our transaction monitoring engine checks the transaction history of the receiving account or UPI VPA. If the recipient ID has been named in police FIRs, reported on the National Cyber Crime Portal, or exhibits high cash-out velocities (immediate withdrawal of incoming funds), the system raises its risk tier, alerts the sender, and blocks real-time outbound processing.

### POL-017: Suspicious Transaction Value Clustering (Structuring)
Structuring or "smurfing" is the practice of breaking down a large sum of money into multiple small transactions to evade regulatory reporting thresholds (e.g., RBI limits or tax checks). Secure Wealth's risk engine runs clustering algorithms to detect when an account initiates multiple transfers just below the ₹50,000 Aadhaar PAN requirement threshold within a 72-hour window.

### POL-018: Real-Time Fraud Alert Generation Pipeline
When a transaction is flagged with a high risk score, the system initiates the alert pipeline. It suspends transaction execution, places a temporary hold on the corresponding funds, and sends a push alert and SMS to the user. The user must review the alert in the app and verify the recipient's identity using secure biometrics to complete the transfer.
