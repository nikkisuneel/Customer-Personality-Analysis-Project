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
       
              SELECT
                     pt.name AS product_category,
                     AVG(cpt.amount_spent) AS average_spending
              FROM
                     Customer AS c
              JOIN
                     Customer_Promotion AS cp ON c.id = cp.customer_id
              JOIN
                     Promotion AS pm ON cp.promotion_id = pm.id
              JOIN
                     Customer_Product_Type AS cpt ON c.id = cpt.customer_id
              JOIN
                     Product_Type AS pt ON cpt.product_id = pt.id
              WHERE
                     pm.name LIKE 'AcceptedCmp%'
                     AND c.has_complained = 0
              GROUP BY
                     pt.name
              ORDER BY
                     average_spending DESC;



# Hrudhai's Queries
       # Query 1: This query will categorize the customer's income level and determine the most popular item they bought based 
       # on their purchases of wine, fruits, meat products, fish products, sweets, and gold products. 

              WITH CustomerIncomeCategories AS (
                  SELECT
                      id,
                      CASE
                          WHEN income <= 30000 THEN 'Low Income'
                          WHEN income <= 60000 THEN 'Medium Income'
                          WHEN income <= 90000 THEN 'High Income'
                          ELSE 'Very High Income'
                      END AS income_category
                  FROM Customer
              ),
              PopularProducts AS (
                  SELECT
                      c.id AS customer_id,
                      pt.name AS product_name,
                      ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY amount_spent DESC) AS rank
                  FROM Customer_Product_Type AS cpt
                  JOIN Product_Type AS pt ON pt.id = cpt.product_id
                  JOIN Customer AS c ON c.id = cpt.customer_id
              )
              SELECT
                  cic.id AS customer_id,
                  cic.income_category,
                  pp.product_name AS most_popular_item
              FROM CustomerIncomeCategories AS cic
              LEFT JOIN PopularProducts AS pp ON pp.customer_id = cic.id AND pp.rank = 1;
              
        # Query 2: This query calculates the necessary and disposable spending percentages for each customer, based on their income and 
        #          product purchases. It combines the total income and total spent information for each customer, calculates the necessary 
        #          and disposable spending amounts, and then determines the corresponding percentages.
        
              WITH TotalIncome AS (
                  SELECT
                      id,
                      income,
                      SUM(income) OVER () AS total_income
                  FROM Customer
              ),
              TotalSpent AS (
                  SELECT
                      c.id AS customer_id,
                      SUM(CASE
                          WHEN pt.name IN ('Fruits', 'Meat', 'Fish', 'Sweet') THEN cpt.amount_spent
                          ELSE 0
                      END) AS necessary_spent,
                      SUM(CASE
                          WHEN pt.name IN ('Wines', 'Gold') THEN cpt.amount_spent
                          ELSE 0
                      END) AS disposable_spent
                  FROM Customer_Product_Type AS cpt
                  JOIN Product_Type AS pt ON pt.id = cpt.product_id
                  JOIN Customer AS c ON c.id = cpt.customer_id
                  GROUP BY c.id
              )
              SELECT
                     customer_id, 
                     ts.necessary_spent, 
                     ts.disposable_spent, 	
                     ts.necessary_spent + ts.disposable_spent AS added_values,
                  ti.income AS income_range,
                  ((CAST(ts.necessary_spent AS float) / (CAST(ts.necessary_spent AS float) + CAST(ts.disposable_spent AS float))) * 100) AS necessary_percentage,
                     ((CAST(ts.disposable_spent AS float) / (CAST(ts.necessary_spent AS float) + CAST(ts.disposable_spent AS float))) * 100) AS disposable_percentage
              FROM TotalIncome AS ti
              JOIN TotalSpent AS ts ON ts.customer_id = ti.id;        
