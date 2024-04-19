SELECT 
    *
FROM
    coviddeaths
Where continent not like ''
ORDER BY 3 , 4;

SELECT 
    *
FROM
    covidvaccinations
ORDER BY 3 , 4;

-- Select Data that we are going to use

SELECT 
    location,
    date,
    total_case,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1 , 2;

-- Look at Total Cases vs Total Deaths
-- This is the likelihood of death 

SELECT 
    location,
    date,
    total_case,
    total_deaths,
    (total_deaths/total_case)*100 as deathpercentage
FROM
    coviddeaths
ORDER BY 1 , 2;

-- In US

SELECT 
    location,
    date,
    total_case,
    total_deaths,
    (total_deaths/total_case)*100 as deathpercentage
FROM
    coviddeaths
Where location like '%States%'
ORDER BY 1 , 2;

-- Total Cases vs Population in US 
-- What population got Covid

SELECT 
    location,
    date,
    total_case,
    population,
    (total_case/population)*100 as pop_percentage
FROM
    coviddeaths
Where location like '%States%'
ORDER BY 1 , 2;

-- Looking at countries that had the highest infection rate compared to population

SELECT 
    location,
    population,
    max(total_case) as highest_infection_count,
    (max(total_case)/population)*100 as highest_infection_rate
FROM
    coviddeaths
Group by location, population
ORDER BY highest_infection_rate desc;

-- Looking at "large" countries that had the highest infection rate compared to population

SELECT 
    location,
    population,
    max(total_case) as highest_infection_count,
    (max(total_case)/population)*100 as highest_infection_rate
FROM
    coviddeaths
Where population > 10000000
Group by location, population
ORDER BY highest_infection_rate desc;

-- Looking at countries that had the highest death rate compared to population

SELECT 
    location, MAX(total_deaths) AS highest_death_count
FROM
    coviddeaths
WHERE
    continent not like ''
GROUP BY location
ORDER BY highest_death_count DESC;

-- ANALYSIS BY CONTINENT

-- Showing continents with highest death count

SELECT 
    location, MAX(total_deaths) AS highest_death_count
FROM
    coviddeaths
WHERE
    continent like ''
GROUP BY location
ORDER BY highest_death_count DESC;

-- GLOBAL NUMBERS

SELECT 
    date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Deathpercent
FROM
    coviddeaths
WHERE
    continent like ''
Group by date 
ORDER BY 1,2;

-- Total number of cases and deathpercent worldwide

SELECT 
    sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Deathpercent
FROM
    coviddeaths
WHERE
    continent like ''
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations
-- Joining covidvaccinations table

With popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vacc)
as 
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vacc
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
)
Select * , (rolling_people_vacc/population)*100 as rolling_vacc_rate
from popvsvac;

-- Creating Table

Drop table if exists Percentpopulationvaccinated;

Create table Percentpopulationvaccinated
(continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
rolling_people_vacc int);

Insert into Percentpopulationvaccinated
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vacc
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
);

Select * , (rolling_people_vacc/population)*100 as rolling_vacc_rate
from Percentpopulationvaccinated;

-- Creating View to store data for tableau

Create view Percentpopulationvaccinated as
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vacc
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
);