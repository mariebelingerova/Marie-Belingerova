-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP 
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
	h.nasledujici_rok,
	h.procento AS procento_hdp,
	m.procento AS procento_mezd,
	c.procento AS procento_cen
FROM v_marie_belingerova_hdp h
JOIN v_marie_belingerova_mzdy m ON h.rok = m.rok
JOIN v_marie_belingerova_ceny c ON h.rok = c.rok
WHERE h.nasledujici_rok IS NOT null

;
