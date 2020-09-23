CREATE OR REPLACE PACKAGE PKG_CTI_CRM AS
    FUNCTION GET_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_NON_MANDATORY_STRING (
        P_DATOS   IN   NCLOB,
        P_FIELD   IN   VARCHAR2
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

    PROCEDURE ENVIAR_RESPUESTA_CRM;

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
        P_ANIO               VARCHAR2 (4);
        P_CICLO              VARCHAR2 (2);
        P_JSON               JSON;
    BEGIN
        /*OWA_UTIL.PRINT_CGI_ENV;
        htp.print('-----------------------------------');
        htp.print(OWA_UTIL.get_cgi_env('cti_token_proveedores'));
        htp.print('-----------------------------------');
        for i in 1..owa.num_cgi_vars loop
             htp.print(owa.cgi_var_name(i)||' = '||owa.cgi_var_val(i)||htf.nl);
        end loop;
        htp.print('-----------------------------------');
        htp.print(owa_cookie.get('cti_token_proveedores').vals(1));*/
        P_JSON               := JSON ();
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
        P_ANIO               := GET_MANDATORY_STRING (P_DATOS, 'anio');
        P_CICLO              := GET_MANDATORY_STRING (P_DATOS, 'ciclo');
        VALIDAR_PROGRAMA (P_CODIGO_PROGRAMA, P_JORNADA_PROGRAMA);
        VALIDAR_INSCRIPCION (P_NUMERO_DOCUMENTO, P_CODIGO_PROGRAMA, P_JORNADA_PROGRAMA, P_ANIO, P_CICLO);
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
            P_JORNADA_PROGRAMA,
            P_PRIMER_NOMBRE,
            P_SEGUNDO_NOMBRE,
            P_PRIMER_APELLIDO,
            P_SEGUNDO_APELLIDO,
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

    PROCEDURE ENVIAR_RESPUESTA_CRM IS

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
        V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'nuevo', '1');
        V_BODY_PARAMS   := ADD_TO_DICTIONNARY (V_BODY_PARAMS, 'fuente', 'SIA');
        MAKE_HTTP_REQUEST (V_URL, V_METHOD, V_HEADERS, V_BODY_PARAMS);
    EXCEPTION
        WHEN OTHERS THEN
            PKG_EXCEPTION.LOG_EXCEPTION;
    END;

END PKG_CTI_CRM;
/