/* Conditionally drop cartoon_user table. */
DROP TABLE IF EXISTS cartoon_user CASCADE;

/* Create cartoon_user table. */
CREATE TABLE cartoon_user
( cartoon_user_id    SERIAL
, cartoon_user_name  VARCHAR(30)  NOT NULL
, PRIMARY KEY (cartoon_user_id)
);

/* Seed the cartoon_user table. */
INSERT INTO cartoon_user
( cartoon_user_name )
VALUES
 ('Bugs Bunny')
,('Wylie Coyote')
,('Elmer Fudd');

/* Conditionally drop grandma table. */
DROP TABLE IF EXISTS grandma CASCADE;
 
/* Create the table. */
CREATE TABLE GRANDMA
( grandma_id     SERIAL
, grandma_house  VARCHAR(30)  NOT NULL
, created_by     INTEGER      NOT NULL
, PRIMARY KEY (grandma_id)
, CONSTRAINT grandma_fk       FOREIGN KEY (created_by)
  REFERENCES cartoon_user (cartoon_user_id)
);
 
/* Conditionally drop a table. */
DROP TABLE IF EXISTS tweetie_bird CASCADE;
 
/* Create the table with primary and foreign key out-of-line constraints. */
SELECT 'CREATE TABLE tweetie_bird' AS command;
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     SERIAL
, tweetie_bird_house  VARCHAR(30)   NOT NULL
, grandma_id          INTEGER       NOT NULL
, created_by          INTEGER       NOT NULL
, PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk1        FOREIGN KEY (grandma_id)
  REFERENCES grandma (grandma_id)
, CONSTRAINT tweetie_bird_fk2        FOREIGN KEY (created_by)
  REFERENCES cartoon_user (cartoon_user_id)
);

/* Create function get_cartoon_user_id function. */
CREATE OR REPLACE
  FUNCTION get_cartoon_user_id
  ( IN pv_cartoon_user_name  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
 
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_cartoon_user_id CURSOR 
    ( cv_cartoon_user_name  VARCHAR ) FOR
      SELECT cartoon_user_id
      FROM   cartoon_user
      WHERE  cartoon_user_name = cv_cartoon_user_name;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_cartoon_user_id(pv_cartoon_user_name) LOOP
      lv_retval := i.cartoon_user_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Create function get_grandma_id function. */
CREATE OR REPLACE
  FUNCTION get_grandma_id
  ( IN pv_grandma_house  VARCHAR ) RETURNS INTEGER AS
$$
  /* Required for PL/pgSQL programs. */
  DECLARE
 
    /* Local return variable. */
    lv_retval  INTEGER := 0;  -- Default value is 0.
 
    /* Use a cursor, which will not raise an exception at runtime. */
    find_grandma_id CURSOR 
    ( cv_grandma_house  VARCHAR ) FOR
      SELECT grandma_id
      FROM   grandma
      WHERE  grandma_house = cv_grandma_house;
 
  BEGIN  
 
    /* Assign a value when a row exists. */
    FOR i IN find_grandma_id(pv_grandma_house) LOOP
      lv_retval := i.grandma_id;
    END LOOP;
 
    /* Return 0 when no row found and the ID # when row found. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/* Create or replace procedure warner_brother. */
CREATE OR REPLACE
  PROCEDURE warner_brother
  ( IN pv_grandma_house       VARCHAR
  , IN pv_tweetie_bird_house  VARCHAR
  , IN pv_cartoon_user_id     INTEGER ) AS
$$ 
  /* Required for PL/pgSQL programs. */
  DECLARE
 
  /* Declare a local variable for an existing grandma_id. */
  lv_grandma_id   INTEGER;
 
BEGIN  
  /* Check for existing grandma row. */
  lv_grandma_id := get_grandma_id(pv_grandma_house);
  IF lv_grandma_id = 0 THEN 
    /* Insert grandma. */
    INSERT INTO grandma
    ( grandma_house
    , created_by )	
    VALUES
    ( pv_grandma_house
    , pv_cartoon_user_id )
    RETURNING grandma_id INTO lv_grandma_id;
  END IF;
 
  /* Insert tweetie bird. */
  INSERT INTO tweetie_bird
  ( tweetie_bird_house 
  , grandma_id
  , created_by )
  VALUES
  ( pv_tweetie_bird_house
  , lv_grandma_id
  , pv_cartoon_user_id );
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE '[%] [%]', SQLERRM, SQLSTATE;  
END;
$$ LANGUAGE plpgsql;

/* Create or replace procedure warner_brother. */
CREATE OR REPLACE
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR
  , pv_tweetie_bird_house  VARCHAR
  , pv_cartoon_user_name   VARCHAR ) AS
$$ 
  /* Required for PL/pgSQL programs. */
  DECLARE
 
  /* Declare a local variable for an existing grandma_id. */
  lv_grandma_id       INTEGER;
  lv_cartoon_user_id  INTEGER;
 
BEGIN  
  /* Check for existing grandma row. */
  lv_cartoon_user_id := get_cartoon_user_id(pv_cartoon_user_name);

  /*  */
  CALL warner_brother( pv_grandma_house
                     , pv_tweetie_bird_house
					 , lv_cartoon_user_id );
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE NOTICE '[%] [%]', SQLERRM, SQLSTATE;  
END;
$$ LANGUAGE plpgsql;

/* Test the warner_brother procedure. */
DO
$$
BEGIN
  /* Insert the yellow house. */
  CALL warner_brother( 'Yellow House', 'Cage', 3);
  CALL warner_brother( 'Yellow House', 'Tree House', 3);
 
  /* Insert the red house. */
  CALL warner_brother( 'Red House', 'Cage', 'Bugs Bunny');
  CALL warner_brother( 'Red House', 'Tree House', 'Bugs Bunny');
END;
$$ LANGUAGE plpgsql;

/* Query data set from grandma and tweetie_bird tables. */
SELECT g.grandma_id
,      g.grandma_house
,      g.created_by
,      tb.tweetie_bird_id
,      tb.tweetie_bird_house
,      tb.created_by
FROM   grandma g INNER JOIN tweetie_bird tb
ON     g.grandma_id = tb.grandma_id;
