create or replace PACKAGE BODY PKG_EXPOSED_SERVICES_FACADE AS

    /*FIXME: Ajustar consultas para que soporten los cierres de horario.*/

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE ESTUDIANTE (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_BODY               JSON;
        V_NUMERO_DOCUMENTO   NUMBER (10) DEFAULT 0;
    BEGIN
        V_BODY := JSON ();
        SELECT COUNT (SFA.DOCUMENTO)
        INTO V_NUMERO_DOCUMENTO
        FROM SIEG_FECHA_ACTUALIZACION_TEMP   SFA
        INNER JOIN DATOS_PERSONALES                DP ON DP.NUMERO_DOCUMENTO = SFA.DOCUMENTO
        WHERE ROUND ((SYSDATE - SFA.FECHA) / 365, 1) > 1
              AND DP.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        IF (V_NUMERO_DOCUMENTO <> 0) THEN
            JSON.PUT (V_BODY, 'status', 'Debe actualizar sus datos personales');
            JSON.HTP (V_BODY);
        ELSE
            PKG_UTILS.GETESTUDIANTE (P_CODIGO_ESTUDIANTE);
        END IF;

    END ESTUDIANTE;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE ESTUDIANTE_CODIGO_CONTRARIO (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_ANIO     VARCHAR2 (4);
        V_CICLO    VARCHAR2 (2);
        V_CODIGO   VARCHAR2 (16);
    BEGIN
        PKG_UTILS.GETANIOCICLO (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO);
        SELECT B_PREMATRICULA_SPRING.F_GET_CODIGO_CONTRARIO (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO)
        INTO V_CODIGO
        FROM DUAL;

        IF (NVL (V_CODIGO, 'NULL') != 'NULL') THEN
            PKG_UTILS.GETESTUDIANTE (V_CODIGO);
        END IF;

    END ESTUDIANTE_CODIGO_CONTRARIO;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_PREMATRICULA_ESTUDIANTE (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS

        V_BODY     JSON;
        V_ANIO     VARCHAR2 (4);
        V_CICLO    VARCHAR2 (2);
        V_CODIGO   VARCHAR2 (16);
        V_NUMBER   NUMBER;
    BEGIN
        /* AGREGANDO HEADERS.*/
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        PKG_UTILS.GETANIOCICLO (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO);
        PKG_PREMATRICULA_AUX.PREMATRICULA (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO, 0, 1);
    END GET_PREMATRICULA_ESTUDIANTE;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_GENERALIDADES (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS

        TYPE CUR_TYP IS REF CURSOR;
        C                       CUR_TYP;
        V_ANIO                  VARCHAR2 (4);
        V_CICLO                 VARCHAR2 (2);
        V_CODIGO_ANTERIOR       VARCHAR2 (5 BYTE) DEFAULT 'NULL';
        V_CODIGO                VARCHAR2 (5 BYTE);
        V_CREDITOS              NUMBER (2, 0);
        V_CURSADA               NUMBER (2, 0);
        V_APROBADA              NUMBER (2, 0);
        V_BODY                  JSON;
        V_PROMEDIO              NUMBER DEFAULT 0;
        V_TOTAL_MATERIAS_PLAN   NUMBER DEFAULT 0;
        V_MATERIAS_CURSANDO     NUMBER DEFAULT 0;
        V_MATERIAS_CURSADAS     NUMBER DEFAULT 0;
        V_MATERIAS_APROBADAS    NUMBER DEFAULT 0;
        V_CREDITOS_PLAN         NUMBER DEFAULT 0;
        V_CREDITOS_CURSANDO     NUMBER DEFAULT 0;
        V_CREDITOS_CURSADOS     NUMBER DEFAULT 0;
        V_CREDITOS_PROBADOS     NUMBER DEFAULT 0;
    BEGIN
        /* AGREGANDO HEADERS. */
        V_BODY := JSON ();
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        FOR V_INDICADORES IN (SELECT TOTAL_CREDITOS,
                                     CREDITOS_APROBADOS,
                                     TOTAL_CREDITOS - CREDITOS_APROBADOS CREDITOS_FALTANTES,
                                     CASE
                                         WHEN TOTAL_CREDITOS != 0 THEN
                                             ROUND (100 / TOTAL_CREDITOS * CREDITOS_APROBADOS, 1)
                                         ELSE
                                             0
                                     END PORCENTAJE_CREDITOS_APROBADOS,
                                     TOTAL_MATERIAS,
                                     MATERIAS_APROBADAS,
                                     TOTAL_MATERIAS - MATERIAS_APROBADAS MATERIAS_FALTANTES,
                                     CASE
                                         WHEN TOTAL_MATERIAS != 0 THEN
                                             ROUND (100 / TOTAL_MATERIAS * MATERIAS_APROBADAS, 1)
                                         ELSE
                                             0
                                     END PORCENTAJE_MATERIAS_APROBADOS,
                                     CREDITOS_CURSADOS,
                                     MATERIAS_CURSADAS,
                                     MATERIAS_CURSANDO,
                                     CREDITOS_CURSANDO
                              FROM (SELECT NVL (SUM (CREDITOS), '0') TOTAL_CREDITOS,
                                           COUNT (CODIGO_MATERIA) TOTAL_MATERIAS
                                    FROM (SELECT DISTINCT CODIGO_MATERIA,
                                                          CREDITOS
                                          FROM TABLE (ESTADO_MATERIAS (P_CODIGO_ESTUDIANTE))
                                         ) MATERIAS_UNICAS
                                   ),
                                   (SELECT NVL (SUM (CREDITOS), '0') CREDITOS_APROBADOS,
                                           COUNT (CODIGO_MATERIA) MATERIAS_APROBADAS
                                    FROM TABLE (ESTADO_MATERIAS (P_CODIGO_ESTUDIANTE))
                                    WHERE APROBADA = '1'
                                   ) MATERIAS_APROBADAS,
                                   (SELECT NVL (SUM (CREDITOS), '0') CREDITOS_CURSADOS,
                                           COUNT (CODIGO_MATERIA) MATERIAS_CURSADAS
                                    FROM TABLE (ESTADO_MATERIAS (P_CODIGO_ESTUDIANTE))
                                    WHERE NOTA IS NOT NULL
                                   ) MATERIAS_CURSADAS,
                                   (SELECT COUNT (CODIGO_MATERIA) MATERIAS_CURSANDO,
                                           NVL (SUM (CREDITOS), '0') CREDITOS_CURSANDO
                                    FROM TABLE (ESTADO_MATERIAS (P_CODIGO_ESTUDIANTE))
                                    WHERE CURSANDO = '1'
                                   ) MATERIAS_CURSANDO
                             ) LOOP
            JSON.PUT (V_BODY, 'promedio', PKG_UTILS.PROMEDIOPONDERADOTOTAL (P_CODIGO_ESTUDIANTE));
            JSON.PUT (V_BODY, 'totalMateriasPlan', V_INDICADORES.TOTAL_MATERIAS);
            JSON.PUT (V_BODY, 'materiasCursando', V_INDICADORES.MATERIAS_CURSANDO);
            JSON.PUT (V_BODY, 'materiasCursadas', V_INDICADORES.MATERIAS_CURSADAS);
            JSON.PUT (V_BODY, 'materiasAprobadas', V_INDICADORES.MATERIAS_APROBADAS);
            JSON.PUT (V_BODY, 'materiasReprobadas', V_INDICADORES.MATERIAS_CURSADAS - V_INDICADORES.MATERIAS_APROBADAS);
            JSON.PUT (V_BODY, 'materiasFaltantes', V_INDICADORES.TOTAL_MATERIAS - V_INDICADORES.MATERIAS_APROBADAS);
            JSON.PUT (V_BODY, 'porcentajeMateriasAprobadas', V_INDICADORES.PORCENTAJE_MATERIAS_APROBADOS);
            JSON.PUT (V_BODY, 'creditosPlan', V_INDICADORES.TOTAL_CREDITOS);
            JSON.PUT (V_BODY, 'creditosCursando', V_INDICADORES.CREDITOS_CURSANDO);
            JSON.PUT (V_BODY, 'creditosCursados', V_INDICADORES.CREDITOS_CURSADOS);
            JSON.PUT (V_BODY, 'creditosAprobados', V_INDICADORES.CREDITOS_APROBADOS);
            JSON.PUT (V_BODY, 'creditosReprobados', V_INDICADORES.CREDITOS_CURSADOS - V_INDICADORES.CREDITOS_APROBADOS);
            JSON.PUT (V_BODY, 'creditosFaltantes', V_INDICADORES.TOTAL_CREDITOS - V_INDICADORES.CREDITOS_APROBADOS);
            JSON.PUT (V_BODY, 'porcentajeCreditosAprobados', V_INDICADORES.PORCENTAJE_CREDITOS_APROBADOS);
        END LOOP;

        JSON.HTP (V_BODY);
    EXCEPTION
        WHEN OTHERS THEN
            PKG_JSON_RESPONSE.PRINT_FAILURE_OR_EXCEPTION;
    END GET_GENERALIDADES;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_HORARIO_DOCENTE (
        P_DOCUMENTO VARCHAR2
    ) IS

        TYPE CUR_TYP IS REF CURSOR;
        C                 CUR_TYP;
        V_BODY            JSON;
        V_JSON_MATERIAS   JSON_LIST;
        V_JSON_MATERIA    JSON;
        V_JSON_DIAS       JSON_LIST;
        V_JSON_DIA        JSON;
        V_JSON_HORAS      JSON_LIST;
        V_JSON_HORA       JSON;
        V_JSON_GRUPO      JSON;
        V_RESPUESTA       JSON := JSON ();
    BEGIN
        /* AGREGANDO HEADERS.*/
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        V_BODY            := JSON ();
        V_JSON_MATERIAS   := JSON_LIST ();
        FOR CURSOR_MATERIAS IN (SELECT DISTINCT CODIGO_FACULTAD,
                                                JORNADA_FACULTAD,
                                                CODIGO_MATERIA,
                                                NOMBRE_MATERIA,
                                                GRUPO
                                FROM MATERIAS_DOCENTE_BLOQUES
                                WHERE NUMERO_DOCUMENTO = P_DOCUMENTO
                                ORDER BY CODIGO_FACULTAD,
                                         JORNADA_FACULTAD,
                                         CODIGO_MATERIA,
                                         GRUPO) LOOP
            V_JSON_MATERIA   := JSON ();
            V_JSON_DIAS      := JSON_LIST ();
            FOR CURSOR_DIA IN (SELECT DISTINCT ID_DIA,
                                               DIA
                               FROM MATERIAS_DOCENTE_BLOQUES
                               WHERE CODIGO_MATERIA = CURSOR_MATERIAS.CODIGO_MATERIA
                                     AND CODIGO_FACULTAD   = CURSOR_MATERIAS.CODIGO_FACULTAD
                                     AND JORNADA_FACULTAD  = CURSOR_MATERIAS.JORNADA_FACULTAD
                                     AND GRUPO             = CURSOR_MATERIAS.GRUPO
                                     AND NUMERO_DOCUMENTO  = P_DOCUMENTO
                               ORDER BY ID_DIA) LOOP
                V_JSON_DIA     := JSON ();
                V_JSON_HORAS   := JSON_LIST ();
                JSON.PUT (V_JSON_DIA, 'idDia', CURSOR_DIA.ID_DIA);
                JSON.PUT (V_JSON_DIA, 'dia', CURSOR_DIA.DIA);
                FOR CURSOR_HORA IN (SELECT HORA,
                                           AREA,
                                           SALON
                                    FROM MATERIAS_DOCENTE_BLOQUES
                                    WHERE CODIGO_MATERIA = CURSOR_MATERIAS.CODIGO_MATERIA
                                          AND CODIGO_FACULTAD   = CURSOR_MATERIAS.CODIGO_FACULTAD
                                          AND JORNADA_FACULTAD  = CURSOR_MATERIAS.JORNADA_FACULTAD
                                          AND GRUPO             = CURSOR_MATERIAS.GRUPO
                                          AND NUMERO_DOCUMENTO  = P_DOCUMENTO
                                          AND ID_DIA            = CURSOR_DIA.ID_DIA
                                    ORDER BY HORA) LOOP
                    V_JSON_HORA := JSON ();
                    JSON.PUT (V_JSON_HORA, 'inicio', SUBSTR (CURSOR_HORA.HORA, 1, 2) ||
                    ':00');

                    JSON.PUT (V_JSON_HORA, 'fin', SUBSTR (CURSOR_HORA.HORA, 3, 2) ||
                    ':00');

                    JSON.PUT (V_JSON_HORA, 'tipo', CURSOR_HORA.AREA);
                    JSON.PUT (V_JSON_HORA, 'salon', CURSOR_HORA.SALON);
                    JSON_LIST.APPEND (V_JSON_HORAS, V_JSON_HORA.TO_JSON_VALUE);
                END LOOP;

                JSON.PUT (V_JSON_DIA, 'horas', V_JSON_HORAS);
                JSON_LIST.APPEND (V_JSON_DIAS, V_JSON_DIA.TO_JSON_VALUE);
            END LOOP;

            JSON.PUT (V_JSON_MATERIA, 'codigoMateria', CURSOR_MATERIAS.CODIGO_MATERIA);
            JSON.PUT (V_JSON_MATERIA, 'codigoMateria', CURSOR_MATERIAS.CODIGO_MATERIA);
            JSON.PUT (V_JSON_MATERIA, 'nombreMateria', CURSOR_MATERIAS.NOMBRE_MATERIA);
            JSON.PUT (V_JSON_MATERIA, 'codigoFacultad', CURSOR_MATERIAS.CODIGO_FACULTAD);
            JSON.PUT (V_JSON_MATERIA, 'grupo', CURSOR_MATERIAS.GRUPO);
            JSON.PUT (V_JSON_MATERIA, 'dias', V_JSON_DIAS);
            JSON_LIST.APPEND (V_JSON_MATERIAS, V_JSON_MATERIA.TO_JSON_VALUE);
        END LOOP;

        JSON.PUT (V_BODY, 'materias', V_JSON_MATERIAS);
        JSON.HTP (V_BODY);
    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_RESPUESTA, 'status', 'fail');
            JSON.PUT (V_RESPUESTA, 'mensaje', SQLERRM);
            JSON.HTP (V_RESPUESTA, FALSE);
    END GET_HORARIO_DOCENTE;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_PENDIENTES (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS

        V_FINANCIERA    VARCHAR2 (4);
        V_BIBLIOTECA    VARCHAR2 (2);
        V_DOCUMENTOS    VARCHAR2 (16);
        V_PAZ_Y_SALVO   VARCHAR2 (16);
        J_RESPUESTA     JSON := JSON ();
    BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        SELECT COUNT (1)
        INTO V_FINANCIERA
        FROM ADMISIONES.A_DEUDAS_FINANCIERA DF
        WHERE DF.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        SELECT COUNT (1)
        INTO V_BIBLIOTECA
        FROM ADMISIONES.A_DEUDAS_BIBLIOTECA DB
        WHERE DB.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        SELECT COUNT (1)
        INTO V_DOCUMENTOS
        FROM DOC_ESTUDIANTE DE
        WHERE DE.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE
              AND DE.ESTADO = 'NO'
              AND DE.CODIGO_DOCUMENTO IN (
            '1',
            '2'
        );

        SELECT COUNT (1)
        INTO V_PAZ_Y_SALVO
        FROM ADMISIONES.DATOS_PERSONALES                DP
        INNER JOIN ADMISIONES.SIEG_FECHA_ACTUALIZACION_TEMP   SFA ON DP.NUMERO_DOCUMENTO = SFA.DOCUMENTO
        WHERE DP.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        JSON.PUT (J_RESPUESTA, 'financiera', V_FINANCIERA);
        JSON.PUT (J_RESPUESTA, 'biblioteca', V_BIBLIOTECA);
        JSON.PUT (J_RESPUESTA, 'documentos', V_DOCUMENTOS);
        JSON.PUT (J_RESPUESTA, 'pazysalvo', V_PAZ_Y_SALVO);
        JSON.HTP (J_RESPUESTA);
    END GET_PENDIENTES;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_ANIO_CICLO (
        P_CODIGO_FACULTAD VARCHAR2
    ) IS

        V_TIPO_PRG    NUMBER DEFAULT 1;
        V_ANIO        VARCHAR2 (4) DEFAULT NULL;
        V_CICLO       VARCHAR2 (2) DEFAULT NULL;
        V_ESQUEMA     VARCHAR2 (256) DEFAULT NULL;
        J_RESPUESTA   JSON := JSON ();
    BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        IF P_CODIGO_FACULTAD = '46' THEN
            V_TIPO_PRG := 4;
        ELSIF P_CODIGO_FACULTAD < '71' THEN
            V_TIPO_PRG := 1;
        ELSIF P_CODIGO_FACULTAD >= '71' THEN
            V_TIPO_PRG := 2;
        END IF;

        PKG_UTILS.GETANIOCICLOESQUEMA (V_TIPO_PRG, V_ANIO, V_CICLO, V_ESQUEMA);
        JSON.PUT (J_RESPUESTA, 'anio', V_ANIO);
        JSON.PUT (J_RESPUESTA, 'ciclo', V_CICLO);
        JSON.PUT (J_RESPUESTA, 'esquema', V_ESQUEMA);
        JSON.HTP (J_RESPUESTA);
    END GET_ANIO_CICLO;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE GET_PLANES (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_BODY     JSON;
        V_PLANES   JSON_LIST;
        V_PLAN     JSON;
    BEGIN
        V_BODY     := JSON ();
        V_PLANES   := JSON_LIST ();
        FOR PLAN IN (SELECT P.CODIGO_FACULTAD,
                            P.JORNADA_FACULTAD,
                            P.PLAN_ESTUDIO,
                            P.DESCRIPCION,
                            CASE
                                WHEN E.PLAN_ESTUDIO = P.PLAN_ESTUDIO THEN
                                    1
                                ELSE
                                    0
                            END ACTIVO
                     FROM POSTGRADO.A_PLANES_DE_ESTUDIO   P
                     INNER JOIN POSTGRADO.B_ESTUDIANTES         E ON E.CODIGO_FACULTAD = P.CODIGO_FACULTAD
                                                             AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
                     WHERE CODIGO = P_CODIGO_ESTUDIANTE
                    ) LOOP
            V_PLAN := JSON ();
            JSON.PUT (V_PLAN, 'codigoFacultad', PLAN.CODIGO_FACULTAD);
            JSON.PUT (V_PLAN, 'jornadaFacultad', PLAN.JORNADA_FACULTAD);
            JSON.PUT (V_PLAN, 'planEstudio', PLAN.PLAN_ESTUDIO);
            JSON.PUT (V_PLAN, 'descripcion', PLAN.DESCRIPCION);
            JSON.PUT (V_PLAN, 'activo', PLAN.ACTIVO);
            JSON_LIST.APPEND (V_PLANES, V_PLAN.TO_JSON_VALUE);
        END LOOP;

        IF (V_PLANES.COUNT > 0) THEN
            JSON.PUT (V_BODY, 'status', 'ok');
            JSON.PUT (V_BODY, 'planes', V_PLANES);
            JSON.HTP (V_BODY);
        ELSE
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', 'No se encontraron planes asociados el codigo.');
            JSON.HTP (V_BODY, FALSE);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', SQLERRM);
            JSON.HTP (V_BODY, FALSE);
    END GET_PLANES;

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------------*/

    PROCEDURE ACTUALIZAR_PLAN_POSTGRADO (
        P_CODIGO_ESTUDIANTE   VARCHAR2,
        P_PLAN_ESTUDIO        VARCHAR2
    ) IS

        V_BODY                   JSON;
        V_UPDATED                NUMBER DEFAULT 0;
        C_USUARIO                A_USUARIOS.USUARIO%TYPE;
        C_CLAVE                  A_USUARIOS.CLAVE%TYPE;
        C_DOCUMENTO              A_USUARIOS.NUMERO_DOCUMENTO%TYPE;
        C_CODIGO                 A_USUARIOS.CODIGO%TYPE;
        C_NOMBRE                 A_USUARIOS.NOMBRE_USUARIO%TYPE;
        C_ID_PERFIL              CTI_PERFILES.ID_PERFIL%TYPE DEFAULT 0;
        V_ESTUDIANTE_ES_NUEVO    NUMBER DEFAULT 0;
        V_NUMERO_MATERIAS_INSC   NUMBER DEFAULT 0;
    BEGIN
        V_BODY := JSON ();
        PKG_UTILS.P_LEER_COOKIE (C_USUARIO, C_CLAVE, C_DOCUMENTO, C_CODIGO, C_NOMBRE);
        SELECT CTI_PERFILES.ID_PERFIL
        INTO C_ID_PERFIL
        FROM CTI_PERFILES
        WHERE REGEXP_LIKE (C_CODIGO,
                           REGEXP);

        IF C_ID_PERFIL NOT IN (
            '1',
            '2',
            '3',
            '4'
        ) THEN
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', 'No autorizado.');
            JSON.HTP (V_BODY);
            RETURN;
        END IF;

        SELECT COUNT (*)
        INTO V_ESTUDIANTE_ES_NUEVO
        FROM POSTGRADO.B_ESTUDIANTES
        WHERE CICLO_DE_INGRESO = ANIO || TO_NUMBER (CICLO)
              AND CODIGO = P_CODIGO_ESTUDIANTE;

        IF (V_ESTUDIANTE_ES_NUEVO = '0') THEN
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', 'Solo se puede cambiar el plan de estudio a estudiantes nuevos.');
            JSON.HTP (V_BODY);
            RETURN;
        END IF;

        SELECT COUNT (*)
        INTO V_NUMERO_MATERIAS_INSC
        FROM POSTGRADO.B_PREMATRICULA
        WHERE CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        IF (V_NUMERO_MATERIAS_INSC > '0') THEN
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', 'El estudiante ya tiene materias inscritas, por favor desinscribalas e intente nuevamente.');
            JSON.HTP (V_BODY);
            RETURN;
        END IF;

        FOR PLAN IN (SELECT P.CODIGO_FACULTAD,
                            P.JORNADA_FACULTAD,
                            P.PLAN_ESTUDIO,
                            P.DESCRIPCION,
                            CASE
                                WHEN E.PLAN_ESTUDIO = P.PLAN_ESTUDIO THEN
                                    1
                                ELSE
                                    0
                            END ACTIVO
                    FROM POSTGRADO.A_PLANES_DE_ESTUDIO   P
                    INNER JOIN POSTGRADO.B_ESTUDIANTES         E ON E.CODIGO_FACULTAD = P.CODIGO_FACULTAD
                                                            AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
                    WHERE CODIGO = P_CODIGO_ESTUDIANTE
                          AND P.PLAN_ESTUDIO = P_PLAN_ESTUDIO
                    ) LOOP
            UPDATE POSTGRADO.B_ESTUDIANTES
            SET
                PLAN_ESTUDIO = P_PLAN_ESTUDIO
            WHERE CODIGO = P_CODIGO_ESTUDIANTE;

            V_UPDATED := 1;
        END LOOP;

        IF (V_UPDATED = 1) THEN
            /*se eliminan las bolsas de credito lectivo que tenga el estudiante maymonroy 14-07-2020*/
            POSTGRADO.PKG_ESTUDIANTE.del_est_bolsa_electiva(P_CODIGO_ESTUDIANTE);
            /*se agregan las bolsas de credito lectivo que tenga el estudiante segun el cambio de plan maymonroy 14-07-2020*/
            POSTGRADO.PKG_ESTUDIANTE.add_est_bolsa_electiva(P_CODIGO_ESTUDIANTE);
            JSON.PUT (V_BODY, 'status', 'ok');
            JSON.PUT (V_BODY, 'mensaje', 'Estudiante actualizado');
            JSON.HTP (V_BODY);
        ELSE
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', 'No se pudo actualizar el plan de estudio.');
            JSON.HTP (V_BODY, FALSE);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_BODY, 'status', 'fail');
            JSON.PUT (V_BODY, 'mensaje', SQLERRM);
            JSON.HTP (V_BODY);
    END ACTUALIZAR_PLAN_POSTGRADO;

END PKG_EXPOSED_SERVICES_FACADE;