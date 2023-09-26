select *
from Portfolio..CovidDeaths1
where continent is not null
order by 3,4

--looking at Total Cases vs Total Death
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths1
Where location like '%nigeria%'
Order By 1,2

--looking at the Total Cases vs Population
--show what percentage of population got covid

Select location, date,population, total_cases,  (total_cases/population)*100 as Percent_of_Population_Infected
From Portfolio..CovidDeaths1
Where location like '%nigeria%'
Order By 1,2


--looking at countries with highest infection rate compare to population

Select location,population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as Percent_of_Population_Infected
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
Group By location,population
Order By Percent_of_Population_Infected DESC

--Showing the countries with the Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
where continent is not null
Group By location
Order By TotalDeathCount DESC

--let's break things down by continent

Select continent, MAX(total_deaths) as TotalDeathCount
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
where continent is not null
Group By continent
Order By TotalDeathCount DESC

--showing the continent with the highest death count
Select continent, MAX(total_deaths) as TotalDeathCount
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
where continent is not null
Group By continent
Order By TotalDeathCount DESC

--Showing the continent with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
where continent is not null
Group By continent
Order By TotalDeathCount DESC

--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths1
--Where location like '%nigeria%'
WHERE continent is not null
AND new_cases !=0 AND new_deaths !=0
Group by date
Order By 1,2


--Looking at Total Population ns Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 --SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
 --(RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths1  dea
Join Portfolio..CovidVaccination1  vac
	on dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 1,2,3




--USE CTE

with Popvsvac (continent,location,Date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 --SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths1  dea
Join Portfolio..CovidVaccination1  vac
	on dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from Popvsvac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 --SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths1  dea
Join Portfolio..CovidVaccination1  vac
	on dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to stor data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 --SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths1  dea
Join Portfolio..CovidVaccination1  vac
	on dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated