CREATE FUNCTION verify_date
  ( IN pv_date_in  VARCHAR(10)) RETURNS BOOLEAN AS
  $$
  DECLARE
    /* Local return variable. */
    lv_retval  BOOLEAN := FALSE;
  BEGIN
    /* Check for a YYYY-MM-DD or YYYY-MM-DD string. */
    IF REGEXP_MATCH(pv_date_in,'^[0-9]{2,4}-[0-9]{2,2}-[0-9]{2,2}$') IS NOT NULL THEN
      /* Case statement checks for 28 or 29, 30, or 31 day month. */
      CASE
        /* Valid 31 day month date value. */
        WHEN (LENGTH(pv_date_in) = 10 AND
              SUBSTRING(pv_date_in,6,2) IN ('01','03','05','07','08','10','12') AND
              TO_NUMBER(SUBSTRING(pv_date_in,9,2),'99') BETWEEN 1 AND 31) OR
             (LENGTH(pv_date_in) = 8 AND
              SUBSTRING(pv_date_in,4,2) IN ('01','03','05','07','08','10','12') AND
              TO_NUMBER(SUBSTRING(pv_date_in,7,2),'99') BETWEEN 1 AND 31) THEN 
          lv_retval := true;
 
        /* Valid 30 day month date value. */
        WHEN (LENGTH(pv_date_in) = 10 AND
              SUBSTRING(pv_date_in,6,2) IN ('04','06','09','11') AND
              TO_NUMBER(SUBSTRING(pv_date_in,9,2),'99') BETWEEN 1 AND 30) OR
             (LENGTH(pv_date_in) = 8 AND
              SUBSTRING(pv_date_in,4,2) IN ('04','06','09','11') AND
              TO_NUMBER(SUBSTRING(pv_date_in,7,2),'99') BETWEEN 1 AND 30) THEN 
          lv_retval := true;
 
        /* Valid 28 or 29 day month date value for February. */
        WHEN (LENGTH(pv_date_in) = 10 AND SUBSTRING(pv_date_in,6,2) = '02') OR
             (LENGTH(pv_date_in) =  8 AND SUBSTRING(pv_date_in,4,2) = '02') THEN
          /* Verify 2-digit or 4-digit year. */
          IF (LENGTH(pv_date_in) = 10 AND
              MOD(TO_NUMBER(SUBSTRING(pv_date_in,1,4),'9999'),4) = 0) OR
             (LENGTH(pv_date_in) =  8 AND
              MOD(TO_NUMBER(CONCAT('20',SUBSTRING(pv_date_in,1,2)),'9999'),4) = 0) THEN
            IF TO_NUMBER(SUBSTRING(pv_date_in,(LENGTH(pv_date_in) -1),2),'99')
                 BETWEEN 1 AND 29 THEN
              lv_retval := true;
            END IF;
          ELSE /* Not a leap year. */
            IF TO_NUMBER(SUBSTRING(pv_date_in,(LENGTH(pv_date_in) -1),2),'99')
              BETWEEN 1 AND 28 THEN
                lv_retval := true;
            /*
             *  The condition does not require evaluation because the default
             *  return value is false; however, it is provided to show you
             *  what happens when a leap year is not found and the day is
             *  outside the range of 1 to 28.
            */
            -- ELSE
            --   RAISE NOTICE '[% %]','Not a non-leap year day:',
            --                         SUBSTRING(pv_date_in,(LENGTH(pv_date_in) - 1),2);
            END IF;
          END IF;
        ELSE
          NULL;
      END CASE;
    END IF;
 
    /* Return date. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

/*Test the implementation of 
the verify_date function*/
DO
$$
DECLARE
  /* Test set values. */
  lv_test_case  VARCHAR[] := ARRAY['2022-01-15','2022-01-32','22-02-29','2022-02-29','2024-02-29'];
