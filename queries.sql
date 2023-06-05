# Nikki's Queries
# Query 1: Combines the averages of the total spending for each category of 
# products and groups them by the levels of education of the customers:
SELECT c.education, pt.name AS category, AVG(cp.amount_spent) AS average_spending
FROM Customer AS c
JOIN Customer_Product_Type AS cp ON c.id = cp.customer_id
JOIN Product_Type AS pt ON cp.product_id = pt.id
GROUP BY c.education, pt.name;

# Query 2: Analyzing the if and what the relationship is between customers and 
# their varying income levels with how they respond to varying marketing campaigns.
SELECT income, 
       AVG(CASE WHEN promotion_id = 1 THEN response ELSE 0 END) AS avg_acceptance_cmp1,
       AVG(CASE WHEN promotion_id = 2 THEN response ELSE 0 END) AS avg_acceptance_cmp2,
       AVG(CASE WHEN promotion_id = 3 THEN response ELSE 0 END) AS avg_acceptance_cmp3,
       AVG(CASE WHEN promotion_id = 4 THEN response ELSE 0 END) AS avg_acceptance_cmp4,
       AVG(CASE WHEN promotion_id = 5 THEN response ELSE 0 END) AS avg_acceptance_cmp5
FROM Customer
JOIN Customer_Promotion ON Customer.id = Customer_Promotion.customer_id
GROUP BY income;
