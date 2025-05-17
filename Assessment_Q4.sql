-- Question 4: Customer Lifetime Value (CLV) Estimation
-- Objective:
-- Estimate CLV using a simplified formula based on transaction frequency, account tenure, and 0.1% profit per transaction.

-- Step 1: Get total transactions and total value per user from inflow transactions
WITH transaction_summary AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) / 100.0 AS total_value_naira  -- convert from kobo to naira
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
),

-- Step 2: Combine with user info and calculate tenure
clv_calc AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        
        -- Tenure in months from date_joined to today
        PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')) AS tenure_months,

        ts.total_transactions,
        ts.total_value_naira,
        
        -- Average profit per transaction = 0.001 × avg transaction value
        (ts.total_value_naira / NULLIF(ts.total_transactions, 0)) * 0.001 AS avg_profit_per_transaction,

        -- CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
        ROUND(
            (ts.total_transactions / NULLIF(PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')), 0))
            * 12 
            * ((ts.total_value_naira / NULLIF(ts.total_transactions, 0)) * 0.001), 
            2
        ) AS estimated_clv
    FROM users_customuser u
    JOIN transaction_summary ts ON ts.owner_id = u.id
)

-- Step 3: Return results ordered by CLV
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;