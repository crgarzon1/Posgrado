create or replace PACKAGE BODY PKG_EXPOSED_SERVICES_FACADE AS

    --FIXME: Ajustar consultas para que soporten los cierres de horario.

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE ESTUDIANTE (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_BODY               JSON;
        V_NUMERO_DOCUMENTO   NUMBER (10) DEFAULT 0;
    BEGIN
        V_BODY := JSON ();
        SELECT COUNT (SFA.DOCUMENTO)
          INTO V_NUMERO_DOCUMENTO
          FROM SIEG_FECHA_ACTUALIZACION_TEMP SFA
         INNER JOIN DATOS_PERSONALES DP ON DP.NUMERO_DOCUMENTO = SFA.DOCUMENTO
         WHERE ROUND ((SYSDATE - SFA.FECHA) / 365, 1) > 1
           AND DP.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        IF (V_NUMERO_DOCUMENTO <> 0) THEN
            JSON.PUT (V_BODY, 'status', 'Debe actualizar sus datos personales');
            JSON.HTP (V_BODY);
        else
            PKG_UTILS.GETESTUDIANTE (P_CODIGO_ESTUDIANTE);
        END IF;

    END ESTUDIANTE;

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE GET_PLANES (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_BODY      JSON;
        V_PLANES    JSON_LIST;
        V_PLAN      JSON;
    BEGIN        
        V_BODY := JSON();
        V_PLANES := JSON_LIST ();
        FOR PLAN IN (SELECT     P.CODIGO_FACULTAD,
                                P.JORNADA_FACULTAD,
                                P.PLAN_ESTUDIO,
                                P.DESCRIPCION,
                                CASE 
                                     WHEN E.PLAN_ESTUDIO = P.PLAN_ESTUDIO THEN 1
                                     ELSE 0
                                END ACTIVO 
                     FROM       POSTGRADO.A_PLANES_DE_ESTUDIO P
                     INNER JOIN POSTGRADO. B_ESTUDIANTES E ON     E.CODIGO_FACULTAD = P.CODIGO_FACULTAD
                                                              AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD 
                     WHERE      CODIGO = P_CODIGO_ESTUDIANTE) LOOP
            V_PLAN := JSON();       
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
            JSON.PUT(V_BODY, 'status', 'fail');
            JSON.PUT(V_BODY, 'mensaje', 'No se encontraron planes asociados el codigo.');
            JSON.HTP(V_BODY, FALSE);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        JSON.PUT(V_BODY, 'status', 'fail');
        JSON.PUT(V_BODY, 'mensaje', SQLERRM);
        JSON.HTP(V_BODY, FALSE);
    END GET_PLANES;

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE ACTUALIZAR_PLAN_POSTGRADO (
        P_CODIGO_ESTUDIANTE VARCHAR2,
        P_PLAN_ESTUDIO VARCHAR2
    ) IS
        V_BODY    JSON;
        V_UPDATED NUMBER DEFAULT 0;
        C_USUARIO   A_USUARIOS.USUARIO%TYPE;
        C_CLAVE     A_USUARIOS.CLAVE%TYPE;
        C_DOCUMENTO A_USUARIOS.NUMERO_DOCUMENTO%TYPE;
        C_CODIGO    A_USUARIOS.CODIGO%TYPE;
        C_NOMBRE    A_USUARIOS.NOMBRE_USUARIO%TYPE;
        C_ID_PERFIL CTI_PERFILES.ID_PERFIL%TYPE DEFAULT 0;
    BEGIN
        V_BODY := JSON();
        
        PKG_UTILS.P_LEER_COOKIE(C_USUARIO, C_CLAVE, C_DOCUMENTO, C_CODIGO, C_NOMBRE);
        SELECT  CTI_PERFILES.ID_PERFIL
        INTO    C_ID_PERFIL
        FROM    CTI_PERFILES
        WHERE   REGEXP_LIKE (C_CODIGO, REGEXP);
        
        IF C_ID_PERFIL NOT IN ('1', '2', '3', '4') THEN
            JSON.PUT(V_BODY, 'status', 'fail');
            JSON.PUT(V_BODY, 'mensaje', 'No autorizado.');
            JSON.HTP(V_BODY, FALSE);
            RETURN;
        END IF;
        
        FOR PLAN IN (SELECT     P.CODIGO_FACULTAD,
                                P.JORNADA_FACULTAD,
                                P.PLAN_ESTUDIO,
                                P.DESCRIPCION,
                                CASE 
                                     WHEN E.PLAN_ESTUDIO = P.PLAN_ESTUDIO THEN 1
                                     ELSE 0
                                END ACTIVO 
                     FROM       POSTGRADO.A_PLANES_DE_ESTUDIO P
                     INNER JOIN POSTGRADO. B_ESTUDIANTES E ON     E.CODIGO_FACULTAD = P.CODIGO_FACULTAD
                                                              AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD 
                     WHERE          CODIGO = P_CODIGO_ESTUDIANTE
                                AND P.PLAN_ESTUDIO = P_PLAN_ESTUDIO) LOOP
            UPDATE POSTGRADO.B_ESTUDIANTES
            SET    PLAN_ESTUDIO = P_PLAN_ESTUDIO
            WHERE  CODIGO = P_CODIGO_ESTUDIANTE;
            V_UPDATED := 1;
        END LOOP;
        IF (V_UPDATED = 1) THEN
            JSON.PUT (V_BODY, 'status', 'ok');
            JSON.PUT (V_BODY, 'planes', 'Estudiante actualizado');
            JSON.HTP (V_BODY);
        ELSE
            json.put(V_BODY, 'status', 'fail');
            json.put(V_BODY, 'mensaje', 'No se pudo actualizar el plan de estudio.');
            json.htp(V_BODY, false);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        JSON.PUT(V_BODY, 'status', 'fail');
        JSON.PUT(V_BODY, 'mensaje', SQLERRM);
        JSON.HTP(V_BODY, FALSE);
    END ACTUALIZAR_PLAN_POSTGRADO;
    
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE GET_PREMATRICULA_ESTUDIANTE (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_ANIO     VARCHAR2 (4);
        V_CICLO    VARCHAR2 (2);
        V_CODIGO   VARCHAR2 (16);
    BEGIN
        -- AGREGANDO HEADERS.
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        PKG_UTILS.GETANIOCICLO (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO);
        PKG_PREMATRICULA_AUX.PREMATRICULA (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO, 0, 1);
    END GET_PREMATRICULA_ESTUDIANTE;

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

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
        -- AGREGANDO HEADERS.
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        V_BODY := JSON ();
        PKG_UTILS.GETANIOCICLO (P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO);
        OPEN C FOR SELECT CODIGO,
                          CREDITOS,
                          APROBADA,
                          CURSADA
                     FROM (SELECT AM.CODIGO,
                                  AM.CREDITOS,
                                  CASE
                                      WHEN N.VALOR IS NOT NULL
                                         AND ((N.INDICADOR != 'V'
                                         AND N.VALOR >= 3)
                                          OR (N.INDICADOR = 'V'
                                         AND N.VALOR >= 3.5)) THEN
                                          1
                                      ELSE
                                          0
                                  END APROBADA,
                                  CASE
                                      WHEN N.VALOR IS NOT NULL THEN
                                          1
                                      ELSE
                                          0
                                  END CURSADA
                           FROM ADMISIONES.B_ESTUDIANTES B
                          INNER JOIN ADMISIONES.A_FACULTADES_UNICA FU ON FU.CODIGO_FACULTAD = B.CODIGO_FACULTAD
                          INNER JOIN ADMISIONES.A_FACULTADES F ON B.CODIGO_FACULTAD = F.CODIGO
                            AND B.JORNADA_FACULTAD = F.JORNADA
                          INNER JOIN ADMISIONES.A_MATERIAS AM ON AM.CODIGO_FACULTAD = F.CODIGO
                            AND AM.JORNADA_FACULTAD = F.JORNADA
                            AND AM.PLAN_ESTUDIO = B.PLAN_ESTUDIO
                           LEFT JOIN ADMISIONES.A_NOTAS N ON N.CODIGO_MATERIA = AM.CODIGO
                            AND N.CODIGO_ESTUDIANTE = B.CODIGO
                          WHERE B.CODIGO = P_CODIGO_ESTUDIANTE
                            AND AM.SEMESTRE NOT IN (
                             '00'
                         )
                         UNION ALL
                         SELECT AM.CODIGO,
                                AM.CREDITOS,
                                CASE
                                    WHEN N.VALOR IS NOT NULL
                                       AND ((N.INDICADOR != 'V'
                                       AND N.VALOR >= 3)
                                        OR (N.INDICADOR = 'V'
                                       AND N.VALOR >= 3.5)) THEN
                                        1
                                    ELSE
                                        0
                                END APROBADA,
                                CASE
                                    WHEN N.VALOR IS NOT NULL THEN
                                        1
                                    ELSE
                                        0
                                END CURSADA
                           FROM POSTGRADO.B_ESTUDIANTES B
                          INNER JOIN ADMISIONES.A_FACULTADES_UNICA FU ON FU.CODIGO_FACULTAD = B.CODIGO_FACULTAD
                          INNER JOIN ADMISIONES.A_FACULTADES F ON B.CODIGO_FACULTAD = F.CODIGO
                            AND B.JORNADA_FACULTAD = F.JORNADA
                          INNER JOIN POSTGRADO.A_MATERIAS AM ON AM.CODIGO_FACULTAD = F.CODIGO
                            AND AM.JORNADA_FACULTAD = F.JORNADA
                            AND AM.PLAN_ESTUDIO = B.PLAN_ESTUDIO
                           LEFT JOIN POSTGRADO.A_NOTAS N ON N.CODIGO_MATERIA = AM.CODIGO
                            AND N.CODIGO_ESTUDIANTE = B.CODIGO
                          WHERE B.CODIGO = P_CODIGO_ESTUDIANTE
                            AND AM.SEMESTRE NOT IN (
                             '00'
                         )
                         UNION ALL
                         SELECT AM.CODIGO,
                                AM.CREDITOS,
                                CASE
                                    WHEN N.VALOR IS NOT NULL
                                       AND ((N.INDICADOR != 'V'
                                       AND N.VALOR >= 3)
                                        OR (N.INDICADOR = 'V'
                                       AND N.VALOR >= 3.5)) THEN
                                        1
                                    ELSE
                                        0
                                END APROBADA,
                                CASE
                                    WHEN N.VALOR IS NOT NULL THEN
                                        1
                                    ELSE
                                        0
                                END CURSADA
                           FROM YOPAL.B_ESTUDIANTES B
                          INNER JOIN ADMISIONES.A_FACULTADES_UNICA FU ON FU.CODIGO_FACULTAD = B.CODIGO_FACULTAD
                          INNER JOIN ADMISIONES.A_FACULTADES F ON B.CODIGO_FACULTAD = F.CODIGO
                            AND B.JORNADA_FACULTAD = F.JORNADA
                          INNER JOIN YOPAL.A_MATERIAS AM ON AM.CODIGO_FACULTAD = F.CODIGO
                            AND AM.JORNADA_FACULTAD = F.JORNADA
                            AND AM.PLAN_ESTUDIO = B.PLAN_ESTUDIO
                           LEFT JOIN YOPAL.A_NOTAS N ON N.CODIGO_MATERIA = AM.CODIGO
                            AND N.CODIGO_ESTUDIANTE = B.CODIGO
                          WHERE B.CODIGO = P_CODIGO_ESTUDIANTE
                            AND AM.SEMESTRE NOT IN (
                             '00'
                         )
                   ) A
                    ORDER BY CODIGO,
                             APROBADA DESC;

        LOOP
            FETCH C INTO
                V_CODIGO,
                V_CREDITOS,
                V_APROBADA,
                V_CURSADA;
            EXIT WHEN C%NOTFOUND;
            IF (V_CURSADA = 1) THEN
                V_CREDITOS_CURSADOS   := V_CREDITOS_CURSADOS + V_CREDITOS;
                V_MATERIAS_CURSADAS   := V_MATERIAS_CURSADAS + 1;
            END IF;

            IF (V_CODIGO != V_CODIGO_ANTERIOR) THEN
                V_CREDITOS_PLAN         := V_CREDITOS_PLAN + V_CREDITOS;
                V_TOTAL_MATERIAS_PLAN   := V_TOTAL_MATERIAS_PLAN + 1;
                IF (V_APROBADA = 1) THEN
                    V_MATERIAS_APROBADAS   := V_MATERIAS_APROBADAS + 1;
                    V_CREDITOS_PROBADOS    := V_CREDITOS_PROBADOS + V_CREDITOS;
                END IF;

            END IF;

            V_CODIGO_ANTERIOR := V_CODIGO;
        END LOOP;
        CLOSE C;


        SELECT COUNT (*), SUM(CREDITOS)
        INTO V_MATERIAS_CURSANDO, V_CREDITOS_CURSANDO
        FROM (
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM ADMISIONES.B_ESTUDIANTES E
          INNER JOIN ADMISIONES.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN ADMISIONES.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
          UNION 
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM CACTUALPRE.B_ESTUDIANTES E
          INNER JOIN CACTUALPRE.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN ADMISIONES.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
          UNION 
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM POSTGRADO.B_ESTUDIANTES E
          INNER JOIN POSTGRADO.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN POSTGRADO.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
          UNION 
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM CACTUALPOS.B_ESTUDIANTES E
          INNER JOIN CACTUALPOS.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN POSTGRADO.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
          UNION 
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM YOPAL.B_ESTUDIANTES E
          INNER JOIN YOPAL.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN YOPAL.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
          UNION 
          SELECT P.MATERIA_PLAN, P.MATERIA_CURSAR, P.GRUPO, M.CREDITOS, P.CODIGO_ESTUDIANTE FROM CACTUALYOP.B_ESTUDIANTES E
          INNER JOIN CACTUALYOP.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE AND E.CODIGO_FACULTAD = P.FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD
          INNER JOIN YOPAL.A_MATERIAS M ON P.MATERIA_PLAN = M.CODIGO AND P.JORNADA_FACULTAD = M.JORNADA_FACULTAD AND P.FACULTAD = M.CODIGO_FACULTAD AND M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
          WHERE P.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE AND P.ANIO = V_ANIO AND P.CICLO = V_CICLO
        ) A;

        JSON.PUT (V_BODY, 'promedio', PKG_UTILS.PROMEDIOPONDERADOTOTAL (P_CODIGO_ESTUDIANTE));
        JSON.PUT (V_BODY, 'totalMateriasPlan', V_TOTAL_MATERIAS_PLAN);
        JSON.PUT (V_BODY, 'materiasCursando', V_MATERIAS_CURSANDO);
        JSON.PUT (V_BODY, 'materiasCursadas', V_MATERIAS_CURSADAS);
        JSON.PUT (V_BODY, 'materiasAprobadas', V_MATERIAS_APROBADAS);
        JSON.PUT (V_BODY, 'materiasReprobadas', V_MATERIAS_CURSADAS - V_MATERIAS_APROBADAS);
        JSON.PUT (V_BODY, 'materiasFaltantes', V_TOTAL_MATERIAS_PLAN - V_MATERIAS_APROBADAS);
        IF (V_TOTAL_MATERIAS_PLAN = 0) THEN
            JSON.PUT (V_BODY, 'porcentajeMateriasAprobadas', '0');
        ELSE
            JSON.PUT (V_BODY, 'porcentajeMateriasAprobadas', ROUND ((V_MATERIAS_APROBADAS / V_TOTAL_MATERIAS_PLAN) * 100, 1)
                                                             || '%');
        END IF;

        JSON.PUT (V_BODY, 'creditosPlan', V_CREDITOS_PLAN);
        JSON.PUT (V_BODY, 'creditosCursando', V_CREDITOS_CURSANDO);
        JSON.PUT (V_BODY, 'creditosCursados', V_CREDITOS_CURSADOS);
        JSON.PUT (V_BODY, 'creditosAprobados', V_CREDITOS_PROBADOS);
        JSON.PUT (V_BODY, 'creditosReprobados', V_CREDITOS_CURSADOS - V_CREDITOS_PROBADOS);
        JSON.PUT (V_BODY, 'creditosFaltantes', V_CREDITOS_PLAN - V_CREDITOS_PROBADOS);
        IF (V_CREDITOS_PLAN = 0) THEN
            JSON.PUT (V_BODY, 'porcentajeCreditosAprobados', '0');
        ELSE
            JSON.PUT (V_BODY, 'porcentajeCreditosAprobados', ROUND ((V_CREDITOS_PROBADOS / V_CREDITOS_PLAN) * 100, 1)
                                                             || '%');
        END IF;

        JSON.HTP (V_BODY);
    END GET_GENERALIDADES;

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE GET_HORARIO_DOCENTE (
        P_DOCUMENTO VARCHAR2
    ) IS

        TYPE CUR_TYP IS REF CURSOR;
        C                   CUR_TYP;
        V_CODIGO_ANTERIOR   VARCHAR2 (5 BYTE) DEFAULT 'NULL';
        V_CODIGO_MATERIA    VARCHAR2 (5 BYTE);
        V_DIA_NUMERICO      NUMBER;
        V_DIA_ANTERIOR      VARCHAR2 (20) DEFAULT 'NULL';
        V_DIA               VARCHAR2 (20);
        V_HORA_ANTERIOR     NUMBER DEFAULT -1;
        V_HORA              NUMBER;
        V_SALON_ANTERIOR    VARCHAR2 (20);
        V_SALON             VARCHAR2 (20);
        V_TIPO_ANTERIOR     VARCHAR2 (5) DEFAULT 'NULL';
        V_TIPO              VARCHAR2 (5);
        V_CONSECUTIVO       NUMBER;
        V_NOMBRE_MATERIA    VARCHAR2 (250 BYTE);
        V_BODY              JSON;
        V_JSON_MATERIAS     JSON_LIST;
        V_JSON_MATERIA      JSON;
        V_JSON_DIAS         JSON_LIST;
        V_JSON_DIA          JSON;
        V_JSON_HORAS        JSON_LIST;
        V_JSON_HORA         JSON;
        V_JSON_GRUPO        JSON;
        V_GRUPO             VARCHAR2 (5);
        V_CODIGO_FACULTAD   VARCHAR2 (5);
        
        v_respuesta json := json();
        
        v_anio_1 varchar2(4);
        v_ciclo_1 varchar2(2);
        v_esquema_1 varchar2(32);
        v_anio_2 varchar2(4);
        v_ciclo_2 varchar2(2);
        v_esquema_2 varchar2(32);
        v_anio_4 varchar2(4);
        v_ciclo_4 varchar2(2);
        v_esquema_4 varchar2(32);
        
    BEGIN
        -- AGREGANDO HEADERS.
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        V_BODY            := JSON ();
        V_JSON_MATERIAS   := JSON_LIST ();
        IF (TRIM (P_DOCUMENTO) != '0') THEN
            pkg_utils.getAnioCicloEsquema('1',v_anio_1,v_ciclo_1,v_esquema_1);
            pkg_utils.getAnioCicloEsquema('2',v_anio_2,v_ciclo_2,v_esquema_2);
            pkg_utils.getAnioCicloEsquema('4',v_anio_4,v_ciclo_4,v_esquema_4);
            OPEN C FOR 'SELECT TRIM (CODIGO_MATERIA),
                              NOMBRE,
                              TO_NUMBER (DIA),
                              CASE TO_NUMBER (DIA)
                                  WHEN 1   THEN
                                      ''Lunes''
                                  WHEN 2   THEN
                                      ''Martes''
                                  WHEN 3   THEN
                                      ''Miercoles''
                                  WHEN 4   THEN
                                      ''Jueves''
                                  WHEN 5   THEN
                                      ''Viernes''
                                  WHEN 6   THEN
                                      ''Sabado''
                                  WHEN 7   THEN
                                      ''Domingo''
                                  ELSE
                                      ''N/A''
                              END DIA,
                              TO_NUMBER (HORA) HORA,
                              NVL (SALON, ''NO APLICA''),
                              TIPO,
                              CONSECUTIVO,
                              GRUPO_MATERIA,
                              CODIGO_FACULTAD
                         FROM (SELECT HV.CODIGO_MATERIA,
                                      AM.NOMBRE,
                                      HV.DIA,
                                      HV.HORA,
                                      HV.SALON,
                                      HV.TIPO,
                                      HV.CONSECUTIVO,
                                      HV.GRUPO_MATERIA,
                                      HV.CODIGO_FACULTAD
                               FROM ' || v_esquema_1 || '.A_HORARIO_VERTICAL HV
                              INNER JOIN ADMISIONES.A_MATERIAS AM ON AM.CODIGO_FACULTAD = HV.CODIGO_FACULTAD
                                AND AM.JORNADA_FACULTAD = HV.JORNADA_FACULTAD
                                AND AM.CODIGO = HV.CODIGO_MATERIA
                              WHERE NUMERO_DOCUMENTO = :documento
                             UNION ALL
                             SELECT HV.CODIGO_MATERIA,
                                    AM.NOMBRE,
                                    HV.DIA,
                                    HV.HORA,
                                    NULL,
                                    HV.TIPO,
                                    HV.CONSECUTIVO,
                                    HV.GRUPO_MATERIA,
                                    HV.CODIGO_FACULTAD
                               FROM ' || v_esquema_2 || '.A_HORARIO_VERTICAL HV
                              INNER JOIN POSTGRADO.A_MATERIAS AM ON AM.CODIGO_FACULTAD = HV.CODIGO_FACULTAD
                                AND AM.JORNADA_FACULTAD = HV.JORNADA_FACULTAD
                                AND AM.CODIGO = HV.CODIGO_MATERIA
                              WHERE NUMERO_DOCUMENTO = :documento
                             UNION ALL
                             SELECT HV.CODIGO_MATERIA,
                                    AM.NOMBRE,
                                    HV.DIA,
                                    HV.HORA,
                                    HV.SALON,
                                    HV.TIPO,
                                    HV.CONSECUTIVO,
                                    HV.GRUPO_MATERIA,
                                    HV.CODIGO_FACULTAD
                               FROM ' || v_esquema_4 || '.A_HORARIO_VERTICAL HV
                              INNER JOIN YOPAL.A_MATERIAS AM ON AM.CODIGO_FACULTAD = HV.CODIGO_FACULTAD
                                AND AM.JORNADA_FACULTAD = HV.JORNADA_FACULTAD
                                AND AM.CODIGO = HV.CODIGO_MATERIA
                              WHERE NUMERO_DOCUMENTO = :documento
                       ) A
                        ORDER BY CODIGO_MATERIA,
                                 DIA,
                                 HORA'
                using p_documento, p_documento, p_documento;

            LOOP
                FETCH C INTO
                    V_CODIGO_MATERIA,
                    V_NOMBRE_MATERIA,
                    V_DIA_NUMERICO,
                    V_DIA,
                    V_HORA,
                    V_SALON,
                    V_TIPO,
                    V_CONSECUTIVO,
                    V_GRUPO,
                    V_CODIGO_FACULTAD;	

					-- Si se cambio de hora.

                IF NOT (V_CODIGO_MATERIA = V_CODIGO_ANTERIOR AND V_DIA = V_DIA_ANTERIOR AND V_TIPO_ANTERIOR = V_TIPO AND V_SALON_ANTERIOR = V_SALON AND V_HORA_ANTERIOR = V_HORA - 1) AND V_HORA_ANTERIOR != -1 THEN
                    JSON_LIST.APPEND (V_JSON_HORAS, V_JSON_HORA.TO_JSON_VALUE);
                END IF;		

					-- Si se cambio de dia, o no hay mas registros.

                IF ((C%NOTFOUND OR V_DIA != V_DIA_ANTERIOR OR V_CODIGO_MATERIA != V_CODIGO_ANTERIOR) AND (V_DIA_ANTERIOR != 'NULL')) THEN
                    JSON.PUT (V_JSON_DIA, 'horas', V_JSON_HORAS);
                    JSON_LIST.APPEND (V_JSON_DIAS, V_JSON_DIA.TO_JSON_VALUE);
                END IF;

					-- Si se cambio de materia, o ya no hay registros.

                IF ((C%NOTFOUND OR V_CODIGO_MATERIA != V_CODIGO_ANTERIOR) AND V_CODIGO_ANTERIOR != 'NULL') THEN
                    JSON.PUT (V_JSON_MATERIA, 'dias', V_JSON_DIAS);
                    JSON_LIST.APPEND (V_JSON_MATERIAS, V_JSON_MATERIA.TO_JSON_VALUE);
                END IF;

					-- Si se cambio materia.

                IF (V_CODIGO_MATERIA != V_CODIGO_ANTERIOR) THEN
                    V_JSON_MATERIA     := JSON ();
                    JSON.PUT (V_JSON_MATERIA, 'codigoMateria', V_CODIGO_MATERIA);
                    JSON.PUT (V_JSON_MATERIA, 'nombreMateria', V_NOMBRE_MATERIA);
                    JSON.PUT (V_JSON_MATERIA, 'codigoFacultad', V_CODIGO_FACULTAD);
                    JSON.PUT (V_JSON_MATERIA, 'grupo', V_GRUPO);
                    V_DIA_ANTERIOR     := 'NULL';
                    V_HORA_ANTERIOR    := -1;
                    V_SALON_ANTERIOR   := 'NULL';
                    V_TIPO_ANTERIOR    := 'NULL';
                    V_JSON_DIAS        := JSON_LIST ();
                    V_JSON_HORAS       := JSON_LIST ();
                END IF;

					-- Si se cambio dia.

                IF (V_DIA != V_DIA_ANTERIOR) THEN
                    V_JSON_DIA         := JSON ();
                    JSON.PUT (V_JSON_DIA, 'idDia', V_DIA_NUMERICO);
                    JSON.PUT (V_JSON_DIA, 'dia', V_DIA);
                    V_HORA_ANTERIOR    := -1;
                    V_SALON_ANTERIOR   := 'NULL';
                    V_TIPO_ANTERIOR    := 'NULL';
                    V_JSON_HORAS       := JSON_LIST ();
                END IF;				

					-- Si se cambio de hora.

                IF (V_CODIGO_MATERIA = V_CODIGO_ANTERIOR AND V_DIA = V_DIA_ANTERIOR AND V_TIPO_ANTERIOR = V_TIPO AND V_SALON_ANTERIOR = V_SALON AND V_HORA_ANTERIOR = V_HORA - 1) THEN
                    JSON.PUT (V_JSON_HORA, 'fin', V_HORA + 1 || ':00');
                ELSE
                    V_JSON_HORA := JSON ();
                    JSON.PUT (V_JSON_HORA, 'inicio', V_HORA || ':00');
                    JSON.PUT (V_JSON_HORA, 'fin', V_HORA + 1 || ':00');
                    JSON.PUT (V_JSON_HORA, 'tipo', V_TIPO);
                    JSON.PUT (V_JSON_HORA, 'salon', V_SALON);
                END IF;

                V_CODIGO_ANTERIOR   := V_CODIGO_MATERIA;
                V_DIA_ANTERIOR      := V_DIA;
                V_HORA_ANTERIOR     := V_HORA;
                V_SALON_ANTERIOR    := V_SALON;
                V_TIPO_ANTERIOR     := V_TIPO;
                EXIT WHEN C%NOTFOUND;
            END LOOP;

            CLOSE C;
        END IF;

        JSON.PUT (V_BODY, 'materias', V_JSON_MATERIAS);
        JSON.HTP (V_BODY);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    END GET_HORARIO_DOCENTE;

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE GET_PENDIENTES (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_FINANCIERA    VARCHAR2 (4);
        V_BIBLIOTECA    VARCHAR2 (2);
        V_DOCUMENTOS    VARCHAR2 (16);
        J_RESPUESTA     JSON := JSON();
    BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS ();
        SELECT COUNT(1)
        INTO   V_FINANCIERA
        FROM   admisiones.a_deudas_financiera df
        WHERE  df.codigo_estudiante=P_CODIGO_ESTUDIANTE; 

        SELECT COUNT(1)
        INTO   V_BIBLIOTECA
        FROM   admisiones.a_deudas_biblioteca db
        WHERE  db.codigo_estudiante=P_CODIGO_ESTUDIANTE;

        SELECT COUNT(1)
        INTO   V_DOCUMENTOS
        FROM   doc_estudiante de
        WHERE  de.codigo_estudiante=P_CODIGO_ESTUDIANTE
        AND    de.estado = 'NO'
        AND    DE.CODIGO_DOCUMENTO IN ('1','2');

        JSON.put(J_RESPUESTA, 'financiera', V_FINANCIERA);
        JSON.put(J_RESPUESTA, 'biblioteca', V_BIBLIOTECA);
        JSON.put(J_RESPUESTA, 'documentos', V_DOCUMENTOS);

        json.htp(j_respuesta);

    END GET_PENDIENTES;

END PKG_EXPOSED_SERVICES_FACADE;