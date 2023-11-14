SELECT *
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--WHERE continent is not NULL
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population 
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths vs Death%"
--Shows likelihood of dying if you contract covid in Cyprus.
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS 'Death%'
From PortfolioProject..CovidDeaths
WHERE location = 'Cyprus' and continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Population 
--Shows what % of Population got Covid
SELECT location,date,population,total_cases, (total_cases/population)*100 AS 'Population_Covid_%'
From PortfolioProject..CovidDeaths
WHERE location = 'Cyprus' and continent is not NULL
ORDER BY 1,2

--Looking at countries-with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS '%PopulationInfected' 
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By Location,population
ORDER BY 4 DESC


--Showing the countries-with Highest Death Count per Population
SELECT location,MAX(cast(total_deaths AS int)) AS 'TotalDeathCount'
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 DESC


--Showng continents with the highest death count per population
SELECT location,MAX(cast(total_deaths AS int)) AS 'TotalDeathCount'
From PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY 2 DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as 'Death%'
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


--Looking at Total Population and Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (Continent,location,date,population,new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMPTABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations.

CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3