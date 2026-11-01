# Tractor Database Management System (DBMS mini project)

Minimal web UI (Python Flask) on top of a relational database for a tractor subsidy scheme:
Dealer, Tractors, Farmer_Info, Farmer_Phone, GovScheme, Purchase, Loan_Details, Tractor_Service.

## Run (SQLite, no database setup)
    pip install flask
    python app.py          # then open http://127.0.0.1:5000
The first run creates `tractor.db` from `sql/schema_sqlite.sql` + `sql/seed.sql`. Delete `tractor.db` to reset.

## Use MySQL (as in the report)
    mysql -u root -p < sql/schema_mysql.sql
    mysql -u root -p tractor_db < sql/seed.sql
    mysql -u root -p tractor_db < sql/queries.sql      # the 12 test queries
(`schema_sqlite.sql` is the same schema, only AUTO_INCREMENT/CHAR types adapted for SQLite.)

## Pages
Dashboard, one list page per table, add farmer/tractor, **New purchase** (subsidy is calculated and the
purchase + loan are saved in ONE transaction, rolled back on error), delete with referential-integrity
protection, and **SQL Queries** (Q1-Q12 from `sql/queries.sql` with results).
