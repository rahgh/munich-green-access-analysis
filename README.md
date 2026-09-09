# Munich Green Access Analysis

## Overview

This project analyses the spatial accessibility of green spaces for schools in Munich, Germany.

The main objective is to investigate how far schools are located from their nearest park and to identify districts where schools have relatively poor access to green space.

The project demonstrates a complete GIS workflow combining spatial databases, SQL/PostGIS, Python and QGIS.

---

## Research Question

How accessible are parks to schools across Munich, and which city districts contain the highest proportion of schools located more than 1 km from the nearest park?

---

## Objectives

The main objectives of the project are:

- Calculate the distance from each school to its nearest park.
- Classify schools according to their distance from the nearest park.
- Identify schools with relatively poor access to parks.
- Analyse the spatial distribution of school access across Munich districts.
- Aggregate school-level results to the district level.
- Create thematic maps and statistical visualisations.
- Demonstrate a reproducible GIS workflow using PostGIS, SQL, Python and QGIS.

---

## Data

The analysis uses spatial datasets representing:

- Schools in Munich
- Parks and green spaces in Munich
- Munich administrative districts

The datasets contain geographic coordinates and spatial geometries required for spatial analysis.

---

## Technologies

The project uses the following technologies:

- **PostgreSQL / PostGIS** — spatial database and spatial analysis
- **SQL** — spatial queries, distance calculations and aggregation
- **Python** — data processing and visualisation
- **pandas** — tabular data processing
- **matplotlib** — statistical charts
- **QGIS** — cartography and spatial visualisation
- **Git / GitHub** — version control and project management

---

## Methodology

### 1. Data Preparation

School, park and administrative district datasets were imported into PostgreSQL/PostGIS.

The school and park datasets were initially provided in geographic coordinates.

### 2. Coordinate Reference System

For distance calculations, the spatial data were transformed to:

**ETRS89 / UTM Zone 32N — EPSG:25832**

A projected coordinate reference system was used so that distances could be calculated in metres.

### 3. School–Park Proximity Analysis

The distance between schools and parks was analysed using PostGIS spatial functions.

The nearest park distance was calculated for each school using:

- `ST_Distance`
- `ST_DWithin`
- spatial joins
- aggregation functions

### 4. School Access Classification

Schools were classified according to their distance to the nearest park:

| Distance to nearest park | Access category |
|---|---|
| 0–250 m | Very close |
| 250–500 m | Close |
| 500–1000 m | Moderate |
| >1000 m | Poor access |

### 5. District-Level Analysis

Each school was spatially joined to its Munich administrative district.

The results were then aggregated by district to identify areas with a high proportion of schools located more than 1 km from the nearest park.

### 6. Cartography

The results were visualised in QGIS using:

- graduated district-level symbology
- categorized school points
- park locations
- map legends
- scale bar
- north arrow
- coordinate reference system information

### 7. Python Visualisation

Python was used to create statistical visualisations of the analytical results.

The charts show:

- number of schools by access category
- percentage of schools by access category
- districts with the highest proportion of schools with poor access

---

## Key Results

A total of **464 schools** and **34 parks** were included in the analysis.

The average distance from a school to its nearest park was:

**1,626.3 metres**

The minimum recorded distance was:

**75.4 metres**

The maximum recorded distance was:

**3,717.9 metres**

### School Access Results

| Access category | Number of schools | Percentage |
|---|---:|---:|
| 0–250 m | 19 | 4.1% |
| 250–500 m | 32 | 6.9% |
| 500–1000 m | 71 | 15.3% |
| >1000 m | 342 | 73.7% |
| **Total** | **464** | **100%** |

The analysis shows that **342 of the 464 schools (73.7%) are located more than 1 km from their nearest park** based on straight-line distance.

---

## Visualisations

### School Access by Distance

![Percentage of schools by distance to nearest park](maps/schools_access_percentage.png)

![Number of schools by distance to nearest park](maps/schools_by_access_category.png)

### District-Level Poor Access

![Districts with highest poor school access](maps/top_districts_poor_access.png)

---

## QGIS Map

The final QGIS map visualises:

- school locations classified by distance to the nearest park
- Munich parks
- district-level percentage of schools with poor access

The map uses **ETRS89 / UTM Zone 32N (EPSG:25832)**.

![Munich Green Access Analysis Map](maps/munich_green_access_map.png)

---

## Main Spatial Analysis Outputs

The project produces the following analytical outputs:

### School-level analysis

- `school_green_access`
- nearest park distance
- school access category
- school geometry

### District-level analysis

- `school_district_access`
- `district_green_access`
- total number of schools per district
- number of schools with poor access
- percentage of schools with poor access

---

## Project Structure

The repository is organised into the following main components:

- **data/**
  - `data_raw/` — raw spatial datasets
  - Munich school data
  - Munich park data
  - Munich district data

- **QGIS/**
  - `munich_green_access.qgz` — QGIS project

- **scripts/**
  - `test_connection.py`
  - `read_schools.py`
  - `load_schools_to_postgis.py`
  - `load_parks_to_postgis.py`
  - `python_charts.py`

- **sql/**
  - `01_green_access.sql` — SQL and PostGIS spatial analysis

- **maps/**
  - `munich_green_access_map.png`
  - `schools_access_percentage.png`
  - `schools_by_access_category.png`
  - `top_districts_poor_access.png`

- **outputs/** — analytical output files

- **README.md** — project documentation

- **.gitignore** — Git configuration
:::

## Limitations

This analysis measures accessibility based on the straight-line distance from each school to its nearest park.

Therefore, the results do not represent actual walking, cycling, or pedestrian accessibility.

The analysis does not consider:

- park size
- park quality
- park facilities
- pedestrian or cycling networks
- physical barriers such as major roads or railway infrastructure
- population distribution
- school capacity or number of students

## Reproducibility

The project follows a structured GIS workflow combining PostgreSQL/PostGIS, SQL, Python, and QGIS.

The main spatial analysis is implemented using SQL and PostGIS, including:

- coordinate reference system transformation
- school–park proximity analysis
- nearest park distance calculation
- school access classification
- school–district spatial joins
- district-level aggregation

## Author

**Rahimeh Gharibpour**

GIS / Geospatial Analysis

