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

SELECT *
FROM v_marie_belingerova_zdrazovani_potravin;

SELECT
	nazev_zbozi,
	round(avg(procento)::NUMERIC, 2) AS procentualni_narust
FROM v_marie_belingerova_zdrazovani_potravin
GROUP BY
	nazev_zbozi
ORDER BY
	procentualni_narust
;