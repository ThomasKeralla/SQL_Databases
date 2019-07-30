
--1.1

select count(*) from person where height is NULL;

-- answer  47315 

--1.2
select count(*)
from (
    select count(*)
    from involved i
    join person p
    on i.personId = p.id
    group by i.movieId
    having avg(p.height) > 190
) x
;

-- 1.3
select count(*)
from (
    select mg.movieId
    from movie_genre mg
    group by mg.movieId
    having count(distinct mg.genre) <> count(*)
) x
;

-- 1.4
select count(distinct personId) from involved where movieId IN (
select movieId from
person p join involved i on p.id = i.personId
where name = 'Steven Spielberg' and role = 'director'
) and role = 'actor'
;

-- answer 2219

-- 1.5
select count(*) from movie where year = 1999
and id not in (select movieId from involved);

-- answer 7

-- 1.6

select p.id
from person p
join involved i
on p.id = i.personId
and i.role = 'actor'
join involved i2
on i.personId = i2.personId
and i2.role = 'director'
and i2.movieId = i.movieId
group by p.id
having count(*) > 1
;

-- answer 345

-- 1.7
    SELECT count(*)
    FROM movie m 
    join involved i 
    on m.id = i.movieId 
    where m.year = 1999
    GROUP BY i.movieId
    HAVING COUNT(DISTINCT role) = (SELECT COUNT(DISTINCT role) FROM role);

-- answer 250

-- 1.8
select count(*)
from (
    select i.personId
    from involved i
    join movie m
    on i.movieId = m.id
    join movie_genre mg
    on mg.movieId = m.id
    join genre g
    on g.genre = mg.genre
    where g.genre in (select genre from genre where category = 'Lame')
    group by i.personId
    having count(distinct g.genre) = (select count(distinct genre) from genre where category = 'Lame')
) x
;

-- 1

-- 2 
-- a is true rest is falls 

-- 3 

-- a
CREATE TABLE Doctor (
    DID INTEGER AUTO_INCREMENT PRIMARY KEY,
    Dname VARCHAR(50)
);
CREATE TABLE Child (
    CID INTEGER AUTO INCREMENT PRIMARY KEY,
    Cname VARCHAR(50)
);
CREATE TABLE QualityAssurer (
    QAID INTEGER AUTO_INCREMENT PRIMARY KEY,
    QAname VARCHAR(50)
);
CREATE TABLE LegalGuardian (
    LgName VARCHAR (50),
    CID INTEGER FOREIGN KEY REFERENCES Child (CID)
    PRIMARY KEY (LgName,CID)
);
CREATE TABLE Cures (
    Since DATE
    DID INTEGER FOREIGN KEY REFERENCES Doctor (DID),
    CID INTEGER FOREIGN KEY REFERENCES Child (CID), 
    PRIMARY KEY (DID, CID)
);

CREATE TABLE Monitors (
    QAID INTEGER REFERENCES QualityAssurer(QAID),
    DID INTEGER,CID INTEGER,
    grade INTEGER,
    PRIMARY KEY (DID, CID, QAID),
    FOREIGN KEY (DID, CID) REFERENCES Cures(DID, CID));
);

-- b

--- Games ---

-- 1.1
select count(*) from Player where email like '%yahoo.dk';
-- answer 87

-- 1.2
select count(*) from Score
where score < (select avg(score) as sc from Score);
-- answer 967

select count(achievementId) from PlayerAchievement
where achievementId not in (select id from Achievement);
-- answer 2

-- 1.3

select count(distinct playerId) from
(select distinct playerId, gameId from 
PlayerAchievement pa JOIN
Achievement a on a.id = pa.achievementId
where gameId in (select id from Game where producer = 'Electronix Arts')) as x
join
(select distinct playerId as p, gameId as gid from Score where gameId in
(select id from Game where producer = 'Electronix Arts')) as y
on x.playerId = y.p
where y.gid = x.gameId;


-- 1.4

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

