
-- test.. the number of schools 

SELECT COUNT(*) FROM schools;

SELECT *
FROM schools
LIMIT 5;

-- Finding schools utm and schools within 500 meters of parks.
SELECT ST_SRID(geometry)
FROM schools
LIMIT 1;

schools_utm
ST_DWithin (...,500)

CREATE VIEW schools_utm AS
SELECT
    *,
    ST_Transform(geometry, 25832) AS geom_utm
FROM schools;


---- Finding counts of parks and crs of parks.

SELECT COUNT(*)
FROM parks;

SELECT ST_SRID(geometry)
FROM parks
LIMIT 1;


parks_utm
ST_DWithin (...,500

CREATE VIEW parks_utm AS
SELECT
    *,
    ST_Transform(geometry, 25832) AS geom_utm
FROM parks;





--For each school, it checks:

--Is there at least one park within a 500-meter radius?

--If so, it counts that school.

SELECT COUNT(DISTINCT s."Name")
FROM schools_utm s
JOIN parks_utm p
ON ST_DWithin(
    s.geom_utm,
    p.geom_utm,
    500
);

--We only want to see the names of the schools.
SELECT DISTINCT s."Name"
FROM schools_utm s
JOIN parks_utm p
ON ST_DWithin(
    s.geom_utm,
    p.geom_utm,
    500
)
LIMIT 20;


--- We want to count the number of parks near each school.

SELECT
    s."Name",
    COUNT(p.*) AS nearby_parks
FROM schools_utm s
LEFT JOIN parks_utm p
ON ST_DWithin(
    s.geom_utm,
    p.geom_utm,
    500
)
GROUP BY s."Name"
ORDER BY nearby_parks DESC;


---How far is each school from the nearest park?

SELECT
    s."Name",
    MIN(
        ST_Distance(
            s.geom_utm,
            p.geom_utm
        )
    ) AS distance_m
FROM schools_utm s
CROSS JOIN parks_utm p
GROUP BY s."Name"
ORDER BY distance_m;



---How many meters is the nearest park to this school?
SELECT
    s."Name" AS school_name,
    MIN(
        ST_Distance(
            s.geom_utm,
            p.geom_utm
        )
    ) AS nearest_park_distance_m
FROM schools_utm s
CROSS JOIN parks_utm p
GROUP BY s."Name"
ORDER BY nearest_park_distance_m;


---We want to find out what the situation is like for all 464 schools in Munich.
SELECT
    COUNT(*) AS total_schools,
    ROUND(AVG(nearest_park_distance_m)::numeric, 1) AS average_distance_m,
    ROUND(MIN(nearest_park_distance_m)::numeric, 1) AS minimum_distance_m,
    ROUND(MAX(nearest_park_distance_m)::numeric, 1) AS maximum_distance_m
FROM (
    SELECT
        s."Name" AS school_name,
        MIN(
		
----Now we want to find out:

---Of these 433 schools:

--How many schools are within 250 meters of the park?

--How many schools are between 250 and 500 meters?

--How many schools are between 500 and 1000 meters?

---How many schools are more than 1 kilometer away?

SELECT
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END AS access_category,
    COUNT(*) AS number_of_schools
FROM (
    SELECT
        s."Name" AS school_name,
        MIN(
            ST_Distance(
                s.geom_utm,
                p.geom_utm
            )
        ) AS nearest_park_distance_m
    FROM schools_utm s
    CROSS JOIN parks_utm p
    GROUP BY s."Name"
) AS school_distances
GROUP BY
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END
ORDER BY
    MIN(nearest_park_distance_m);


---Which 31 schools are not in the results and why?

SELECT
    s."Name" AS school_name
FROM schools_utm s
LEFT JOIN (
    SELECT DISTINCT
        s2."Name" AS school_name
    FROM schools_utm s2
    CROSS JOIN parks_utm p
) AS analyzed
ON s."Name" = analyzed.school_name
WHERE analyzed.school_name IS NULL;


---Finding 31 schools that have no parks
SELECT
    s."Name" AS school_name
FROM schools_utm s
WHERE NOT EXISTS (
    SELECT 1
    FROM parks_utm p
    WHERE ST_DWithin(
        s.geom_utm,
        p.geom_utm,
        100000
    )
);	


---- test
SELECT
    COUNT(*) AS total_schools,
    COUNT(geom_utm) AS schools_with_geometry
FROM schools_utm;


SELECT
    COUNT(*) AS total_parks,
    COUNT(geom_utm) AS parks_with_geometry
FROM parks_utm;

SELECT
    COUNT(*) AS total_school_records,
    COUNT(DISTINCT "Name") AS unique_school_names
FROM schools_utm;


SELECT
    COUNT(*) AS total_school_records,
    COUNT(DISTINCT "Name") AS unique_school_names
FROM schools_utm;

SELECT
    "Name" AS school_name,
    COUNT(*) AS number_of_records
	

---Finding duplicate names
SELECT
    "Name" AS school_name,
    COUNT(*) AS number_of_records
FROM schools_utm
GROUP BY "Name"
HAVING COUNT(*) > 1
ORDER BY number_of_records DESC, school_name;

---Finding the actual number of duplicate records

SELECT
    SUM(number_of_records - 1) AS duplicate_records
FROM (
    SELECT
        "Name",
        COUNT(*) AS number_of_records
    FROM schools_utm
    GROUP BY "Name"
    HAVING COUNT(*) > 1
) AS duplicates;


---Creating a unique ID for each school

CREATE OR REPLACE VIEW schools_utm_id AS
SELECT
    ROW_NUMBER() OVER () AS school_id,
    s.*
FROM schools_utm s;


SELECT
    COUNT(*) AS total_schools,
    COUNT(DISTINCT school_id) AS unique_school_ids
FROM schools_utm_id;

---Nearest Park calculation for each of the 464 schools

SELECT
    s.school_id,
    s."Name" AS school_name,
    s."Adresse" AS address,
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
    s."Adresse"
ORDER BY nearest_park_distance_m;

-- Calculating the closest park to each school

SELECT
    s.school_id,
    s."Name" AS school_name,
    s."Adresse" AS address,
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
    s."Adresse"
ORDER BY
    nearest_park_distance_m;

---Let's see if we really have 464 results.
SELECT
    COUNT(*) AS analyzed_schools
FROM (
    SELECT
        s.school_id,
        MIN(
            ST_Distance(
                s.geom_utm,
                p.geom_utm
            )
        ) AS nearest_park_distance_m
    FROM schools_utm_id s
    CROSS JOIN parks_utm p
    GROUP BY s.school_id
) AS results;



--Overall statistics of 464 schools

SELECT
    COUNT(*) AS total_schools,
    ROUND(AVG(nearest_park_distance_m)::numeric, 1) AS average_distance_m,
    ROUND(MIN(nearest_park_distance_m)::numeric, 1) AS minimum_distance_m,
    ROUND(MAX(nearest_park_distance_m)::numeric, 1) AS maximum_distance_m
FROM (
    SELECT
        s.school_id,
        MIN(
            ST_Distance(
                s.geom_utm,
                p.geom_utm
            )
        ) AS nearest_park_distance_m
    FROM schools_utm_id s
    CROSS JOIN parks_utm p
    GROUP BY s.school_id
) AS results;

--Finding schools with the worst access

SELECT
    s.school_id,
    s."Name" AS school_name,
    s."Adresse" AS address,
    ROUND(
        MIN(ST_Distance(s.geom_utm, p.geom_utm))::numeric,
        1
    ) AS nearest_park_distance_m
FROM schools_utm_id s
CROSS JOIN parks_utm p
GROUP BY
    s.school_id,
    s."Name",
    s."Adresse"
ORDER BY
    nearest_park_distance_m DESC
LIMIT 20;

--Stare at the result as a View

CREATE OR REPLACE VIEW school_nearest_park AS
SELECT
    s.school_id,
    s."Name" AS school_name,
    s."Adresse" AS address,
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
    s."Adresse";


--How many schools are in each access area?

SELECT
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END AS access_category,
    COUNT(*) AS number_of_schools
FROM school_nearest_park
GROUP BY
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END
ORDER BY
    MIN(nearest_park_distance_m);



--Percentage of each group

SELECT
    access_category,
    number_of_schools,
    ROUND(
        100.0 * number_of_schools
        / SUM(number_of_schools) OVER (),
        1
    ) AS percentage
FROM (
    SELECT
        CASE
            WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
            WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
            WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
            ELSE '>1000 m'
        END AS access_category,
        COUNT(*) AS number_of_schools
    FROM school_nearest_park
    GROUP BY
        CASE
            WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
            WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
            WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
            ELSE '>1000 m'
        END
) AS categories
ORDER BY
    CASE access_category
        WHEN '0-250 m' THEN 1
        WHEN '250-500 m' THEN 2
        WHEN '500-1000 m' THEN 3
        WHEN '>1000 m' THEN 4
    END;	


-- Finding the 20 schools with the worst access

SELECT
    school_id,
    school_name,
    address,
    ROUND(nearest_park_distance_m::numeric, 1)
        AS nearest_park_distance_m
FROM school_nearest_park
ORDER BY nearest_park_distance_m DESC
LIMIT 20;

-- Creating the final view with Access Category


CREATE OR REPLACE VIEW school_green_access AS
SELECT
    school_id,
    school_name,
    address,
    nearest_park_distance_m,
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END AS access_category
FROM school_nearest_park;



--View review


SELECT *
FROM school_green_access
ORDER BY nearest_park_distance_m DESC
LIMIT 20;

 

--Add Geometry to school

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


DROP VIEW IF EXISTS school_nearest_park CASCADE;

CREATE VIEW school_nearest_park AS
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

SELECT *
FROM school_nearest_park
LIMIT 5;

CREATE VIEW school_green_access AS
SELECT
    school_id,
    school_name,
    address,
    geom_utm,
    nearest_park_distance_m,
    CASE
        WHEN nearest_park_distance_m <= 250 THEN '0-250 m'
        WHEN nearest_park_distance_m <= 500 THEN '250-500 m'
        WHEN nearest_park_distance_m <= 1000 THEN '500-1000 m'
        ELSE '>1000 m'
    END AS access_category
FROM school_nearest_park;

SELECT
    COUNT(*) AS total_schools,
    COUNT(geom_utm) AS schools_with_geometry
FROM school_green_access;

---ENTER OF Bezirke_München TO SQL
SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT
    COUNT(*) AS number_of_districts
FROM "Bezirke_München";


---CRS و Geometry
SELECT
    ST_SRID(geom) AS srid,
    GeometryType(geom) AS geometry_type
FROM "Bezirke_München"
LIMIT 5;	

SELECT
    *
FROM "Bezirke_München"
LIMIT 5;

----Spatial Join
SELECT
    s.school_id,
    s.school_name,
    s.address,
    s.nearest_park_distance_m,
    s.access_category,
    d.name AS district_name
FROM school_green_access s
JOIN "Bezirke_München" d
    ON ST_Within(
        s.geom_utm,
        d.geom
    );


---Finding District column names
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'Bezirke_München'
ORDER BY ordinal_position;

----Building View Schools + Stadtbezirk
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


----Verify that all 464 schools are located within the District

SELECT
    COUNT(*) AS total_schools,
    COUNT(DISTINCT school_id) AS unique_schools
FROM school_district_access;

----Number of schools in each district

SELECT
    district_number,
    district_name,
    COUNT(*) AS total_schools
FROM school_district_access
GROUP BY
    district_number,
    district_name
ORDER BY
    total_schools DESC;

----How many schools in each District are more than 1 km from the nearest park?

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
	
---Poor Access Percentage for Each District
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
        / COUNT(*),
        1
    ) AS poor_access_percentage
FROM school_district_access
GROUP BY
    district_number,
    district_name
ORDER BY
    poor_access_percentage DESC;

---Ranking of regions
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
            / COUNT(*),
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

----Creating the final District Analysis View

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


SELECT
    district_number,
    district_name,
    total_schools,
    poor_access_schools,
    poor_access_percentage
FROM district_green_access
ORDER BY poor_access_percentage DESC;








