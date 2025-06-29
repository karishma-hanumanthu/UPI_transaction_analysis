# UPI_transaction_analysis SQL Project
A data-driven analysis using SQL and Pandas to extract insights and detect fraud from UPI transactions.This project explores transaction behaviors, spending patterns and detects fraud trends based on user demographics, device types, bank activity, and more.

## Project Objective

To analyze UPI transaction data from various angles such as:

- Overall transaction volume & patterns
- Spend trends across categories, states, and time
- User behaviour by age, device and network
- Fraud detection across banks, transaction types, and age groups

## Tools & Technologies

- **SQL** 
- **Python(Pandas)** 
- **Jupyter in VS code**

## Process Overview
1. Data Understanding:
- I began by exploring the dataset to understand the structure, key columns, and      types of information available.
2. Data Preprocessing with Python (Pandas)
- Renamed columns for better readability
- Removed irrelevant or redundant columns
- Converted data types to appropriate formats to ensure consistency
3. Data Analysis with SQL:
- After preparing the data, I performed extensive analysis using SQL to answer various business and fraud-related questions. This included insights on transaction patterns, user behavior, fraud rates, and trends across time, banks, age groups, and device types.

##  Dataset Overview

The dataset includes **anonymized UPI transaction records from 2024**, with the following columns:
Key Columns Include:
- **transaction_id**: Unique identifier for each transaction
- **timestamp**: Date and time of the transaction
- **transaction_type**: Type of UPI transaction (e.g., P2P, P2M)
- **merchant_category**: Category of the merchant
- **amount_inr**: Transaction amount in Indian Rupees
- **transaction_status**: Whether the transaction succeeded or failed
- **sender_age_group & receiver_age_group**: Age group classifications
- **sender_state**: Originating state of the sender
- **sender_bank & receiver_bank**: Banks involved in the transaction
- **device_type**: Type of device used (e.g., Android, iOS)
- **network_type**: Internet connection type (e.g., 4G, Wi-Fi)
- **fraud_flag**: Binary flag indicating whether the transaction was fraudulent
- **day_of_week**: Day the transaction took place

## Key Business Insights
### **General Insights**
- What is the total volume and average value of transactions?
-  What are the busiest months, days, and hours for UPI usage?
- Which merchant categories attract the most spend?
- Which banks process the most UPI volume?
### **Behavioral Analysis**
- Which age groups spend the most and on what categories?
- How do users across age groups use different devices?
- What network types (Wi-Fi, 4G) are most used by each age group?
### **Risk & Fraud Analysis**
- What is the fraud rate by:
   - Bank (sender/receiver)
   - Network type
   - Transaction type
   - Merchant category
   - Age group
   - State
   - Transaction amount range
- Which transaction types are most affected by fraud?
- How does fraud vary across age groups and network types?

## Sample SQL Queries
1. Which Age Group Spends the Most via UPI?
```sql
SELECT
    sender_age_group,
    SUM(amount_inr) AS total_spent,
    ROUND(SUM(amount_inr) * 100.0 / SUM(SUM(amount_inr)) OVER(), 2) AS percentage_share
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY total_spent DESC;
```
2. Which Network Type Has the Highest Fraud Rate?
```sql
SELECT 
    network_type,
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_transactions,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY network_type
ORDER BY fraud_rate_percent DESC;
```
3.  Which Banks Are Most Frequently Used in UPI Transactions?
```sql
WITH all_banks AS (
    SELECT sender_bank AS bank FROM upi_transactions
    UNION ALL
    SELECT receiver_bank FROM upi_transactions
),
bank_usage AS (
    SELECT bank, COUNT(*) AS total_transactions
    FROM all_banks
    GROUP BY bank
)
SELECT 
    bank,
    total_transactions,
    ROUND(total_transactions * 100.0 / SUM(total_transactions) OVER(), 2) AS usage_percentage
FROM bank_usage
ORDER BY total_transactions DESC;
```
4. Fraud Rate by Transaction Amount Range
```sql
SELECT 
    CASE 
        WHEN amount_inr < 500 THEN 'Low'
        WHEN amount_inr BETWEEN 500 AND 5000 THEN 'Medium'
        ELSE 'High' 
    END AS amount_range,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM upi_transactions
GROUP BY 
    CASE 
        WHEN amount_inr < 500 THEN 'Low'
        WHEN amount_inr BETWEEN 500 AND 5000 THEN 'Medium'
        ELSE 'High' 
    END
ORDER BY fraud_rate DESC;
```
## Findings & Insights
- Transaction Trends
  - UPI usage is high across months, with certain months showing peak activity.
  - Most transactions happen on specific weekdays, indicating user behavior trends.
  - P2P and P2M transaction types show varying usage and spend patterns.
- Demographic Patterns
  - Age groups 25–34 and 35–44 contribute the highest transaction value.
  - Different device types are preferred by different age groups.
  - Key merchant categories like shopping and groceries drive the most spend.
- Bank & Regional Analysis
  - Certain banks dominate UPI usage as senders/receivers.
  - States like Maharastra, Uttar Pradesh, Karnataka show higher volume and value of transactions.
- Fraud Insights
  - Fraud is present in a small but important share of transactions.
  - Some banks, states, and merchant categories show higher fraud rates.
  - Fraud likelihood increases with transaction amount and varies by network type and age group.
 
## Conclusion
This project highlights key patterns in UPI usage and fraud. It helps identify high-risk areas like certain banks, networks, or age groups, and gives insight into user behavior such as spending trends and transaction habits.
These findings can support better fraud control, improve user experience, and guide smarter decisions in digital banking.







