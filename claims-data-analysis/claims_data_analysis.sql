-- Question 1

SELECT COUNT(DISTINCT DESYNPUF_ID) AS total_enrolled
FROM
	(SELECT DESYNPUF_ID
	FROM de1_0_2008_beneficiary_summary_file_sample_1
	
	UNION ALL 
	
	SELECT DESYNPUF_ID
	FROM de1_0_2009_beneficiary_summary_file_sample_1
	
	UNION ALL 
	
	SELECT DESYNPUF_ID
	FROM de1_0_2010_beneficiary_summary_file_sample_1) AS all_beneficiaries;

/*
total_enrolled
116352

There are 116352 total patients enrolled in the Medicare program between 2008 and 2010.
*/

-- Question 2

SELECT COUNT(DISTINCT DESYNPUF_ID) AS enrolled_due_to_age
FROM (
    SELECT DESYNPUF_ID FROM de1_0_2008_beneficiary_summary_file_sample_1 
    WHERE (2007 - YEAR(BENE_BIRTH_DT)) >= 65
    
    UNION ALL 
    
    SELECT DESYNPUF_ID FROM de1_0_2009_beneficiary_summary_file_sample_1 
    WHERE (2008 - YEAR(BENE_BIRTH_DT)) >= 65
    
    UNION ALL 
    
    SELECT DESYNPUF_ID FROM de1_0_2010_beneficiary_summary_file_sample_1 
    WHERE (2009 - YEAR(BENE_BIRTH_DT)) >= 65
) AS above_65;

/*
enrolled_due_to_age
97993

97993 patients who were enrolled in Medicaire between 2008 and 2010 were eligible because of their age (65 and older).
*/


-- Question 3

SELECT COUNT(DISTINCT a.DESYNPUF_ID) AS covered_all_3
FROM de1_0_2008_beneficiary_summary_file_sample_1 AS a 
	JOIN de1_0_2009_beneficiary_summary_file_sample_1 AS b 
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2010_beneficiary_summary_file_sample_1 AS c
	USING (DESYNPUF_ID)
WHERE (2007 - YEAR(a.BENE_BIRTH_DT)) >= 65
  AND a.BENE_HI_CVRAGE_TOT_MONS = 12 AND a.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND b.BENE_HI_CVRAGE_TOT_MONS = 12 AND b.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND c.BENE_HI_CVRAGE_TOT_MONS = 12 AND c.BENE_SMI_CVRAGE_TOT_MONS = 12;

/*
covered_all_3
69371

69371 patients were enrolled because of age and had complete coverage of Medicare Part A and B for all three years, 2008-2010.
*/


-- Question 4

SELECT COUNT(DISTINCT a.DESYNPUF_ID) AS covered_and_alive
FROM de1_0_2008_beneficiary_summary_file_sample_1 AS a 
	JOIN de1_0_2009_beneficiary_summary_file_sample_1 AS b 
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2010_beneficiary_summary_file_sample_1 AS c
	USING (DESYNPUF_ID)
WHERE (2007 - YEAR(a.BENE_BIRTH_DT)) >= 65
  AND a.BENE_HI_CVRAGE_TOT_MONS = 12 AND a.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND b.BENE_HI_CVRAGE_TOT_MONS = 12 AND b.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND c.BENE_HI_CVRAGE_TOT_MONS = 12 AND c.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND c.BENE_DEATH_DT='';

/*
covered_and_alive
68182

68,182 patients were enrolled in Medicare because of age, had complete coverage of Part A and B from 2008-2010, and were alive by the end of 2010.
*/


-- Question 5

SELECT COUNT(DISTINCT a.DESYNPUF_ID) AS covered_alive_suicidal
FROM de1_0_2008_beneficiary_summary_file_sample_1 AS a 
	JOIN de1_0_2009_beneficiary_summary_file_sample_1 AS b 
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2010_beneficiary_summary_file_sample_1 AS c
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2008_to_2010_inpatient_claims_sample_1 AS d 
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2008_to_2010_outpatient_claims_sample_1 AS e 
	USING (DESYNPUF_ID)
