-- =====================================
-- SCHEMA AND TABLE SETUP: EMPLOYEES + EMPLOYMENT_HISTORY
-- =====================================
CREATE SCHEMA workforce;
USE workforce;

-- ============================
-- EMPLOYEES TABLE (FIXED ORDER)
-- ============================
CREATE TABLE employees (
    employee_id SMALLINT UNSIGNED AUTO_INCREMENT,
    PRIMARY KEY (employee_id),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    gender VARCHAR(1),
    age TINYINT UNSIGNED,
    nationality VARCHAR(45),
    job_network VARCHAR(45),
    job_family VARCHAR(45),
    functional_title VARCHAR(45),
    grade VARCHAR(5),
    employment_type VARCHAR(10),
    spa_grade VARCHAR(10),
    manager_id SMALLINT UNSIGNED,
    training_completed VARCHAR(1),
    leadership_program_completed VARCHAR(1)
);

-- ==================================
-- INDEX: Index Job Family, as it will be used often in later queries.
-- ==================================
CREATE INDEX idx_job_family
	ON employees(job_family);

-- ==================================
-- TRIGGER: Validate age in employees
-- ==================================
DELIMITER //

CREATE TRIGGER trg_check_age
	BEFORE INSERT ON employees
	FOR EACH ROW
BEGIN
  IF NEW.age < 18 OR NEW.age > 75 THEN
    SIGNAL SQLSTATE 'HY000' 
    SET MESSAGE_TEXT = 'Age must be between 18 and 75';
  END IF;
  
END //

DELIMITER ;




-- ====================================
-- TRIGGER: Validate grade in employees
-- ====================================
DELIMITER //

CREATE TRIGGER grade
	BEFORE INSERT ON employees
	FOR EACH ROW
BEGIN
	IF NEW.grade NOT IN ('P-1','P-2','P-3','P-4','P-5','D-1','D-2','G-1','G-2','G-3','G-4','G-5','G-6','G-7','NO-A','NO-B','NO-C','NO-D','FS-1','FS-2','FS-3','FS-4','FS-5','FS-6', NULL) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Insert a valid grade: P1 to P-5, D-1 to D-2, G-1 to G-7, NO-A to NO-D, FS-1 to FS-7, or NULL';
	END IF;
    
END //

DELIMITER ;



-- =========================================
-- TRIGGER: Validate SPA grade in employees
-- =========================================
DELIMITER //

CREATE TRIGGER spa_grade
	BEFORE INSERT ON employees
	FOR EACH ROW
BEGIN
	IF NEW.spa_grade NOT IN ('SPA1','SPA2','SPA3','SPA4','SPA5',NULL) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Insert a valid spa grade: SPA1 through SPA5, or NULL';
	END IF;
    
END //

DELIMITER ;


-- =================================================
-- TRIGGER: Validate training completed in employees
-- =================================================
DELIMITER //

CREATE TRIGGER training_completed
	BEFORE INSERT ON employees
	FOR EACH ROW
BEGIN
	IF NEW.training_completed NOT IN ('Y','N',NULL) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Insert a valid training_completed response: Y, N, or NULL';
	END IF;
    
END //

DELIMITER ;


-- ==========================================================
-- TRIGGER: Validate leadership program completed in employees
-- ===========================================================
DELIMITER //

CREATE TRIGGER leadership_program_completed
	BEFORE INSERT ON employees
	FOR EACH ROW
BEGIN
	IF NEW.leadership_program_completed NOT IN ('Y','N',NULL) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Insert a valid leadership_program_completed response: Y, N, or NULL';
	END IF;
    
END //
DELIMITER ;


-- ==========================================
-- 1st CHILD TABLE: EMPLOYMENT_HISTORY TABLE
-- ===========================================
CREATE TABLE employment_history (
	PRIMARY KEY (employee_id, entry_on_duty),
    employee_id SMALLINT UNSIGNED, 
    entry_on_duty DATE,
    appointment_expiry_date DATE,
    retirement_date DATE,
    appointment_type VARCHAR(25),
    position_type VARCHAR(10),
    promotion_status VARCHAR(1),
    promotion_year YEAR,
    new_grade VARCHAR(10),
    resignation_reason VARCHAR(25),
    retention_flag TINYINT UNSIGNED,
    turnover_flag TINYINT UNSIGNED,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);


