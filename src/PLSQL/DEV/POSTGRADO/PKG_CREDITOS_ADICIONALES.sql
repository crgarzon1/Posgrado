-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- ELIMINACION DE OBJETOS PARA EL FUNCIONAMIENTO DE LOS CREDITOS ADICIONALES.
-- ****************************************************************************************************************************

-- ELIMINANDO TRIGGERS.
DROP TRIGGER CTI_LOG_POSGRADO_TRG;
DROP TRIGGER CREDITOS_EXTRAS_AUTOR_TRG;
-- ELIMINANDO TABLAS.
DROP TABLE CTI_LOG_POSGRADO;
DROP TABLE CTI_CRED_EXTRAS_AUTORIZACION;
-- ELIMINANDO SECUENCIAS.
DROP SEQUENCE CTI_LOG_POSGRADO_SEQ;
DROP SEQUENCE CREDITOS_EXTRAS_AUTOR_SEQ;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBJETOS PARA LA CREACION DE LA TABLA CTI_CRED_EXTRAS_AUTORIZACION. REGISTROS DE TODAS LAS SOLICITUDES DE CREDITOS 
-- ADICIONALES.
-- ****************************************************************************************************************************

-- CREACION DE SECUENCIA.
CREATE SEQUENCE CREDITOS_EXTRAS_AUTOR_SEQ START WITH 1;
-- CREACION DE TABLA.
CREATE TABLE CTI_CRED_EXTRAS_AUTORIZACION (
    AUTORIZACION_ID NUMBER PRIMARY KEY,
    CODIGO_ESTUDIANTE VARCHAR2(8) NOT NULL,
    CODIGO_GUIA NUMBER REFERENCES ADMISIONES.G_GUIAS_DE_PAGO(CODIGO_GUIA),
    GUIA_FINANCIERA VARCHAR2(50) NOT NULL,
    NUMERO_CREDITOS_ADICIONALES NUMBER NOT NULL,
    CANCELADA NUMBER DEFAULT 0,
    ANIO_SOLICITUD VARCHAR2(4) NOT NULL,
    CICLO_SOLICITUD VARCHAR2(2) NOT NULL,
    CONSTRAINT CREDITOS_EXTRAS_AUTO_CANC CHECK (CANCELADA IN (0, 1))
);
-- CREACION DE TRIGGER.
CREATE TRIGGER CREDITOS_EXTRAS_AUTOR_TRG 
BEFORE INSERT ON CTI_CRED_EXTRAS_AUTORIZACION 
FOR EACH ROW
BEGIN
  SELECT CREDITOS_EXTRAS_AUTOR_SEQ.NEXTVAL
  INTO   :NEW.AUTORIZACION_ID
  FROM   DUAL;
END;
/

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBJETOS PARA LA CREACION DE LA TABLA CTI_CRED_EXTRAS_AUTORIZACION. REGISTROS DE TODAS LAS SOLICITUDES DE CREDITOS 
-- ADICIONALES.
-- ****************************************************************************************************************************

-- CREACION DE SECUENCIA.
CREATE SEQUENCE CTI_LOG_POSGRADO_SEQ START WITH 1;
-- CREACION DE TABLA.
CREATE TABLE CTI_LOG_POSGRADO (
    LOG_ID NUMBER,
    PROCESO VARCHAR2(50),
    FECHA DATE NOT NULL,
    IP VARCHAR2 (16),
    USUARIO_ACCION VARCHAR2 (32) NOT NULL,
    USUARIO_AFECTADO VARCHAR2 (32),
    ACCION VARCHAR2 (32) NOT NULL,
    DESCRIPCION VARCHAR2 (256) NOT NULL,
    ANIO VARCHAR2 (4) NOT NULL,
	CICLO VARCHAR2 (2) NOT NULL
);
-- CREACION DE TRIGGER.
CREATE TRIGGER CTI_LOG_POSGRADO_TRG 
BEFORE INSERT ON CTI_LOG_POSGRADO 
FOR EACH ROW
BEGIN
  SELECT CTI_LOG_POSGRADO_SEQ.NEXTVAL
  INTO   :NEW.LOG_ID
  FROM   DUAL;
END;
/

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- PAQUETE QUE CONTIENE TODOS LOS PROCEDIMIENTOS NECESARIOS PARA LA AUTORIZACION DE CREDITOS ADICIONALES PARA POSGRADO.
-- ****************************************************************************************************************************

