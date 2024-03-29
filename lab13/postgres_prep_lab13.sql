/* Conditionally drop grandma table and grandma_s sequence. */
DROP TABLE IF EXISTS grandma CASCADE;
 
/* Create the table. */
SELECT 'CREATE TABLE grandma' AS statement;
CREATE TABLE GRANDMA
( grandma_id     SERIAL
, grandma_house  VARCHAR(30)  NOT NULL
, PRIMARY KEY (grandma_id)
);
 
/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS tweetie_bird CASCADE;
 
/* Create the table with primary and foreign key out-of-line constraints. */
SELECT 'CREATE TABLE tweetie_bird' AS statement;
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     SERIAL
, tweetie_bird_house  VARCHAR(30)   NOT NULL
, grandma_id          INTEGER       NOT NULL
, PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES grandma (grandma_id)
);

/* Conditionally drop a table and sequence. */
DROP TABLE IF EXISTS grandma_log CASCADE;

/* Create grandma logging table. */
SELECT 'CREATE TABLE grandma_log' AS statement;
CREATE TABLE grandma_log
( grandma_log_id     SERIAL
, trigger_name       VARCHAR(30)
, trigger_timing     VARCHAR(6)
, trigger_event      VARCHAR(6)
, trigger_type       VARCHAR(12)
, old_grandma_house  VARCHAR(30)
, new_grandma_house  VARCHAR(30));

DROP FUNCTION IF EXISTS grandma_dml_f;

CREATE FUNCTION grandma_dml_f()
  RETURNS trigger AS
$$
DECLARE
  /* Declare local trigger-scope variables. */
  lv_trigger_name   VARCHAR(30) := 'GRANDMA_DML_T';
  lv_trigger_event  VARCHAR(6);
  lv_trigger_type   VARCHAR(12) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR(6) := 'BEFORE';
BEGIN
  IF old.grandma_id IS NULL THEN
    lv_trigger_event := 'INSERT';
  ELSE
    lv_trigger_event := 'UPDATE';
  END IF;
  
  /* Log event into the grandma_log table. */
  INSERT INTO grandma_log
  ( trigger_name
  , trigger_event
  , trigger_type
  , trigger_timing
  , old_grandma_house
  , new_grandma_house )
  VALUES
  ( lv_trigger_name
  , lv_trigger_event
  , lv_trigger_type
  , lv_trigger_timing
  , old.grandma_house
  , new.grandma_house );
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER grandma_log_t
  BEFORE INSERT OR UPDATE ON grandma
  FOR EACH ROW EXECUTE FUNCTION grandma_dml_f();
  
INSERT INTO grandma
( grandma_house )
VALUES
( 'Red' );

UPDATE grandma
SET    grandma_house = 'Yellow'
WHERE  grandma_house = 'Red';

SELECT * FROM grandma_log;
