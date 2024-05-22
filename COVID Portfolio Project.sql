Select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total cases Vs Total deaths

Select location, date, total_cases ,total_deaths , (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Shows the likelihood of dying if one contracts Covid in their country
Select location, date, total_cases ,total_deaths , (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null, location like '%Canada%'
order by 1,2

--Looking at the Total cases Vs Population
--Shows the precentage of population that got Covid
Select location, date, total_cases, population, (CAST(total_cases as float)/CAST(population as float))*100 as ContractionPercentage
from PortfolioProject..CovidDeaths
where location like '%Cayman%'
order by 1,2

--Looking at countries with highest infection rate compared to the whole populatio

Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((CAST(total_cases as float)/CAST(population as float)))*100 as ContractionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by ContractionPercentage desc


--Showing countries with highest Death count per Population

Select location, MAX(CAST (total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Breakdown of Data by Continent

--Showing continents with the Highest Death Count per Population
Select continent, MAX(CAST (total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the continents with the highest Infection Rate 
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((CAST(total_cases as float)/CAST(population as float)))*100 as ContractionPercentage
from PortfolioProject..CovidDeaths
where continent is null
Group by location, population
order by ContractionPercentage desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalGlobalCases, SUM(CAST (new_deaths as float))
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
group by date
order by 1,2

Select continent, SUM(new_cases) as TotalGlobalCases, SUM(CAST (new_deaths as float)) as TotalGlobalDeaths
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
group by continent
order by TotalGlobalCases

Select date, SUM(CAST(new_cases as float)) as TotalGlobalCases, SUM(CAST (new_deaths as float)) as TotalGlobalDeaths, (SUM(CAST (new_deaths as float))/SUM(CAST(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
group by date
order by 1,2

Select SUM(CAST(new_cases as float)) as TotalGlobalCases, SUM(CAST (new_deaths as float)) as TotalGlobalDeaths, (SUM(CAST (new_deaths as float))/SUM(CAST(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
--group by date
order by 1,2



--Join table CovidDeaths and CovidVaccinations
--Looking at Total Population Vs Vaccinations

Select *
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as float)) OVER (Partition by Dea.location order by Dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
where Dea.continent is not null
order by 2,3


--USE CTE , because we could not do calculations by refering to a newly created variable which is RollingPeopleVaccinated
-- We want to find the percentage of people that have been vaccinated in a particular population

With PopsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated  )
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as float)) OVER (Partition by Dea.location order by Dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
where Dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
from PopsVac


--TEMP TABLE
Drop Table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population float,
new_vaccinations float,
RollingPeoplevaccinated float
)

Insert into PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as float)) OVER (Partition by Dea.location order by Dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
--where Dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View RollingPeopleView as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as float)) OVER (Partition by Dea.location order by Dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
where Dea.continent is not null

Select *
from RollingPeopleView

Create View DeathPercentageView as
Select date, SUM(CAST(new_cases as float)) as TotalGlobalCases, SUM(CAST (new_deaths as float)) as TotalGlobalDeaths, (SUM(CAST (new_deaths as float))/SUM(CAST(new_cases as float)))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
group by date
--order by 1,2


Create View TotalGlobalNUmbers as
Select continent, SUM(new_cases) as TotalGlobalCases, SUM(CAST (new_deaths as float)) as TotalGlobalDeaths
from PortfolioProject..CovidDeaths
where continent is not null AND new_cases !='0' AND  new_deaths !='0'
group by continent
--order by TotalGlobalCases


Create View HighestInfectionRate as
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((CAST(total_cases as float)/CAST(population as float)))*100 as ContractionPercentage
from PortfolioProject..CovidDeaths
where continent is null
Group by location, population
--order by ContractionPercentage desc
