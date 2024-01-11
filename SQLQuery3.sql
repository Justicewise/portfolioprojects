select * from  [dbo].[superstoretest]
select * from [dbo].[superstoretrain]
select * from [dbo].[superstoreresult]

--In this walmart project i will be doing a little data cleaning beofre analysing the data for key insights 
--lets work on date column on both table to make it easy to use
update superstoretest
set NewOrderDate =  convert (Date, [Order Date]) 

alter table superstoretest 
add NewOrderDate date;

alter table superstoretest 
add NewShipDate date;

update superstoretest
set NewShipDate =   convert (Date, [Order Date]) 

alter table superstoretest
drop column [Ship Date]
--train table

alter table superstoretrain 
add NewOrderDate date;


update superstoretrain
set NewOrderDate =  convert (Date, [Order Date]) 
--removed both the ship date and order date that i wont be needing 
alter table superstoretrain
add NewShipDate date;

update superstoretrain
set NewShipDate =   convert (Date, [Order Date]) 

alter table superstoretrain
drop column [Order Date]

--understand sales trend  on top selling products first acorss individual table then all tables 
select 
Category, [Sub-Category], [Product Name], sum(Sales) Total_sales
from superstoretest
where Region is not null
group by Category, [Product Name] , [Sub-Category]
order by Category, Total_sales desc

-- looking at top sales per region via segment 

select region, Segment, [Sub-Category], sum(sales) as RegionSales 
from superstoretest
where Segment is not null 
group by Region, [Sub-Category],Segment
order by region, RegionSales desc
--So consumers around central side of usa buy more of binders?? but why 

--looking at both tables now 
select sp.Region, st.Category, sp.[Sub-Category], st.[Product Name], sum(st.Sales + sp.Sales) Total_sales
from superstoretest sp
join superstoretrain st 
on st.NewOrderDate = sp.NeworderDate and 
st.NewShipDate = sp.NewShipDate
where sp.Region is not null
group by st.Category,st.[Product Name],sp.[Sub-Category], sp.Region
order by st.Category, Total_sales desc

-- but looking at both tables most sales happened around coppiers in the west side of the country 

select NewShipDate, NewOrderDate
from superstoretest

select Max(sales) 
from superstoretest
where NewOrderDate between '2015-12-12' and '2017-05-04'


select Region, [Product Name], sum(quantity) totalquantity, category, [Sub-Category],  sum(sales) higestsales from superstoretest 
where NewOrderDate >= '2015-12-12' and NewOrderDate <='2017-05-04'
group by Region, category, [Sub-Category],[Product Name]
order by Region, higestsales desc, totalquantity desc
-- based on a single table of test central sold more of binders office suppliers?? diging futher 

select b.*, ROW_NUMBER() over (partition by orderyear,allquarter order by higestsales desc ) as rn from (
select a.*, sum(sales) over (partition by [Product ID],Region,orderyear,allquarter) as higestsales
from (
select Region, [Product ID], [Product Name], quantity, category, [Sub-Category],
sales, DATEPART(year, NewOrderDate)AS orderyear, DATEPART(quarter, NewOrderDate) as allquarter
from superstoretest 
--where NewOrderDate >= '2015-12-12' and NewOrderDate <='2017-05-04'
--group by Region, category, [Sub-Category],[Product Name],quantity,sales
) a 
) b order by  higestsales desc 
-- still working on test table biggest sales happen around 1st quarter of 2017 on coppiers 
----------------------------------------
select  Region, [Product ID], [Product Name], quantity, category, [Sub-Category],higestsales,
case when allquarter = 1 then concat(orderyear,'-Q1')
 when allquarter = 2 then concat(orderyear,'-Q2')
 when allquarter = 3 then concat(orderyear,'-Q3')
 when allquarter = 4 then concat(orderyear,'-Q4') end as curr_year_qtr from
(
select b.*, ROW_NUMBER() over (partition by orderyear,allquarter order by higestsales desc ) as rn from (
select a.*, sum(sales) over (partition by [Product ID],Region,orderyear,allquarter) as higestsales
from (
select Region, [Product ID], [Product Name], quantity, category, [Sub-Category],
sales, DATEPART(year, NewOrderDate)AS orderyear, DATEPART(quarter, NewOrderDate) as allquarter
from superstoretest 
--where NewOrderDate >= '2015-12-12' and NewOrderDate <='2017-05-04'
--group by Region, category, [Sub-Category],[Product Name],quantity,sales
) a 
) b
) c where rn = 1 
order by  higestsales desc 
-- 2017 1st quarter recorded highest sales on the west coast of the country 

