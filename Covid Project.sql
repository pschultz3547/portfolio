
select * 
from covidData..covidDeaths
Where Continent is not null
order by 3,4;

--select * from covidData..covidVacs;
--order by 3,4
-- Select Data that im going to  be using

select location,date, total_Cases, New_cases,total_deaths, population
From covidData..covidDeaths
order by 1,2;

--Total cases vs Total Deaths
--Shows likelyhood of dieng of covid per country

select location,date, total_Cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From covidData..covidDeaths
where location like '%states%'
order by 1,2;

--Total Cases VS.Population
--Shows pecentage of population who contracted Covid


select location,date, total_Cases,Population,(total_Cases/Population)*100 as DeathPercentage
From covidData..covidDeaths
where location like '%states%'
order by 1,2;

--what countries have the highest infection rate vs Population?
--Andorra had the highest percent

select location,Max(total_Cases) as Highestinfectioncount,Population,Max((total_Cases/Population))*100 as Percentpopulationinfected
From covidData..covidDeaths
--where location like '%states%'
Group by location, population
order by Percentpopulationinfected desc;

--Who had the highest Death count per population?
--United States

select location,Max(cast(Total_Deaths as int))as TotalDeathCount
From covidData..covidDeaths
--where location like '%states%'
Where Continent is not Null
Group by location
order by TotalDeathCount desc;

-- Where Contentent is null

select location,Max(cast(Total_Deaths as int))as TotalDeathCount
From covidData..covidDeaths
--where location like '%states%'
Where continent is Null
Group by location
order by TotalDeathCount desc;

--Contenent highest death count

select continent,Max(cast(Total_Deaths as int))as TotalDeathCount
From covidData..covidDeaths
--where location like '%states%'
Where Continent is not Null
Group by continent
order by TotalDeathCount desc;

--Global numbers

select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPecentage 
From covidData..covidDeaths
--where location  like '%States%'
where continent is not null
--Group by Date
order by 1,2;


--Total Vacination Vs Population


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidData..covidDeaths dea
join covidData..covidVacs vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


---Use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidData..covidDeaths dea
join covidData..covidVacs vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3;
)
select*,(rollingpeoplevaccinated/population)*100
from popvsvac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)



insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidData..covidDeaths dea
join covidData..covidVacs vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3;

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--View to store data for future visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidData..covidDeaths dea
join covidData..covidVacs vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3;

select * from covidData..PercentPopulationVaccinated;


Create View Globalnumbers as
select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPecentage 
From covidData..covidDeaths
--where location  like '%States%'
where continent is not null
--Group by Date
--order by 1,2;

Select* From covidData..Globalnumbers

create view infectedvspopulation as
select location,Max(total_Cases) as Highestinfectioncount,Population,Max((total_Cases/Population))*100 as Percentpopulationinfected
From covidData..covidDeaths
--where location like '%states%'
Group by location, population
--order by Percentpopulationinfected desc;

Select* From covidData.. infectedvspopulation