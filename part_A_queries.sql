-- 1. zadatak

SELECT
    COUNT(*)
FROM matches
WHERE kickoff_ts >= '2025-02-01 00:00:00' AND kickoff_ts < '2025-03-01 00:00:00';

-- A1 = 40


-- 2. zadatak

SELECT
    s.stadium_name,
    s.capacity,
    t.team_name
FROM stadiums s    
LEFT JOIN teams t ON t.stadium_id = s.stadium_id
GROUP BY s.stadium_name, s.capacity, t.team_name
ORDER BY capacity DESC;

/*
A2 = Stadion sa najvećim kapacitetom je National Stadium (80.000), 
a najveći stadion nekog kluba je Harbourside Park (52.000) od Northport Uniteda.
*/


-- 3. zadatak

SELECT
    COUNT(*)
FROM players
WHERE nationality = 'Serbia';

-- A3 = 42 igrača


-- 4. zadatak

SELECT 
    SUM(CASE WHEN home_goals = 1 AND away_goals = 1 THEN 1 
        ELSE 0 END) AS matches_one_one
FROM matches;

-- A4 = 94 utakmice 


-- 5. zadatak

-SELECT
    season,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM matches
GROUP BY season;

/*
A5
season	avg_attendance
2023/24	24252.95
2024/25	24199.49
*/


-- 6. zadatak

SELECT
    season,
    COUNT(me.event_id) AS penalty_goals
FROM matches m    
INNER JOIN match_events me ON me.match_id = m.match_id
WHERE me.event_type = 'penalty_goal'
GROUP BY season;

/*
A6
season	penalty_goals
2023/24	104
2024/25	109
*/


-- 7. zadatak

WITH player_goals AS (
    SELECT
        me.player_id,
        COUNT(me.event_type)
    FROM matches m   
    INNER JOIN match_events me ON me.match_id = m.match_id
    WHERE me.event_type IN ('goal', 'penalty_goal')
        AND season = '2024/25'
    GROUP BY me.player_id
)
SELECT COUNT(*)
FROM player_goals;

-- A7 = 308 igrača ima bar jedan pogodak


-- 8. zadatak

SELECT
    r.referee_id,
    r.referee_name,
    COUNT(m.match_id) AS match_num
FROM matches m    
INNER JOIN referees r ON r.referee_id = m.referee_id
INNER JOIN teams t ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
WHERE t.team_name = 'Northport United'
GROUP BY r.referee_id, r.referee_name
ORDER BY match_num DESC
LIMIT 1;

-- A8 = Peter Lindgren je sudija koji sudio najviše utakmica Northport United-u, ukupno 9.


-- 9. zadatak

SELECT
    r.referee_name,
    COUNT(DISTINCT CASE WHEN me.event_type IN ('penalty_goal', 'penalty_miss') THEN m.match_id END) AS penalty_matches,
    ROUND(COUNT(DISTINCT CASE WHEN me.event_type IN ('penalty_goal', 'penalty_miss') THEN m.match_id END) / COUNT(DISTINCT m.match_id) * 100, 2) AS penalty_pct
FROM matches m    
INNER JOIN referees r ON r.referee_id = m.referee_id
LEFT JOIN match_events me ON me.match_id = m.match_id
WHERE season = '2024/25'
GROUP BY r.referee_id, r.referee_name
ORDER BY penalty_pct DESC;

-- A9: Peter Lindgren je sudija koji je u 9 od 20 utakmica (45%) dosudio penal na utakmicama koje je sudio u sezoni 2024/25.


-- 10. zadatak

WITH all_points AS (
    SELECT 
        ms.manager_name AS manager,
        CASE 
            WHEN m.home_goals > m.away_goals THEN 3
            WHEN m.home_goals = m.away_goals THEN 1
            ELSE 0 
        END AS points
    FROM matches m
    INNER JOIN manager_spells ms ON ms.team_id = m.home_team_id
    WHERE m.season = '2024/25'
      AND m.home_goals_ht < m.away_goals_ht
      AND m.kickoff_ts BETWEEN ms.start_date AND COALESCE(ms.end_date, '9999-12-31')
    UNION ALL
    SELECT 
        ms.manager_name AS manager,
        CASE 
            WHEN m.away_goals > m.home_goals THEN 3
            WHEN m.away_goals = m.home_goals THEN 1
            ELSE 0 
        END AS points
    FROM matches m
    INNER JOIN manager_spells ms ON ms.team_id = m.away_team_id
    WHERE m.season = '2024/25'
      AND m.away_goals_ht < m.home_goals_ht
      AND m.kickoff_ts BETWEEN ms.start_date AND COALESCE(ms.end_date, '9999-12-31')
)
SELECT 
    manager,
    SUM(points) AS total_points
FROM all_points
GROUP BY manager
ORDER BY total_points DESC;

-- A10 = Zoran Tošić 15