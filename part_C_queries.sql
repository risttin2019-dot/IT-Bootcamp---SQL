-- 1. zadatak 

WITH team_matches AS (
    SELECT
        m.season,
        m.home_team_id AS team_id,
        t.team_name AS team_name,
        m.home_goals AS goals_for
    FROM matches m
    INNER JOIN teams t ON t.team_id = m.home_team_id
    WHERE m.season = '2024/25' AND status = 'played'
    UNION ALL
    SELECT
        m.season,
        m.away_team_id AS team_id,
        t.team_name AS team_name,
        m.away_goals AS goals_for
    FROM matches m
    INNER JOIN teams t ON t.team_id = m.away_team_id
    WHERE m.season = '2024/25' AND status = 'played'
),
goals_per_club AS (
    SELECT 
        team_name,
        SUM(goals_for) AS goals
    FROM team_matches
    GROUP BY team_name
),
ukupno_liga AS (
    SELECT 
        SUM(goals) AS total_goals 
    FROM goals_per_club
)
SELECT 
    k.team_name,
    k.goals,
    ROUND(k.goals * 100.0 / u.total_goals, 2) AS pct
FROM goals_per_club k
CROSS JOIN ukupno_liga u
ORDER BY pct DESC;

/*
B1
team_name	        goals	pct
Kingsbridge City	83	    7.60
Castlebrook United	82	    7.51
Northport United	69	    6.32
.
.
.
*/


-- 2. zadatak

WITH avg_attendance AS (   
    SELECT
        s.stadium_name,
        ROUND(AVG(m.attendance), 2) AS avg_att
    FROM matches m
    INNER JOIN stadiums s ON s.stadium_id = m.stadium_id
    WHERE season = '2024/25'
    GROUP BY s.stadium_id, s.stadium_name
),
stadium_rank (
    SELECT
        stadium_name,
        avg_att,
        DENSE_RANK() OVER (
            ORDER BY avg_att DESC
        ) rang
    FROM avg_attendance
)
SELECT
    stadium_name,
    avg_att
FROM stadium_rank
WHERE rang <= 3;

/*
C1
stadium_name	    avg_att
Harbourside Park	44074.05
Kingsbridge Stadium	37968.42
Northport Arena	    36250.17
*/


-- 3. zadatak

WITH all_goals AS (
    SELECT 
        me.player_id,
        CONCAT(p.first_name, ' ', p.last_name) AS player_name,
        CASE 
            WHEN me.team_id = m.home_team_id THEN m.home_team_id
            ELSE m.away_team_id 
        END AS team_id,
        t.team_name,
        m.match_id,
        m.kickoff_ts AS goal_date
    FROM match_events me
    INNER JOIN matches m ON m.match_id = me.match_id
    INNER JOIN teams t ON t.team_id = me.team_id
    LEFT JOIN players p ON p.player_id = me.player_id
    WHERE m.season = '2024/25' 
      AND me.event_type = 'goal'
),
poslednji_gol_kluba AS (
    SELECT 
        team_name,
        player_name,
        goal_date,
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY goal_date DESC) as rnk
    FROM all_goals
)
SELECT 
    team_name,
    player_name AS strelac_poslednjeg_gola,
    goal_date
FROM poslednji_gol_kluba
WHERE rnk = 1
ORDER BY goal_date ASC;

-- B3 = Marko Stanković je igrač Elmsworth Wanderers-a koji je postigao najraniji posljednji gol (2025-04-19 15:00:00). 


-- 4. zadatak

SELECT
    m.match_id,
    m.attendance,
    LAG(attendance) OVER (
        ORDER BY kickoff_ts
    ) AS prev_match,
    m.attendance - LAG(m.attendance) OVER (
        ORDER BY kickoff_ts
    ) AS att_diff
FROM matches m
INNER JOIN teams t ON t.team_id = m.home_team_id
WHERE m.season = '2024/25' 
    AND t.team_name = 'Northport United'
ORDER BY att_diff;

-- B4 = Utakmica pod 2110 ID ima najveću razliku, 10267 gledalaca manje u odnosu na prethodnu utakmicu.


-- 5. zadatak

WITH team_matches AS (
    SELECT
        m.season,
        m.home_team_id AS team_id,
        m.kickoff_ts AS match_date,
        t.team_name AS team_name,
        m.home_goals AS goals_for,
         CASE 
            WHEN m.home_goals > m.away_goals THEN 3
            WHEN m.home_goals = m.away_goals THEN 1
            ELSE 0 
        END AS points
    FROM matches m
    INNER JOIN teams t ON t.team_id = m.home_team_id
    WHERE m.season = '2024/25' 
        AND status = 'played'
        AND t.team_name = 'Northport City'
    UNION ALL
    SELECT
        m.season,
        m.away_team_id AS team_id,
        m.kickoff_ts AS match_date,
        t.team_name AS team_name,
        m.away_goals AS goals_for,
        CASE 
            WHEN m.home_goals > m.away_goals THEN 3
            WHEN m.home_goals = m.away_goals THEN 1
            ELSE 0 
        END AS points
    FROM matches m
    INNER JOIN teams t ON t.team_id = m.away_team_id
        WHERE m.season = '2024/25' 
        AND status = 'played'
        AND t.team_name = 'Northport City'
)
SELECT
    team_name,
    match_date,
    points,
    SUM(points) OVER (
        ORDER BY match_date
    ) AS point_sum,
    RANK() OVER (
        ORDER BY match_date
    ) AS rnk
FROM team_matches
QUALIFY point_sum >= 50;

-- B5 = U 24. meču Northport City je osvojio 3 boda i prešeao prag od 50 bodova u sezoni 2024/25.