CREATE OR REPLACE PROCEDURE GET_MENSAJES (
    P_CODIGO_ESTUDIANTE VARCHAR2
) IS
    JS_MSG    JSON;
    JS_MSGS   JSON_LIST := JSON_LIST ();
    N_N       NUMBER;
BEGIN
    FOR MSG IN (SELECT *
                FROM DESARROLLOSPRE.CTI_MENSAJES_MENU
                WHERE SYSDATE BETWEEN DESDE AND HASTA
                      OR DESDE IS NULL
               ) LOOP
        JS_MSG := NULL;
        BEGIN
            IF MSG.FUNCION IS NOT NULL THEN
                EXECUTE IMMEDIATE 'select ' ||
                MSG.FUNCION || '(:p_codigo) from dual'
                INTO N_N
                    USING P_CODIGO_ESTUDIANTE;
                IF N_N > 0 THEN
                    JS_MSG := DESARROLLOSPRE.PKG_MENSAJES.MENSAJEJSON (MSG);
                END IF;

            ELSE
                JS_MSG := DESARROLLOSPRE.PKG_MENSAJES.MENSAJEJSON (MSG);
            END IF;

            IF JS_MSG IS NOT NULL THEN
                JSON_LIST.APPEND (JS_MSGS, JS_MSG.TO_JSON_VALUE);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

    END LOOP;

    PKG_JSON_RESPONSE.PRINT_SUCCESSFUL (JS_MSGS);
EXCEPTION
    WHEN OTHERS THEN
        PKG_JSON_RESPONSE.PRINT_FAILURE_OR_EXCEPTION ();
END;
/