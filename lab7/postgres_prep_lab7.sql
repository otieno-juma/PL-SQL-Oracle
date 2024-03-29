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

/* Drop the funciton conditionally. */
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

/* Select from the result of the function. */
SELECT * FROM getAvenger('Asgardian');
