-- Select data I am going to be using


SELECT 
location,date,total_cases,New_cases, total_deaths, population
FROM `dap-c3.CovidProject.CovidDeaths` 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM `dap-c3.CovidProject.CovidDeaths` 
WHERE location = 'United States'
AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage got covid

SELECT 
location,date,population,total_cases, (total_cases/population)*100 AS percentage_of_population_infected
FROM `dap-c3.CovidProject.CovidDeaths` 
WHERE location = 'United States'
AND continent is not null
order by 1,2

-- Looking at countries with Highest Infection rate compared to Population

SELECT 
location,population,MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS Percent_of_population_infected
FROM `dap-c3.CovidProject.CovidDeaths` 
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location,population
order by Percent_of_population_infected desc

-- Showing Countries with Highest Death Count per Population

SELECT 
location, MAX(cast(total_deaths as INT)) AS Total_Death_Count
FROM `dap-c3.CovidProject.CovidDeaths` 
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc

-- LETS'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count per population

SELECT 
continent, MAX(cast(total_deaths as INT)) AS Total_Death_Count
FROM `dap-c3.CovidProject.CovidDeaths` 
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

-- GLOBAL NUMBERS

SELECT 
date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM `dap-c3.CovidProject.CovidDeaths` 
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY date
order by 1,2

-- Total Death Percentage from new cases and new deaths

SELECT 
SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM `dap-c3.CovidProject.CovidDeaths` 
-- WHERE location = 'United States'
WHERE continent is not null
-- GROUP BY date
order by 1,2

SELECT 
SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM `dap-c3.CovidProject.CovidDeaths` 

-- Looking at Total Population vs Vaccinations

SELECT 
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS rollingpeoplevaccinated
FROM `dap-c3.CovidProject.CovidDeaths` dea
JOIN `dap-c3.CovidProject.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac as
(SELECT 
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS rollingpeoplevaccinated
FROM `dap-c3.CovidProject.CovidDeaths` dea
JOIN `dap-c3.CovidProject.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)

SELECT *, (rollingpeoplevaccinated/population)*100 as RollingPeopleVaccinatedPercent
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
SELECT 
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS rollingpeoplevaccinated
FROM `dap-c3.CovidProject.CovidDeaths` dea
JOIN `dap-c3.CovidProject.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100 as RollingPeopleVaccinatedPercent
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated as
SELECT 
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS rollingpeoplevaccinated
FROM `dap-c3.CovidProject.CovidDeaths` dea
JOIN `dap-c3.CovidProject.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated
