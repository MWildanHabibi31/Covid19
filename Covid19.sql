/*-----------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------Covid-19---------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------
  -Skills used : join, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data types-
  -----------------------------------------------------------------------------------------------------------------------
*/

select *
from coviddeaths c
where continent is not null
order by 3,4

-- Select data that we are going to be starting with

select location_name, date, total_cases, new_cases, total_deaths, population
from coviddeaths c 
where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contrast covid in your country


select location_name, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as percentdeaths
from coviddeaths c 
where location_name = 'Indonesia'
	and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with covid

select location_name, date, population, total_cases, (total_cases/population)*100 as percenPopu
from coviddeaths c
where location_name = 'Indonesia'
	and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location_name, population, max(total_cases) as HighestInfection, max(total_cases/population)*100 as percentPopuInfected
from coviddeaths c
where continent is not null
group by location_name, population 
order by percentPopuInfected desc

-- Countries with Highest Death per Population

select location_name, max(cast(total_deaths as int)) as TotalDeath
from coviddeaths c 
where continent is not null 
group by location_name
order by TotalDeath desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death per population

select location_name, MAX(cast(total_deaths as int)) as TotalDeath
from coviddeaths c 
where continent is null 
group by location_name 
order by TotalDeath desc

--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from coviddeaths c 
where continent is not null 
order by 1,2

-- Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location_name, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location_name Order by d.location_name, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location_name = v.location_name
	and d.date = v.date
where d.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location_name, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location_name, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location_name Order by d.location_name, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location_name = v.location_name
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated ;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location_name varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select d.continent, d.location_name, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location_name Order by d.location_name, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location_name = v.location_name
	and d.date = v.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location_name, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location_name Order by d.location_name, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location_name = v.location_name
	and d.date = v.date
where d.continent is not null 

