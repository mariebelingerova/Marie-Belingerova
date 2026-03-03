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
	nazev_zbozi
;
