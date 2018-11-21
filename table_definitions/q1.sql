-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
-- DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW election_year_format AS
SELECT CAST(DATE_PART('YEAR', e.e_date) AS INT) AS e_date, country_id, id, votes_valid 
FROM election e;

CREATE FUNCTION range(v real) RETURNS VARCHAR(20) AS $$
BEGIN 
	IF (v > 0  AND v <= 5) THEN RETURN '(0,5]';
	ELSIF (v > 5  AND v <= 10) THEN RETURN '(5,10]'; 
	ELSIF (v > 10  AND v <= 20) THEN RETURN '(10,20]';
	ELSIF (v > 20  AND v <= 30) THEN RETURN '(20,30]';
	ELSIF (v > 30  AND v <= 40) THEN RETURN '(30,40]';
	ELSIF (v > 40  AND v <= 100) THEN RETURN '(40,100]';
	ELSE RETURN NULL;
	END IF;
END $$ LANGUAGE plpgsql;

-- the answer to the query 
insert into q1 
SELECT c.name, p.name_short, e.e_date, range(avg(e_r.votes * 100.0 / e.votes_valid)) 
FROM country c, election_year_format e, election_result e_r, party p
WHERE (c.id = e.country_id) AND (e.id = e_r.election_id) AND (e_r.party_id = p.id) AND (e.e_date BETWEEN 1996 AND 2016) and (c.name = 'Germany')
GROUP BY c.name, p.name_short, e.e_date;


