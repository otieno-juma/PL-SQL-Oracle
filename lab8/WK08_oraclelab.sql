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

/* Create or replace procedure warner_brother. */
CREATE OR REPLACE PROCEDURE warner_brother
  ( pv_grandma_house       VARCHAR2
  , pv_tweetie_bird_house  VARCHAR2 ) IS
 
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
    , grandma_house )
    VALUES
    ( grandma_seq.NEXTVAL
    , pv_grandma_house );
    /* Assign grandma_seq.currval to local variable. */
    lv_grandma_id := grandma_seq.CURRVAL;
 
  END IF;
 
  /* Insert tweetie bird. */
  INSERT INTO tweetie_bird
  ( tweetie_bird_id
  , tweetie_bird_house 
  , grandma_id )
  VALUES
  ( tweetie_bird_seq.NEXTVAL
  , pv_tweetie_bird_house
  , lv_grandma_id );
 
  /* If the program gets here, both insert statements work. Commit it. */
  COMMIT;
 
EXCEPTION
  /* When anything is broken do this. */
  WHEN OTHERS THEN
    /* Until any partial results. */
    ROLLBACK TO starting;
END;
/

/* Test the warner_brother procedure. */
BEGIN
  warner_brother( pv_grandma_house      => 'Yellow House'
                , pv_tweetie_bird_house => 'Cage');
  warner_brother( pv_grandma_house      => 'Yellow House'
                , pv_tweetie_bird_house => 'Tree House');
END;
/

/* Query results from warner_brother procedure. */
COL grandma_id          FORMAT 9999999  HEADING "Grandma|ID #"
COL grandma_house       FORMAT A20      HEADING "Grandma House"
COL tweetie_bird_id     FORMAT 9999999  HEADING "Tweetie|Bird ID"
COL tweetie_bird_house  FORMAT A20      HEADING "Tweetie Bird House"
SELECT *
FROM   grandma NATURAL JOIN tweetie_bird;



/*Create a insert_contact function that writes to the following five tables:
member
contact
address
street_address
telephone*/
/*writes to all five tables, and change the SELECT-INTO 
logic into a standalone get_user_id local function like 
the get_lookup_type local function*/


