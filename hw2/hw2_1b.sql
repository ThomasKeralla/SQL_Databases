-- Generator script for HW2 1 b

SELECT 'Creating database ...' as 'Print_hack';

DROP DATABASE IF EXISTS Hunting;
CREATE DATABASE IF NOT EXISTS Hunting;
USE Hunting;

SELECT 'Creating tables ...' as 'Print_hack';

DROP TABLE IF EXISTS Animal, Bird, Fox, Dog, Hunter, Fox_kills, Assists;

CREATE TABLE Hunter (
  id          INT           NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id)
);

CREATE TABLE Animal (
  id          INT           NOT NULL AUTO_INCREMENT,
  weight      INT           NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE Bird (
  animal_id   INT           NOT NULL,
  wingspan    INT           NOT NULL,
  FOREIGN KEY (animal_id)   REFERENCES Animal (id) ON DELETE CASCADE,
  PRIMARY KEY (animal_id)
);

CREATE TABLE Dog (
  animal_id   INT           NOT NULL,
  breed       VARCHAR(50)   NOT NULL,
  name        VARCHAR(50)   NOT NULL,
  owned_by    INT           NOT NULL,
  FOREIGN KEY (owned_by)    REFERENCES Hunter (id)  ON DELETE CASCADE,
  FOREIGN KEY (animal_id)   REFERENCES Animal (id)  ON DELETE CASCADE,
  PRIMARY KEY (animal_id)
);

CREATE TABLE Fox (
  animal_id   INT           NOT NULL,
  color       VARCHAR(50)   NOT NULL,
  FOREIGN KEY (animal_id)   REFERENCES Animal (id)    ON DELETE CASCADE,
  PRIMARY KEY (animal_id)
);

CREATE TABLE Kills (
  id          INT           NOT NULL AUTO_INCREMENT,
  animal_id   INT           NOT NULL,
  hunter_id   INT           NOT NULL,
  FOREIGN KEY (animal_id)   REFERENCES Animal (id)    ON DELETE CASCADE,
  FOREIGN KEY (hunter_id)   REFERENCES Hunter (id)    ON DELETE CASCADE,
  UNIQUE (animal_id, hunter_id),
  PRIMARY KEY (id)
);

CREATE TABLE Assist (
  kill_id     INT         NOT NULL,
  dog_id      INT         NOT NULL,
  FOREIGN KEY (dog_id)    REFERENCES Dog (animal_id),
  FOREIGN KEY (kill_id)   REFERENCES Kills (id),
  PRIMARY KEY (kill_id)
);

SELECT 'Creating Triggers ...' as 'Print_hack';

DROP TRIGGER IF EXISTS checkNotDog;
delimiter //
CREATE TRIGGER checkNotDog
BEFORE INSERT ON Kills
FOR EACH ROW
BEGIN
IF (
NEW.animal_id IN (SELECT animal_id FROM Dog)
)
THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Cannot kill dog.';
END IF;
END //
delimiter ;

DROP TRIGGER IF EXISTS checkAssistKillsFox;
delimiter //
CREATE TRIGGER checkAssistKillsFox
BEFORE INSERT ON Assist
FOR EACH ROW
BEGIN
IF (
  NEW.kill_id NOT IN (
    SELECT k.id FROM Kills k
    JOIN Fox f
    ON k.animal_id = f.animal_id
  )
)
THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Dog can only assist kill on fox.';
END IF;
END //
delimiter ;

SELECT 'Inserting Values ...' as 'Print_hack';

INSERT INTO Hunter VALUES
(),(),()
;

INSERT INTO Animal (weight) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11)
;

INSERT INTO Bird (animal_id, wingspan) VALUES
(1, 100),
(2, 200),
(3, 300)
;

INSERT INTO Dog (animal_id, breed, name, owned_by) VALUES
(4, 'Retriever', 'Balder', 1),
(5, 'Pitbull', 'Fido', 1),
(6, 'Labrador', 'Killer', 2)
;

INSERT INTO Fox (animal_id, color) VALUES
(7, 'Green'),
(8, 'Purple'),
(9, 'Orange'),
(10, 'Blue')
;

SELECT 'Inserting kills ...' as 'Print_hack';

INSERT INTO Kills (animal_id, hunter_id) VALUES
(2, 1), -- bird
(3, 2), -- bird
-- (4, 1), -- dog should fail
(7, 1),
(8, 1),
(9, 2),
(10, 3)
;

INSERT INTO Assist (kill_id, dog_id) VALUES
-- (2, 4), -- kill_id 2 = bird - should fail
(4, 5)
;


DROP FUNCTION IF EXISTS insertKilledFox;
DELIMITER //
CREATE FUNCTION insertKilledFox(
  p_animal_id INT,
  p_color CHAR(50),
  p_hunter_id INT
)
RETURNS CHAR(50) DETERMINISTIC
BEGIN
  DECLARE return_str VARCHAR(50);
  IF (p_hunter_id IN (SELECT id FROM Hunter)) THEN
    INSERT INTO Fox (animal_id, color) VALUES
    (p_animal_id, p_color);
    INSERT INTO Kills (animal_id, hunter_id) VALUES
    (p_animal_id, p_hunter_id);
    SET return_str='Success'
    ;
  ELSE
    SET return_str='Failure'
    ;
  END IF;
  RETURN return_str;
END //
DELIMITER ;

SELECT insertKilledFox(11,'camo',4);

-- IF (1 NOT IN (SELECT id FROM Hunter) THEN
--   ROLLBACK
-- ) ELSE (
--   INSERT INTO Kills (animal_id, hunter_id) VALUES
--   (11, 1)
-- )
-- END IF;

-- COMMIT;

-- ROLLBACK;

-- extra bonus stufferinos

-- CREATE FUNCTION checkNotDog ()
-- RETURNS VARCHAR(5)
-- AS
-- BEGIN
--   IF EXISTS (SELECT animal_id FROM Dog WHERE animal_id = @field)
--     THEN RETURN 'false'
--   ELSE
--     RETURN 'true'
--   END IF
-- END
-- ;

-- SELECT 'Creating Triggers ...' as 'Print_hack';
--
-- DROP TRIGGER IF EXISTS checkIfLegalKillsInsert;
--
-- delimiter //
-- CREATE TRIGGER checkIfLegalKillsInsert
-- BEFORE INSERT ON Kills
-- FOR EACH ROW
-- BEGIN
--
--   IF (
--       ((
--           NEW.id NOT IN (SELECT id from Fox)
--         ) AND (
--           NEW.animal_type NOT IN (SELECT animal_type FROM Fox)
--       ))
--   )
--   THEN
--     SIGNAL SQLSTATE '45000'
--     SET MESSAGE_TEXT = 'Cannot insert fox ...';
--
--   -- ELSEIF (
--   --   ((
--   --       NEW.id NOT IN (SELECT id from Bird)
--   --     ) AND (
--   --       NEW.animal_type NOT IN (SELECT animal_type FROM Bird)
--   --   ))
--   -- )
--   -- THEN
--   --   SIGNAL SQLSTATE '45000'
--   --   SET MESSAGE_TEXT = 'Cannot insert bird ...';
--
--   END IF;
-- END //
-- delimiter ;