select count(distinct z.spid)
from (
  select pa.playerId as paPid, a.gameId as agid
  from PlayerAchievement pa
  join Achievement a
  on pa.achievementId = a.id
) x
right join (
  select s.playerId as spid, s.gameId as sgid
  from Score s
) z
on x.paPid = z.spid and x.agid = z.sgid
where x.paPid is NULL
;

-- 1.5

select count(playerId)
from Score s join Game g on s.gameId=g.id
where name = 'Bioforge' 
group by playerId 
having 
count(playerId) = (select count(id) from Game where name = 'Bioforge');

select count(playerId) from
(select playerId
from Score s join Game g on s.gameId=g.id
where name = 'Bioforge') x ;
having count(x.playerId) = (select count(id) from Game where name = 'Bioforge');

group by playerId 
having 
count(playerId) = (select count(id) from Game where name = 'Bioforge');


select count(id) from Game where name = 'Bioforge';

-- right one
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
where (TIME_TO_SEC(Duration) / 60) > 60;
-- answer 2

2.2
select sum(TIME_TO_SEC(Duration)) from Songs;
-- answer 3883371

2.3
-- The database contains just 5 songs released in 1953. 
--What is the largest number of songs released in a single year?
select max(c) FROM
(
select count(distinct songId) as c,YEAR(releaseDate) as year1 from Songs
group by YEAR(releaseDate)
) x;
-- answer 833

2.4
select count(*) FROM
Artists a join AlbumArtists aa
on a.ArtistId=aa.ArtistId
join Albums al on aa.AlbumId=al.AlbumId
where Artist = 'Tom Waits';

-- answer 24

2.5
select count(distinct a.AlbumId) FROM
Albums a join AlbumGenres ag
on a.AlbumId = ag.AlbumId
join Genres g on ag.GenreId=g.GenreId
where genre like 'Alt%' ;

-- answer 421

2.6
--For how many songs does there exist another di↵erent song in the database with the same title?

select count(*) FROM
Songs s1 join Songs s2
on s1.Title=s2.Title
where s1.SongId <> s2.SongId;

-- answer 3340

2.7
-- The average number of albumIds per genreId in albumGenres is 26.5246. 
-- An album can have multiple genres. What is the average number of genreIds per albumId?

select avg(c) FROM
(
  select count(a.ALbumId) as c FROM
  Albums a join AlbumGenres ag
  on a.AlbumId=ag.ALbumId
  group by GenreId
) x;

select avg(c) FROM
(
  select count(ag.GenreId) as c FROM
  Albums a join AlbumGenres ag
  on a.AlbumId=ag.ALbumId
  group by a.AlbumId
) x;

-- answer 1.1994

2.8
--An album can have multiple genres. There are 1215 albums in the database 
--that do not have the genre Rock. How many albums do not have the genre HipHop?

select count(distinct a.AlbumId) from 
Albums a join AlbumGenres ag
on a.AlbumId=ag.AlbumId
join Genres g on ag.GenreId=g.GenreId
where Genre <> 'HipHop';

-- answer might be wrong 1349



----- EXAM ----

-- DDL

