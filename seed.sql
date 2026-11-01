-- Sample data
INSERT INTO Dealer (dealer_name, city, phone) VALUES
  ('Shree Agro Motors', 'Pune', '9822011101'),
  ('Kisan Tractors', 'Nashik', '9822011102'),
  ('Mahalaxmi Agri Sales', 'Kolhapur', '9822011103'),
  ('Sai Farm Equipments', 'Ahmednagar', '9822011104'),
  ('Vidarbha Tractors', 'Nagpur', '9822011105');

INSERT INTO Tractors (brand, model, hp, price, dealer_id) VALUES
  ('Mahindra', '575 DI', 45, 780000, 1),
  ('Mahindra', '265 DI', 30, 590000, 1),
  ('Swaraj', '744 FE', 48, 820000, 2),
  ('Swaraj', '735 XT', 40, 690000, 2),
  ('John Deere', '5050 D', 50, 880000, 3),
  ('John Deere', '5105', 40, 740000, 3),
  ('Sonalika', 'DI 750', 50, 760000, 4),
  ('Sonalika', 'Tiger 55', 55, 900000, 4),
  ('TAFE', '45 DI', 45, 710000, 5),
  ('Kubota', 'MU4501', 45, 850000, 5),
  ('New Holland', '3630', 55, 910000, 2),
  ('Eicher', '380', 40, 650000, 3);

INSERT INTO Farmer_Info (fname, lname, village, district, land_acres) VALUES
  ('Ramesh', 'Patil', 'Wadgaon', 'Pune', 5.5),
  ('Suresh', 'Jadhav', 'Sinnar', 'Nashik', 8),
  ('Ganesh', 'Shinde', 'Karveer', 'Kolhapur', 3.5),
  ('Dattatray', 'Pawar', 'Shevgaon', 'Ahmednagar', 12),
  ('Vilas', 'Bhosale', 'Baramati', 'Pune', 7),
  ('Sanjay', 'More', 'Niphad', 'Nashik', 2.5),
  ('Anil', 'Kale', 'Kamptee', 'Nagpur', 15),
  ('Prakash', 'Gaikwad', 'Rahuri', 'Ahmednagar', 4),
  ('Mahesh', 'Deshmukh', 'Katol', 'Nagpur', 9),
  ('Sunil', 'Kadam', 'Shirol', 'Kolhapur', 6),
  ('Balasaheb', 'Chavan', 'Indapur', 'Pune', 20),
  ('Vitthal', 'Mane', 'Hatkanangale', 'Kolhapur', 1.5),
  ('Rajendra', 'Salunkhe', 'Yeola', 'Nashik', 10),
  ('Nitin', 'Thorat', 'Sangamner', 'Ahmednagar', 6.5),
  ('Hanumant', 'Wagh', 'Umred', 'Nagpur', 3);

INSERT INTO GovScheme (scheme_name, subsidy_percent, max_subsidy, min_land_acres) VALUES
  ('PM-KISAN Mechanisation Subsidy', 25, 125000, 2),
  ('Sub-Mission on Agri Mechanization (SMAM)', 40, 150000, 1),
  ('Mahadbt Farm Mechanization', 35, 100000, 0),
  ('SC/ST Farmer Tractor Scheme', 50, 200000, 1),
  ('Women Farmer Tractor Scheme', 50, 180000, 0.5);

INSERT INTO Farmer_Phone (farmer_id, phone) VALUES
  (1, '9853464097'),
  (2, '9830246633'),
  (3, '9862992312'),
  (3, '7097366946'),
  (4, '9816480894'),
  (5, '9819722233'),
  (6, '9881924865'),
  (6, '7022633920'),
  (7, '9859081935'),
  (8, '9888220482'),
  (9, '9817784483'),
  (9, '7078106871'),
  (10, '9838816302'),
  (11, '9815032582'),
  (12, '9821535642'),
  (12, '7068202938'),
  (13, '9866126116'),
  (14, '9819375836'),
  (15, '9842301241'),
  (15, '7022175294');

INSERT INTO Purchase (farmer_id, tractor_id, scheme_id, purchase_date, price_paid, subsidy_amt) VALUES
  (1, 9, 1, '2023-02-14', 585000, 125000),
  (2, 10, NULL, '2023-05-20', 850000, 0),
  (3, 2, 3, '2023-08-11', 490000, 100000),
  (5, 2, 4, '2023-11-03', 390000, 200000),
  (7, 6, NULL, '2024-01-18', 740000, 0),
  (9, 10, 2, '2024-03-25', 700000, 150000),
  (10, 8, 5, '2024-06-09', 720000, 180000),
  (11, 8, 3, '2024-08-30', 800000, 100000),
  (14, 4, NULL, '2024-10-12', 690000, 0),
  (8, 2, 1, '2025-01-07', 465000, 125000),
  (6, 1, 2, '2025-03-19', 630000, 150000),
  (15, 3, 4, '2025-06-02', 620000, 200000),
  (12, 11, 3, '2025-08-21', 810000, 100000),
  (13, 8, NULL, '2025-09-15', 900000, 0);

INSERT INTO Loan_Details (purchase_id, bank_name, loan_amount, interest_rate, tenure_months, status) VALUES
  (1, 'SBI', 410000.0, 10.25, 36, 'Active'),
  (2, 'Union Bank', 595000.0, 7.5, 48, 'Active'),
  (4, 'SBI', 273000.0, 10.25, 36, 'Overdue'),
  (5, 'Cosmos Bank', 518000.0, 9.5, 60, 'Active'),
  (7, 'SBI', 504000.0, 7.5, 60, 'Active'),
  (8, 'SBI', 560000.0, 7.5, 60, 'Overdue'),
  (10, 'Union Bank', 326000.0, 9.5, 60, 'Active'),
  (11, 'Cosmos Bank', 441000.0, 8.5, 60, 'Active'),
  (13, 'Union Bank', 567000.0, 9.5, 84, 'Closed'),
  (14, 'Union Bank', 630000.0, 7.5, 48, 'Active');

INSERT INTO Tractor_Service (purchase_id, service_no, service_date, service_type, cost) VALUES
  (2, 1, '2025-05-14', 'General Service', 9500),
  (3, 1, '2025-09-27', 'General Service', 1500),
  (3, 2, '2025-10-19', 'General Service', 4200),
  (4, 1, '2025-08-22', 'Tyre Replacement', 6800),
  (5, 1, '2025-03-23', 'General Service', 1500),
  (6, 1, '2025-06-24', 'Hydraulic Check', 4200),
  (6, 2, '2025-10-03', 'Oil Change', 9500),
  (6, 3, '2025-07-06', 'Clutch Repair', 2500),
  (7, 1, '2025-10-16', 'Tyre Replacement', 6800),
  (7, 2, '2025-02-27', 'Oil Change', 4200),
  (8, 1, '2025-05-23', 'Hydraulic Check', 4200),
  (8, 2, '2025-01-15', 'Clutch Repair', 2500),
  (8, 3, '2025-10-04', 'Hydraulic Check', 1500),
  (9, 1, '2025-04-13', 'Hydraulic Check', 6800),
  (10, 1, '2025-09-09', 'Hydraulic Check', 4200),
  (10, 2, '2025-07-08', 'General Service', 1500),
  (10, 3, '2025-03-05', 'General Service', 2500),
  (12, 1, '2025-10-19', 'Clutch Repair', 2500),
  (12, 2, '2025-09-20', 'Oil Change', 6800),
  (14, 1, '2025-08-06', 'Oil Change', 4200);
