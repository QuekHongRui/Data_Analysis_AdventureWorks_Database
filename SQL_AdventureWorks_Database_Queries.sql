/* 1. Show the first name and email address of customers with CompanyName ‘Bike World’. */

SELECT FirstName, EmailAddress
FROM SalesLT.Customer
WHERE CompanyName = 'Bike World';

/* 2. Show the CompanyName for all customers with an address in City ‘Dallas’. */

SELECT c.CustomerID, CONCAT(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) AS Name, c.CompanyName
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE a.City = 'Dallas';

/* 3. How many items with ListPrice more than $1000 have been sold? */

SELECT SUM(OrderQty) AS TotalQuantitySold
FROM SalesLT.SalesOrderDetail
WHERE ProductID IN
   (SELECT ProductID
       FROM SalesLT.Product
       WHERE ListPrice > 1000);

/* 4. Give the CompanyName of those customers with orders over $100,000. Include the subtotal plus tax plus freight. */

SELECT CustomerID, CompanyName
FROM SalesLT.Customer
WHERE CustomerID IN
    (SELECT CustomerID
        FROM SalesLT.SalesOrderHeader
        WHERE TotalDue > 100000);

/* 5. Find the number of left racing socks (‘Racing Socks, L’) ordered by CompanyName ‘Riding Cycles’. */

SELECT OrderQty
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE c.CompanyName = 'Riding Cycles' AND sod.ProductID IN
   (SELECT ProductID
     FROM SalesLT.Product
     WHERE Name = 'Racing Socks, L');

/* 6. A ‘Single Item Order’ is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order. */

SELECT SalesOrderID, AVG(UnitPrice) AS UnitPrice
FROM SalesLT.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(DISTINCT ProductID) = 1;

/* 7. Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel ‘Racing Socks’. */

SELECT p.Name, c.CompanyName
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
WHERE p.ProductModelID IN
   (SELECT ProductModelID FROM SalesLT.ProductModel
    WHERE Name = 'Racing Socks');

/* 8. Show the product description for culture ‘fr’ for product with ProductID 736. */

SELECT pd.[Description]
FROM (SELECT ProductModelID
     FROM SalesLT.Product
     WHERE ProductID = 736) AS p
JOIN SalesLT.ProductModel AS pm ON pm.ProductModelID = p.ProductModelID
JOIN SalesLT.ProductModelProductDescription AS pmpd ON pm.ProductModelID = pmpd.ProductModelID
JOIN SalesLT.ProductDescription AS pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
WHERE pmpd.Culture = 'fr';

/* 9. Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order. */

WITH table1 AS
(SELECT soh.SalesOrderID, SUM(p.Weight) AS TotalWeight
    FROM SalesLT.SalesOrderHeader AS soh
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN SalesLT.Product AS p ON p.ProductID = sod.ProductID
    GROUP BY soh.SalesOrderID)

SELECT table1.SalesOrderID, table1.TotalWeight, soh.SubTotal, c.CompanyName
FROM table1
JOIN SalesLT.SalesOrderHeader AS soh ON table1.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID
ORDER BY soh.SubTotal DESC;

/* 10. How many products in ProductCategory ‘Cranksets’ have been sold to an address in ‘London’? */

SELECT COUNT(DISTINCT p.ProductID) AS NoOfProducts
FROM SalesLT.ProductCategory AS pc
JOIN SalesLT.Product AS p ON pc.ProductCategoryID = p.ProductCategoryID
JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Address AS a ON soh.ShipToAddressID = a.AddressID
WHERE pc.Name = 'Cranksets' AND a.City = 'London';

/* 11. For every customer with a ‘Main Office’ in Dallas show AddressLine1 of the ‘Main Office’ and AddressLine1 of the ‘Shipping’ address — if there is no shipping address leave it blank. Use one row per customer. */

SELECT a.AddressLine1 AS MainOfficeAddressLine1, a2.AddressLine1 AS ShippingAddressLine1
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
JOIN SalesLT.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID
JOIN SalesLT.Address AS a2 ON soh.ShipToAddressID = a2.AddressID
WHERE a.City = 'Dallas' AND ca.AddressType = 'Main Office';

/* 12. For each order show the SalesOrderID and SubTotal calculated in three ways: from the SalesOrderHeader, sum of OrderQty * UnitPrice and sum of OrderQty * ListPrice. */

