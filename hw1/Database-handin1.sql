/*
  Thomas Keralla Høpfner-Dahl
  thkh@itu.dk
*/


-- PART 1

use Sports;

-- 1
SELECT count(DISTINCT R.peopleID)
FROM Results as R
WHERE R.result is Null
;

-- +----------------------------+
-- | count(DISTINCT R.peopleID) |
-- +----------------------------+
-- |                         75 |
-- +----------------------------+
-- 1 row in set (0.00 sec)

-- 2
SELECT P.ID, P.name
FROM People P LEFT JOIN Results R
ON P.ID = R.peopleID
WHERE R.peopleID is NULL
;

-- +-----+----------------+
-- | ID  | name           |
-- +-----+----------------+
-- | 249 | Jens Hvidt     |
-- | 250 | Inge Lauridsen |
-- | 251 | Peter Laudruup |
-- +-----+----------------+
-- 3 rows in set (0.01 sec)

-- 3
SELECT DISTINCT P.ID, P.name
FROM Results R JOIN Sports S
ON S.ID = R.sportID
JOIN People P ON R.peopleID=P.ID
JOIN Competitions C ON R.competitiONID=C.ID
-- WHERE (year(C.held)=2002 AND mONth(C.held)=6)
WHERE C.held LIKE "2002-06%"
-- OR result LIKE 2.11
OR S.name = "High Jump" && R.result >= S.record
;

-- 53 rows in set, 1 warning (0.02 sec)

-- 4
SELECT DISTINCT P.ID, P.name
FROM People P INNER JOIN Results R
ON R.peopleID=P.ID
INNER JOIN Sports S ON R.sportID=S.ID
AND R.result=S.record
WHERE P.ID NOT IN (
  SELECT P.ID
  FROM People P INNER JOIN Results R
  ON R.peopleID=P.ID
  INNER JOIN Sports S ON R.sportID=S.ID
  AND R.result != S.record
)
group by P.ID, R.sportID
;

-- +-----+--------------+
-- | ID  | name         |
-- +-----+--------------+
-- | 119 | Peter Jansen |
-- +-----+--------------+
-- 1 row in set (0.04 sec)

-- 5
SELECT S.ID, S.name,
FORMAT(MAX(R.result),2) AS "maxres"
FROM Results R LEFT JOIN Sports S
ON R.sportID=S.ID
GROUP BY S.ID
ORDER BY S.ID
;

-- +------+-------------+--------+
-- | ID   | name        | maxres |
-- +------+-------------+--------+
-- |    0 | High Jump   | 2.11   |
-- |    1 | Long Jump   | 6.78   |
-- |    2 | Triple Jump | 13.15  |
-- |    3 | Shot Put    | 16.66  |
-- |    4 | Pole Vault  | 5.52   |
-- |    5 | Javelin     | 60.46  |
-- |    6 | Discus      | 25.20  |
-- +------+-------------+--------+
-- 7 rows in set (0.03 sec)


-- 6
SELECT ID, name, totalRecords
FROM (
  SELECT P.ID, P.name, COUNT(*) AS totalRecords
  -- COUNT(DISTINCT(R.sportID)) AS sportsWithMoreThanOneRecord
  FROM People P INNER JOIN Results R
  ON R.peopleID=P.ID
  INNER JOIN Sports S ON R.sportID=S.ID
  AND R.result>=S.record
  GROUP BY P.ID
  HAVING totalRecords > 1 && COUNT(DISTINCT(R.sportID)) > 1
  -- HAVING totalRecords > 1 && sportsWithMoreThanOneRecord > 1
) AS x
;

-- +----+-------------+--------------+
-- | ID | name        | totalRecords |
-- +----+-------------+--------------+
-- | 25 | Jens Jansen |           21 |
-- +----+-------------+--------------+
-- 1 row in set (0.03 sec)

-- 7

SELECT peeps_id AS ID, p.name, p.height, result, s.name AS Sport,  
  IF(result = s.record AND peeps_sid = s.ID, "YES" , "NO") AS IsRecord
  FROM
  (
  SELECT distinct rt.peopleID AS peeps_id, rt.sportID AS peeps_Sid, 
  rt.result AS result
    FROM 
    (
    SELECT FORMAT(MAX(r.result),2) AS best_result, r.sportID AS ID
    FROM Results r
    WHERE r.sportID <= (SELECT MAX(Results.sportID) FROM Results)
    GROUP BY r.sportID 
    ) AS result_set 
    INNER JOIN Results rt ON rt.sportID=result_set.ID 
    WHERE FORMAT(rt.result,2) = result_set.best_result 
    ) AS X
  INNER JOIN People p ON X.peeps_id=p.ID
  INNER JOIN Sports s ON X.peeps_Sid=s.ID;



-- 8
SELECT COUNT(*) AS Number of Athletes FROM (
  SELECT COUNT(*)
  FROM People P INNER JOIN Results R ON P.ID=R.peopleID
  INNER JOIN Competitions C ON R.competitionID=C.ID
  GROUP BY P.ID
  HAVING COUNT(DISTINCT C.place) >= 10
) 
;

-- +--------------------+
-- | Number of Athletes |
-- +--------------------+
-- |                206 |
-- +--------------------+
-- 1 row in set (0.04 sec)


-- 9
INSERT INTO People (ID,name,gender,height)
VALUES (1000, "THOMAS",'M', 1.90);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 0, 2.11);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 1, 6.78);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 2, 13.15);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 3, 16.66);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 4, 5.52);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 5, 60.46);
INSERT INTO Results (peopleID, competitionID, sportID, result)
VALUES (1000, 2, 6, 25.20);


