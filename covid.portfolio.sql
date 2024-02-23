select *
from PortfolioProject.. CovidDeaths$
Where continent is not null
order by 3,4

--select *
--from PortfolioProject.. CovidVaccinations$
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths$
order by 1,2 

-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as PercentpopulationInfected
from PortfolioProject.. CovidDeaths$
Where Location like '%states%'
order by 1,2 



--shows what percentage of population got covid
Select location, date, total_cases, Population, (Total_cases/population)*100 as DeathPercentage
from PortfolioProject.. CovidDeaths$
Where Location like '%states%'
order by 1,2

-- looking at countries with Highest Infection Rate compared to Population
Select location,population, MAX(total_cases)as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.. CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--showing continents with the highest death per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- the correct way of working back into tableu

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject.. CovidDeaths$
-- Where Location like '%states%'
where continent is not null
group by date
order by 1,2 



-- looking at total population vs Vaccinations
Select * 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date


With PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- use cte
With PopvsVac (Continent, Location, date, population RollingPeopleVaccinated)
as


-- temp table

Drop table if exists #percentpopulationvaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3

	Select* 
	from PercentPopulationVaccinated