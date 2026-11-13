-- 06_subqueries_habitable.sql
-- Subqueries: using the result of one query inside another.
-- Part 1: comparing planets to the average size, and average vs. median.
-- Part 2: subqueries that return a list (IN).
-- Part 3: potentially habitable planet candidates.
-- Part 4: CTEs (WITH) for multi-step questions.

-- What is the average planet radius? (Earth = 1)
-- Result: 5.85
SELECT ROUND(AVG(radius_earths), 2) AS avg_radius
FROM planets;

-- Which planets are larger than 5 Earth radii? (fixed number, no subquery yet)
SELECT planet_name, radius_earths
FROM planets
WHERE radius_earths > 5
ORDER BY radius_earths DESC
LIMIT 10;

-- This fails, because WHERE runs before AVG can be calculated:
-- WHERE radius_earths > AVG(radius_earths)
-- ERROR: aggregate functions are not allowed in WHERE

-- Which planets are larger than average?
-- The subquery in parentheses runs first and returns one number (the average).
-- Result: top planet is V2376 Ori b at about 87 Earth radii (nearly 8x Jupiter, an outlier)
SELECT planet_name, radius_earths
FROM planets
WHERE radius_earths > (SELECT AVG(radius_earths) FROM planets)
ORDER BY radius_earths DESC
LIMIT 10;

-- How many planets are larger than average?
-- Result: 2186 of 6414 planets with a radius (34%), well below half.
-- That means a smaller group of giant planets pulls the average up.
SELECT COUNT(*) AS above_average
FROM planets
WHERE radius_earths > (SELECT AVG(radius_earths) FROM planets);

-- Median vs. average planet radius
-- PERCENTILE_CONT(0.5) finds the middle value. CAST converts it so ROUND can use it.
-- Result: median 2.86, average 5.85. The average is about twice the median,
-- so the median better describes a typical planet.
SELECT
    ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY radius_earths) AS NUMERIC), 2) AS median_radius,
    ROUND(AVG(radius_earths), 2) AS avg_radius
FROM planets;


-- ============================================================
-- PART 2: SUBQUERIES THAT RETURN A LIST
-- ============================================================

-- Which stars have 6 or more planets?
SELECT star_name
FROM stars
WHERE num_planets >= 6;

-- Which planets orbit those stars?
-- The subquery returns a list of star names, so IN is used instead of =.
-- Two tables are needed: the planet count is in stars, the planet names are in planets.
SELECT planet_name, star_name
FROM planets
WHERE star_name IN (SELECT star_name FROM stars WHERE num_planets >= 6)
ORDER BY star_name, planet_name;


-- ============================================================
-- PART 3: POTENTIALLY HABITABLE PLANET CANDIDATES
-- ============================================================
-- Screening criteria (simplified, not proof of habitability):
--   Size: 0.5 to 1.6 Earth radii (larger planets tend to be gassy; smaller ones may not hold an atmosphere)
--   Temperature: 180 to 310 K (equilibrium temperature, which ignores any atmosphere)
-- Planets with no recorded temperature drop out automatically, so the count is a minimum.

-- Which planets meet both conditions?
-- Result: 36 candidates (about 0.6% of all planets). Coolest: GJ 1002 c at 181.7 K
SELECT planet_name, star_name, radius_earths, temperature_k
FROM planets
WHERE radius_earths BETWEEN 0.5 AND 1.6
  AND temperature_k BETWEEN 180 AND 310
ORDER BY temperature_k ASC;

-- Which candidate is closest to Earth?
-- JOIN on star_name, not temperature_k: the shared name means different things in each table.
-- Result: Proxima Cen b, 1.02 Earth radii, 218 K, 1.30 parsecs (4.2 light-years)
SELECT
    p.planet_name,
    s.star_name,
    p.radius_earths,
    p.temperature_k,
    s.distance_pc,
    ROUND(s.distance_pc * 3.26, 1) AS distance_ly
FROM planets AS p
JOIN stars AS s ON p.star_name = s.star_name
WHERE p.radius_earths BETWEEN 0.5 AND 1.6
  AND p.temperature_k BETWEEN 180 AND 310
ORDER BY s.distance_pc ASC, p.planet_name;

-- How was Proxima Cen b discovered?
-- Radial velocity measures mass, not size, so its radius is likely a calculated estimate.
SELECT planet_name, discovery_method
FROM planets
WHERE planet_name = 'Proxima Cen b';


-- ============================================================
-- PART 4: CTEs (WITH)
-- ============================================================
-- A CTE names the result of one query so the next query can use it like a table.

-- Which discovery methods found the habitable candidates?
-- Result: Transit 20 (55.6%), Radial Velocity 15 (41.7%), Transit Timing Variations 1.
-- Radial Velocity is 18.6% of all planets but 41.7% of candidates.
WITH candidates AS (
    SELECT planet_name, discovery_method
    FROM planets
    WHERE radius_earths BETWEEN 0.5 AND 1.6
      AND temperature_k BETWEEN 180 AND 310
)
SELECT discovery_method, COUNT(*) AS num_candidates
FROM candidates
GROUP BY discovery_method
ORDER BY num_candidates DESC;

-- Which discovery methods found the giant planets (over 10 Earth radii)?
-- Result: 1,863 giants. Transit 774 (41.5%), Radial Velocity 764 (41.0%),
-- Microlensing 188 (10.1%), Imaging 94 (5.0%), others under 1% each.
WITH giants AS (
    SELECT planet_name, discovery_method
    FROM planets
    WHERE radius_earths > 10
)
SELECT discovery_method, COUNT(*) AS num_giants
FROM giants
GROUP BY discovery_method
ORDER BY num_giants DESC;
