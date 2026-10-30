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