# WealthWise - Banking FAQ Knowledge Base

This document serves as the official Banking FAQ knowledge base for WealthWise's support center and the SAGE AI retrieval system. It covers transaction protocols, account operations, security setups, and dispute mechanisms.

---

## UPI (Unified Payments Interface)

### FAQ-001: What is UPI and how does it work on WealthWise?
Unified Payments Interface (UPI) is a real-time payment system developed by the National Payments Corporation of India (NPCI). It facilitates instant inter-bank peer-to-peer (P2P) and peer-to-merchant (P2M) transactions. On the WealthWise application, UPI allows users to link their registered bank accounts and transfer funds using a virtual address known as a Virtual Payment Address (VPA) or UPI ID (e.g., username@WealthWise), bypassing the need to enter sensitive routing details like IFSC codes or account numbers.

### FAQ-002: What are the daily transaction limits for UPI on WealthWise?
As per NPCI guidelines, the standard daily limit for UPI transfers is ₹1,00,000 per user per day. However, for specific categories such as educational institutions, healthcare providers, and IPO applications, the limit is extended up to ₹5,00,000. WealthWise also enforces an initial 24-hour limit of ₹5,000 for users who have newly registered or changed their UPI PIN to protect against unauthorized account takeovers and velocity-based attacks.

### FAQ-003: Can I link multiple bank accounts to a single UPI VPA?
No, a single Virtual Payment Address (VPA) can only be mapped to one primary bank account at any given moment for receiving payments. However, within the WealthWise app, you can create multiple unique VPAs and assign each to a different linked bank account. When initiating an outgoing transfer, you can select any of your linked accounts as the source, irrespective of the default primary receiving VPA.

### FAQ-004: What should I do if my UPI transaction status is marked as 'Pending'?
A 'Pending' status indicates that the transaction request has been successfully initiated by WealthWise but is awaiting confirmation from either the remitter bank, NPCI, or the beneficiary bank's servers. In most cases, these resolve automatically within 24 hours. If the status does not update, the funds will either be credited to the beneficiary or refunded to your account within 48 to 72 business hours in accordance with NPCI settlement rules.

### FAQ-005: What is a UPI PIN and how is it different from a login passcode?
Your login passcode grants access to the WealthWise application dashboard and spending views. The UPI PIN, however, is a highly secure 4-digit or 6-digit numeric password established directly with your bank during UPI registration. The UPI PIN is required to authorize every debit transaction from your linked bank account and is processed directly on the NPCI secure central switch. WealthWise never stores your UPI PIN on its servers.

### FAQ-006: How do I reset a forgotten UPI PIN?
To reset your UPI PIN on WealthWise, navigate to "Linked Bank Accounts" under settings, select the relevant bank account, and tap "Reset UPI PIN". You will be prompted to enter the last six digits of your active Debit Card associated with that account, along with its expiry date. After verifying these details via a secure One-Time Password (OTP) sent to your registered mobile number, you can set a new UPI PIN.

### FAQ-007: What is UPI Lite and how does it function?
UPI Lite is an on-device wallet feature supported by WealthWise for processing low-value transactions up to ₹500 without requiring a UPI PIN. Users can load up to ₹2,000 into their local UPI Lite wallet from their linked bank account. Since UPI Lite transactions bypass core banking systems and communicate directly with NPCI's decentralized ledger, they exhibit exceptionally high success rates and keep your bank passbook clean of small debit entries.

### FAQ-008: Can I make international payments using UPI?
Yes, WealthWise supports UPI International for select merchant outlets in countries that have partnered with NPCI (e.g., UAE, Singapore, Nepal, Bhutan, Mauritius). To utilize this, you must activate "UPI International" in your WealthWise profile settings, choose the destination country, and authorize the linkage. Transactions are calculated in local currency, converted to INR, and carry standard cross-border transaction fees.

---

## NEFT (National Electronic Funds Transfer)

### FAQ-009: What is NEFT and when is it appropriate to use?
National Electronic Funds Transfer (NEFT) is a nationwide electronic fund transfer system maintained by the Reserve Bank of India (RBI). NEFT operates on a Net Settlement basis, meaning transactions are batched every half-hour rather than processed instantly. It is ideal for scheduled, non-urgent transfers of varying amounts, especially for routine payments like rent, salaries, and vendor disbursements, where real-time settlement is not mandatory.

