-- creating database

create database book_store;
use book_store;

-- crating tables for bookstore

drop table if exists books;
CREATE TABLE books(
Book_ID	INT PRIMARY KEY,
Title VARCHAR(100),
Author VARCHAR(100),
Genre VARCHAR(100),
Published_Year INT,
Price NUMERIC(10,2),
Stock INT);

drop table if exists customer;
CREATE TABLE customer(
Customer_ID SERIAL PRIMARY KEY,
Name VARCHAR(100),
Email VARCHAR(100),
Phone VARCHAR(20),
City VARCHAR(100),
Country VARCHAR(100));

drop table if exists Orders;
CREATE TABLE Orders(
Order_ID INT PRIMARY KEY,
Customer_ID	SERIAL,
Book_ID	INT,
Order_Date DATE,
Quantity INT,
Total_Amount NUMERIC(10,2),
FOREIGN KEY(Customer_ID) REFERENCES customer(Customer_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY(Book_ID) REFERENCES books(Book_ID)
ON DELETE CASCADE
ON UPDATE CASCADE);

SELECT * FROM books;
SELECT * FROM customer;
SELECT * FROM Orders;
-- BASIC QUESTIONS
-- Retrieve all books in the "Fiction" genre
SELECT * FROM books 
WHERE Genre = 'Fiction';

-- Find books published after the year 1950
SELECT Title FROM books
WHERE Published_Year>1950;

-- List all customers from the Canada
SELECT Name FROM customer
WHERE Country = 'Canada';

-- Show orders placed in November 2023
SELECT * FROM Orders
WHERE Order_Date LIKE '2023-11-__';

-- Retrieve the total stock of books available
SELECT SUM(Stock) FROM books;

-- Find the details of the most expensive book
SELECT * FROM books
WHERE Price = (SELECT MAX(Price) FROM books);

-- Show all customers who ordered more than 1 quantity of a book
SELECT * FROM Orders
WHERE Quantity>1;

-- Retrieve all orders where the total amount exceeds $20
SELECT * FROM Orders
WHERE Total_Amount>20;

-- List all genres available in the Books table
SELECT DISTINCT Genre FROM books;

-- Find the book with the lowest stock
SELECT * FROM books
WHERE Stock = (SELECT min(Stock) FROM books);

-- Calculate the total revenue generated from all orders
SELECT SUM(Total_Amount) AS Revenue FROM Orders;

-- Adavance questions
-- Retrieve the total number of books sold for each genre
SELECT b.Genre, SUM(o.Quantity) AS Total_Book_Sold
FROM Orders o
JOIN books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre;

-- Find the average price of books in the "Fantasy" genre
SELECT AVG(Price) AS Average_Price FROM books
WHERE Genre = 'Fantasy';

-- List customers who have placed at least 2 orders
SELECT o.Customer_ID, c.Name, COUNT(o.Order_ID) AS Order_count
FROM orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID
GROUP BY o.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2;

-- Find the most frequently ordered book
SELECT o.Book_ID, b.Title, COUNT(o.Order_ID) AS Order_count
FROM orders o
JOIN books b ON b.Book_ID = o.Book_ID
GROUP BY o.Book_ID, b.Title
ORDER BY Order_count DESC LIMIT 1;

-- Show the top 3 most expensive books of 'Fantasy' Genre
SELECT Title FROM books
where Genre = 'Fantasy'
ORDER BY Price DESC LIMIT 3;

-- Retrieve the total quantity of books sold by each author
SELECT b.Author,SUM(o.Quantity) As Total_quantity 
from Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author;

-- List the cities where customers who spent over $30 are located
SELECT DISTINCT c.City FROM Orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID
WHERE o.Total_Amount>30;

-- Find the customer who spent the most on orders
SELECT c.Name, c.Customer_ID , SUM(o.Total_Amount) AS Total_Spent
FROM orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID 
GROUP BY c.Name, c.Customer_ID
ORDER BY Total_Spent DESC;
-- Calculate the stock remaining after fulfilling all orders
SELECT b.Title , b.Book_ID , b.Stock - COALESCE(SUM(o.Quantity),0) AS Remaining_Quantity
FROM Orders o
RIGHT JOIN books b ON o.Book_ID = b.Book_ID
GROUP BY  b.Title , b.Book_ID;


-- Sales & Revenue Analysis
-- Top 5 books by revenue:
SELECT b.Title,SUM(o.Total_Amount) AS Total_Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Title
ORDER BY Total_Revenue DESC LIMIT 5;

-- Monthly revenue trend in 2024:
SELECT MONTH(Order_date) AS Month , SUM(Total_Amount) AS Revenue
FROM Orders
WHERE Order_date LIKE '2023-__-__'
GROUP BY  Month
ORDER BY Month;

-- Customer with highest total purchase:
SELECT c.Name, c.Customer_ID , SUM(Total_Amount) as Total_Purchse 
FROM Orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID
ORDER BY Total_Purchse DESC LIMIT 1;

--  Inventory & Stock Insights
-- Books with high sales but low stock (below 10):
SELECT b.Title , SUM(Quantity) as Total_Sold,b.Stock
FROM Orders o 
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Title,b.Stock
HAVING b.Stock < 10
ORDER BY Total_Sold DESC;

-- Most popular genres by sales:
SELECT b.Genre , SUM(Quantity) as Total_Sold
FROM Orders o 
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genre
ORDER BY Total_Sold DESC LIMIT 5;

-- Customer Behavior
-- Repeat customers (ordered more than once):
SELECT c.Name, COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN customer c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Name
HAVING COUNT(o.Order_ID) > 1;

-- Top countries by number of customers:
SELECT Country, COUNT(*) AS Customer_Count
FROM customer
GROUP BY Country
ORDER BY Customer_Count DESC;

-- Creating Some Useful Views:
-- Top_Selling_Books
CREATE VIEW Top_Selling_Books AS
SELECT b.Title ,  b.Author, b.Book_ID ,  SUM(Quantity) AS Total_Sold
FROM Orders o 
JOIN books b ON b.Book_ID =o.Book_ID
GROUP BY b.Title,b.Author, b.Book_ID 
ORDER BY Total_Sold DESC;
SELECT * FROM Top_Selling_Books;

-- Customer_Spending
CREATE VIEW Customer_Spending AS
SELECT c.Name, c.Customer_ID , SUM(Total_Amount) as Total_Purchse 
FROM Orders o
JOIN customer c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID
ORDER BY Total_Purchse DESC;
SELECT * FROM Customer_Spending;

-- Genre_Sales_Summary
CREATE VIEW Genre_Sales_Summary AS
SELECT b.Genre , SUM(o.Quantity) as Total_Sold , SUM(o.Total_Amount) AS Revenue
FROM Orders o 
JOIN Books b ON b.Book_ID = o.Book_ID
GROUP BY b.Genrecustomer_spending
ORDER BY Revenue DESC;
SELECT * FROM Genre_Sales_Summary;


-- Stored Procedure: Monthly Sales Summary:
DELIMITER $$
CREATE PROCEDURE GetMonthlySalesSummary(IN input_year INT, IN input_month INT)
BEGIN
    SELECT 
        COUNT(Order_ID) AS Total_Orders,
        SUM(Quantity) AS Total_Quantity_Sold,
        SUM(Total_Amount) AS Total_Revenue
    FROM Orders
    WHERE YEAR(Order_Date) = input_year AND MONTH(Order_Date) = input_month;
END $$
DELIMITER ;

CALL GetMonthlySalesSummary(2024, 5);  -- May 2024


