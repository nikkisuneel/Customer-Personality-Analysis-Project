-- Creating a customer table
CREATE TABLE IF NOT EXISTS Customer (
    id INTEGER PRIMARY KEY,
    birth_year INTEGER,
    education VARCHAR,
    marital_status VARCHAR,
    income INTEGER,
    kids_in_home INTEGER,
    teens_in_home INTEGER,
    enrollment_date DATE,
    recency INTEGER,
    has_complained BOOLEAN,
    num_web_visits INTEGER
);

-- Insert into Customer table
-- Copying data from customerdata table to the Customer table
INSERT INTO Customer (id, birth_year, education, marital_status, income, kids_in_home, teens_in_home, enrollment_date, recency, has_complained, num_web_visits)
SELECT ID, Year_Birth, Education, Marital_Status, Income, Kidhome, Teenhome, Dt_Customer, Recency, Complain, NumWebVisitsMonth
FROM customerdata;
-- END OF Into Customer table

-- Create table Purchase_Source
CREATE TABLE IF NOT EXISTS Purchase_Source (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR
);

-- Creating a linking table Customer_Purchase_Source
CREATE TABLE IF NOT EXISTS Customer_Purchase_Source (
    customer_id INTEGER REFERENCES Customer(id),
    purchase_source_id INTEGER REFERENCES Purchase_Source(id),
    num_of_purchases INTEGER
);

-- Insert into Purchase_Source table
-- Inserting purchase sources into the Purchase_Source table
INSERT INTO Purchase_Source(name) VALUES ('Web');
INSERT INTO Purchase_Source(name) VALUES ('Catalog');
INSERT INTO Purchase_Source(name) VALUES ('Store');

-- Insert into Customer_Purchase_Source table
-- Inserting customer purchase source data into the Customer_Purchase_Source table
INSERT INTO Customer_Purchase_Source (customer_id, purchase_source_id, num_of_purchases)
SELECT c.id, ps.id, c.NumWebPurchases
FROM customerdata AS c
JOIN Purchase_Source AS ps ON ps.name = 'Web';

INSERT INTO Customer_Purchase_Source (customer_id, purchase_source_id, num_of_purchases)
SELECT c.id, ps.id, c.NumCatalogPurchases
FROM customerdata AS c
JOIN Purchase_Source AS ps ON ps.name = 'Catalog';

INSERT INTO Customer_Purchase_Source (customer_id, purchase_source_id, num_of_purchases)
SELECT c.id, ps.id, c.NumStorePurchases
FROM customerdata AS c
JOIN Purchase_Source AS ps ON ps.name = 'Store';

-- Create Promotion and Customer_Promotion tables
CREATE TABLE Promotion (
    id INTEGER PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE Customer_Promotion (
    customer_id INTEGER,
    promotion_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES Customer(id),
    FOREIGN KEY (promotion_id) REFERENCES Promotion(id)
);

-- Insert into Promotion table
-- Inserting promotion names into the Promotion table
INSERT INTO Promotion(name) VALUES ('AcceptedCmp1');
INSERT INTO Promotion(name) VALUES ('AcceptedCmp2');
INSERT INTO Promotion(name) VALUES ('AcceptedCmp3');
INSERT INTO Promotion(name) VALUES ('AcceptedCmp4');
INSERT INTO Promotion(name) VALUES ('AcceptedCmp5');

-- Insert into Customer_Promotion linking table
-- Inserting customer promotion data into the Customer_Promotion table
INSERT INTO Customer_Promotion(customer_id, promotion_id)
SELECT c.id, pm.id
FROM customerdata AS c
JOIN Promotion AS pm ON pm.name = 'AcceptedCmp1';

INSERT INTO Customer_Promotion(customer_id, promotion_id)
SELECT c.id, pm.id
FROM customerdata AS c
JOIN Promotion AS pm ON pm.name = 'AcceptedCmp2';

INSERT INTO Customer_Promotion(customer_id, promotion_id)
SELECT c.id, pm.id
FROM customerdata AS c
JOIN Promotion AS pm ON pm.name = 'AcceptedCmp3';

INSERT INTO Customer_Promotion(customer_id, promotion_id)
SELECT c.id, pm.id
FROM customerdata AS c
JOIN Promotion AS pm ON pm.name = 'AcceptedCmp4';

INSERT INTO Customer_Promotion(customer_id, promotion_id)
SELECT c.id, pm.id
FROM customerdata AS c
JOIN Promotion AS pm ON pm.name = 'AcceptedCmp5';

-- Create Product_Type and Customer_Product_Type tables
CREATE TABLE Product_Type (
    id INTEGER PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE Customer_Product_Type (
    customer_id INTEGER,
    product_id INTEGER,
    amount_spent INTEGER,
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
);

-- Insert into Product_Type table
-- Inserting product types into the Product_Type table
INSERT INTO Product_Type(name) VALUES ('Wines');
INSERT INTO Product_Type(name) VALUES ('Fruits');
INSERT INTO Product_Type(name) VALUES ('Meat');
INSERT INTO Product_Type(name) VALUES ('Fish');
INSERT INTO Product_Type(name) VALUES ('Sweet');
INSERT INTO Product_Type(name) VALUES ('Gold');

-- Insert into Customer_Product_Type table
-- Inserting customer product type data into the Customer_Product_Type table
INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntWines
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Wines';

INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntFruits
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Fruits';

INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntMeatProducts
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Meat';

INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntFishProducts
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Fish';

INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntSweetProducts
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Sweet';

INSERT INTO Customer_Product_Type(customer_id, product_id, amount_spent)
SELECT c.id, pt.id, c.MntGoldProds
FROM customerdata AS c
JOIN Product_Type AS pt ON pt.name = 'Gold';
