# Nikki's Queries
# Query 1: Combines the averages of the total spending for each category of 
# products and groups them by the levels of education of the customers:
       
SELECT c.education, pt.name AS category, AVG(cp.amount_spent) AS average_spending
  FROM Customer AS c
  JOIN Customer_Product_Type AS cp ON c.id = cp.customer_id
  JOIN Product_Type AS pt ON cp.product_id = pt.id
  GROUP BY c.education, pt.name;

# Query 2: Finding the most popular marketing campaign for each product category, 
# and calculate the average spending per product category for customers who have 
# responded positively to marketing campaigns. 
       
SELECT
  pt.name AS product_category,
  AVG(cpt.amount_spent) AS average_spending,
  pm.name AS most_popular_campaign
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
JOIN
  (
    SELECT
      cpt.product_id,
      cp.promotion_id,
      COUNT(*) AS campaign_count
    FROM
      Customer_Product_Type AS cpt
    JOIN
      Customer_Promotion AS cp ON cpt.customer_id = cp.customer_id
    GROUP BY
      cpt.product_id,
      cp.promotion_id
    ORDER BY
      cpt.product_id,
      campaign_count DESC
  ) AS pc ON pt.id = pc.product_id AND pm.id = pc.promotion_id
WHERE
  pm.name LIKE 'AcceptedCmp%'
  AND c.has_complained = 0
  AND pc.campaign_count = (
    SELECT MAX(campaign_count)
    FROM (
      SELECT
        cpt.product_id,
        cp.promotion_id,
        COUNT(*) AS campaign_count
      FROM
        Customer_Product_Type AS cpt
      JOIN
        Customer_Promotion AS cp ON cpt.customer_id = cp.customer_id
      GROUP BY
        cpt.product_id,
        cp.promotion_id
    ) AS subquery
    WHERE subquery.product_id = pc.product_id
  )
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
              
# Jenny's Queries
# Query 1: Calculates the average amounts spent across product categories
# (wine, fruit, meat, fish, sweets, and gold) by customers based on the number of children (kids_in_home) and 
# teenagers (teens_in_home) in a customer’s household.

SELECT
    kids_in_home,
    teens_in_home,
    AVG(CASE WHEN pt.name = 'Wines' THEN cp.amount_spent END) AS avg_wine_spending,
    AVG(CASE WHEN pt.name = 'Fruits' THEN cp.amount_spent END) AS avg_fruit_spending,
    AVG(CASE WHEN pt.name = 'Meat' THEN cp.amount_spent END) AS avg_meat_spending,
    AVG(CASE WHEN pt.name = 'Fish' THEN cp.amount_spent END) AS avg_fish_spending,
    AVG(CASE WHEN pt.name = 'Sweet' THEN cp.amount_spent END) AS avg_sweet_spending,
    AVG(CASE WHEN pt.name = 'Gold' THEN cp.amount_spent END) AS avg_gold_spending
FROM
    Customer AS c
    JOIN Customer_Product_Type AS cp ON c.id = cp.customer_id
    JOIN Product_Type AS pt ON cp.product_id = pt.id
GROUP BY
    kids_in_home,
    teens_in_home;
    
# Query 2: Calculates the average duration of customer enrollment according to education
# level, marital status, and income level in order to better understand customer loyalty 
# across customer segments. 

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
)

SELECT
    c.education,
    c.marital_status,
    ci.income_category,
    ROUND(AVG(CAST(CURRENT_DATE - c.enrollment_date AS INTEGER)), 2) AS avg_enrollment_duration
FROM
    Customer AS c
LEFT JOIN
    CustomerIncomeCategories AS ci ON c.id = ci.id
GROUP BY
    c.education,
    c.marital_status,
    ci.income_category
ORDER BY
    c.education,
    c.marital_status,
    ci.income_category;

# Teerth's Queries:
#
# Query 1: The SQL query retrieves data from the "Customer" table and performs several calculations. 
# First, it extracts the enrollment year from the "enrollment_date" column for each customer and casts it as an integer.
# Next, it counts the distinct customer IDs to determine the total number of customers for each enrollment year.
# Then, it uses a conditional statement to count the distinct customer IDs for customers who have a "Recency" value greater than 30, 
# indicating churned customers. Finally, it calculates the churn rate by dividing the count of churned customers by the total number 
# of customers and multiplying by 100. The results are grouped by enrollment year and ordered in ascending order.

SELECT CAST(substr(enrollment_date, 7, 4) AS INTEGER) AS EnrollmentYear,
       COUNT(DISTINCT(id)) AS TotalCustomers,
       COUNT(DISTINCT CASE WHEN Recency > 30 THEN id END) AS ChurnedCustomers,
       (COUNT(DISTINCT CASE WHEN Recency > 30 THEN id END) * 100 / COUNT(DISTINCT id)) AS ChurnRate
FROM Customer
GROUP BY EnrollmentYear
ORDER BY EnrollmentYear;
