from sqlalchemy import create_engine
import pandas as pd


engine = create_engine(
    "postgresql://postgres:{password}@localhost/munich_green"
)

query = "SELECT PostGIS_Version();"

df = pd.read_sql(query, engine)

print(df)