WHERE (2007 - YEAR(a.BENE_BIRTH_DT)) >= 65
  AND a.BENE_HI_CVRAGE_TOT_MONS = 12 AND a.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND b.BENE_HI_CVRAGE_TOT_MONS = 12 AND b.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND c.BENE_HI_CVRAGE_TOT_MONS = 12 AND c.BENE_SMI_CVRAGE_TOT_MONS = 12
  AND c.BENE_DEATH_DT=''
  AND 'V6284' IN (d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3, d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7, d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10, e.ICD9_DGNS_CD_1, e.ICD9_DGNS_CD_2, e.ICD9_DGNS_CD_3, e.ICD9_DGNS_CD_4, e.ICD9_DGNS_CD_5, e.ICD9_DGNS_CD_6, e.ICD9_DGNS_CD_7, e.ICD9_DGNS_CD_8, e.ICD9_DGNS_CD_9, e.ICD9_DGNS_CD_10);

/*
covered_alive_suicidal
364

364 patients were enrolled in Medicare becuase of age, had complete coverage of Part A and B from 2008-2010, were alive by the end of 2010, and had a suicidal ideation diagnosis (whether inpatient or outpatient) between 2008 and 2010. 
*/

-- Question 6

CREATE TEMPORARY TABLE index_visits
	SELECT a.DESYNPUF_ID, 
			LEAST(
			    COALESCE(NULLIF(MIN(d.CLM_ADMSN_DT), ''), 20110101),
			    COALESCE(NULLIF(MIN(e.CLM_FROM_DT), ''), 20110101)
			) AS index_date
	FROM de1_0_2008_beneficiary_summary_file_sample_1 AS a 
		JOIN de1_0_2009_beneficiary_summary_file_sample_1 AS b 
		USING (DESYNPUF_ID)
		
		JOIN de1_0_2010_beneficiary_summary_file_sample_1 AS c
		USING (DESYNPUF_ID)
		
		JOIN de1_0_2008_to_2010_inpatient_claims_sample_1 AS d 
		USING (DESYNPUF_ID)
		
		JOIN de1_0_2008_to_2010_outpatient_claims_sample_1 AS e 
		USING (DESYNPUF_ID)
	WHERE (2007 - YEAR(a.BENE_BIRTH_DT)) >= 65
	  AND a.BENE_HI_CVRAGE_TOT_MONS = 12 AND a.BENE_SMI_CVRAGE_TOT_MONS = 12
	  AND b.BENE_HI_CVRAGE_TOT_MONS = 12 AND b.BENE_SMI_CVRAGE_TOT_MONS = 12
	  AND c.BENE_HI_CVRAGE_TOT_MONS = 12 AND c.BENE_SMI_CVRAGE_TOT_MONS = 12
	  AND c.BENE_DEATH_DT=''
	  AND 'V6284' IN (d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3, d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7, d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10, e.ICD9_DGNS_CD_1, e.ICD9_DGNS_CD_2, e.ICD9_DGNS_CD_3, e.ICD9_DGNS_CD_4, e.ICD9_DGNS_CD_5, e.ICD9_DGNS_CD_6, e.ICD9_DGNS_CD_7, e.ICD9_DGNS_CD_8, e.ICD9_DGNS_CD_9, e.ICD9_DGNS_CD_10)
	GROUP BY a.DESYNPUF_ID;

CREATE TEMPORARY TABLE bene_info
	SELECT DISTINCT *
	FROM
		(SELECT DESYNPUF_ID, BENE_BIRTH_DT, BENE_SEX_IDENT_CD, BENE_RACE_CD
		FROM de1_0_2008_beneficiary_summary_file_sample_1
		
		UNION ALL 
		
		SELECT DESYNPUF_ID, BENE_BIRTH_DT, BENE_SEX_IDENT_CD, BENE_RACE_CD
		FROM de1_0_2009_beneficiary_summary_file_sample_1
		
		UNION ALL 
		
		SELECT DESYNPUF_ID, BENE_BIRTH_DT, BENE_SEX_IDENT_CD, BENE_RACE_CD
		FROM de1_0_2010_beneficiary_summary_file_sample_1) AS all_bene;

