-- Tractor Database Management System  (MySQL 8 / MariaDB)
CREATE DATABASE IF NOT EXISTS tractor_db;
USE tractor_db;

CREATE TABLE Dealer (
    dealer_id   INT AUTO_INCREMENT,
    dealer_name VARCHAR(50) NOT NULL,
    city        VARCHAR(30) NOT NULL,
    phone       CHAR(10)    NOT NULL,
    PRIMARY KEY (dealer_id),
    UNIQUE (dealer_name)
);

CREATE TABLE Tractors (
    tractor_id INT AUTO_INCREMENT,
    brand      VARCHAR(30)   NOT NULL,
    model      VARCHAR(40)   NOT NULL,
    hp         INT           NOT NULL CHECK (hp > 0),
    price      DECIMAL(10,2) NOT NULL CHECK (price > 0),
    dealer_id  INT           NOT NULL,
    PRIMARY KEY (tractor_id),
    UNIQUE (brand, model),
    FOREIGN KEY (dealer_id) REFERENCES Dealer(dealer_id)
);

CREATE TABLE Farmer_Info (
    farmer_id  INT AUTO_INCREMENT,
    fname      VARCHAR(20) NOT NULL,
    lname      VARCHAR(20) NOT NULL,
    village    VARCHAR(30) NOT NULL,
    district   VARCHAR(30) NOT NULL,
    land_acres DECIMAL(6,2) NOT NULL CHECK (land_acres >= 0),
    PRIMARY KEY (farmer_id)
);

CREATE TABLE Farmer_Phone (
    farmer_id INT      NOT NULL,
    phone     CHAR(10) NOT NULL,
    PRIMARY KEY (farmer_id, phone),
    FOREIGN KEY (farmer_id) REFERENCES Farmer_Info(farmer_id) ON DELETE CASCADE
);

CREATE TABLE GovScheme (
    scheme_id        INT AUTO_INCREMENT,
    scheme_name      VARCHAR(60)  NOT NULL,
    subsidy_percent  DECIMAL(4,1) NOT NULL CHECK (subsidy_percent BETWEEN 0 AND 100),
    max_subsidy      DECIMAL(10,2) NOT NULL,
    min_land_acres   DECIMAL(6,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (scheme_id),
    UNIQUE (scheme_name)
);

CREATE TABLE Purchase (
    purchase_id   INT AUTO_INCREMENT,
    farmer_id     INT  NOT NULL,
    tractor_id    INT  NOT NULL,
    scheme_id     INT  NULL,
    purchase_date DATE NOT NULL,
    price_paid    DECIMAL(10,2) NOT NULL,
    subsidy_amt   DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (farmer_id)  REFERENCES Farmer_Info(farmer_id),
    FOREIGN KEY (tractor_id) REFERENCES Tractors(tractor_id),
    FOREIGN KEY (scheme_id)  REFERENCES GovScheme(scheme_id)
);

CREATE TABLE Loan_Details (
    loan_id       INT AUTO_INCREMENT,
    purchase_id   INT NOT NULL,
    bank_name     VARCHAR(40)   NOT NULL,
    loan_amount   DECIMAL(10,2) NOT NULL CHECK (loan_amount > 0),
    interest_rate DECIMAL(4,2)  NOT NULL,
    tenure_months INT           NOT NULL,
    status        VARCHAR(10)   NOT NULL DEFAULT 'Active'
                  CHECK (status IN ('Active','Closed','Overdue')),
    PRIMARY KEY (loan_id),
    UNIQUE (purchase_id),
    FOREIGN KEY (purchase_id) REFERENCES Purchase(purchase_id) ON DELETE CASCADE
);

CREATE TABLE Tractor_Service (
    purchase_id  INT NOT NULL,
    service_no   INT NOT NULL,
    service_date DATE NOT NULL,
    service_type VARCHAR(30)  NOT NULL,
    cost         DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (purchase_id, service_no),
    FOREIGN KEY (purchase_id) REFERENCES Purchase(purchase_id) ON DELETE CASCADE
);
