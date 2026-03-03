-- Zjištění stejných roků

SELECT *
FROM czechia_payroll;

SELECT
    MIN(payroll_year) AS nejnizsi_rok,
    MAX(payroll_year) AS nejvyssi_rok
FROM czechia_payroll;

-- roky jsou mezi 2000 a 2021

SELECT *
FROM czechia_price;

SELECT
    MIN(date_from) AS nejnizsi_rok,
    MAX(date_from) AS nejvyssi_rok
FROM czechia_price;

-- roky jsou mezi 2006 a 2018

-- společné roky jsou tedy mezi 2006 a 2018

-- tabulka s daty s mzdami a cenami
CREATE TABLE t_marie_belingerova_project_SQL_primary_final AS
SELECT
	cpay.payroll_year AS roky,
	cpib.name AS odvetvi,
	round(avg(cpay.value)::NUMERIC, 2) AS mzdy,
	cp.category_code,
	cpc.name AS nazev_zbozi,
	round(avg(cp.value)::NUMERIC, 2) AS ceny
FROM czechia_payroll cpay
LEFT JOIN czechia_payroll_industry_branch cpib ON cpay.industry_branch_code = cpib.code
LEFT JOIN czechia_price cp ON cpay.payroll_year = date_part('year', cp.date_from)
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
WHERE
	cpay.value IS NOT NULL AND
	cpay.value_type_code = '5958' AND 
	cpay.payroll_year BETWEEN 2006 AND 2018 AND
	cpib.name IS NOT NULL
GROUP BY
	roky,
	odvetvi,
	cp.category_code,
	cpc.name
ORDER BY
	cpib.name,
	cpay.payroll_year
;

SELECT *
FROM t_marie_belingerova_project_SQL_primary_final;


-- tabulka s daty o HDP, GINI koeficientem a populací dalších evropských států
CREATE TABLE t_marie_belingerova_project_SQL_secondary_final AS
SELECT
	c.country AS zeme,
	e.population AS populace,
	e.year AS rok,
	e.gdp AS hdp,
	e.gini AS gini
FROM countries c
LEFT JOIN economies e ON c.country = e.country
WHERE
	c.continent = 'Europe' AND
	e.year BETWEEN 2006 AND 2018
ORDER BY
	c.country,
	e.year;

SELECT *
FROM t_marie_belingerova_project_SQL_secondary_final;

