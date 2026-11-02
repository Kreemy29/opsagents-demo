import pytest

from orders import db


@pytest.fixture()
def conn():
    connection = db.connect()
    db.create_schema(connection)
    yield connection
    connection.rollback()
    connection.close()


def test_add_order_returns_an_id(conn):
    assert db.add_order(conn, "ines", 1250) > 0


def test_revenue_adds_up_orders(conn):
    before = db.revenue_cents(conn)
    db.add_order(conn, "sami", 500)
    db.add_order(conn, "sami", 700)
    assert db.revenue_cents(conn) == before + 1200