CREATE TABLE Team (
    TID INTEGER AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE RegisteredTeams (
    RegID INTEGER AUTO_INCREMENT,
    team INTEGER,
    FOREIGN KEY (team) REFERENCES Team (TID) 
);

CREATE TABLE Matchh (
    MID INTEGER AUTO_INCREMENT PRIMARY KEY,
    MatchTime INTEGER 
);

CREATE TABLE Setss (
    matchID INTEGER,
    SetNumb INTEGER, 
    FOREIGN KEY (matchID) REFERENCES Matchh(MID),
    PRIMARY KEY (matchID, SetNumb)
);

CREATE TABLE Plays (
    Home INTEGER, 
    Away INTEGER,
    MatchId INTEGER, 
    PRIMARY KEY (MatchId),
    FOREIGN KEY (Home) REFERENCES Team (TID),
    FOREIGN KEY (Away) REFERENCES Team (TID),
    FOREIGN KEY (MatchId) REFERENCES Matchh(MID)
);

--acgroup(ag, agfullname)
--aircraft(actype, actypefullname, capacity, ag)
--airport(airport, country)
--country(country, region)
--flights(id, al, dep, arr, actype, start_op, end_op, ...)

1a
select count(*) from airport
where country = 'DK';

1b
--in  Asia,  there  are  57  airports  that  have  both  departing  and  arriving  flights.   
--Howmany airports are in Europe have both departing and arriving flights?

select distinct airport as ap from 

-- all EU airposrt 
select count(distinct res) from
(select distinct res from 
(select a.airport as res  FROM
airport a join country c
on a.country=c.country
where region = 'EU') X
join flights f1 on f1.dep = x.res) y 
join flights f2 on f2.arr = y.res;

2c
--The average number of days that a flight route has been running is 42.77.  
--For how many days has the longest running flight route been running?

select max(DATEDIFF(end_op, start_op)) from 
flights;

2d
--There are 6126 flights that a) depart from an airport within Europe and b) have an aircraft 
--capacity of more than 300 passengers.  How many flights with more capacitythan 300 passengers 
--depart from an airport within Asia?

select count(*) from
(select dep, capacity FROM
flights f join aircraft a 
on f.actype=a.actype) x
where x.dep in (select a.airport as res  FROM
airport a join country c
on a.country=c.country
where region = 'EU') and x.capacity > 300;

select count(*) FROM
flights f join aircraft a 
on f.actype=a.actype
where dep in (select a.airport as res  FROM
airport a join country c
on a.country=c.country
where region = 'AS') and capacity > 300;

2e
--Each aircraft has a registered aircraft group (aircraft.ag).  
--The smallest such aircraftgroup has 2 members.  
--How many members does the largest group have?
--Hint:  Using a view can simplify the query significantly.  
--If you do, include the viewcreation statement in your answer

select ag from aircraft;

select * from acgroup;

2f
--According to the flights relation, there are 124 airports with more departing flights than arriving flights.  
--How many airports have more arriving flights than departingflights?

--acgroup(ag, agfullname)
--aircraft(actype, actypefullname, capacity, ag)
--airport(airport, country)
--country(country, region)
--flights(id, al, dep, arr, actype, start_op, end_op, ...)

select count(*) from
(select count(dep) as d, dep from
flights f join airport a on a.airport=f.dep
group by dep) x
left join 
(select count(arr) as a, arr from
flights f join airport a on a.airport=f.dep
group by arr) y
on x.dep=y.arr
where x.d > y.a or y.a is null;



select count(*) from
(select count(dep) as d, dep from
flights
group by dep) x
right join 
(select count(arr) as a, arr from
flights
group by arr) y
on x.dep=y.arr
where x.d < y.a or x.d is null;

2g
--How  many  freight  flights  (ag = ’F’)  land  in  a  different  country  
--from  where  theydeparted, but in the same region?

--acgroup(ag, agfullname)
--aircraft(actype, actypefullname, capacity, ag)
--airport(airport, country)
--country(country, region)
--flights(id, al, dep, arr, actype, start_op, end_op, ...)

select count(*) from
(
select dep,arr FROM
flights f join aircraft a 
on f.actype=a.actype
where ag='F' and  (select country from airport where airport = dep) <> 
(select country from airport where airport = arr)
) X
where 

select count(*) FROM
(
select x.dep as d,x.arr as a,depRegion region as arrRegion from
(select dep,arr, region as depRegion FROM
flights f join aircraft a 
on f.actype=a.actype
left join airport ap on f.dep=ap.airport 
left join country c on c.country=ap.country
where ag='F') x
left join airport ap on x.arr=ap.airport 
left join country c on c.country=ap.country
) y
where (select country from airport where airport = dep) <> 
(select country from airport where airport = arr)
