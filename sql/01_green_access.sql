-- ============================================================
-- Munich Green Access Analysis
-- Spatial accessibility of parks to schools in Munich
--
-- Database: PostgreSQL / PostGIS
-- CRS: ETRS89 / UTM Zone 32N (EPSG:25832)
-- ============================================================


-- ============================================================
-- 01. DATA VALIDATION
-- ============================================================

-- Check the number of school records.
SELECT
    COUNT(*) AS total_school_records
FROM schools;


-- Check the number of park records.
SELECT
    COUNT(*) AS total_park_records
FROM parks;


-- Check school geometry and CRS.
SELECT
    ST_SRID(geometry) AS srid,
    GeometryType(geometry) AS geometry_type
FROM schools
LIMIT 1;


-- Check park geometry and CRS.
SELECT
    ST_SRID(geometry) AS srid,
    GeometryType(geometry) AS geometry_type
FROM parks
LIMIT 1;


-- ============================================================
-- 02. PROJECT DATA TO EPSG:25832
-- ============================================================

-- Project school geometries to ETRS89 / UTM Zone 32N.
-- This allows distance calculations in metres.

CREATE OR REPLACE VIEW schools_utm AS
SELECT
    *,
    ST_Transform(geometry, 25832) AS geom_utm
FROM schools;


-- Project park geometries to EPSG:25832.

CREATE OR REPLACE VIEW parks_utm AS
SELECT
    *,
    ST_Transform(geometry, 25832) AS geom_utm
FROM parks;


-- Validate projected geometries.

SELECT
    COUNT(*) AS total_schools,
    COUNT(geom_utm) AS schools_with_geometry
FROM schools_utm;


SELECT
    COUNT(*) AS total_parks,
    COUNT(geom_utm) AS parks_with_geometry
FROM parks_utm;


-- ============================================================
-- 03. SCHOOL DATA QUALITY AND UNIQUE IDs
-- ============================================================

-- Check whether school names are duplicated.

SELECT
    "Name" AS school_name,
    COUNT(*) AS number_of_records
FROM schools_utm
GROUP BY "Name"
HAVING COUNT(*) > 1
ORDER BY number_of_records DESC, school_name;


-- Count records beyond the first occurrence
-- for duplicated school names.

SELECT
    COALESCE(SUM(number_of_records - 1), 0) AS duplicate_records
FROM (
    SELECT
        "Name",
        COUNT(*) AS number_of_records
    FROM schools_utm
    GROUP BY "Name"
    HAVING COUNT(*) > 1
) AS duplicates;


-- Create a unique identifier for each school record.

CREATE OR REPLACE VIEW schools_utm_id AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            "Name",
            "Adresse"
    ) AS school_id,
    s.*
FROM schools_utm s;


-- Validate school IDs.

SELECT
    COUNT(*) AS total_schools,
    COUNT(DISTINCT school_id) AS unique_school_ids
FROM schools_utm_id;


-- ============================================================
-- 04. NEAREST PARK ANALYSIS
-- ============================================================

-- Calculate the straight-line distance from each school
-- to its nearest park.

CREATE OR REPLACE VIEW school_nearest_park AS
SELECT
    s.school_id,
    s."Name" AS school_name,
    s."Adresse" AS address,
    s.geom_utm,
    MIN(
        ST_Distance(
            s.geom_utm,
            p.geom_utm
        )
    ) AS nearest_park_distance_m
FROM schools_utm_id s
CROSS JOIN parks_utm p
GROUP BY
    s.school_id,
    s."Name",
    s."Adresse",
    s.geom_utm;


-- Check the number of analysed schools.

SELECT
    COUNT(*) AS analyzed_schools
FROM school_nearest_park;


-- ============================================================
-- 05. OVERALL DISTANCE STATISTICS
-- ============================================================

SELECT
    COUNT(*) AS total_schools,
    ROUND(AVG(nearest_park_distance_m)::numeric, 1)
        AS average_distance_m,
    ROUND(MIN(nearest_park_distance_m)::numeric, 1)
        AS minimum_distance_m,
    ROUND(MAX(nearest_park_distance_m)::numeric, 1)
        AS maximum_distance_m
FROM school_nearest_park;


-- ============================================================
-- 06. SCHOOL GREEN ACCESS CLASSIFICATION
-- ============================================================

-- Classify schools according to their distance
-- to the nearest park.

CREATE OR REPLACE VIEW school_green_access AS
SELECT
    school_id,
    school_name,
    address,
    geom_utm,
    nearest_park_distance_m,
    CASE
        WHEN nearest_park_distance_m <= 250
            THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500
            THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000
            THEN '500-1000 m'
        ELSE '>1000 m'
    END AS access_category
FROM school_nearest_park;


-- ============================================================
-- 07. SCHOOL ACCESS STATISTICS
-- ============================================================

-- Count schools in each access category.

SELECT
    access_category,
    COUNT(*) AS number_of_schools
FROM school_green_access
GROUP BY access_category
ORDER BY
    CASE access_category
        WHEN '0-250 m' THEN 1
        WHEN '250-500 m' THEN 2
        WHEN '500-1000 m' THEN 3
        WHEN '>1000 m' THEN 4
    END;


-- Calculate the percentage of schools
-- in each access category.

SELECT
    access_category,
    COUNT(*) AS number_of_schools,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        1
    ) AS percentage
FROM school_green_access
GROUP BY access_category
ORDER BY
    CASE access_category
        WHEN '0-250 m' THEN 1
        WHEN '250-500 m' THEN 2
        WHEN '500-1000 m' THEN 3
        WHEN '>1000 m' THEN 4
    END;


