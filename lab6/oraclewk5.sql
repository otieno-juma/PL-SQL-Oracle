

/*Create a lyrics User-Defined Type (UDT) type of a lyric UDT*/

CREATE OR REPLACE
TYPE lyrics IS TABLE OF LYRIC;
/


/*An array of lyrics with the following structure values*/

CREATE OR REPLACE TYPE t_days IS TABLE OF VARCHAR2(10);

CREATE OR REPLACE FUNCTION twelve_days (p_days IN t_days)
RETURN VARCHAR2 IS
  v_gifts t_days := t_days('a Partridge in a Pear Tree', 'two Turtle Doves', 'three French Hens', 'four Calling Birds', 'five Gold Rings', 'six Geese a Laying', 'seven Swans a Swimming', 'eight Maids a Milking', 'nine Ladies Dancing', 'ten Lords a Leaping', 'eleven Pipers Piping', 'twelve Drummers Drumming');
  v_result VARCHAR2(4000);
BEGIN
  FOR i IN 1..p_days.COUNT LOOP
    v_result := v_result || 'On the ' || p_days(i) || ' day of Christmas, my true love gave to me: ' || v_gifts(i) || CHR(10);
  END LOOP;
  RETURN v_result;
END twelve_days;


/*Create a twelve_days function that accepts:
An array of days with the following values*/

DECLARE
  v_days t_days := t_days('first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'nineth', 'tenth', 'eleventh', 'twelfth');
  v_result VARCHAR2(4000);
BEGIN
  v_result := twelve_days(v_days);
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
