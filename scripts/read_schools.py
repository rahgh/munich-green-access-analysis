import geopandas as gpd
from pathlib import Path


# ============================================================
# 1. Project and data paths
# ============================================================

project_folder = Path(
    r"C:\Users\ghari\Documents\MyDocs\munich-green-access-analysis"
)

school_file = (
    project_folder
    / "data"
    / "data_raw"
    / "Schulen_München.shp"
)


# ============================================================
# 2. Read school data
# ============================================================

schools = gpd.read_file(school_file)


# ============================================================
# 3. Basic dataset information
# ============================================================

print("Number of schools:")
print(len(schools))

print("\nColumns:")
print(schools.columns.tolist())

print("\nCRS:")
print(schools.crs)

print("\nFirst 5 records:")
print(schools.head())