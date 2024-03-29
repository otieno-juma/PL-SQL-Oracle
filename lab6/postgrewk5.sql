/*Create a lyric record type:
The first member of the type should have days as its name and it should be a variable length string 8 characters in length.
The second member of the type should have gift as its name and it should be a variable length string 24 characters in length.*/

CREATE TYPE lyrics AS (
  days VARCHAR(8),
  gift VARCHAR(36)
);

CREATE OR REPLACE FUNCTION twelve_days
(IN pv_days VARCHAR(8)[]
 , IN pv_gifts LYRIC[])
RETURNS VARCHAR(36)[] AS $$

DECLARE
  lv_retval VARCHAR(36)[] := ARRAY[]::VARCHAR(36)[];
  
BEGIN
  FOR i IN 1..ARRAY_LENGTH(pv_days, 1) LOOP
    lv_retval := ARRAY_APPEND(lv_retval, 'On the ' || pv_days(i) || ' day of Christmas' );
    lv_retval := ARRAY_APPEND(lv_retval, 'my true love sent to me' );
	FOR j IN REVERSE i..1 LOOP
      IF j = 1
	  	lv_retval := ARRAY_APPEND(lv_retval,'A' ||pv_gifts(j),gift);
	  ELSE
	  	lv_retval := ARRAY_APPEND(lv_retval, '-' ||pv_gifts(J),days|| ' ' ||pv_gifts(j),gift);
      END IF;
	  lv_vetral := ARRAY_APPEND(lv_retval,CHAR(13));
    END LOOP;
	
  END LOOP;
  RETURN lv_vetral;
END;
$$ LANGUAGE plpgsql;

SELECT UNNEST(twelve_days(ARRAY['first','second','third','fourth'
                          ,'fifth','sixth','seventh','eighth'
                          ,'nineth','tenth','eleventh','twelfth']
                         ,ARRAY[('and a','Partridge in a pear tree')::lyric
                          ,('Two','Turtle doves')::lyric
                          ,('Three','French hens')::lyric
                          ,('Four','Calling birds')::lyric
                          ,('Five','Golden rings')::lyric
                          ,('Six','Geese a laying')::lyric
                          ,('Seven','Swans a swimming')::lyric
                          ,('Eight','Maids a milking')::lyric
                          ,('Nine','Ladies dancing')::lyric
                          ,('Ten','Lords a leaping')::lyric
                          ,('Eleven','Pipers piping')::lyric
                          ,('Twelve','Drummers drumming')::lyric])) AS "12-Days of Christmas";
						  

DO
$$  
DECLARE 
  /* Initialize the collection of lyrics:
   *   - An array of 114 elements of 36 character variable length strings.
   */
	lv_days VARCHAR(8)[]:=ARRAY[ 'first','second','third','fourth','fifth','sixth'
								,'seventh','eighth','nineth','tenth','eleventh','twelfth'];
	lv_gifts lyrics[]:=ARRAY[('and a','Partridge in a pear tree')::lyric
                          ,('Two','Turtle doves')::lyric
                          ,('Three','French hens')::lyric
                          ,('Four','Calling birds')::lyric
                          ,('Five','Golden rings')::lyric
                          ,('Six','Geese a laying')::lyric
                          ,('Seven','Swans a swimming')::lyric
                          ,('Eight','Maids a milking')::lyric
                          ,('Nine','Ladies dancing')::lyric
                          ,('Ten','Lords a leaping')::lyric
                          ,('Eleven','Pipers piping')::lyric
                          ,('Twelve','Drummers drumming')::lyric])) AS "12-Days of Christmas";

/* Declare an lv_song array without initializing values.*/

lv_song VARCHAR(36)[]:=ARRAY[]::VARCHAR(36)[];

BEGIN
  /* Call the twelve_days function and assign the results to a local song variable. */
  lv_song:=twelve_days(lv-days,lv_gifts);
  
  /* Read the lines from the local song variable. */
  FOR i IN 1..ARRAY_LENGTH(lv_song,1) LOOP
    RAISE NOTICE '%', lv_song(i);
  END LOOP;
END;
$$
