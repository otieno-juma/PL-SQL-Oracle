CREATE OR REPLACE
  FUNCTION verify_date
  ( pv_date_in  VARCHAR2) RETURN BOOLEAN IS
 
  /* Local variable to ensure case-insensitive comparison. */
  lv_date_in  VARCHAR2(11);
 
  /* Local return variable. */
  lv_date  BOOLEAN := FALSE;
BEGIN
  /* Convert string input to uppercase month. */
  lv_date_in := UPPER(pv_date_in);
 
  /* Check for a DD-MON-RR or DD-MON-YYYY string. */
  IF REGEXP_LIKE(lv_date_in,'^[0-9]{2,2}-[ADFJMNOS][ACEOPU][BCGLNPRTVY]-([0-9]{2,2}|[0-9]{4,4})$') THEN
    /* Case statement checks for 28 or 29, 30, or 31 day month. */
    CASE
      /* Valid 31 day month date value. */
      WHEN SUBSTR(lv_date_in,4,3) IN ('JAN','MAR','MAY','JUL','AUG','OCT','DEC') AND
           TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 31 THEN 
        lv_date := TRUE;
      /* Valid 30 day month date value. */
      WHEN SUBSTR(lv_date_in,4,3) IN ('APR','JUN','SEP','NOV') AND
           TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 30 THEN 
        lv_date := TRUE;
      /* Valid 28 or 29 day month date value. */
      WHEN SUBSTR(lv_date_in,4,3) = 'FEB' THEN
        /* Verify 2-digit or 4-digit year. */
        IF (LENGTH(pv_date_in) = 9 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,2)) + 2000,4) = 0 OR
            LENGTH(pv_date_in) = 11 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,4)),4) = 0) AND
            TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 29 THEN
          lv_date := TRUE;
        ELSE /* Not a leap year. */
          IF TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 28 THEN
            lv_date := TRUE;
          END IF;
        END IF;
      ELSE
        NULL;
    END CASE;
  END IF;
  /* Return date. */
  RETURN lv_date;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN lv_date;
END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Test set values. */
  TYPE test_case IS TABLE OF VARCHAR2(11);
  
  /* Test set values. */
  lv_test_case  TEST_CASE := test_case('15-JAN-2022','32-JAN-2022','29-FEB-2022','29-FEB-2024');
BEGIN
  /* Test the set of values. */
  FOR i IN 1..lv_test_case.COUNT LOOP
    IF verify_date(lv_test_case(i)) THEN
  	  dbms_output.put_line('True.');
    ELSE
      dbms_output.put_line('False.');
    END IF;
  END LOOP;
END;
/


/*Create a list data type of 100 character variable length 
strings with the name tre (e.g., VARCHAR2(20)):*/

CREATE OR REPLACE
  TYPE tre IS TABLE OF VARCHAR2(100);
  
/

/*Create a structure with the name struct that contains the following:
An xnumber member with the NUMBER data type.
An xdate member with the DATE data type.
An xstring member with the VARCHAR2(20) data type.*/
CREATE OR REPLACE
  TYPE struct IS OBJECT
  ( xnumber NUMBER
  , xdate DATE
  , xstring VARCHAR2(20));
/

/*Create a list data type of the name structs 
that uses a base element type of struct as qualified above:*/
CREATE OR REPLACE
  TYPE structs IS TABLE OF struct;
/

/*Create cast_strings function that accepts 
a single parameter of the tre, 
a Attribute Data Type (ADT) created above; 
and returns a struct structure as qualified above*/

/*Set debugger*/
ALTER SESSION SET PLSQL_CCFLAGS = 'debug:1';

CREATE OR REPLACE
  FUNCTION cast_strings
  ( pv_list  TRE ) RETURN struct IS
 
    /* Declare a UDT and initialize an empty struct variable. */
    lv_retval  STRUCT := struct( NULL
                               , NULL
                               , NULL); 
	
    /* A debugger function. */	
    FUNCTION debugger
    ( pv_string  VARCHAR2 ) RETURN VARCHAR2 IS
      /* Declare return value. */
      lv_retval  VARCHAR2(60);
    BEGIN
      /* Conditional compilation evaluation. */
      $IF $$DEBUG = 1 $THEN
        lv_retval := 'Evaluating ['||pv_string||']';
      $END
	  
      /* Return debug value. */
      RETURN lv_retval;
    END debugger;
	
  BEGIN  
    /* Loop through list of values to find only the numbers. */
    FOR i IN 1..pv_list.LAST LOOP
	
      /* Print debugger remark. */
      dbms_output.put_line(debugger(pv_list(i)));
	  
      /* Ensure that a sparsely populated list can't fail. */
      IF pv_list.EXISTS(i) THEN
        /* Order if number evaluation before string evaluation. */
        CASE
            /* Implement WHEN clause that checks that the xnumber member is null and that
               the pv_list element contains only digits; and assign the pv_list element to
               the lv_retval's xnumber member. */
          WHEN lv_retval.xnumber IS NULL AND REGEXP_LIKE(pv_list(i), '^[0-9]+$') THEN
            lv_retval.xnumber := TO_NUMBER(pv_list(i));

            /* Implement WHEN clause that checks that the xdate member is null and that
               the pv_list element is a valid date; and assign the pv_list element to
               the lv_retval's xdate member. */
          WHEN lv_retval.xdate IS NULL AND TO_DATE(pv_list(i), 'YYYY-MM-DD') IS NOT NULL THEN
            lv_retval.xdate := TO_DATE(pv_list(i), 'YYYY-MM-DD');

            /* Implement WHEN clause that checks that the xstring member is null and that
               the pv_list element contains only alphanumeric values; and assign the pv_list
               element to the lv_retval's xstring member. */
          WHEN lv_retval.xstring IS NULL AND REGEXP_LIKE(pv_list(i), '^[a-zA-Z0-9]+$') THEN
            lv_retval.xstring := pv_list(i);
          ELSE
            NULL;
        END CASE;
      END IF;
    END LOOP;
 
    /* Print the results. */
    RETURN lv_retval;
  END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Define a list. */
  lv_list  TRE := TRE('16-APR-2018', 'Day after ...', '1040');
  
  /* Declare a structure. */
  lv_struct  STRUCT := struct(NULL, NULL, NULL); 
BEGIN
  /* Assign a parsed value set to get a value structure. */
  lv_struct := cast_strings(lv_list);
  
  /* Print the values of the compound struct variable. */
  dbms_output.put_line('xstring ['||lv_struct.xstring||']');
  dbms_output.put_line('xdate   ['||TO_CHAR(lv_struct.xdate, 'DD-MON-YYYY')||']');
  dbms_output.put_line('xnumber ['||TO_CHAR(lv_struct.xnumber)||']');
END;
/

/*Run the following query, which also tests the cast_strings function:*/
SELECT TO_CHAR(xdate,'DD-MON-YYYY') AS xdate
,      xnumber
,      xstring
FROM   TABLE(structs(cast_strings(tre('catch22','25','25-Nov-1945'))
                    ,cast_strings(tre('31-APR-2017','1918','areodromes'))));
            
