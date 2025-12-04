-- Looking at the Total Cases vs Population --
-- Shows what percentage of population got Covid --

SELECT Location, date, total_cases, population, ((total_cases/population)*100) as InfectionRate
FROM `processing-with-sql-p1.Covid.Covid_deaths`
WHERE location LIKE "%States%"
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

/* 
SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as InfectionRate
FROM `processing-with-sql-p1.Covid.Covid_deaths`
GROUP By Location, population
ORDER BY InfectionRate desc 
*/

-- Showing Countries with Highest Death Count per Population --

SELECT Location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(total_deaths/population)*100 as DeathRate
FROM `processing-with-sql-p1.Covid.Covid_deaths`
WHERE continent is not null
GROUP BY Location, population
ORDER BY DeathRate desc

-- LET'S BREAK THINGS DOWN BY CONTINENT--

SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM `processing-with-sql-p1.Covid.Covid_deaths`
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths desc

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM `processing-with-sql-p1.Covid.Covid_deaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2 


-- Looking at Total Population vs Vaccinations -- 

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated
FROM `processing-with-sql-p1.Covid.Covid_vaccinations` as VAC
JOIN `processing-with-sql-p1.Covid.Covid_deaths` AS DEA
  On DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

-- USE CTE --

WITH PopvsVac AS (SELECT continent, location, date, population, new_vaccinatons, RollingPeopleVaccinated)
(
  SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated
FROM `processing-with-sql-p1.Covid.Covid_vaccinations` as VAC
JOIN `processing-with-sql-p1.Covid.Covid_deaths` AS DEA
  On DEA.location = VAC.location
  AND DEA.date = VAC.date
Where DEA.continent is not null
)



WITH PopvsVac AS (
  SELECT
    DEA.continent,
    DEA.location,
    DEA.date,
    DEA.population,
    VAC.new_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS INT64))
        OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated
  FROM `processing-with-sql-p1.Covid.Covid_vaccinations` AS VAC
  JOIN `processing-with-sql-p1.Covid.Covid_deaths` AS DEA
      ON DEA.location = VAC.location
     AND DEA.date = VAC.date
  WHERE DEA.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaccinated
FROM PopvsVac;



CREATE VIEW `processing-with-sql-p1.Covid.PercentPopulationVaccinated` AS
SELECT
    DEA.continent,
    DEA.location,
    DEA.date,
    DEA.population,
    VAC.new_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS INT64))
        OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated,
    (SUM(CAST(VAC.new_vaccinations AS INT64))
        OVER (PARTITION BY DEA.location ORDER BY DEA.date) / DEA.population) * 100
        AS PercentPopVaccinated
FROM `processing-with-sql-p1.Covid.Covid_vaccinations` AS VAC
JOIN `processing-with-sql-p1.Covid.Covid_deaths` AS DEA
    ON DEA.location = VAC.location
   AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL;