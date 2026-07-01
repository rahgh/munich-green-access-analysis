import geopandas as gpd

schools = gpd.read_file(
    r"C:\Users\ghari\Documents\MyDocs\munich-green-access-analysis\data\data_raw\Schulen_München.shp"
)

print("Number of schools:")
print(len(schools))

print("\nColumns:")
print(schools.columns)

print("\nCRS:")
print(schools.crs)

print("\nFirst 5 records:")
print(schools.head())