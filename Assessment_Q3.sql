-- Q3: Identify active (non-archived, non-deleted) savings or investment plans 
-- that have been inactive for more than 365 days based on the last transaction date

SELECT 
    p.id AS plan_id,  -- Unique identifier of the plan
    p.owner_id,  -- User who owns the plan
    -- Determine the type of the plan: Savings, Investment, or Unclassified
    CASE 
        WHEN p.is_regular_savings THEN 'Savings'
        WHEN p.is_a_fund THEN 'Investment'
        ELSE 'Unclassified'
    END AS type,
    -- Most recent transaction date (or fallback to plan creation date if no transactions exist)
    COALESCE(MAX(s.transaction_date), p.created_on) AS last_transaction_date,
    -- Number of days since the last transaction (or since creation if no transactions exist)
    DATEDIFF(CURDATE(), COALESCE(MAX(s.transaction_date), p.created_on)) AS inactivity_days

FROM 
    plans_plan p  -- Plans table (can be savings or investments)

-- Left join to savings accounts to gather transaction data if available
LEFT JOIN 
    savings_savingsaccount s 
    ON s.plan_id = p.id 
    AND s.owner_id = p.owner_id
    AND s.confirmed_amount > 0  -- Only consider confirmed transactions
    AND s.transaction_date IS NOT NULL  -- Ignore records with no transaction date

WHERE 
    -- Only include regular savings or fund-based plans
    (p.is_regular_savings = TRUE OR p.is_a_fund = TRUE)
    -- Exclude archived or deleted plans
    AND p.is_archived = FALSE
    AND p.is_deleted = FALSE

GROUP BY 
    p.id, p.owner_id, p.is_regular_savings, p.is_a_fund, p.created_on

HAVING 
    inactivity_days > 365  -- Only include plans inactive for more than a year

ORDER BY 
    inactivity_days DESC;  -- Show the most inactive plans first
