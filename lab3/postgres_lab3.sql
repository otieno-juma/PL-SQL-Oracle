DO 
$$
DECLARE
    i INTEGER;
BEGIN
    /* Ascending loops. */
    FOR i IN 1..10 LOOP
        RAISE NOTICE '%', i;
    END LOOP;

    /*Descending loops.*/
    FOR i IN REVERSE 10..1 LOOP
        RAISE NOTICE '%', i;
    END LOOP;
END;
$$;