CREATE OR REPLACE PACKAGE PKG_CREDITOS_ADICIONALES AS

    /*
        SE LISTAN TODOS LOS ESTUDIANTES DE POSGRADO CON CREDITOS ADICIONALES EN CUALQUIER ESTADO (AUTORIZADO, PAGADO O CANCELADO)
        @param P_CODIGO_FACULTAD => Codigo facultad.   
        @param P_JORNADA_FACULTAD => Jornada facultad. 
        */
	PROCEDURE LISTAR_ESTUDIANTES (
        P_CODIGO_FACULTAD VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
    );

    /*        
        SE BUSCAN ESTUDIANTES DE POSGRADO QUE CUMPLAN CON EL CREITERIO DE BUSQUEDA (NOMBRE, CODIGO O NUMERO DE DOCUMENTO).
        @param P_CRITERIO_BUSQUEDA VARCHAR2 => NOMBRE, CODIGO O NUMERO DE DOCUMENTO.
        @param P_CODIGO_FACULTAD => Codigo facultad.   
        @param P_JORNADA_FACULTAD => Jornada facultad. 
        */
	PROCEDURE BUSCAR_ESTUDIANTE (
		P_CRITERIO_BUSQUEDA VARCHAR2,
        P_CODIGO_FACULTAD VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
	);

    /*
        SE AUTORIZAN LOS CREDITOS ADICIONALES PARA UN DETERMINADO ESTUDIANTE (SIN ESTADO => AUTORIZADO). SE CREA EL REGISTRO EN 
        CTI_CRED_EXTRAS_AUTORIZACION.
        @param P_CODIGO_ESTUDIANTE VARCHAR2 => Codigo del estudiante.
        @param P_NUMERO_CREDITOS NUMBER     => Numero de creditos autorizados.
        @param P_CODIGO_FACULTAD => Codigo facultad.   
        @param P_JORNADA_FACULTAD => Jornada facultad. 
        */
	PROCEDURE AUTORIZAR_CREDITOS (
		P_CODIGO_ESTUDIANTE VARCHAR2,
        P_NUMERO_CREDITOS NUMBER,
        P_NUMERO_GUIA_PAGO NUMBER,
        P_GUIA_FINANCIERA   VARCHAR2,
        P_CODIGO_FACULTAD VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
	);
        
    /*
        SE LE ASIGNA ESTADO CANCELADO A DETERMINADO REGISTRO EN CTI_CRED_EXTRAS_AUTORIZACION.
        @param ID_AUTORIZACION VARCHAR2 => Identificador de la tabla CTI_CRED_EXTRAS_AUTORIZACION.  
        @param P_CODIGO_FACULTAD => Codigo facultad.   
        @param P_JORNADA_FACULTAD => Jornada facultad. 
        */
	PROCEDURE CANCELAR_CREDITOS (
		P_AUTORIZACION_ID NUMBER,
        P_CODIGO_FACULTAD VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
    );
    
    /*
        OBTIENE LA CANTIDAD DE CREDITOS ADICIONALES DISPONIBLES PARA UN ESTUDIANTE.
            EL NUMERO DE CREDITOS ADICIONALES DISPONIBLES SE DA POR LA FORMULA:
            CAD = (CT / 2) - CAI.
            DONDE:
            CAD: CREDITOS ADICIONALES INSCRITOS.
            CT: CREDITOS TRIMESTRE.
            CAI: CREDITOS ADICIONALES INSCRITOS.        
        @param P_CODIGO_ESTUDIANTE VARCHAR2
        @return 
        */
    FUNCTION GET_CREDITOS_ADICIONALES_DISP (
		P_CODIGO_ESTUDIANTE VARCHAR2
    ) RETURN NUMBER;
    
    /*
        AGREGAR REGISTRO EN EL LOG.
        @param IP VARCHAR2
        @param USUARIO VARCHAR2
        @param USUARIO_AFECTADO VARCHAR2
        @param ACCION VARCHAR2
        @param DESCRIPCION VARCHAR2
        */
    PROCEDURE ADD_LOG (
        P_PROCESO VARCHAR2,
        P_IP VARCHAR2,
        P_USUARIO VARCHAR2,
        P_USUARIO_AFECTADO VARCHAR2,
        P_ACCION VARCHAR2,
        P_DESCRIPCION VARCHAR2
    );