### FAQ-010: What are the operating hours and settlement times for NEFT?
NEFT is available 24/7/365, including weekends and public holidays. Transactions are processed in half-hourly batches starting from 00:30 hours to 00:00 hours. Outgoing transactions initiated through WealthWise are typically credited to the beneficiary's account within 30 to 120 minutes of batch settlement, depending on the speed of the receiving bank's batch processing system.

### FAQ-011: What are the minimum and maximum transfer limits for NEFT?
There is no minimum transaction limit for NEFT transfers initiated via WealthWise, allowing users to send amounts as low as ₹1. While the RBI does not place any regulatory upper limit on NEFT transactions, WealthWise enforces a standard security cap of ₹10,00,000 per day for individual savings account holders to minimize exposure to fraud and phishing exploits.

### FAQ-012: What happens if an NEFT transaction fails to credit?
If the beneficiary's bank account details (such as account number or IFSC) are incorrect, the receiving bank is mandated by RBI regulations to return the funds to the originating bank branch within two hours of the batch settlement. WealthWise will automatically credit the returned amount back to your source account, accompanied by an SMS and push notification explaining the failure reason.

---

## RTGS (Real-Time Gross Settlement)

### FAQ-013: What is RTGS and how does it differ from NEFT?
Real-Time Gross Settlement (RTGS) is a high-value fund transfer system maintained by the RBI. Unlike NEFT, which settles in batches, RTGS settles transactions individually and continuously on a "gross" basis in real-time. Once authorized on WealthWise, the money is immediately debited from your account and credited to the receiving bank's RBI settlement account, making it the fastest and most secure method for sending large sums.

### FAQ-014: What is the minimum transaction limit for RTGS?
RTGS is reserved exclusively for high-value financial transfers. The regulatory minimum limit for an RTGS transaction is ₹2,00,000. If you need to transfer any amount below ₹2,00,000, you must select alternative transfer options on WealthWise such as IMPS, UPI, or NEFT, which are optimized for lower-value, retail transactions.

### FAQ-015: What are the processing charges for RTGS on WealthWise?
In accordance with the RBI directives to promote digital banking, WealthWise charges zero fees for all online RTGS transactions initiated through the mobile app or web portal. This enables businesses and individual investors to manage large capital movements, property purchases, and asset acquisitions without incurring processing overheads.

### FAQ-016: Is it possible to cancel or recall an RTGS transaction?
No, RTGS transactions are legally binding and final once they are submitted to the RBI settlement engine. Because settlement occurs in real-time and on a gross basis, the funds are immediately routed to the beneficiary bank. If you discover you have transferred funds to an incorrect beneficiary, you must contact WealthWise support immediately to initiate an inter-bank recovery request, though success is dependent on the beneficiary's consent.

---

## IMPS (Immediate Payment Service)

### FAQ-017: What is IMPS and how does it work?
Immediate Payment Service (IMPS) is an instant, inter-bank electronic fund transfer service managed by NPCI. IMPS facilitates immediate cash transfers 24/7/365 across registered banking networks. On WealthWise, you can initiate an IMPS transfer using either the beneficiary's Account Number and IFSC code or their Mobile Number and Mobile Money Identifier (MMID).

### FAQ-018: What is an MMID and how is it used in IMPS?
A Mobile Money Identifier (MMID) is a unique 7-digit numeric code issued by bank branches to customers registered for mobile banking. To send money via IMPS using MMID, you only need the receiver's registered mobile number and their MMID code. This serves as an alternative to sharing traditional account numbers and bank IFSC codes, enhancing privacy during rapid peer-to-peer transfers.

### FAQ-019: What are the limits and transaction charges for IMPS?
WealthWise supports IMPS transactions up to ₹5,00,000 per day. Transactions up to ₹1,000 are processed free of charge, while transactions above ₹1,000 carry a nominal processing fee ranging from ₹2.50 to ₹15 (exclusive of GST), depending on the transfer slab. These charges cover NPCI switching fees and network maintenance costs.

### FAQ-020: My IMPS transaction failed but the amount was debited. What should I do?
In rare instances of network timeouts between NPCI and the receiving bank, an IMPS transfer may fail after debiting your account. In such scenarios, the NPCI reconciliation system automatically detects the mismatch and initiates a reversal. The debited amount is typically credited back to your WealthWise linked bank account within 24 to 48 hours. If the refund is not received within 3 business days, you can raise a dispute via the app.

