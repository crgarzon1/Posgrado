CREATE TYPE MY_ARRAY_ITEM IS OBJECT (KEY VARCHAR2(200), VALUE VARCHAR2(500));
/
CREATE TYPE MY_ARRAY IS TABLE OF MY_ARRAY_ITEM;
/
CREATE OR REPLACE PACKAGE PKG_MENU AS 

    PROCEDURE CALL_FACADE (
        P_OPTION_ID NUMBER DEFAULT 0,
        P_PARAMS IN NCLOB DEFAULT '[]'
    );
    
    FUNCTION ADD_PARAMS_VALUES (
        P_DICCIONARIO MY_ARRAY,
        P_PARAMS IN NCLOB DEFAULT '[]'
    ) RETURN MY_ARRAY;
    
    FUNCTION PLACEHOLDER_IS_VALID (
        P_KEY VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION REMOVE_SPECIAL_CHARS (
        P_VALUE VARCHAR2
    ) RETURN VARCHAR2;
    
     FUNCTION ADD_COOKIE_VALUES (
        P_DICCIONARIO MY_ARRAY
    ) RETURN MY_ARRAY;
    
    FUNCTION GET_CODIGO_FACULTAD (
        P_USUARIO VARCHAR,
        P_CLAVE VARCHAR
    ) RETURN VARCHAR;
        
    PROCEDURE EXECUTE_PROCEDURE(
        P_DICCIONARIO MY_ARRAY,
        P_OPTION_ID NUMBER DEFAULT 0
    );
    
    FUNCTION GET_PROCEDURE_TEMPLATE (
        P_OPTION_ID NUMBER DEFAULT 0
    ) RETURN VARCHAR2;
    
    FUNCTION REPLACE_KEYS_FROM_TEMPLATE(
        P_DICCIONARIO MY_ARRAY,
        P_TEMPLATE VARCHAR2
    ) RETURN VARCHAR2;
    
    FUNCTION ADD_TO_DICTIONNARY (
        P_DICCIONARIO MY_ARRAY,
        P_KEY VARCHAR,
        P_VALUE VARCHAR
    ) RETURN MY_ARRAY;
    
    PROCEDURE REDIRECT (
        P_URL VARCHAR
    );
END PKG_MENU;
/

CREATE OR REPLACE PACKAGE BODY PKG_MENU AS

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- RECIBE LA PETICION DE EL MENU DE POSTGRADO.
-- ****************************************************************************************************************************

    PROCEDURE CALL_FACADE (
        P_OPTION_ID NUMBER DEFAULT 0,
        P_PARAMS IN NCLOB DEFAULT '[]'
    ) AS
        V_ERROR JSON;
        -- ARRAY PARA ALMACENAR DICCINARIO DE DATOS.
        V_DICCIONARIO MY_ARRAY DEFAULT MY_ARRAY();
    BEGIN
        V_DICCIONARIO := ADD_PARAMS_VALUES (V_DICCIONARIO, P_PARAMS);
        V_DICCIONARIO := ADD_COOKIE_VALUES (V_DICCIONARIO);
        EXECUTE_PROCEDURE(V_DICCIONARIO, P_OPTION_ID);
    EXCEPTION
        WHEN OTHERS THEN
            V_ERROR := JSON();
            JSON.PUT (V_ERROR, 'status', 'fail');
            JSON.PUT (V_ERROR, 'mensaje', SQLERRM);
            JSON.HTP (V_ERROR, FALSE);
    END CALL_FACADE;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE A PARTIR DEL PARAMETRO P_PARAMS UN OBJETO JSON Y, A PARTIR DE EL, OBTIENE REGISTROS PARA AGREGAR AL DICCIONARIO.
-- ****************************************************************************************************************************

    FUNCTION ADD_PARAMS_VALUES (
        P_DICCIONARIO MY_ARRAY,
        P_PARAMS IN NCLOB
    ) RETURN MY_ARRAY IS
        -- PARAMETROS DE LA COOKIE.   
        V_INPUT_PARAMS JSON_LIST DEFAULT JSON_LIST(P_PARAMS);
        V_INPUT_PARAM  JSON;
        V_DICCIONARIO  MY_ARRAY DEFAULT P_DICCIONARIO;
    BEGIN
        -- ADICION DE PARAMETROS DE OBJETO JSON.
        FOR i IN 1 .. V_INPUT_PARAMS.COUNT        
        LOOP
            V_INPUT_PARAM := JSON(V_INPUT_PARAMS.GET(I));
            -- VALIDA SI SE ENCONTRO UN PLACEHOLDER VALIDO.
            IF(PLACEHOLDER_IS_VALID(V_INPUT_PARAM.GET('key').GET_STRING) = '1') THEN
                -- AGREGA VALOR AL DICCIONARIO ELIMINANDO CARACTERES ESPECIALES PARA EVITAR INYECCIONES SQL.
                V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, V_INPUT_PARAM.GET('key').GET_STRING, 
                                                    REMOVE_SPECIAL_CHARS(V_INPUT_PARAM.GET('value').GET_STRING));
            END IF;
        END LOOP;
        RETURN V_DICCIONARIO;
    END ADD_PARAMS_VALUES;
        
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- VERIFICA SI UN PLACEHOLDER ESTA EN LA TABLA CTI_PARAMETRO_PROCESO, PARA EVITAR REEMPLAZOS INDESEADOS EN EL PROCEDIMIENTO
-- REPLACE_KEYS_FROM_TEMPLATE().
-- ****************************************************************************************************************************

    FUNCTION PLACEHOLDER_IS_VALID (
        P_KEY VARCHAR2
    ) RETURN NUMBER IS
        V_COUNT NUMBER;
    BEGIN
        SELECT COUNT(IDENTIFIER)
        INTO   V_COUNT
        FROM   ADMISIONES.CTI_PARAMETRO_PROCESO
        WHERE  IDENTIFIER = P_KEY;
        IF(V_COUNT > 0) THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END PLACEHOLDER_IS_VALID;    
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- REMUEVE CARACTERES ESPECIALES DE UNA CADENA DE CARACTERES, PARA EVITAR SQL INJECTION.
-- ****************************************************************************************************************************
    
    FUNCTION REMOVE_SPECIAL_CHARS (
        P_VALUE VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN
        RETURN REGEXP_REPLACE(P_VALUE, '[^0-9A-Za-z]', '');
    END REMOVE_SPECIAL_CHARS;    
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- AGREGA LAS VARIABLES ALMACENADAS EN LA COOKIE AL DICCIONARIO ENVIADO COMO PARAMETRO.
-- ****************************************************************************************************************************

    FUNCTION ADD_COOKIE_VALUES (
        P_DICCIONARIO MY_ARRAY
    ) RETURN MY_ARRAY IS
        -- PARAMETROS DE LA COOKIE.                                                                                       
        V_USUARIO     VARCHAR2 (200);
        V_CLAVE       VARCHAR2 (200);
        V_DOCUMENTO   VARCHAR2 (200);
        V_CODIGO      VARCHAR2 (200);
        V_NOMBRE      VARCHAR2 (200);
        V_DICCIONARIO MY_ARRAY DEFAULT P_DICCIONARIO;
    BEGIN
        -- VARIABLES ALMACENADAS EN LA COOKIE.
        ADMISIONES.PKG_UTILS.P_LEER_COOKIE(V_USUARIO, V_CLAVE, V_DOCUMENTO, V_CODIGO, V_NOMBRE);
        -- ADICION DE VARIABLES DE LA COOKIE.
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_USUARIO]', V_USUARIO);
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_CLAVE]', V_CLAVE);
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_DOCUMENTO]', V_DOCUMENTO);
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_CODIGO]', V_CODIGO);
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_NOMBRE]', V_NOMBRE);
        V_DICCIONARIO := ADD_TO_DICTIONNARY(V_DICCIONARIO, '[P_CODIGO_FACULTAD]', GET_CODIGO_FACULTAD(V_USUARIO, V_CLAVE));
        RETURN V_DICCIONARIO;
    END ADD_COOKIE_VALUES;
        
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
--  OBTIENE EL CODIGO DE LA FACULTAD A PARTIR DEL USUARIO Y CLAVE.
-- ****************************************************************************************************************************

    FUNCTION GET_CODIGO_FACULTAD (
        P_USUARIO VARCHAR,
        P_CLAVE VARCHAR
    ) RETURN VARCHAR IS
        V_AUXILIAR    VARCHAR2 (200);
    BEGIN   
        BEGIN
            -- OBTENCION DEL CODIGO DE LA FACULTAD A PARTIR DE USUARIO Y CLAVE.
            SELECT     PR.CODIGO
            INTO       V_AUXILIAR
            FROM       ADMISIONES.A_USUARIOS U
            INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                    OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
            INNER JOIN ADMISIONES.A_PROGRAMAS PR ON    PR.FACULTAD = SUBSTR (U.CODIGO, 2, 2) 
                                                    OR PR.CODIGO   = SUBSTR (U.CODIGO, 2, 2)
            WHERE          U.USUARIO = P_USUARIO
                       AND U.CLAVE   = P_CLAVE;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'No se encontró el usuario');
        END;
        RETURN V_AUXILIAR;
    END GET_CODIGO_FACULTAD;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- EJECUTA EL PROCEDIMIENTO ALMACENADO A PARTIR DE UNA OPCION.
