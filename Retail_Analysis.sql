use retail;

/* 1. Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique values and remove the the original table from the databases and replace the name of the new table with the original name. */

select transactionID, count(*) from sales_transaction
group by transactionID
having count(*)>1;

create table sales_new as 
select distinct *
from sales_transaction;

drop table sales_transaction;

alter table sales_new rename to sales_transaction;

select * from sales_transaction;

/*2. Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. Also, update those discrepancies to match the price in both the tables.*/

select st.TransactionID, st.price TransactionPrice,  p.price InventoryPrice from 
sales_transaction st
join product_inventory p
on st.productID=p.productID
where st.price <> p.price;

UPDATE sales_transaction st 
join product_inventory p 
on st.productID=p.productID
SET st.price = p.price
WHERE st.price<>p.price;

select * from sales_transaction;

/*3. Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.*/

select sum(case when CustomerID is null then 1 else 0 end)+sum(case when age is null then 1 else 0 end)+sum(case when gender is null then 1 else 0 end)+
sum(case when location is null then 1 else 0 end)+sum(case when JoinDate is null then 1 else 0 end) as "count(*)"
from customer_profiles;

update customer_profiles
set customerid = coalesce(CustomerID, 'Unknown'), age =coalesce(age, 'Unknown'),gender = coalesce(gender,'Unknown'),location = coalesce(location, 'Unknown'),joindate = coalesce(joindate, 'Unknown');

select * from customer_profiles;

/*4. Write a SQL query to summarize the total sales and quantities sold per product by the company.*/

select productID,  sum(quantityPurchased) as totalunitssold, sum(quantityPurchased*price) as totalsales
from sales_transaction
group by productID
order by totalsales desc;

/*5. Write a SQL query to count the number of transactions per customer to understand purchase frequency.*/

select customerID, count(customerID) as numberoftransactions
from sales_transaction
group by customerID
order by numberoftransactions desc;


/*6. Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.*/

select p.category, sum(s.quantitypurchased) as totalunitssold, sum(s.quantitypurchased*s.price) as totalsales
from sales_transaction s 
join product_inventory p 
on s.productID=p.productID 
group by p.category
order by totalsales desc;

/*7. Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.*/

select productID, sum(quantitypurchased*price) as totalrevenue
from sales_transaction
group by productID 
order by totalrevenue desc
limit 10;

/*8. Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that at least one unit was sold for those products.*/

select productID, sum(quantitypurchased) as totalunitssold
from sales_transaction
group by productID
having sum(quantitypurchased)>0
order by totalunitssold asc
limit 10;

/*9. Write a SQL query to identify the sales trend to understand the revenue pattern of the company.*/

select transactiondate as DATETRANS, count(*) as Transaction_count, sum(quantitypurchased) TotalUnitsSold, sum(quantitypurchased*price) as TotalSales
from sales_transaction
group by DATETRANS
order by DATETRANS desc;

/*10. Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.*/

with sales as(
select month(TransactionDate) as month,
round(sum(QuantityPurchased*Price),2) as total_sales
from sales_transaction
group by month(TransactionDate) )
select 
month, 
total_sales, 
round(lag(total_sales) over(order by month),2) as previous_month_sales,
round((total_sales - lag(total_sales) over(order by month))/lag(total_sales) over(order by month)*100,2) as mom_growth_percentage
from sales;

/*11. Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.*/

select CustomerID, count(*) as NumberOfTransactions, sum(quantitypurchased*price) as totalspent
from sales_transaction
group by customerID
having totalspent>1000 AND count(*)>10
order by TotalSpent desc;

/*12. Write a SQL query that describes the number of transaction along with the total amount spent by each customer, which will help us understand the customers who are occasional customers or have low purchase frequency in the company.*/

select CustomerID, count(*) as NumberOfTransactions, sum(quantitypurchased*price) as totalspent
from sales_transaction
group by customerID
having count(*)<=2
order by NumberOfTransactions asc, TotalSpent desc;

/*13. Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.*/

select CustomerID, ProductID, count(QuantityPurchased) TimesPurchased from Sales_transaction
group by CustomerID, ProductID
having count(QuantityPurchased)>1
order by TimesPurchased desc;

/*14. Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.*/

select CustomerID, min(transactiondate) as firstpurchase, 
max(transactiondate) as lastpurchase, datediff(max(transactiondate),min(transactiondate)) as daysbetweenpurchases
from sales_transaction
group by CustomerID
having daysbetweenpurchases>0
order by daysbetweenpurchases desc;

/*15. Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment which will help us target a particular segment for marketing.*/

CREATE TABLE customer_segment AS
SELECT 
    cp.customerid,
    SUM(st.quantitypurchased) AS total_quantity,
    CASE 
        WHEN SUM(st.quantitypurchased) BETWEEN 1 AND 10 THEN 'Low'
        WHEN SUM(st.quantitypurchased) BETWEEN 11 AND 30 THEN 'Med'
        ELSE 'High'
    END AS CustomerSegment
FROM customer_profiles cp
JOIN sales_transaction st
ON cp.customerid = st.customerid
GROUP BY cp.customerid;

select CustomerSegment,
COUNT(*) AS "count(*)"
FROM customer_segment
GROUP BY CustomerSegment;







