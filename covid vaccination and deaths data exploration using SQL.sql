--jenny.

--EXPLORING THE COVID DATA obtained from https://ourworldindata.org/covid-deaths
--Partitioned into deaths and vaccination table,using 
--my SQL database to help us derive insights and to create views to be 
-- used for visualizations with tableau

-- Viewing the deaths table
SELECT *
FROM portfolio..CovidDeaths$
ORDER BY 3,4

--Viewing the vaccinations table
--SELECT *
--FROM portfolio..CovidVaccinations$
--ORDER BY 3,4

--Data selection
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM portfolio..CovidDeaths$
ORDER BY 1,2

--Total deaths for cases found
SELECT Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as percentage_death
FROM portfolio..CovidDeaths$
where location='Kenya'
ORDER BY 1,2

--Total cases vs population
SELECT Location,date,total_cases,new_cases,total_deaths,(total_cases/population)*100 as percentage_infected
FROM portfolio..CovidDeaths$
where location='Kenya'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT Location,population,MAX((total_cases/population))*100 as percentage_infected
FROM portfolio..CovidDeaths$
GROUP BY location,population
ORDER BY percentage_infected desc


--Countries with highest DEATH count
SELECT Location,population,MAX(cast(total_deaths as int))*100 as TotalDeathcount
FROM portfolio..CovidDeaths$
WHERE continent is not null
GROUP BY location,population
ORDER BY TotalDeathcount desc

--Continent  with highest DEATH count
SELECT Location,population,MAX(cast(total_deaths as int))*100 as TotalDeathcount
FROM portfolio..CovidDeaths$
WHERE continent is null and location not like '%income%' and location not like '%International%'
GROUP BY location,population
ORDER BY TotalDeathcount desc


--income group with highest DEATH count
SELECT Location,population,MAX(cast(total_deaths as int))*100 as TotalDeathcount
FROM portfolio..CovidDeaths$
WHERE location like '%income%'
GROUP BY location,population
ORDER BY TotalDeathcount desc

--Death percentage in kenya
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolio..CovidDeaths$
WHERE location = 'Kenya'
ORDER BY 1,2


--VACCINATIONS TABLE 

-- Looking at total population vs Vaccination
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to look at percentage of people vaccinated in kenya
WITH popvsvac (continent,location,date,population,new_vaccination,RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.location='Kenya'
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS perc_vaccinated
FROM popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEWS FOR LATER USE

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

FROM portfolio..CovidDeaths$ dea
JOIN portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date--
where dea.continent is not null 

--Continent  with highest DEATH count view
Create View deathcount as
SELECT Location,population,MAX(cast(total_deaths as int))*100 as TotalDeathcount
FROM portfolio..CovidDeaths$
WHERE continent is null and location not like '%income%' and location not like '%International%'
GROUP BY location,population