-- ================================================================
-- TRIGGER: Ensure entry_on_duty is before appointment_expiry_date
-- ================================================================
DELIMITER //

CREATE TRIGGER appointment_expiry
	BEFORE INSERT ON employment_history
	FOR EACH ROW
BEGIN
	IF NEW.appointment_expiry_date IS NOT NULL AND NEW.appointment_expiry_date < NEW.entry_on_duty THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'entry_on_duty must be before appointment_expiry_date.';
	END IF;
    
END //

DELIMITER ;



-- =============================================================================================================
-- TRIGGER: Ensure retirement date exists (and is after entry on duty Date) if resignation reason is retirement.
-- =============================================================================================================
DELIMITER //

CREATE TRIGGER retirement
	BEFORE INSERT ON employment_history
	FOR EACH ROW
BEGIN
	IF NEW.resignation_reason='Retirement' AND (NEW.retirement_date IS NULL OR NEW.retirement_date<NEW.entry_on_duty) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'If Resignation Reason is Retirement, Retirement date must be a date after entry on duty date.';
	END IF;
    
END //

DELIMITER ;


-- ================================================================
-- TRIGGER: Ensure promotion year is after entry and not in future
-- ================================================================
DELIMITER //

CREATE TRIGGER promotion
	BEFORE INSERT ON employment_history
	FOR EACH ROW
BEGIN
	IF NEW.promotion_status='Y' AND (NEW.promotion_year IS NULL OR NEW.promotion_year<YEAR(NEW.entry_on_duty) OR NEW.promotion_year > YEAR(CURDATE())) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'If promotion Status is Y, promotion Year must be some year after the entry year, but not in the future.';
	END IF;
    
END //

DELIMITER ;


-- ==========================================
-- TRIGGER: Ensure new grade score is valid
-- ==========================================
DELIMITER //

CREATE TRIGGER new_grade
	BEFORE INSERT ON employment_history
	FOR EACH ROW
BEGIN
	IF NEW.new_grade NOT IN ('P-1','P-2','P-3','P-4','P-5','D-1','D-2','G-1','G-2','G-3','G-4','G-5','G-6','G-7','NO-A','NO-B','NO-C','NO-D','FS-1','FS-2','FS-3','FS-4','FS-5','FS-6', NULL) THEN
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Insert a valid new grade: P1 to P-5, D-1 to D-2, G-1 to G-7, NO-A to NO-D, FS-1 to FS-7, or NULL';
	END IF;
    
END //

DELIMITER ;


