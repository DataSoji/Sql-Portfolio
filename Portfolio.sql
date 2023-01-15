USE [Covid 19]

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we aregoing to be uisng
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2


-- Total Cases Vs Total Death
-- Percentage of Death for likelihood after contracting Covid-19
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE location like '%Nigeria%' 
ORDER BY 1,2

-- Total Cases Vs Population
-- Population percent the contracted Covid-19
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_percent
FROM CovidDeaths
WHERE location like '%Nigeria%' 
ORDER BY 1,2

-- Countries with Highest Infection Rate
SELECT location, population, MAx(total_cases) AS Highest_Infection_Count,
MAX((total_cases/population))*100 AS Population_percent
FROM CovidDeaths
--WHERE location like '%Nigeria%' 
GROUP BY location, population
ORDER BY Population_percent DESC


SELECT location, MAX (cast(total_deaths as int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--Continent with Highest Death Count Per Population
SELECT continent, MAX (cast(total_deaths as int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Global Numbers
SELECT SUM(new_cases) AS New_cases, SUM(CAST(new_deaths AS INT)) AS  New_Deaths,
SUM(CAST (New_Deaths AS INT))/SUM(New_cases) * 100 AS Percentage_Deaths
--total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths
--WHERE location like '%Nigeria%' 
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccination over partition by 
-- USE CTE

 With PopvsVac (continent, location, Date, population, new_vaccinations, Total_new_Vaccinations)
 AS
(
SELECT CV.continent, CV.location, 
CV.date, population, CV.new_vaccinations,
 SUM(cast(CV.new_vaccinations AS INT)) 
 OVER (PARTITION BY CV.location 
 ORDER BY CV.location, CV.date) AS Total_new_Vaccinations
 --(Total_new_Vaccinations/population)*100
 FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
 ON CD.location = CV.location
 AND CD.date = CV.date
 WHERE CV.continent IS NOT NULL
 --ORDER BY 2,3
 )

 SELECT *, (Total_new_Vaccinations/population)*100 AS Vac_percent
 FROM PopvsVac


--TEMP TABLE

DROP TABLE  if exists #PercentPopulation
CREATE TABLE #PercentPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Total_new_Vaccinations numeric
)

INSERT INTO #PercentPopulation
SELECT CV.continent, CV.location, 
CV.date, population, CV.new_vaccinations,
 SUM(cast(CV.new_vaccinations AS INT)) 
 OVER (PARTITION BY CV.location 
 ORDER BY CV.location, CV.date) AS Total_new_Vaccinations
 --(Total_new_Vaccinations/population)*100
 FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
 ON CD.location = CV.location
 AND CD.date = CV.date
 --WHERE CV.continent IS NOT NULL
 --ORDER BY 2,3

SELECT *, (Total_new_Vaccinations/population)*100 AS Vac_percent
FROM #PercentPopulation



-- Creating View to store data
Create View PercentPopulation AS
 SELECT CV.continent, CV.location, 
CV.date, population, CV.new_vaccinations,
 SUM(cast(CV.new_vaccinations AS INT)) 
 OVER (PARTITION BY CV.location 
 ORDER BY CV.location, CV.date) AS Total_new_Vaccinations
 --(Total_new_Vaccinations/population)*100
 FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
 ON CD.location = CV.location
 AND CD.date = CV.date
 WHERE CV.continent IS NOT NULL
 --ORDER BY 2,3

 SELECT *
 FROM PercentPopulation
