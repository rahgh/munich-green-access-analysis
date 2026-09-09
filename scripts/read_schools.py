```python
from pathlib import Path

import geopandas as gpd


# ============================================================
# Project and data paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]

SCHOOL_FILE = (
    PROJECT_ROOT
    / "data"
    / "data_raw"
    / "Schulen_München.shp"
)


# ============================================================
# Read school data
# ============================================================

schools = gpd.read_file(SCHOOL_FILE)


# ============================================================
# Basic dataset information
# ============================================================

print("Number of schools:")
print(len(schools))

print("\nColumns:")
print(schools.columns.tolist())

print("\nCRS:")
print(schools.crs)

print("\nFirst 5 records:")
print(schools.head())
```