-- ============================================================
-- 08. SCHOOLS WITH THE POOREST ACCESS
-- ============================================================

-- Identify the 20 schools with the greatest
-- nearest-park distance.

SELECT
    school_id,
    school_name,
    address,
    ROUND(
        nearest_park_distance_m::numeric,
        1
    ) AS nearest_park_distance_m
FROM school_green_access
ORDER BY nearest_park_distance_m DESC
LIMIT 20;


-- ============================================================
-- 09. MUNICIPAL DISTRICT DATA
-- ============================================================

-- Check the number of Munich administrative districts.

SELECT
    COUNT(*) AS number_of_districts
FROM "Bezirke_München";


-- Check district geometry and CRS.

SELECT
    ST_SRID(geom) AS srid,
    GeometryType(geom) AS geometry_type
FROM "Bezirke_München"
LIMIT 5;


-- Inspect district attributes.

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'Bezirke_München'
ORDER BY ordinal_position;


-- ============================================================
-- 10. SCHOOL–DISTRICT SPATIAL JOIN
-- ============================================================

-- Assign each school to the Munich administrative
-- district containing its location.

CREATE OR REPLACE VIEW school_district_access AS
SELECT
    s.school_id,
    s.school_name,
    s.address,
    s.nearest_park_distance_m,
    s.access_category,
    d.sb_nummer AS district_number,
    d.name AS district_name,
    s.geom_utm
FROM school_green_access s
JOIN "Bezirke_München" d
    ON ST_Within(
        s.geom_utm,
        d.geom
    );


-- Validate the spatial join.

SELECT
    COUNT(*) AS total_schools,
    COUNT(DISTINCT school_id) AS unique_schools
FROM school_district_access;


-- ============================================================
-- 11. DISTRICT-LEVEL GREEN ACCESS ANALYSIS
-- ============================================================

-- Count schools and poor-access schools by district.

SELECT
    district_number,
    district_name,
    COUNT(*) AS total_schools,
    COUNT(*) FILTER (
        WHERE nearest_park_distance_m > 1000
    ) AS poor_access_schools
FROM school_district_access
GROUP BY
    district_number,
    district_name
ORDER BY
    poor_access_schools DESC;


-- Calculate the percentage of poor-access schools
-- in each district.

SELECT
    district_number,
    district_name,
    COUNT(*) AS total_schools,
    COUNT(*) FILTER (
        WHERE nearest_park_distance_m > 1000
    ) AS poor_access_schools,
    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE nearest_park_distance_m > 1000
        )
        / NULLIF(COUNT(*), 0),
        1
    ) AS poor_access_percentage
FROM school_district_access
GROUP BY
    district_number,
    district_name
ORDER BY
    poor_access_percentage DESC;


-- ============================================================
-- 12. DISTRICT RANKING
-- ============================================================

-- Rank districts by the percentage of schools
-- with poor green-space access.
-- Districts with fewer than five schools are excluded.

SELECT
    district_number,
    district_name,
    total_schools,
    poor_access_schools,
    poor_access_percentage
FROM (
    SELECT
        district_number,
        district_name,
        COUNT(*) AS total_schools,
        COUNT(*) FILTER (
            WHERE nearest_park_distance_m > 1000
        ) AS poor_access_schools,
        ROUND(
            100.0 *
            COUNT(*) FILTER (
                WHERE nearest_park_distance_m > 1000
            )
            / NULLIF(COUNT(*), 0),
            1
        ) AS poor_access_percentage
    FROM school_district_access
    GROUP BY
        district_number,
        district_name
) AS district_stats
WHERE total_schools >= 5
ORDER BY
    poor_access_percentage DESC,
    poor_access_schools DESC;


-- ============================================================
-- 13. FINAL DISTRICT ANALYSIS VIEW
-- ============================================================

-- Create the final district-level analytical output.

CREATE OR REPLACE VIEW district_green_access AS
SELECT
    d.id,
    d.sb_nummer AS district_number,
    d.name AS district_name,
    d.geom,
    COUNT(s.school_id) AS total_schools,
    COUNT(s.school_id) FILTER (
        WHERE s.nearest_park_distance_m > 1000
    ) AS poor_access_schools,
    ROUND(
        100.0 *
        COUNT(s.school_id) FILTER (
            WHERE s.nearest_park_distance_m > 1000
        )
        / NULLIF(COUNT(s.school_id), 0),
        1
    ) AS poor_access_percentage
FROM "Bezirke_München" d
LEFT JOIN school_green_access s
    ON ST_Within(
        s.geom_utm,
        d.geom
    )
GROUP BY
    d.id,
    d.sb_nummer,
    d.name,
    d.geom;


-- ============================================================
-- 14. FINAL VALIDATION
-- ============================================================

-- Overall number of schools and poor-access schools.

SELECT
    SUM(total_schools) AS total_schools,
    SUM(poor_access_schools) AS total_poor_access_schools
FROM district_green_access;


-- Overall percentage of schools with poor access.

SELECT
    ROUND(
        100.0 *
        SUM(poor_access_schools)
        / NULLIF(SUM(total_schools), 0),
        1
    ) AS overall_poor_access_percentage
FROM district_green_access;


-- ============================================================
-- FINAL ANALYTICAL OUTPUTS
--
-- school_nearest_park
-- school_green_access
-- school_district_access
-- district_green_access
 HEAD
-- ============================================================

-- ============================================================
 4afee350918ff4e9695165efc394b55166ff9f50
