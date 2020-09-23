SET DEFINE OFF;

/* ******************************ELIMINACION DE OBJETOS CREADOS****************************************/
/* ****************************************************************************************************/

DROP TYPE DICTIONARY;

DROP TYPE KEY_VALUE_PAIR;

DROP SEQUENCE HTTP_REQUEST_LOG_SEQ;

DROP TRIGGER HTTP_REQUEST_LOG_TRG;

DROP TABLE HTTP_REQUEST_LOG;

DROP TYPE CRM_ADITIONAL_INFO;

/* ***********************************CREACION DE TABLA DE LOG*****************************************/
/* ****************************************************************************************************/

CREATE SEQUENCE HTTP_REQUEST_LOG_SEQ START WITH 1;

CREATE TABLE HTTP_REQUEST_LOG (
    HTTP_REQUEST_LOG_ID   NUMBER PRIMARY KEY,
    REQUEST_DATE          DATE,
    HTTP_METHOD           VARCHAR2 (10) NOT NULL,
    URL                   VARCHAR2 (4000) NOT NULL,
    CONTENT               VARCHAR2 (4000) NULL,
    RESPONSE              VARCHAR2 (4000) NOT NULL
);

CREATE TRIGGER HTTP_REQUEST_LOG_TRG BEFORE
    INSERT ON HTTP_REQUEST_LOG
    FOR EACH ROW
BEGIN
    SELECT HTTP_REQUEST_LOG_SEQ.NEXTVAL
    INTO :NEW.HTTP_REQUEST_LOG_ID
    FROM DUAL;

END;
/

/* ********************************CREACION Y CONFIGURACION ACLS***************************************/
/* ****************************************************************************************************/

BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (ACL => 'CRM.xml', DESCRIPTION => 'CRM', PRINCIPAL => 'ADMISIONES', IS_GRANT => TRUE, PRIVILEGE => 'connect',
                                      START_DATE => SYSTIMESTAMP, END_DATE => NULL);
END;
/
/* ****************************************************************************************************/
/* ****************************************************************************************************/

BEGIN
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (ACL => 'CRM.xml', HOST => 'jupiter.lasalle.edu.co', LOWER_PORT => 80, UPPER_PORT => NULL);
END;
/
/* **************************CREACION DE OBJECTOS PARA PETICIONES HTTP*********************************/
/* ****************************************************************************************************/

CREATE TYPE KEY_VALUE_PAIR IS OBJECT (
    KEY     VARCHAR2 (200),
    VALUE   VARCHAR2 (500)
);
/

CREATE TYPE DICTIONARY IS
    TABLE OF KEY_VALUE_PAIR;
/

CREATE OR REPLACE FUNCTION ADD_TO_DICTIONNARY (
    P_DICTIONARY   DICTIONARY,
    P_KEY          VARCHAR,
    P_VALUE        VARCHAR
) RETURN DICTIONARY IS
    V_DICTIONARY DICTIONARY DEFAULT P_DICTIONARY;
BEGIN
    V_DICTIONARY.EXTEND ();
    V_DICTIONARY (V_DICTIONARY.COUNT) := KEY_VALUE_PAIR (P_KEY, P_VALUE);
    RETURN V_DICTIONARY;
EXCEPTION
    WHEN OTHERS THEN
        RETURN DICTIONARY ();
END ADD_TO_DICTIONNARY;
/

/* ******************************PROCEDIMIENTO PARA PETICIONES HTTP************************************/
/* ****************************************************************************************************/

CREATE OR REPLACE PROCEDURE MAKE_HTTP_REQUEST (
    P_URL       VARCHAR2,
    P_METHOD    VARCHAR2,
    P_HEADERS   DICTIONARY,
    P_BODY      DICTIONARY
) IS

    V_REQ        UTL_HTTP.REQ;
    V_RES        UTL_HTTP.RESP;
    V_HEADERS    DICTIONARY DEFAULT P_HEADERS;
    V_BODY       DICTIONARY DEFAULT P_BODY;
    V_BUFFER     VARCHAR2 (4000);
    V_CONTENT    VARCHAR2 (4000);
    V_RESPONSE   VARCHAR2 (4000) DEFAULT '';
