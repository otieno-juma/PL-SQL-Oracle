--Write a npv named deterministic function that calculates the Net Present Value (NPV). It should accept the following parameters:
--A future_value parameter using a number data type.
--A periods parameter using an integer data type.
--An interest parameter using a number data type.
--The npv function should return a decimal (in Oracle a NUMBER data type) value rounded to the nearest penny.

CREATE OR REPLACE
  FUNCTION npv
  ( future_value  NUMBER
  , periods       INTEGER
  , interest      NUMBER )
  RETURN NUMBER DETERMINISTIC IS
  BEGIN
    RETURN ROUND(future_value / POWER(1 + interest, periods),2);
    
  END;
/
   
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
    fv NUMBER := 2000;
    p INTEGER := 15;
    ir NUMBER := 0.05;
BEGIN
  /* Call, round, and print the return value from the npv deterministic function. */
  dbms_output.put_line('The current value is ['||npv(fv, p, ir)||']');
END;
/