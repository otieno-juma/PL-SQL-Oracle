/* Drop table unconditionally. */
DROP TABLE avenger;

/* Create avenger table. */
CREATE TABLE avenger
( avenger_id      NUMBER
, first_name      VARCHAR(30)
, last_name       VARCHAR(30)
, character_name  VARCHAR(30)
, species         VARCHAR(30));

/* Drop sequence unconditionally. */
DROP SEQUENCE avenger_seq;

/* Create a sequence starting with 1001. */
CREATE SEQUENCE avenger_seq START WITH 1001;

/* Insert 6-rows of data. */
INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Anthony','Stark','Iron Man','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES 
(avenger_seq.NEXTVAL,'Thor','Odinson','God of Thunder','Asgardian');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Steven','Rogers','Captain America','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Bruce','Banner','Hulk','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Clinton','Barton','Hackeye','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Natasha','Romanoff','Black Widow','Terran');


/* Drop the dependent before the dependency. */
DROP TYPE avenger_table;
DROP TYPE avenger_struct;

/* Create a record structure. */
CREATE OR REPLACE
  TYPE avenger_struct IS OBJECT
  ( first_name      VARCHAR(30)
  , last_name       VARCHAR(30)
  , character_name  VARCHAR(30));
/

/* Create an avenger table. */
CREATE OR REPLACE
  TYPE avenger_table IS TABLE OF avenger_struct;
/


/* Drop the funciton conditionally. */
DROP FUNCTION getAvenger;

/* Create the function. */
CREATE OR REPLACE
  FUNCTION getAvenger (pv_species IN VARCHAR) RETURN avenger_table IS
  
  /* Declare a return variable. */
  lv_retval  AVENGER_TABLE := avenger_table();

  /* Declare a dynamic cursor. */
  CURSOR get_avenger
  ( cv_species  VARCHAR2 ) IS
    SELECT a.first_name
    ,      a.last_name
    ,      a.character_name
    FROM   avenger a
    WHERE  a.species = cv_species;
  
  /* Local procedure to add to the song. */
  PROCEDURE ADD
  ( pv_input  AVENGER_STRUCT ) IS
  BEGIN
    lv_retval.EXTEND;
    lv_retval(lv_retval.COUNT) := pv_input;
  END ADD;
  
BEGIN
  /* Read through the cursor and assign to the UDT table. */
  FOR i IN get_avenger(pv_species) LOOP
    add(avenger_struct( i.first_name
                      , i.last_name
                      , i.character_name ));
  END LOOP;
  
  /* Return collection. */
  RETURN lv_retval;
END;
/

COL first_name      FORMAT A10
COL last_name       FORMAT A10
COL character_name  FORMAT A20

SELECT * FROM TABLE(getAvenger('Asgardian'));


CREATE OR REPLACE
  VIEW avenger_asgardian AS
  SELECT * FROM TABLE(getAvenger('Asgardian')); 
/

COL first_name      FORMAT A10
COL last_name       FORMAT A10
COL character_name  FORMAT A20

SELECT * FROM avenger_asgardian;

/*Create a sample conquistador table with the following columns:
An conquistador_id column, using a numeric data type.
An conquistador column, using a 30-character variable length string data type.
An actual_name column, using a 30-character variable length string data type.
An nationality column, using a 30-character variable length string data type.
An lang column, using a 2-character variable length string data type*/

/* Drop table unconditionally. */
DROP TABLE IF EXISTS conquistador;

/* Create conquistador table. */
CREATE TABLE conquistador
( conquistador_id NUMERIC
, conquistador VARCHAR(30)
, actual_name VARCHAR(30)
, nationality VARCHAR(30)
, lang VARCHAR(2));

/* Drop sequence unconditionally. */
DROP SEQUENCE IF EXISTS conquistador_seq;

/* Create a sequence starting with 1001. */
CREATE SEQUENCE conquistador_seq START WITH 1001;


/*You populate it with the following nine values:*/
/* Insert 9-rows of data. */
INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Juan de Fuca','Ioánnis Fokás','Greek','el');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES 
(conquistador_seq.NEXTVAL,'Nicolás de Federmán','Nikolaus Federmann','German','de');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Sebastián Caboto','Sebastiano Caboto','Venetian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Jorge de la Espira','Georg von Speyer','German','de');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Eusebio Francisco Kino','Eusebius Franz Kühn','Italian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Wenceslao Linck','Wenceslaus Linck','Bohemian','cs');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Fernando Consag','Ferdinand Konšcak','Croatian','sr');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Américo Vespucio','Amerigo Vespucci','Italian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Alejo García','Aleixo Garcia','Portuguese','pt');

/*Create a User-Defined Type (UDT) as the conquistador_struct object*/

/* Drop the dependent before the dependency. */
DROP TYPE IF EXISTS conquistador_table;
DROP TYPE IF EXISTS conquistador_struct;

/* Create a record structure. */
CREATE OR REPLACE
  TYPE conquistador_struct IS OBJECT
  ( conquistador VARCHAR(30)
  , actual_name VARCHAR(30)
  , nationality VARCHAR(30));
//*create a conquistador_table ADT of the conquistador_struct object type.*/
/* Create an conquistador table. */
CREATE OR REPLACE
  TYPE conquistador_table IS TABLE OF conquistador_struct; 
/


/* Drop the function conditionally. */
DROP FUNCTION IF EXISTS getConquistador;

/* Create the function. */
CREATE OR REPLACE
  FUNCTION getConquistador (pv_lang IN VARCHAR) RETURN conquistador_table IS
  
  /* Declare a return variable. */
  lv_retval  CONQUISTADOR_TABLE := conquistador_table();

  /* Declare a dynamic cursor. */
  CURSOR get_conquistador
  ( cv_lang  VARCHAR2 ) IS
    SELECT 
    c.conquistador
    ,c.actual_name
    ,c.nationality
    FROM conquistador c WHERE cv_lang = c.lang;
  
  /* Local procedure to add to the song. */
  PROCEDURE ADD
  ( pv_input  CONQUISTADOR_STRUCT ) IS
  BEGIN
    lv_retval.EXTEND;
    lv_retval(lv_retval.COUNT) := pv_input;
  END ADD;
  
BEGIN
  /* Read through the cursor and assign to the UDT table. */
  FOR i IN get_conquistador(pv_lang) LOOP
    add(conquistador_struct(i.conquistador
  , i.actual_name
  , i.nationality));
  END LOOP;
  
  /* Return collection. */
  RETURN lv_retval;
END;
/

/*Deploy the getConquistador function.
Accepts a pv_lang parameter of a 2-character variable length string data type.
Return a table of the conquistador_struct data type from the getConquistador function.*/

COL conquistador  FORMAT A21
COL actual_name   FORMAT A21
COL nationality   FORMAT A12

SELECT * FROM TABLE(getConquistador('de'));

CREATE OR REPLACE
  VIEW conquistador_de AS
  SELECT * FROM TABLE(getConquistador('de')); 
/

COL conquistador  FORMAT A21
COL actual_name   FORMAT A21
COL nationality   FORMAT A12

SELECT * FROM conquistador_de;
