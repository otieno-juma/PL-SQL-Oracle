/* Drop table unconditionally. */
DROP FUNCTION adding;

/* Create an adding function. */
CREATE OR REPLACE
  FUNCTION adding
  ( a  integer
  , b  integer )
  RETURNS decimal AS
  $$
  DECLARE
    /* Declare a return value. */
    ret_val  decimal;
  BEGIN
    /* Assign the result to a local variable. */
    ret_val :=  a + b;
    RETURN ret_val;
  END;
  $$ LANGUAGE plpgsql IMMUTABLE;

/* An anonymous block must declare the variables and call the function. */
DO
$$
DECLARE
  /* Declare inputs by data type. */
  lv_a  integer := 2;
  lv_b  integer := 2;

  /* Result variable. */
  lv_result  decimal;
BEGIN
  /* Call function and assign value. */
  SELECT adding(lv_a,lv_b) INTO lv_result;
  
  /* Display value. */
  RAISE NOTICE '%',CONCAT('The result [',lv_result,'].');
END;
$$;
