-- 05_analysis.sql
-- Aggregation: summarizing planets by discovery method, year, and facility.
--
-- Order SQL runs in (not the order it's written):
--   1. FROM  2. WHERE  3. GROUP BY  4. HAVING  5. SELECT  6. ORDER BY  7. LIMIT
-- This is why WHERE can't use COUNT or SELECT aliases, but ORDER BY can.

-- Which discovery method found the most planets?
SELECT
    discovery_method,
    COUNT(*) AS planets
FROM planets
GROUP BY discovery_method
ORDER BY planets DESC;

-- Same question, with each method's share of the total.
-- 100.0 (not 100) avoids integer division, which would drop the decimals and return 0.
-- Result (top 3): Transit 4797 (74.2%), Radial Velocity 1205 (18.6%), Microlensing 292 (4.5%)
SELECT
    discovery_method,
    COUNT(*) AS planets,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM planets), 1) AS pct_of_total
FROM planets
GROUP BY discovery_method
ORDER BY planets DESC;

-- How many planets were discovered (confirmed) each year?
SELECT
    discovery_year,
    COUNT(*) AS planets
FROM planets
GROUP BY discovery_year
ORDER BY discovery_year;

-- Do different methods find different sizes of planets?
-- with_radius shows how many planets each average is based on, since AVG skips NULLs.
SELECT
    discovery_method,
    COUNT(*)                        AS planets,
    COUNT(radius_earths)            AS with_radius,
    ROUND(AVG(radius_earths), 2)    AS avg_radius_earths
FROM planets
GROUP BY discovery_method
ORDER BY planets DESC;

-- Which facilities have found 50 or more planets since 2020?
-- WHERE filters rows before grouping. HAVING filters groups after grouping.
-- Result: TESS 989, Kepler 458, Multiple Observatories 223, K2 145,
--         KMTNet 136, La Silla Observatory 75, OGLE 53
-- Note: Kepler shut down in 2018. Its planets here were confirmed later from its stored data.
SELECT
    discovery_facility,
    COUNT(*) AS planets
FROM planets
WHERE discovery_year >= 2020
GROUP BY discovery_facility
HAVING COUNT(*) >= 50
ORDER BY planets DESC;

-- This version fails, because WHERE runs before COUNT exists:
-- WHERE discovery_year >= 2020 AND COUNT(*) >= 50
-- ERROR: aggregate functions are not allowed in WHERE
