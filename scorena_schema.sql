--SCHEMA DEFINATIONS

CREATE TABLE teams(
    tid int CONSTRAINT pk_teams PRIMARY KEY,
    tname varchar(50) CONSTRAINT uk_tname UNIQUE,
    coach varchar(50) CONSTRAINT uk_coach UNIQUE
);

CREATE TABLE players(
    pid serial CONSTRAINT pk_players PRIMARY KEY,
    pname varchar(50),
    teamid int NOT NULL, 
    pos varchar(50),
    jerseyno int CONSTRAINT jerseyno UNIQUE,
    CONSTRAINT fk_teamid FOREIGN KEY (teamid) REFERENCES teams(tid)
);

CREATE TABLE games(
    gid serial CONSTRAINT pk_games PRIMARY KEY,
    homeid int NOT NULL,
    awayid int NOT NULL, 
    hometimeouts int,
    awaytimeouts int,
    CONSTRAINT uk_games UNIQUE (homeid, awayid), --this was not present in the pdf but makes sense to add it
    CONSTRAINT fk_homeid FOREIGN KEY (homeid) REFERENCES teams(tid),
    CONSTRAINT fk_awayid FOREIGN KEY (awayid) REFERENCES teams(tid)
);

CREATE TABLE boxscores(
    playerid int,
    gameid int, 
    min_played time,
    fieldgoals int,
    fieldgoal_attempts int,
    threepoints int,
    threepoint_attempts int,
    freethrows int,
    freethrow_attempts int,
    off_rebounds int,
    def_rebounds int,
    assists int,
    steals int,
    blocks int,
    turnovers int,
    personal_fouls int,
    points int,
    CONSTRAINT pk_boxscore PRIMARY KEY (playerid, gameid),
    CONSTRAINT fk_playerid FOREIGN KEY (playerid) REFERENCES players(pid),
    CONSTRAINT fk_gameid FOREIGN KEY (gameid) REFERENCES games(gid)
);

CREATE TABLE events(
    eid serial CONSTRAINT pk_event PRIMARY KEY,
    ename varchar(50)
);

CREATE TABLE plays(
    playid serial CONSTRAINT pk_plays PRIMARY KEY,
    gameid int NOT NULL,
    playerid int NOT NULL,
    time_elapsed time,
    eventid int NOT NULL,
    second_playerid int,
    CONSTRAINT fk_plays_gameid FOREIGN KEY (gameid) REFERENCES games(gid),
    CONSTRAINT fk_plays_playerid FOREIGN KEY (playerid) REFERENCES players(pid),
    CONSTRAINT fk_plays_eventid FOREIGN KEY (eventid) REFERENCES events(eid),
    CONSTRAINT fk_plays_second_playerid FOREIGN KEY (second_playerid) REFERENCES players(pid)
);





--INSERTING RECORDS TO CREATE A DATABASE

INSERT INTO teams 
VALUES
    (0001, 'Bheemavaram Bodybuilders', 'Nikhilesh'),
    (0002, 'Kacheguda Chainsnatchers', 'Ashish'),
    (0003, 'Chikkadapally Chai Drinkers', 'Prahlad'),
    (0004, 'East Godavari Ethical Hackers', 'Srivant');

