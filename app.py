"""Tractor Database Management System - minimal Flask UI.
Run:  pip install flask  ->  python app.py  ->  open http://127.0.0.1:5000
Default DB is SQLite (zero setup). The same schema for MySQL is in sql/schema_mysql.sql.
"""
import os, re, sqlite3
from flask import Flask, render_template, request, redirect, url_for, flash, g

BASE = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(BASE, "tractor.db")
app = Flask(__name__)
app.secret_key = "tractor-dbms"


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


@app.teardown_appcontext
def close_db(_):
    db = g.pop("db", None)
    if db:
        db.close()


def init_db():
    if os.path.exists(DB):
        return
    c = sqlite3.connect(DB)
    for f in ("schema_sqlite.sql", "seed.sql"):
        c.executescript(open(os.path.join(BASE, "sql", f)).read())
    c.commit(); c.close()


def load_queries():
    """Parse sql/queries.sql -> [(title, sql)]"""
    out = []
    for block in open(os.path.join(BASE, "sql", "queries.sql")).read().split(";"):
        m = re.search(r"--\s*(Q\d+\s.*)", block)
        if m:
            sql = re.sub(r"--.*\n", "", block).strip()
            out.append((m.group(1).strip(), sql))
    return out


@app.route("/")
def home():
    db = get_db()
    stats = {t: db.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
             for t in ("Farmer_Info", "Tractors", "Dealer", "GovScheme", "Purchase", "Loan_Details")}
    stats["Subsidy given (Rs)"] = db.execute("SELECT COALESCE(SUM(subsidy_amt),0) FROM Purchase").fetchone()[0]
    recent = db.execute("""SELECT p.purchase_id, f.fname||' '||f.lname AS farmer, t.brand||' '||t.model AS tractor,
        p.purchase_date, p.price_paid, COALESCE(g.scheme_name,'-') AS scheme
        FROM Purchase p JOIN Farmer_Info f USING(farmer_id) JOIN Tractors t USING(tractor_id)
        LEFT JOIN GovScheme g USING(scheme_id) ORDER BY p.purchase_date DESC LIMIT 6""").fetchall()
    return render_template("home.html", stats=stats, recent=recent)


TABLES = {
    "farmers": ("Farmers", "SELECT farmer_id AS ID, fname AS First, lname AS Last, village AS Village, district AS District, land_acres AS Acres FROM Farmer_Info ORDER BY farmer_id"),
    "tractors": ("Tractors", "SELECT t.tractor_id AS ID, t.brand AS Brand, t.model AS Model, t.hp AS HP, t.price AS Price, d.dealer_name AS Dealer FROM Tractors t JOIN Dealer d USING(dealer_id) ORDER BY t.tractor_id"),
    "dealers": ("Dealers", "SELECT dealer_id AS ID, dealer_name AS Name, city AS City, phone AS Phone FROM Dealer"),
    "schemes": ("Govt. Schemes", "SELECT scheme_id AS ID, scheme_name AS Scheme, subsidy_percent AS 'Subsidy %', max_subsidy AS 'Max subsidy', min_land_acres AS 'Min acres' FROM GovScheme"),
    "purchases": ("Purchases", "SELECT p.purchase_id AS ID, f.fname||' '||f.lname AS Farmer, t.brand||' '||t.model AS Tractor, COALESCE(g.scheme_name,'-') AS Scheme, p.purchase_date AS Date, p.subsidy_amt AS Subsidy, p.price_paid AS Paid FROM Purchase p JOIN Farmer_Info f USING(farmer_id) JOIN Tractors t USING(tractor_id) LEFT JOIN GovScheme g USING(scheme_id) ORDER BY p.purchase_id"),
    "loans": ("Loans", "SELECT l.loan_id AS ID, f.fname||' '||f.lname AS Farmer, l.bank_name AS Bank, l.loan_amount AS Amount, l.interest_rate AS 'Rate %', l.tenure_months AS Months, l.status AS Status FROM Loan_Details l JOIN Purchase p USING(purchase_id) JOIN Farmer_Info f USING(farmer_id) ORDER BY l.loan_id"),
    "services": ("Tractor Service", "SELECT s.purchase_id AS Purchase, s.service_no AS 'Svc #', t.brand||' '||t.model AS Tractor, s.service_date AS Date, s.service_type AS Type, s.cost AS Cost FROM Tractor_Service s JOIN Purchase p USING(purchase_id) JOIN Tractors t USING(tractor_id) ORDER BY s.purchase_id, s.service_no"),
}


@app.route("/view/<name>")
def view(name):
    if name not in TABLES:
        return redirect(url_for("home"))
    title, sql = TABLES[name]
    cur = get_db().execute(sql)
    return render_template("table.html", title=title, name=name, cols=[d[0] for d in cur.description], rows=cur.fetchall())


