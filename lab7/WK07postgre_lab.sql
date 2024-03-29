/* Drop table unconditionally. */
DROP TABLE IF EXISTS avenger;

/* Create avenger table. */
CREATE TABLE avenger
( avenger_id      SERIAL
, first_name      VARCHAR(30)
, last_name       VARCHAR(30)
, character_name  VARCHAR(30)
, species         VARCHAR(30));

/* Insert 6-rows of data. */
INSERT INTO avenger
( first_name, last_name, character_name, species )
VALUES
 ('Anthony','Stark','Iron Man','Terran')
,('Thor','Odinson','God of Thunder','Asgardian')
,('Steven','Rogers','Captain America','Terran')
,('Bruce','Banner','Hulk','Terran')
,('Clinton','Barton','Hackeye','Terran')
,('Natasha','Romanoff','Black Widow','Terran');

/* Drop the function conditionally. */
DROP FUNCTION IF EXISTS getAvenger;

/* Create the function. */
CREATE FUNCTION getAvenger (IN species_in VARCHAR(2))
  RETURNS TABLE
    ( first_name      VARCHAR(30)
    , last_name       VARCHAR(30)
    , character_name  VARCHAR(30)) AS
$$
BEGIN
  RETURN QUERY
  SELECT a.first_name
  ,      a.last_name
  ,      a.character_name
  FROM   avenger a
  WHERE  a.species = species_in;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM getAvenger('Asgardian');

CREATE OR REPLACE
  VIEW avenger_asgardian AS
  SELECT * FROM getAvenger('Asgardian'); 
  
SELECT * FROM avenger_asgardian;


/*Create a sample conquistador table with the following columns:
A conquistador_id column, using a numeric data type.
A conquistador column, using a 30-character variable length string data type.
An actual_name column, using a 30-character variable length string data type.
A nationality column, using a 30-character variable length string data type.
An lang column, using a 2-character variable length string data type.*/

/* Drop table unconditionally. */
DROP TABLE IF EXISTS conquistador;

/* Create avenger table. */
CREATE TABLE conquistador
( conquistador_id   SERIAL
, conquistador      VARCHAR(30)
, actual_name       VARCHAR(30)
, nationality       VARCHAR(30)
, lang              VARCHAR(2));


/*You populate the conquistador table with the following nine values:*/
/* Insert 9-rows of data. */
INSERT INTO conquistador
( conquistador
, actual_name
, nationality
, lang )
VALUES
 ('Juan de Fuca','Ioánnis Fokás','Greek','el')
,('Nicolás de Federmán','Nikolaus Federmann','German','de')
,('Sebastián Caboto','Sebastiano Caboto','Venetian','it')
,('Jorge de la Espira','Georg von Speyer','German','de')
,('Eusebio Francisco Kino','Eusebius Franz Kühn','Italian','it')
,('Wenceslao Linck','Wenceslaus Linck','Bohemian','cs')
,('Fernando Consag','Ferdinand Konšcak','Croatian','sr')
,('Américo Vespucio','Amerigo Vespucci','Italian','it')
,('Alejo García','Aleixo Garcia','Portuguese','pt');


/* Conditionally drop the type. */
DROP TYPE IF EXISTS conquistador_struct;

/* Create a type to use as a row structure. */
CREATE TYPE conquistador_struct AS
(
  conquistador VARCHAR(30),
  actual_name VARCHAR(30),
  nationality VARCHAR(30)
);

/* Drop the function conditionally. */
DROP FUNCTION IF EXISTS getConquistador;

/* Create a table function that returns a set of a structure. */
CREATE FUNCTION getConquistador (IN lang_in VARCHAR(2))
  RETURNS SETOF conquistador_struct AS
$$
BEGIN
  RETURN QUERY
  SELECT c.conquistador
  ,		 c.actual_name
  ,	 	 c.nationality
  FROM conquistador c
  WHERE lang_in = c.lang;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM getConquistador('de');

/* Drop the function conditionally. */
DROP FUNCTION IF EXISTS getConquistador;

/* Create a table function that returns a set of a structure. */
CREATE FUNCTION getConquistador (IN pv_lang VARCHAR(2))
  RETURNS SETOF conquistador_struct AS
$$
BEGIN
  RETURN QUERY
  SELECT * FROM conquistador WHERE lang = pv_lang;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM getConquistador('de');