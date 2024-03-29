/* Drop table unconditionally. */
DROP FUNCTION adding;

/* Create an adding function. */
CREATE OR REPLACE
  FUNCTION adding
  ( a NUMBER
  , b NUMBER ) RETURN NUMBER DETERMINISTIC IS
  BEGIN
    RETURN a + b;
  END;
/

/* An anonymous block must declare the variables and call the function. */
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Declare the variables. */
  a  NUMBER := 2;
  b  NUMBER := 2;
BEGIN
  /* Call, round, and print the return 
  value from the npv deterministic function*/
  dbms_output.put_line('The result ['||adding(a,b)||'].');
END;
/