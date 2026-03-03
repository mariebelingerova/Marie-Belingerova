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
	p.nasledujici_rok,
	p.procento AS procento_cen,
	m.procento AS procento_mezd
FROM v_marie_belingerova_rust_potravin p
JOIN v_marie_belingerova_rust_mezd m ON p.rok = m.rok
WHERE p.nasledujici_rok IS NOT null
ORDER BY
	p.rok;