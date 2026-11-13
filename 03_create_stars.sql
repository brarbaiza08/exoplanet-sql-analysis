-- 03_create_stars.sql
-- Builds the stars table: one row per star, with star details stored once.

-- Check before building: are star details consistent across a star's planets?
-- Query A: number of unique star names. Result: 4857
SELECT COUNT(DISTINCT hostname) AS unique_stars
FROM exoplanets_raw;

-- Query B: number of unique star name + detail combinations. Result: 5082
-- B > A means some stars have conflicting values from different studies.
SELECT COUNT(*) AS unique_star_versions
FROM (
    SELECT DISTINCT hostname, st_teff, st_rad, st_mass, sy_dist, sy_pnum
    FROM exoplanets_raw
) AS star_versions;

-- Which stars have conflicting values?
SELECT hostname, COUNT(*) AS versions
FROM (
    SELECT DISTINCT hostname, st_teff, st_rad, st_mass, sy_dist, sy_pnum
    FROM exoplanets_raw
) AS star_versions
GROUP BY hostname
HAVING COUNT(*) > 1
ORDER BY versions DESC;

-- Decision for conflicting values:
--   temperature, radius, mass, distance: average of the reported values
--   number of planets: highest reported value (most likely the current count)

CREATE TABLE stars (
    star_name      TEXT PRIMARY KEY,
    temperature_k  NUMERIC,
    radius_suns    NUMERIC,
    mass_suns      NUMERIC,
    distance_pc    NUMERIC,
    num_planets    INTEGER
);

-- One row per star. Column order in SELECT must match the INSERT column list.
INSERT INTO stars (star_name, temperature_k, radius_suns, mass_suns, distance_pc, num_planets)
SELECT
    hostname,
    ROUND(AVG(st_teff), 1),
    ROUND(AVG(st_rad), 3),
    ROUND(AVG(st_mass), 3),
    ROUND(AVG(sy_dist), 4),
    MAX(sy_pnum)
FROM exoplanets_raw
GROUP BY hostname;

-- Check: expected 4857, matching Query A
SELECT COUNT(*) FROM stars;

-- Stars with the most planets
SELECT * FROM stars
ORDER BY num_planets DESC, star_name
LIMIT 10;