INSERT INTO players 
VALUES
    (1001, 'Virat Kohli', 0001, 'power forward', 18),
    (1002, 'Sachin Tendulkar', 0001, 'power forward', 10),
    (1003, 'AB de Villiers', 0001, 'point gaurd', 17),
    (1004, 'David Warner', 0001, 'small forward', 31),
    (1005, 'Pat Cummins', 0001, 'shooting gaurd', 30),
    (1006, 'Jasprit Bumrah', 0001, 'shooting gaurd', 93),
    (1007, 'MS Dhoni', 0001, 'center', 7),
    (1008, 'Anthony Davis', 0002, 'power forward', 3),
    (1009, 'LeBron James', 0002, 'small forward', 23),
    (1010, 'Kevin Durant', 0002, 'small forward', 35),
    (1011, 'Stephen Curry', 0002, 'point gaurd', 20),
    (1012, 'Joel Embiid', 0002, 'center', 21),
    (1013, 'James Harden', 0002, 'shooting gaurd', 1),
    (1014, 'Luka Doncic', 0002, 'point gaurd', 77),
    (1015, 'Nikola Jokic', 0002, 'center', 15),
    (1016, 'Erling Haaland', 0003, 'power forward', 9),
    (1017, 'Julian Alvarez', 0003, 'small forward', 19),
    (1018, 'Gabriel Martinelli', 0003, 'small forward', 11),
    (1019, 'Jude Bellingham', 0003, 'point gaurd', 5),
    (1020, 'Toni Kroos', 0003, 'center', 8),
    (1021, 'Virgil van Dijk', 0003, 'shooting gaurd', 4),
    (1022, 'Thiago', 0003, 'point gaurd', 6),
    (1023, 'Daniel Carvajal', 0003, 'center', 2),
    (1024, 'Albert Einstein', 0004, 'power forward', 55),
    (1025, 'Isaac Newton', 0004, 'power forward', 27),
    (1026, 'Galileo Galilei', 0004, 'point gaurd', 42),
    (1027, 'Charles Darwin', 0004, 'small forward', 82),
    (1028, 'Nikola Tesla', 0004, 'shooting gaurd', 43),
    (1029, 'Max Planck', 0004, 'center', 47),
    (1030, 'Michael Faraday', 0004, 'shooting gaurd', 67);

INSERT INTO games 
VALUES
    (2001, 0001, 0002, 0, 0),
    (2002, 0003, 0004, 0, 0),
    (2003, 0002, 0001, 0, 0),
    (2004, 0004, 0003, 0, 0),
    (2005, 0001, 0003, 0, 0),
    (2006, 0002, 0004, 0, 0),
    (2007, 0003, 0001, 0, 0),
    (2008, 0004, 0002, 0, 0),
    (2009, 0001, 0004, 0, 0),
    (2010, 0002, 0003, 0, 0),
    (2011, 0004, 0001, 0, 0),
    (2012, 0003, 0002, 0, 0);

INSERT INTO events 
VALUES
    (3001, 'fieldgoals'),
    (3002, 'fieldgoal_attempts'),
    (3003, 'threepoints'),
    (3004, 'threepoint_attempts'),
    (3005, 'freethrows'),
    (3006, 'freethrow_attempts'),
    (3007, 'off_rebounds'),
    (3008, 'def_rebounds'),
    (3009, 'assists'),
    (3010, 'steals'),
    (3011, 'blocks'),
    (3012, 'turnovers'),
    (3013, 'personal_fouls');






--TRIGGERS

CREATE OR REPLACE TRIGGER prevent_excess_timeouts
BEFORE UPDATE OF hometimeouts, awaytimeouts ON games
FOR EACH ROW
BEGIN
    IF :NEW.hometimeouts > 2 OR :NEW.awaytimeouts > 2 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Timeouts Finished');
    END IF;
END;

CREATE OR REPLACE TRIGGER prevent_excess_personal_fouls
BEFORE UPDATE OF personal_fouls ON boxscores
FOR EACH ROW
BEGIN
    IF :NEW.personal_fouls >= 6 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Player Fouled Out');
    END IF;
END;

CREATE OR REPLACE TRIGGER prevent_same_team_ids
BEFORE INSERT OR UPDATE OF homeid, awayid ON games
FOR EACH ROW
BEGIN
    IF :NEW.homeid = :NEW.awayid THEN
        RAISE_APPLICATION_ERROR(-20001, 'Home Team ID and Away Team ID cannot be the same');
    END IF;
END;





--PROCEDURES

