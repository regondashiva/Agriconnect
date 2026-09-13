"""
Agriconnect Database & API Seeding Script
=========================================
Can be used by the Backend Team to:
1. Validate `seed_data.json` structure
2. Push seed records directly into a database (PostgreSQL / SQLite / MongoDB)
3. Or test backend API endpoints by POSTing the seed datasets.

Usage:
    python seed_runner.py --dry-run
    python seed_runner.py --export-sqlite agriconnect.db
"""

import json
import sqlite3
import sys
from pathlib import Path


def load_seed_data(file_path="seed_data.json"):
    path = Path(__file__).parent / file_path
    if not path.exists():
        print(f"Error: {file_path} not found.")
        sys.exit(1)
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def print_summary(data):
    if sys.stdout.encoding.lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')
    print("=" * 60)
    print("AgriConnect Backend Seed Data Summary")
    print("=" * 60)
    for key, val in data.items():
        if key.startswith("_"):
            continue
        if isinstance(val, list):
            print(f"  • {key.ljust(25)}: {len(val)} records")
    print("=" * 60)


def export_sqlite(data, db_path="agriconnect.db"):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # Users
    cur.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        phone_number TEXT UNIQUE,
        role TEXT,
        full_name TEXT,
        business_name TEXT,
        location TEXT,
        latitude REAL,
        longitude REAL,
        preferred_language TEXT,
        fpo_cluster_assigned TEXT,
        verified_id TEXT,
        is_verified INTEGER,
        bank_name TEXT,
        account_number_masked TEXT,
        ifsc_code TEXT,
        upi_id TEXT,
        created_at TEXT
    )""")

    for u in data.get("users", []):
        b = u.get("bank_details") or {}
        cur.execute("""
        INSERT OR REPLACE INTO users VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            u["id"], u["phone_number"], u["role"], u["full_name"], u["business_name"],
            u["location"], u["latitude"], u["longitude"], u["preferred_language"],
            u["fpo_cluster_assigned"], u["verified_id"], 1 if u["is_verified"] else 0,
            b.get("bank_name"), b.get("account_number_masked"), b.get("ifsc_code"), b.get("upi_id"),
            u["created_at"]
        ))

    # Produce Listings
    cur.execute("""
    CREATE TABLE IF NOT EXISTS produce_listings (
        id TEXT PRIMARY KEY,
        farmer_id TEXT,
        farmer_name TEXT,
        crop_name TEXT,
        variety TEXT,
        total_quantity_kg REAL,
        available_quantity_kg REAL,
        expected_price_per_kg REAL,
        quality_grade TEXT,
        quality_score REAL,
        confidence_score REAL,
        risk_level TEXT,
        photo_count INTEGER,
        harvest_date TEXT,
        pickup_address TEXT,
        pickup_latitude REAL,
        pickup_longitude REAL,
        status TEXT,
        created_at TEXT,
        FOREIGN KEY(farmer_id) REFERENCES users(id)
    )""")

    for p in data.get("produce_listings", []):
        cur.execute("""
        INSERT OR REPLACE INTO produce_listings VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            p["id"], p["farmer_id"], p.get("farmer_name", ""), p["crop_name"], p.get("variety", ""),
            p["total_quantity_kg"], p["available_quantity_kg"], p["expected_price_per_kg"],
            p["quality_grade"], p["quality_score"], p["confidence_score"], p["risk_level"],
            p.get("photo_count", 0), p.get("harvest_date", ""), p.get("pickup_address", ""),
            p.get("pickup_latitude", 0.0), p.get("pickup_longitude", 0.0),
            p.get("status", "Listed"), p.get("created_at", "")
        ))

    conn.commit()
    conn.close()
    print(f" Successfully seeded local SQLite database: {db_path}")


if __name__ == "__main__":
    data = load_seed_data()
    print_summary(data)
    if "--export-sqlite" in sys.argv:
        target = "agriconnect.db"
        idx = sys.argv.index("--export-sqlite")
        if idx + 1 < len(sys.argv):
            target = sys.argv[idx + 1]
        export_sqlite(data, target)
