USE covidafrica;

-- Likelihood of dying with Covid 
SELECT location, date, total_cases, new_cases, round((total_deaths/total_cases) *100, 3) as deathPercentage, total_deaths, population
FROM `covid-data-africa-deathscsv`
Where location = 'Zimbabwe';


-- Total cases vs Population (percentage of population with covid)
SELECT location, date, total_cases, new_cases, round((total_cases/population) *100, 5) as InfectionRate, total_deaths, population
FROM `covid-data-africa-deathscsv`
Where location = 'Zimbabwe';

-- Looking at countries with Highest infection rate compared to population
SELECT location, population,  max(total_cases) as HighestInfectionCount, MAX(round((total_cases/population) *100, 5)) as populationInfectionRate
FROM `covid-data-africa-deathscsv`-- Where location = 'Zimbabwe'
GROUP BY location, population
ORDER BY populationInfectionRate DESC;

-- Looking at countries with highest death count per population
SELECT location, population,  max(total_deaths) as HighestDeathCount, MAX(round((total_deaths/population) *100, 5)) as populationDeathRate
FROM `covid-data-africa-deathscsv`-- Where location = 'Zimbabwe'
GROUP BY location, population
ORDER BY populationDeathRate DESC;

-- CONTINENTAL VALUES (total cases and deaths)
SELECT date, sum(total_cases) as 'total cases', sum(total_deaths) as 'total deaths'
FROM `covid-data-africa-deathscsv`-- Where location = 'Zimbabwe'
GROUP BY date
ORDER BY 'total cases' DESC;

-- Death coninental
SELECT date, sum(total_cases) as 'total cases', sum(total_deaths) as 'total deaths'
FROM `covid-data-africa-deathscsv`-- Where location = 'Zimbabwe'
GROUP BY date
ORDER BY 'total cases' DESC;

-- Continental deathrate
SELECT date,  sum(new_cases) as 'new cases', sum(new_deaths) as 'new deaths', sum(new_deaths)/sum(new_cases)*100 as deathRate
FROM `covid-data-africa-deathscsv`-- Where location = 'Zimbabwe'
GROUP BY date
ORDER BY deathRate DESC;

-- VACCINATIONS EVALUATIONS
 -- SUM(dths.new_cases) as Total_cases, SUM(vacc.new_vaccinations) as Total_vaccinations, SUM(dths.new_deaths) as Total_deaths, max(dths.population) over()

-- TOTAL POPULATION VS VACCINATIONS
SELECT dths.location, dths.date, dths.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER(partition by dths.location ORDER by dths.location, dths.date) as total_vaccination
FROM `covid-data-africa-deathscsv` as dths
JOIN `covid-data-vaccination-africacsv` vacc
ON dths.location = vacc.location and dths.date = vacc.date;
-- WHERE new_vaccinations IS NOT NULL;
-- GROUP BY dths.location
-- ORDER BY 2 DESC;

-- Comparing the total vaccinated with total population
-- Creating temp table
DROP TABLE IF exists country_by_vacc;
CREATE TABLE  country_by_vacc(location VARCHAR(40), proportion FLOAT);
INSERT INTO country_by_vacc(
WITH vaccinated(location, date, population, new_vaccinations, total_vaccination) as 
(SELECT dths.location, dths.date, dths.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER(partition by dths.location ORDER by dths.location, dths.date) as total_vaccination
FROM `covid-data-africa-deathscsv` as dths
JOIN `covid-data-vaccination-africacsv` vacc
ON dths.location = vacc.location and dths.date = vacc.date)

SELECT location, max(total_vaccination/population) as vaccinated_proportion_max
FROM vaccinated v
group by v.location
HAVING vaccinated_proportion_max > 0.3);

-- CREATING VIEWS FOR VISUALIZATIONS
CREATE view country_by_vaccination AS 
WITH vaccinated(location, date, population, new_vaccinations, total_vaccination) as 
(SELECT dths.location, dths.date, dths.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER(partition by dths.location ORDER by dths.location, dths.date) as total_vaccination
FROM `covid-data-africa-deathscsv` as dths
JOIN `covid-data-vaccination-africacsv` vacc
ON dths.location = vacc.location and dths.date = vacc.date)

SELECT location, max(total_vaccination/population) as vaccinated_proportion_max
FROM vaccinated v
group by v.location
HAVING vaccinated_proportion_max > 0.3;



SELECT *
FROM `covid-data-africa-deathscsv`
LIMIT 5