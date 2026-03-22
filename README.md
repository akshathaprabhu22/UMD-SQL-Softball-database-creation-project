# 🥎 UMD Softball Database — SQL Database Design & Analytics Project

A comprehensive relational database built in T-SQL for the University of Maryland Softball Team, covering two decades of game, player, and season data. This project demonstrates end-to-end database design — from schema creation and data ingestion to analytical querying and view creation.

---

## 📌 Project Objective

To design and implement a normalized relational database that stores historical softball data for UMD, enabling structured querying for player performance analysis, team win/loss tracking, and seasonal trend reporting.

---

## 📂 Repository Structure

| File | Type | Description |
|---|---|---|
| `softball_database_create.sql` | DDL | Creates all tables, defines schema, sets primary and foreign keys |
| `softball_data_insert.sql` | DML | Inserts two decades of historical game, player, and season data |
| `create_winloss_view.sql` | View | Creates a reusable SQL VIEW to calculate win/loss records dynamically |
| `softball_stats_analysis.sql` | Analytics | Analytical queries for player stats, team performance, and seasonal trends |
| `Read Me - Database Design.pdf` | Documentation | ER diagram, table relationships, and database design decisions |

---

## 🗄️ Database Design

The database follows a normalized relational schema designed to minimize redundancy and support flexible querying across players, games, and seasons.

### Core Tables

| Table | Description |
|---|---|
| `Players` | Player profiles — name, position, year, jersey number |
| `Games` | Game records — opponent, date, location, result |
| `Seasons` | Season-level metadata — year, conference, overall record |
| `PlayerStats` | Per-game batting and fielding stats per player |
| `TeamStats` | Aggregate team-level statistics per season |

### Key Relationships

- Each `PlayerStats` record links to a `Player` and a `Game` (many-to-one)
- Each `Game` belongs to a `Season` (many-to-one)
- `TeamStats` rolls up from `PlayerStats` and `Games` per season

---

## 🔍 SQL Features Demonstrated

**Schema Design**
- Primary and foreign key constraints
- Referential integrity across tables
- Normalization to reduce data redundancy

**Data Manipulation**
- Bulk INSERT statements for historical data population
- Structured data across players, games, and seasons

**Views**
- `WinLossView` — dynamically calculates win/loss record per season without rewriting logic in every query

**Analytical Queries**
- Player batting average calculations
- Top performers by season
- Win/loss record trends over two decades
- Opponent analysis and home vs. away performance breakdowns

---

## 📊 Sample Queries

**Season win/loss record:**
```sql
SELECT season_year, wins, losses,
       ROUND(CAST(wins AS FLOAT) / (wins + losses) * 100, 2) AS win_pct
FROM WinLossView
ORDER BY season_year DESC;
```

**Top batting averages in a season:**
```sql
SELECT p.player_name, ps.season_year,
       ROUND(SUM(ps.hits) * 1.0 / SUM(ps.at_bats), 3) AS batting_avg
FROM PlayerStats ps
JOIN Players p ON ps.player_id = p.player_id
WHERE ps.at_bats > 0
GROUP BY p.player_name, ps.season_year
ORDER BY batting_avg DESC;
```

**Home vs. Away performance:**
```sql
SELECT location_type,
       COUNT(*) AS games_played,
       SUM(CASE WHEN result = 'W' THEN 1 ELSE 0 END) AS wins,
       SUM(CASE WHEN result = 'L' THEN 1 ELSE 0 END) AS losses
FROM Games
GROUP BY location_type;
```

---

## 🔧 Tech Stack

| Tool | Usage |
|---|---|
| T-SQL (Microsoft SQL Server) | Database engine & query language |
| SQL Server Management Studio (SSMS) | Development environment |
| SQL Views | Reusable win/loss logic |

---

## 🚀 How to Run

```sql
-- Step 1: Create the database schema
-- Run: softball_database_create.sql

-- Step 2: Populate with historical data
-- Run: softball_data_insert.sql

-- Step 3: Create the win/loss view
-- Run: create_winloss_view.sql

-- Step 4: Run analytical queries
-- Run: softball_stats_analysis.sql
```

> Run scripts in the order above. Each script depends on the previous one.

---

## 🔄 Future Improvements — Data Ingestion Pipeline

The current data ingestion relies on manual INSERT statements. Below are improvements to make ingestion automated, scalable, and production-ready.

### 1. Python ETL Pipeline (Replace Manual INSERTs)

```python
import pandas as pd
import pyodbc

df = pd.read_csv('softball_stats.csv')
conn = pyodbc.connect('your_connection_string')
cursor = conn.cursor()

for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO PlayerStats (player_id, season_year, hits, at_bats)
        VALUES (?, ?, ?, ?)
    """, row['player_id'], row['season_year'], row['hits'], row['at_bats'])

conn.commit()
```

### 2. Web Scraping for Live Data

UMD Athletics publishes stats publicly. A scraper could feed live data directly into the database:

```python
import requests
from bs4 import BeautifulSoup

url = "https://umterps.com/sports/softball/stats"
soup = BeautifulSoup(requests.get(url).content, 'html.parser')
# Parse stats table → load into DB
```

### 3. S3 Staging Layer

Add a raw data staging layer before loading into the database for auditability:

```
UMD Athletics Site → Python Scraper → AWS S3 (Raw) → ETL Script → SQL Database
```

### 4. Upsert Logic (Prevent Duplicates)

Replace plain INSERTs with MERGE statements to safely re-run ingestion:

```sql
MERGE INTO PlayerStats AS target
USING (VALUES (?, ?, ?, ?)) AS source (player_id, season_year, hits, at_bats)
ON target.player_id = source.player_id AND target.season_year = source.season_year
WHEN MATCHED THEN
    UPDATE SET hits = source.hits, at_bats = source.at_bats
WHEN NOT MATCHED THEN
    INSERT (player_id, season_year, hits, at_bats)
    VALUES (source.player_id, source.season_year, source.hits, source.at_bats);
```

### 5. Pre-Ingestion Data Validation

Validate records before they hit the database to prevent bad data:

```python
def validate_record(row):
    assert 0 <= row['batting_avg'] <= 1, "Invalid batting average"
    assert row['season_year'] >= 2000, "Season out of expected range"
    assert row['player_id'] is not None, "Missing player ID"
    assert row['at_bats'] >= 0, "At bats cannot be negative"
```

---

## 👩‍💻 Author

**Akshatha Prabhu**
Associate Product Manager II (AI/ML) @ HiLabs
[GitHub](https://github.com/akshathaprabhu22) · [Tableau](https://public.tableau.com/app/profile/akshatha.prabhu6534/vizzes)
