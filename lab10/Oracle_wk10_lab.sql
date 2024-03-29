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
( tweetie_bird_id     NUMBER       CONSTRAINT tweetie_bird_nn1 NOT NULL
, tweetie_bird_house  VARCHAR2(30) CONSTRAINT tweetie_bird_nn2 NOT NULL
, grandma_id          NUMBER       CONSTRAINT tweetie_bird_nn3 NOT NULL
, created_by          NUMBER       CONSTRAINT tweetie_bird_nn4 NOT NULL
, CONSTRAINT tweetie_bird_pk       PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk       FOREIGN KEY (grandma_id)
  REFERENCES GRANDMA (GRANDMA_ID)
);
 
/* Create sequence. */
CREATE SEQUENCE tweetie_bird_seq;

CREATE OR REPLACE
  PACKAGE sylvester IS
  
  /* This one takes three strings. */
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_name    VARCHAR2  );
  
  /* This one takes two strings and a number. */
  PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2
  , pv_system_user_id      NUMBER   );

END sylvester;
/

CREATE OR REPLACE
  PACKAGE BODY sylvester IS

  /* This one takes two strings and a number. */
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

  /* This one takes three strings. */
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

/*Task:
Create the following account_creation package specification*/

CREATE OR REPLACE
  PACKAGE account_creation IS
  
  PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
  , pv_last_name           VARCHAR2
  , pv_contact_type        VARCHAR2
  , pv_account_number      VARCHAR2
  , pv_member_type         VARCHAR2
  , pv_credit_card_number  VARCHAR2
  , pv_credit_card_type    VARCHAR2
  , pv_street_address      VARCHAR2
  , pv_city                VARCHAR2
  , pv_state_province      VARCHAR2
  , pv_postal_code         VARCHAR2
  , pv_address_type        VARCHAR2
  , pv_country_code        VARCHAR2
  , pv_area_code           VARCHAR2
  , pv_telephone_number    VARCHAR2
  , pv_telephone_type      VARCHAR2
  , pv_user_id             NUMBER );

  PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
  , pv_last_name           VARCHAR2
  , pv_contact_type        VARCHAR2
  , pv_account_number      VARCHAR2
  , pv_member_type         VARCHAR2
  , pv_credit_card_number  VARCHAR2
  , pv_credit_card_type    VARCHAR2
  , pv_street_address      VARCHAR2
  , pv_city                VARCHAR2
  , pv_state_province      VARCHAR2
  , pv_postal_code         VARCHAR2
  , pv_address_type        VARCHAR2
  , pv_country_code        VARCHAR2
  , pv_area_code           VARCHAR2
  , pv_telephone_number    VARCHAR2
  , pv_telephone_type      VARCHAR2
  , pv_user_name           VARCHAR2 );
  
END account_creation;
/



CREATE OR REPLACE
  PACKAGE BODY account_creation IS

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

  PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
  , pv_last_name           VARCHAR2
  , pv_contact_type        VARCHAR2
  , pv_account_number      VARCHAR2
  , pv_member_type         VARCHAR2
  , pv_credit_card_number  VARCHAR2
  , pv_credit_card_type    VARCHAR2
  , pv_street_address      VARCHAR2
  , pv_city                VARCHAR2
  , pv_state_province      VARCHAR2
  , pv_postal_code         VARCHAR2
  , pv_address_type        VARCHAR2
  , pv_country_code        VARCHAR2
  , pv_area_code           VARCHAR2
  , pv_telephone_number    VARCHAR2
  , pv_telephone_type      VARCHAR2
  , pv_user_name           VARCHAR2 ) IS
  
  BEGIN
      INSERT INTO MEMBER (
         member_id 
        ,member_type
        ,account_number
        ,credit_card_number
        ,credit_card_type
        ,created_by
        ,creation_date
        ,last_update_by
        ,last_update_date)
    VALUES
        (member_s1.NEXTVAL
        ,lv_member_type
        ,pv_account_number
        ,pv_credit_card_number
        ,lv_credit_card_type
        ,lv_created_by
        ,lv_current-date
        ,lv_update_by);
    
    lv_member_id := member_s1.CURRVAL;  
  
  /* Insert into contact table */
  INSERT INTO CONTACT
    (contact_id
     ,member_id
     ,contact_type
     ,last_name
     ,first_name
     ,middle_name
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update-date )
  VALUES 
    (contact_s1.NEXTVAL
     ,lv_member_id
     ,lv_cotact_type
     ,lv_last_name
     ,lv_first_name
     ,lv_middle_name
     ,lv_created_by
     ,lv_current_date
     ,lv_last_updated_by
     ,lv_current_date );
    
    lv_contact_id := contact_s1.CURRVAL;

  /* Insert into address table */
  INSERT INTO ADDRESS
    (address_id
     ,contact_id
     ,address-type
     ,city
     ,state_province
     ,postal_code
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update_date )
  VALUES 
    (address_s1.NEXTVAL
     ,lv_contact_id
     ,lv_address_type
     ,lv_city
     ,lv_state_province
     ,lv_postal_code
     ,lv_current_date
     ,lv_updated_by
     ,lv_current_date );
  lv_address_id := address.s1.CURRVAL

  /* Insert into street_address table (assuming it's a separate table) */
  INSERT INTO STREET_ADDRESS
    (address_id,
     ,line_number
     ,street_address
     ,creation_date
     ,last_updated_by
     ,last_update-date )
  VALUES 
    (street_address_s1.NEXTVAL
     ,lv_address_id
     ,pv_street_address
     ,lv_created_by
     ,lv_updated_by
     ,lv_current_date );

  /* Insert into telephone table */
  INSERT INTO TELEPHONE
    (telephone_id
     ,contact_id
     ,address_id
     ,telephone_type
     ,country_code
     ,area_code
     ,telephone_number
     ,created_by
     ,craetion_date
     ,last_updated-by
     ,last_update_date )
  VALUES 
    (telephone_s1.NEXTVAL
     ,lv_contact_id
     ,lv_address_id
     ,lv_telephone_type
     ,lv_country_code
     ,pv_area_code
     ,pv_telephone_number
     ,lv_created_by
     ,lv_current_date
     ,lv_updated_by
     ,lv_current_date );


   /* Commit the writes to all four tables. */
  COMMIT;

