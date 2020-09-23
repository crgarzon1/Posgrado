SET DEFINE OFF;

/* ******************************ELIMINACION DE OBJETOS CREADOS****************************************/
/* ****************************************************************************************************/

DROP TYPE DICTIONARY;

DROP TYPE KEY_VALUE_PAIR;

DROP SEQUENCE HTTP_REQUEST_LOG_SEQ;

DROP TRIGGER HTTP_REQUEST_LOG_TRG;

DROP TABLE HTTP_REQUEST_LOG;

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

/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ***********************************LOGICA DE INTEGRACION********************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/

DROP TABLE CTI_INTERESADO_CRM;

DROP TRIGGER CALL_CRM_SERVICE_INTERESADO;

/* ****************************************************************************************************/

CREATE TABLE CTI_INTERESADO_CRM (
    TIPDOC             VARCHAR2 (8),
    NUMDOC             VARCHAR2 (32),
    CODIGO_FACULTAD    VARCHAR2 (2),
    JORNADA_FACULTAD   VARCHAR2 (1),
    ANIO               VARCHAR2 (4),
    CICLO              VARCHAR2 (2),
    HABEAS_DATA        NUMBER,
    PAGO_INSCRIPCION   NUMBER,
    ENTREVISTA         NUMBER,
    ADMITIDO           NUMBER,
    MATRICULADO        NUMBER,
    SPP                NUMBER,
    FORMULARIO1        NUMBER,
    FORMULARIO2        NUMBER,
    CONSTRAINT CTI_INTERESADO_CRM_PK PRIMARY KEY (TIPDOC,
                                                  NUMDOC,
                                                  CODIGO_FACULTAD,
                                                  JORNADA_FACULTAD,
                                                  ANIO,
                                                  CICLO),
    CONSTRAINT CTI_INTERESADO_CRM_FK FOREIGN KEY (TIPDOC,
                                                  NUMDOC,
                                                  CODIGO_FACULTAD,
                                                  JORNADA_FACULTAD,
                                                  ANIO,
                                                  CICLO)
        REFERENCES CTI_INTERESADO (TIPDOC,
                                   NUMDOC,
                                   CODIGO_FACULTAD,
                                   JORNADA_FACULTAD,
                                   ANIO,
                                   CICLO),
    CONSTRAINT CTI_INT_HABEAS_DATA CHECK (HABEAS_DATA in (0, 1)),
    CONSTRAINT CTI_INT_PAGO_INSCRIPCION CHECK (PAGO_INSCRIPCION in (0, 1)),
    CONSTRAINT CTI_INT_ENTREVISTA CHECK (ENTREVISTA in (0, 1)),
    CONSTRAINT CTI_INT_ADMITIDO CHECK (ADMITIDO in (0, 1)),
    CONSTRAINT CTI_INT_MATRICULADO CHECK (MATRICULADO in (0, 1)),
    CONSTRAINT CTI_INT_SPP CHECK (SPP in (0, 1)),
    CONSTRAINT CTI_INT_FORMULARIO1 CHECK (FORMULARIO1 in (0, 1)),
    CONSTRAINT CTI_INT_FORMULARIO2 CHECK (FORMULARIO2 in (0, 1))
);
/

CREATE OR REPLACE TRIGGER CALL_CRM_SERVICE_INTERESADO AFTER
    UPDATE OR INSERT ON CTI_INTERESADO_CRM
    FOR EACH ROW
DECLARE
    V_INTERESADO       DESARROLLOSPRE.CTI_INTERESADO%ROWTYPE;
    V_ADITIONAL_INFO   ADMISIONES.CRM_ADITIONAL_INFO;
BEGIN
    SELECT TIPDOC,
           NUMDOC,
           CODIGO_FACULTAD,
           JORNADA_FACULTAD,
           PRIMER_NOMBRE,
           SEGUNDO_NOMBRE,
           PRIMER_APELLIDO,
           SEGUNDO_APELLIDO,
           CELULAR,
           EMAIL,
           ORIGEN,
           ANIO,
           CICLO,
           FECHA
    INTO V_INTERESADO
    FROM CTI_INTERESADO A
    WHERE A.TIPDOC = :NEW.TIPDOC
          AND A.NUMDOC = :NEW.NUMDOC
          AND A.CODIGO_FACULTAD = :NEW.CODIGO_FACULTAD
          AND A.JORNADA_FACULTAD = :NEW.JORNADA_FACULTAD
          AND A.ANIO   = :NEW.ANIO
          AND A.CICLO  = :NEW.CICLO;

    V_ADITIONAL_INFO := ADMISIONES.CRM_ADITIONAL_INFO (:NEW.HABEAS_DATA, :NEW.PAGO_INSCRIPCION, :NEW.ENTREVISTA, :NEW.ADMITIDO, :NEW.MATRICULADO,
                               :NEW.SPP, :NEW.FORMULARIO1, :NEW.FORMULARIO2, CASE WHEN UPDATING THEN 1 ELSE 0 END);

    ADMISIONES.CALL_CRM_SERVICE (V_INTERESADO, V_ADITIONAL_INFO);
END;
/

/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ***********************************LOGICA DE INTEGRACION********************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/

CREATE OR REPLACE TRIGGER CALL_CRM_SERVICE_ASPIRANTE AFTER
    UPDATE OR INSERT ON A_ASPIRANTES
