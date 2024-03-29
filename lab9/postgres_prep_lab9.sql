/* Conditionally drop grandma table and grandma_s sequence. */
DROP TABLE IF EXISTS grandma CASCADE;
 
/* Create the table. */
CREATE TABLE GRANDMA
( grandma_id     SERIAL
, grandma_house  VARCHAR(30)  NOT NULL
, PRIMARY KEY (grandma_id)
);
 
/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS tweetie_bird CASCADE;
 
/* Create the table with primary and foreign key out-of-line constraints. */
SELECT 'CREATE TABLE tweetie_bird' AS command;
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     SERIAL
, tweetie_bird_house  VARCHAR(30)   NOT NULL
, grandma_id          INTEGER       NOT NULL
, PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES grandma (grandma_id)
);

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
  ( pv_grandma_house       VARCHAR
  , pv_tweetie_bird_house  VARCHAR ) AS
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
    ( grandma_house )
    VALUES
    ( pv_grandma_house )
    RETURNING grandma_id INTO lv_grandma_id;
  END IF;
 
  /* Insert tweetie bird. */
  INSERT INTO tweetie_bird
  ( tweetie_bird_house 
  , grandma_id )
  VALUES
  ( pv_tweetie_bird_house
  , lv_grandma_id );
 
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
  , pv_tweetie_bird_house  VARCHAR ) AS
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
    ( grandma_house )
    VALUES
    ( pv_grandma_house )
    RETURNING grandma_id INTO lv_grandma_id;
  END IF;
 
  /* Insert tweetie bird. */
  INSERT INTO tweetie_bird
  ( tweetie_bird_house 
  , grandma_id )
  VALUES
  ( pv_tweetie_bird_house
  , lv_grandma_id );
 
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
  CALL warner_brother( 'Yellow House', 'Cage');
  CALL warner_brother( 'Yellow House', 'Tree House');
 
  /* Insert the red house. */
  CALL warner_brother( 'Red House', 'Cage');
  CALL warner_brother( 'Red House', 'Tree House');
END;
$$ LANGUAGE plpgsql;
