```python
from getpass import getpass
from pathlib import Path

import geopandas as gpd
from sqlalchemy import create_engine


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]
PARKS_FILE = (
    PROJECT_ROOT
    / "data"
    / "data_raw"
    / "Parks_München.shp"
)


# ============================================================
# Database connection
# ============================================================

password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    f"postgresql://postgres:{password}@localhost/munich_green"
)


# ============================================================
# Load park data
# ============================================================

parks = gpd.read_file(PARKS_FILE)


# ============================================================
# Import data into PostGIS
# ============================================================

parks.to_postgis(
    "parks",
    engine,
    if_exists="replace",
    index=False,
)

print("Parks imported successfully!")
```
