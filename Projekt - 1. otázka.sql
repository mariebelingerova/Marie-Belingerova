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