@app.route("/farmers/add", methods=["GET", "POST"])
def add_farmer():
    if request.method == "POST":
        f = request.form
        db = get_db()
        cur = db.execute("INSERT INTO Farmer_Info(fname,lname,village,district,land_acres) VALUES(?,?,?,?,?)",
                         (f["fname"], f["lname"], f["village"], f["district"], f["land_acres"]))
        if f["phone"].strip():
            db.execute("INSERT INTO Farmer_Phone VALUES(?,?)", (cur.lastrowid, f["phone"].strip()))
        db.commit(); flash("Farmer added."); return redirect(url_for("view", name="farmers"))
    return render_template("form.html", title="Add Farmer", fields=[
        ("fname", "First name", "text"), ("lname", "Last name", "text"), ("village", "Village", "text"),
        ("district", "District", "text"), ("land_acres", "Land (acres)", "number"), ("phone", "Phone (optional)", "text")])


@app.route("/tractors/add", methods=["GET", "POST"])
def add_tractor():
    db = get_db()
    if request.method == "POST":
        f = request.form
        try:
            db.execute("INSERT INTO Tractors(brand,model,hp,price,dealer_id) VALUES(?,?,?,?,?)",
                       (f["brand"], f["model"], f["hp"], f["price"], f["dealer_id"]))
            db.commit(); flash("Tractor added."); return redirect(url_for("view", name="tractors"))
        except sqlite3.IntegrityError as e:
            flash(f"Not saved: {e}")
    dealers = [(r["dealer_id"], r["dealer_name"]) for r in db.execute("SELECT dealer_id, dealer_name FROM Dealer")]
    return render_template("form.html", title="Add Tractor", fields=[
        ("brand", "Brand", "text"), ("model", "Model", "text"), ("hp", "Horsepower", "number"),
        ("price", "Price (Rs)", "number"), ("dealer_id", "Dealer", dealers)])


@app.route("/purchase/new", methods=["GET", "POST"])
def new_purchase():
    """One TRANSACTION: Purchase (+ subsidy calc) and optional Loan - all or nothing."""
    db = get_db()
    if request.method == "POST":
        f = request.form
        try:
            tractor = db.execute("SELECT price FROM Tractors WHERE tractor_id=?", (f["tractor_id"],)).fetchone()
            farmer = db.execute("SELECT land_acres FROM Farmer_Info WHERE farmer_id=?", (f["farmer_id"],)).fetchone()
            price, sub, sid = tractor["price"], 0, f["scheme_id"] or None
            if sid:
                s = db.execute("SELECT * FROM GovScheme WHERE scheme_id=?", (sid,)).fetchone()
                if farmer["land_acres"] < s["min_land_acres"]:
                    raise ValueError(f"Farmer has {farmer['land_acres']} acres; scheme needs {s['min_land_acres']}.")
                sub = min(round(price * s["subsidy_percent"] / 100), s["max_subsidy"])
            cur = db.execute("INSERT INTO Purchase(farmer_id,tractor_id,scheme_id,purchase_date,price_paid,subsidy_amt) VALUES(?,?,?,?,?,?)",
                             (f["farmer_id"], f["tractor_id"], sid, f["purchase_date"], price - sub, sub))
            if f["bank_name"].strip():
                db.execute("INSERT INTO Loan_Details(purchase_id,bank_name,loan_amount,interest_rate,tenure_months) VALUES(?,?,?,?,?)",
                           (cur.lastrowid, f["bank_name"], f["loan_amount"], f["interest_rate"], f["tenure_months"]))
            db.commit(); flash(f"Purchase recorded. Subsidy applied: Rs {sub:,.0f}")
            return redirect(url_for("view", name="purchases"))
        except (ValueError, sqlite3.Error) as e:
            db.rollback(); flash(f"Transaction rolled back: {e}")
    q = lambda sql: [tuple(r) for r in db.execute(sql)]
    from datetime import date
    return render_template("form.html", title="New Purchase (with optional loan)", fields=[
        ("farmer_id", "Farmer", q("SELECT farmer_id, fname||' '||lname FROM Farmer_Info")),
        ("tractor_id", "Tractor", q("SELECT tractor_id, brand||' '||model||' - Rs '||price FROM Tractors")),
        ("scheme_id", "Govt. scheme", [("", "None")] + q("SELECT scheme_id, scheme_name FROM GovScheme")),
        ("purchase_date", "Date", "date"),
        ("bank_name", "Bank (leave blank for no loan)", "text"), ("loan_amount", "Loan amount", "number"),
        ("interest_rate", "Interest rate %", "number"), ("tenure_months", "Tenure (months)", "number")],
        today=date.today().isoformat())


@app.route("/delete/<name>/<int:rid>", methods=["POST"])
def delete(name, rid):
    table = {"farmers": ("Farmer_Info", "farmer_id"), "purchases": ("Purchase", "purchase_id"), "tractors": ("Tractors", "tractor_id")}.get(name)
    if table:
        try:
            db = get_db(); db.execute(f"DELETE FROM {table[0]} WHERE {table[1]}=?", (rid,)); db.commit(); flash("Deleted.")
        except sqlite3.IntegrityError:
            flash("Cannot delete: other records still refer to this row (referential integrity).")
    return redirect(url_for("view", name=name))


@app.route("/queries")
@app.route("/queries/<int:n>")
def queries(n=1):
    qs = load_queries()
    title, sql = qs[n - 1]
    cur = get_db().execute(sql)
    return render_template("queries.html", qs=qs, n=n, title=title, sql=sql, cols=[d[0] for d in cur.description], rows=cur.fetchall())


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
