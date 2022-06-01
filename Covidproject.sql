--select *
--from PortfolioProject..CovidDeaths$
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select location, date, total_cases,new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths$
--order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths$
--where location like '%state%'
--order by 1,2

-- Looking at Total Cases vs Population
---- SHow what percentage of the population got Covid
--select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
--from PortfolioProject..CovidDeaths$
----where location like '%state%'
--order by 1,2

---- Which country with highesh infection rate compared to population
--select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
--from PortfolioProject..CovidDeaths$
----where location like '%state%'
--group by location, population
--order by PercentPopulationInfected desc

---- LET'S BREAK THINGS DOWN BY CONTINENT
--select continent, MAX(cast(total_deaths as int)) as TotalDeathbyContinent
--from PortfolioProject..CovidDeaths$
--where continent is not NULL
--group by continent 
--order by TotalDeathbyContinent desc


--Showing the country with Highest Death Count per Population
--select location, MAX(total_deaths) as TotalDeathCount
--from PortfolioProject..CovidDeaths$
--group by location
--order by TotalDeathCount desc

-- Showing the continent with The Highest Death Count
select continent, MAX(cast(total_deaths as int)) as TotalDeathbyContinent
from PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent 
order by TotalDeathbyContinent desc

-- GLOBAL NUMBERS
--Calculate the DeathPercentage from over the world
select  date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not Null
group by Date
order by 1,2


-- JOIN 2 TABLE COVIDDEATHS AND COVIDVACCINATIONS
select *
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
--USE CTE
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- CREATE TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated


--Creating View to store data for later Visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not Null
--order by 2,3
Select *
from PercentPopulationVaccinated