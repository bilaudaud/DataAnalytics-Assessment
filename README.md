# DataAnalytics-Assessment
## Question 1: High-Value Customers with Multiple Products

**Objective:**  
Identify customers who have both at least one funded savings plan and one funded investment plan. The goal is to find high-value users that the business could potentially cross-sell to.

**Approach:**
1. Created a CTE `plan_counts` that counts savings and investment plans per user using the `is_regular_savings` and `is_a_fund` flags.
2. Created another CTE `deposit_totals` to compute total deposits from the `savings_savingsaccount` table, converted from kobo to naira.
3. Joined both with the `users_customuser` table to get user info, using `CONCAT(first_name, last_name)` to display the full name.
4. Filtered users to only those who had at least 1 savings and 1 investment plan.
5. Sorted final result by `total_deposits` in descending order.

**Challenges Encountered:**
- The `name` field in `users_customuser` was always NULL. I solved this by concatenating `first_name` and `last_name`.
- Some joins failed until I normalized `owner_id` and `id` fields using `TRIM` and `LOWER` functions for consistent formatting.

**Technologies Used:**  
SQL (MySQL 8+), CTEs, conditional aggregation, COALESCE

Data Insights
_Q1 Insight:_ Out of all users, only a small segment have both savings and investment plans — ideal for cross-selling.

## Question 2: Transaction Frequency Analysis

**Objective:**  
Segment customers by how frequently they transact each month, using savings transaction history. Categories include:
- High Frequency (≥10/month)
- Medium Frequency (3–9/month)
- Low Frequency (≤2/month)

**Approach:**
1. Used the `transaction_date` field in the `savings_savingsaccount` table to calculate each customer's transaction timeline.
2. Calculated the total number of transactions and how many months passed between their first and last transactions.
3. Computed the average transactions per month.
4. Applied classification logic to group each customer into one of the frequency categories.
5. Aggregated the result by frequency category to report total customers and their average frequency.

**Challenges:**
- Ensured division by zero was avoided using `NULLIF`.
- Used `PERIOD_DIFF()` to account for month-based span between dates.
- Sorted the final output to match the required category order.

**Key SQL Concepts Used:**
CTEs, aggregation, `PERIOD_DIFF`, `CASE`, `ROUND`, conditional logic, and `GROUP BY`.

## Q2 Insights:
- The majority of customers (618) fall under the **Low Frequency** segment, averaging 1.35 transactions/month — which signals a potential area for engagement improvement.
- A smaller subset (128 users) are **highly active**, averaging over 40 transactions/month — these could be prime candidates for loyalty programs or advanced investment offerings.

## Question 3: Account Inactivity Alert

**Objective:**  
Find all active savings or investment plans with no inflow transactions in the past 365 days.

**Approach:**
1. Retrieved the most recent inflow (`confirmed_amount > 0`) per `plan_id` from `savings_savingsaccount`.
2. Joined the result with the `plans_plan` table to identify active plans (not archived or deleted).
3. Classified plans as either “Savings” or “Investment” based on their respective flags.
4. Filtered results to include only those where the last transaction date was over 365 days ago.
5. Calculated inactivity in days using `DATEDIFF(CURDATE(), last_transaction_date)`.

**Key Considerations:**
- Used `MAX(transaction_date)` to get the latest inflow.
- Applied filtering only to active plans.
- Used a `CASE` statement for type labeling.

**Key SQL Concepts Used:**  
CTEs, joins, date difference, conditional expressions, filters.

## Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate each customer’s lifetime value using account tenure and their total inflow transaction volume.

**Approach:**
1. Aggregated the number of inflow transactions (`confirmed_amount > 0`) and their total value (converted from kobo to naira).
2. Calculated tenure in months using `PERIOD_DIFF()` between `CURDATE()` and `users_customuser.date_joined`.
3. Used the CLV formula:
$\text{CLV} = \left( \frac{\text{total\_transactions}}{\text{tenure}} \right) \times 12 \times \text{avg\_profit\_per\_transaction}$

4. Calculated `avg_profit_per_transaction` as 0.1% of the average transaction value.
5. Ordered customers by `estimated_clv` from highest to lowest.

**Hints Incorporated:**
- Used `confirmed_amount` as inflow (from savings_savingsaccount)
- Converted kobo to naira by dividing by 100
- Ensured no division by zero using `NULLIF()`

**Techniques Used:**  
CTEs, `PERIOD_DIFF`, aggregation, profit formula, rounding, and sorting.


### Q2 Visualization & Insights

![Q2 Bar Chart - Avg Transactions per Month] ![image](https://github.com/user-attachments/assets/6abbba45-cc78-4fdc-9716-5e21c89ef815)


**Insights:**
- High Frequency users (128 customers) average over **41 transactions per month**, showing a highly engaged core audience.
- Medium Frequency users (127) perform around **4.7 transactions/month** — they present a prime opportunity for nudges or campaigns to boost engagement.
- The largest group by far (618 users) are Low Frequency customers with **1.35 monthly transactions** on average — this indicates potential retention or reactivation targets.

**Recommendation:**
Introduce personalized savings goals or usage reminders for Medium and Low Frequency groups. Consider A/B testing messages tied to milestones or behavior-based rewards. If you're pushing to GitHub, you can:
