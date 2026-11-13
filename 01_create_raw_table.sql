-- 01_create_raw_table.sql
-- Creates the staging table for the NASA Exoplanet Archive data.
-- Source: NASA Exoplanet Archive, Planetary Systems Composite Parameters table (pscomppars)
-- Download URL (14 columns, CSV):
-- https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,hostname,discoverymethod,disc_year,disc_facility,pl_orbper,pl_rade,pl_bmasse,pl_eqt,sy_pnum,st_teff,st_rad,st_mass,sy_dist+from+pscomppars&format=csv
--
-- This table matches the CSV column for column, in the same order.
-- No cleaning happens here. Clean tables are built from it in 03 and 04.

CREATE TABLE exoplanets_raw (
    pl_name          TEXT,      -- planet name
    hostname         TEXT,      -- star the planet orbits
    discoverymethod  TEXT,      -- e.g. Transit, Radial Velocity
    disc_year        INTEGER,   -- year the planet was confirmed
    disc_facility    TEXT,      -- telescope or observatory credited
    pl_orbper        NUMERIC,   -- orbit length in days
    pl_rade          NUMERIC,   -- planet radius (Earth = 1)
    pl_bmasse        NUMERIC,   -- planet mass (Earth = 1)
    pl_eqt           NUMERIC,   -- equilibrium temperature in Kelvin
    sy_pnum          INTEGER,   -- number of planets in the system
    st_teff          NUMERIC,   -- star temperature in Kelvin
    st_rad           NUMERIC,   -- star radius (Sun = 1)
    st_mass          NUMERIC,   -- star mass (Sun = 1)
    sy_dist          NUMERIC    -- distance from Earth in parsecs
);

-- After running this, import exoplanets.csv in pgAdmin:
-- Right-click exoplanets_raw > Import/Export Data
--   General: Import, Format csv, Encoding UTF8
--   Options: Header ON, Delimiter ",", Quote '"'