-- ****************************************************************************************************************************

    PROCEDURE EXECUTE_PROCEDURE(
        P_DICCIONARIO MY_ARRAY,
        P_OPTION_ID NUMBER DEFAULT 0
    ) IS
        V_DICCIONARIO MY_ARRAY DEFAULT P_DICCIONARIO;
        V_DYNAMIC_SQL VARCHAR2 (2000);
    BEGIN
        -- OBTIENE PLANTILLA Y LA FORMATEA CON EL DICCIONARIO.
        V_DYNAMIC_SQL := REPLACE_KEYS_FROM_TEMPLATE(P_DICCIONARIO, GET_PROCEDURE_TEMPLATE (P_OPTION_ID));
        --HTP.PRN(V_DYNAMIC_SQL);
        EXECUTE IMMEDIATE V_DYNAMIC_SQL;
    END EXECUTE_PROCEDURE;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE UNA PLANTILLA A PARTIR DE UNA OPCION. LA OPCION SE DEFINE EN CTI_PROCESOS UTILIZANDO LA URL:
--  DEV: HTTP://PRUEBASIA.LASALLE.EDU.CO/PLS/POSTGRADODES/PKG_MENU.CALL_FACADE?P_OPTION_ID=[OPTION_ID]
-- ****************************************************************************************************************************

    FUNCTION GET_PROCEDURE_TEMPLATE (
        P_OPTION_ID NUMBER DEFAULT 0
    ) RETURN VARCHAR2 IS
        V_RETURNABLE VARCHAR2 (1000) DEFAULT '';
        -- PROCEDIMIENTOS ALMACENADOS DINAMICOS.
        V_SQL1       VARCHAR2 (1000) DEFAULT 'CALL VALIDAR_F2_DECANO (''[P_USUARIO]'', 
                                                                      ''[P_CLAVE]'',
                                                                      ''[P_CODIGO_ESTUDIANTE]'',
                                                                      ''[P_CODIGO_FACULTAD]'',
                                                                      ''1'', 
                                                                      ''[P_OPCION]'',
                                                                      ''XX'',
                                                                      ''X'')';
        V_SQL2       VARCHAR2 (1000) DEFAULT 'CALL CAPTURA_HORARIO_POSTGRADO_BAK (''[P_CODIGO_FACULTAD]'',
                                                                                  ''[P_USUARIO]'',
                                                                                  ''[P_CLAVE]'',
                                                                                  ''X'')';
        V_SQL3       VARCHAR2 (1000) DEFAULT 'CALL ADMISIONES.PG_CRED_DOC2 (''[P_CODIGO_FACULTAD]'')';
        V_SQL4       VARCHAR2 (1000) DEFAULT 'CALL POSTGRADO.PINTAR_GRUPOS_SINNOTA (''[P_CODIGO_FACULTAD]'')';
        V_SQL5       VARCHAR2 (1000) DEFAULT 'CALL POSTGRADO.PINTAR_ESTADISTICA_NOTAS (''[P_CODIGO_FACULTAD]'')';
        V_SQL6       VARCHAR2 (1000) DEFAULT 'CALL POSTGRADO.PINTAR_MATERIAS_OTRAFAC (''[P_CODIGO_FACULTAD]'')';
        V_SQL7       VARCHAR2 (1000) DEFAULT 'CALL POSTGRADO.PKG_MENU.REDIRECT (''[P_URL]'')';
        V_SQL8       VARCHAR2 (1000) DEFAULT 'CALL ADMISIONES.MATRICULAXGENERO_3 (''[P_CODIGO_FACULTAD]'')';
    BEGIN
        -- DEFINE PROCEDIMIENTO A LLAMAR DE ACUERDO A LA OPCION.
        SELECT CASE P_OPTION_ID
                    WHEN 1  THEN REPLACE(V_SQL1, '[P_OPCION]', 'crear_horario')
                    WHEN 2  THEN REPLACE(V_SQL1, '[P_OPCION]', 'planes')
                    WHEN 3  THEN REPLACE(V_SQL1, '[P_OPCION]', 'lreintegros')
                    WHEN 4  THEN V_SQL3
                    WHEN 5  THEN REPLACE(V_SQL1, '[P_OPCION]', 'reintegros_extemporaneos')
                    WHEN 6  THEN REPLACE(V_SQL1, '[P_OPCION]', 'crearmat')
                    WHEN 7  THEN V_SQL2
                    WHEN 8  THEN REPLACE(V_SQL1, '[P_OPCION]', 'consulta_general')
                    WHEN 9  THEN REPLACE(V_SQL1, '[P_OPCION]', 'admisiones')
                    WHEN 10 THEN REPLACE(V_SQL1, '[P_OPCION]', 'matricula_xtipo')
                    WHEN 11 THEN V_SQL4
                    WHEN 12 THEN REPLACE(V_SQL7, '[P_URL]', 'http://oarglass.lasalle.edu.co:8080/administracionOAR-war/Admision/listadoAspirantesPos.jsf?programa=[P_CODIGO_FACULTAD]')
                    WHEN 13 THEN V_SQL5
                    WHEN 14 THEN V_SQL6
                    WHEN 15 THEN V_SQL8
               END
        INTO   V_RETURNABLE
        FROM   DUAL;
        RETURN V_RETURNABLE;
    END GET_PROCEDURE_TEMPLATE;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- REEMPLAZA LAS LLAVES POR LOS VALORES EN UNA PLANTILLA (OBTENIDA DE GET_PROCEDURE_TEMPLATE) Y DEVUELVE UN STRING CON EL 
