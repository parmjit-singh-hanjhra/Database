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
DROP VIEW IF EXISTS num_country_party CASCADE;
DROP VIEW IF EXISTS sum_winning_parties CASCADE;
DROP VIEW IF EXIST\qS avg_wins CASCADE;
DROP VIEW IF EXISTS candidate_parties CASCADE;
DROP VIEW IF EXISTS latest_years CASCADE;
DROP VIEW IF EXISTS latest_election_won CASCADE;


-- Define views for your intermediate steps here.

-- get maximum number of votes for a country at a given election
CREATE VIEW max_votes AS 
SELECT e.country_id AS country_id, e.id AS election_id, MAX(e_r.votes) AS max_votes
FROM election e, election_result e_r
WHERE e.id = e_r.election_id
GROUP BY e.country_id, e.id; 

-- Match the maximum votes from max_votes to the parties' votes and this results in winning parties 
CREATE VIEW winning_parties AS
SELECT m_v.country_id AS country_id, e_r.party_id AS party_id, count(*) AS win_nums
FROM max_votes m_v, election_result e_r 
WHERE (m_v.election_id = e_r.election_id) AND (m_v.max_votes = e_r.votes)
GROUP BY m_v.country_id, e_r.party_id;

-- Gets the number of election run per party in a country
CREATE VIEW num_country_party AS
SELECT e.country_id AS country_id, count(DISTINCT e_r.party_id) AS party_count
FROM election_result e_r, election e
WHERE e_r.election_id = e.id
GROUP BY e.country_id;

-- Sum the winnings of all winning parties in a country
CREATE VIEW sum_winning_parties AS 
SELECT w_p.country_id AS country_id, SUM(win_nums) AS sum_wins
FROM winning_parties w_p
GROUP BY w_p.country_id;

-- Average of winning parties by sum of winning parties divided by the number of parties in a country
CREATE VIEW avg_wins AS 
SELECT n_c_p.country_id AS country_id, s_w_p.sum_wins / n_c_p.party_count AS avg_wins
FROM num_country_party n_c_p, sum_winning_parties s_w_p 
WHERE n_c_p.country_id = s_w_p.country_id;

-- Gets all the winning parties that are greater than 3 times the average winning parties
CREATE VIEW candidate_parties AS
SELECT w_p.country_id AS country_id, w_p.party_id AS party_id, w_p.win_nums AS win_nums, p_f.family AS family
FROM (winning_parties w_p JOIN avg_wins a_w  ON (w_p.country_id = a_w.country_id)) LEFT JOIN party_family p_f ON (p_f.party_id = w_p.party_id)
WHERE (w_p.win_nums > (3 * a_w.avg_wins)); 

-- Retrieves the latest election year of the winning best average parties
CREATE VIEW latest_years AS
SELECT m_v.country_id AS country_id, e_r.party_id AS party_id, max(e.e_date) AS most_recent_date
FROM max_votes m_v, election e, election_result e_r
WHERE (m_v.election_id = e.id) AND (m_v.election_id = e_r.election_id) AND (e_r.votes = m_v.max_votes)
GROUP BY m_v.country_id, e_r.party_id;

-- Retrieves the latest election of the winning best average parties 
CREATE VIEW latest_election_won AS
SELECT l_y.country_id AS country_id, l_y.party_id AS party_id, l_y.most_recent_date AS most_recent_date, e.id AS election_id  
FROM latest_years l_y, election e
WHERE (l_y.most_recent_date = e.e_date) AND (l_y.country_id = e.country_id);


-- the answer to the query 
insert into q2 

SELECT c.name AS countryName, p.name AS partyName, c_p.family AS partyFamily, c_p.win_nums AS wonElections,
           l_e_w.election_id AS mostRecentlyWonElectionId, CAST(DATE_PART('YEAR', l_e_w.most_recent_date) AS INT) AS mostRecentlyWonElectionYear  
FROM ((latest_election_won l_e_w JOIN candidate_parties c_p ON  (l_e_w.party_id = c_p.party_id) JOIN country c ON (c.id = l_e_w.country_id)) JOIN party p ON (l_e_w.party_id = p.id));



