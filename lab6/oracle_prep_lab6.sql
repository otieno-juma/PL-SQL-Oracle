/* Unconditionally drop the function. */
DROP FUNCTION verify_date;

/* Create the library function. */
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

/* Test the verify_date function. */
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
