Select *
From dbo.covidDeaths
Order by 3,4

Select *
From dbo.covidVaccinations
Order by 3,4

--Select the data we needed in analysis

Select location, date ,total_cases, new_cases, total_deaths, population
From dbo.covidDeaths
Order by 1,2

--Comparing total deaths to total cases
Select location, date ,total_cases,total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
From dbo.covidDeaths
Where total_cases is not null
Order by 2,3


--Chance of dying when infected in Philippines 

Select location, date ,total_cases,total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
From dbo.covidDeaths
Where total_cases is not null and total_deaths is not null and location like '%pines%'
Order by 2,3

--Comparing total population to the total cases 

Select location, date ,total_cases,population, (convert(decimal,total_cases)/convert(decimal,population))*100 as InfectedPercentage
From dbo.covidDeaths
Where total_cases is not null
Order by InfectedPercentage desc

--Looking at countries with the highest infection rate compared to population 

Select location, population,Max(total_cases) as HighestInfectionCount, Max((convert(decimal,total_cases)/convert(decimal,population))) * 100 as InfectedPercentage
From dbo.covidDeaths
Group by location, population
Order by InfectedPercentage desc

--Showing countries with highest death count

Select location, Max(convert(bigint,total_deaths)) as DeathCount
From dbo.covidDeaths
Where continent is not null
Group by location
Order by DeathCount desc

--Continents with highest death count

Select continent, Max(convert(bigint,total_deaths)) as DeathCount
From dbo.covidDeaths
Where continent is not null
Group by continent
Order by DeathCount desc

--Global numbers
Select date, Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/Sum(new_cases) as DeathPercentage
From dbo.covidDeaths
Where new_cases > 0 
Group by date
Order by date asc

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/Sum(new_cases) as DeathPercentage
From dbo.covidDeaths
Where continent is not null
Order by 1,2

--Comparing total vaccinations to the total population 
--USING CTE
With VacVsPop (continent, location, date, population, new_vaccinnations, RollingVaccinationCount)as 
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
Sum(Convert(decimal,cv.new_vaccinations)) Over (Partition by cd.location Order by cd.location,cd.location,cd.date) as RollingVaccinationCount
From DealingWithSQL..covidDeaths cd
Join DealingWithSQL..covidVaccinations cv
On cd.date = cv.date and cd.location = cv.location
Where cd.continent is not null and cv.new_vaccinations is not null

)
Select *, (RollingVaccinationCount/population) * 100 as PercentagePopulationVaccinated
From VacVsPop


--Create view to store data

Create View PercentPopulationVaccinated as

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
Sum(Convert(decimal,cv.new_vaccinations)) Over (Partition by cd.location Order by cd.location,cd.location,cd.date) as RollingVaccinationCount
From DealingWithSQL..covidDeaths cd
Join DealingWithSQL..covidVaccinations cv
On cd.date = cv.date and cd.location = cv.location
Where cd.continent is not null and cv.new_vaccinations is not null