SELECT AVG(DATEDIFF(index_date, BENE_BIRTH_DT)/365) AS avg_age
FROM index_visits AS a 
	JOIN bene_info AS b 
	USING (DESYNPUF_ID);
	
/*
avg_age
78.79893121

The average age of patients when they are first diagnosed with suicidal ideation is 78.799 years.
*/

SELECT 
	CASE 
		WHEN BENE_SEX_IDENT_CD='1' THEN 'Male'
		WHEN BENE_SEX_IDENT_CD='2' THEN 'Female'
	END AS sex,
	COUNT(a.DESYNPUF_ID) AS num_patients
FROM index_visits AS a 
	JOIN bene_info AS b 
	USING (DESYNPUF_ID)
GROUP BY sex;

/*
sex	num_patients
Female	238
Male	126

Of the cohort of 364 patients who were enrolled in Medicare becuase of age, had complete coverage of Part A and B from 2008-2010, were alive by the end of 2010, and had a suicidal ideation diagnosis (whether inpatient or outpatient) between 2008 and 2010, 238 were female and 126 were male. 
*/

SELECT 
	CASE 
		WHEN BENE_RACE_CD='1' THEN 'White'
		WHEN BENE_RACE_CD='2' THEN 'Black'
		WHEN BENE_RACE_CD='3' THEN 'Others'
		WHEN BENE_RACE_CD='5' THEN 'Hispanic'
	END AS race,
	COUNT(a.DESYNPUF_ID) AS num_patients
FROM index_visits AS a 
	JOIN bene_info AS b 
	USING (DESYNPUF_ID)
GROUP BY race;

/*
race	num_patients
White	321
Others	10
Black	25
Hispanic	8

Of our cohort of 364 suicidal patients, 321 were white, 25 were black, 8 were hispanic, and 10 were categorized in the "Other" race group.

In our cohort generally, there are almost double the amount of females diagnosed as suicidal compared to males. The far majority of our suicidal cohort is white, making up 321 of the 364 patients in the cohort. The average age of our cohort of patients when they are first diagnosed with suicidal ideation is 78.799 years.
*/


-- Question 7

SELECT COUNT(DISTINCT DESYNPUF_ID) AS num_patients_suicide
FROM index_visits AS a 
	JOIN de1_0_2008_to_2010_inpatient_claims_sample_1 AS d 
	USING (DESYNPUF_ID)
	
	JOIN de1_0_2008_to_2010_outpatient_claims_sample_1 AS e 
	USING (DESYNPUF_ID)