EXCEPTION
  /* Catch all errors. */
  WHEN OTHERS THEN
    /* Unremark the following line to generate an error message. */
    -- dbms_output.put_line('['||SQLERRM||']');
    ROLLBACK TO start_point;
 END insert_contact;
 /
 PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
  , pv_last_name           VARCHAR2
  , pv_contact_type        VARCHAR2
  , pv_account_number      VARCHAR2
  , pv_member_type         VARCHAR2
  , pv_credit_card_number  VARCHAR2
  , pv_credit_card_type    VARCHAR2
  , pv_street_address      VARCHAR2
  , pv_city                VARCHAR2
  , pv_state_province      VARCHAR2
  , pv_postal_code         VARCHAR2
  , pv_address_type        VARCHAR2
  , pv_country_code        VARCHAR2
  , pv_area_code           VARCHAR2
  , pv_telephone_number    VARCHAR2
  , pv_telephone_type      VARCHAR2
  , pv_user_id             NUMBER ) IS

     v_user_id NUMBER;

  BEGIN
  
/*Convert pv_user_name to pv_user_id by querying system_user tabl*/
    SELECT system_user_id INTO v_user_id
    FROM system_user
    WHERE system_user_name = pv_user_name;

/*Call the first insert_contact procedure 
with the converted user ID*/
    insert_contact(pv_first_name, pv_middle_name, pv_last_name, pv_contact_type,
                   pv_account_number, pv_member_type, pv_credit_card_number,
                   pv_credit_card_type, pv_street_address, pv_city, v_user_id);

  END insert_contact;
  
END account_creation;
/

UPDATE system_user
SET    system_user_name = system_user_name || ' ' || system_user_id
WHERE  system_user_name = 'DBA';



BEGIN
  DELETE FROM telephone WHERE contact_id > 1007;
  DELETE FROM street_address WHERE address_id > 1007;
  DELETE FROM address WHERE address_id > 1007;
  DELETE FROM contact WHERE contact_id > 1007;
  DELETE FROM member WHERE member_id > 1007;
END;
/

BEGIN
  /* Call procedure once. */
  account_creation.insert_contact(
      pv_first_name         => 'Charles'
    , pv_middle_name        => 'Francis'
    , pv_last_name          => 'Xavier'
    , pv_contact_type       => 'CUSTOMER'
    , pv_account_number     => 'SLC-000008'
    , pv_member_type        => 'INDIVIDUAL'
    , pv_credit_card_number => '7777-6666-5555-4444'
    , pv_credit_card_type   => 'DISCOVER_CARD'
    , pv_street_address     => '1407 Graymalkin Lane' 
    , pv_city               => 'Bayville'
    , pv_state_province     => 'New York'
    , pv_postal_code        => '10032'
    , pv_address_type       => 'HOME'
    , pv_country_code       => '001'
    , pv_area_code          => '207'
    , pv_telephone_number   => '111-1234'
    , pv_telephone_type     => 'HOME'
    , pv_user_name          => 'DBA 2'
    );

  /* Call procedure twice. */
  account_creation.insert_contact(
      pv_first_name         => 'James'
    , pv_last_name          => 'Xavier'
    , pv_contact_type       => 'CUSTOMER'
    , pv_account_number     => 'SLC-000008'
    , pv_member_type        => 'INDIVIDUAL'
    , pv_credit_card_number => '7777-6666-5555-4444'
    , pv_credit_card_type   => 'DISCOVER_CARD'
    , pv_street_address     => '1407 Graymalkin Lane' 
    , pv_city               => 'Bayville'
    , pv_state_province     => 'New York'
    , pv_postal_code        => '10032'
    , pv_address_type       => 'HOME'
    , pv_country_code       => '001'
    , pv_area_code          => '207'
    , pv_telephone_number   => '111-1234'
    , pv_telephone_type     => 'HOME'
    , pv_user_name          =>  4
    );
END;
/

COLUMN account_number  FORMAT A10  HEADING "Account|Number"
COLUMN contact_name    FORMAT A30  HEADING "Contact Name"
SELECT m.account_number
,      c.last_name ||', '||c.first_name AS contact_name
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id
WHERE  m.account_number = 'SLC-000008';