BEGIN
    V_REQ   := UTL_HTTP.BEGIN_REQUEST (P_URL, P_METHOD);
    IF (V_HEADERS IS NOT NULL AND V_HEADERS.COUNT > 0) THEN
        FOR I IN 1..V_HEADERS.COUNT LOOP
            UTL_HTTP.SET_HEADER (V_REQ, V_HEADERS (I).KEY, V_HEADERS (I).VALUE);
        END LOOP;

    END IF;

    IF (P_METHOD = 'POST' AND V_BODY IS NOT NULL AND V_BODY.COUNT > 0) THEN
        UTL_HTTP.SET_HEADER (V_REQ, 'content-type', 'application/x-www-form-urlencoded');
        FOR I IN 1..V_BODY.COUNT LOOP
            IF (I > 1) THEN
                V_CONTENT := V_CONTENT || '&';
            END IF;
            V_CONTENT := V_CONTENT ||
            V_BODY (I).KEY ||
            '=' ||
            V_BODY (I).VALUE;

        END LOOP;

        UTL_HTTP.SET_HEADER (V_REQ, 'content-length', LENGTH (V_CONTENT));
        UTL_HTTP.WRITE_TEXT (V_REQ, V_CONTENT);
    END IF;

    V_RES   := UTL_HTTP.GET_RESPONSE (V_REQ);
    BEGIN
        LOOP
            UTL_HTTP.READ_LINE (V_RES, V_BUFFER);
            V_RESPONSE := V_RESPONSE || V_BUFFER;
        END LOOP;

        UTL_HTTP.END_RESPONSE (V_RES);
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            UTL_HTTP.END_RESPONSE (V_RES);
    END;

    INSERT INTO HTTP_REQUEST_LOG (
        REQUEST_DATE,
        HTTP_METHOD,
        URL,
        CONTENT,
        RESPONSE
    ) VALUES (
        SYSDATE,
        P_METHOD,
        P_URL,
        V_CONTENT,
        V_RESPONSE
    );

END;
/

GRANT EXECUTE ON MAKE_HTTP_REQUEST TO DESARROLLOSPRE;
GRANT EXECUTE ON CALL_CRM_SERVICE TO DESARROLLOSPRE;

/* ************************PROCEDIMIENTO PARA SER LLAMADO POR EL TRIGGER*******************************/
/* ****************************************************************************************************/

CREATE TYPE CRM_ADITIONAL_INFO AS OBJECT (
    HABEAS_DATA        NUMBER,
    PAGO_INSCRIPCION   NUMBER,
    ENTREVISTA         NUMBER,
    ADMITIDO           NUMBER,
    MATRICULADO        NUMBER,
    SPP                NUMBER,
    FORMULARIO1        NUMBER,
    FORMULARIO2        NUMBER,
    NUEVO              NUMBER
)
/

GRANT EXECUTE ON CRM_ADITIONAL_INFO TO DESARROLLOSPRE;

/* *********************PROCEDIMIENTO PARA SABER SI VIENEN VALORES INICIALES***************************/
/* ****************************************************************************************************/

CREATE OR REPLACE FUNCTION ADITIONAL_INFO_HAS_VALUES (
    V_ADITIONAL_INFO CRM_ADITIONAL_INFO
) RETURN NUMBER IS
BEGIN
    IF (V_ADITIONAL_INFO.HABEAS_DATA != 0 OR V_ADITIONAL_INFO.PAGO_INSCRIPCION != 0 OR V_ADITIONAL_INFO.ENTREVISTA != 0 OR V_ADITIONAL_INFO.ADMITIDO != 0 OR V_ADITIONAL_INFO.MATRICULADO != 0 OR V_ADITIONAL_INFO.SPP != 0 OR V_ADITIONAL_INFO.FORMULARIO1 != 0 OR V_ADITIONAL_INFO.FORMULARIO2 != 0) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/

