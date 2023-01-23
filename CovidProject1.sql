select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4


-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows liklihood of dying if you contract covid in your country


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

select location, date, Population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentOfPopulationInfected DESC

-- Showing Countries with the Highest Death Count Per Population

select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Let's Break Things Down By Continent

-- -- Showing the Continents with the Highest Death Count Per Population


select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Total Population vs Vaccinations 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Use CTE

With PopvsVac (Continet, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table

Drop Table if exists  #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3