CREATE OR REPLACE PROCEDURE insert_contact
( pv_first_name          VARCHAR2
, pv_middle_name         VARCHAR2
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

  /* Declare local constants. */
  lv_current_date      DATE := TRUNC(SYSDATE);

  /* Declare a who-audit variables. */
  lv_member_id         NUMBER := 0; 
  lv_created_by        NUMBER;
  lv_updated_by        NUMBER;
  lv_system_user_id    NUMBER;
 /*Additional variables for sequencing*/
  lv_contact_id NUMBER := 0;
  lv_address_id NUMBER := 0;
  
  /* Declare type variables. */
  lv_member_type       NUMBER;
  lv_credit_card_type  NUMBER;
  lv_contact_type      NUMBER;
  lv_address_type      NUMBER;
  lv_telephone_type    NUMBER;

  /* Define your get_user_id function here */
 FUNCTION get_lookup_type 
  ( pv_table_name    VARCHAR2
  , pv_column_name   VARCHAR2
  , pv_type_name     VARCHAR2 ) RETURN NUMBER IS
  
    /* Declare a return variable. */
    lv_retval  NUMBER := 0;
    
    /* Declare a local cursor. */
    CURSOR get_lookup_value
    ( cv_table_name    VARCHAR2
    , cv_column_name   VARCHAR2
    , cv_type_name     VARCHAR2 ) IS
      SELECT common_lookup_id
      FROM   common_lookup
      WHERE  common_lookup_table = cv_table_name
      AND    common_lookup_column = cv_column_name
      AND    common_lookup_type = cv_type_name;
      

  BEGIN

    /* Find a valid value. */
    FOR i IN get_lookup_value(pv_table_name, pv_column_name, pv_type_name) LOOP
      lv_retval := i.common_lookup_id;
    END LOOP;

    /* Return the value, where a 0 always fails the insert statements. */
    RETURN lv_retval;
  END get_lookup_type;
  
  /* Convert the member account_number into a surrogate member_id value. */
  FUNCTION get_member_id
  ( pv_account_number VARCHAR2 ) RETURN NUMBER IS
  
    /* Local return variable. */
    lv_retval  NUMBER := 0;  -- Default value is 0.
 
    /* A cursor that lookups up a member's ID by their account number. */
    CURSOR find_member_id
    ( cv_account_number VARCHAR2 ) IS
      SELECT member_id
      FROM member
      WHERE account_number = cv_account_number;
    
  BEGIN  
    /* 
     *  Write a FOR-LOOP that:
     *    Assign a member_id as the return value when a row exists.
     */
    FOR i IN find_member-id(pv_account_number) LOOP
        lv_retval := i.member_id;
    END LOOP; 
    /* Return 0 when no row found and the member_id when a row is found. */
    RETURN lv_retval;
  END get_member_id;
  
BEGIN
  /* Get the member_type ID value. */
  lv_member_type := get_lookup_type('MEMBER','MEMBER_TYPE', pv_member_type);

  /* Get the credit_card_type ID value. */
  lv_credit_card_type := get_lookup_type('MEMBER','CREDIT_CARD_TYPE', pv_credit_card_type);

  /* Get the contact_type ID value. */
  lv_contact_type := get_lookup_type('CONTACT','CONTACT_TYPE', pv_contact_type);

  /* Get the address_type ID value. */
  lv_address_type := get_lookup_type('ADDRESS','ADDRESS_TYPE', pv_address_type);

  /* Get the telephone_type ID value. */
  lv_telephone_type := get_lookup_type('TELEPHONE','TELEPHONE_TYPE', pv_telephone_type);

  /*
   *  Convert the system_user_name value into a surrogate system_user_id value
   *  and assign the system_user_id value to the local lv_system_user_id variable.
   */
  SELECT system_user_id
  INTO   lv_system_user_id
  FROM   system_user
  WHERE  system_user_name = pv_user_name;

  /* Assign the system_user_id value to these local variables. */
  lv_created_by := lv_system_user_id;
  lv_updated_by := <lv_system_user_id;

  /* Set save point. */
  SAVEPOINT start_point;

  /*
   *  Identify whether a member account exists and assign it's value
   *  to a local variable.
   */
  lv_member_id := get_member_id(pv_account_number)
  IF lv_member_id = 0 THEN  
    /*
     *  Conditionally insert a new member account into the member table
     *  only when a member account does not exist.
     */
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
  END IF;
  
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

/*The first thing to do before testing the insert_contact procedure, 
 you should run the following update statement to ensure 
 all system_user_name values are unique:*/
UPDATE system_user
SET    system_user_name = system_user_name || ' ' || system_user_id
WHERE  system_user_name = 'DBA';

/*The second thing to do before testing 
the insert_contact procedure, you should run 
the following anonymous block program to clean prior test data:*/
BEGIN
  DELETE FROM telephone WHERE contact_id > 1018;
  DELETE FROM street_address WHERE address_id > 1018;
  DELETE FROM address WHERE address_id > 1018;
  DELETE FROM contact WHERE contact_id > 1018;
  DELETE FROM member WHERE member_id > 1018;
END;
/

/*Test your procedure with the following two anonymous blocks:*/
BEGIN
  /* Call procedure once. */
  insert_contact(
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
  insert_contact(
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
    , pv_user_name          => 'DBA 2'
    );
END;
/

/* query*/
COLUMN account_number  FORMAT A10  HEADING "Account|Number"
COLUMN contact_name    FORMAT A30  HEADING "Contact Name"
SELECT m.account_number
,      c.last_name ||', '||c.first_name AS contact_name
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id
WHERE  m.account_number = 'SLC-000008';









