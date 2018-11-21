-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS partyInfo CASCADE;
DROP VIEW IF EXISTS Range1 CASCADE;
DROP VIEW IF EXISTS Range2 CASCADE;
DROP VIEW IF EXISTS Range3 CASCADE;
DROP VIEW IF EXISTS Range4 CASCADE;
DROP VIEW IF EXISTS Range5 CASCADE;
DROP VIEW IF EXISTS Result CASCADE;



-- Define views for your intermediate steps here.
-- This view has 3 attributes: the country ID, party ID, and left_right
-- value for every party in the database
CREATE VIEW PartyInfo AS
SELECT country_id, party_id, left_right
FROM party, party_position
WHERE id = party_id;

-- This view stores the countryID and the number
-- of parties in that country with l_r values
-- in the range of [0,2)
CREATE VIEW Range1 AS
SELECT country_id, COUNT(party_id) as r0_2
FROM PartyInfo
WHERE left_right >= 0 AND left_right < 2 AND left_right IS DISTINCT FROM NULL
GROUP BY country_id;

-- This view stores the countryID and the number
-- of parties in that country with l_r values
-- in the range of [2,4)
CREATE VIEW Range2 AS
SELECT country_id, COUNT(party_id) as r2_4
FROM PartyInfo
WHERE left_right >= 2 AND left_right < 4 AND left_right IS DISTINCT FROM NULL
GROUP BY country_id;

-- This view stores the countryID and the number
-- of parties in that country with l_r values
-- in the range of [4,6)
CREATE VIEW Range3 AS
SELECT country_id, COUNT(party_id) as r4_6
FROM PartyInfo
WHERE left_right >= 4 AND left_right < 6 AND left_right IS DISTINCT FROM NULL
GROUP BY country_id;

-- This view stores the countryID and the number
-- of parties in that country with l_r values
-- in the range of [6,8)
CREATE VIEW Range4 AS
SELECT country_id, COUNT(party_id) as r6_8
FROM PartyInfo
WHERE left_right >= 6 AND left_right < 8 AND left_right IS DISTINCT FROM NULL
GROUP BY country_id;

-- This view stores the countryID and the number
-- of parties in that country with l_r values
-- in the range of [8,10)
CREATE VIEW Range5 AS
SELECT country_id, COUNT(party_id) as r8_10
FROM PartyInfo
WHERE left_right >= 8 AND left_right < 10 AND left_right IS DISTINCT FROM NULL
GROUP BY country_id;

CREATE VIEW Result AS
SELECT Range1.country_id, r0_2, r2_4, r4_6, r6_8, r8_10
FROM Range1, Range2, Range3, Range4, Range5
WHERE Range1.country_id = Range2.country_id AND Range1.country_id = Range3.country_id
AND Range1.country_id = Range4.country_id AND Range1.country_id = Range5.country_id;
-- the answer to the query
insert into q4
SELECT name AS countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM country, Result
WHERE country_id = id;

