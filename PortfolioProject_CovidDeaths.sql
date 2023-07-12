--select *
--from PortfolioProject..CovidDeaths
--ORDER BY 3,4

--select *
--from PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject.dbo.CovidDeaths
--Order by 1,2


-- Calculate the percent of infections that resulted in deaths

Select Location, date, total_cases, total_deaths, CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_deaths) / CONVERT(DECIMAL(18, 4), total_cases)))*100 as [DeathPercentage]
From PortfolioProject.dbo.CovidDeaths
Where location = 'United States'
Order by 1,2

-- Calculate the percent of the total population that has been infected with the virus

Select Location, date, population, total_cases, total_deaths, CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_cases) / population))*100 as [PercentOfPopulationInfected]
From PortfolioProject.dbo.CovidDeaths
Where location = 'United States'
Order by 1,2

-- Highest infection rates by country

Select Location, population, MAX(Convert(bigint, total_cases)) as HighestInfectionCount, MAX(CONVERT(bigint, total_cases) / population)*100 as
PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentPopulationInfected desc

-- Countries with highest death count

Select Location, Max(Cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Countries with Highest Death Count per Population

Select Location, population, Max(Convert(bigint, total_deaths)) as HighestDeathCount, Max(Convert(bigint, total_deaths) / population) * 100 as
PercentPopulationDeaths
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentPopulationDeaths desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Looking at total population vs Vaccinations with CTE

With PopvsVac (continent, Location, date, population, new_vaccinations, RollingTotalVaccinations)
as
(
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
)
Select *, (RollingTotalVaccinations/population)*100 as PercentPopulationVaccinated
From PopvsVac

-- Looking at total population vs Vaccinations with temporary table

Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVaccinations numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null
Select *, (RollingTotalVaccinations/population)*100 as PercentPopulationVaccinated
From #PercentPeopleVaccinated

-- Creating views for visualization

-- View of Percent of People Vaccinated 

Create view PercentPeopleVaccinated as
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, dea.date) as RollingTotalVaccinations
From PortfolioProject.dbo.CovidDeaths as dea
	join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.Location = vac.Location
	and dea.date = vac.date
	Where dea.continent is not null

-- Creat view for Highest Deaths by Continent

Create view HighestDeathsbyContinent as
Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

-- Create view for Highest Deaths by Country per total Population

Create view HighestDeathsbyCountryperPopulation as
Select Location, population, Max(Convert(bigint, total_deaths)) as HighestDeathCount, Max(Convert(bigint, total_deaths) / population) * 100 as
PercentPopulationDeaths
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, population

-- Create view for Countries with the Highest Death Counts

Create view CountriesWithHighestDeathCount as
Select Location, Max(Cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
