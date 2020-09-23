CREATE OR REPLACE PACKAGE PKG_BOLSAS_ELECTIVAS AS

    PROCEDURE GET_BOLSAS(
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    );
    
    FUNCTION GET_MATERIAS_BOLSA_ELECTIVA(
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN JSON_LIST;
    
    FUNCTION GET_CURSOR_ELECTIVAS_1 (
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN SYS_REFCURSOR;
    
    FUNCTION GET_GRUPOS (
        P_CODIGO_MATERIA A_MATERIAS.CODIGO%TYPE,
        P_CODIGO_FACULTAD A_MATERIAS.CODIGO_FACULTAD%TYPE,
        P_JORNADA_FACULTAD A_MATERIAS.JORNADA_FACULTAD%TYPE,
        P_PLAN_ESTUDIO A_MATERIAS.PLAN_ESTUDIO%TYPE
    ) RETURN JSON_LIST;
END PKG_BOLSAS_ELECTIVAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_BOLSAS_ELECTIVAS AS

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- 
-- ****************************************************************************************************************************

    PROCEDURE GET_BOLSAS(
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) IS
        V_CODIGO_ESTUDIANTE VARCHAR2(8);
		V_BODY              JSON_LIST := JSON_LIST();    
        V_ERROR             JSON := JSON();  
		V_BOLSA             JSON;
		V_MATERIAS          JSON_LIST;
        V_QUERY             VARCHAR2(4000);
    BEGIN
        PKG_HTML.CORSHEADERS();
        -- VERIFICANDO LA EXISTENCIA DEL ESTUDIANTE.
        SELECT CODIGO
        INTO   V_CODIGO_ESTUDIANTE
        FROM   B_ESTUDIANTES
        WHERE      CODIGO = P_CODIGO_ESTUDIANTE
               AND PKG_UTILS.EVALUAR_PAGO (INDICADOR_PAGO) = 1;
        IF(V_CODIGO_ESTUDIANTE IS NOT NULL) THEN
            -- OBTENIENDO BOLSAS PARA EL ESTUDIANTE ACTUAL.
            FOR BOLSA IN (SELECT     BC.ID_BOLSA, 
                                     BC.NOMBRE, 
                                     BC.FN_OFERTA, 
                                     BE.CODIGO 
                          FROM       CTI_BOLSA_ESTUDIANTE BE 
                          INNER JOIN CTI_BOLSAS_CREDITOS BC ON BC.ID_BOLSA = BE.ID_BOLSA
                          WHERE      BE.CODIGO = V_CODIGO_ESTUDIANTE) LOOP
                V_BOLSA := JSON();
                JSON.PUT(V_BOLSA, 'id', BOLSA.ID_BOLSA);
                JSON.PUT(V_BOLSA, 'nombre', BOLSA.NOMBRE);
                -- OBTENIENDO INFORMACION DE LA FUNCION FINAMICAMENTE.
                V_QUERY:= 'SELECT ' || BOLSA.FN_OFERTA || '(:codigo) FROM DUAL';
                EXECUTE IMMEDIATE V_QUERY INTO V_MATERIAS USING V_CODIGO_ESTUDIANTE;
                JSON.PUT(V_BOLSA, 'asignaturasDisponibles', V_MATERIAS);   
                JSON_LIST.APPEND(V_BODY, V_BOLSA.TO_JSON_VALUE);
            END LOOP;   
        END IF;     
        JSON_LIST.HTP(V_BODY, FALSE);
    EXCEPTION 
        WHEN OTHERS THEN
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);   
    END GET_BOLSAS;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE LAS MATERIAS DE LAS BOLSAS ELECTIVAS. SI SE AGREGA OTRA BOLSA ELECTIVA, CON UNA FUNCION NUEVA PARA OBTENER LAS
-- MATERIAS, SE DEBE MODIFICAR EL CURSOR Y EL PROGRAMA HARÁ EL RESTO.
-- ****************************************************************************************************************************

    FUNCTION GET_MATERIAS_BOLSA_ELECTIVA(
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN JSON_LIST IS
        V_MATERIAS          JSON_LIST := JSON_LIST();
		V_MATERIA           JSON := JSON();
        -- VARIABLES RELACIONADAS AL CURSOR.
        OFERTA_CURSOR       SYS_REFCURSOR;
        V_CODIGO_MATERIA    VARCHAR2(5);
        V_CODIGO_FACULTAD   VARCHAR2(2);
        V_JORNADA_FACULTAD	VARCHAR2(1);
        V_PLAN_ESTUDIOS  	VARCHAR2(3);
    BEGIN      
        OFERTA_CURSOR := GET_CURSOR_ELECTIVAS_1(P_CODIGO_ESTUDIANTE);
        LOOP
            FETCH OFERTA_CURSOR INTO V_CODIGO_MATERIA,
                                     V_CODIGO_FACULTAD,
                                     V_JORNADA_FACULTAD,
                                     V_PLAN_ESTUDIOS; 
            EXIT WHEN OFERTA_CURSOR%NOTFOUND;
            V_MATERIA := JSON();
            JSON.PUT(V_MATERIA, 'materia', PKG_UTILS.GETMATERIA(V_CODIGO_FACULTAD, 
                                                                V_JORNADA_FACULTAD, 
                                                                V_PLAN_ESTUDIOS, 
                                                                V_CODIGO_MATERIA, 
                                                                1));
            JSON.PUT(V_MATERIA, 'grupos', GET_GRUPOS(V_CODIGO_MATERIA,
                                                     V_CODIGO_FACULTAD, 
                                                     V_JORNADA_FACULTAD, 
                                                     V_PLAN_ESTUDIOS));
            
            JSON_LIST.APPEND(V_MATERIAS, V_MATERIA.TO_JSON_VALUE);
        END LOOP;
        RETURN V_MATERIAS;
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000, 'Error al obtener materias de la bolsa.'); 
    END GET_MATERIAS_BOLSA_ELECTIVA;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREA UN QUERY PARA OBTENER LAS MATERIAS PERTENECIENTES A LA BOLSA "Bolsa de créditos electivos" Y , A PARTIR DE ESTE,
-- CREA UN CURSOR CON LAS MATERIAS, LO ABRE Y LO DEVUELVE. 
-- ****************************************************************************************************************************

    FUNCTION GET_CURSOR_ELECTIVAS_1 (
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN SYS_REFCURSOR IS 
        V_ANIO        VARCHAR2(4);
        V_CICLO       VARCHAR2(2);
        V_ESQUEMA     VARCHAR2(32);
        OFERTA_CURSOR SYS_REFCURSOR;
        V_QUERY       CLOB;
    BEGIN
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA('2',V_ANIO,V_CICLO,V_ESQUEMA);
        -- CREANDO QUERY QUE OBTENGA LAS MATERIAS.
        V_QUERY := '-- MATERIAS QUE ESTAN OFERTADAS PARA TODAS LAS FACULTADES.
                    SELECT  A.CODIGO,
                            A.CODIGO_FACULTAD,
                            A.JORNADA_FACULTAD,
                            A.PLAN_ESTUDIO
                    FROM    (SELECT DISTINCT M.CODIGO,
                                             M.CODIGO_FACULTAD,
                                             M.JORNADA_FACULTAD,
                                             M.PLAN_ESTUDIO,
                                             F.NOMBRE,
                                             M.SEMESTRE
                             FROM            A_MATERIAS M 
                             INNER JOIN      ADMISIONES.A_FACULTADES F ON     F.CODIGO  = M.CODIGO_FACULTAD 
                                                                          AND F.JORNADA = M.JORNADA_FACULTAD
                             INNER JOIN      ' || v_esquema || '.A_HORARIO_HORIZONTAL H ON     H.CODIGO_FACULTAD  = M.CODIGO_FACULTAD 
                                                                                           AND H.JORNADA_FACULTAD = M.JORNADA_FACULTAD
                                                                                           AND H.PLAN_ESTUDIO     = M.PLAN_ESTUDIO 
                                                                                           AND H.CODIGO_MATERIA   = M.CODIGO
                             MINUS
                             -- NO SE TIENEN EN CUENTA TODAS LAS:
                             SELECT B.CODIGO_MATERIA,
                                    B.CODIGO_FACULTAD,
                                    B.JORNADA_FACULTAD,
                                    B.PLAN_ESTUDIO,
                                    F.NOMBRE,
                                    M.SEMESTRE
                             FROM   (-- 1. MATERIAS APROBADAS.
                                     SELECT CODIGO_MATERIA,
                                            CODIGO_FACULTAD,
                                            JORNADA_FACULTAD,
                                            IND_HNVOPLAN PLAN_ESTUDIO
                                     FROM   A_NOTAS N
                                     WHERE      N.VALOR > ''3.5''
                                            AND N.CODIGO_ESTUDIANTE = :codigoEstudiante
                                     UNION ALL
                                     -- 2. MATERIAS CON REQUISITOS NO CUMPLIDOS.
                                     SELECT    R.CODIGO_MATERIA,
                                               R.CODIGO_FACULTAD,
                                               R.JORNADA_FACULTAD,
                                               R.PLAN_ESTUDIO
                                     FROM      A_REQUISITOS R                                
                                     UNION ALL
                                     -- 3. MATERIAS DEL PLAN DEL ESTUDIANTE CON SEMESTRE DIFERENTE DE 0. 
                                     SELECT     M.CODIGO,
                                                M.CODIGO_FACULTAD,
                                                M.JORNADA_FACULTAD,
                                                M.PLAN_ESTUDIO
                                     FROM       A_MATERIAS M
                                     INNER JOIN ' || v_esquema || '.B_ESTUDIANTES E ON     E.CODIGO_FACULTAD  = M.CODIGO_FACULTAD 
                                                                                       AND E.JORNADA_FACULTAD = M.JORNADA_FACULTAD
                                                                                       AND E.PLAN_ESTUDIO     = M.PLAN_ESTUDIO 
                                                                                       AND TO_NUMBER(M.SEMESTRE) != 0
                                     WHERE     E.CODIGO = :codigoEstudiante) B
                             INNER JOIN      A_MATERIAS M ON     B.CODIGO_FACULTAD  = M.CODIGO_FACULTAD 
                                                             AND B.JORNADA_FACULTAD = M.JORNADA_FACULTAD
                                                             AND B.PLAN_ESTUDIO     = M.PLAN_ESTUDIO 
                                                             AND B.CODIGO_MATERIA   = M.CODIGO
                             INNER JOIN      ADMISIONES.A_FACULTADES F ON     F.CODIGO  = B.CODIGO_FACULTAD 
                                                                          AND F.JORNADA = B.JORNADA_FACULTAD) A
                    ORDER BY   A.CODIGO';
        OPEN OFERTA_CURSOR FOR V_QUERY USING P_CODIGO_ESTUDIANTE, P_CODIGO_ESTUDIANTE;
        RETURN OFERTA_CURSOR;
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000, 'Error al obtener electivas.');
    END GET_CURSOR_ELECTIVAS_1;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE LOS GRUPOS DE LA TABLA A_HORARIO_HORIZONTAL CORRESPONDIENTES A LA MATERIA DESEADA.
-- ****************************************************************************************************************************

    FUNCTION GET_GRUPOS (
        P_CODIGO_MATERIA   A_MATERIAS.CODIGO%TYPE,
        P_CODIGO_FACULTAD  A_MATERIAS.CODIGO_FACULTAD%TYPE,
        P_JORNADA_FACULTAD A_MATERIAS.JORNADA_FACULTAD%TYPE,
        P_PLAN_ESTUDIO     A_MATERIAS.PLAN_ESTUDIO%TYPE
    ) RETURN JSON_LIST IS
        V_RETURNABLE  JSON_LIST := JSON_LIST();
        V_ANIO        VARCHAR2(4);
        V_CICLO       VARCHAR2(2);
        V_ESQUEMA     VARCHAR2(32);
        V_QUERY       VARCHAR2(4096);
        OFERTA_CURSOR SYS_REFCURSOR;
        V_CONSECUTIVO NUMBER;
    BEGIN
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA('2',V_ANIO,V_CICLO,V_ESQUEMA);
        V_QUERY := 'SELECT CONSECUTIVO
                    FROM   ' || v_esquema || '.A_HORARIO_HORIZONTAL H 
                    WHERE     H.CODIGO_FACULTAD  = :codigoFacultad
                          AND H.JORNADA_FACULTAD = :jornadaFacultad
                          AND H.PLAN_ESTUDIO     = :planEstudio
                          AND H.CODIGO_MATERIA   = :codigoMateria';
        OPEN OFERTA_CURSOR FOR V_QUERY USING P_CODIGO_FACULTAD, 
                                             P_JORNADA_FACULTAD,
                                             P_PLAN_ESTUDIO,
                                             P_CODIGO_MATERIA;
        LOOP
            FETCH OFERTA_CURSOR INTO V_CONSECUTIVO;
            EXIT WHEN OFERTA_CURSOR%NOTFOUND;
            JSON_LIST.APPEND(V_RETURNABLE, PKG_UTILS.GETGRUPO(V_CONSECUTIVO).TO_JSON_VALUE);
        END LOOP;                          
        RETURN V_RETURNABLE;
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000, 'Error al obtener grupos.');
    END GET_GRUPOS;
END PKG_BOLSAS_ELECTIVAS;
/