SELECT Y.ID, p.name FROM(
SELECT rt.peopleID AS ID, X.best_result, X.ID, rt.sportID, rt.result 
  FROM 
  (
  SELECT FORMAT(MAX(r.result),2) AS best_result, r.sportID AS ID
      FROM Results r
      WHERE r.sportID <= (SELECT MAX(Results.sportID) FROM Results)
      GROUP BY r.sportID 
      ) AS X 
      INNER JOIN Results rt ON X.ID=rt.sportID 
      WHERE X.best_result = FORMAT(rt.result,2) AND rt.peopleID = 1000
) AS Y INNER JOIN People p ON Y.ID=p.ID
      ;
      


DELETE FROM People WHERE People.ID = 1000;
DELETE FROM Results WHERE Results.peopleID = 1000;


-- 10
SELECT Sport_ID, Sport, Record, Worst
FROM (
  SELECT S.ID AS Sport_ID, S.name AS Sport,
  FORMAT(S.record,2) AS Record,
  FORMAT(MIN(R.result),2) AS Worst,
  COUNT(DISTINCT C.place) AS places_count
  FROM Sports S INNER JOIN Results R ON S.ID=R.sportID INNER JOIN Competitions C ON R.competitionID=C.ID
  GROUP By S.ID
  HAVING places_count = (
    SELECT COUNT(DISTINCT Competitions.place) FROM Competitions
  )
) AS x
GROUP BY Sport_ID
;


-- ===============================================================
-- PART 2
-- ======


use Games;

-- 11
select count(*)
from Player p
where p.email like "%yahoo.dk"
;

-- +----------+
-- | count(*) |
-- +----------+
-- |       87 |
-- +----------+
-- 1 row in set (0.00 sec)

-- 12
select count(s.playerId)
from Score s
where s.score < (
  select avg(score)
  from Score
)
;

-- +-------------------+
-- | count(s.playerId) |
-- +-------------------+
-- |               967 |
-- +-------------------+
-- 1 row in set (0.00 sec)


-- 13
Select count(achievementId) - (
	select count(p.achievementId)
From PlayerAchievement p
Inner join achievement a
On p.achievementId = a.id
) as missing_id
From PlayerAchievement;

-- +------------+
-- | missing_id |
-- +------------+
-- |          2 |
-- +------------+
-- 1 row in set (0.01 sec)


--14

SELECT COUNT(distinct(id_1)) FROM
(   SELECT p.playerId AS id_1, g.producer AS P1, s.score, s.gameId AS G1
    FROM PlayerAchievement p INNER JOIN Score s ON p.playerId=s.playerId
    INNER JOIN Game g ON s.gameId=g.id
    WHERE g.producer = 'codemasters'
) X INNER JOIN (
    SELECT p.playerId AS id_2, g.producer AS P2, a.id, a.gameId AS G2
    FROM PlayerAchievement p INNER JOIN Achievement a ON p.achievementId=a.id
    INNER JOIN Game g ON a.gameId=g.id
    WHERE g.producer = 'codemasters') Z
    ON X.id_1=Z.id_2 AND X.G1=Z.G2
    ;

--  +-------------+
--  | COUNT(id_1) |
--  +-------------+
--  |           6 |
--  +-------------+
--  1 row in set (0.01 sec)


--15

select count(distinct x.playerId) as "players"
from (
  select pa.playerId, a.gameId
  from PlayerAchievement pa
  join Achievement a
  on pa.achievementId = a.id
) x
left join (
  select s.playerId, s.gameId
  from Score s
  where s.score is not null
) z
on x.playerId = z.playerId and x.gameId = z.gameId
where z.playerId is null
;

--  +---------+
--  | players |
--  +---------+
--  |     486 |
--  +---------+
--  1 row in set (0.01 sec)


--16

SELECT count(playerId) from
  (SELECT distinct playerId FROM score
  WHERE
  gameId IN (
    SELECT id FROM game
    WHERE
    name = "Project Eden"
  )
  GROUP BY playerId
  HAVING count(playerId) >1) x
;

--  +-----------------+
--  | count(playerId) |
--  +-----------------+
--  |               2 |
--  +-----------------+
--  1 row in set (0.00 sec)


--17

SELECT count(*) from
    (SELECT count(*)
    FROM game
    GROUP BY name
    HAVING count(*) = 2) x ;

--  +----------+
--  | count(*) |
--  +----------+
--  |        7 |
--  +----------+
--  1 row in set (0.00 sec)


--18

SELECT SUM(mycount) from (SELECT COUNT(*) as "mycount" 
FROM (
  SELECT count(*) as "count"
  FROM game
  GROUP BY name
  HAVING count(*) = 2 ) x
UNION
  SELECT count(*) as "count"
  FROM game
  GROUP BY name
  HAVING count(*) = 3 ) z;

--  +--------------+
--  | SUM(mycount) |
--  +--------------+
--  |           10 |
--  +--------------+
--  1 row in set (0.00 sec)


--- jan 2018

Artists(ArtistId,Artist,ArtistImageUrl)
   Songs(SongId,Title,ArtistId,Duration,IsExplicit,ImageUrl,ReleaseDate)
   Genres(GenreId,Genre)
   Albums(AlbumId,Album,AlbumImageUrl,AlbumReleaseDate)
   AlbumArtists(AlbumId,ArtistId)
   AlbumGenres(AlbumId,GenreId)
   AlbumSongs(AlbumId,SongId)
   SongGenres(SongId,GenreId)

2.1
select count(*) from Songs
where (TIME_TO_SEC(duration) / 60) > 60;

-- answer = 2
2.2
select sum(TIME_TO_SEC(duration)) from Songs;
-- answer = 3883371 sec


2.3
--The database contains just 5 songs released in 1953. 
--What is the largest number of songs released in a single year?

select count(*) from Songs
where year(ReleaseDate) = (select min(year(ReleaseDate)) from Songs);

-- 