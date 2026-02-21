# Insurance Claims SQL Analysis

## Project Overview
Designed and implemented a PostgreSQL relational database schema to manage insurance claims, staff assignments, and claim workflows.

This project demonstrates structured data modelling and analytical SQL querying skills.

---


-- Drop the tables (drop in dependency order)
DROP TABLE IF EXISTS claim_assignment;
DROP TABLE IF EXISTS claim;
DROP TABLE IF EXISTS staff;

--=================================================================================================
-- Create and insert into the tables below

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_num VARCHAR(20),
    email VARCHAR(100),
    role VARCHAR(100),
    status VARCHAR(20)
);

INSERT INTO staff VALUES(1111,'Jim','Cross','0400000001','JimCross@aami.com.au','CSO','Active');
INSERT INTO staff VALUES(1112,'Daniel','Beyene','0400000002','DanielBeyene@aami.com.au','Purchase Head','Active');
INSERT INTO staff VALUES(1113,'Mark','Urban','0400000003','MarkUrban@aami.com.au','Data Mining Manager','Inactive');
INSERT INTO staff VALUES(1114,'Maureen','Joseph','0400000004','MaureenJoseph@aami.com.au','National Manager Industry Relations','Active');
INSERT INTO staff VALUES(1115,'Nick','Addison','0400000005','NickAddison@aami.com.au','Sponsorship Specialist','Active');

CREATE TABLE claim (
    claim_id VARCHAR(20) PRIMARY KEY,
    request_type VARCHAR(50),
    policy_id VARCHAR(50),
    contact_channel VARCHAR(50),
    staff_id INT,
    lodged_date DATE,
    CONSTRAINT claim_staff_fk FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

INSERT INTO claim VALUES('A12','Collision','CAR13102024C11','website',1114,'2025-09-28');
INSERT INTO claim VALUES('A65','BodilyInjury','CAR03072024B81','website',1111,'2025-09-30');
INSERT INTO claim VALUES('B34','Collision','CAR23042025B58','phone',1115,'2025-10-03');
INSERT INTO claim VALUES('C66','Comprehensive','CAR19062023A89','phone',1112,'2025-08-05');
INSERT INTO claim VALUES('D93','Collision','CAR11022023A12','email',1111,'2025-10-06');
INSERT INTO claim VALUES('F74','Collision','CAR21062023A12','email',1112,'2025-10-08');

CREATE TABLE claim_assignment (
    claim_id VARCHAR(20),
    staff_id INT,
    workload_status VARCHAR(20),
    assigned_date DATE,
    unassigned_date DATE,
    CONSTRAINT pk_claim_assignment PRIMARY KEY (claim_id, staff_id, assigned_date),
    CONSTRAINT fk_ca_claim FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
    CONSTRAINT fk_ca_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

INSERT INTO claim_assignment VALUES('A12',1114,'Completed','2025-09-29','2025-10-02');
INSERT INTO claim_assignment VALUES('A65',1111,'Completed','2025-10-01','2025-10-08');
INSERT INTO claim_assignment VALUES('B34',1115,'Assigned','2025-10-04',NULL);
INSERT INTO claim_assignment VALUES('C66',1112,'Completed','2025-08-06','2025-08-09');
INSERT INTO claim_assignment VALUES('D93',1111,'Assigned','2025-10-07',NULL);

--=================================================================================================
-- Select * from TableName Statements
-- Note: SELECT statements for full-table reads written in one line as requested.

-- 2.b.1: Question: Get all the information of all staff stored in the database.
-- 2.b.1: SELECT statement:
SELECT * FROM staff;

-- 2.b.2: Question: Get all the information of all claims stored in the database.
-- 2.b.2: SELECT statement:
SELECT * FROM claim;

-- 2.b.3: Question: Get all the information of all claim assignments stored in the database.
-- 2.b.3: SELECT statement:
SELECT * FROM claim_assignment;

--=================================================================================================
-- 3.a: Question: Count the number of claims per request type and show only types with at least 2 claims.
-- 3.a: SELECT statement using GROUP BY:
SELECT request_type, COUNT(*) AS num FROM claim
GROUP BY request_type
HAVING COUNT(*) >= 2;

-- 3.b: Question: Get all currently active claim assignments, showing each claim’s claim_id, request_type, workload_status, and assigned_date.
-- 3.b: SELECT statement using INNER JOIN:
SELECT c.claim_id, c.request_type, ca.workload_status, ca.assigned_date
FROM claim AS c
INNER JOIN claim_assignment AS ca ON c.claim_id = ca.claim_id
WHERE ca.unassigned_date IS NULL;

-- 3.c: Question: Show assignments that were created on the latest assigned_date in the system.
-- 3.c: SELECT statement using subquery:
SELECT ca.*
FROM claim_assignment ca
WHERE ca.assigned_date = (SELECT MAX(ca2.assigned_date) FROM claim_assignment ca2);

-- 4.a: Average number of assignments per staff
SELECT s.staff_id, s.first_name, COUNT(ca.claim_id) AS total_assignments
FROM staff s
LEFT JOIN claim_assignment ca ON s.staff_id = ca.staff_id
GROUP BY s.staff_id, s.first_name;

-- 4.b: Claims by contact channel
SELECT contact_channel, COUNT(*) AS total_claims
FROM claim
GROUP BY contact_channel;

-- 4.c: Current active assignments by staff
SELECT ca.staff_id, COUNT(*) AS active_assignments
FROM claim_assignment ca
WHERE ca.unassigned_date IS NULL
GROUP BY ca.staff_id
ORDER BY active_assignments DESC;
