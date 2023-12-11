USE Portfolio_Covid --Database name
GO

--EDA on the datasets

SELECT *
FROM CovidDeaths
Where continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths
FROM CovidDeaths
ORDER BY 1,2

--looking at total Cases vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
-- specify where the location/nation 
WHERE location = 'Indonesia'
ORDER BY 1, 2

--looking at Total Cases vs Population
-- shows percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 PopulationPercentage
FROM CovidDeaths
ORDER BY 1, 2

-- Looking at countries with highest infection rate 
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 PopulationPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY PopulationPercentage DESC

-- showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as bigint)) as TotalDeathsCount
FROM CovidDeaths
-- filter location column is exact country name not continent
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

--data distribution based on continent
SELECT location, MAX(CAST(total_deaths as bigint)) as TotalDeathsCount
FROM CovidDeaths
-- filter location column is exact country name not continent
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as bigint)) as TotalNewDeaths,
	SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS NewDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 

--Looking at Total Population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS CummulativeVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3 

--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS CummulativeVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CummulativeVaccinations/Population)*100 AS Percentage
FROM PopvsVac

--using Temporary Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
CummulativeVaccinations NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS CummulativeVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT*, (CummulativeVaccinations/Population)*100 AS Percentage
FROM #PercentagePopulationVaccinated

--creating view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS CummulativeVaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated
