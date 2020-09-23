/* CREACION DE SECUENCIA.*/
CREATE SEQUENCE CTI_INTERESADOS_CRM_LOG_SEQ START WITH 1;

/* CREACION DE TABLA.*/

CREATE TABLE CTI_INTERESADOS_CRM_LOG (
    CTI_INTERESADOS_CRM_LOG_ID   NUMBER PRIMARY KEY,
    INSERTION_DATE               DATE,
    TIPDOC                       VARCHAR2 (8),
    NUMDOC                       VARCHAR2 (32),
    CODIGO_FACULTAD              VARCHAR2 (2),
    JORNADA_FACULTAD             VARCHAR2 (1),
    ANIO                         VARCHAR2 (4),
    CICLO                        VARCHAR2 (2)
);

/* CREACION DE TRIGGER.*/

CREATE TRIGGER CTI_INTERESADOS_CRM_LOG_TRG BEFORE
    INSERT ON CTI_INTERESADOS_CRM_LOG
    FOR EACH ROW
BEGIN
    SELECT CTI_INTERESADOS_CRM_LOG_SEQ.NEXTVAL,
           SYSDATE
    INTO
        :NEW.CTI_INTERESADOS_CRM_LOG_ID,
        :NEW.INSERTION_DATE
    FROM DUAL;