FOR EACH ROW DECLARE
    V_INTERESADO               DESARROLLOSPRE.CTI_INTERESADO%ROWTYPE;
    V_ADITIONAL_INFO           CRM_ADITIONAL_INFO;
    V_ESTUDIANTE_INSCRITO      NUMBER DEFAULT '0';
    V_ESTUDIANTE_MATRICULADO   NUMBER DEFAULT '0';
    V_ESTUDIANTE_SPP           NUMBER DEFAULT '0';
BEGIN
    SELECT TIPDOC,
           NUMDOC,
           CODIGO_FACULTAD,
           JORNADA_FACULTAD,
           PRIMER_NOMBRE,
           SEGUNDO_NOMBRE,
           PRIMER_APELLIDO,
           SEGUNDO_APELLIDO,
           CELULAR,
           EMAIL,
           ORIGEN,
           ANIO,
           CICLO,
           FECHA
    INTO V_INTERESADO
    FROM DESARROLLOSPRE.CTI_INTERESADO
    WHERE TIPDOC = :NEW.TIPDOC
          AND NUMDOC            = :NEW.NUMDOC
          AND CODIGO_FACULTAD   = :NEW.CODIGO_FACULTAD
          AND JORNADA_FACULTAD  = :NEW.JORNADA_FACULTAD
          AND ANIO              = :NEW.ANIO
          AND CICLO             = :NEW.CICLO
          AND ORIGEN            = 'sepRebr5';

    SELECT NVL ((SELECT '1'
                FROM G_OTROS_PAGOS OP
                WHERE OP.CODIGO_EST = :NEW.CODIGO
                      AND OP.INDICADOR_PAGO  = 'P'
                      AND OP.ACTIVA          = 1
                      AND OP.ANIO            = :NEW.ANIO
                      AND OP.CICLO           = :NEW.CICLO
                ), 0)
    INTO V_ESTUDIANTE_INSCRITO
    FROM DUAL;

    SELECT NVL ((SELECT '1'
                FROM B_ESTUDIANTES E
                WHERE E.CODIGO IS NOT NULL
                      AND E.CODIGO = :NEW.COD_DEF
                      AND E.INDICADOR_PAGO IN (
                    'P', 'V'
                )
                ), 0)
    INTO V_ESTUDIANTE_MATRICULADO
    FROM DUAL;
    
    SELECT NVL ((SELECT 1
             FROM BENEFICIARIOS_BECAS BB
             WHERE BB.DOCUMENTO = :NEW.NUMDOC
                   AND BB.ANIO   = :NEW.ANIO
                   AND BB.CICLO  = :NEW.CICLO
            ), 0)
    INTO V_ESTUDIANTE_SPP
    FROM DUAL;

-- NUEVO
                                            
    CALL_CRM_SERVICE (V_INTERESADO, V_ADITIONAL_INFO);
EXCEPTION
    WHEN OTHERS THEN
        PKG_EXCEPTION.LOG_EXCEPTION ();
END;
/
/* ************************************SCRIPT DE PRUEBA************************************************/
/* ****************************************************************************************************/

DECLARE
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
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'primer_nombre', 'DIEGO');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'segundo_nombre', 'ALEJANDRO');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'primer_apellido', 'CASAS');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'segundo_apellido', 'FORERO');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'tipo_documento', 'C');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'documento', '1007103502');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'email', 'ralejo178@gmail.com');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'celular', '3502631126');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'programa', '10D');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'origen', 'Google Adwords - 10');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'fecha', '2020-03-11 15:51:43');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'habeas_data', '1');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'pago_inscripcion', '0');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'entrevista', '0');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'admitido', '0');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'matriculado', '0');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'spp', '0');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'formulario1', '1');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'formulario2', '1');
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'nuevo', '1'); -- Nuevo en 0 actualizar en 1
    V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'fuente', 'SIA');
    MAKE_HTTP_REQUEST (V_URL, V_METHOD, V_HEADERS, V_BODY_PARAMS);
    MAKE_HTTP_REQUEST ('http://jupiter.lasalle.edu.co:80/laSalleExposedServices/gateway/19D6414BEADFE763874DB7882ADA9E105C97FE2BDFE09D4D47A75E1F291ABF84ACEC26927C04F975E51CAF5F452622874DB10A9EAC823BE19E6ABAF6E90BF77E4C5CB0E41728437DA74A6370CA62DE908B6360ABB41D7DB00F06C20A9C012D9A?p_codigo_estudiante=81052210'
    , 'GET', NULL, NULL);
END;
/

    INSERT INTO DESARROLLOSPRE.CTI_INTERESADO VALUES (
        'C',
        '12332444544',
        '85',
        'N',
        'MIGUEL111',
        'ANGEL111',
        'SARMIENTO111',
        'ALONSO111',
        '3126854051',
        'zeussar@hotmail.com',
        'sepRebr5',
        '2020',
        '01',
        SYSDATE
    );
/
SELECT COUNT (*)
FROM HTTP_REQUEST_LOG;

SELECT HTTP_REQUEST_LOG_ID,
       TO_CHAR (REQUEST_DATE, 'YYYY-MM-DD HH:MI'),
       HTTP_METHOD,
       URL,
       CONTENT,
       RESPONSE
FROM HTTP_REQUEST_LOG
ORDER BY HTTP_REQUEST_LOG_ID DESC;