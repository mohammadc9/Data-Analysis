ALTER TABLE CovidDeaths
DROP COLUMN `index`;

ALTER TABLE CovidVaccinations
DROP COLUMN `index`;

SELECT * FROM CovidVaccinations;

SELECT`location`,`date`,total_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2;


SELECT `location`,`date`,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPCT FROM CovidDeaths WHERE `location` LIKE '%Italy%' ORDER BY DeathPCT desc;


SELECT`location`,max(total_cases)AS highestinfected,population,max((total_cases/population))*100 AS infectionPCT FROM CovidDeaths WHERE ((total_cases/population)*100)>8 GROUP BY population,`location` ORDER BY infectionPCT DESC;




SELECT `location` , max(total_deaths) AS totaldeath FROM CovidDeaths WHERE continent is NULL GROUP BY `location`;


SELECT
	dea.continent,
	dea. `location`,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.`location` ORDER BY dea.`location`,dea.`date`) as RolingPeopleVaccinated
FROM
	CovidDeaths dea
	JOIN CovidVaccinations vac ON dea. `location` = vac. `location`
		AND dea.date = vac. `date`
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,3;



with PopVSVac (continent,`location`,`date`,population,new_vaccinations,RolingPeopleVaccinated)

AS 
(
SELECT
	dea.continent,
	dea. `location`,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.`location` ORDER BY dea.`location`,dea.`date`) as RolingPeopleVaccinated
FROM
	CovidDeaths dea
	JOIN CovidVaccinations vac ON dea. `location` = vac. `location`
		AND dea.date = vac. `date`
WHERE
	dea.continent IS NOT NULL
-- ORDER BY
	-- 2,3
)
SELECT *, (RolingPeopleVaccinated/population)*100 as VaccinatedPCT FROM PopVSVac WHERE new_vaccinations is NOT NULL;


-- temp TABLE

DROP TABLE IF EXISTS PctPeopleVaccinated;

CREATE TABLE PctPeopleVaccinated
(
continent VARCHAR(255) ,
`location` VARCHAR(255),
`Date` datetime,
population int,
new_vaccinations int,
RolingPeopleVaccinated NUMERIC
);


INSERT INTO PctPeopleVaccinated
SELECT
	dea.continent,
	dea. `location`,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.`location` ORDER BY dea.`location`,dea.`date`) as RolingPeopleVaccinated
FROM
	CovidDeaths dea
	JOIN CovidVaccinations vac ON dea. `location` = vac. `location`
		AND dea.date = vac. `date`
WHERE
	dea.continent IS NOT NULL
ORDER BY 2,3;


CREATE VIEW PctPeopleVaccination AS
SELECT
	dea.continent,
	dea. `location`,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.`location` ORDER BY dea.`location`,dea.`date`) as RolingPeopleVaccinated
FROM
	CovidDeaths dea
	JOIN CovidVaccinations vac ON dea. `location` = vac. `location`
		AND dea.date = vac. `date`
WHERE
	dea.continent IS NOT NULL
ORDER BY 2,3;


SELECT * FROM PctPeopleVaccination;