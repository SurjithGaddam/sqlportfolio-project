
-- total cases by date
select date, sum(total_cases) as total_cases  
from ProjectPortfolio..coviddeaths
 group by date;

 -- Total cases detaails by date and location
Select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..coviddeaths
order by 1,2
 -- total cases vs total deaths

 Select location, date, total_cases,  total_deaths, 
 case 
 when total_cases =0 then 0
 else (total_deaths/total_cases)*100 
 end as death_rate
from ProjectPortfolio..coviddeaths
where location = 'Australia';

-- total cases vs population

Select location, date, population ,total_cases, 
 case 
 when total_cases =0 then 0
 else (total_cases/population)*100
 end as 'cases% by population'
from ProjectPortfolio..coviddeaths
where location = 'Australia';

--  countries with highest infection rate compared to population
Select location,  population ,
max(total_cases) as highestinfectioncount ,
 case 
 when max(total_cases) =0 then 0
 else (max(total_cases/population))*100
 end as 'percentpopulationinfected'
from ProjectPortfolio..coviddeaths
group by location, population
order by percentpopulationinfected desc;


-- countries with highest death count per population
  Select location,  
max(total_deaths ) as totaldeathcount 
from ProjectPortfolio..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc;

-- break things down by continent
 Select continent,  
max(total_deaths ) as totaldeathcount 
from ProjectPortfolio..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc;

 -- death count by location
  Select location,  
max(total_deaths ) as totaldeathcount 
from ProjectPortfolio..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc;

-- continent with highest death count per population
    Select continent,  
max(total_deaths ) as totaldeathcount 
from ProjectPortfolio..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc;

-- global numbers and death percentage by date

select date, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths,
case
when sum(total_cases) = 0 then 0
 else (sum(total_deaths)/SUM(total_cases))* 100 
 end as deathpercentage
from ProjectPortfolio..coviddeaths
group by date 
;

-- Overall global number and death percentage 
 select  sum(total_cases) as total_cases, sum(total_deaths) as total_deaths,
case
when sum(total_cases) = 0 then 0
 else (sum(total_deaths)/SUM(total_cases))* 100 
 end as deathpercentage
from ProjectPortfolio..coviddeaths 
;

-- total population vs vaccinations

select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population,
sum(convert(bigint,new_vaccinations ))  over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as 
rollingpeoplevaccinated,
covidvaccination.new_vaccinations
from ProjectPortfolio..coviddeaths
join ProjectPortfolio..covidvaccination
on coviddeaths.location= covidvaccination.location
and coviddeaths.continent is not null
order by 1,2,3;

-- use CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population,
sum(convert(bigint,new_vaccinations ))  over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as 
rollingpeoplevaccinated,
covidvaccination.new_vaccinations
from ProjectPortfolio..coviddeaths
join ProjectPortfolio..covidvaccination
on coviddeaths.location= covidvaccination.location
and coviddeaths.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

-- temp table
create table #percentpopulationvaccinated
(
insert into 
select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population,
sum(convert(bigint,new_vaccinations ))  over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as 
rollingpeoplevaccinated,
covidvaccination.new_vaccinations
from ProjectPortfolio..coviddeaths
join ProjectPortfolio..covidvaccination
on coviddeaths.location= covidvaccination.location
and coviddeaths.continent is not null


-- creating view to store data of population vs vaccination


create view populationvsvaccination
as
select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population,
sum(convert(bigint,new_vaccinations ))  over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as 
rollingpeoplevaccinated,
covidvaccination.new_vaccinations
from ProjectPortfolio..coviddeaths
join ProjectPortfolio..covidvaccination
on coviddeaths.location= covidvaccination.location
and coviddeaths.continent is not null
--order by 1,2,3;

Select * from populationvsvaccination

-- stored procedure with multiple parameters by continent with highest death count per population using string_split
   Create procedure spgetcont_withhighestdeath
   @continent nvarchar(200)
   as
   begin
   Select continent,  
max(total_deaths ) as totaldeathcount 
from ProjectPortfolio..coviddeaths
where continent is not null and continent in(select * from string_split(@continent,',')) 
group by continent
order by totaldeathcount desc
end;

exec spgetcont_withhighestdeath @continent ='South America,Asia,Africa';

-- new cases, positive rates, hospital beds per thousand by using stored procedures without parameters
Create proc spget_newcsaes_positive_rates
as
begin
Select  coviddeaths.date,coviddeaths.location, coviddeaths.population, coviddeaths.new_cases, covidvaccination.positive_rate, covidvaccination.hospital_beds_per_thousand,
covidvaccination.aged_65_older as '% aged 65 older', coviddeaths.icu_patients 
from coviddeaths
join covidvaccination
on coviddeaths.date = covidvaccination.date
order by 1,2,3
end;
exec  spget_newcsaes_positive_rates
select * from coviddeaths

--total cases and deaths by	population
create view cases_and_death_by_population
as
select coviddeaths.continent,sum(coviddeaths.population) as 'total population', 
sum(coviddeaths.total_cases) as 'total cases' ,sum(coviddeaths.total_deaths) as 'total deaths'
from coviddeaths
where coviddeaths.continent is not null
group by coviddeaths.continent 
--order by coviddeaths.continent asc;

select * from cases_and_death_by_population