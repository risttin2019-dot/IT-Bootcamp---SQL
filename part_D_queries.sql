-- 1. zadatak

-- Korak A

CREATE TABLE dim_team AS
SELECT DISTINCT
    team_id,
    team_name,
    short_name,
    city,
    founded_year,
    stadium_id
FROM bootcamp.northern_star.teams;


-- Korak B

CREATE OR REPLACE TABLE dim_date AS
SELECT CAST(DATE_FORMAT(d, 'yyyyMMdd') AS INT) AS date_key,
       d                                       AS full_date,
       DATE_FORMAT(d, 'EEEE')                  AS weekday_name,
       DAYOFWEEK(d) IN (1, 7)                  AS is_weekend,
       CASE WHEN MONTH(d) >= 7 THEN CONCAT(YEAR(d), '/', SUBSTRING(CAST(YEAR(d) + 1 AS STRING), 3, 2))
            ELSE CONCAT(YEAR(d) - 1, '/', SUBSTRING(CAST(YEAR(d) AS STRING), 3, 2))
       END                                     AS season
FROM (SELECT EXPLODE(SEQUENCE(DATE'2023-07-01', DATE'2025-06-30', INTERVAL 1 DAY)) AS d);


-- Korak C

CREATE OR REPLACE TABLE dim_player
SELECT DISTINCT
    player_id,
    first_name,
    last_name,
    known_as,
    birth_date,
    nationality,
    position,
    preferred_foot,
    height_cm
FROM bootcamp.northern_star.players
UNION 
SELECT -1, 
    'Unknown',
    'Unknown',
    'Unknown',
    '9999-12-31',
    'Unknown',
    'Unknown',
    'Unknown',
    '999';


-- Korak D

CREATE TABLE dim_referee AS
SELECT DISTINCT
    referee_id,
    referee_name,
    nationality,
    debut_season
FROM bootcamp.northern_star.referees;


-- Korak E

CREATE TABLE fact_card AS
SELECT 
    me.event_id,
    me.match_id,
    CAST(DATE_FORMAT(m.kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
    me.team_id,
    CASE 
        WHEN p.player_id IS NOT NULL THEN me.player_id 
        ELSE -1 
    END AS player_id,
    m.referee_id,
    me.event_type AS card_type
FROM match_events me
INNER JOIN matches m ON m.match_id = me.match_id
LEFT JOIN players p ON p.player_id = me.player_id
WHERE me.event_type IN ('yellow_card', 'second_yellow', 'red_card');


-- 2. zadatak

SELECT 
    COUNT(*) AS row_num
FROM fact_card;

SELECT 
    COUNT(*) AS card_num 
FROM match_events 
WHERE event_type IN ('yellow_card', 'second_yellow', 'red_card');

-- D2 = Oba upita izbacuju po 2678 redova.


-- 3. zadatak

SELECT
    COUNT(*) AS unknown_player_cards
FROM fact_card
WHERE player_id = -1;

-- D3 = 2 kartona