SELECT table1.SalesOrderID, soh.SubTotal, table1.ByUnitPrice, table1.ByListPrice
FROM(
   SELECT sod.SalesOrderID, SUM(sod.OrderQty * sod.UnitPrice) AS ByUnitPrice, SUM(sod.OrderQty * p.ListPrice) AS ByListPrice
   FROM SalesLT.SalesOrderDetail AS sod
   JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
   GROUP BY sod.SalesOrderID
) AS table1
JOIN SalesLT.SalesOrderHeader AS soh ON table1.SalesOrderID = soh.SalesOrderID;

/* 13. Show the best selling item by value. */

SELECT TOP 1 sod.ProductID, p.Name, SUM(OrderQty * (UnitPrice - UnitPriceDiscount)) AS TotalValue
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
GROUP BY sod.ProductID, p.Name
ORDER BY TotalValue DESC;

/* 14. Show how many orders are in and the total value of orders in the following ranges (in $): 0-99, 100-999, 1000-9999, 10000+. Name the columns RANGE, Num Orders and Total Value. */

SELECT RANGE, COUNT(*) AS NumOrders, SUM(SubTotal) AS TotalValue
FROM (
   SELECT CASE
       WHEN SubTotal >= 0 AND SubTotal <= 99 THEN '0-99'
       WHEN SubTotal >= 100 AND SubTotal <= 999 THEN '100-999'
       WHEN SubTotal >= 1000 AND SubTotal <= 9999 THEN '1000-9999'
       ELSE '10000+'
   END AS RANGE, SubTotal
   FROM SalesLT.SalesOrderHeader) AS table1
GROUP BY RANGE;

/* 15. Identify the three most important cities. */

SELECT TOP 3 a.City, SUM(soh.SubTotal) AS TotalRevenue
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Address AS a ON soh.BillToAddressID = a.AddressID
GROUP BY a.City
ORDER BY TotalRevenue DESC;

/* 16. Show the breakdown of top level product category by city. */

WITH table1 AS
(SELECT City, ProductID, OrderQty * (UnitPrice - UnitPriceDiscount) AS Sales
    FROM (SELECT SalesOrderID, City
            FROM SalesLT.Address AS a
            JOIN SalesLT.SalesOrderHeader AS soh ON a.AddressID = soh.ShipToAddressID) AS table1
    JOIN SalesLT.SalesOrderDetail AS sod ON table1.SalesOrderID = sod.SalesOrderID),
table2 AS
(SELECT City, pc.Name AS Category, SUM(Sales) AS TotalSales
    FROM table1
    JOIN SalesLT.Product AS p ON table1.ProductID = p.ProductID
    JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY City, pc.Name)

SELECT City, Category AS TopProductCategory, TotalSales
FROM (SELECT City, Category, TotalSales, RANK() OVER(PARTITION BY City ORDER BY TotalSales DESC) AS Ranking
       FROM table2) AS table3
WHERE Ranking = 1;

/* 17. List the SalesOrderNumber for the customer ‘Good Toys’ ‘Bike World’. */

SELECT SalesOrderID
FROM SalesLT.SalesOrderHeader
WHERE CustomerID IN (
   SELECT CustomerID
   FROM SalesLT.Customer
   WHERE CompanyName IN ('Bike World', 'Good Toys')
);

/* 18. List the ProductName and the quantity of what was ordered by ‘Futuristic Bikes’. */

SELECT p.Name, sod.OrderQty
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
WHERE c.CompanyName = 'Futuristic Bikes';

/* 19. List the name and addresses of companies containing the word ‘Bike’ (upper or lower case) and companies containing the word ‘cycle’ (upper or lower case). Ensure that the ‘bike’s are listed before the ‘cycle’s. */

SELECT c.CompanyName, a.AddressLine1
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE c.CompanyName LIKE '%bike%' OR c.CompanyName LIKE '%BIKE%' OR c.CompanyName LIKE '%cycle%' OR c.CompanyName LIKE '%CYCLE%';

/* 20. Show the total order value for each CountryRegion. List by value with the highest first. */

SELECT a.CountryRegion, SUM(soh.SubTotal) AS TotalOrderValue
FROM SalesLT.Address AS a
JOIN SalesLT.SalesOrderHeader AS soh ON a.AddressID = soh.BillToAddressID
GROUP BY a.CountryRegion
ORDER BY TotalOrderValue DESC;