WHERE (d.ICD9_DGNS_CD_1 LIKE 'E95__') OR (d.ICD9_DGNS_CD_2 LIKE 'E95__') OR (d.ICD9_DGNS_CD_3 LIKE 'E95__') OR (d.ICD9_DGNS_CD_4 LIKE 'E95__') OR (d.ICD9_DGNS_CD_5 LIKE 'E95__') OR (d.ICD9_DGNS_CD_6 LIKE 'E95__') OR (d.ICD9_DGNS_CD_7 LIKE 'E95__') OR (d.ICD9_DGNS_CD_8 LIKE 'E95__') OR (d.ICD9_DGNS_CD_9 LIKE 'E95__') OR (d.ICD9_DGNS_CD_10 LIKE 'E95__') OR (e.ICD9_DGNS_CD_1 LIKE 'E95__') OR (e.ICD9_DGNS_CD_2 LIKE 'E95__') OR (e.ICD9_DGNS_CD_3 LIKE 'E95__') OR (e.ICD9_DGNS_CD_4 LIKE 'E95__') OR (e.ICD9_DGNS_CD_5 LIKE 'E95__') OR (e.ICD9_DGNS_CD_6 LIKE 'E95__') OR (e.ICD9_DGNS_CD_7 LIKE 'E95__') OR (e.ICD9_DGNS_CD_8 LIKE 'E95__') OR (e.ICD9_DGNS_CD_9 LIKE 'E95__') OR (e.ICD9_DGNS_CD_10 LIKE 'E95__') OR (d.ICD9_DGNS_CD_1 LIKE 'E98__') OR (d.ICD9_DGNS_CD_2 LIKE 'E98__') OR (d.ICD9_DGNS_CD_3 LIKE 'E98__') OR (d.ICD9_DGNS_CD_4 LIKE 'E98__') OR (d.ICD9_DGNS_CD_5 LIKE 'E98__') OR (d.ICD9_DGNS_CD_6 LIKE 'E98__') OR (d.ICD9_DGNS_CD_7 LIKE 'E98__') OR (d.ICD9_DGNS_CD_8 LIKE 'E98__') OR (d.ICD9_DGNS_CD_9 LIKE 'E98__') OR (d.ICD9_DGNS_CD_10 LIKE 'E98__') OR (e.ICD9_DGNS_CD_1 LIKE 'E98__') OR (e.ICD9_DGNS_CD_2 LIKE 'E98__') OR (e.ICD9_DGNS_CD_3 LIKE 'E98__') OR (e.ICD9_DGNS_CD_4 LIKE 'E98__') OR (e.ICD9_DGNS_CD_5 LIKE 'E98__') OR (e.ICD9_DGNS_CD_6 LIKE 'E98__') OR (e.ICD9_DGNS_CD_7 LIKE 'E98__') OR (e.ICD9_DGNS_CD_8 LIKE 'E98__') OR (e.ICD9_DGNS_CD_9 LIKE 'E98__') OR (e.ICD9_DGNS_CD_10 LIKE 'E98__');

/*
num_patients_suicide
15

15 of the patients in this cohort had a suicide attempt diagnosis between 2008 and 2010.
*/
CREATE TEMPORARY TABLE inpatient_suicide
	SELECT DESYNPUF_ID, 
		CASE
			WHEN d.CLM_ADMSN_DT < a.index_date THEN 'Before'
			WHEN d.CLM_ADMSN_DT < d.NCH_BENE_DSCHRG_DT THEN 'During'
			ELSE 'After'
		END AS relative_to_ideation_visit
	FROM index_visits AS a 
		JOIN de1_0_2008_to_2010_inpatient_claims_sample_1 AS d 
		USING (DESYNPUF_ID)
		
		JOIN de1_0_2008_to_2010_outpatient_claims_sample_1 AS e 
		USING (DESYNPUF_ID)
	WHERE (d.ICD9_DGNS_CD_1 LIKE 'E95__') OR (d.ICD9_DGNS_CD_2 LIKE 'E95__') OR (d.ICD9_DGNS_CD_3 LIKE 'E95__') OR (d.ICD9_DGNS_CD_4 LIKE 'E95__') OR (d.ICD9_DGNS_CD_5 LIKE 'E95__') OR (d.ICD9_DGNS_CD_6 LIKE 'E95__') OR (d.ICD9_DGNS_CD_7 LIKE 'E95__') OR (d.ICD9_DGNS_CD_8 LIKE 'E95__') OR (d.ICD9_DGNS_CD_9 LIKE 'E95__') OR (d.ICD9_DGNS_CD_10 LIKE 'E95__') OR (d.ICD9_DGNS_CD_1 LIKE 'E98__') OR (d.ICD9_DGNS_CD_2 LIKE 'E98__') OR (d.ICD9_DGNS_CD_3 LIKE 'E98__') OR (d.ICD9_DGNS_CD_4 LIKE 'E98__') OR (d.ICD9_DGNS_CD_5 LIKE 'E98__') OR (d.ICD9_DGNS_CD_6 LIKE 'E98__') OR (d.ICD9_DGNS_CD_7 LIKE 'E98__') OR (d.ICD9_DGNS_CD_8 LIKE 'E98__') OR (d.ICD9_DGNS_CD_9 LIKE 'E98__') OR (d.ICD9_DGNS_CD_10 LIKE 'E98__');


