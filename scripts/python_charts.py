import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine, URL
from getpass import getpass
from pathlib import Path


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
# 2. Output folder
# ============================================================

project_folder = Path(
    r"C:\Users\ghari\Documents\MyDocs\munich-green-access-analysis"
)

output_folder = project_folder / "maps"

output_folder.mkdir(exist_ok=True)

print(f"Output folder: {output_folder}")


# ============================================================
# 3. Read school access data
# ============================================================

school_query = """
SELECT
    school_id,
    school_name,
    nearest_park_distance_m,
    access_category
FROM school_green_access
"""

schools = pd.read_sql(school_query, engine)

print(f"Schools loaded: {len(schools)}")


# ============================================================
# 4. Chart 1 — Number of schools by access category
# ============================================================

category_order = [
    "0-250 m",
    "250-500 m",
    "500-1000 m",
    ">1000 m"
]

category_counts = (
    schools["access_category"]
    .value_counts()
    .reindex(category_order)
    .fillna(0)
)

plt.figure(figsize=(9, 6))

category_counts.plot(kind="bar")

plt.title("Schools by Distance to Nearest Park")
plt.xlabel("Distance category")
plt.ylabel("Number of schools")

plt.xticks(rotation=0)
plt.tight_layout()

plt.savefig(
    output_folder / "schools_by_access_category.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()


# ============================================================
# 5. Chart 2 — Percentage of schools by access category
# ============================================================

category_percentages = (
    category_counts / len(schools) * 100
)

plt.figure(figsize=(9, 6))

category_percentages.plot(kind="bar")

plt.title("Percentage of Schools by Distance to Nearest Park")
plt.xlabel("Distance category")
plt.ylabel("Percentage of schools (%)")

plt.xticks(rotation=0)
plt.tight_layout()

plt.savefig(
    output_folder / "schools_access_percentage.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()


# ============================================================
# 6. Read district-level data
# ============================================================

district_query = """
SELECT
    district_number,
    district_name,
    total_schools,
    poor_access_schools,
    poor_access_percentage
FROM district_green_access
WHERE total_schools > 0
ORDER BY poor_access_percentage DESC
"""

districts = pd.read_sql(district_query, engine)

print(f"Districts with schools: {len(districts)}")


# ============================================================
# 7. Chart 3 — Districts with highest poor access
# ============================================================

top_districts = districts.head(10).sort_values(
    "poor_access_percentage"
)

plt.figure(figsize=(10, 7))

plt.barh(
    top_districts["district_name"],
    top_districts["poor_access_percentage"]
)

plt.title(
    "Districts with Highest Poor School Access to Green Space"
)

plt.xlabel(
    "Schools more than 1 km from nearest park (%)"
)

plt.ylabel("District")

plt.tight_layout()

plt.savefig(
    output_folder / "top_districts_poor_access.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()


# ============================================================
# 8. Summary
# ============================================================

print("\nCharts successfully created:")

print("1. maps/schools_by_access_category.png")
print("2. maps/schools_access_percentage.png")
print("3. maps/top_districts_poor_access.png")

print("\nOverall results:")

print(f"Total schools: {len(schools)}")

print(
    f"Average distance to nearest park: "
    f"{schools['nearest_park_distance_m'].mean():.1f} m"
)

print("\nAccess categories:")

print(category_counts)

print("\nDistricts with highest poor access:")

print(
    districts[
        [
            "district_name",
            "total_schools",
            "poor_access_percentage"
        ]
    ].head(10)
)