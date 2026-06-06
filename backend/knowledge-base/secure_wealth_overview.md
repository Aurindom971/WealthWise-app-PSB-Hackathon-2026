# Secure Wealth - Product Overview Manual

Secure Wealth is a next-generation banking, wealth management, and automated transaction monitoring platform. It combines robust retail banking services, dynamic investment tracking, spending analytics, and an integrated AI fraud-detection engine with an interactive security assistant called SAGE. This document serves as a comprehensive system summary for technical audits, support team onboarding, and vector database retrieval.

---

## 1. What Secure Wealth Does
Secure Wealth is designed to bridge the gap between traditional retail banking and modern automated wealth management while ensuring cybersecurity. The platform allows users to:
* Manage savings accounts, process instant UPI/IMPS transfers, and schedule NEFT/RTGS payments.
* Purchase and monitor equity listings, mutual funds, dynamic option chains, and upcoming IPO offerings.
* Access automated transaction classification, category-level budgeting, and recurring payment analytics.
* Protect accounts using real-time behavioral and statistical anomaly monitoring.
* Consult with SAGE, a secure natural language interface, to answer support questions, query expenses, and explain security events.

---

## 2. Major Modules
The architecture of Secure Wealth is structured around four primary application modules:
1. **Core Banking & Transactions Gateway**: Handles balance checks, beneficiary limits, card locks, and outbound payments (UPI, IMPS, NEFT, RTGS).
2. **Investment & Market Data Module**: Fetches live equity prices, NAV calculations, option chain tables, and IPO application details from public and cached market APIs.
3. **Transaction Monitoring & Fraud Engine**: Processes incoming transaction metadata in real-time, executing deterministic and statistical checks to flag malicious requests.
4. **SAGE AI Intelligence Hub**: Parses natural language inputs, fetches relevant transactional context from backend databases, and generates conversational replies via a security-hardened pipeline.

---

## 3. How Fraud Detection Works
Secure Wealth's fraud engine uses a dual-layer validation model:
* **Deterministic Rules Layer**: Validates transaction inputs against strict operational policies, such as checking for rooted operating systems (jailbreaks), checking for blacklisted IP segments/Tor nodes, and verifying SIM card hardware bindings.
* **Statistical Anomaly Layer**: Matches current transaction parameters against the user's historical profile baseline. The system tracks spending values, transaction time windows, geographic travel velocity, daily transaction frequency, and high-speed multi-transaction bursts (velocity attacks).
If a transaction triggers a high-severity anomaly (such as a velocity burst of more than 3 transactions in 5 minutes), the engine locks the transaction and sets a re-authentication flag (`reauth_required`), prompting the user to complete biometric or video verification.

---

## 4. How Investments are Tracked
Asset tracking within Secure Wealth is handled by dedicated integration services:
* **Stocks**: Leverages `yahoo-finance2` to query active quotes for major symbols like INFY, TCS, RELIANCE, HDFCBANK, and WIPRO. The system caches these quotes for 5 minutes.
* **Mutual Funds**: Connects with the free public MFAPI system (`api.mfapi.in`) to retrieve daily Net Asset Value (NAV) statistics for listed schemes, utilizing a 30-minute cache window.
* **Option Chains**: Accesses NSE option tables for NIFTY and BANKNIFTY. In cases of API rate-limiting or network issues, the system automatically runs a realistic fallback generator that maps spot indexes to ATM strike brackets with synthetic Open Interest (OI) numbers.
* **IPOs**: Pulls current and upcoming NSE issue parameters, converting them to consistent date and price ranges for retail application.

---

## 5. How Risk Scores are Generated
Risk score generation is executed on the backend immediately before transaction settlement:
1. **Anomaly Classification**: Six rules validate the transaction. Each rule outputs a risk score from 0.0 to 1.0.
2. **Weight Allocation**: Each rule has a custom weight:
   * Amount Anomaly: 35
   * New Device ID: 25
   * Velocity Attack (rolling 5 minutes): 25
   * Unusual Time Window: 20
   * Unfamiliar Geolocation Location: 15
   * Daily Transaction Frequency Burst: 15
3. **Normalization and Smoothing**: The sum of all weighted scores is normalized against the maximum possible weight (135) and passed through a power curve calculation (`Math.pow(normalized, 0.85)`). This generates a final risk score (0 to 100). Scores above 70 trigger transaction holds and push security alerts.

---

## 6. How SAGE Works
SAGE (Secure Agent for Guidance and Explanation) operates as an embedded conversational assistant:
1. **Input Processing**: Receives user query messages alongside active customer session tokens.
2. **Intent & Security Filtering**: The input query is parsed by regex and string classifiers to check for transactional actions (e.g. transfer keywords like "send", "pay", "invest"). If an action intent is detected, SAGE immediately blocks the prompt and outputs a security reminder telling the user to use the official menus.
3. **Data Retrieval (RAG)**: For valid informational queries, SAGE queries database systems to fetch context, such as current account balances, 7-day spending totals, or latest transaction logs.
4. **Conversational Synthesis**: Sends the user query, retrieved data context, and strict system safety instructions to a local Llama3 interface. SAGE then returns a concise, accurate 2-to-3 sentence explanation to the user.
