-- 1. zadatak

SELECT
    COUNT(*) AS num_of_matches,
    SUM(home_goals + away_goals) AS total_goals,
    ROUND(AVG(home_goals + away_goals), 2) AS avg_goals,
    ROUND(COUNT(CASE WHEN home_goals > away_goals THEN 1 END) * 100 / COUNT(*), 2) AS home_win,
    ROUND(COUNT(CASE WHEN home_goals = away_goals THEN 1 END) * 100 / COUNT(*), 2) AS draw,
    ROUND(COUNT(CASE WHEN home_goals < away_goals THEN 1 END) * 100 / COUNT(*), 2) AS away_win
FROM matches
WHERE season = '2024/25' AND status = 'played';

/*
B1
num_of_matches	total_goals	avg_goals	home_win	draw	away_win
380	            1092	    2.87	    41.32	    25	    33.68
*/


-- 2. zadatak 

SELECT
    DATE_TRUNC('month', kickoff_ts) AS mjesec,
    DATE_FORMAT(kickoff_ts, 'MMMM yyyy') AS naziv_mjeseca,
    SUM(home_goals + away_goals) AS total_goals,
    ROUND(AVG(home_goals + away_goals), 2) AS avg_goals
FROM matches
WHERE season = '2024/25'
GROUP BY DATE_TRUNC('month', kickoff_ts), DATE_FORMAT(kickoff_ts, 'MMMM yyyy')
ORDER BY mjesec;

/*
B2
naziv_mjeseca	total_goals	avg_goals
August 2024	    99	        3.54
October 2024	102	        3.4
April 2025	    124	        3.1
February 2025	119	        2.98
March 2025	    113	        2.83
December 2024	145	        2.79
January 2025	137     	2.69
May 2025	    79	        2.63
November 2024	96	        2.59
September 2024	78	        2.44

Avgust 2024 godine se izdvaja po prosjeku golova, dok je decembar mjesec sa najvise golova.
*/ 


-- 3. zadatak

SELECT
    s.stadium_name,
    ROUND(AVG(m.attendance), 2) AS avg_attendance,
    ROUND(AVG(m.attendance / s.capacity) * 100, 2) AS avg_att_pct,
    COUNT(CASE WHEN m.attendance IS NULL THEN 1 END) AS no_data,
    COUNT(CASE WHEN m.attendance = 0 THEN 1 END) AS no_viewers
FROM matches m    
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE season = '2024/25'
GROUP BY s.stadium_id, s.stadium_name;

/*
B3
stadium_name	    avg_attendance	avg_att_pct	no_data	no_viewers
Castle Grounds	    29616.78	    89.75	    1	    0
Northport Arena	    36250.17	    88.42	    1	    0
Pemberton Park	    29905.26	    83.07	    0	    0
Harbourside Park	44074.05	    84.76	    0	    0
.
.
.
*/


-- 4. zadatak

SELECT 
    r.referee_name,
    COUNT(DISTINCT m.match_id) AS match_num,
    COUNT(CASE WHEN me.event_type IN ('yellow_card', 'second_yellow', 'red_card') THEN 1 END) / COUNT(DISTINCT m.match_id) AS avg_card
FROM matches m     
INNER JOIN referees r ON r.referee_id = m.referee_id
LEFT JOIN match_events me ON me.match_id = m.match_id
WHERE season = '2024/25'
GROUP BY r.referee_id, r.referee_name;

/*
B4
referee_name	        match_num	card_num
Mark Halsey-Brown	    20	        3.75
Craig Pawson-Lee	    20	        4
Owen Pritchard	        20	        3.4
Stuart Attwell-Jones	20	        3.55
.
.
.
*/


-- 5. zadatak

SELECT
    p.player_id,
    p.first_name,
    p.last_name,
    COUNT(me.event_id) AS goals
FROM match_events me
INNER JOIN matches m ON m.match_id = me.match_id
INNER JOIN players p ON p.player_id = me.player_id
WHERE season = '2024/25'
    AND me.event_type IN ('goal', 'penalty_goal')
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY goals DESC
LIMIT 5;

/*
B5a
TOP 5 strelaca
player_id   first_name	last_name	goals
678	        Mattéo	    O'Brien	    34
676	        Leo	        Marsh   	32
680	        José	    Muñoz	    24
234	        Marko	    Stanković	17
677	        Leo	        Marsh	    16
*/

SELECT
    p.player_id,
    p.first_name,
    p.last_name,
    COUNT(me.event_id) AS goals
FROM match_events me
INNER JOIN matches m ON m.match_id = me.match_id
INNER JOIN players p ON p.player_id = me.related_player_id
WHERE season = '2024/25'
    AND me.event_type IN ('goal', 'penalty_goal')
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY goals DESC
LIMIT 5;

/*
B5b
TOP 5 asistencija
player_id	first_name	last_name	goals
19	        Pablo	    Fernández	9
111	        Filip	    Petrović	7
341	        Eirik	    Solberg	    7
49	        Lucas	    Pereira	    7
45	        Mikkel	    Nielsen	    6
*/


-- 6. zadatak

SELECT
    COUNT(*)
FROM matches
WHERE attendance IS NULL and season = '2024/25';

SELECT *
FROM matches
WHERE weather IS NULL and season = '2024/25';

/*
B6
Devet utakmica nema podatke o publici, dok 34 nemaju podatke o vremenu.
*/