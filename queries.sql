-- Q1  List all farmers with their district and land holding
SELECT farmer_id, fname, lname, village, district, land_acres FROM Farmer_Info ORDER BY land_acres DESC;

-- Q2  Tractors costing more than 8,00,000 with their dealer
SELECT t.brand, t.model, t.hp, t.price, d.dealer_name FROM Tractors t JOIN Dealer d ON t.dealer_id = d.dealer_id WHERE t.price > 800000 ORDER BY t.price DESC;

-- Q3  Which farmer bought which tractor (JOIN of three tables)
SELECT p.purchase_id, f.fname, f.lname, t.brand, t.model, p.purchase_date, p.price_paid FROM Purchase p JOIN Farmer_Info f ON p.farmer_id = f.farmer_id JOIN Tractors t ON p.tractor_id = t.tractor_id ORDER BY p.purchase_date;

-- Q4  Number of tractors sold and total sales per dealer
SELECT d.dealer_name, COUNT(p.purchase_id) AS tractors_sold, SUM(p.price_paid) AS total_sales FROM Dealer d JOIN Tractors t ON t.dealer_id = d.dealer_id JOIN Purchase p ON p.tractor_id = t.tractor_id GROUP BY d.dealer_id, d.dealer_name ORDER BY total_sales DESC;

-- Q5  Total subsidy given under each government scheme
SELECT g.scheme_name, COUNT(*) AS beneficiaries, SUM(p.subsidy_amt) AS total_subsidy FROM GovScheme g JOIN Purchase p ON p.scheme_id = g.scheme_id GROUP BY g.scheme_id, g.scheme_name ORDER BY total_subsidy DESC;

-- Q6  Farmers who bought a tractor WITHOUT any government scheme
SELECT f.fname, f.lname, f.district FROM Farmer_Info f JOIN Purchase p ON p.farmer_id = f.farmer_id WHERE p.scheme_id IS NULL;

-- Q7  Active or overdue loans with farmer name and bank
SELECT f.fname, f.lname, l.bank_name, l.loan_amount, l.interest_rate, l.status FROM Loan_Details l JOIN Purchase p ON l.purchase_id = p.purchase_id JOIN Farmer_Info f ON p.farmer_id = f.farmer_id WHERE l.status IN ('Active','Overdue') ORDER BY l.loan_amount DESC;

-- Q8  Total service expenditure per tractor purchase (weak entity), highest first
SELECT p.purchase_id, f.fname, t.model, COUNT(s.service_no) AS services, SUM(s.cost) AS total_cost FROM Tractor_Service s JOIN Purchase p ON s.purchase_id = p.purchase_id JOIN Farmer_Info f ON p.farmer_id = f.farmer_id JOIN Tractors t ON p.tractor_id = t.tractor_id GROUP BY p.purchase_id, f.fname, t.model ORDER BY total_cost DESC;

-- Q9  Farmers with more than 8 acres of land who have not yet bought a tractor (subquery)
SELECT fname, lname, village, land_acres FROM Farmer_Info WHERE land_acres > 8 AND farmer_id NOT IN (SELECT farmer_id FROM Purchase);

-- Q10 Most popular tractor brand (by number sold)
SELECT t.brand, COUNT(*) AS units_sold FROM Purchase p JOIN Tractors t ON p.tractor_id = t.tractor_id GROUP BY t.brand ORDER BY units_sold DESC;

-- Q11 Average loan interest rate per bank
SELECT bank_name, COUNT(*) AS loans, ROUND(AVG(interest_rate),2) AS avg_rate, SUM(loan_amount) AS total_lent FROM Loan_Details GROUP BY bank_name ORDER BY total_lent DESC;

-- Q12 Farmers with more than one phone number (multivalued attribute)
SELECT f.fname, f.lname, COUNT(*) AS phones FROM Farmer_Info f JOIN Farmer_Phone ph ON ph.farmer_id = f.farmer_id GROUP BY f.farmer_id, f.fname, f.lname HAVING COUNT(*) > 1;
