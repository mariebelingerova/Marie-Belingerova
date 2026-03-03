-- Zjištění stejných roků

SELECT *
FROM czechia_payroll;

SELECT *
FROM czechia_payroll
ORDER BY payroll_year;

SELECT *
FROM czechia_payroll
ORDER BY payroll_year desc;

-- roky jsou mezi 2000 a 2021

SELECT *
FROM czechia_price
ORDER BY date_from;

SELECT *
FROM czechia_price
ORDER BY date_from desc;

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


-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT
	pf1.odvetvi AS odvetvi,
	pf1.roky AS rok,
	round(avg(pf1.mzdy)::NUMERIC, 2) AS mzdy,
	pf2.roky AS nasledujici_rok,
	round(avg(pf2.mzdy)::NUMERIC, 2) AS mzdy_nasledujiciho_roku,
	CASE
    	WHEN round(avg(pf2.mzdy)::NUMERIC, 2) > round(avg(pf1.mzdy)::NUMERIC, 2) THEN 'Stoupá'
    	ELSE 'Klesá'
    END AS info
FROM t_marie_belingerova_project_SQL_primary_final pf1
LEFT JOIN t_marie_belingerova_project_SQL_primary_final pf2 ON pf1.odvetvi = pf2.odvetvi AND
	pf2.roky = pf1.roky + 1
WHERE pf2.roky IS NOT null
GROUP BY
	pf1.odvetvi,
	pf1.roky,
	pf2.roky
ORDER BY
	pf1.odvetvi,
	pf1.roky
;


-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední 
-- srovnatelné období v dostupných datech cen a mezd?
SELECT *
FROM t_marie_belingerova_project_SQL_primary_final pf1
WHERE
	nazev_zbozi ILIKE '%mléko%' or 
	nazev_zbozi ILIKE '%chléb%';

-- kód pro chléb je 111301 a pro mléko 114201

SELECT
	nazev_zbozi,
	roky,
	round(avg(pf1.ceny)::NUMERIC, 2) AS ceny,
	round(avg(pf1.mzdy)::NUMERIC, 2) AS mzdy,
	round(avg(pf1.mzdy) / avg(pf1.ceny)) AS pocet
FROM t_marie_belingerova_project_SQL_primary_final pf1
WHERE
	category_code IN (111301, 114201) AND
	roky IN (2006, 2018)
GROUP BY
	nazev_zbozi,
	roky
ORDER BY
	roky
;

-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
CREATE OR REPLACE VIEW v_marie_belingerova_zdrazovani_potravin AS 
SELECT
	pf1.nazev_zbozi AS nazev_zbozi,
	pf1.roky AS rok,
	avg(pf1.ceny) AS cena,
	pf2.roky AS nasledujici_rok,
	round(avg(pf2.ceny)::NUMERIC, 2) AS cena_nasledujiciho_roku,
	round(avg(pf2.ceny)::NUMERIC, 2) - avg(pf1.ceny) AS rozdil,
	round((avg(pf2.ceny) - avg(pf1.ceny)) * 100 / avg(pf1.ceny)::NUMERIC, 2) AS procento
FROM t_marie_belingerova_project_SQL_primary_final pf1
LEFT JOIN t_marie_belingerova_project_SQL_primary_final pf2 ON pf1.nazev_zbozi = pf2.nazev_zbozi  AND
	pf2.roky = pf1.roky + 1
GROUP BY
	pf1.nazev_zbozi,
	pf1.roky,
	pf2.roky
ORDER BY
	pf1.nazev_zbozi,
	pf1.roky
;

SELECT
	nazev_zbozi,
	round(avg(procento)::NUMERIC, 2) AS procentualni_narust
FROM v_marie_belingerova_zdrazovani_potravin
GROUP BY
	nazev_zbozi
ORDER BY
	procentualni_narust
;

-- 4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
CREATE OR REPLACE VIEW v_marie_belingerova_rust_potravin AS 
SELECT
	pf1.roky AS rok,
	round(avg(pf1.ceny)::NUMERIC, 2) AS cena,
	pf2.roky AS nasledujici_rok,
	round(avg(pf2.ceny)::NUMERIC, 2) AS cena_nasledujiciho_roku,
	round(avg(pf2.ceny) - avg(pf1.ceny)::NUMERIC, 2) AS rozdil,
	round((avg(pf2.ceny) - avg(pf1.ceny)) * 100 / avg(pf1.ceny)::NUMERIC, 2) AS procento
FROM t_marie_belingerova_project_SQL_primary_final pf1
LEFT JOIN t_marie_belingerova_project_SQL_primary_final pf2 ON pf1.nazev_zbozi = pf2.nazev_zbozi  AND
	pf2.roky = pf1.roky + 1
GROUP BY
	pf1.roky,
	pf2.roky
ORDER BY
	pf1.roky
;

SELECT *
FROM v_marie_belingerova_rust_potravin;

