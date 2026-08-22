# WealthWise - App Help & Feature Documentation

This document provides user-facing documentation, support articles, and feature explanations for the WealthWise application, including the SAGE AI assistant interface, portfolio tracking tools, and security features.

---

## Risk Score & Fraud Alerts

### HLP-001: Understanding Your Transaction Risk Score
The WealthWise Risk Score is a security metric calculated in real-time for every transaction initiated on your account. The score ranges from 0 to 100, where higher numbers represent a higher likelihood of unauthorized activity. It is determined by analyzing your device fingerprint, transaction location, recent transfer speed (velocity), and recipient VPA. You can view this score in the Transaction History ledger details.

### HLP-002: What triggers a Fraud Alert on WealthWise?
A Fraud Alert is triggered when the transaction monitoring engine assigns a risk score above 70 to a transfer request. This occurs during anomalies like login attempts from foreign locations, high-value transfers to newly added recipients, or rapid consecutive transactions. When triggered, WealthWise holds the transfer, sends a push alert, and requires biometrics or video verification to complete the transaction.

### HLP-003: Resolving a False Positive Fraud Alert
If the app flags a legitimate transaction as suspicious, you can resolve the alert directly inside the app. Open the notification tray, tap the pending alert, and select "I Authorized This Transaction". The app will prompt you to complete a face scan or enter your passcode. Once verified, the transaction completes, and the system updates its behavioral profile to prevent similar alerts in the future.

---

## Spending Analytics & Transaction Monitoring

### HLP-004: Interactive Spending Analytics Dashboard
WealthWise's Spending Analytics tab automatically categorizes your debits into buckets like Food, Utilities, Investments, Shopping, and Travel. The system uses merchant category codes (MCCs) to group transactions and displays them in charts. You can use this dashboard to set category budgets, view month-on-month changes, and identify areas to optimize your spending.

### HLP-005: Custom Budget Alerts and Category Thresholds
To manage your expenses, you can set custom monthly budgets for specific spending categories. Navigate to Analytics, select "Set Budget", choose a category, and enter your monthly limit. The app will send push alerts when you reach 50%, 80%, and 100% of your budget. If you exceed the limit, the app will request additional confirmation before authorizing further transactions in that category.

### HLP-006: Transaction Ledgers and Filter Options
The Transaction History ledger provides a record of all incoming and outgoing funds. You can filter transactions by category (e.g., UPI, card debits, investments), date range, amount slabs, or specific keywords. Tapping on any transaction shows the status (Successful, Pending, Failed), receipt details, beneficiary bank, processing channel, and related risk analytics.

---

## Investment Dashboard & Portfolio Tracking

### HLP-007: Navigating the Investment Dashboard
The Investment Dashboard provides a view of your linked wealth accounts, including Stocks, Mutual Funds, IPOs, and retirement plans. The main screen displays your portfolio value, total investment cost, current market value, and absolute and percentage returns. Tabs allow you to switch views to inspect specific stock gains, fund performance history, or modify recurring investments.

### HLP-008: Real-Time Stock Portfolio Tracking
Our Stocks tab features live tracking for major equity listings. It integrates with market data feeds to display live stock prices, daily changes, and portfolio allocation percentages. Clicking on a specific holding shows your average purchase price, quantity, current valuation, and historical price charts. You can execute market orders directly from this dashboard.

### HLP-009: Mutual Fund NAV Tracking and SIP Management
The Mutual Funds dashboard tracks Net Asset Value (NAV) updates for all your investments. The dashboard lists your active Systematic Investment Plans (SIPs), upcoming payment dates, and performance against benchmark indices. You can set up new SIPs, execute lump-sum purchases, pause active SIP schedules, or redeem units directly to your bank account.

---

## AI Assistant SAGE

### HLP-010: Conversing with SAGE — Your AI Financial Guide
SAGE is an AI assistant integrated directly into WealthWise. You can access SAGE by tapping the chat icon on the home screen. SAGE helps you query transaction histories (e.g., "How much did I spend on food last week?"), analyze portfolio performance, or find app settings. For security reasons, SAGE operates in an read-only query mode and cannot execute transfers.

### HLP-011: SAGE's Security Filter and Action Restrictions
To protect your funds, SAGE has strict security filters that block transactional intents. If you ask SAGE to "send ₹1,000 to John" or "buy Reliance shares", the assistant will explain that it cannot execute transactions or modify portfolios. It will instead guide you to the correct app menu to perform the action securely.

### HLP-012: Inquiring about Fraud Alerts with SAGE
If you receive a fraud alert or want to understand why a transaction was flagged, you can ask SAGE. SAGE queries the transaction monitoring system and provides a simple summary of the risk factors, such as: "This transfer was flagged because it was sent from a new device in a different city. You can authorize it using face recognition under the alerts tab."

---

## App Features & Implementation Details

### HLP-013: Risk Score Calculation Parameters & Weighting
WealthWise's risk engine dynamically calculates scores based on six distinct transactional factors, totaling a maximum baseline weight of 135. Amount anomalies contribute up to a weight of 35 based on Z-score deviation; time anomalies carry a weight of 20 relative to circular hour distances; unrecognized device IDs carry a weight of 25; unfamiliar location geolocation mismatch carries 15; daily frequency triggers carry 15; and rolling 5-minute velocity checks contribute 25. The consolidated score is normalized against the maximum weight (135) and smoothed using a power curve of 0.85 before conversion to a final percentage score.

### HLP-014: Rules of the Fraud Detection Engine
The backend fraud engine executes a deterministic sequence of evaluation rules. First, it queries historical database transaction baselines to extract standard deviation values for user transactions. It computes time deviations relative to historical hour ranges (e.g., standard sleep hours vs. waking activity). Location anomalies match current inputs against the user's historical coordinates, and frequency tracks transactions executed within a sliding 24-hour window. Re-authentication prompts are dynamically raised specifically if a high-velocity attack is verified.

### HLP-015: Investment Portfolio Module Components
The WealthWise investment system bridges retail markets with personal bank accounts. It tracks stocks using the yahoo-finance2 library for real-time asset pricing, fetches mutual fund values using the public MFAPI schema, and collects option chain and IPO listings through customized parsing services that automatically invoke resilient fallbacks during NSE server rate-limiting or cookie blocking. The frontend displays these assets across dedicated tabs with live profit/loss and allocation distributions.

### HLP-016: Bills & Payments Processing
The payments interface facilitates standard bill pay services, including cellular recharge, utility clearance, DTH mapping, and insurance premiums. Transactions are processed securely through payment aggregation nodes that require double-auth confirmations. Every outbound bill pay request is parsed by the security gateway for synthetic payee checks and account takeover alerts to prevent automated funds drainage.

### HLP-017: Transaction Insights Engine
The insights processor uses local SQLite databases and remote analytics warehouses to categorize raw statement narratives. The parser applies pattern matching to identify transaction channels, extract merchant identifiers, and classify purchases. Monthly summary cards display savings opportunities, recurring subscription bills, and anomalies like double-billing or sudden rate adjustments automatically to keep users informed.

### HLP-018: SAGE Assistant Intent Processing
SAGE runs a natural language parsing engine powered by localized LLM interfaces (e.g. Llama3 models). Upon receiving an query, the intent analyzer categorizes the request as informational, analytical, or action-based. If an action-based intent (e.g., transferring funds, changing passwords) is detected, SAGE blocks execution at the runtime layer, outputting a security warning instructing the user to navigate to the official payment and settings pages manually.

