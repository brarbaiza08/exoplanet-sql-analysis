# Exoplanet analysis with SQL

A PostgreSQL project analyzing NASA data on 6,464 confirmed planets outside our solar system. I loaded the raw data, designed a two-table database, and used SQL to answer questions about how planets are found, what a typical planet looks like, and which ones might be habitable.

## Questions

1. Which methods have discovered the most planets, and why?
2. What does a typical exoplanet look like?
3. Which planets might be able to support liquid water, and how close is the nearest one?
4. Do different discovery methods find different kinds of planets?

## Data

**Source:** [NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/), Planetary Systems Composite Parameters table (`pscomppars`), downloaded November 2026.

The composite table has one row per confirmed planet. It combines measurements from many studies, and where a value wasn't measured directly, NASA sometimes fills it in with a calculated estimate.

I downloaded 14 of the table's columns: planet name, host star, discovery method, year and facility, orbit length, radius, mass, temperature, and the host star's temperature, radius, mass, distance and planet count.

## Tools

- PostgreSQL
- pgAdmin 4

## Database design

The raw CSV repeats each star's details once for every planet it has. A star with 7 planets has its temperature, size and distance stored 7 times. I normalized the data into two tables so each fact is stored once:

| Table | Rows | Contents |
|---|---|---|
| `stars` | 4,857 | One row per star: temperature, radius, mass, distance, number of planets |
| `planets` | 6,464 | One row per planet: discovery details, orbit, radius, mass, temperature |

`planets.star_name` is a foreign key to `stars.star_name`, so every planet must belong to a star that exists in the database.

The original data stays in a staging table, `exoplanets_raw`, so the clean tables can be rebuilt at any time.

## Data decisions and limitations

**Conflicting star values.** 4,857 unique stars appeared in 5,082 different versions, because different studies reported slightly different values for the same star. For each star, I averaged temperature, radius, mass and distance, and kept the highest reported planet count as the most likely current one.

**Missing values.** Not every planet has every measurement:

| Measurement | Planets with a value | Missing |
|---|---|---|
| Radius | 6,414 | 50 |
| Mass | 6,433 | 31 |
| Temperature | 5,924 | 540 |

Averages and filters only include planets with a recorded value.

**Estimated values.** The radial velocity method measures a planet's mass, not its size. For planets found this way, the radius is likely an estimate calculated from mass.

**Equilibrium temperature.** The temperature column is a planet's equilibrium temperature, which ignores any atmosphere. Earth's equilibrium temperature is about 255 K, while its actual average surface temperature is about 288 K.

## Findings

### 1. Transit is the most common discovery method by far.
Transit accounts for 4,797 of 6,464 confirmed planets (74.2%). It detects planets by measuring tiny drops in a star's brightness when a planet passes between the star and Earth. It leads because the two most productive telescopes, Kepler and TESS, both use this method and can watch thousands of stars at once.

### 2. Kepler is still producing discoveries years after it shut down.
The Kepler telescope stopped operating in 2018, but 458 planets credited to it were confirmed in 2020 or later. Scientists are still analyzing the data Kepler collected and confirming new planets from it. This means "discovery year" in this dataset is the year a planet was confirmed, not the year it was observed.

### 3. The dataset reflects what's easy to detect, not what's most common.
Transit works best for large planets orbiting close to their stars, and only when the orbit lines up with our view from Earth. Because 74% of planets were found this way, the dataset over-represents those kinds of planets. Any conclusion about what planets are "typically" like has to account for this bias.

### 4. Most exoplanets are smaller than the average suggests.
The median planet is 2.86 times Earth's size, but the average is 5.85. Only 2,186 of 6,414 planets (34%) are larger than average, because a smaller group of larger planets pulls the average up. To describe a typical exoplanet, the median radius is the better number.

### 5. Potentially habitable planets are rare, and radial velocity finds an outsized share of them.
I screened for planets between 0.5 and 1.6 Earth radii with temperatures between 180 and 310 K. Only 36 of 6,464 planets (about 0.6%) qualify. The closest is Proxima Cen b, about 4.2 light-years away. Radial velocity found 18.6% of all planets but 41.7% of these candidates (15 of 36), likely because many orbit small, cool stars where a planet's pull on its star is easier to detect.

This count is a minimum, since 540 planets have no recorded temperature. The screen is also simplified and doesn't confirm a planet can hold water. And the radii for the 15 radial velocity candidates are likely estimates, not measurements.

## Files

| File | Purpose |
|---|---|
| `01_create_raw_table.sql` | Creates the staging table matching the CSV |
| `02_check_import.sql` | Confirms the import and measures missing data |
| `03_create_stars.sql` | Checks for conflicting star values and builds the `stars` table |
| `04_create_planets_and_join.sql` | Builds the `planets` table with a foreign key and tests the join |
| `05_analysis.sql` | Aggregations by discovery method, year and facility |
| `06_subqueries_habitable.sql` | Subqueries, median vs. average, habitable candidates, CTEs |
| `column_reference.txt` | Column names and meanings for each table |

## How to run it

1. Download the CSV using the URL at the top of `01_create_raw_table.sql`.
2. Create a PostgreSQL database called `space_project`.
3. Run `01_create_raw_table.sql`.
4. Import the CSV into `exoplanets_raw` (csv format, header on).
5. Run files `02` through `06` in order.

## SQL skills used

- Table design with data types, primary keys and foreign keys
- Data loading and validation
- Aggregate functions: `COUNT`, `AVG`, `MAX`, `ROUND`, `PERCENTILE_CONT`
- `GROUP BY` and `HAVING`
- `JOIN` with table aliases
- Subqueries returning one value or a list (`IN`)
- Common table expressions (`WITH`)
