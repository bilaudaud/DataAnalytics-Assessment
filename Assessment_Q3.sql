-- Question 3: Account Inactivity Alert
-- Objective:
-- Find active savings or investment plans with no inflow transactions in the past 365 days.

-- Step 1: Get last inflow (confirmed deposit) date per plan
WITH last_transactions AS (
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- Only inflow transactions
    GROUP BY plan_id
)

-- Step 2: Combine with plans and filter inactive accounts
SELECT
    p.id AS plan_id,
    p.owner_id,
    
    -- Classify the plan type
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    
    lt.last_transaction_date,
    
    -- Calculate days since last transaction
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days

FROM plans_plan p

-- Join with last known transaction
LEFT JOIN last_transactions lt ON p.id = lt.plan_id

-- Include only active plans
WHERE p.is_deleted = 0 
  AND p.is_archived = 0
  AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)

-- Only show if it's been more than 365 days since the last transaction
  AND DATEDIFF(CURDATE(), lt.last_transaction_date) > 365;