-- ==================================
-- 2nd CHILD TABLE: wellness_tracking
-- ==================================
CREATE TABLE wellness_tracking (
	PRIMARY KEY (employee_id, record_date),
    employee_id SMALLINT UNSIGNED,
    record_date DATE NOT NULL, -- First day of the reporting month
    sick_days_taken TINYINT,
    burnout_score TINYINT,
    overtime_hours DECIMAL(5,2),
    remote_work_days TINYINT,
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE INDEX idx_record_date
	ON wellness_tracking(record_date);

CREATE INDEX idx_burnout_score
	ON wellness_tracking(burnout_score);

CREATE INDEX idx_sick_days_taken
	ON wellness_tracking(sick_days_taken);
    
CREATE INDEX idx_overtime_hours
	ON wellness_tracking(overtime_hours);
    
-- ===============================================
-- TRIGGER: Validate burnout_score between 1 and 5
-- ===============================================
DELIMITER //

CREATE TRIGGER burnout_score           # name of trigger
	BEFORE INSERT ON wellness_tracking   # which table is it being applied to 
	FOR EACH ROW
BEGIN
	IF NEW.burnout_score < 1 OR NEW.burnout_score > 5 THEN   # condition that would trigger the error
		SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT = 'Burnout Score must be between 1 and 5';   ## custom warning message
	END IF;   # can add multiple IF END IF blocks for multiple rules
	
END //

DELIMITER ;


-- ==================================================
-- TRIGGER: Validate sick_days and remote_work_days (Leap-year aware)
-- ================================================== 
DELIMITER //

CREATE TRIGGER trg_check_wellness_values
	BEFORE INSERT ON wellness_tracking
	FOR EACH ROW
BEGIN
  -- Validate remote_work_days and sick_days_taken with leap-year and calendar logic
  IF NEW.remote_work_days < 0 OR
     (MONTH(NEW.record_date) = 2 AND 
       (((YEAR(NEW.record_date) % 4 != 0) OR (YEAR(NEW.record_date) % 100 = 0 AND YEAR(NEW.record_date) % 400 != 0))
         AND NEW.remote_work_days > 28)) OR
     (MONTH(NEW.record_date) = 2 AND 
       ((YEAR(NEW.record_date) % 4 = 0 AND YEAR(NEW.record_date) % 100 != 0) OR (YEAR(NEW.record_date) % 400 = 0))
       AND NEW.remote_work_days > 29) OR
     (MONTH(NEW.record_date) IN (4, 6, 9, 11) AND NEW.remote_work_days > 30) OR
     (MONTH(NEW.record_date) IN (1, 3, 5, 7, 8, 10, 12) AND NEW.remote_work_days > 31) THEN
		SIGNAL SQLSTATE 'HY000' 
		SET MESSAGE_TEXT = 'remote_work_days exceeds valid days in month';
  END IF;

  IF NEW.sick_days_taken < 0 OR
     (MONTH(NEW.record_date) = 2 AND 
       (((YEAR(NEW.record_date) % 4 != 0) OR (YEAR(NEW.record_date) % 100 = 0 AND YEAR(NEW.record_date) % 400 != 0))
         AND NEW.sick_days_taken > 28)) OR
     (MONTH(NEW.record_date) = 2 AND 
       ((YEAR(NEW.record_date) % 4 = 0 AND YEAR(NEW.record_date) % 100 != 0) OR (YEAR(NEW.record_date) % 400 = 0))
       AND NEW.sick_days_taken > 29) OR
     (MONTH(NEW.record_date) IN (4, 6, 9, 11) AND NEW.sick_days_taken > 30) OR
     (MONTH(NEW.record_date) IN (1, 3, 5, 7, 8, 10, 12) AND NEW.sick_days_taken > 31) THEN
		SIGNAL SQLSTATE 'HY000' 
        SET MESSAGE_TEXT = 'sick_days_taken exceeds valid days in month';
  END IF;
END //

DELIMITER ;


-- ==================================
-- employees: Data Input
-- ==================================
-- Insert statements with consistent employee_id and manager_id relationships
INSERT INTO workforce.employees (
    employee_id, first_name, last_name, gender, age, nationality, job_network, job_family,
    functional_title, grade, employment_type, spa_grade, manager_id,
    training_completed, leadership_program_completed
) VALUES
(1, 'Amelia', 'Jones', 'F', 34, 'USA', 'Clinical', 'Nursing', 'Registered Nurse', 'P-2', 'Full-Time', NULL, NULL, 'Y', 'N'),
(2, 'Brian', 'Lopez', 'M', 46, 'Mexico', 'Medical', 'Surgery', 'Surgeon', 'D-1', 'Full-Time', NULL, 1, 'Y', 'Y'),
(3, 'Chloe', 'Nguyen', 'F', 28, 'Vietnam', 'Clinical', 'Pharmacy', 'Clinical Pharmacist', 'P-2', 'Full-Time', NULL, 1, 'Y', 'N'),
(4, 'David', 'Patel', 'M', 39, 'India', 'Public Health', 'Epidemiology', 'Epidemiologist', 'P-3', 'Full-Time', NULL, 1, 'Y', 'Y'),
(5, 'Elena', 'Smith', 'F', 30, 'USA', 'Clinical', 'Nursing', 'Nurse Practitioner', 'P-3', 'Full-Time', NULL, 1, 'Y', 'Y'),
(6, 'Felix', 'Garcia', 'M', 42, 'Spain', 'Medical', 'Radiology', 'Radiologist', 'P-5', 'Full-Time', NULL, 2, 'N', 'Y'),
(7, 'Grace', 'Kim', 'F', 31, 'South Korea', 'Admin', 'Medical Records', 'Records Technician', 'G-4', 'Full-Time', NULL, 10, 'Y', 'N'),
(8, 'Henry', 'Zhang', 'M', 45, 'China', 'IT', 'Support', 'Health IT Specialist', 'P-2', 'Full-Time', NULL, 10, 'Y', 'N'),
(9, 'Isabella', 'Brown', 'F', 37, 'UK', 'Admin', 'Billing', 'Medical Billing Specialist', 'G-5', 'Part-Time', NULL, 10, 'Y', 'N'),
(10, 'Jacob', 'Wilson', 'M', 50, 'USA', 'Admin', 'Finance', 'Healthcare Accountant', 'P-4', 'Full-Time', NULL, 20, 'Y', 'Y'),
(11, 'Karen', 'Adams', 'F', 33, 'USA', 'Public Health', 'Community Health', 'Health Educator', 'P-2', 'Full-Time', NULL, 4, 'Y', 'N'),
(12, 'Leo', 'Chen', 'M', 29, 'Taiwan', 'Clinical', 'Pharmacy', 'Pharmacy Technician', 'G-3', 'Consultant', 'SPA2', 3, 'Y', 'N'),
(13, 'Maria', 'Gonzalez', 'F', 41, 'Argentina', 'Medical', 'Internal Medicine', 'Physician', 'P-5', 'Full-Time', NULL, 2, 'Y', 'Y'),
(14, 'Nathan', 'Lee', 'M', 35, 'South Korea', 'Clinical', 'Lab', 'Medical Lab Technologist', 'P-2', 'Full-Time', NULL, 6, 'Y', 'N'),
(15, 'Olivia', 'Martins', 'F', 36, 'Portugal', 'Admin', 'Human Resources', 'HR Coordinator', 'P-2', 'Part-Time', NULL, 10, 'Y', 'Y'),
(16, 'Paul', 'Thomas', 'M', 44, 'USA', 'IT', 'Systems', 'EHR Systems Analyst', 'P-3', 'Full-Time', NULL, 8, 'Y', 'N'),
(17, 'Quinn', 'Ali', 'F', 38, 'Pakistan', 'Public Health', 'Research', 'Public Health Researcher', 'P-4', 'Full-Time', NULL, 4, 'Y', 'Y'),
(18, 'Ravi', 'Singh', 'M', 40, 'India', 'Clinical', 'Nursing', 'Charge Nurse', 'P-4', 'Full-Time', NULL, 1, 'Y', 'Y'),
(19, 'Sophia', 'Davis', 'F', 26, 'USA', 'Clinical', 'Nursing', 'Licensed Practical Nurse', 'G-5', 'Consultant', 'SPA1', 18, 'Y', 'N'),
(20, 'Thomas', 'White', 'M', 48, 'USA', 'Admin', 'Leadership', 'Hospital Administrator', 'D-2', 'Full-Time', NULL, NULL, 'Y', 'Y');


INSERT INTO workforce.employment_history (
    employee_id, entry_on_duty, appointment_expiry_date, retirement_date,
    appointment_type, position_type, promotion_status, promotion_year,
    new_grade, resignation_reason, retention_flag, turnover_flag
) VALUES
(1, '2015-06-15', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2019, 'P-2', NULL, 1, 0),
(2, '2010-03-10', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2016, 'D-1', NULL, 1, 0),
(3, '2019-09-01', NULL, NULL, 'Initial', 'Full-Time', 'N', NULL, NULL, NULL, 1, 0),
(4, '2012-01-01', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2018, 'P-3', NULL, 1, 0),
(5, '2016-05-23', NULL, NULL, 'Renewal', 'Full-Time', 'Y', 2020, 'P-3', NULL, 1, 0),
(6, '2008-10-10', NULL, '2024-12-31', 'Initial', 'Full-Time', 'Y', 2013, 'P-5', 'Retirement', 0, 1),
(7, '2017-08-14', NULL, NULL, 'Initial', 'Full-Time', 'N', NULL, NULL, NULL, 1, 0),
(8, '2014-11-05', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2021, 'P-2', NULL, 1, 0),
(9, '2021-03-10', '2023-03-10', NULL, 'Temporary Assignment', 'Part-Time', 'N', NULL, NULL, 'Voluntary', 0, 1),
(10, '2010-02-01', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2015, 'P-4', NULL, 1, 0),
(11, '2018-04-02', NULL, NULL, 'Initial', 'Full-Time', 'N', NULL, NULL, NULL, 1, 0),
(12, '2023-01-15', '2024-12-31', NULL, 'Temporary Assignment', 'Consultant', 'N', NULL, NULL, NULL, 1, 0),
(13, '2011-06-25', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2017, 'P-5', NULL, 1, 0),
(14, '2020-07-18', NULL, NULL, 'Initial', 'Full-Time', 'N', NULL, NULL, NULL, 1, 0),
(15, '2022-09-30', NULL, NULL, 'Initial', 'Part-Time', 'N', NULL, NULL, NULL, 1, 0),
(16, '2016-03-12', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2021, 'P-3', NULL, 1, 0),
(17, '2013-10-20', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2019, 'P-4', NULL, 1, 0),
(18, '2010-01-01', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2015, 'P-4', NULL, 1, 0),
(19, '2023-04-01', '2024-04-01', NULL, 'Temporary Assignment', 'Consultant', 'N', NULL, NULL, 'Burnout', 0, 1),
(20, '2005-07-01', NULL, NULL, 'Initial', 'Full-Time', 'Y', 2010, 'D-2', NULL, 1, 0),
-- Additional rows for promotions/renewals
(1, '2019-07-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-2', NULL, 1, 0),
(2, '2016-04-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'D-1', NULL, 1, 0),
(4, '2018-05-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-3', NULL, 1, 0),
(5, '2020-06-15', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-3', NULL, 1, 0),
(6, '2013-01-01', NULL, '2024-12-31', 'Renewal', 'Full-Time', 'N', NULL, 'P-5', 'Retirement', 0, 1),
(8, '2021-08-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-2', NULL, 1, 0),
(10, '2015-03-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-4', NULL, 1, 0),
(13, '2017-07-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-5', NULL, 1, 0),
(16, '2021-04-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-3', NULL, 1, 0),
(17, '2019-11-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-4', NULL, 1, 0),
(18, '2015-02-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'P-4', NULL, 1, 0),
(20, '2010-09-01', NULL, NULL, 'Renewal', 'Full-Time', 'N', NULL, 'D-2', NULL, 1, 0);

-- Assumes Employee_IDs 1 through 5 exist in Employee table
INSERT INTO workforce.wellness_tracking VALUES
(1, '2024-01-01', 2, 3, 5.5, 2, 'Normal workload'),
(1, '2024-02-01', 0, 4, 7.0, 3, 'Overtime increasing'),
(2, '2024-01-01', 1, 2, 3.0, 4, 'Seems fine'),
(2, '2024-02-01', 4, 5, 8.5, 1, 'Burnout risk'),
(3, '2024-01-01', 0, 1, 1.0, 5, 'High remote engagement'),
(3, '2024-02-01', 1, 2, 2.0, 5, 'Consistent wellness'),
(4, '2024-01-01', 3, 4, 6.0, 1, 'Heavy workload'),
(5, '2024-01-01', 0, 3, 0.0, 0, NULL),
(4, '2024-02-01', 2, 5, 7.0, 2, 'Burnout rising'),
(5, '2024-02-01', 0, 2, 1.5, 0, 'Improving'),
(1, '2024-03-01', 1, 3, 6.0, 3, 'Steady'),
(2, '2024-03-01', 2, 4, 5.5, 2, 'Still high load'),
(3, '2024-03-01', 0, 2, 2.5, 5, 'Stable'),
(4, '2024-03-01', 1, 5, 7.5, 1, 'Red flag'),
(5, '2024-03-01', 0, 3, 2.0, 0, 'Okay'),
(1, '2024-04-01', 0, 2, 4.0, 3, 'Better'),
(2, '2024-04-01', 3, 4, 6.0, 2, 'Holding steady'),
(3, '2024-04-01', 1, 2, 2.0, 5, NULL),
(4, '2024-04-01', 2, 4, 6.5, 1, 'Monitoring'),
(5, '2024-04-01', 1, 2, 1.0, 0, 'Low stress');


-- ============================
-- LOOKUP TABLE: Job_Categories
-- ============================
CREATE TABLE job_categories (
	PRIMARY KEY (job_family_id),
    job_family_id INT AUTO_INCREMENT,
    job_family VARCHAR(100) NOT NULL,
    job_network VARCHAR(100) NOT NULL,
    job_description VARCHAR(100)	
);

SET GLOBAL local_infile = true;

LOAD DATA LOCAL INFILE 'C:/Users/yaeli/OneDrive/Documents/Data Management SQL/Final Project/group11_lookup_data.csv'
INTO TABLE job_categories
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(job_family, job_network, job_description);


-- ------------------------------------------------------
-- Query 1: View (with Join)
-- Purpose: Combine wellness metrics with employee attributes.
-- Why: Enables multi-dimensional wellness analysis across job characteristics.
-- ------------------------------------------------------
CREATE VIEW workforce.view_employee_wellness AS
SELECT 
  w.employee_id AS employee_id,
  w.record_date AS record_date,
  w.burnout_score AS burnout_score,
  w.sick_days_taken AS sick_days_taken,
  w.overtime_hours AS overtime_hours,
  w.remote_work_days AS remote_work_days,
  e.job_family AS job_family,
  e.functional_title AS functional_title,
  e.grade AS grade,
  e.age AS age,
  e.nationality AS nationality
FROM workforce.wellness_tracking AS w
	JOIN workforce.employees AS e 
    ON w.employee_id = e.employee_id;
    
-- ------------------------------------------------------
-- Query 2: Temporary Table (with Join)
-- Purpose: Store average burnout by job family temporarily.
-- Why: Helps with real-time, session-based reporting on wellness.
-- ------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_avg_burnout_by_family;
CREATE TEMPORARY TABLE temp_avg_burnout_by_family AS
SELECT 
  c.job_family AS job_family,
  AVG(w.burnout_score) AS avg_burnout_score
FROM workforce.wellness_tracking AS w
	JOIN workforce.employees AS e 
    ON w.employee_id = e.employee_id

	JOIN workforce.job_categories AS c 
    ON LOWER(TRIM(e.job_family)) = LOWER(TRIM(c.job_family))
GROUP BY c.job_family;

SELECT * FROM temp_avg_burnout_by_family;



-- =====================================================
-- Query 3: Sick Days Flag vs. Personal Average
-- Purpose: Identify employees who exceeded their average
--          sick days in any given month.
-- Why: Highlights possible health concerns or absenteeism patterns.
-- =====================================================
SELECT 
  employee_id,
  record_date,
  sick_days_taken,
  AVG(sick_days_taken) OVER (PARTITION BY employee_id) AS avg_sick_days,
  CASE 
    WHEN sick_days_taken > AVG(sick_days_taken) OVER (PARTITION BY employee_id)
    THEN 'Above Average'
    ELSE 'Normal or Below'
  END AS sick_days_flag
FROM workforce.wellness_tracking;

-- ------------------------------------------------------
-- Query 4: Pivot
-- Purpose: View burnout score across months per employee.
-- Why: Tracks monthly wellness fluctuations.
-- ------------------------------------------------------
SELECT 
  employee_id AS employee_id,
  MAX(CASE WHEN record_date = '2024-01-01' THEN burnout_score END) AS burnout_jan,
  MAX(CASE WHEN record_date = '2024-02-01' THEN burnout_score END) AS burnout_feb,
  MAX(CASE WHEN record_date = '2024-03-01' THEN burnout_score END) AS burnout_mar,
  MAX(CASE WHEN record_date = '2024-04-01' THEN burnout_score END) AS burnout_apr
FROM workforce.wellness_tracking
GROUP BY employee_id;

-- ------------------------------------------------------
-- Query 5: Self-Join
-- Purpose: Compare burnout score across consecutive months.
-- Why: Detects short-term changes in employee stress.
-- ------------------------------------------------------
SELECT 
  w1.employee_id AS employee_id,
  w1.record_date AS previous_month,
  w2.record_date AS current_month,
  w1.burnout_score AS previous_score,
  w2.burnout_score AS current_score,
  (w2.burnout_score - w1.burnout_score) AS change_in_score
FROM workforce.wellness_tracking AS w1
	JOIN workforce.wellness_tracking AS w2 
	ON w1.employee_id = w2.employee_id
		AND PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM w2.record_date), EXTRACT(YEAR_MONTH FROM w1.record_date)) = 1;

-- ------------------------------------------------------
-- Query 6: Subquery (with Ties)
-- Purpose: Return employee(s) with the highest burnout sum.
-- Why: Finds most at-risk employees.
-- ------------------------------------------------------
SELECT employee_id, total_burnout
FROM (
  SELECT 
    employee_id AS employee_id,
    SUM(burnout_score) AS total_burnout
  FROM workforce.wellness_tracking
  GROUP BY employee_id
) AS summary
WHERE total_burnout = (
  SELECT MAX(total_burnout)
  FROM (
    SELECT SUM(burnout_score) AS total_burnout
    FROM workforce.wellness_tracking
    GROUP BY employee_id
  ) AS subquery
);

-- ============================================================
-- Query 7: UNION ALL
-- Purpose: Combine employees with 0 sick days (possible presenteeism)
-- and those with maximum burnout score (wellness red flag).
-- Why we used UNION ALL: Some employees may meet both criteria in different
-- months or even the same one — we want to include all records without removing duplicates.
-- ============================================================

SELECT employee_id, record_date, 'Zero Sick Days' AS flag
FROM workforce.wellness_tracking
WHERE sick_days_taken = 0

UNION ALL

SELECT employee_id, record_date, 'Max Burnout' AS flag
FROM workforce.wellness_tracking
WHERE burnout_score = 10;

-- ------------------------------------------------------
-- Query 8: OVER() with CASE
-- Purpose: Identify short-term workload spikes for targeted wellness checks
-- Why we used OVER(PARTITION BY): It calculates each employee’s average overtime
-- across all months so we can compare each monthly value to the personal average.
-- ------------------------------------------------------
SELECT 
  employee_id AS employee_id,
  record_date AS record_date,
  overtime_hours AS overtime_hours,
  AVG(overtime_hours) OVER (PARTITION BY employee_id) AS avg_overtime,
  CASE 
    WHEN overtime_hours > AVG(overtime_hours) OVER (PARTITION BY employee_id)
    THEN 'Above Average'
    ELSE 'Normal or Below'
  END AS overtime_flag
FROM workforce.wellness_tracking;

-- ------------------------------------------------------
-- Query 9: RANK()
-- Purpose: Rank burnout scores within each employee's timeline.
-- Why we used RANK(): We want to know the highest burnout periods, and RANK()
-- handles ties appropriately (e.g., two top scores both get rank 1).
-- ------------------------------------------------------
SELECT 
  employee_id AS employee_id,
  record_date AS record_date,
  burnout_score AS burnout_score,
  RANK() OVER (PARTITION BY employee_id ORDER BY burnout_score DESC) AS stress_rank
FROM workforce.wellness_tracking;

-- ============================================================
-- Query 10: Which job networks have highest burnout on average?
-- Purpose: Compare burnout across networks using a pre-joined CTE.
-- Why: Helps leadership target burnout-heavy domains.
-- Answer: Returns average burnout per job_network.
-- ============================================================
WITH burnout_network_cte AS (
  SELECT 
    e.employee_id,
    c.job_network,
    w.burnout_score
  FROM workforce.employees AS e
	JOIN workforce.job_categories AS c 
    ON LOWER(TRIM(e.job_family)) = LOWER(TRIM(c.job_family))
		AND LOWER(TRIM(e.job_network)) = LOWER(TRIM(c.job_network))
	JOIN workforce.wellness_tracking AS w 
    ON e.employee_id = w.employee_id
)
SELECT 
  job_network,
  AVG(burnout_score) AS avg_burnout_score
FROM burnout_network_cte
GROUP BY job_network;
