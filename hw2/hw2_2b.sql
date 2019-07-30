DROP DATABASE IF EXISTS wasp;
CREATE DATABASE IF NOT EXISTS wasp;
USE wasp;

CREATE TABLE People (
       id       INT,
       dob      DATE NOT NULL,
       dod      DATE DEFAULT NULL,
       name     VARCHAR(50) NOT NULL,
       address  VARCHAR(100),
       phone    INT,
       PRIMARY KEY (id)
);

CREATE TABLE Member (
       member_id    INT,
       start        DATE NOT NULL,
       PRIMARY KEY (member_id),
       FOREIGN KEY (member_id) REFERENCES People (id)
);

CREATE TABLE Enemy (
       enemy_id INT,
       PRIMARY KEY (enemy_id),
       FOREIGN KEY (enemy_id) REFERENCES People (id) ON DELETE CASCADE
);

CREATE TABLE Asset (
       name             VARCHAR(50),
       member_id        INT,
       assetUsage       VARCHAR(200),
       assetDescription VARCHAR(200),
       UNIQUE (name),
       PRIMARY KEY (name),
       FOREIGN KEY (member_id) REFERENCES Member (member_id) ON DELETE CASCADE
);

CREATE TABLE IsOpponent  (
       enemy_id     INT,
       opponent     INT NOT NULL,
       start        DATE NOT NULL,
       end_date     DATE,
       PRIMARY KEY (enemy_id),
       FOREIGN KEY (enemy_id)   REFERENCES Enemy (enemy_id) ON DELETE CASCADE,
       FOREIGN KEY (opponent)   REFERENCES Member (member_id) ON DELETE CASCADE
);

CREATE TABLE Linking  (
    link_id     INT AUTO_INCREMENT,
    name        VARCHAR(50),
    type        VARCHAR(50),
    description VARCHAR(200),
    PRIMARY KEY (link_id)
);


CREATE TABLE ParticipatesIn  (
    people_id   INT NOT NULL,
    link_id     INT NOT NULL,
    PRIMARY KEY (people_id,link_id),
    FOREIGN KEY (people_id) REFERENCES People (id),
    FOREIGN KEY (link_id)   REFERENCES Linking (link_id) ON DELETE CASCADE
);

DROP TRIGGER IF EXISTS Participate_delete_check;
delimiter //
CREATE TRIGGER Participate_delete_check
AFTER DELETE ON ParticipatesIn
FOR EACH ROW
BEGIN
IF (OLD.link_id NOT IN (SELECT link_id FROM ParticipatesIn) ) THEN
  DELETE FROM Linking WHERE link_id = OLD.link_id;
END IF;
END //
delimiter ;


DROP FUNCTION IF EXISTS Linking_insert;
DELIMITER //
CREATE FUNCTION Linking_insert (
  people_id_ INT,
  name_ VARCHAR(50),
  type_ VARCHAR(50),
  description VARCHAR(200)
)
RETURNS CHAR(50) DETERMINISTIC
BEGIN
  DECLARE return_str VARCHAR(50);
  IF (people_id_ IN (SELECT id FROM People)) THEN
    INSERT INTO Linking (name, type, description) VALUES
    (name_, type_, description_);
    INSERT INTO ParticipatesIn (people_id, link_id) VALUES
    (people_id_, (SELECT link_id FROM Linking WHERE type = type AND name = name_ AND description = description_));
    SET return_str='Success'
    ;
  ELSE
    SET return_str='Failure'
    ;
  END IF;
  RETURN return_str;
END //
DELIMITER ;


CREATE TABLE Roles  (
    role_id INT AUTO_INCREMENT,
    title   VARCHAR(50),
    UNIQUE (title),
    PRIMARY KEY (role_id)
);

CREATE TABLE isAssigned (
    member_id       INT,
    role_id         INT,
    start           DATE NOT NULL,
    end_date        DATE NOT NULL,
    salary          INT,
    FOREIGN KEY (member_id) REFERENCES Member (member_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id)   REFERENCES Roles (role_id)    ON DELETE CASCADE,
    UNIQUE (member_id, role_id)
);

DROP TRIGGER IF EXISTS No_delete_isAssigned;
delimiter //
CREATE TRIGGER No_delete_isAssigned
BEFORE DELETE ON isAssigned
FOR EACH ROW
BEGIN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Assignments cannot be deleted.';
END //
delimiter ;


CREATE TABLE PoliticalParty (
id              INT AUTO_INCREMENT,
name            VARCHAR(50),
country         VARCHAR(50),
monitored_by    INT NOT NULL,
UNIQUE (name,country),
PRIMARY KEY (id),
FOREIGN KEY (monitored_by) REFERENCES Member (member_id)
);

CREATE TABLE Sponsor (
sponsor_id  INT AUTO_INCREMENT,
name        VARCHAR(50),
address     VARCHAR(50),
industry    VARCHAR(50),
PRIMARY KEY (sponsor_id)
);


CREATE TABLE GivesGrants (
member_id       INT,
sponsor_id      INT,
date_granted    DATE,
amount          INT,
payback         VARCHAR(200),
UNIQUE (member_id, sponsor_id, date_granted),
PRIMARY KEY (member_id, sponsor_id, date_granted),
FOREIGN KEY (member_id) REFERENCES Member (member_id) ON DELETE CASCADE,
FOREIGN KEY (sponsor_id) REFERENCES Sponsor (sponsor_id) ON DELETE CASCADE
);

CREATE TABLE Reviews (
review_date     DATE NOT NULL,
review_grade    INT CHECK (review_grade >= 0 && review_grade<11),
reviewed_by     INT,
given_by        INT,
given_to        INT,
date_granted    DATE,
PRIMARY KEY (given_to, given_by, date_granted),
FOREIGN KEY (given_to, given_by, date_granted) REFERENCES GivesGrants (member_id, sponsor_id, date_granted),
FOREIGN KEY (reviewed_by) REFERENCES Member (member_id)
);
