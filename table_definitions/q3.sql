-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS avg_participation_rate CASCADE;
DROP VIEW IF EXISTS valid_candidates CASCADE;
DROP VIEW IF EXISTS resulting_countries_from_a_p_r CASCADE;
DROP VIEW IF EXISTS resulting_countries_from_v_c CASCADE;
DROP VIEW IF EXISTS final_countries CASCADE;

-- Define views for your intermediate steps here.

-- This view creates the table grouped by with countryName, year and average participation rate
CREATE VIEW avg_participation_rate AS
SELECT country_id, EXTRACT(YEAR FROM e_date) AS year, COALESCE(AVG(votes_cast * 100.0 / electorate), 0) AS avg_participation_rate 
FROM election e
WHERE (EXTRACT(YEAR FROM e_date) BETWEEN 2001 AND 2016) AND electorate IS NOT NULL 
GROUP BY country_id, year;

-- From this view we get the country names with the condition of Y1 < Y2 and avg rate >-= to previouse avg rate (But it considers just pairs not all)
CREATE VIEW valid_candidates AS
SELECT country_id, year, avg_participation_rate
FROM avg_participation_rate a_p_r1
WHERE a_p_r1.avg_participation_rate >= ALL (SELECT a_p_r2.avg_participation_rate
                                            FROM avg_participation_rate a_p_r2 
                                            WHERE a_p_r1.country_id = a_p_r2.country_id AND a_p_r1.year >= a_p_r2.year);

CREATE VIEW resulting_countries_from_a_p_r AS 
SELECT country_id, count(year) AS num_years
FROM avg_participation_rate a_p_r
GROUP BY country_id;

CREATE VIEW resulting_countries_from_v_c AS
SELECT country_id, count(year) AS num_years
FROM valid_candidates
GROUP BY country_id;

CREATE VIEW final_countries AS
SELECT r_c_v_c.country_id AS country_id
FROM resulting_countries_from_v_c r_c_v_c, resulting_countries_from_a_p_r r_c_a_p_r
WHERE r_c_v_c.num_years = r_c_a_p_r.num_years AND r_c_a_p_r.country_id = r_c_v_c.country_id;
 
-- the answer to the query 
insert into q3 

SELECT c.name AS countryName, a_p_r.year AS year, a_p_r.avg_participation_rate AS participationRatio
FROM final_countries f_c, avg_participation_rate a_p_r ,  country c
WHERE f_c.country_id = a_p_r.country_id AND c.id = a_p_r.country_id; 



