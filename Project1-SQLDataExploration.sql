--PROJECT 1 : SQL DATA EXPLORATION

SELECT * FROM CovidVaccinations order by 3, 4

--Selecting the data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths order by 1, 2

-- Total cases vs total deaths
SELECT Location, date,total_deaths, total_cases, (cast(total_cases as int)/cast(total_deaths as int))*100 AS DeathPercentage
FROM CovidDeaths 
WHERE location like '%states%'
order by 1, 2

--Total cases vs Population
SELECT Location, date,total_cases, Population, (cast(total_cases as float)/cast(population as float))*100 AS PercentPopulationInfected
FROM CovidDeaths 
WHERE location like '%states%'
order by 1, 2

-- Countries with highest infected rate compared to population
SELECT Location,Population, MAX(cast(total_cases as float)) AS HighestInfectionCount, 
MAX(cast(total_cases as float)/cast(population as float))*100 AS PercentPopulationInfected
FROM CovidDeaths 
--WHERE location like '%states%'
GROUP BY Location, Population
order by PercentPopulationInfected DESC

-- Countries with Highest Death count per population
SELECT Location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM CovidDeaths 
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY Location
order by TotalDeathCount DESC

--By continents
SELECT location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM CovidDeaths 
--WHERE location like '%states%'
WHERE continent is NULL
GROUP BY location
order by TotalDeathCount DESC

-- Global numbers grouping by dates
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date ORDER BY 1, 2

--Joining the covid deaths table with covid vaccinations table
SELECT * FROM CovidDeaths death JOIN CovidVaccinations vaccine 
ON death.location = vaccine.location AND death.date = vaccine.date

--Total population that got vaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
FROM CovidDeaths death JOIN CovidVaccinations vaccine 
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 2, 3

--Using CTE's
WITH PopulationVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS RollingPeopleVaccinated
FROM CovidDeaths death JOIN CovidVaccinations vaccine 
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVaccinated

--Using temp tables
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS RollingPeopleVaccinated
FROM CovidDeaths death JOIN CovidVaccinations vaccine 
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Using views 
Create VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations as BIGINT))
OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS RollingPeopleVaccinated
FROM CovidDeaths death JOIN CovidVaccinations vaccine 
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM PercentPopulationVaccinated


