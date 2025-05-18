-- Q4: Estimate Customer Lifetime Value (CLV) based on transaction behavior and tenure

SELECT 
    u.id AS customer_id,  -- Unique user ID
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the user
    -- Number of months since the user registered
    TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,
    -- Total number of confirmed transactions for this user
    COUNT(s.id) AS total_transactions,
    -- Estimated Customer Lifetime Value (CLV) formula:
    -- ((Annualized transaction count) * (average transaction value * 0.001)) rounded to 2 decimal places
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()), 0)) * 12 *  -- Annualized frequency
        ((SUM(s.confirmed_amount) / 100.0 * 0.001) / NULLIF(COUNT(s.id), 0)), -- Avg value per transaction * margin rate
        2
    ) AS estimated_clv

FROM 
    users_customuser u  -- Users table

-- Join to savings accounts to access confirmed transactions
JOIN 
    savings_savingsaccount s 
    ON u.id = s.owner_id 
    AND s.confirmed_amount > 0  -- Only include confirmed deposits

WHERE 
    u.is_active = 1  -- Only include active users

GROUP BY 
    u.id, u.first_name, u.last_name, u.created_on

ORDER BY 
    estimated_clv DESC;  -- Rank customers by estimated lifetime value (highest first)
