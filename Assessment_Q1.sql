-- Q1: Retrieve users who have both savings and investment accounts, along with their total deposits

SELECT 
    u.id AS owner_id,  -- Unique identifier of the user
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the user
    
    -- Count of savings accounts (where is_regular_savings = 1)
    COUNT(IF(p.is_regular_savings = 1, s.id, NULL)) AS savings_count,
    
    -- Count of investment accounts (where is_a_fund = 1)
    COUNT(IF(p.is_a_fund = 1, s.id, NULL)) AS investments_count,
    
    -- Total confirmed deposit amount, converted from kobo to naira and rounded to 2 decimal places
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits

FROM 
    users_customuser u  -- Users table

JOIN 
    savings_savingsaccount s ON s.owner_id = u.id  -- Join to savings accounts using user ID

JOIN 
    plans_plan p ON s.plan_id = p.id  -- Join to plans table using plan ID

GROUP BY 
    u.id, u.first_name, u.last_name  -- Grouping by user identity to aggregate per user

HAVING 
    savings_count >= 1  -- Only include users with at least one savings account
    AND investments_count >= 1  -- ...and at least one investment account

ORDER BY 
    total_deposits DESC;  -- Sort users by their total deposits in descending order
