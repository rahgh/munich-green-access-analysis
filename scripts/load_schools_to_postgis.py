```python
from getpass import getpass
from pathlib import Path

import geopandas as gpd
from sqlalchemy import create_engine


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCHOOLS_FILE = (
    PROJECT_ROOT
    / "data"
    / "data_raw"
    / "Schulen_München.shp"
)


# ============================================================
# Database connection
# ============================================================

password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    f"postgresql://postgres:{password}@localhost/munich_green"
)


# ============================================================
# Load school data
# ============================================================

schools = gpd.read_file(SCHOOLS_FILE)


# ============================================================
# Import data into PostGIS
# ============================================================

schools.to_postgis(
    "schools",
    engine,
    if_exists="replace",
    index=False,
)

print("Schools imported successfully!")
```
