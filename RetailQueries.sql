Select * From Customer

Select * From prod_cat_info

Select * From Transactions

Select count(*) as Total_Rows_of_Table from Customer

Select count(*) as Total_Rows_of_Table from prod_cat_info

Select count(*) as Total_Rows_of_Table from Transactions

select COUNT(Qty) as total_returns from Transactions where Qty <= 0;

update Transactions
set tran_date = CONVERT(NVARCHAR(50),CONVERT(date, tran_date,103))
ALTER TABLE transactions
ALTER COLUMN tran_date date

update Customer
set DOB = CONVERT(NVARCHAR(50),CONVERT(date, DOB,103))
ALTER TABLE transactions
ALTER COLUMN DOB date

Select tran_date, FORMAT(tran_date,'dd-MM-yyyy') as convert_date from Transactions

SELECT 
    MIN(tran_date) AS Start_tran_Date,
    MAX(tran_date) AS End_tran_Date,
    DATEDIFF(DAY,  Min(tran_date), Max(tran_date)) AS Difference_Days,
    DATEDIFF(MONTH,Min(tran_date), Max(tran_date)) AS Difference_Months,
    DATEDIFF(YEAR, Min(tran_date), Max(tran_date)) AS Difference_Years
FROM Transactions

Select Prod_cat, prod_subcat from prod_cat_info where prod_subcat = 'DIY';

SELECT Top 1 store_type, COUNT(store_type) as most_used_channel
    FROM Transactions
    GROUP BY Store_type
    ORDER BY most_used_channel desc;

Select COUNT(case when UPPER(Gender) = 'M' then 1 end) as Male,
	 Count(case when UPPER(Gender) = 'F' then 1 end) as Female from customer;

SELECT Top 1 city_code, COUNT(city_code) as total_count
    FROM Customer
    GROUP BY city_code
    ORDER BY total_count desc;

Select count(prod_cat) as subcat_under_books from prod_cat_info
where prod_cat = 'books';

select MAX(Qty) as Max_Qty_ordered, prod_cat from Transactions
inner join prod_cat_info on Transactions.prod_subcat_code = prod_cat_info.prod_subcat_code  group by prod_cat order by prod_cat;

select prod_cat, COUNT(total_amt) as [Net total revenue] from Transactions inner join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code where prod_cat IN ('Electronics','Books') Group by prod_cat;  

Select cust_id, COUNT(cust_id) as No_of_tran from Transactions where Qty >= 0 group by cust_id having COUNT(cust_id) > 10;

select prod_cat, Store_type, COUNT(total_amt) as total_revenue from Transactions inner join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code where prod_cat IN ('Electronics','Clothing') Group by Store_type, prod_cat having(Store_type) = 'flagship store' order by Store_type;  

Select prod_subcat, COUNT(total_amt) as total_revenue from Transactions inner join  Customer on Transactions.cust_id = Customer.cust_Id inner join prod_cat_info on Transactions.prod_subcat_code = prod_cat_info.prod_subcat_code where Gender = 'M' and prod_cat = 'Electronics' group by prod_subcat order by prod_subcat desc; 

select
prod_subcat as subcategory,
Sales =   Round(SUM(cast( case when T.Qty > 0 then total_amt else 0 end as float)),2) , 
Returns = Round(SUM(cast( case when T.Qty < 0 then total_amt else 0 end as float)),2)
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_subcat_code
group by P.prod_subcat

Select top 5
prod_subcat as Subcategory ,
((Round(SUM(cast(case when T.Qty <= 0 then T.Qty  else 0 end as float)),2))/
(Round(SUM(cast(case when T.Qty >= 0 then T.Qty else 0 end as float)),2) - Round(SUM(cast(case when T.Qty <= 0 then T.Qty   else 0 end as float)),2)))*100[%_Returs],
  
((Round(SUM(cast(case when T.Qty >= 0 then T.Qty  else 0 end as float)),2))/
(Round(SUM(cast(case when T.Qty >= 0 then T.Qty else 0 end as float)),2) - Round(SUM(cast(case when T.Qty <= 0 then T.Qty   else 0 end as float)),2)))*100[%_sales]
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_subcat_code
group by P.prod_subcat
order by [%_sales] desc;

SELECT SUM(t.total_amt) as net_total_revenue
FROM (SELECT t.*,
             MAX(t.tran_date) OVER () as max_tran_date
      FROM Transactions t
     ) t JOIN
     Customer c
     ON t.cust_id = c.cust_Id
WHERE t.tran_date >= DATEADD(day, -30, t.max_tran_date) AND 
      t.tran_date >= DATEADD(YEAR, 25, c.DOB) AND
      t.tran_date < DATEADD(YEAR, 31, c.DOB);
	  
SELECT TOP 1
    prod_cat_code
    ,SUM(Total_amt) as totalreturns
    FROM TRANSACTIONS
WHERE Tran_date >= DATEADD(day, -90, 28-02-2014)
    AND Total_amt < 0
GROUP BY prod_cat_code
ORDER BY totalreturns ASC	

select 
Store_type,
SUM(total_amt) AS Total_total_amt,
SUM(Qty) AS Total_Qty
from Transactions 
group by Store_type

select 
store_type, 
MAX(total_amt) AS max_total_amt, 
MAX(Qty) AS max_Qty
from Transactions 
group by Store_type

SELECT p.prod_cat, AVG(t.total_amt) AS average 
FROM (SELECT t.*, AVG(t.total_amt) OVER () as overall_average
      FROM Transactions T
     ) t JOIN
     prod_cat_info P 
     ON T.prod_cat_code = P.prod_cat_code
GROUP BY p.prod_cat, overall_average
HAVING AVG(t.total_amt) > overall_average;

Select P.prod_cat_code, P.prod_subcat as Product_SubCategory, 
AVG(cast(total_amt as float)) as Average_Revenue,
SUM(cast(total_amt as float)) as Total_Revenue
from Transactions as T
INNER JOIN prod_Cat_info as P
ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = 
P.prod_subcat_code
WHERE P.prod_cat_code IN (
select top 5 P.prod_cat_code
from prod_cat_info as P
inner join Transactions as T
ON P.prod_cat_code = T.prod_cat_code AND P.prod_subcat_code = 
T.prod_subcat_code
group by P.prod_cat, p.prod_cat_code
order by sum(Cast(Qty as int)) desc
)
group by P.prod_subcat, P.prod_cat_code;