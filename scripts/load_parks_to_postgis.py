import geopandas as gpd
from sqlalchemy import create_engine
from getpass import getpass

password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    f"postgresql://postgres:{password}@localhost/munich_green"
)
parks = gpd.read_file(
    r"C:\Users\ghari\Documents\MyDocs\munich-green-access-analysis\data\data_raw\Parks_München.shp"
)

parks.to_postgis(
    "parks",
    engine,
    if_exists="replace",
    index=False
)
print("Parks imported successfully!")
