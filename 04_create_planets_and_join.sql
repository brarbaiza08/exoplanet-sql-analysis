-- 04_create_planets_and_join.sql
-- Builds the planets table, links it to stars with a foreign key,
-- and joins the two tables back together.

-- stars must exist before this runs, because planets references it.
CREATE TABLE planets (
    planet_name         TEXT PRIMARY KEY,
    star_name           TEXT NOT NULL REFERENCES stars (star_name),
    discovery_method    TEXT,
    discovery_year      INTEGER,
    discovery_facility  TEXT,
    orbit_days          NUMERIC,
    radius_earths       NUMERIC,
    mass_earths         NUMERIC,
    temperature_k       NUMERIC
);

-- The raw table already has one row per planet, so no GROUP BY is needed.
INSERT INTO planets (planet_name, star_name, discovery_method, discovery_year,
                     discovery_facility, orbit_days, radius_earths, mass_earths, temperature_k)
SELECT pl_name, hostname, discoverymethod, disc_year,
       disc_facility, pl_orbper, pl_rade, pl_bmasse, pl_eqt
FROM exoplanets_raw;

-- Check: expected 6464
SELECT COUNT(*) FROM planets;

-- Foreign key test (commented out so it doesn't run).
-- This fails because 'Fake Star' is not in the stars table:
-- INSERT INTO planets (planet_name, star_name) VALUES ('Test b', 'Fake Star');

-- The 10 closest planets to Earth, with details from both tables.
-- planet_name is a tie-breaker, since planets of the same star share a distance.
SELECT
    p.planet_name,
    p.discovery_year,
    s.star_name,
    s.temperature_k AS star_temp_k,
    s.distance_pc
FROM planets AS p
JOIN stars AS s
    ON p.star_name = s.star_name
WHERE s.distance_pc IS NOT NULL
ORDER BY s.distance_pc, p.planet_name
LIMIT 10;

-- Join check: expected 6464. Lower means planets were dropped; higher means duplicates.
SELECT COUNT(*)
FROM planets AS p
JOIN stars AS s ON p.star_name = s.star_name;
