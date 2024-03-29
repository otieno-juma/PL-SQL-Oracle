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
, CONSTRAINT tweetie_bird_pk        PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
  REFERENCES GRANDMA (GRANDMA_ID)
);
 
/* Create sequence. */
CREATE SEQUENCE tweetie_bird_seq;

/* Conditionally drop a table and sequence. */
BEGIN
  FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('GRANDMA_LOG','GRANDMA_LOG_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/

/* Create logging table. */
CREATE TABLE grandma_log
( grandma_log_id     NUMBER
, trigger_name       VARCHAR2(30)
, trigger_timing     VARCHAR2(6)
, trigger_event      VARCHAR2(6)
, trigger_type       VARCHAR2(12)
, old_grandma_house  VARCHAR2(30)
, new_grandma_house  VARCHAR2(30));

/* Create logging sequence. */
CREATE SEQUENCE grandma_log_seq;

/* Create or replace dml trigger. */
CREATE OR REPLACE TRIGGER grandma_dml_t
  BEFORE INSERT OR UPDATE OR DELETE ON grandma
  FOR EACH ROW
DECLARE
  /* Declare local trigger-scope variables. */
  lv_sequence_id    NUMBER := grandma_log_seq.NEXTVAL;
  lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
  lv_trigger_event  VARCHAR2(6);
  lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN
  /* Check the event type. */
  IF INSERTING THEN
    lv_trigger_event := 'INSERT';
  ELSIF UPDATING THEN
    lv_trigger_event := 'UPDATE';
  ELSIF DELETING THEN
    lv_trigger_event := 'DELETE';
  END IF;
  
  /* Log event into the grandma_log table. */
  INSERT INTO grandma_log
  ( grandma_log_id
  , trigger_name
  , trigger_event
  , trigger_type
  , trigger_timing
  , old_grandma_house
  , new_grandma_house )
  VALUES
  ( lv_sequence_id
  , lv_trigger_name
  , lv_trigger_event
  , lv_trigger_type
  , lv_trigger_timing
  , :old.grandma_house
  , :new.grandma_house );
END grandma_dml_t;
/

/* Test case for insert event trigger. */
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES
( grandma_seq.nextval
,'Red' );

/* Test case for update event trigger. */
UPDATE grandma
SET    grandma_house = 'Yellow'
WHERE  grandma_house = 'Red';

/* Test case for delete event trigger. */
DELETE 
FROM   grandma
WHERE  grandma_house = 'Yellow';

/* Query the results from the grandma_log table. */
COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;

/* Create or replace autonomous procedure. */
CREATE OR REPLACE 
  PROCEDURE write_grandma_log
  ( pv_trigger_name       VARCHAR2
  , pv_trigger_event      VARCHAR2
  , pv_trigger_type       VARCHAR2
  , pv_trigger_timing     VARCHAR2
  , pv_old_grandma_house  VARCHAR2
  , pv_new_grandma_house  VARCHAR2 ) IS
  
  /* Set the precompiler directive to autonomous. */
  PRAGMA autonomous_transaction;
BEGIN
    /* Log event into the grandma_log table. */
    INSERT INTO grandma_log
    ( grandma_log_id
    , trigger_name
    , trigger_event
    , trigger_type
    , trigger_timing
    , old_grandma_house
    , new_grandma_house )
    VALUES
    ( grandma_log_seq.nextval
    , pv_trigger_name
    , pv_trigger_event
    , pv_trigger_type
    , pv_trigger_timing
    , pv_old_grandma_house
    , pv_new_grandma_house );
	
	/* Commit the transaction. */
	COMMIT;	
EXCEPTION
  WHEN others THEN
    ROLLBACK;
END write_grandma_log;
/

/* Create or replace dml trigger. */
CREATE OR REPLACE TRIGGER grandma_dml_t
  BEFORE INSERT OR UPDATE OR DELETE ON grandma
  FOR EACH ROW
DECLARE
  /* Declare local trigger-scope variables. */
  lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
  lv_trigger_event  VARCHAR2(6);
  lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
  lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN
  /* Check the event type. */
  IF INSERTING THEN
    lv_trigger_event := 'INSERT';
  ELSIF UPDATING THEN
    lv_trigger_event := 'UPDATE';
  ELSIF DELETING THEN
    lv_trigger_event := 'DELETE';
  END IF;
  
  /* Log event into the grandma_log table. */
  write_grandma_log(
      pv_trigger_name      => lv_trigger_name
    , pv_trigger_event     => lv_trigger_event
    , pv_trigger_type      => lv_trigger_type
    , pv_trigger_timing    => lv_trigger_timing
    , pv_old_grandma_house => :old.grandma_house
    , pv_new_grandma_house => :new.grandma_house );

END grandma_dml_t;
/

/* Test case for insert event trigger. */
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES
( grandma_seq.nextval
,'Blue' );

/* Test case for update event trigger. */
UPDATE grandma
SET    grandma_house = 'Green'
WHERE  grandma_house = 'Blue';

/* Test case for delete event trigger. */
DELETE 
FROM   grandma
WHERE  grandma_house = 'Green';

/* Query the results from the grandma_log table. */
COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;