GRANT EXECUTE ON ADITIONAL_INFO_HAS_VALUES TO DESARROLLOSPRE;

/* ************************PROCEDIMIENTO PARA SER LLAMADO POR EL TRIGGER*******************************/
/* ****************************************************************************************************/

CREATE OR REPLACE PROCEDURE CALL_CRM_SERVICE (
    P_INTERESADO DESARROLLOSPRE.CTI_INTERESADO%ROWTYPE,
    P_CRM_INFO CRM_ADITIONAL_INFO
) IS

    V_URL           VARCHAR2 (4000) := 'http://jupiter.lasalle.edu.co:80/laSalleExposedServices/gateway/1896B502E924E37DE8DE85148F3F4385AE0F7E820617377EB20763A83E4A8C4A4653F8272BFD1067FB854A075E15DE2BF968B89E740BB283';
    V_METHOD        VARCHAR (4) := 'POST';
    V_HEADERS       DICTIONARY DEFAULT DICTIONARY ();
    V_BODY_PARAMS   DICTIONARY DEFAULT DICTIONARY ();
    V_RESPONSE      VARCHAR2 (4000);
BEGIN
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'authorization', 'Token 400b0eba0da2f819a9be6d0cf70b89723d7aaa5b');
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'accept', '*/*');
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'cache-control', 'no-cache');
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'host', 'jupiter.lasalle.edu.co:80');
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'accept-encoding', 'gzip, deflate, br');
    V_HEADERS       := ADD_TO_DICTIONNARY (V_HEADERS, 'connection', 'keep-alive');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'primer_nombre', P_INTERESADO.PRIMER_NOMBRE);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'segundo_nombre', P_INTERESADO.SEGUNDO_NOMBRE);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'primer_apellido', P_INTERESADO.PRIMER_APELLIDO);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'segundo_apellido', P_INTERESADO.SEGUNDO_APELLIDO);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'tipo_documento', P_INTERESADO.TIPDOC);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'documento', P_INTERESADO.NUMDOC);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'email', P_INTERESADO.EMAIL);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'celular', P_INTERESADO.CELULAR);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'programa', P_INTERESADO.CODIGO_FACULTAD || P_INTERESADO.JORNADA_FACULTAD);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'origen', P_INTERESADO.ORIGEN);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'fecha', TO_CHAR (P_INTERESADO.FECHA, 'YYYY-MM-DD hh24:mm:ss'));

    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'habeas_data', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.HABEAS_DATA END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'pago_inscripcion', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.PAGO_INSCRIPCION END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'entrevista', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.ENTREVISTA END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'admitido', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.ADMITIDO END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'matriculado', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.MATRICULADO END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'spp', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.SPP END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'formulario1', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.FORMULARIO1 END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'formulario2', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.FORMULARIO2 END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'nuevo', CASE WHEN P_CRM_INFO IS NULL THEN '0' ELSE P_CRM_INFO.NUEVO END);
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'fuente', 'SIA');
    MAKE_HTTP_REQUEST (V_URL, V_METHOD, V_HEADERS, V_BODY_PARAMS);
END;
/

GRANT EXECUTE ON CALL_CRM_SERVICE TO DESARROLLOSPRE;

/* ************************PAQUETE PARA DETERMINAR EL ESTADO DEL ASPIRANTE*****************************/
/* ****************************************************************************************************/

