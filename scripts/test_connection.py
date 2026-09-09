from sqlalchemy import create_engine
import pandas as pd
from getpass import getpass

password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    f"postgresql://postgres:{password}@localhost/munich_green"
)
query = "SELECT PostGIS_Version();"

df = pd.read_sql(query, engine)

print(df)