---

## Account Security & KYC

### FAQ-021: How does WealthWise secure my login credentials?
WealthWise employs military-grade cryptographic hashing (bcrypt/PBKDF2) to protect passcodes and login pins. All network traffic between the mobile application and our APIs is encrypted using TLS 1.3 with Perfect Forward Secrecy. Additionally, WealthWise utilizes biometrics (TouchID/FaceID) mapped to secure enclaves inside iOS and Android devices, ensuring that your password is never exposed in memory or over the network.

### FAQ-022: What steps should I take if I suspect my account has been compromised?
If you observe suspicious login alerts, unrecognized transaction logs, or change-profile notifications, you must act instantly. Open the WealthWise app, navigate to Security Settings, and tap "Freeze All Accounts". Alternatively, call our 24/7 automated emergency line at 1-800-SECURE-W to immediately suspend your digital access, block linked cards, and invalidate active API sessions.

### FAQ-023: How do I change my registered mobile number or email address?
Due to RBI anti-money laundering and cybersecurity guidelines, updates to sensitive contact fields cannot be performed entirely online without verification. To change your registered mobile number, you must complete a video-KYC session inside the WealthWise app using your Aadhaar card and PAN card, or visit a partner biometric verification center to prevent unauthorized social engineering takeovers.

### FAQ-024: What is Re-KYC and why is it mandatory for my WealthWise account?
Re-KYC is a periodic update of customer identification records mandated by RBI Master Directions on KYC. Low-risk customers must update their KYC details once every 10 years, medium-risk every 8 years, and high-risk customers every 2 years. WealthWise will alert you 60 days before your KYC expires, allowing you to submit updated address proofs and complete a quick Aadhaar-based e-KYC directly inside the app.

### FAQ-025: Can a non-resident Indian (NRI) open a WealthWise account?
Yes, NRIs can open accounts with WealthWise. However, they must link Non-Resident External (NRE) or Non-Resident Ordinary (NRO) accounts rather than standard domestic savings accounts. NRI registration requires compliance with the Foreign Exchange Management Act (FEMA) guidelines, including submission of a valid visa/work permit, foreign address proof, and FATCA/CRS declarations during onboarding.

### FAQ-026: What is FATCA compliance and does it apply to me?
The Foreign Account Tax Compliance Act (FATCA) is a mutual tax reporting agreement signed between India and other nations (including the US) to prevent tax evasion. If you are a tax resident of any country outside India, you must declare your Tax Identification Number (TIN) on WealthWise. Non-disclosure or false declarations can lead to the temporary blocking of investment portfolios and wealth trading access.

---

## Transaction Disputes & Card Security

### FAQ-027: How do I file a dispute for an unauthorized debit transaction?
To report an unauthorized debit, tap on the specific transaction in your History ledger and select "Dispute Transaction". You will be guided through a series of questions to classify the claim (e.g., duplicate billing, merchant fraud, or unrecognized ATM debit). Once submitted, the app raises a formal chargeback claim with the card network (Visa/Mastercard) or NPCI, and a tracking ID is generated.

### FAQ-028: What is the RBI policy on customer liability for unauthorized electronic transactions?
As per RBI guidelines, a customer has zero liability if the unauthorized transaction occurs due to contributory fraud/negligence on the part of the bank. If the fraud is due to a third-party breach elsewhere in the system and the customer reports it within 3 working days of receiving the alert, the liability is zero. Reporting within 4 to 7 days caps customer liability (ranging from ₹5,000 to ₹25,000 depending on account type), while delay beyond 7 days is subject to bank policy.

### FAQ-029: How do I temporarily block or unblock my WealthWise debit card?
If you misplace your card, open the WealthWise app, navigate to Card Management, and toggle "Lock Card". This instantly blocks all transaction requests (online, offline, ATM, contactless) at the processor level. If you find your card later, you can toggle it back to "Unlocked" instantly without needing a card replacement or calling customer service.

### FAQ-030: What is Tokenization and how does it secure my card?
Card tokenization replaces your actual 16-digit card number with a unique digital identifier called a "token" created for your specific device and merchant (e.g., Apple Pay, Google Pay, or online stores). If a merchant database is breached, hackers only retrieve the useless token rather than your physical card details, preventing unauthorized card-not-present (CNP) fraud. WealthWise automatically tokenizes cards during mobile wallet setup.
