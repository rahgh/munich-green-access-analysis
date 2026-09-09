import geopandas as gpd
from sqlalchemy import create_engine

# PostgreSQL password


engine = create_engine(
    "postgresql://postgres:{password}@localhost/munich_green"
)

schools = gpd.read_file(
    r"C:\Users\ghari\Documents\MyDocs\munich-green-access-analysis\data\data_raw\Schulen_München.shp"
)

schools.to_postgis(
    "schools",
    engine,
    if_exists="replace",
    index=False
)

print("Schools imported successfully!")