CREATE OR REPLACE VIEW v_marie_belingerova_rust_mezd AS 
SELECT
	pf1.roky AS rok,
	round(avg(pf1.mzdy)::NUMERIC, 2) AS mzda,
	pf2.roky AS nasledujici_rok,
	round(avg(pf2.mzdy)::NUMERIC, 2) AS mzda_nasledujiciho_roku,
	round(avg(pf2.mzdy)::NUMERIC, 2) - round(avg(pf1.mzdy)::NUMERIC, 2) AS rozdil,
	round((avg(pf2.mzdy) - avg(pf1.mzdy)) * 100 / avg(pf1.mzdy)::NUMERIC, 2) AS procento
FROM t_marie_belingerova_project_SQL_primary_final pf1
LEFT JOIN t_marie_belingerova_project_SQL_primary_final pf2 ON pf1.odvetvi = pf2.odvetvi AND
	pf2.roky = pf1.roky + 1
GROUP BY
	pf1.roky,
	pf2.roky
ORDER BY
	pf1.roky
;

SELECT *
FROM v_marie_belingerova_rust_mezd;

SELECT
	p.rok,
	p.procento AS procento_cen,
	m.procento AS procento_mezd
FROM v_marie_belingerova_rust_potravin p
JOIN v_marie_belingerova_rust_mezd m ON p.rok = m.rok
ORDER BY
	p.rok;

-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP 
-- vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve 
-- stejném nebo následujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_marie_belingerova_pt AS
SELECT
	sf1.zeme,
	pf1.roky AS rok,
	round(avg(sf1.hdp)::NUMERIC, 2) AS hdp,
	round(avg(pf1.mzdy)::NUMERIC, 2) AS mzdy,
	round(avg(pf1.ceny)::NUMERIC, 2) AS ceny
FROM t_marie_belingerova_project_SQL_primary_final pf1
LEFT JOIN t_marie_belingerova_project_SQL_secondary_final sf1 ON pf1.roky = sf1.rok
WHERE sf1.zeme = 'Czech Republic'
GROUP BY
	sf1.zeme,
	pf1.roky
ORDER BY
	pf1.roky
;

SELECT *
FROM v_marie_belingerova_pt;

-- HDP (výrazný růst HDP je 3 - 4 %)
CREATE OR REPLACE VIEW v_marie_belingerova_hdp AS 
SELECT
	pt1.rok AS rok,
	pt1.hdp AS hdp,
	pt2.rok AS nasledujici_rok,
	pt2.hdp AS hdp_nasledujiciho_roku,
	pt2.hdp - pt1.hdp AS rozdil,
	round((pt2.hdp - pt1.hdp) * 100 / pt1.hdp::NUMERIC, 2) AS procento
FROM v_marie_belingerova_pt pt1
LEFT JOIN v_marie_belingerova_pt pt2 ON pt1.zeme = pt2.zeme AND
	pt2.rok = pt1.rok + 1
;

SELECT *
FROM v_marie_belingerova_hdp;

-- Mzdy (výrazný růst mezd je 7 - 8 % ročně)
CREATE OR REPLACE VIEW v_marie_belingerova_mzdy AS 
SELECT
	pt1.rok AS rok,
	pt1.mzdy AS mzdy,
	pt2.rok AS nasledujici_rok,
	pt2.mzdy AS mzdy_nasledujiciho_roku,
	pt2.mzdy - pt1.mzdy AS rozdil,
	round((pt2.mzdy - pt1.mzdy) * 100 / pt1.mzdy::NUMERIC, 2) AS procento
FROM v_marie_belingerova_pt pt1
LEFT JOIN v_marie_belingerova_pt pt2 ON pt1.zeme = pt2.zeme AND
	pt2.rok = pt1.rok + 1
;

SELECT *
FROM v_marie_belingerova_mzdy;

-- Ceny (výrazný růst cen je přes 10 %)
CREATE OR REPLACE VIEW v_marie_belingerova_ceny AS 
SELECT
	pt1.rok AS rok,
	pt1.ceny AS ceny,
	pt2.rok AS nasledujici_rok,
	pt2.ceny AS ceny_nasledujiciho_roku,
	pt2.ceny - pt1.ceny AS rozdil,
	round((pt2.ceny - pt1.ceny) * 100 / pt1.ceny::NUMERIC, 2) AS procento
FROM v_marie_belingerova_pt pt1
LEFT JOIN v_marie_belingerova_pt pt2 ON pt1.zeme = pt2.zeme AND
	pt2.rok = pt1.rok + 1
;

SELECT *
FROM v_marie_belingerova_ceny;

SELECT
	h.rok,
	h.procento AS procento_hdp,
	m.procento AS procento_mezd,
	c.procento AS procento_cen
FROM v_marie_belingerova_hdp h
JOIN v_marie_belingerova_mzdy m ON h.rok = m.rok
JOIN v_marie_belingerova_ceny c ON h.rok = c.rok
;
