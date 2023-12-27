--select * from [COVID DEATH]
--order by 3,4

--select * from [COVID VACINATION]
--order by 3,4
-- select the data we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population from 
[COVID DEATH]
order by 1,2

-- the total cases vs total death by %

select location, date, total_cases, total_deaths,  (cast(total_cases as int) / total_deaths) * 100 as deathperct
from 
[COVID DEATH]
where location like '%Nigeria%'
order by 1,2

-- looking at the total cases vs the popluation 
-- the population of Nigeria that got the virus 
select location, date,  population,total_cases,   (total_cases / population) * 100 as confiremdcases
from 
[COVID DEATH]
where location like 'N%'
and 
continent is not null
order by 1,2

-- look at countries with highest infection rate 

select location, population, max(total_cases) as highestinfectioncount,   max((total_cases / population)) * 100 as percentageofpopulationinfected
from 
[COVID DEATH]
--where location like 'N%'
where continent is not null
group by location, population
order by percentageofpopulationinfected desc
-- showing countries with highest death count per population 


select location, max(cast(total_deaths as int)) as highestdeathscount
from 
[COVID DEATH]
where continent is not null
group by location
order by highestdeathscount desc

--trying to figure something out by continent

select continent, max(cast(total_deaths as int)) as highestdeathscount
from 
[COVID DEATH]
where continent is not null
group by continent
order by highestdeathscount desc

select location, max(cast(total_deaths as int)) as highestdeathscount
from 
[COVID DEATH]
where continent is null
group by location
order by highestdeathscount desc

--showing continent with the highest death count
select continent, max(cast(total_deaths as int)) as highestdeathscount
from 
[COVID DEATH]
where continent is not null
group by continent
order by highestdeathscount desc

--global numbers 
--cased each part because of zero division 
select SUM(new_cases) as totalcases, sum(new_deaths) as totaldeath,
case 
when sum(new_deaths) = 0
then NULL
when SUM(new_cases) = 0
then null 
else 
sum(new_deaths) / SUM(new_cases)  * 100 
end as perctagenewdeaths 
from 
[COVID DEATH]
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


--total population vs vacinations 
select dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint))  over ( partition by dea.location order by dea.location, dea.date) as totalvac
from [COVID DEATH] dea
join 
[COVID VACINATION] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
 
 --using cte
 with
 Popsvac (continent, location, date, population,new_vaccinations,totalvac) as 
(
select dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint))  over ( partition by dea.location order by dea.location, dea.date) as totalvac
from [COVID DEATH] dea
join 
[COVID VACINATION] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  
--order by 2,3
)
select * from Popsvac 

select * from [dbo].[COVID DEATH]
SELECT * FROM [dbo].[COVID VACINATION]

SELECT location, DATE, extreme_poverty
from 
[COVID VACINATION]
where continent is not null
order by 1,2
--using rolling count to see the new deaths by adding up daily deaths over time 

select dea.continent, dea.location, dea.date, dea.population, vac.total_tests,dea.new_deaths,
sum(dea.new_deaths) over (partition by dea.location order by dea.location, dea.date) as rollingdeaths
from 
[dbo].[COVID DEATH] dea
join [dbo].[COVID VACINATION] vac
on dea.location = vac.location 
and dea.date = vac.date 


With 
popdeath( continent,location, date, population, total_tests,new_deaths,rollingdeaths)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.total_tests,dea.new_deaths,
sum(dea.new_deaths) over (partition by dea.location order by dea.location, dea.date) as rollingdeaths
from  
[dbo].[COVID DEATH] dea
join [dbo].[COVID VACINATION] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
)
select *,(rollingdeaths / population)
from popdeath

--temp table 
drop table if exists  #perpopulatondeath
create table #perpopulatondeath
( 
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, total_tests numeric, new_deaths numeric , rollingdeaths  numeric 
)
insert into  #perpopulatondeath
select dea.continent, dea.location, dea.date, dea.population, vac.total_tests,dea.new_deaths,
sum(dea.new_deaths) over (partition by dea.location order by dea.location, dea.date) as rollingdeaths
from  
[dbo].[COVID DEATH] dea
join [dbo].[COVID VACINATION] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null

select *,(rollingdeaths / population)
from #perpopulatondeath

--creating views 
create view  rollingdeathaddup as 
select dea.continent, dea.location, dea.date, dea.population, vac.total_tests,dea.new_deaths,
sum(dea.new_deaths) over (partition by dea.location order by dea.location, dea.date) as rollingdeaths
from 
[dbo].[COVID DEATH] dea
join [dbo].[COVID VACINATION] vac
on dea.location = vac.location 
and dea.date = vac.date 

create view allrecord as 
select location, date, total_cases, new_cases, total_deaths, population from 
[COVID DEATH]
where continent is not null
--order by 1,2
create view totalcasesbytotaldeath as 
select location, date, total_cases, total_deaths,  (cast(total_cases as int) / total_deaths) * 100 as deathperct
from 
[COVID DEATH]
where location like '%Nigeria%'
--order by 1,2

create view highestnfectionrate as 
select location, population, max(total_cases) as highestinfectioncount,   max((total_cases / population)) * 100 as percentageofpopulationinfected
from 
[COVID DEATH]
--where location like 'N%'
where continent is not null
group by location, population
--order by percentageofpopulationinfected desc
create view higestdeathcount as
select location, max(cast(total_deaths as int)) as highestdeathscount
from 
[COVID DEATH]
where continent is not null
group by location
--order by highestdeathscount desc

create view globalnumbers as 
select SUM(new_cases) as totalcases, sum(new_deaths) as totaldeath,
case 
when sum(new_deaths) = 0
then NULL
when SUM(new_cases) = 0
then null 
else 
sum(new_deaths) / SUM(new_cases)  * 100 
end as perctagenewdeaths 
from 
[COVID DEATH]
--where location like '%Nigeria%'
where continent is not null
--group by date
create view totalpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint))  over ( partition by dea.location order by dea.location, dea.date) as totalvac
from [COVID DEATH] dea
join 
[COVID VACINATION] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
