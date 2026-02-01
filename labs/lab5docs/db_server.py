from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

DB_PATH = "chinook.db"


def run_query(sql):
    """Execute a SELECT query and return rows as dictionaries."""
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    cur.execute(sql)

    rows = [dict(r) for r in cur.fetchall()]
    con.close()

    return rows


def is_safe_select(sql):
    """Allow only simple SELECT queries for safety."""
    if not isinstance(sql, str):
        return False

    s = sql.strip().lower()

    if not s.startswith("select"):
        return False

    banned = [
        "insert", "update", "delete",
        "drop", "alter", "create",
        "attach", "detach", "pragma"
    ]

    return not any(word in s for word in banned)


@app.post("/query")
def query():
    data = request.get_json(silent=True) or {}
    sql = data.get("sql", "")

    if not is_safe_select(sql):
        return jsonify({"error": "Only SELECT queries are allowed."}), 400

    try:
        rows = run_query(sql)
        return jsonify(rows)

    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    # listen on all interfaces so it is reachable remotely
    app.run(host="0.0.0.0", port=5000)