CREATE OR REPLACE PACKAGE PKG_ESTADO_INTERESADO IS
    FUNCTION HABEAS_DATA (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION PAGO_INSCRIPCION (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION ENTREVISTA (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION ADMITIDO (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION MATRICULADO (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION SPP (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION FORMULARIO1 (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

    FUNCTION FORMULARIO2 (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY PKG_ESTADO_INTERESADO IS

    FUNCTION HABEAS_DATA (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN INTERESADO.ORIGEN = 'sepRebr5' THEN
                '1'
            WHEN INTERESADO.ORIGEN != 'sepRebr5' AND ASPIRANTE.CODIGO IS NOT NULL THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;
        RETURN V_RETURNABLE;
    END;

    FUNCTION PAGO_INSCRIPCION (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN PAGO_INSCRIPCION.CODIGO_EST IS NOT NULL THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        LEFT JOIN ADMISIONES.G_OTROS_PAGOS        PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                               AND PAGO_INSCRIPCION.INDICADOR_PAGO = 'P'
                                                               AND PAGO_INSCRIPCION.ACTIVA = 1
                                                               AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                               AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION ENTREVISTA (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN ASPIRANTE.PENTRE IS NOT NULL THEN
                1
            ELSE
                0
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          PENTRE,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          NULL,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION ADMITIDO (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN IND1 = 2 THEN
                1
            ELSE
                0
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          IND1,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          IND1,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION MATRICULADO (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN ESTUDIANTE.CODIGO IS NOT NULL THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          COD_DEF,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          COD_DEF,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        LEFT JOIN (SELECT CODIGO,
                          INDICADOR_PAGO
                   FROM ADMISIONES.B_ESTUDIANTES
                   UNION
                   SELECT CODIGO,
                          INDICADOR_PAGO
                   FROM POSTGRADO.B_ESTUDIANTES
        ) ESTUDIANTE ON ESTUDIANTE.CODIGO = ASPIRANTE.COD_DEF
                        AND ESTUDIANTE.INDICADOR_PAGO IN (
            'P',
            'V',
            'W'
        )
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION SPP (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN ESTUDIANTE_SPP.DOCUMENTO IS NOT NULL
                 AND ASPIRANTE.ESQUEMA = 'PREGRADO' THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO    INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        LEFT JOIN ADMISIONES.BENEFICIARIOS_BECAS   ESTUDIANTE_SPP ON ESTUDIANTE_SPP.DOCUMENTO = ASPIRANTE.NUMDOC
                                                                   AND ESTUDIANTE_SPP.ANIO = ASPIRANTE.ANIO
                                                                   AND ESTUDIANTE_SPP.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION FORMULARIO1 (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN ASPIRANTE.CODIGO IS NOT NULL THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

    FUNCTION FORMULARIO2 (
        P_TIPDOC             VARCHAR2,
        P_NUMDOC             VARCHAR2,
        P_CODIGO_FACULTAD    VARCHAR2,
        P_JORNADA_FACULTAD   VARCHAR2,
        P_ANIO               VARCHAR2,
        P_CICLO              VARCHAR2
    ) RETURN NUMBER IS
        V_RETURNABLE NUMBER;
    BEGIN
        SELECT CASE
            WHEN ASPIRANTE.ESQUEMA = 'PREGRADO'
                 AND ASPIRANTE.NUMSNP IS NOT NULL THEN
                '1'
            WHEN ASPIRANTE.ESQUEMA = 'POSTGRADO'
                 AND ASPIRANTE.SEXO IS NOT NULL THEN
                '1'
            ELSE
                '0'
        END
        INTO V_RETURNABLE
        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
        LEFT JOIN (SELECT CODIGO,
                          TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          NUMSNP,
                          SEXO,
                          'PREGRADO' ESQUEMA
                   FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                   UNION
                   SELECT CODIGO,
                          CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                          NUMDOC,
                          CODIGO_FACULTAD,
                          JORNADA_FACULTAD,
                          ANIO,
                          CICLO,
                          NULL,
                          SEXO,
                          'POSTGRADO' ESQUEMA
                   FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
        WHERE INTERESADO.TIPDOC = P_TIPDOC
              AND INTERESADO.NUMDOC            = P_NUMDOC
              AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
              AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
              AND INTERESADO.ANIO              = P_ANIO
              AND INTERESADO.CICLO             = P_CICLO;

        RETURN V_RETURNABLE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END;

END;
/

GRANT EXECUTE ON PKG_ESTADO_INTERESADO TO DESARROLLOSPRE;