
-- Exercise 1
SELECT COUNT(*)
FROM Player 
WHERE email LIKE "%yahoo.dk";
-- output = 87

-- Excrcise 2
SELECT COUNT(playerId) 
FROM Score
WHERE score <
(SELECT AVG(score) AS avg1  
FROM Score)
;
-- output = 967

-- Exercise 3
SELECT COUNT(achievementId) as result FROM (
    SELECT achievementId FROM
)