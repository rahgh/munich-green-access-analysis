from sqlalchemy import create_engine
import pandas as pd

PASSWORD = "A1B2C3_narges"

engine = create_engine(
    "postgresql://postgres:{password}@localhost/munich_green"
)

query = "SELECT PostGIS_Version();"

df = pd.read_sql(query, engine)

print(df)