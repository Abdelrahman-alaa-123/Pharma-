--all columns for all records in the dataset. 
SELECT * from Pharma_data$
--unique countries are represented in the dataset
select count(distinct Country) as [unique countries ]from Pharma_data$ 
--the names of all the customers on the 'Retail' channel. 
select distinct [Customer Name] from Pharma_data$ where [Sub-channel]='Retail' order by [Customer Name]
--the total quantity sold for the ' Antibiotics' product class.
SELECT round(SUM(Quantity),2) AS TotalQuantitySold
FROM Pharma_data$ WHERE [Product Class] = 'Antibiotics';
--the distinct months present in the dataset
select distinct [Month] from Pharma_data$ order by [Month]
--Calculate the total sales for each year. 
select distinct[Year] , sum ([Sales]) over (partition by [year]) as [sales per year] from Pharma_data$ order by [Year]
--the customer with the highest sales value. 
select * from Pharma_data$ where [Sales]=(select MAX([Sales]) from Pharma_data$)
--the names of all employees who are Sales Reps and are managed by 'James Goodwill'. 
select distinct[Name of Sales Rep] from Pharma_data$ where Manager='James Goodwill'
--the average price of products in each sub-channel. 
select distinct [Sub-channel] , AVG([Price]) over (partition by [Sub-channel]) as [Avg Price] from Pharma_data$
--the top 5 cities with the highest sales
select top 5 [City] from Pharma_data$ order by Sales desc
--the 'Employees' table with the 'Sales' table to get the name of the Sales Rep and the  corresponding sales records. 
select distinct e.[Name of Sales Rep] , s.[Sales] from Pharma_data$ e join Pharma_data$ s on e.Distributor=s.Distributor
--all sales made by employees from ' Rendsburg ' in the year 2018
SELECT Sales
FROM [Pharma_data$]
WHERE [Year] = 2018 AND City ='Rendsburg'
order by Sales desc;

--the total sales for each product class, for each month, and order the results by year, month, and product class
select [Product Class],Year,Month,(select sum ([Sales])) as total 
from Pharma_data$
group by [Product Class],Year,Month
order by [Product Class],Year,Month
--the total sales for each product class, for each month, and order the results by year, month, and product class
select distinct[Product Class],Year,Month, sum ([Sales]) over (partition by [Product Class],Month) as [TOTAL]
from Pharma_data$
order by Year,Month
--the top 3 sales reps with the highest sales in 2019. 
select top 3 [Name of Sales Rep],Sales from Pharma_data$ where Year=2019 order by Sales desc
--the monthly total sales for each sub-channel, and then calculate the average monthly sales for each sub-channel over the years. 
with monthlytotalasales as(
      select [Sub-channel],Year,Month,sum(Sales) as monthlysales from Pharma_data$
	  group by [Sub-channel],Year,Month)
	  select [Sub-channel],AVG(monthlysales) as avgmonthlysales from monthlytotalasales
	  group by [Sub-channel]
	  order by [Sub-channel]

--Create a summary report that includes the total sales, average price, and total quantity sold for each product class. 
select [Product Class],SUM([Sales]) as TotalSales , AVG(Price) as [Avg Price],SUM(Quantity) as TotalQuantity 
from Pharma_data$
group by [Product Class]
order by [Product Class] desc
--the top 5 customers with the highest sales for each year. 
select top 5 [Customer Name],[Sales]from Pharma_data$
order by [Customer Name] desc,[Sales] desc
--the top 5 customers with the highest sales for each year. 
SELECT TOP 5
    [Customer Name],
    [Sales],
    YEAR AS OrderYear
FROM
    Pharma_data$
ORDER BY
    [Customer Name] DESC,
    [Sales] DESC,
    OrderYear;

--the year-over-year growth in sales for each country
WITH YearlySales AS (
    SELECT
        Country,
        YEAR AS OrderYear,
        SUM(Sales) AS TotalSales
    FROM
       Pharma_data$
    GROUP BY
        Country, YEAR
),
YearOverYearGrowth AS (
    SELECT
        Country,
        OrderYear,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY Country ORDER BY OrderYear) AS PrevYearSales
    FROM
        YearlySales
)
SELECT
    Y1.Country,
    Y1.OrderYear,
    Y1.TotalSales,
    COALESCE((Y1.TotalSales - Y2.PrevYearSales) / NULLIF(Y2.PrevYearSales, 0), 0) AS YoYGrowth
FROM
    YearOverYearGrowth Y1
LEFT JOIN
    YearOverYearGrowth Y2 ON Y1.Country = Y2.Country
    AND Y1.OrderYear = Y2.OrderYear + 1;

--the month with the lowest sales  
select Month ,Year from Pharma_data$ where Sales=(select MIN(Sales) from Pharma_data$)

--the months with the lowest sales for each year 
WITH MonthlySales AS (
    SELECT
        YEAR AS OrderYear,
        Month AS OrderMonth,
        MIN(Sales) AS LowestSales
    FROM
       Pharma_data$
    GROUP BY
        YEAR, Month
)
SELECT top 10
    OrderYear,
    OrderMonth,
    LowestSales
FROM
    MonthlySales
	order by OrderYear,LowestSales 

--the highest total sales for each sub-channel.
/*with TotalSales as (
select 
  [Sub-channel] as Orderchannel,
  sum(Sales) as total,
  Country as ordercountry
  FROM
     Pharma_data$
	group by [Sub-channel],Country
)
select ordercountry,MAX(total) as [Highest Total Sales] from TotalSales
group by ordercountry*/

--Calculate the total sales for each sub-channel in each country, and then find the country with the highest total sales for each sub-channel. 
WITH SubChannelSales AS (
    SELECT
        Country, [Sub-channel],SUM(Sales) AS TotalSales
    FROM Pharma_data$
    GROUP BY Country, [Sub-channel]
),
MaxCountrySales AS (
SELECT [Sub-channel],Country,TotalSales, ROW_NUMBER() OVER (PARTITION BY [Sub-channel] ORDER BY TotalSales DESC) AS Rank FROM SubChannelSales)
SELECT [Sub-channel], Country,TotalSales FROM MaxCountrySales
WHERE Rank = 1;