/* 21. Find the best customer in each region. */

WITH table1 AS
(SELECT a.CountryRegion, soh.CustomerID, soh.SubTotal, RANK() OVER (PARTITION BY a.CountryRegion ORDER BY soh.SubTotal DESC) AS CustomerRank
    FROM SalesLT.Address AS a
    JOIN SalesLT.SalesOrderHeader AS soh ON a.AddressID = soh.ShipToAddressID)

SELECT CountryRegion, table1.CustomerID, CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS Name, CompanyName, SubTotal
FROM table1
JOIN SalesLT.Customer AS c ON table1.CustomerID = c.CustomerID
WHERE table1.CustomerRank = 1;

/* 22. Find the top 10 customers with the highest total purchase amount. */

SELECT TOP 10 CONCAT(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) AS CustomerName, soh.SubTotal
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
ORDER BY SubTotal DESC;

/* 23. Find the top 10 customers with the highest number of orders. */

SELECT CONCAT(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) AS CustomerName, table1.NoOfOrders
FROM (SELECT TOP 10 SalesOrderID, COUNT(SalesOrderDetailID) AS NoOfOrders
       FROM SalesLT.SalesOrderDetail
       GROUP BY SalesOrderID
       ORDER BY NoOfOrders DESC) AS table1
JOIN SalesLT.SalesOrderHeader AS soh ON table1.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID;

/* 24. Find the top 10 customers with the highest total number of products purchased. */

SELECT CONCAT(c.FirstName, ' ', c.MiddleName, ' ', c.LastName) AS CustomerName, TotalQtyPurchased
FROM (SELECT TOP 10 SalesOrderID, SUM(OrderQty) AS TotalQtyPurchased
       FROM SalesLT.SalesOrderDetail
       GROUP BY SalesOrderID
       ORDER BY TotalQtyPurchased DESC) AS table1
JOIN SalesLT.SalesOrderHeader AS soh ON table1.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID;

/* 25. Find the total number of products in each color. */

SELECT Color, COUNT(ProductID) AS NoOfProducts
FROM SalesLT.Product
GROUP BY Color;

/* 26. Find the total number of products in each product category. */

SELECT pc.Name, COUNT(ProductID) AS NoOfProducts
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name;

/* 27. Find the average purchase amount for each customer. */

SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS CustomerName, Average
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN (SELECT SalesOrderID, AVG(OrderQty * (UnitPrice - UnitPriceDiscount)) AS Average
       FROM SalesLT.SalesOrderDetail
       GROUP BY SalesOrderID) AS table1 ON table1.SalesOrderID = soh.SalesOrderID;

/* 28. List the product names of products that have never been ordered. Hint: Use a subquery to find products not in `SalesLT.SalesOrderDetail`. */

SELECT ProductID, Name
FROM SalesLT.Product
WHERE ProductID NOT IN (
   SELECT DISTINCT(ProductID)
   FROM SalesLT.SalesOrderDetail
);

/* 29. Retrieve the details of the most recent order placed by any customer from `SalesLT.SalesOrderHeader`. */

SELECT *
FROM SalesLT.SalesOrderDetail
WHERE SalesOrderID IN (
   SELECT TOP 1 SalesOrderID
   FROM SalesLT.SalesOrderHeader
);

/* 30. Calculate the percentage of total sales contributed by each customer using a subquery within the `SalesLT.SalesOrderHeader` table. */

SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS CustomerName, CONCAT(CAST(ROUND(100 * SubTotal / TotalSubTotal, 2) AS varchar), '%') AS PercentageOfSales
FROM (SELECT CustomerID, SubTotal, (SELECT SUM(SubTotal)
                                   FROM SalesLT.SalesOrderHeader) AS TotalSubTotal
     FROM SalesLT.SalesOrderHeader) AS table1
JOIN SalesLT.Customer AS c ON table1.CustomerID = c.CustomerID;

/* 31. Identify the top 3 products with the highest `ListPrice` in each `ProductCategoryID`. */

SELECT ProductCategoryID, Name
FROM (SELECT p.ProductCategoryID, p.Name, RANK() OVER(PARTITION BY p.ProductCategoryID ORDER BY p.ListPrice DESC) AS Ranking
       FROM SalesLT.Product AS p
       JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID) AS table1
WHERE Ranking <= 3;