create view bestsellingyrqtr as
select  Region, [Product ID], [Product Name], quantity, category, [Sub-Category],higestsales,
case when allquarter = 1 then concat(orderyear,'-Q1')
 when allquarter = 2 then concat(orderyear,'-Q2')
 when allquarter = 3 then concat(orderyear,'-Q3')
 when allquarter = 4 then concat(orderyear,'-Q4') end as curr_year_qtr from
(
select b.*, ROW_NUMBER() over (partition by orderyear,allquarter order by higestsales desc ) as rn from (
select a.*, sum(sales) over (partition by [Product ID],Region,orderyear,allquarter) as higestsales
from (
select Region, [Product ID], [Product Name], quantity, category, [Sub-Category],
sales, DATEPART(year, NewOrderDate)AS orderyear, DATEPART(quarter, NewOrderDate) as allquarter
from superstoretrain 
--where NewOrderDate >= '2015-12-12' and NewOrderDate <='2017-05-04'
--group by Region, category, [Sub-Category],[Product Name],quantity,sales
) a 
) b
) c where rn = 1 
--order by  higestsales desc

--but on train table biggest sales happen around 1st q of 2014 on machines in the south part of the country 
--lets look at both tables and see 

create view bestsellingyear_qtr as 
select  Region, [Product ID], [Product Name], quantity, category, [Sub-Category],higestsales,
case when allquarter = 1 then concat(orderyear,'-Q1')
 when allquarter = 2 then concat(orderyear,'-Q2')
 when allquarter = 3 then concat(orderyear,'-Q3')
 when allquarter = 4 then concat(orderyear,'-Q4') end as curr_year_qtr from
(
select b.*, ROW_NUMBER() over (partition by orderyear,allquarter order by higestsales desc ) as rn from (
select a.*, sum(sales) over (partition by [Product ID],Region,orderyear,allquarter) as higestsales
from (
select t.Region, t.[Product ID], t.[Product Name], t.quantity, t.category, t.[Sub-Category],
t.sales, DATEPART(year, t.NewOrderDate)AS orderyear, DATEPART(quarter, t.NewOrderDate) as allquarter
from superstoretest t
join superstoretrain n
on t.[Product ID] = n.[Product ID] and t.NewOrderDate = n.NewOrderDate
--where NewOrderDate >= '2015-12-12' and NewOrderDate <='2017-05-04'
--group by Region, category, [Sub-Category],[Product Name],quantity,sales
) a 
) b
) c where rn = 1 
--order by  higestsales desc
-- but when combined togther Accessories sold the higest around q4 of 2015 central side 

--lets look at customers 
create view statewithbestcomingbackcustmer as
select Region, city, state, count(distinct [Customer ID]) repeat_cus
from 
superstoretest
where Quantity > 1
group by Region, city, state
--order by repeat_cus desc

--so new_york has the highest customer base
--Inventory management 
--BEST SOLD PRODUCT 
create view topsellingproduct as 
select [Product ID], [Product Name], Region, city,  max(quantity)  as bestsellingprduct
from superstoretest
group by  [Product ID], Region, city, [Product Name]
--order by bestsellingprduct desc


--Lets look a bit about profit and the product with the highest profit 

select t.Region, t.Category, t.[Sub-Category], t.[Product ID], t.[Product Name], t.[Customer Name], t.Discount, t.Sales, r.Profit
from 
superstoretest t
join superstoretrain n
 on t.[Product ID] = n.[Product ID] 
join superstoreresult r 
on n.Profit = r.Profit 
order by n.Profit desc, r.Profit desc

create view mostrecodedloss as 
select t.Region, t.Category, t.[Sub-Category], t.[Product ID], t.[Product Name], t.[Customer Name], t.Discount, t.Sales, r.Profit
from 
superstoretest t
join superstoretrain n
 on t.[Product ID] = n.[Product ID] 
join superstoreresult r 
on n.Profit = r.Profit 
where r.Profit < 0
--order by n.Profit desc, r.Profit desc
--accessories recorded highest loss 

create view highestrecordedprofit as  
with profitmargin as (
select t.Region, t.Category, t.[Sub-Category], t.[Product ID], t.[Product Name], t.[Customer Name], t.Discount, t.Sales, r.Profit
from 
superstoretest t
join superstoretrain n
 on t.[Product ID] = n.[Product ID] 
join superstoreresult r 
on n.Profit = r.Profit 
--order by n.Profit desc, r.Profit desc
) select *, sales - Discount as product_profit 
from profitmargin
--order by product_profit desc

--binders has the higest recorded profit margin still central part of the cuntry 