/* 
Exploratory Data Analysis for Covid 19 Data

Data Source: ourworldindata.org/covid-deaths
-> Splitted into two tables: CovidDeahts and CovidVaccinations

The following Skills are applied: Joins, CTE, Temp Table, Aggregate Functions, Views, Converting Data Types
*/

-- First look at CovidDeaths table
Select *
From CovidProject..CovidDeaths
Where continent is not null
order by 3,4


-- The data from the table that will be analysed here:
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths in Germany
--		-> How likely is it to die from an infection?
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'Germany'
order by 1,2


-- Looking at Total Cases vs Population
--		-> What percentage of the population is or was infected?
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From CovidProject..CovidDeaths
Where location like 'Germany'
order by 1,2


-- Looking at Countries with Highest Infection Rate of Population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
From CovidProject..CovidDeaths
Group by Location, population
order by InfectedPercentage desc


-- Showing Countries with Highest Death Count 
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing Countries with Highest Share of Population Died
Select Location, (Max(cast(total_deaths as int))/max(population))*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by Location
order by DeathPercentage desc


--------------------------
-- BREAK DOWN BY CONTINENT
--------------------------


-- showing continents with highest death count 
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- showing continents with highest death percentage
Select location, Max(cast(total_deaths as int))/Max(population)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is null
Group by location
order by DeathPercentage desc



-- Global Numbers

--		by date
Select date, Sum(New_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From CovidProject..covidDeaths
where continent is not null
Group by date
order by 1,2


--		in total
Select Sum(New_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From CovidProject..covidDeaths
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
--, (Rolling_Vaccination_Count/population)*100 
From CovidProject..covidDeaths dea
Join CovidProject..covidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Rolling_Vaccination_Count cannot be used as intend in the line commented out, but there are other options:

--		1) USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccination_Count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
--(Rolling_Vaccination_Count/population)*100 
From CovidProject..covidDeaths dea
Join CovidProject..covidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Rolling_Vaccination_Count/Population)*100 as PercentVaccinated
From PopVsVac


-- 2) TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccination_Count numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
--(Rolling_Vaccination_Count/population)*100 
From CovidProject..covidDeaths dea
Join CovidProject..covidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null


Select *, (Rolling_Vaccination_Count/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
--(Rolling_Vaccination_Count/population)*100 
From CovidProject..covidDeaths dea
Join CovidProject..covidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated