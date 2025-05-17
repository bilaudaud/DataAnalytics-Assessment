-- Question 1: High-Value Customers with Multiple Products
-- Objective:
-- Identify users who have at least one funded savings plan AND one funded investment plan.
-- Then calculate how much they've deposited (from savings_savingsaccount), and display their full name.
-- Final output is sorted by total_deposits (in naira) descending.

-- Step 1: Get number of savings and investment plans per user
WITH plan_counts AS (
    SELECT
        -- Normalize owner_id for joining
        TRIM(LOWER(owner_id)) AS owner_id,
        
        -- Count savings plans (flag: is_regular_savings = 1)
        SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,

        -- Count investment plans (flag: is_a_fund = 1)
        SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count
    FROM plans_plan
    WHERE is_deleted = 0 AND is_archived = 0  -- Only include active plans
    GROUP BY TRIM(LOWER(owner_id))
),

-- Step 2: Get total deposits per user from the savings_savingsaccount table
deposit_totals AS (
    SELECT
        TRIM(LOWER(owner_id)) AS owner_id,
        
        -- Sum confirmed deposits, converting from kobo to naira
        SUM(confirmed_amount) / 100.0 AS total_deposits
    FROM savings_savingsaccount
    GROUP BY TRIM(LOWER(owner_id))
)

-- Step 3: Join both sets with the users table to get final result
SELECT
    u.id AS owner_id,
    
    -- Combine first and last name for full name display
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    
    pc.savings_count,
    pc.investment_count,
    
    -- Default to 0.0 if user has no deposits
    COALESCE(dt.total_deposits, 0.0) AS total_deposits

FROM plan_counts pc

-- Join to get deposit totals
LEFT JOIN deposit_totals dt 
    ON dt.owner_id = pc.owner_id

-- Join to get user info; use TRIM+LOWER for safe ID match
JOIN users_customuser u 
    ON LOWER(TRIM(u.id)) = pc.owner_id

-- Only include users who have both a savings and investment plan
WHERE pc.savings_count >= 1 AND pc.investment_count >= 1

-- Sort users by total deposits in descending order
ORDER BY total_deposits DESC;
