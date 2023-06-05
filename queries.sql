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
