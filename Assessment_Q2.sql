-- Question 2: Transaction Frequency Analysis
-- Objective:
-- Determine how frequently customers perform transactions and categorize them as:
--   - High Frequency: ≥10 transactions/month
--   - Medium Frequency: 3–9 transactions/month
--   - Low Frequency: ≤2 transactions/month

-- Step 1: Calculate total transactions and duration of activity per customer
WITH customer_activity AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,

        -- Calculate number of months between first and last transaction (inclusive)
        PERIOD_DIFF(
            DATE_FORMAT(MAX(transaction_date), '%Y%m'),
            DATE_FORMAT(MIN(transaction_date), '%Y%m')
        ) + 1 AS months_active
    FROM savings_savingsaccount
    GROUP BY owner_id
),

-- Step 2: Compute average transactions per month and classify frequency level
classified_customers AS (
    SELECT
        owner_id,
        total_transactions,
        months_active,

        -- Compute average and handle divide-by-zero if months_active is 0
        ROUND(total_transactions / NULLIF(months_active, 0), 2) AS avg_transactions_per_month,

        -- Categorize based on average monthly transactions
        CASE
            WHEN total_transactions / NULLIF(months_active, 0) >= 10 THEN 'High Frequency'
            WHEN total_transactions / NULLIF(months_active, 0) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_activity
)

-- Step 3: Aggregate results by frequency category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM classified_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');