/* Conditionally drop grandma table and grandma_s sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('GRANDMA','GRANDMA_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      /* Use the cascade constraints to drop the dependent constraint. */
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create the table. */
CREATE TABLE GRANDMA
( grandma_id     NUMBER       CONSTRAINT grandma_nn1 NOT NULL
, grandma_house  VARCHAR2(30) CONSTRAINT grandma_nn2 NOT NULL
, created_by     NUMBER       CONSTRAINT grandma_nn3 NOT NULL
, CONSTRAINT grandma_pk       PRIMARY KEY (grandma_id)
);
 
/* Create the sequence. */
CREATE SEQUENCE grandma_seq;
 
/* Conditionally drop a table and sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('TWEETIE_BIRD','TWEETIE_BIRD_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create the table with primary and foreign key out-of-line constraints. */
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     NUMBER        CONSTRAINT tweetie_bird_nn1 NOT NULL
, tweetie_bird_house  VARCHAR2(30)  CONSTRAINT tweetie_bird_nn2 NOT NULL
, grandma_id          NUMBER        CONSTRAINT tweetie_bird_nn3 NOT NULL
, created_by          NUMBER        CONSTRAINT tweetie_bird_nn4 NOT NULL
, CONSTRAINT tweetie_bird_pk        PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES GRANDMA (GRANDMA_ID)
);
 
/* Create sequence. */
CREATE SEQUENCE tweetie_bird_seq;

CREATE OR REPLACE
  PACKAGE sylvester IS
  
  /* Three variable length strings. */
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_name    VARCHAR2  );

  /* Two variable length strings and a number. */  
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_id      NUMBER   );

END sylvester;
/

CREATE OR REPLACE
  PACKAGE BODY sylvester IS

  /* Procedure warner_brother with user name. */
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_id      NUMBER  ) IS
 
    /* Declare a local variable for an existing grandma_id. */
    lv_grandma_id   NUMBER;
 
    FUNCTION get_grandma_id
    ( pv_grandma_house  VARCHAR2 ) RETURN NUMBER IS
 
      /* Initialized local return variable. */
      lv_retval  NUMBER := 0;  -- Default value is 0.
 
      /* A cursor that lookups up a grandma's ID by their name. */
      CURSOR find_grandma_id
      ( cv_grandma_house  VARCHAR2 ) IS
        SELECT grandma_id
        FROM   grandma
        WHERE  grandma_house = cv_grandma_house;
 
    BEGIN   
      /* Assign a grandma_id as the return value when a row exists. */
      FOR i IN find_grandma_id(pv_grandma_house) LOOP
        lv_retval := i.grandma_id;
      END LOOP;
 
      /* Return 0 when no row found and the grandma_id when a row is found. */
      RETURN lv_retval;
    END get_grandma_id;
 
  BEGIN
    /* Set the savepoint. */
    SAVEPOINT starting;
 
    /*
     *  Identify whether a member account exists and assign it's value
     *  to a local variable.
     */
    lv_grandma_id := get_grandma_id(pv_grandma_house);
  
    /*
     *  Conditionally insert a new member account into the member table
     *  only when a member account does not exist.
     */
    IF lv_grandma_id = 0 THEN
 
      /* Insert grandma. */
      INSERT INTO grandma
      ( grandma_id
      , grandma_house
      , created_by )
      VALUES
      ( grandma_seq.NEXTVAL
      , pv_grandma_house
      , pv_system_user_id  );
	  
      /* Assign grandma_seq.currval to local variable. */
      lv_grandma_id := grandma_seq.CURRVAL;
 
    END IF;
 
    /* Insert tweetie bird. */
    INSERT INTO tweetie_bird
    ( tweetie_bird_id
    , tweetie_bird_house 
    , grandma_id
    , created_by )
    VALUES
    ( tweetie_bird_seq.NEXTVAL
    , pv_tweetie_bird_house
    , lv_grandma_id
    , pv_system_user_id );

    /* If the program gets here, both insert statements work. Commit it. */
    COMMIT;
 
  EXCEPTION
    /* When anything is broken do this. */
    WHEN OTHERS THEN
      /* Until any partial results. */
      ROLLBACK TO starting;
  END;
  
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_name    VARCHAR2  ) IS
  
    /* Define a local variable. */
	lv_system_user_id  NUMBER := 0;

    FUNCTION get_system_user_id
    ( pv_system_user_name  VARCHAR2 ) RETURN NUMBER IS
 
      /* Initialized local return variable. */
      lv_retval  NUMBER := 0;  -- Default value is 0.
 
      /* A cursor that lookups up a grandma's ID by their name. */
      CURSOR find_system_user_id
      ( cv_system_user_id  VARCHAR2 ) IS
        SELECT system_user_id
        FROM   system_user
        WHERE  system_user_name = pv_system_user_name;
 
    BEGIN   
      /* Assign a grandma_id as the return value when a row exists. */
      FOR i IN find_system_user_id(pv_system_user_name) LOOP
        lv_retval := i.system_user_id;
      END LOOP;
 
      /* Return 0 when no row found and the grandma_id when a row is found. */
      RETURN lv_retval;
    END get_system_user_id;
	
  BEGIN
  
    /* Convert a system_user_name to system_user_id. */
	lv_system_user_id := get_system_user_id(pv_system_user_name);
	
	/* Call the warner_brother procedure. */
	warner_brother
    ( pv_grandma_house      => pv_grandma_house
    , pv_tweetie_bird_house => pv_tweetie_bird_house
    , pv_system_user_id     => lv_system_user_id  );
  
  EXCEPTION
    /* When anything is broken do this. */
    WHEN OTHERS THEN
      /* Until any partial results. */
      ROLLBACK TO starting;
  END;  
  
END sylvester;
/


/* Test the warner_brother procedure. */
BEGIN
  sylvester.warner_brother( pv_grandma_house      => 'Blue House'
                          , pv_tweetie_bird_house => 'Cage'
				          , pv_system_user_name   => 'DBA 3' );
  sylvester.warner_brother( pv_grandma_house      => 'Blue House'
                          , pv_tweetie_bird_house => 'Tree House'
				          , pv_system_user_id     =>  4 );
END;
/

/* Query results from warner_brother procedure. */
COL grandma_id          FORMAT 9999999  HEADING "Grandma|ID #"
COL grandma_house       FORMAT A14      HEADING "Grandma House"
COL created_by          FORMAT 9999999  HEADING "Created|By"
COL tweetie_bird_id     FORMAT 9999999  HEADING "Tweetie|Bird ID"
COL tweetie_bird_house  FORMAT A18      HEADING "Tweetie Bird House"
SELECT *
FROM   grandma g INNER JOIN tweetie_bird tb
ON     g.grandma_id = tb.grandma_id;