CREATE OR REPLACE PROCEDURE get_top_scorers IS
BEGIN
    FOR rec IN (
        SELECT b.gameid,p.pname AS player_name,b.points AS points_scored
        FROM boxscores b,players p,games g
        WHERE b.points = (SELECT MAX(points) FROM boxscores WHERE gameid = b.gameid) AND b.playerid = p.pid AND b.gameid = g.gid 
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Game ID: ' || rec.gameid || ', Player: ' || rec.player_name || ', Points: ' || rec.points_scored);
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE MVP IS
    v_player_name varchar(20);
    v_max_avg_points NUMBER;
BEGIN
    SELECT pname, avg_points INTO v_player_name, v_max_avg_points
    FROM (
        SELECT p.pname, AVG(b.points) AS avg_points
        FROM boxscores b,players p
        WHERE b.playerid = p.pid
        GROUP BY p.pname
    ) WHERE avg_points = (
        SELECT MAX(avg_points) FROM (
            SELECT AVG(points) AS avg_points
            FROM boxscores
            GROUP BY playerid
        )
    );
    DBMS_OUTPUT.PUT_LINE('The MVP is ' || v_player_name || ' with an average of ' || v_max_avg_points || ' points per game.');
END;
/   


CREATE OR REPLACE PROCEDURE public.update_boxscore(
	IN event_id integer,
	IN game_id integer,
	IN player_id integer)
DECLARE event_name varchar(20);
DECLARE player_exists BOOLEAN;
BEGIN

  SELECT EXISTS (
    SELECT 1 FROM boxscores WHERE playerid = player_id AND gameid = game_id
  ) INTO player_exists;
  
  IF NOT player_exists THEN
    INSERT INTO boxscores (playerid, gameid, min_played , fieldgoals , fieldgoal_attempts , threepoints , threepoint_attempts , freethrows , freethrow_attempts , off_rebounds , def_rebounds , assists , steals , blocks , turnovers , personal_fouls , points)
    VALUES (player_id, game_id, now() , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0, 0 , 0 , 0 , 0 , 0);

  End if;
  
      select ename into event_name from events where eid = event_id;
      update boxscores
      set 
      
      fieldgoals = fieldgoals + CASE WHEN event_name = 'fieldgoals' THEN 1 ELSE 0 END,
        
      fieldgoal_attempts = fieldgoal_attempts + CASE WHEN event_name = 'fieldgoal_attempts' THEN 1 ELSE 0 END
      + CASE WHEN event_name = 'fieldgoals' THEN 1 ELSE 0 END,
      
      threepoints = threepoints + CASE WHEN event_name = 'threepoints' THEN 1 ELSE 0 END,
      threepoint_attempts = threepoint_attempts + CASE WHEN event_name = 'threepoint_attempts' THEN 1 ELSE 0 END,
        
      freethrows = freethrows + CASE WHEN event_name = 'freethrows' THEN 1 ELSE 0 END,
      freethrow_attempts = freethrow_attempts + CASE WHEN event_name = 'freethrow_attempts' THEN 1 ELSE 0 END,
      
      off_rebounds = off_rebounds + CASE WHEN event_name = 'off_rebounds' THEN 1 ELSE 0 END,
      def_rebounds = def_rebounds + CASE WHEN event_name = 'def_rebounds' THEN 1 ELSE 0 END,
      
      assists = assists + CASE WHEN event_name = 'assists' THEN 1 ELSE 0 END,
      steals = steals + CASE WHEN event_name = 'steals' THEN 1 ELSE 0 END,
      
      blocks = blocks + CASE WHEN event_name = 'blocks' THEN 1 ELSE 0 END,
      turnovers = turnovers + CASE WHEN event_name = 'turnovers' THEN 1 ELSE 0 END,
      personal_fouls = personal_fouls + CASE WHEN event_name = 'personal_fouls' THEN 1 ELSE 0 END,
      
	  points = points + CASE WHEN event_name = 'threepoints' THEN 3 ELSE 0 END + 
	  CASE WHEN event_name = 'fieldgoals' THEN 2 ELSE 0 END +
	  CASE WHEN event_name = 'freethrows' THEN 1 ELSE 0 END
	  
      where playerid = player_id AND game_id = gameid;
      
	  update games 
	  set 
	  hometimeouts = hometimeouts + CASE WHEN event_name = 'hometimeout' THEN 1 ELSE 0 END,
	  awaytimeouts = awaytimeouts + CASE WHEN event_name = 'awaytimeout' THEN 1 ELSE 0 END
	  where gid = game_id;
END;
$BODY$;
