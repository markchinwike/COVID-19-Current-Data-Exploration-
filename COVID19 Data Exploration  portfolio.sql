/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioWareHouse..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data needed

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioWareHouse..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Germany

Select Location, date, total_cases,total_deaths, Cast (total_deaths as float)/(total_cases)*100 as PercentageDeath
From PortfolioWareHouse..CovidDeaths
Where location like '%Germany%'
and continent is not null 
order by 1,2 DESC


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioWareHouse..CovidDeaths
Where location like '%Germany%'
order by 1,2 


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionRate,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioWareHouse..CovidDeaths
--Where location like '%Germany%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioWareHouse..CovidDeaths
--Where location like '%Germany%'
--and continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioWareHouse..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioWareHouse..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Select *
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageofVaccInd
From PopvsVac



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
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioWareHouse..CovidDeaths dea
Join PortfolioWareHouse..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Conclusion
The exploration of COVID-19 data has provided valuable insights into the global impact of the pandemic. While the crisis may have abated, the lessons learned from analyzing infection rates, death counts, and vaccination progress remain invaluable. This data serves as a reminder of the importance of preparedness and resilience in the face of future health crises. By understanding the patterns and dynamics of COVID-19, we can better equip ourselves to respond effectively to future challenges and safeguard public health worldwide.
