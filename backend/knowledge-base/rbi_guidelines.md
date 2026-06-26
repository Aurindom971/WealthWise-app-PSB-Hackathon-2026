# Secure Wealth - RBI Regulatory Guidelines & Compliance

This reference document outlines the regulatory guidelines, security recommendations, and compliance policies mandated by the Reserve Bank of India (RBI) that govern Secure Wealth's digital platforms and investment services.

---

## RBI Digital Banking & Security Guidelines

### REG-001: Master Direction on Digital Payment Security Controls
The RBI's Master Direction on Digital Payment Security Controls requires all regulated entities to implement robust security controls for digital payment products. Under this direction, Secure Wealth maintains strict guidelines for application security, database encryption, server configuration, network monitoring, and API security. It requires periodic vulnerability assessments and penetration testing (VAPT) to identify and remediate security gaps.

### REG-002: Customer Protection and Limiting Liability of Customers
Under RBI's circular on Limiting Liability of Customers in Unauthorized Electronic Banking Transactions, banks and digital wallets must offer clear mechanisms for reporting fraudulent activity. Secure Wealth provides a 24/7 reporting line and in-app dispute forms. When a customer reports unauthorized activity within 3 working days, their liability is capped at zero, and the bank must credit the disputed amount back to the customer's account within 10 working days.

### REG-003: Guidelines for Security of Mobile Applications
RBI mandates that mobile banking applications must implement secure code practices, obfuscation, anti-tampering controls, and device binding. Secure Wealth complies by cryptographically tying the application instance to the user's physical SIM card and device hardware UUID. Any attempt to modify the application package or run it in a modified environment will lock the application instance and require re-registration.

---

## Cybersecurity Framework & Incident Reporting

### REG-004: Cyber Security Framework in Banks
The RBI Cyber Security Framework requires banks to establish an independent Cyber Security Committee, appoint a Chief Information Security Officer (CISO), and set up a Security Operations Center (SOC) for continuous threat monitoring. Secure Wealth's infrastructure runs under active SOC surveillance, monitoring security events, traffic anomalies, database queries, and unauthorized server access to detect and block threats in real-time.

### REG-005: Mandatory Reporting of Cyber Security Incidents to CERT-In and RBI
As per regulatory guidelines, all cyber security incidents, unauthorized system access, data leaks, ransomware attacks, or service outages must be reported to the Indian Computer Emergency Response Team (CERT-In) and the RBI within 6 hours of detection. Secure Wealth maintains an Incident Response Team that catalogs security events and submits detailed reports outlining impact analysis and remediation actions.

### REG-006: Business Continuity Planning (BCP) and Disaster Recovery (DR)
RBI directions require financial institutions to establish robust Business Continuity Plans (BCP) and Disaster Recovery (DR) systems to ensure operational continuity during hardware failures, natural disasters, or grid outages. Secure Wealth maintains active-active hot-backup databases across geographically separated cloud regions, ensuring data replication occurs in real-time with an RTO (Recovery Time Objective) under 10 minutes.

---

## KYC & Anti-Money Laundering (AML) Rules

### REG-007: Master Direction on Know Your Customer (KYC)
Secure Wealth follows the RBI Master Direction on KYC, which requires customer verification before account creation. During registration, the app runs Aadhaar e-KYC validation, matches identity details with PAN databases, and records a live, geotagged video-KYC clip to verify the user is physically present. Accounts without verified KYC are blocked from executing outward transfers and investment purchases.

### REG-008: Prevention of Money Laundering Act (PMLA) Compliance
Under the PMLA, Secure Wealth must monitor transaction histories and report suspicious transaction patterns that suggest money laundering or terrorist financing. The compliance team monitors high-value transactions, cash-out patterns, and structural splits, reporting suspicious activities to the Financial Intelligence Unit - India (FIU-IND) via Suspicious Transaction Reports (STRs).

### REG-009: Periodic Updating of KYC (Re-KYC)
RBI mandates periodic updates of customer KYC files based on the customer's risk category. Secure Wealth runs Aadhaar e-KYC and digital address validations every 2 years for high-risk customers, every 8 years for medium-risk, and every 10 years for low-risk customers. If a user fails to update their KYC records within the specified timeline, their digital banking channels and investment accounts are suspended.