CREATE TEMPORARY TABLE outpatient_suicide
	SELECT DESYNPUF_ID,
		CASE
			WHEN e.CLM_FROM_DT < a.index_date THEN 'Before'
			WHEN e.CLM_FROM_DT < e.CLM_THRU_DT THEN 'During'
			ELSE 'After'
		END AS relative_to_ideation_visit,
	FROM index_visits AS a 
		JOIN de1_0_2008_to_2010_inpatient_claims_sample_1 AS d 
		USING (DESYNPUF_ID)
		
		JOIN de1_0_2008_to_2010_outpatient_claims_sample_1 AS e 
		USING (DESYNPUF_ID)
	WHERE (e.ICD9_DGNS_CD_1 LIKE 'E95__') OR (e.ICD9_DGNS_CD_2 LIKE 'E95__') OR (e.ICD9_DGNS_CD_3 LIKE 'E95__') OR (e.ICD9_DGNS_CD_4 LIKE 'E95__') OR (e.ICD9_DGNS_CD_5 LIKE 'E95__') OR (e.ICD9_DGNS_CD_6 LIKE 'E95__') OR (e.ICD9_DGNS_CD_7 LIKE 'E95__') OR (e.ICD9_DGNS_CD_8 LIKE 'E95__') OR (e.ICD9_DGNS_CD_9 LIKE 'E95__') OR (e.ICD9_DGNS_CD_10 LIKE 'E95__') OR (e.ICD9_DGNS_CD_1 LIKE 'E98__') OR (e.ICD9_DGNS_CD_2 LIKE 'E98__') OR (e.ICD9_DGNS_CD_3 LIKE 'E98__') OR (e.ICD9_DGNS_CD_4 LIKE 'E98__') OR (e.ICD9_DGNS_CD_5 LIKE 'E98__') OR (e.ICD9_DGNS_CD_6 LIKE 'E98__') OR (e.ICD9_DGNS_CD_7 LIKE 'E98__') OR (e.ICD9_DGNS_CD_8 LIKE 'E98__') OR (e.ICD9_DGNS_CD_9 LIKE 'E98__') OR (e.ICD9_DGNS_CD_10 LIKE 'E98__');

SELECT relative_to_ideation_visit, COUNT(DESYNPUF_ID) as num_patients
FROM 
	((SELECT * FROM inpatient_suicide)
	
	UNION ALL 
	
	(SELECT * FROM outpatient_suicide)) AS grouped_suicide
GROUP BY relative_to_ideation_visit;

/*
relative_to_ideation_visit	num_patients
During	156
After	27

156 of the suicide attempts happened during the visit when they were first diagnosed for suicidal ideations and 27 happened after. 

*/

ALTER TABLE inpatient_suicide ADD COLUMN type VARCHAR(10);
ALTER TABLE outpatient_suicide ADD COLUMN type VARCHAR(10);

UPDATE inpatient_suicide
SET type= 'inpatient';

UPDATE outpatient_suicide
SET type= 'outpatient';


SELECT type, COUNT(DESYNPUF_ID) AS num_suicide_attempt_visits
FROM
	((SELECT * FROM inpatient_suicide)
	
	UNION ALL 
	
	(SELECT * FROM outpatient_suicide)) as grouped_suicide
WHERE relative_to_ideation_visit='After'
GROUP BY type;

/*
type	num_suicide_attempt_visits
outpatient	27

All 27 suicide attempt visits that happened after the indexed suicidal ideation visit were outpatient visits.

*/

SELECT COUNT(DISTINCT DESYNPUF_ID) AS chronicly_depressed
FROM
	((SELECT * FROM inpatient_suicide)
	
	UNION ALL 
	
	(SELECT * FROM outpatient_suicide)) as grouped_suicide
	
	JOIN de1_0_2008_beneficiary_summary_file_sample_1 AS b 
	USING (DESYNPUF_ID)
WHERE relative_to_ideation_visit='After'
	AND b.SP_DEPRESSN='1';

/* 
chronicly_depressed
5

Of those whose suicide attempt happened after the index visit, 5 were chronically depressed in 2008.
*/