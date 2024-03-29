SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
   /* Ascending loops. */
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;

    /* Descending loop. */
    FOR i IN REVERSE 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/
