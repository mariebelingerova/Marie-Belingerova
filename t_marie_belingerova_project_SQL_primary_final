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