END;
/
CREATE OR REPLACE PACKAGE PKG_CTI_CRM AS
    FUNCTION GET_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_NON_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GETPERIODO (
        P_PROGRAMA VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE GUARDAR_DATOS_INTERESADO (
        P_DATOS IN NCLOB
    );

    PROCEDURE VALIDAR_INSCRIPCION (
        P_DOCUMENTO   VARCHAR2,
        P_PROGRAMA    VARCHAR2,
        P_JORNADA     VARCHAR2,
        P_ANIO        VARCHAR2,
        P_CICLO       VARCHAR2
    );

    PROCEDURE VALIDAR_PROGRAMA (
        P_PROGRAMA   VARCHAR2,
        P_JORNADA    VARCHAR2
    );

END PKG_CTI_CRM;
/

CREATE OR REPLACE PACKAGE BODY PKG_CTI_CRM AS
 /*
        -----------------------------------------------------------------------------
        VERIFICA QUE EL CAMPO OBLIGATORIO EXISTE
        -----------------------------------------------------------------------------
        */

    FUNCTION GET_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
    ) RETURN VARCHAR2 IS
        C_DATOS JSON DEFAULT JSON (P_DATOS);
    BEGIN
        BEGIN
            RETURN C_DATOS.GET (P_FIELD).GET_STRING;
        EXCEPTION
            WHEN OTHERS THEN
                PKG_EXCEPTION.RAISE_EXCEPTION_WITH_INFO ('-20006', P_FIELD);
        END;
    END GET_MANDATORY_STRING;

 /*
        -----------------------------------------------------------------------------
        VERIFICA QUE EL CAMPO NO OBLIGATORIO EXISTE
        -----------------------------------------------------------------------------
        */

    FUNCTION GET_NON_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
    ) RETURN VARCHAR2 IS
        C_DATOS JSON DEFAULT JSON (P_DATOS);
    BEGIN
        BEGIN
            RETURN C_DATOS.GET (P_FIELD).GET_STRING;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN '';
        END;
    END GET_NON_MANDATORY_STRING;
    
    /*
        -----------------------------------------------------------------------------
        ´FUNCION PARA OBTENER ANIO Y CICLO PARA REGISTRO
        -----------------------------------------------------------------------------
        */

    FUNCTION GETPERIODO (
        P_PROGRAMA VARCHAR2
    ) RETURN VARCHAR2 AS
        V_PERIODO VARCHAR2 (8);
    BEGIN
        SELECT ANIO || CICLO
        INTO V_PERIODO
        FROM ADMISIONES.A_FECHAS_DE_CORTE
        WHERE PROCESO =
            CASE
                WHEN P_PROGRAMA < '71' THEN
                    'ADMISION ESTUDIANTES NUEVOS-PREGRADO'
                ELSE
                    'ADMISION ESTUDIANTES NUEVOS-POSTGRADO'
            END;

        RETURN V_PERIODO;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END GETPERIODO;

 /*
        -----------------------------------------------------------------------------
        ´PROCEDIMIENTO PARA GUARDAR INTERESADO 
        -----------------------------------------------------------------------------
        */

    PROCEDURE GUARDAR_DATOS_INTERESADO (
        P_DATOS IN NCLOB
    ) AS

        C_DATOS              JSON DEFAULT JSON (P_DATOS);
        P_TIPO_DOCUMENTO     VARCHAR2 (2);
        P_NUMERO_DOCUMENTO   VARCHAR2 (16);
        P_PRIMER_NOMBRE      VARCHAR2 (256);
        P_SEGUNDO_NOMBRE     VARCHAR2 (256);
        P_PRIMER_APELLIDO    VARCHAR2 (256);
        P_SEGUNDO_APELLIDO   VARCHAR2 (256);
        P_CELULAR            VARCHAR2 (32);
        P_EMAIL              VARCHAR2 (512);
        P_CODIGO_PROGRAMA    VARCHAR2 (8);
        P_JORNADA_PROGRAMA   VARCHAR2 (4);
        P_ORIGEN             VARCHAR2 (64);
        V_PERIODO            VARCHAR2 (8);
        P_ANIO               VARCHAR2 (4);
        P_CICLO              VARCHAR2 (2);
        P_JSON               JSON;
    BEGIN
        P_TIPO_DOCUMENTO     := GET_MANDATORY_STRING (P_DATOS, 'tipo_documento');
        P_NUMERO_DOCUMENTO   := GET_MANDATORY_STRING (P_DATOS, 'numero_documento');
        P_PRIMER_NOMBRE      := GET_MANDATORY_STRING (P_DATOS, 'primer_nombre');
        P_SEGUNDO_NOMBRE     := GET_NON_MANDATORY_STRING (P_DATOS, 'segundo_nombre');
        P_PRIMER_APELLIDO    := GET_MANDATORY_STRING (P_DATOS, 'primer_apellido');
        P_SEGUNDO_APELLIDO   := GET_NON_MANDATORY_STRING (P_DATOS, 'segundo_apellido');
        P_CELULAR            := GET_MANDATORY_STRING (P_DATOS, 'celular');
        P_EMAIL              := GET_MANDATORY_STRING (P_DATOS, 'email');
        P_CODIGO_PROGRAMA    := GET_MANDATORY_STRING (P_DATOS, 'codigo_programa');
        P_JORNADA_PROGRAMA   := GET_MANDATORY_STRING (P_DATOS, 'jornada_programa');
        P_ORIGEN             := GET_MANDATORY_STRING (P_DATOS, 'origen');
        V_PERIODO            := GETPERIODO (P_CODIGO_PROGRAMA);
        P_ANIO               := SUBSTR (V_PERIODO, 0, 4);
        P_CICLO              := SUBSTR (V_PERIODO, 5, 2);
        VALIDAR_PROGRAMA (P_CODIGO_PROGRAMA, P_JORNADA_PROGRAMA);
        VALIDAR_INSCRIPCION (P_NUMERO_DOCUMENTO, P_CODIGO_PROGRAMA, P_JORNADA_PROGRAMA, P_ANIO, P_CICLO);
        INSERT INTO CTI_INTERESADOS_CRM_LOG (
            TIPDOC,
            NUMDOC,
            CODIGO_FACULTAD,
            JORNADA_FACULTAD,
            ANIO,
            CICLO
        ) VALUES (
            P_TIPO_DOCUMENTO,
            P_NUMERO_DOCUMENTO,
            P_CODIGO_PROGRAMA,
            UPPER (P_JORNADA_PROGRAMA),
            P_ANIO,
            P_CICLO
        );
        INSERT INTO DESARROLLOSPRE.CTI_INTERESADO (
            TIPDOC,
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
        ) VALUES (
            P_TIPO_DOCUMENTO,
            P_NUMERO_DOCUMENTO,
            P_CODIGO_PROGRAMA,
            UPPER (P_JORNADA_PROGRAMA),
            UPPER (P_PRIMER_NOMBRE),
            UPPER (P_SEGUNDO_NOMBRE),
            UPPER (P_PRIMER_APELLIDO),
            UPPER (P_SEGUNDO_APELLIDO),
            P_CELULAR,
            P_EMAIL,
            P_ORIGEN,
            P_ANIO,
            P_CICLO,
            SYSDATE
        );
        PKG_JSON_RESPONSE.PRINT_SUCCESSFUL ('El aspirante se inscribio satisfactoriamente.');
    EXCEPTION
        WHEN OTHERS THEN
            PKG_JSON_RESPONSE.PRINT_FAILURE_OR_EXCEPTION ();
    END GUARDAR_DATOS_INTERESADO;

 /*
        -----------------------------------------------------------------------------
        VALIDAR SI EL ESTUDIANTE YA ESTÁ INSCRITO BUSCANDO POR DOCUMENTO,
        CODIGO DE PROGRAMA Y JORNADA
        -----------------------------------------------------------------------------
        */

    PROCEDURE VALIDAR_INSCRIPCION (
        P_DOCUMENTO   VARCHAR2,
        P_PROGRAMA    VARCHAR2,
        P_JORNADA     VARCHAR2,
        P_ANIO        VARCHAR2,
        P_CICLO       VARCHAR2
    ) AS
        V_ESTA_INSCRITO NUMBER;
    BEGIN
        SELECT COUNT (*)
        INTO V_ESTA_INSCRITO
        FROM DESARROLLOSPRE.CTI_INTERESADO I
        WHERE I.NUMDOC = P_DOCUMENTO
              AND I.CODIGO_FACULTAD   = P_PROGRAMA
              AND I.JORNADA_FACULTAD  = P_JORNADA
              AND I.ANIO || I.CICLO   = P_ANIO || P_CICLO
              AND ROWNUM <= 1;

        IF V_ESTA_INSCRITO > 0 THEN
            PKG_EXCEPTION.RAISE_EXCEPTION ('-20004');
        END IF;
    END VALIDAR_INSCRIPCION;

 /*
        -----------------------------------------------------------------------------
        VALIDAR SI EL PROGRAMA EXISTE
        -----------------------------------------------------------------------------
        */

    PROCEDURE VALIDAR_PROGRAMA (
        P_PROGRAMA   VARCHAR2,
        P_JORNADA    VARCHAR2
    ) AS
        V_EXISTE_PROGRAMA NUMBER;
    BEGIN
        SELECT COUNT (*)
        INTO V_EXISTE_PROGRAMA
        FROM (SELECT CODIGO,
                     JORNADA
              FROM ADMISIONES.A_FACULTADES
              UNION
              SELECT CODIGO,
                     JORNADA
              FROM POSTGRADO.A_FACULTADES
        ) P
        WHERE P.CODIGO = P_PROGRAMA
              AND P.JORNADA = P_JORNADA;

        IF V_EXISTE_PROGRAMA = 0 THEN
            PKG_EXCEPTION.RAISE_EXCEPTION ('-20003');
        END IF;
    END VALIDAR_PROGRAMA;

END PKG_CTI_CRM;
/