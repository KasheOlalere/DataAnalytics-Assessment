-- Q2: Categorize customers based on the average frequency of their transactions per month

-- Step 1: Calculate total transactions and number of active months per user
WITH transactions AS (
    SELECT
        s.owner_id,  -- User ID
        COUNT(*) AS total_transactions,  -- Total number of transactions
        -- Number of active months between first and last transaction
        TIMESTAMPDIFF(MONTH, MIN(s.created_on), MAX(s.transaction_date)) + 1 AS active_months
    FROM 
        savings_savingsaccount s
    GROUP BY 
        s.owner_id
),

-- Step 2: Calculate average monthly transaction frequency per user
customer_avg AS (
    SELECT
        t.owner_id,
        t.total_transactions,
        t.active_months,
        ROUND(t.total_transactions / t.active_months, 2) AS monthly_avg  -- Average transactions per month
    FROM 
        transactions t
),

-- Step 3: Categorize users based on their average transaction frequency
category AS (
    SELECT
        CASE
            WHEN monthly_avg >= 10 THEN 'High Frequency'
            WHEN monthly_avg BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        monthly_avg
    FROM 
        customer_avg
)

-- Final Output: Count of users in each frequency category and their average transaction frequency
SELECT
    frequency_category,
    COUNT(*) AS customer_count,  -- Number of users in each category
    ROUND(AVG(monthly_avg), 2) AS avg_transactions_per_month  -- Average monthly frequency for the category
FROM 
    category
GROUP BY 
    frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');  -- Custom order of categories