END PKG_CREDITOS_ADICIONALES;
/

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- 
-- ****************************************************************************************************************************

CREATE OR REPLACE PACKAGE BODY PKG_CREDITOS_ADICIONALES AS

    /*
        SE LISTAN TODOS LOS ESTUDIANTES DE POSGRADO CON CREDITOS ADICIONALES EN CUALQUIER ESTADO (AUTORIZADO, PAGADO O CANCELADO)
        @param P_CODIGO_FACULTAD => Codigo facultad.   
        @param P_JORNADA_FACULTAD => Jornada facultad. 
        */
	PROCEDURE LISTAR_ESTUDIANTES (
        P_CODIGO_FACULTAD  VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
    ) IS
        V_ANIO      VARCHAR2 (4);
        V_CICLO     VARCHAR2 (2);
        V_ESQUEMA   VARCHAR2 (32);
		V_RESPONSE  JSON;
		V_REGISTROS JSON_LIST;
		V_REGISTRO  JSON;
	BEGIN
        PKG_HTML.CORSHEADERS();
		V_RESPONSE := JSON (); 
		V_REGISTROS := JSON_LIST (); 
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
        -- ITERANDO SOBRE LOS REGISTROS DEL AÑO Y CICLO ACTUAL.
        FOR AUXILIAR_RECORD IN (SELECT     CEA.AUTORIZACION_ID,
                                           CEA.CODIGO_ESTUDIANTE,
                                           INITCAP(BE.NOMBRES || ' ' || BE.APELLIDOS) NOMBRES,
                                           CEA.NUMERO_CREDITOS_ADICIONALES,
                                           CEA.CODIGO_GUIA,
                                           CEA.GUIA_FINANCIERA,
                                           CASE
                                                WHEN GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '0' THEN 'Autorizado'
                                                WHEN GDP.INDICADOR_PAGO = 'P' THEN 'Pagado'
                                                WHEN GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '1' THEN 'Cancelado'
                                           END VALOR,
                                           CEA.ANIO_SOLICITUD,
                                           CEA.CICLO_SOLICITUD,
                                           CASE
                                                WHEN GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '0' THEN '1'
                                                WHEN GDP.INDICADOR_PAGO = 'P' THEN '2'
                                                WHEN GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '1' THEN '3'
                                           END ESTADO_ID
                                FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA
                                INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA.CODIGO_GUIA
                                INNER JOIN B_ESTUDIANTES BE ON CEA.CODIGO_ESTUDIANTE = BE.CODIGO
                                WHERE      -- QUE LA SOLICITUD SEA PARA EL PERIODO ACTUAL.
                                               ANIO_SOLICITUD  = V_ANIO 
                                           AND CICLO_SOLICITUD = V_CICLO
                                           -- IMPORTANTE: QUE PERTENEZCAN AL PROGRAMA ACTUAL.
                                           AND BE.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                           AND BE.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                ORDER BY   GDP.INDICADOR_PAGO,
                                           GDP.FECHA_GEN DESC) LOOP 
			V_REGISTRO := JSON ();
			JSON.PUT (V_REGISTRO, 'autorizacionId', AUXILIAR_RECORD.AUTORIZACION_ID);
			JSON.PUT (V_REGISTRO, 'codigoEstudiante', AUXILIAR_RECORD.CODIGO_ESTUDIANTE);
			JSON.PUT (V_REGISTRO, 'nombreEstudiante', AUXILIAR_RECORD.NOMBRES);
			JSON.PUT (V_REGISTRO, 'numeroCreditosAdicionales', AUXILIAR_RECORD.NUMERO_CREDITOS_ADICIONALES);
			JSON.PUT (V_REGISTRO, 'numeroGuiaPago', AUXILIAR_RECORD.CODIGO_GUIA);
			JSON.PUT (V_REGISTRO, 'guiaFinanciera', AUXILIAR_RECORD.GUIA_FINANCIERA);
			JSON.PUT (V_REGISTRO, 'estado', AUXILIAR_RECORD.VALOR);
			JSON.PUT (V_REGISTRO, 'anioSolicitud', AUXILIAR_RECORD.ANIO_SOLICITUD);
			JSON.PUT (V_REGISTRO, 'cicloSolicitud', AUXILIAR_RECORD.CICLO_SOLICITUD);
			JSON_LIST.APPEND (V_REGISTROS, V_REGISTRO.TO_JSON_VALUE);
        END LOOP;
        JSON.PUT (V_RESPONSE, 'statusId', '1');
		JSON.PUT (V_RESPONSE, 'status', 'OK');
		JSON.PUT (V_RESPONSE, 'values', V_REGISTROS);
        JSON.HTP(V_RESPONSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_RESPONSE := JSON (); 
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_RESPONSE);
	END LISTAR_ESTUDIANTES;
    
    /*        
        SE BUSCAN ESTUDIANTES DE POSGRADO QUE CUMPLAN CON EL CREITERIO DE BUSQUEDA (NOMBRE, CODIGO O NUMERO DE DOCUMENTO).
        @param P_CRITERIO_BUSQUEDA VARCHAR2 => NOMBRE, CODIGO O NUMERO DE DOCUMENTO.
        */
    PROCEDURE BUSCAR_ESTUDIANTE (
		P_CRITERIO_BUSQUEDA VARCHAR2,
        P_CODIGO_FACULTAD VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
	) IS
		V_RESPONSE                  JSON;
		V_ESTUDIANTES               JSON_LIST;
		V_ESTUDIANTE                JSON;
        V_ANIO                      VARCHAR2 (4);
        V_CICLO                     VARCHAR2 (2);
        V_ESQUEMA                   VARCHAR2 (32);
        V_CREDITOS_ADICIONALES_DISP NUMBER;
    BEGIN
        PKG_HTML.CORSHEADERS();
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
		V_RESPONSE := JSON ();  
		V_ESTUDIANTES := JSON_LIST ();        
        -- ITERANDO SOBRE LOS ESTUDIANTES VALIDOS.
        FOR AUXILIAR_RECORD IN (SELECT DISTINCT E.CODIGO,
                                                INITCAP(E.NOMBRES || ' ' || E.APELLIDOS) NOMBRES,
                                                BG.TOPE,
                                                CEA.GUIA_FINANCIERA
                                FROM            B_ESTUDIANTES E
                                -- QUE TENGA UN REGISTRO EN CTI_BOLSA_GENERAL (BOLSA DE CREDITOS).
                                INNER JOIN      CTI_BOLSA_GENERAL BG ON BG.CODIGO = E.CODIGO
                                LEFT JOIN       ADMISIONES.DATOS_PERSONALES DP ON DP.CODIGO_ESTUDIANTE = E.CODIGO
                                LEFT JOIN       (SELECT     AUTORIZACION_ID,
                                                            CODIGO_ESTUDIANTE,
                                                            GUIA_FINANCIERA
                                                 FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA2
                                                 INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA2.CODIGO_GUIA
                                                 WHERE          GDP.INDICADOR_PAGO = 'X' 
                                                            AND CEA2.CANCELADA = '0') CEA ON CEA.CODIGO_ESTUDIANTE = E.CODIGO
                                WHERE               BG.CODIGO = P_CRITERIO_BUSQUEDA
                                                -- QUE TENGA EL SEMESTRE COMPLETO PAGADO.
                                                AND E.INDICADOR_PAGO = 'P'
                                                -- QUE NO TENGA SOLICITUDES AUTORIZADAS (NO PAGADAS) PARA EL SEMESTRE ACTUAL.
                                                AND BG.ANIO = V_ANIO
                                                AND BG.CICLO = V_CICLO
                                                -- IMPORTANTE: QUE PERTENEZCA AL PROGRAMA ACTUAL.
                                                AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
                                                AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                                AND ROWNUM = 1) LOOP 
            -- OBTENCION DE CREDITOS ADICIONALES DISPONIBLES.
            SELECT GET_CREDITOS_ADICIONALES_DISP(AUXILIAR_RECORD.CODIGO)
            INTO   V_CREDITOS_ADICIONALES_DISP
            FROM   DUAL;
			V_ESTUDIANTE := JSON ();
			JSON.PUT (V_ESTUDIANTE, 'foto', ADMISIONES.PKG_UTILS.GETFOTO(AUXILIAR_RECORD.CODIGO));
			JSON.PUT (V_ESTUDIANTE, 'codigoEstudiante', AUXILIAR_RECORD.CODIGO);
			JSON.PUT (V_ESTUDIANTE, 'nombreEstudiante', AUXILIAR_RECORD.NOMBRES);
			JSON.PUT (V_ESTUDIANTE, 'topeActual', AUXILIAR_RECORD.TOPE);
			JSON.PUT (V_ESTUDIANTE, 'creditosAdicionalesDisponibles', V_CREDITOS_ADICIONALES_DISP);
			JSON.PUT (V_ESTUDIANTE, 'guiaFinanciera', AUXILIAR_RECORD.GUIA_FINANCIERA);
			JSON_LIST.APPEND (V_ESTUDIANTES, V_ESTUDIANTE.TO_JSON_VALUE);
        END LOOP;
        JSON.PUT (V_RESPONSE, 'statusId', '1');
		JSON.PUT (V_RESPONSE, 'status', 'OK');
		JSON.PUT (V_RESPONSE, 'values', V_ESTUDIANTES);
        JSON.HTP(V_RESPONSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_RESPONSE := JSON (); 
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', SQLERRM);
            JSON.HTP(V_RESPONSE);
    END BUSCAR_ESTUDIANTE;

    /*
        SE AUTORIZAN LOS CREDITOS ADICIONALES PARA UN DETERMINADO ESTUDIANTE (SIN ESTADO => AUTORIZADO). SE CREA EL REGISTRO EN 
        CTI_CRED_EXTRAS_AUTORIZACION.
        @param P_CODIGO_ESTUDIANTE VARCHAR2 => Codigo del estudiante.
        @param P_NUMERO_CREDITOS NUMBER     => Numero de creditos autorizados.
        */
    PROCEDURE AUTORIZAR_CREDITOS (
		P_CODIGO_ESTUDIANTE VARCHAR2,
        P_NUMERO_CREDITOS   NUMBER,
        P_NUMERO_GUIA_PAGO  NUMBER,
        P_GUIA_FINANCIERA   VARCHAR2,
        P_CODIGO_FACULTAD   VARCHAR2,
        P_JORNADA_FACULTAD  VARCHAR2
	) IS
        V_ANIO                      VARCHAR2 (4);
        V_CICLO                     VARCHAR2 (2);
        V_ESQUEMA                   VARCHAR2 (32);
		V_RESPONSE                  JSON;
        V_CODIGO_ESTUDIANTE         VARCHAR2(8) DEFAULT NULL;
        V_CREDITOS_ADICIONALES_DISP NUMBER;
    BEGIN
        PKG_HTML.CORSHEADERS();
		V_RESPONSE := JSON (); 
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
        -- OBTENIENDO CODIGO DEL ESTUDIANTE PARA VERIFICAR VALIDEZ.
        SELECT    MAX(CODIGO)
        INTO      V_CODIGO_ESTUDIANTE
        FROM      B_ESTUDIANTES E
        -- AUTORIZACIONES DE CREDITOS ADICIONALES ACTUALES.
        LEFT JOIN (SELECT     CEA.AUTORIZACION_ID,
                              CEA.CODIGO_ESTUDIANTE
                   FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA
                   INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA.CODIGO_GUIA
                   WHERE          CEA.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE
                              -- AUTORIZACIONES PARA EL PERIODO ACTUAL.
                              AND CEA.ANIO_SOLICITUD = V_ANIO
                              AND CEA.CICLO_SOLICITUD = V_CICLO
                              -- AUTORIZACIONES EN ESTADO AUTORIZADAS O CON EL MISMO NUMERO DE GUIA.
                              AND (   (GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '0') 
                                   OR CEA.CODIGO_GUIA = P_NUMERO_GUIA_PAGO)) CEA_B ON CEA_B.CODIGO_ESTUDIANTE = E.CODIGO
        WHERE      E.CODIGO = P_CODIGO_ESTUDIANTE
               AND E.INDICADOR_PAGO = 'P'
               -- NO DEBEN EXISTIR AUTORIZACIONES SIN PAGAR O SIN CANCELAR, O ACTUALIZACIONES CON EL NUMERO DE GUIA ENVIADO.
               AND CEA_B.AUTORIZACION_ID IS NULL
               -- IMPORTANTE: EL ESTUDIANTE DEBE PERTENECER AL PROGRAMA ACTUAL.
               AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
               AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD;
        -- OBTENCION DE CREDITOS ADICIONALES DISPONIBLES.
        SELECT GET_CREDITOS_ADICIONALES_DISP(P_CODIGO_ESTUDIANTE)
        INTO   V_CREDITOS_ADICIONALES_DISP
        FROM   DUAL;        
        -- VERIFICANDO SI LA INFORMACION ES VALIDA.
        IF (    P_NUMERO_CREDITOS > 0 
            AND V_CODIGO_ESTUDIANTE IS NOT NULL
            AND P_NUMERO_CREDITOS <= V_CREDITOS_ADICIONALES_DISP) THEN
            INSERT INTO CTI_CRED_EXTRAS_AUTORIZACION (CODIGO_ESTUDIANTE ,
                                                      CODIGO_GUIA,
                                                      GUIA_FINANCIERA,
                                                      NUMERO_CREDITOS_ADICIONALES,
                                                      ANIO_SOLICITUD,
                                                      CICLO_SOLICITUD)
            VALUES (V_CODIGO_ESTUDIANTE,
                    P_NUMERO_GUIA_PAGO,
                    P_GUIA_FINANCIERA,
                    P_NUMERO_CREDITOS,
                    V_ANIO,
                    V_CICLO);
            -- <TEST>
            ADD_LOG ('CREDITOS ADICIONALES',
                     '111',
                     'TEST',
                     V_CODIGO_ESTUDIANTE,
                     'AUTORIZACION',
                     'AUTORIZACION_ID: ' || CREDITOS_EXTRAS_AUTOR_SEQ.CURRVAL);
            JSON.PUT (V_RESPONSE, 'statusId', '1');
            JSON.PUT (V_RESPONSE, 'status', 'OK');
            JSON.PUT (V_RESPONSE, 'values', CREDITOS_EXTRAS_AUTOR_SEQ.CURRVAL);
        ELSE
            V_RESPONSE := JSON (); 
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', 'Los datos suministrados no son validos.');
        END IF;
        JSON.HTP(V_RESPONSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_RESPONSE := JSON (); 
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_RESPONSE);
    END AUTORIZAR_CREDITOS;
        
    /*
        SE LE ASIGNA ESTADO CANCELADO A DETERMINADO REGISTRO EN CTI_CRED_EXTRAS_AUTORIZACION.
        @param ID_AUTORIZACION VARCHAR2 => Identificador de la tabla CTI_CRED_EXTRAS_AUTORIZACION.        
        */
	PROCEDURE CANCELAR_CREDITOS (
		P_AUTORIZACION_ID  NUMBER,
        P_CODIGO_FACULTAD  VARCHAR2,
        P_JORNADA_FACULTAD VARCHAR2
	) IS
        V_AUTORIZACION_ID   NUMBER DEFAULT NULL;
        V_CODIGO_ESTUDIANTE VARCHAR2(8) DEFAULT NULL;
		V_RESPONSE          JSON;
        V_CODIGO_GUIA       NUMBER;
    BEGIN
        PKG_HTML.CORSHEADERS();
		V_RESPONSE := JSON (); 
        -- OBTENEMOS LA AUTORIZACION SI ES VALIDA.        
        SELECT     MAX(AUTORIZACION_ID),
                   MAX(CODIGO_ESTUDIANTE),
                   MAX(CEA.CODIGO_GUIA)
        INTO       V_AUTORIZACION_ID,
                   V_CODIGO_ESTUDIANTE,
                   V_CODIGO_GUIA
        FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA
        INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA.CODIGO_GUIA
        INNER JOIN B_ESTUDIANTES E ON E.CODIGO = CEA.CODIGO_ESTUDIANTE
        WHERE      AUTORIZACION_ID = P_AUTORIZACION_ID
               AND (GDP.INDICADOR_PAGO = 'X' AND CEA.CANCELADA = '0')
               AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
               AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD;
        IF (    V_AUTORIZACION_ID IS NOT NULL
            AND V_CODIGO_ESTUDIANTE IS NOT NULL
            AND V_CODIGO_GUIA IS NOT NULL) THEN
            PKG_LIQUIDACION.MARCARGUIADESACTIVADA(V_CODIGO_GUIA);
            -- ACTUALIZAMOS EL REGISTRO ASIGNANDOLE ESTADO CANCELADO.
            -- SOLO SE ACTUALIZA SI EL ESTADO ACTUAL ES AUTORIZADO.
            UPDATE CTI_CRED_EXTRAS_AUTORIZACION 
            SET    CANCELADA = 1
            WHERE      AUTORIZACION_ID = P_AUTORIZACION_ID 
                   AND CANCELADA = 0;
            -- <TEST>
            ADD_LOG ('CREDITOS ADICIONALES',
                     '111',
                     'TEST',
                     V_CODIGO_ESTUDIANTE,
                     'CANCELACION',
                     'AUTORIZACION_ID: ' || P_AUTORIZACION_ID);
            JSON.PUT (V_RESPONSE, 'statusId', '1');
            JSON.PUT (V_RESPONSE, 'status', 'OK');
        ELSE
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', 'Los datos suministrados no son validos.');
        END IF;
        JSON.HTP(V_RESPONSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_RESPONSE := JSON (); 
            JSON.PUT (V_RESPONSE, 'statusId', '0');
            JSON.PUT (V_RESPONSE, 'status', 'Error');
            JSON.PUT (V_RESPONSE, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_RESPONSE);
    END CANCELAR_CREDITOS;  
    
    /*
        OBTIENE LA CANTIDAD DE CREDITOS ADICIONALES DISPONIBLES PARA UN ESTUDIANTE.
            EL NUMERO DE CREDITOS ADICIONALES DISPONIBLES SE DA POR LA FORMULA:
            CAD = (CT / 2) - CAI.
            DONDE:
            CAD: CREDITOS ADICIONALES INSCRITOS.
            CT: CREDITOS TRIMESTRE.
            CAI: CREDITOS ADICIONALES INSCRITOS.        
        @param P_CODIGO_ESTUDIANTE VARCHAR2
        @return 
        */
    FUNCTION GET_CREDITOS_ADICIONALES_DISP (
		P_CODIGO_ESTUDIANTE VARCHAR2
    ) RETURN NUMBER
    IS
        V_CREDITOS_TRIMESTRE_PROGRAMA NUMBER;
        V_CRED_ADIC_PAGADOS           NUMBER;
        V_ANIO                        VARCHAR2 (4);
        V_CICLO                       VARCHAR2 (2);
        V_ESQUEMA                     VARCHAR2 (32);
    BEGIN    
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
        -- CANTIDAD DE CREDITOS ADICIONALES PAGADOS.
        SELECT     NVL(SUM(NUMERO_CREDITOS_ADICIONALES), 0)
        INTO       V_CRED_ADIC_PAGADOS
        FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA
        INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA.CODIGO_GUIA
        WHERE          CEA.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE
                   -- CREDITOS EN ESTADO PAGADO.
                   AND GDP.INDICADOR_PAGO = 'P' 
                   -- AUTORIZACIONES PARA EL CICLO ACTUAL.
                   AND CEA.ANIO_SOLICITUD    = V_ANIO
                   AND CEA.CICLO_SOLICITUD   = V_CICLO;
        -- CALCULANDO SEGUN LA FORMULA.
        RETURN 4 - V_CRED_ADIC_PAGADOS;
    END GET_CREDITOS_ADICIONALES_DISP;  
    
    /*
        AGREGAR REGISTRO EN EL LOG.
        @param IP VARCHAR2
        @param USUARIO VARCHAR2
        @param USUARIO_AFECTADO VARCHAR2
        @param ACCION VARCHAR2
        @param DESCRIPCION VARCHAR2
        */
    PROCEDURE ADD_LOG (
        P_PROCESO VARCHAR2,
        P_IP VARCHAR2,
        P_USUARIO VARCHAR2,
        P_USUARIO_AFECTADO VARCHAR2,
        P_ACCION VARCHAR2,
        P_DESCRIPCION VARCHAR2
    ) IS
        V_ANIO      VARCHAR2 (4);
        V_CICLO     VARCHAR2 (2);
        V_ESQUEMA   VARCHAR2 (32);
    BEGIN
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
        INSERT INTO CTI_LOG_POSGRADO (PROCESO,
                                      FECHA,
                                      IP,
                                      USUARIO_ACCION,
                                      USUARIO_AFECTADO,
                                      ACCION,
                                      DESCRIPCION,
                                      ANIO,
                                      CICLO)
        VALUES (P_PROCESO,
                SYSDATE,
                P_IP,
                P_USUARIO,
                P_USUARIO_AFECTADO,
                P_ACCION,
                P_DESCRIPCION,
                V_ANIO,
                V_CICLO);
    END ADD_LOG;
END PKG_CREDITOS_ADICIONALES;
/