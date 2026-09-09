```python
from getpass import getpass

import pandas as pd
from sqlalchemy import URL, create_engine


# ============================================================
# Database connection
# ============================================================

password = getpass("Enter PostgreSQL password: ")

connection_url = URL.create(
    "postgresql+psycopg2",
    username="postgres",
    password=password,
    host="localhost",
    port=5432,
    database="munich_green",
)

engine = create_engine(connection_url)


# ============================================================
# Test PostGIS connection
# ============================================================

query = "SELECT PostGIS_Version();"

df = pd.read_sql(query, engine)

print("PostGIS connection successful.")
print("\nPostGIS version:")
print(df)


# ============================================================
# Close database connection
# ============================================================

engine.dispose()
```
