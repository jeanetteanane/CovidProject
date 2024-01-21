--SELECT * 
--FROM CovidDeaths
--ORDER BY 3, 4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3, 4

-- Select necessary data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Percetage rate of Total Cases vs Total Deaths (death percentage if someone in the country gets covid)
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM CovidDeaths
Where location like '%kingdom%'
and continent is not null
ORDER BY 1, 2

-- Percetage rate of Total Cases vs Population (What percentage of the population got covid)
SELECT location, date, population, total_cases, (total_cases / population) * 100 as CovidPercentage
FROM CovidDeaths
Where location like '%kingdom%'
ORDER BY 1, 2

-- Highest infection percentage of population within a country who got covid
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 as HighestInfectionPercentage
FROM CovidDeaths
--Where location like '%kingdom%'
GROUP BY location, population
ORDER BY HighestInfectionPercentage desc

-- Showing countries with highest death count of population
-- change datatype of total_deaths to int as orginal is nvarchar
SELECT location,  MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
--Where location like '%kingdom%'
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Looking at location highest death count
SELECT location,  MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
--Where location like '%kingdom%'
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Continent with highest death count
SELECT continent,  MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
--Where location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Percentage of death percentage across the world
-- new deaths and new_cases add up to the total for totaldeaths and totalcases
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths AS INT)) as TotalDeaths, SUM(cast(new_deaths AS INT)) / SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
order by 1, 2

-- Looking at people worldwide who have been vaccinated 
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCounter,
--(PeopleVaccinatedCounter/population)*100
--FROM CovidDeaths AS dea
--JOIN CovidVaccinations AS vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null and 
--vac.new_vaccinations is not null
--order by 2, 3

-- Using CTE
WITH PopulationVSVaccination(continent, location, date, population, new_vaccinations, PeopleVaccinatedCounter)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCounter
--(PeopleVaccinatedCounter/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- and vac.new_vaccinations is not null
)
SELECT *, (PeopleVaccinatedCounter/population) * 100
FROM PopulationVSVaccination
order by 1, 2

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentOfPopulationVaccinated
CREATE TABLE #PercentOfPopulationVaccinated(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
PeopleVaccinatedCounter numeric
)

INSERT INTO #PercentOfPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCounter
--(PeopleVaccinatedCounter/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- and vac.new_vaccinations is not null

SELECT *, (PeopleVaccinatedCounter/population) * 100
FROM #PercentOfPopulationVaccinated
order by 1, 2

-- Creating View to store data for visualisations
CREATE VIEW PercentOfPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCounter
--(PeopleVaccinatedCounter/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM PercentOfPopulationVaccinated