select * from dbo.['unicorns till sep 2020$'] u

-- https://www.kaggle.com/datasets/ramjasmaurya/unicorn-startups?search=Economics&page=5
--1. The amount of valuation unicos accumulates over time
select u.[Date Joined],
sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) 
over (order by format(u.[Date Joined],'dd/MM/yyyy') 
ROWS between unbounded preceding and current row) as Accumulate_Valuation
from dbo.['unicorns till sep 2020$'] u where u.[Date Joined] is not null
order by format(u.[Date Joined],'dd/MM/yyyy')

--2. Top 5 invested companies
select top 5 u.Company, u.Country
from dbo.['unicorns till sep 2020$'] u 
group by u.Company,  u.Country
order by sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) desc

--3. Top 5 invested countries
select Top 5 u.Country, sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float))
from dbo.['unicorns till sep 2020$'] u 
group by u.Country
order by sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) desc

--4. for each industry,Number_of_unicorns and Valuation 
select u.Industry, count(u.Industry) as number_of_unicorns, sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float))
as Valuation 
from dbo.['unicorns till sep 2020$'] u 
group by u.Industry
order by 2 desc

--5. The relative value of each company to the industry
with Industry_Valuations as(
select u.Industry as Industry, sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) 
as Valuation 
from dbo.['unicorns till sep 2020$'] u 
group by u.Industry)

select u.Industry, sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) over (partition by u.Industry order 
by u.Industry) as Industry_Valuation,
u.Company,cast(round(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)/Industry_Valuations.Valuation*100,2) as varchar)+'%'
as Relative_Value
from dbo.['unicorns till sep 2020$'] u join Industry_Valuations on u.Industry=Industry_Valuations.Industry
order by u.Industry

--6.Number of unicorns each year
select year(u.[Date Joined]) date, count(u.company)
from dbo.['unicorns till sep 2020$'] u where u.[Date Joined] is not null
group by year(u.[Date Joined])
order by year(u.[Date Joined])

--7 Israeli unicorns
select u.Company,'$'+cast(sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) as varchar)
from dbo.['unicorns till sep 2020$'] u 
where u.Country='israel'
group by u.Company,  u.Country
order by sum(cast(SUBSTRING(u.[Valuation ($B)],2,10) as float)) desc