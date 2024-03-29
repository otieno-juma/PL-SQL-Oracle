/*Create a days Attribute Data Type (ADT) type of a variable length string 8 characters in length.*/

CREATE OR REPLACE
  TYPE days IS TABLE OF VARCHAR2(8);
/

/*Create a song Attribute Data Type (ADT) type of a variable length string 36 characters in length*/

CREATE OR REPLACE
TYPE song IS TABLE OF VARCHAR2(36);
/

/*Create a lyric User-Defined Type (UDT) data type:
The first member of the type should have days as its name and it should be a variable length string 8 characters in length.
The second member of the type should have gift as its name and it should be a variable length string 24 characters in length.*/

CREATE OR REPLACE
  TYPE lyric IS OBJECT
  ( DAY   VARCHAR2(8)
  , gift  VARCHAR2(24));
/

/*Create a lyrics User-Defined Type (UDT) type of a lyric UDT*/

CREATE OR REPLACE
TYPE lyrics IS TABLE OF LYRIC;
/


/*An array of lyrics with the following structure values*/

CREATE OR REPLACE 
    FUNCTION twelve_days 
    (pv_days   DAYS
    ,pv_gifts   LYRICS) RETURN song IS
    
    /*initialize the collection of lyrics*/
    lv_retval SONG := song();
    PROCEDURE ADD
    (pv_input VARCHAR2) IS
    BEGIN
        lv_retval.EXTEND;
        lv_retval(lv_retval.COUNT) := pv_input;
    END ADD;
/* Read forward through the days. */    
BEGIN
  FOR i IN 1..pv_days.COUNT LOOP
    ADD('On the ' || pv_days(i) ||' of Christmas');
    ADD('my true love sent to me.');
    
      /* Read backward through the lyrics based on the ascending value of the day. */
    FOR j IN REVERSE 1..i LOOP
      /*  Add the unique string for the partridge and pear tree's first 
       *  occurrence in the song when the condition is met, and the 
       *  generic verses when the condition is not met.
       */
      IF i=1 THEN
        ADD('A' ||pv_gifts(j).gift);
      ELSE
        ADD('-' ||pv_gifts(j).DAY|| ' ' ||pv_gifts(j).gift);
      END IF;
    END LOOP;
 
    /* A line break by verse. */
    ADD(CHR(13));
  END LOOP;
 
  /* Return the song's lyrics. */
  RETURN lv_retval;
END;
/

SELECT column_value AS "12-Days of Christmas"
FROM   TABLE(twelve_days(days('first','second','third','fourth'
                             ,'fifth','sixth','seventh','eighth'
                             ,'nineth','tenth','eleventh','twelfth')
                        ,lyrics(lyric(days => 'and a', gift => 'Partridge in a pear tree')
                               ,lyric(days => 'Two',   gift => 'Turtle doves')
                               ,lyric(days => 'Three', gift => 'French hens')
                               ,lyric(days => 'Four',  gift => 'Calling birds')
                               ,lyric(days => 'Five',  gift => 'Golden rings' )
                               ,lyric(days => 'Six',   gift => 'Geese a laying')
                               ,lyric(days => 'Seven', gift => 'Swans a swimming')
                               ,lyric(days => 'Eight', gift => 'Maids a milking')
                               ,lyric(days => 'Nine',  gift => 'Ladies dancing')
                               ,lyric(days => 'Ten',   gift => 'Lords a leaping')
                               ,lyric(days => 'Eleven',gift => 'Pipers piping')
                               ,lyric(days => 'Twelve',gift => 'Drummers drumming')))); 


SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    lv_days DAYS := days('first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'nineth', 'tenth', 'eleventh', 'twelfth');
    
    lv_gifts LYRICS := lyrics(lyric(days => 'and a', gift => 'Partridge in a pear tree')
                               ,lyric(days => 'Two',   gift => 'Turtle doves')
                               ,lyric(days => 'Three', gift => 'French hens')
                               ,lyric(days => 'Four',  gift => 'Calling birds')
                               ,lyric(days => 'Five',  gift => 'Golden rings' )
                               ,lyric(days => 'Six',   gift => 'Geese a laying')
                               ,lyric(days => 'Seven', gift => 'Swans a swimming')
                               ,lyric(days => 'Eight', gift => 'Maids a milking')
                               ,lyric(days => 'Nine',  gift => 'Ladies dancing')
                               ,lyric(days => 'Ten',   gift => 'Lords a leaping')
                               ,lyric(days => 'Eleven',gift => 'Pipers piping')
                               ,lyric(days => 'Twelve',gift => 'Drummers drumming'));
                               
    lv_song SONG;
 /*  Call the twelve_days function and assign the results to the local
   *  lv_song variable.
   */   
BEGIN

    lv_song := twelve_days(lv_days, lv_gifts);
    
    FOR i in 1..lv_song.COUNT LOOP
    
    dbms_output.put_line(lv_song(i));

    END LOOP;
END;
/
    
    