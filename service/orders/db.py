"""Database access for the orders service."""
import os

import psycopg2

# Falls back to a local database for development.
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://orders:orders@localhost:5432/orders")


def connect():
    return psycopg2.connect(DATABASE_URL, connect_timeout=5)


def create_schema(conn) -> None:
    with conn.cursor() as cur:
        cur.execute("""CREATE TABLE IF NOT EXISTS orders (
                           id SERIAL PRIMARY KEY,
                           customer TEXT NOT NULL,
                           total_cents INTEGER NOT NULL CHECK (total_cents >= 0))""")
    conn.commit()


def add_order(conn, customer: str, total_cents: int) -> int:
    with conn.cursor() as cur:
        cur.execute("INSERT INTO orders (customer, total_cents) VALUES (%s, %s) RETURNING id",
                    (customer, total_cents))
        order_id = cur.fetchone()[0]
    conn.commit()
    return order_id


def revenue_cents(conn) -> int:
    with conn.cursor() as cur:
        cur.execute("SELECT coalesce(sum(total_cents), 0) FROM orders")
        return cur.fetchone()[0]
