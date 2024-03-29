CREATE OR REPLACE
  FUNCTION npv
  ( future_val    DECIMAL
  , periods       INTEGER
  , interest      DECIMAL )
  RETURNS DECIMAL AS
  $$
DECLARE
	/* Declare a result variable. */
	npv_val DECIMAL;
BEGIN
/* Calculate the result and round it to the nearest penny and assign it to a local variable.*/
	npv_val := future_val / POWER(1 + interest, periods);
/* Return the calculated result. */
	RETURN ROUND(npv_val, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


DO
$$
DECLARE
  /* Declare inputs by data type. */
  
	future_val DECIMAL := 200000;
	periods INTEGER := 4;
	interest DECIMAL := .07;
BEGIN
  /* Call function and assign value. */
  /* Display value. */
	RAISE NOTICE 'calculated value was [%]',npv(future_val,periods,interest);
END;
$$;