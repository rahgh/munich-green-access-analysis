from sqlalchemy import create_engine, URL
import pandas as pd
from getpass import getpass


# ============================================================
# 1. Database connection
# ============================================================

password = getpass("Enter PostgreSQL password: ")

connection_url = URL.create(
    "postgresql+psycopg2",
    username="postgres",
    password=password,
    host="localhost",
    port=5432,
    database="munich_green"
)

engine = create_engine(connection_url)


# ============================================================
# 2. Test PostGIS connection
# ============================================================

query = "SELECT PostGIS_Version();"

df = pd.read_sql(query, engine)

print("PostGIS connection successful.")
print("\nPostGIS version:")
print(df)


# ============================================================
# 3. Close database connection
# ============================================================

engine.dispose()
