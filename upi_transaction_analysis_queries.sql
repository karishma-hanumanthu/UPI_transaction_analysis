CREATE TABLE upi_transactions(
	[transaction_id] VARCHAR(50),
	[timestamp] DATETIME,
	[transaction_type] VARCHAR(50),
	[merchant_category] VARCHAR(100),
	[amount_inr] INT,
	[transaction_status] VARCHAR(50),
	[sender_age_group] VARCHAR(20),
	[receiver_age_group] VARCHAR(20),
	[sender_state] VARCHAR(50),
	[sender_bank] VARCHAR(20),
	[receiver_bank] VARCHAR(20),
	[device_type] VARCHAR(30),
	[network_type] VARCHAR(50),
	[fraud_flag] INT,
	[day_of_week] VARCHAR(50)
)

SELECT* FROM upi_transactions;

--1.What is the total number of UPI transactions and the overall transaction amount and average transaction value?
SELECT
	COUNT(*) AS total_no_of_transactions,
	SUM(amount_inr) AS total_amount,
	AVG(amount_inr) AS avg_total_amount
FROM upi_transactions;

--2.How does the total transaction amount vary across different months in 2024?
SELECT 
	DATENAME(MONTH,timestamp) AS month_2024,
	SUM(amount_inr) AS spend_per_month,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percentage_per_month
FROM upi_transactions
GROUP BY DATENAME(MONTH,timestamp)
ORDER BY spend_per_month DESC

--3.On which day of the week do most UPI transactions occur?
SELECT
	day_of_week,
	COUNT(*) AS transactions_count
FROM upi_transactions
GROUP BY day_of_week 
ORDER BY transactions_count DESC

--4.How many UPI transactions were successful versus failed?
SELECT*, ROUND(status_count*100.0/SUM(status_count) OVER(),2) AS status_percentage 
FROM(
SELECT
	transaction_status,
	COUNT(*) AS status_count
FROM upi_transactions
GROUP BY transaction_status)A
GROUP BY transaction_status,status_count

--5.How is spending distributed across different transaction types?
SELECT
	transaction_type,
	SUM(amount_inr) AS sum_amount,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percn
FROM upi_transactions
GROUP BY transaction_type
ORDER BY sum_amount DESC

--6.Which merchant categories received the most spending?
SELECT 
	merchant_category,
	SUM(amount_inr) AS spend_per_merchant,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percentage_share
FROM upi_transactions
GROUP BY merchant_category
ORDER BY spend_per_merchant DESC

--7.Which sender age group spends the most through UPI?
SELECT
	sender_age_group,
	SUM(amount_inr) AS amount_per_agegroup,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percentage_share
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY amount_per_agegroup DESC

--8.How does spending vary by merchant category across different age groups?
SELECT
	sender_age_group,
	merchant_category,
	SUM(amount_inr) as amount_spent,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percn
FROM upi_transactions
GROUP BY sender_age_group,merchant_category
ORDER BY amount_spent DESC

--9.Which device types are preferred by different age groups during UPI transactions?
SELECT 
	sender_age_group,
	device_type,
	COUNT(*) AS usage_count
FROM upi_transactions
GROUP BY sender_age_group,device_type
ORDER BY sender_age_group,device_type

--10.Which states have the highest transaction volume and value?
SELECT 
	sender_state,
	COUNT(*) AS no_of_transactions,
	SUM(amount_inr) AS amount_sum,
	ROUND(SUM(amount_inr)*100.0/SUM(SUM(amount_inr)) OVER(),2) AS percentage
FROM upi_transactions 
GROUP BY sender_state 
ORDER BY amount_sum DESC,no_of_transactions DESC

--11.What is the total transaction volume handled by each sender bank?
SELECT
	sender_bank,
	SUM(amount_inr) AS total_amount
FROM upi_transactions
GROUP BY sender_bank
ORDER BY total_amount DESC

--12.Which banks have the highest monthly transaction volume in 2024?
SELECT 
	MONTH(timestamp) AS transaction_month,
	sender_bank,
	SUM(amount_inr) AS amount_volume,
	SUM(amount_inr)*100.0/sum(sum(amount_inr)) OVER(partition by MONTH(timestamp)) AS amount_percentage
FROM upi_transactions
GROUP BY MONTH(timestamp),sender_bank
ORDER BY MONTH(timestamp),amount_percentage DESC;

--13.Which banks (sender + receiver combined) are the most frequently involved in UPI transactions?
WITH bank_list AS(
SELECT
	sender_bank AS bank_name
FROM upi_transactions
UNION ALL
SELECT 
	receiver_bank
FROM upi_transactions)

,cte AS(
SELECT bank_name,COUNT(*) AS bank_count
FROM bank_list 
GROUP BY bank_name)

SELECT*,ROUND((bank_count*100.0/SUM(bank_count) OVER()),2) AS percn
FROM cte
GROUP BY bank_name,bank_count
ORDER BY bank_count DESC

--14.List of fraud transactions sorted by highest first
SELECT*
FROM upi_transactions
WHERE fraud_flag=1
ORDER BY amount_inr DESC

--15.Which merchant categories have the highest fraud rate?
SELECT 
    merchant_category,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY merchant_category
ORDER BY fraud_rate_percent DESC

--16.Which sender banks have the highest fraud rate?
SELECT 
    sender_bank,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_bank
ORDER BY fraud_rate_percent DESC;

--17.Which receiver banks have the highest fraud rate?
SELECT 
    receiver_bank,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY receiver_bank
ORDER BY fraud_rate_percent DESC;

--18.Which network types show higher rates of fraud?
SELECT 
    network_type,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM upi_transactions
GROUP BY network_type
ORDER BY fraud_rate DESC;

--19.Which age groups are more susceptible to fraud?
SELECT 
    sender_age_group,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_age_group
ORDER BY fraud_rate_percent DESC;

--20.How does fraud rate vary across age groups and network types?
SELECT 
    sender_age_group,
    network_type,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) AS fraud_txns,
    ROUND(COUNT(CASE WHEN fraud_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent
FROM upi_transactions
GROUP BY sender_age_group, network_type
ORDER BY fraud_rate_percent DESC;

--21.What is the failure rate of transactions across different network types?
SELECT 
    network_type,
    COUNT(*) AS total_txns,
    COUNT(CASE WHEN transaction_status = 'FAILED' THEN 1 END) AS failed_txns,
    ROUND(COUNT(CASE WHEN transaction_status = 'FAILED' THEN 1 END) * 100.0 / COUNT(*), 2) AS failure_rate
FROM upi_transactions
GROUP BY network_type
ORDER BY failure_rate ASC;

--22.How does the likelihood of fraud vary across transaction amount ranges (low/medium/high)?
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

--23.Which transaction types are most vulnerable to fraud, and what is their average fraudulent amount?
SELECT 
	transaction_type,
	COUNT(fraud_flag) as no_of_fraud,
	SUM(amount_inr) AS total_amount,
	AVG(amount_inr) AS fraud_amount
FROM upi_transactions
WHERE fraud_flag=1
GROUP BY transaction_type
ORDER BY fraud_amount DESC

--24.Which states report the highest number and value of fraudulent transactions?
SELECT
	sender_state,
	COUNT(*) AS fraud_count,
	SUM(amount_inr) AS fraud_amount,
	COUNT(*)*100.0/SUM(COUNT(*)) OVER() AS percentage
FROM upi_transactions
WHERE fraud_flag=1
GROUP BY sender_state
ORDER BY fraud_count DESC

