BEGIN
  /* Test the set of values. */
  FOR i IN 1..ARRAY_LENGTH(lv_test_case,1) LOOP
    IF verify_date(lv_test_case[i]) = 't' THEN
  	  RAISE NOTICE '[%][%]','True. ',lv_test_case[i];
    ELSE
  	  RAISE NOTICE '[%][%]','False.',lv_test_case[i];
    END IF;
  END LOOP;
END;
$$;
/*Create a structure with the name struct that contains the following:
An xnumber member with the NUMBER data type.
An xdate member with the DATE data type.
An xstring member with the VARCHAR(20) data type*/
CREATE TYPE struct AS
( xnumber NUMERIC
, xdate DATE
, xstring VARCHAR(20) );

CREATE OR REPLACE
  FUNCTION cast_strings
  ( pv_list  VARCHAR[] ) RETURNS struct AS
  $$
  DECLARE
    /* Declare a UDT and initialize an empty struct variable. */
    lv_retval struct;	
  BEGIN  
    /* Loop through list of values to find only the numbers. */
    FOR i IN 1..array_length(pv_list, 1) LOOP
      CASE	
        /* 
         *  Implement WHEN clause that checks that the xnumber member is null and that
         *  the pv_list element contains only digits; and assign the pv_list element to
         *  the lv_retval's xnumber member.
         */
        WHEN lv_retval.xnumber IS NULL AND pv_list[i] SIMILAR TO '^[0-9]+$' THEN
          lv_retval.xnumber := pv_list[i]::NUMERIC;

        /*
         *  Implement WHEN clause that checks that the xdate member is null and that
         *  the pv_list element is a valid date; and assign the pv_list element to
         *  the lv_retval's xdate member.
         */
        WHEN lv_retval.xdate IS NULL AND pv_list[i] SIMILAR TO '^\d{4}-\d{2}-\d{2}$' AND
             TO_DATE(pv_list[i],'YYYY-MM-DD') IS NOT NULL THEN
          lv_retval.xdate := TO_DATE(pv_list[i],'YYYY-MM-DD');

        /*
         *  Implement WHEN clause that checks that the xstring member is null and that
         *  the pv_list element contains only alphanumeric values; and assign the pv_list
         *  element to the lv_retval's xstring member.
         */
        WHEN lv_retval.xstring IS NULL AND pv_list[i] SIMILAR TO '^[a-zA-Z0-9]+$' THEN
          lv_retval.xstring := pv_list[i];
        ELSE
          NULL;
      END CASE;
    END LOOP;
 
    /* Print the results. */
    RETURN lv_retval;
  END;
$$ LANGUAGE plpgsql;

DO
$$
DECLARE
  /* Define a list. */
  lv_list  VARCHAR[] := ARRAY['2018-04-16','Day after ...','1040'];
  
  /* Declare a structure. */
  lv_struct  struct; 
BEGIN
  /* Assign a parsed value set to get a value structure. */
  lv_struct := cast_strings(lv_list);
  
  /* Print the values of the compound struct variable. */
  RAISE NOTICE '[%]',lv_struct.xstring;
  RAISE NOTICE '[%]',TO_CHAR(lv_struct.xdate,'DD-MON-YYYY');
  RAISE NOTICE '[%]',lv_struct.xnumber;
END;
$$;

DO
$$
DECLARE
  lv_list    VARCHAR(11)[] := ARRAY['86','1944-04-25','Happy'];
  lv_struct  STRUCT;
BEGIN
  /* Pass the array of strings and return a record type. */
  lv_struct := cast_strings(lv_list);
 
  /* Print the elements returned. */
  RAISE NOTICE '[%]', lv_struct.xnumber;
  RAISE NOTICE '[%]', lv_struct.xdate;
  RAISE NOTICE '[%]', lv_struct.xstring;
END;
$$;

WITH get_struct AS
(SELECT cast_strings(ARRAY['99','2015-06-14','Agent 99']) AS mystruct)
SELECT (mystruct).xnumber
,      (mystruct).xdate
,      (mystruct).xstring
FROM    get_struct;
