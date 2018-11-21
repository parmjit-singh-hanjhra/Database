-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS max_votes CASCADE;
DROP VIEW IF EXISTS winning_parties CASCADE;
DROP VIEW IF EXISTS avg_wins CASCADE;
DROP VIEW IF EXISTS best_avg_parties CASCADE;
DROP VIEW IF EXISTS latest_years CASCADE;
DROP VIEW IF EXISTS latest_election_won CASCADE;
-- Define views for your intermediate steps here.

-- Get the elections of a country with maximum votes
CREATE VIEW max_votes AS
SELECT c.name AS country_name, e.id AS election_id, max(e_r.votes) AS votes
FROM election_result e_r, election e, country c
WHERE (e_r.election_id = e.id) AND (e.country_id = c.id)
GROUP BY c.name, e.id;

-- Matches the party with the maximum votes from max_votes and counts the number of win of that party for each country
CREATE VIEW winning_parties AS
SELECT m_v.country_name AS country_name, e_r.party_id AS party_id, count(*) AS num_wins 
FROM max_votes m_v, election_result e_r
WHERE (m_v.election_id =  e_r.election_id) AND (m_v.votes = e_r.votes)
GROUP BY m_v.country_name, e_r.party_id;

-- Gets the average number of elections won per party at a given country
CREATE VIEW avg_wins AS
SELECT country_name , avg(num_wins) AS avg_wins
FROM winning_parties w_p
GROUP BY country_name;

-- Retrieve the parties that have won more than three times the average number of elections won by the parties
-- in the same country
CREATE VIEW best_avg_parties AS
SELECT w_p.country_name AS country_name, w_p.party_id AS party_id, w_p.num_wins AS num_wins, p_f.family AS family
FROM (winning_parties w_p JOIN avg_wins a_w ON  (w_p.country_name = a_w.country_name)) LEFT JOIN party_family p_f ON (p_f.party_id = w_p.party_id)
WHERE (w_p.num_wins > (3*a_w.avg_wins));

-- Retrieves the latest election of the winning best_avg
CREATE VIEW latest_years AS
SELECT c.name AS country_name, e_r.party_id AS party_id, max(e.e_date) AS most_recent_date
FROM max_votes m_v, election e, election_result e_r, country c
WHERE (m_v.election_id = e.id) AND (e.id = e_r.election_id) AND (e_r.votes = m_v.votes) AND (c.id = e.country_id)
GROUP BY e_r.party_id, c.name;

CREATE VIEW latest_election_won AS
SELECT l_y.country_name AS country_name, l_y.party_id AS party_id, l_y.most_recent_date AS most_recent_date, e.id AS election_id  
FROM latest_years l_y, country c, election e
WHERE (l_y.country_name = c.name) AND (e.country_id = c.id) AND (l_y.most_recent_date = e.e_date);

-- the answer to the query 
insert into q2 

SELECT l_e_w.country_name AS countryName, p.name AS partyName, b_a_p.family AS partyFamily, b_a_p.num_wins AS wonElections,
	   l_e_w.election_id AS mostRecentlyWonElectionId, CAST(DATE_PART('YEAR', l_e_w.most_recent_date) AS INT) AS mostRecentlyWonElectionYear  
FROM ((latest_election_won l_e_w JOIN best_avg_parties b_a_p ON  (l_e_w.party_id = b_a_p.party_id)) JOIN 
party p ON (l_e_w.party_id = p.id));