-- RESULTADO.
-- ****************************************************************************************************************************

    FUNCTION REPLACE_KEYS_FROM_TEMPLATE(
        P_DICCIONARIO MY_ARRAY,
        P_TEMPLATE VARCHAR2
    ) RETURN VARCHAR2 IS
        V_DICCIONARIO  MY_ARRAY DEFAULT P_DICCIONARIO;
        V_TEMPLATE     VARCHAR2 (2000) DEFAULT P_TEMPLATE;
    BEGIN
        -- REEMPLAZO A PARTIR DEL DICCIONARIO.
        FOR I IN 1..V_DICCIONARIO.COUNT LOOP
            V_TEMPLATE := REPLACE(V_TEMPLATE, V_DICCIONARIO(I).KEY, V_DICCIONARIO(I).VALUE);
        END LOOP;   
        -- REEMPLAZO DE TODOS LOS PLACEHOLDERS FALTANTES 
        V_TEMPLATE := REGEXP_REPLACE(V_TEMPLATE, '\[(.*?)\]', '');
        RETURN V_TEMPLATE;
    END REPLACE_KEYS_FROM_TEMPLATE;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
--  AGREGA UN REGISTRO AL DICCIONARIO.
-- ****************************************************************************************************************************

    FUNCTION ADD_TO_DICTIONNARY (
        P_DICCIONARIO MY_ARRAY,
        P_KEY VARCHAR,
        P_VALUE VARCHAR
    ) RETURN MY_ARRAY IS
        V_DICCIONARIO MY_ARRAY DEFAULT P_DICCIONARIO;
    BEGIN
        V_DICCIONARIO.EXTEND();
        V_DICCIONARIO(V_DICCIONARIO.COUNT) := MY_ARRAY_ITEM(P_KEY, P_VALUE);
        RETURN V_DICCIONARIO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN MY_ARRAY();
    END ADD_TO_DICTIONNARY;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
--  IMPRIME UNA PAGINA HTML QUE REDIRIGE A LA DIRECCION SOLICITADA.
-- ****************************************************************************************************************************

    PROCEDURE REDIRECT (
        P_URL VARCHAR
    ) IS
    BEGIN
        HTP.PRN('
            <html><head><script>location.href = "' || P_URL ||'";</script></head></html>
        ');
    END REDIRECT;
END PKG_MENU;
/