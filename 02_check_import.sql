-- 02_check_import.sql
-- Checks that the CSV import worked and measures missing data.

-- Did every row load? Expected: 6464 (row count of the CSV minus the header)
SELECT COUNT(*) FROM exoplanets_raw;

-- Look at a sample of rows
SELECT pl_name, hostname, discoverymethod, disc_year, pl_rade
FROM exoplanets_raw
LIMIT 10;

-- How complete are the planet measurements?
-- COUNT(*) counts all rows. COUNT(column) counts only rows where that column is not NULL.
-- Result: 6464 total, 6414 with radius, 6433 with mass, 5924 with temperature
SELECT
    COUNT(*)          AS total_planets,
    COUNT(pl_rade)    AS have_radius,
    COUNT(pl_bmasse)  AS have_mass,
    COUNT(pl_eqt)     AS have_temperature
FROM exoplanets_raw;

-- The 10 closest planets to Earth
SELECT pl_name, hostname, sy_dist
FROM exoplanets_raw
WHERE sy_dist IS NOT NULL
ORDER BY sy_dist, pl_name
LIMIT 10;
