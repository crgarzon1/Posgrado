create or replace PACKAGE BODY PKG_CTI_DASHBOARD_POSGRADOS AS

     /*
    OBTIENE LOS PRIMEROS 10 ESTUDIANTES QUE CUMPLAN CON EL CRITERIO DE BUSQUEDA.
    EL CRITERIO DE BUSQUEDA PUEDE SER EL NOMBRE, EL NUMERO DE DOCUMENTO O EL CODIGO ESTUDIANTIL.
    @param P_CRITERIO_BUSQUEDA VARCHAR2 => C = codigo estudiantil, D = Numero de documento, N = Nombre o apellido.
    @param P_VALOR => VALOR DE BUSQUEDA (CODIGO ESTUDIANTIL, NOMBRE O NUMERO DE DOCUMENTO.)
    */  
	PROCEDURE BUSCAR_ESTUDIANTE(
        P_CRITERIO_BUSQUEDA VARCHAR2,
        P_VALOR VARCHAR2, 
		P_CODIGO_FACULTAD VARCHAR2,
		P_JORNADA_FACULTAD VARCHAR2
    ) IS
		V_BODY      JSON_LIST;
		V_ERROR     JSON;        
	BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS();
		V_BODY := JSON_LIST();  
        -- OBTENCION DE ESTUDIANTES QUE CUMPLAN CON LOS CRITERIOS DE BUSQUEDA.
        --D = Documento
        --C = Codigo
        --N = Nombre
        IF P_CRITERIO_BUSQUEDA = 'D' THEN
            FOR ESTUDIANTE IN (SELECT     E.CODIGO
                           FROM       POSTGRADO.B_ESTUDIANTES E
                           INNER JOIN POSTGRADO.DATOS_PERSONALES DP ON E.CODIGO = DP.CODIGO_ESTUDIANTE
                           WHERE  (LOWER(DP.NUMERO_DOCUMENTO) LIKE '%' || LOWER(P_VALOR) || '%')
                                      AND ROWNUM <= 10
                                      AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
                                      AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD) LOOP  
            JSON_LIST.APPEND (V_BODY, PKG_UTILS.GETESTUDIANTE(ESTUDIANTE.CODIGO).TO_JSON_VALUE);
            END LOOP;

        ELSIF P_CRITERIO_BUSQUEDA = 'C' THEN
            FOR ESTUDIANTE IN (SELECT     E.CODIGO
                           FROM       POSTGRADO.B_ESTUDIANTES E
                           WHERE (E.CODIGO LIKE '%' || P_VALOR || '%')
                                      AND ROWNUM <= 10
                                      AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
                                      AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD) LOOP  
            JSON_LIST.APPEND (V_BODY, PKG_UTILS.GETESTUDIANTE(ESTUDIANTE.CODIGO).TO_JSON_VALUE);
            END LOOP;

        ELSIF P_CRITERIO_BUSQUEDA = 'N' THEN
            FOR ESTUDIANTE IN (SELECT     E.CODIGO
                           FROM       POSTGRADO.B_ESTUDIANTES E
                           INNER JOIN POSTGRADO.DATOS_PERSONALES DP ON E.CODIGO = DP.CODIGO_ESTUDIANTE
                           WHERE          (   LOWER(E.NOMBRE) LIKE '%' || LOWER(P_VALOR) ||'%')
                                      AND ROWNUM <= 10
                                      AND E.CODIGO_FACULTAD = P_CODIGO_FACULTAD
                                      AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD) LOOP  
            JSON_LIST.APPEND (V_BODY, PKG_UTILS.GETESTUDIANTE(ESTUDIANTE.CODIGO).TO_JSON_VALUE);
            END LOOP;

        END IF;
		JSON_LIST.HTP(V_BODY, FALSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);
	END BUSCAR_ESTUDIANTE;

    /*
    OBTIENE LOS SIGUIENTES INDICADORES DE LAS INSCRIPCIONES DE UN PROGRAMA ACADEMICO:
        - HABEAS DATA.
        - FORMULARIO 1.
        - FORMULARIO 2.
        - PAGO DE INSCRIPCIÃ¯Â¿Â½N.
        - ENTREVISTADOS.
        - ADMITIDOS.
        - MATRICULADOS.
    @param P_CODIGO_FACULTAD VARCHAR2  => CODIGO FACULTAD.
    @param P_JORNADA_FACULTAD VARCHAR2 => JORNADA FACULTAD.
    */
	PROCEDURE GET_INDICADORES (
		P_CODIGO_FACULTAD VARCHAR2,
		P_JORNADA_FACULTAD VARCHAR2
	) IS
		V_BODY        JSON;
		V_ERROR       JSON;
		V_HABEAS_DATA NUMBER;
		V_FORM1       NUMBER;
		V_FORM2       NUMBER;
		V_PAGO_INS    NUMBER;
		V_ENTREVISTA  NUMBER;
		V_ADMITIDO    NUMBER;
		V_MATRICULADO NUMBER;
        V_ANIO        VARCHAR2 (4);
        V_CICLO       VARCHAR2 (2);
        V_ESQUEMA     VARCHAR2 (32);
	BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS();
        
        BEGIN
            SELECT ANIO, CICLO
            INTO V_ANIO, V_CICLO
            FROM POSTGRADO.A_ASPIRANTES WHERE CODIGO_FACULTAD = P_CODIGO_FACULTAD AND JORNADA_FACULTAD = P_JORNADA_FACULTAD AND ROWNUM = '1'
            ORDER BY TO_NUMBER(ANIO || CICLO) DESC;
        EXCEPTION
            WHEN OTHERS THEN
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA ('2', V_ANIO, V_CICLO, V_ESQUEMA);
        END;
        
		V_BODY := JSON ();
        -- OBTENCION DE LOS INDICADORES.
        SELECT NVL(SUM(HABEAS_DATA), 0) HABEAS_DATA,
               NVL(SUM(FORM1), 0) FORM1,
               NVL(SUM(FORM2), 0) FORM2,
               NVL(SUM(PAGO_INS), 0) PAGO_INS,
               NVL(SUM(ENTREVISTA), 0) ENTREVISTA,
               NVL(SUM(ADMITIDO), 0) ADMITIDO,
               NVL(SUM(MATRICULADO), 0) MATRICULADO
        INTO   V_HABEAS_DATA,
               V_FORM1,
               V_FORM2,
               V_PAGO_INS,
               V_ENTREVISTA,
               V_ADMITIDO,
               V_MATRICULADO
        FROM   (-- PERSONAS INTERESADAS EN INGRESAR A ESTUDIOS QUE NO ESTAN EN A_ASPIRANTES.
                SELECT     1 AS HABEAS_DATA,
                           0 AS FORM1,
                           0 AS FORM2,
                           0 AS PAGO_INS,
                           0 as ENTREVISTA,
                           0 AS ADMITIDO,
                           0 AS MATRICULADO
                FROM       DESARROLLOSPRE.CTI_INTERESADO I
                INNER JOIN ADMISIONES.A_FACULTADES F ON  I.CODIGO_FACULTAD  = F.CODIGO
                                                     AND I.JORNADA_FACULTAD = F.JORNADA
                INNER JOIN DESARROLLOSPRE.CTI_CAMPANIA C ON I.ORIGEN = C.CODIGO
                WHERE          I.ANIO    = V_ANIO
                           AND I.CICLO   = V_CICLO
                           AND F.CODIGO  = P_CODIGO_FACULTAD
                           AND F.JORNADA = P_JORNADA_FACULTAD
                           -- QUE NO EXISTAN EN A_ASPIRANTES.    
                           AND NOT EXISTS(SELECT 1
                                          FROM   ADMISIONES.A_ASPIRANTES AA
                                          WHERE      AA.NUMDOC          = I.NUMDOC
                                                 AND AA.TIPDOC          = I.TIPDOC
                                                 AND AA.ANIO            = I.ANIO
                                                 AND AA.CICLO           = I.CICLO
                                                 AND I.CODIGO_FACULTAD  = AA.CODIGO_FACULTAD
                                                 AND I.JORNADA_FACULTAD = AA.JORNADA_FACULTAD
                                          UNION
                                          SELECT 1
                                          FROM   POSTGRADO.A_ASPIRANTES AP
                                          WHERE      AP.NUMDOC = I.NUMDOC
                                                 AND AP.ANIO = I.ANIO
                                                 AND AP.CICLO = I.CICLO
                                                 AND I.CODIGO_FACULTAD  = AP.CODIGO_FACULTAD
                                                 AND I.JORNADA_FACULTAD = AP.JORNADA_FACULTAD)
                /*UNION ALL
                -- ASPIRANTES DE PREGRADO.
                SELECT     1 AS HABEAS_DATA, 
                           1 AS FORM1, 
                           CASE
                                WHEN A.NUMSNP IS NOT NULL THEN 1
                                ELSE 0
                           END AS FORM2,
                           NVL((SELECT 1
                                FROM   G_OTROS_PAGOS OP
                                WHERE      OP.CODIGO_EST = A.CODIGO 
                                       AND OP.INDICADOR_PAGO  = 'P' 
                                       AND OP.ACTIVA          = 1 
                                       AND OP.ANIO            = A.ANIO 
                                       AND OP.CICLO           = A.CICLO),
                               0) AS PAGO_INS, 
                           CASE 
                                WHEN A.PENTRE IS NOT NULL THEN 1
                                ELSE 0
                           END AS ENTREVISTA,
                           CASE
                                WHEN A.IND1 = 1 THEN 0
                                WHEN A.IND1 = 2 THEN 1
                                ELSE NULL
                           END AS ADMITIDO, 
                           NVL((SELECT 1
                                FROM   B_ESTUDIANTES E
                                WHERE      E.CODIGO IS NOT NULL 
                                       AND E.CODIGO = A.COD_DEF 
                                       AND E.INDICADOR_PAGO IN ('P', 'V')),
                               0) AS MATRICULADO
                FROM       A_ASPIRANTES A
                INNER JOIN A_FACULTADES F ON  A.CODIGO_FACULTAD  = F.CODIGO 
                                          AND A.JORNADA_FACULTAD = F.JORNADA
                WHERE          A.ANIO    = '2019' 
                           AND A.CICLO   = '02'
                           AND F.CODIGO  = P_CODIGO_FACULTAD
                           AND F.JORNADA = P_JORNADA_FACULTAD*/
                -- ASPIRANTES DE POSGRADO.           
                UNION ALL
                SELECT     1 AS HABEAS_DATA,
                           1 AS FORM1,
                           CASE
                                WHEN A.SEXO IS NOT NULL THEN 1
                                ELSE 0
                           END AS FORM2,
                           NVL((SELECT 1
                                FROM   G_OTROS_PAGOS OP
                                WHERE      OP.CODIGO_EST     = A.CODIGO
                                       AND OP.INDICADOR_PAGO = 'P'
                                       AND OP.ACTIVA         = 1
                                       AND OP.ANIO           = A.ANIO
                                       AND OP.CICLO          = A.CICLO),
                               0) AS PAGO_INS,
                           0 AS ENTREVISTA,
                           CASE
                                WHEN A.IND1 = 1 THEN 0
                                WHEN A.IND1 = 2 THEN 1
                                ELSE NULL
                           END AS ADMITIDO,
                           NVL((SELECT 1
                                FROM   POSTGRADO.B_ESTUDIANTES E
                                WHERE      E.CODIGO IS NOT NULL
                                       AND E.CODIGO = A.COD_DEF
                                       AND E.INDICADOR_PAGO IN ('P','V')),
                               0) AS MATRICULADO
                FROM       POSTGRADO.A_ASPIRANTES A
                INNER JOIN ADMISIONES.A_FACULTADES F ON  A.CODIGO_FACULTAD = F.CODIGO
                                                    AND A.JORNADA_FACULTAD = F.JORNADA
                WHERE          A.ANIO    = V_ANIO 
                           AND A.CICLO   = V_CICLO
                           AND F.CODIGO  = P_CODIGO_FACULTAD
                           AND F.JORNADA = P_JORNADA_FACULTAD) ASPIRANTES;
        JSON.PUT (V_BODY, 'habeasData', V_HABEAS_DATA);
        JSON.PUT (V_BODY, 'form1', V_FORM1);
        JSON.PUT (V_BODY, 'form2', V_FORM2);
        JSON.PUT (V_BODY, 'pagoInscripcion', V_PAGO_INS);
        JSON.PUT (V_BODY, 'entrevista', V_ENTREVISTA);
        JSON.PUT (V_BODY, 'admitido', V_ADMITIDO);
        JSON.PUT (V_BODY, 'matriculado', V_MATRICULADO);
		JSON.HTP (V_BODY);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            --JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);   
	END GET_INDICADORES;

    /*
    OBTENER NUMERO DE ESTUDIANTES POR TIPO DE INGRESO, FILTRADOS POR PROGRAMA ACADÃ¯Â¿Â½MICO.
    @param P_CODIGO_FACULTAD VARCHAR2  => CODIGO FACULTAD.
    @param P_JORNADA_FACULTAD VARCHAR2 => JORNADA FACULTAD.
    */
	PROCEDURE GET_ESTUDIANTES_TIPO_ING (
		P_CODIGO_FACULTAD VARCHAR2,
		P_JORNADA_FACULTAD VARCHAR2
	) IS
		V_CHARTS    JSON_LIST;
		V_CHART     JSON;
		V_ITEMS     JSON_LIST;
		V_ITEM      JSON;

		V_ERROR     JSON;
		V_REGISTRO  JSON;
        V_VALUE     NUMBER;
	BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS();
		V_CHARTS := JSON_LIST(); 

        -- PRIMERA GRAFICA.
		V_CHART := JSON(); 
        JSON.PUT (V_CHART, 'label', 'Tipo de Estudiante');
        JSON.PUT (V_CHART, 'xAxisLabel', 'Tipo de Estudiante');
        JSON.PUT (V_CHART, 'yAxisLabel', 'Cantidad de estudiantes');
        V_ITEMS := JSON_LIST();
        -- ITERANDO SOBRE RESULTADOS DE BUSQUEDA.
        FOR AUXILIAR_RECORD IN (SELECT   TIPO_DE_INGRESO, 
                                         TIPO_DE_INGRESO_LABEL,  
                                         COUNT(CODIGO) NUMERO_DE_ESTUDIANTES
                                FROM     (SELECT CASE
                                                    WHEN (E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)) THEN E.TIPO_DE_INGRESO
                                                    ELSE 'AN'
                                                 END TIPO_DE_INGRESO,
                                                 CASE
                                                    WHEN (E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)) THEN TE.DESCRIPCION
                                                    ELSE 'ANTIGUO'
                                                 END TIPO_DE_INGRESO_LABEL,
                                                 E.CODIGO
                                          FROM   POSTGRADO.B_ESTUDIANTES E
                                          LEFT JOIN ADMISIONES.A_TIPO_ESTUDIANTE TE ON TE.TIPO = E.TIPO_DE_INGRESO
                                          WHERE      INDICADOR_PAGO IN ('P', 'V', 'W')
                                                 AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                                 AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD) B
                                GROUP BY TIPO_DE_INGRESO,
                                         TIPO_DE_INGRESO_LABEL) LOOP 
			V_ITEM := JSON();
			JSON.PUT (V_ITEM, 'key', AUXILIAR_RECORD.TIPO_DE_INGRESO);
			JSON.PUT (V_ITEM, 'label', AUXILIAR_RECORD.TIPO_DE_INGRESO_LABEL);
			JSON.PUT (V_ITEM, 'value', AUXILIAR_RECORD.NUMERO_DE_ESTUDIANTES);
			JSON_LIST.APPEND (V_ITEMS, V_ITEM.TO_JSON_VALUE);
        END LOOP;
		JSON.PUT (V_CHART, 'barChartItems', V_ITEMS);
		JSON_LIST.APPEND (V_CHARTS, V_CHART.TO_JSON_VALUE);

        -- SEGUNDA GRAFICA.
		V_CHART := JSON(); 
        JSON.PUT (V_CHART, 'label', 'Género');
        JSON.PUT (V_CHART, 'xAxisLabel', 'Género');
        JSON.PUT (V_CHART, 'yAxisLabel', 'Cantidad de estudiantes');
        V_ITEMS := JSON_LIST();
        -- ITERANDO SOBRE RESULTADOS DE BUSQUEDA.
        FOR AUXILIAR_RECORD IN (SELECT   SEXO, 
                                         COUNT(E.CODIGO) NUMERO_DE_ESTUDIANTES
                                FROM     POSTGRADO.B_ESTUDIANTES E
                                WHERE        INDICADOR_PAGO IN ('P', 'V', 'W')
                                         AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                         AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                GROUP BY SEXO) LOOP 
			V_ITEM := JSON();
			JSON.PUT (V_ITEM, 'key', AUXILIAR_RECORD.SEXO);
			JSON.PUT (V_ITEM, 'label', AUXILIAR_RECORD.SEXO);
			JSON.PUT (V_ITEM, 'value', AUXILIAR_RECORD.NUMERO_DE_ESTUDIANTES);
			JSON_LIST.APPEND (V_ITEMS, V_ITEM.TO_JSON_VALUE);
        END LOOP;
		JSON.PUT (V_CHART, 'barChartItems', V_ITEMS);
		JSON_LIST.APPEND (V_CHARTS, V_CHART.TO_JSON_VALUE);

        -- TERCERA GRAFICA.
		V_CHART := JSON(); 
        JSON.PUT (V_CHART, 'label', 'Tipo de Matricula');
        JSON.PUT (V_CHART, 'xAxisLabel', 'Tipo de Matricula');
        JSON.PUT (V_CHART, 'yAxisLabel', 'Cantidad de estudiantes');
        V_ITEMS := JSON_LIST();
        -- ITERANDO SOBRE RESULTADOS DE BUSQUEDA.
        FOR AUXILIAR_RECORD IN (SELECT     P.INDICADOR_PAGO,
                                           P.PERIODO, 
                                           COUNT(E.CODIGO) NUMERO_DE_ESTUDIANTES
                                FROM       POSTGRADO.B_ESTUDIANTES E
                                INNER JOIN POSTGRADO.CTI_PERIODO P ON E.INDICADOR_PAGO = P.INDICADOR_PAGO
                                WHERE          E.INDICADOR_PAGO IN ('P', 'V', 'W')
                                           AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                           AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                GROUP BY   P.INDICADOR_PAGO, 
                                           P.PERIODO) LOOP 
			V_ITEM := JSON();
			JSON.PUT (V_ITEM, 'key', AUXILIAR_RECORD.INDICADOR_PAGO);
			JSON.PUT (V_ITEM, 'label', AUXILIAR_RECORD.PERIODO);
			JSON.PUT (V_ITEM, 'value', AUXILIAR_RECORD.NUMERO_DE_ESTUDIANTES);
			JSON_LIST.APPEND (V_ITEMS, V_ITEM.TO_JSON_VALUE);
        END LOOP;
		JSON.PUT (V_CHART, 'barChartItems', V_ITEMS);
		JSON_LIST.APPEND (V_CHARTS, V_CHART.TO_JSON_VALUE);

        -- CUARTA GRAFICA.
		V_CHART := JSON(); 
        JSON.PUT (V_CHART, 'label', 'Plan de estudio');
        JSON.PUT (V_CHART, 'xAxisLabel', 'Plan de estudio');
        JSON.PUT (V_CHART, 'yAxisLabel', 'Cantidad de estudiantes');
        V_ITEMS := JSON_LIST();
        -- ITERANDO SOBRE RESULTADOS DE BUSQUEDA.
        FOR AUXILIAR_RECORD IN (SELECT     P.PLAN_ESTUDIO,
                                           P.DESCRIPCION,
                                           COUNT(E.CODIGO) NUMERO_DE_ESTUDIANTES
                                FROM       POSTGRADO.A_PLANES_DE_ESTUDIO P
                                INNER JOIN POSTGRADO.B_ESTUDIANTES E ON     E.CODIGO_FACULTAD = P.CODIGO_FACULTAD
                                                                        AND E.JORNADA_FACULTAD = P.JORNADA_FACULTAD 
                                                                        AND E.PLAN_ESTUDIO = P.PLAN_ESTUDIO 
                                WHERE          E.INDICADOR_PAGO IN ('P', 'V', 'W')
                                           AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                           AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                GROUP BY   P.PLAN_ESTUDIO, 
                                           P.DESCRIPCION) LOOP 
			V_ITEM := JSON();
			JSON.PUT (V_ITEM, 'key', AUXILIAR_RECORD.PLAN_ESTUDIO);
			JSON.PUT (V_ITEM, 'label', AUXILIAR_RECORD.DESCRIPCION);
			JSON.PUT (V_ITEM, 'value', AUXILIAR_RECORD.NUMERO_DE_ESTUDIANTES);
			JSON_LIST.APPEND (V_ITEMS, V_ITEM.TO_JSON_VALUE); 
        END LOOP;
		JSON.PUT (V_CHART, 'barChartItems', V_ITEMS);
		JSON_LIST.APPEND (V_CHARTS, V_CHART.TO_JSON_VALUE);

        -- IMPRESION JSON.
		JSON_LIST.HTP(V_CHARTS, FALSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);
	END GET_ESTUDIANTES_TIPO_ING;

    PROCEDURE GET_DETALLES_EST_TIPO_ING (
		P_CODIGO_FACULTAD VARCHAR2,
		P_JORNADA_FACULTAD VARCHAR2
    ) IS
		V_ESTUDIANTES JSON_LIST;
		V_ESTUDIANTE  JSON;        
		V_ERROR     JSON;
        v_periodo   varchar2(100) default null; --mariano rua mejia 11/08/2020
    BEGIN
        V_ESTUDIANTES := JSON_LIST();
        select unique b.anio||b.ciclo  --mariano rua mejia 11/08/2020
        into v_periodo
        from b_estudiantes b;
        -- ITERANDO SOBRE RESULTADOS DE BUSQUEDA.
        FOR AUXILIAR_RECORD IN ( SELECT     E.CODIGO,
                                           E.NOMBRE,
                                           NVL(BG.TOPE, 0) TOPE,
                                           NVL(BG.TOPE, 0) - NVL(BG.DISPONIBLES, 0) INSCRITOS,
                                           NVL(CE.CREDITOS, 0) ADICIONALES
                                FROM       POSTGRADO.B_ESTUDIANTES E
                                LEFT JOIN  POSTGRADO.CTI_BOLSA_GENERAL BG ON BG.CODIGO = E.CODIGO
                                           and bg.anio||bg.ciclo = e.anio||e.ciclo --mariano rua mejia 11/08/2020
                                LEFT JOIN  (SELECT     SUM(NUMERO_CREDITOS_ADICIONALES) CREDITOS,
                                                       CEA.CODIGO_ESTUDIANTE
                                            FROM       CTI_CRED_EXTRAS_AUTORIZACION CEA
                                            INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO GDP ON GDP.CODIGO_GUIA = CEA.CODIGO_GUIA
                                            WHERE      GDP.INDICADOR_PAGO = 'P'
                                            GROUP BY   CEA.CODIGO_ESTUDIANTE) CE ON CE.CODIGO_ESTUDIANTE = E.CODIGO
                                WHERE          E.INDICADOR_PAGO IN ('P', 'V', 'W')
                                           AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                                           AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                           AND E.ANIO||E.CICLO = V_PERIODO --mariano rua mejia 11/08/2020
                                ORDER BY   E.CODIGO) LOOP 
			V_ESTUDIANTE := JSON();
			JSON.PUT (V_ESTUDIANTE, 'codigo', AUXILIAR_RECORD.CODIGO);
			JSON.PUT (V_ESTUDIANTE, 'nombre', AUXILIAR_RECORD.NOMBRE);
			JSON.PUT (V_ESTUDIANTE, 'creditosMatriculados', AUXILIAR_RECORD.TOPE);
			JSON.PUT (V_ESTUDIANTE, 'creditosInscritos', AUXILIAR_RECORD.INSCRITOS);
			JSON.PUT (V_ESTUDIANTE, 'estado', CASE WHEN AUXILIAR_RECORD.TOPE = AUXILIAR_RECORD.INSCRITOS THEN 'Completo' ELSE 'Incompleto' END);
			JSON.PUT (V_ESTUDIANTE, 'creditosAdicionales', AUXILIAR_RECORD.ADICIONALES);
			JSON_LIST.APPEND (V_ESTUDIANTES, V_ESTUDIANTE.TO_JSON_VALUE);
        END LOOP;
		JSON_LIST.HTP(V_ESTUDIANTES, FALSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);
    END GET_DETALLES_EST_TIPO_ING;

    /*
    OBTIENE EL ESTADO DE LAS NOTAS PARA EL PERIODO ACTUAL.   
    @param P_CODIGO_FACULTAD VARCHAR2  => CODIGO FACULTAD.
    */
	PROCEDURE GET_ESTADO_NOTAS (
		P_CODIGO_FACULTAD VARCHAR2
	) IS
		V_BODY  JSON;
		V_ERROR JSON;
        TYPE TYP_REF_CUR IS REF CURSOR;
        TYPE TYPE_PROF IS RECORD
        (
          NOMPRO VARCHAR2(1000),
          APEDOC VARCHAR2(1000),
          NOMBRE VARCHAR2(1000)
        );
        TYPE TYPE_HORARIO IS RECORD
        (
            CODIGO_FACULTAD           VARCHAR2(1000),
            JORNADA_FACULTAD          VARCHAR2(1000),
            CODIGO_MATERIA            VARCHAR2(1000),
            GRUPO_MATERIA             VARCHAR2(1000),
            NOMBRE_PROFESOR           VARCHAR2(1000),
            LUNES                     VARCHAR2(1000),
            MARTES                    VARCHAR2(1000),
            MIERCOLES                 VARCHAR2(1000),
            JUEVES                    VARCHAR2(1000),
            VIERNES                   VARCHAR2(1000),
            SABADO                    VARCHAR2(1000),
            CUPO                      VARCHAR2(1000),
            PROFESOR_PRACTICA         VARCHAR2(1000),
            TEORIA_INTEGRADA          VARCHAR2(1000),
            FACINT                    VARCHAR2(1000),
            CODMATINT                 VARCHAR2(1000),
            GRUPINT                   VARCHAR2(1000),
            CUPO_UTILIZADO            VARCHAR2(1000),
            MATRICULADOS              VARCHAR2(1000),
            ABIERTO                   VARCHAR2(1000),
            TIPO_MATERIA              VARCHAR2(1000),
            NUMERO_DOCUMENTO          VARCHAR2(1000),
            APEDOC                    VARCHAR2(1000),
            NOMBRE                    VARCHAR2(1000),
            POR_TEORIA                VARCHAR2(1000),
            POR_PRACTICA              VARCHAR2(1000),
            SEDE                      VARCHAR2(1000),
            ANIO                      VARCHAR2(1000),
            CICLO                     VARCHAR2(1000),
            FECHA_INICIO_CLASES       VARCHAR2(1000),
            FECHA_INICIO_NOTAS        VARCHAR2(1000),
            FECHA_FIN_NOTAS           VARCHAR2(1000),
            SEMANAS                   VARCHAR2(1000),
            PLAN_ESTUDIO              VARCHAR2(1000),
            NOMBRE_MATERIA            VARCHAR2(1000),
            INTENSIDAD_HORARIA        VARCHAR2(1000),
            SEMESTRE                  VARCHAR2(1000),
            CREDITOS                  VARCHAR2(1000),
            ABREVIATURA_NOMBRE        VARCHAR2(1000),
            AREA                      VARCHAR2(1000),
            HOR_TRABAJO_INDEPENDIENTE VARCHAR2(1000),
            PLAN_CARACTER             VARCHAR2(1000),
            CONSECUTIVO               VARCHAR2(1000),
            GRAN_FACULTAD             VARCHAR2(1000),
            FECHA_FIN_CLASES          VARCHAR2(1000),
            FECHA                     VARCHAR2(1000),
            NUMERO_DOCUMENTO2         VARCHAR2(1000),
            INDICADOR_CIERRE          VARCHAR2(1000),
            APROBARON_DEF             VARCHAR2(1000),
            REPROBARON_DEF            VARCHAR2(1000),
            POR_APROBARON_DEF         VARCHAR2(1000),
            POR_REPROBARON_DEF        VARCHAR2(1000),
            FECHA_EXAMEN_FINAL        VARCHAR2(1000),
            FECHA_TERCER_INGRESO      VARCHAR2(1000)
        );  
        V_REF_CUR TYP_REF_CUR;
        V_REF_CUR2 TYP_REF_CUR;
        V_PROFE TYPE_PROF;
        V_DATOS TYPE_HORARIO;
        V_MATRICULADOS         NUMBER DEFAULT 0;
        V_MATRICULADOS_TOTALES NUMBER DEFAULT 0;
        V_APROBADOS_TOTALES    NUMBER DEFAULT 0;
        V_REPROBADOS_TOTALES   NUMBER DEFAULT 0;
	BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS();
		V_BODY := JSON();
        -- OBTENCION DE TODOS LOS DOCENTES POR FACULTAD E ITERACION SOBRE ELLOS.
        V_REF_CUR := POSTGRADO.PKG_NOTAS.PRC_GET_DOCENTES_CURSOR (P_CODIGO_FACULTAD); 
        LOOP
            FETCH V_REF_CUR INTO V_PROFE;
            EXIT WHEN V_REF_CUR%NOTFOUND;            
            -- OBTENCION DE TODOS LOS CURSOS POR DOCENTE E ITERACION SOBRE ELLOS.
            V_REF_CUR2 := POSTGRADO.PKG_NOTAS.PRC_GET_HORARIOS_CURSOR(P_CODIGO_FACULTAD, V_PROFE.APEDOC, V_PROFE.NOMBRE);
            LOOP 
                FETCH V_REF_CUR2 INTO V_DATOS;
                EXIT  WHEN  V_REF_CUR2%NOTFOUND;
                    -- OBTENCION DE NUMERO DE MATRICULADOS POR CURSO                    
                    SELECT COUNT (*)
                    INTO   V_MATRICULADOS
                    FROM   B_PREMATRICULA_NOTAS_DEPURADA INS
                    WHERE      INS.FACULTAD_CURSAR   = V_DATOS.CODIGO_FACULTAD 
                           AND INS.MATERIA_CURSAR    = V_DATOS.CODIGO_MATERIA 
                           AND TO_NUMBER (INS.GRUPO) = TO_NUMBER (V_DATOS.GRUPO_MATERIA) 
                           AND INS.INDICADOR_PAGO IN ('P', 'V', 'C');
                    -- SUMA DE ACUMULADOS.
                    V_MATRICULADOS_TOTALES := V_MATRICULADOS_TOTALES + V_MATRICULADOS;
                    V_APROBADOS_TOTALES    := V_APROBADOS_TOTALES + NVL(V_DATOS.APROBARON_DEF, '0');
                    V_REPROBADOS_TOTALES   := V_REPROBADOS_TOTALES + NVL(V_DATOS.REPROBARON_DEF, '0');
            END LOOP;
        END LOOP;
        JSON.PUT(V_BODY, 'estudiantesMatriculados', V_MATRICULADOS_TOTALES);
        JSON.PUT(V_BODY, 'estudiantesMatriculadosConNota', V_APROBADOS_TOTALES + V_REPROBADOS_TOTALES);
        JSON.PUT(V_BODY, 'estudiantesMatriculadosSinNota', V_MATRICULADOS_TOTALES - (V_APROBADOS_TOTALES + V_REPROBADOS_TOTALES));
        JSON.PUT(V_BODY, 'estudiantesAprobados', V_APROBADOS_TOTALES);
        JSON.PUT(V_BODY, 'estudiantesReprobados', V_REPROBADOS_TOTALES);
		JSON.HTP(V_BODY);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);
	END GET_ESTADO_NOTAS;

    /*
    OBTIENE DATOS ESTADISTICOS DE LAS NOTAS PARA EL PERIODO ACTUAL (DATOS DESTINADOS PARA SER 
    UTILIZADOS EN GRAFICA DE CAJA Y BIGOTES):
        - CUARTILES 1, 2(MEDIANA) Y 3.
        - MEDIA.
        - VALORES MAXIMOS Y MINIMOS.
        - OUTLIERS.
    @param P_CODIGO_FACULTAD VARCHAR2
    @param P_JORNADA_FACULTAD VARCHAR2
    */
	PROCEDURE GET_ESTADISTICAS_NOTAS (
		P_CODIGO_FACULTAD VARCHAR2,
		P_JORNADA_FACULTAD VARCHAR2
	) IS
		V_BODY                    JSON_LIST;
		V_ERROR                   JSON;
        V_DATA_SET                TABLE_DATA_SET;
	BEGIN
        POSTGRADO.PKG_HTML.CORSHEADERS();
		V_BODY := JSON_LIST(); 
        -- OBTENIENDO PRIMER DATA SET.
        SELECT     REGISTRO_DATA_ITEM(PND.DEFINITIVA) BULK COLLECT
        INTO       V_DATA_SET
        FROM       POSTGRADO.B_PREMATRICULA_NOTAS_DEPURADA PND
        INNER JOIN POSTGRADO.B_ESTUDIANTES E ON E.CODIGO = PND.CODIGO_ESTUDIANTE
        WHERE          PND.DEFINITIVA IS NOT NULL;
        JSON_LIST.APPEND (V_BODY, GET_ESTADISTICAS_DATA_SET('Total universidad', V_DATA_SET).TO_JSON_VALUE);
        -- OBTENIENDO SEGUNDO DATA SET.
        SELECT     REGISTRO_DATA_ITEM(PND.DEFINITIVA) BULK COLLECT
        INTO       V_DATA_SET
        FROM       POSTGRADO.B_PREMATRICULA_NOTAS_DEPURADA PND
        INNER JOIN POSTGRADO.B_ESTUDIANTES E ON E.CODIGO = PND.CODIGO_ESTUDIANTE
        WHERE          PND.DEFINITIVA IS NOT NULL
                   AND E.CODIGO_FACULTAD  = P_CODIGO_FACULTAD
                   AND E.JORNADA_FACULTAD = P_JORNADA_FACULTAD;
        JSON_LIST.APPEND (V_BODY, GET_ESTADISTICAS_DATA_SET('Total programa', V_DATA_SET).TO_JSON_VALUE);
		JSON_LIST.HTP(V_BODY, FALSE);
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            JSON.HTP(V_ERROR);
	END GET_ESTADISTICAS_NOTAS;

    /*
    OBTIENE DATOS ESTADISTICOS DE UN DATA SET
        - CUARTILES 1, 2(MEDIANA) Y 3.
        - MEDIA.
        - VALORES MAXIMOS Y MINIMOS.
        - OUTLIERS.    
    @param P_NOMBRE_DATA_SET VARCHAR => Nombre del Data Set.
    @param P_DATA_SET TABLE_DATA_SET => Valores del Data Set.
    @return  
    */
	FUNCTION GET_ESTADISTICAS_DATA_SET(
        P_NOMBRE_DATA_SET VARCHAR,
        P_DATA_SET TABLE_DATA_SET
	) RETURN JSON IS
		V_BODY                    JSON;
		V_ERROR                   JSON;
		V_OUTLIERS                JSON_LIST;
        V_LIMITE_INFERIOR_OUTLIER NUMBER;
        V_MINIMO                  NUMBER;
        V_PRIMER_CUARTIL          NUMBER;
        V_MEDIANA                 NUMBER;
        V_TERCER_CUARTIL          NUMBER;
        V_MAXIMO                  NUMBER;
        V_LIMITE_SUPERIOR_OUTLIER NUMBER;
        V_MEDIA                   NUMBER;
	BEGIN
		V_BODY := JSON(); 
		V_OUTLIERS := JSON_LIST(); 
        -- CALCULO DE MINIMOS Y MAXIMOS DE OUTLIERS, CUARTILES, MEDIANA Y MEDIA.
        SELECT PRIMER_CUARTIL - 1.5 * (TERCER_CUARTIL - PRIMER_CUARTIL) LIMITE_INFERIOR_OUTLIER,
               PRIMER_CUARTIL,
               SEGUNDO_CUARTIL,
               TERCER_CUARTIL,
               TERCER_CUARTIL + 1.5 * (TERCER_CUARTIL - PRIMER_CUARTIL) LIMITE_SUPERIOR_OUTLIER,
               MEDIA
        INTO   V_LIMITE_INFERIOR_OUTLIER,
               V_PRIMER_CUARTIL,
               V_MEDIANA,
               V_TERCER_CUARTIL,
               V_LIMITE_SUPERIOR_OUTLIER,
               V_MEDIA               
        FROM   (SELECT   MEDIAN (CASE
                                      WHEN VALOR < MEDIANA THEN VALOR
                                 END) PRIMER_CUARTIL, 
                         MEDIANA SEGUNDO_CUARTIL,
                         MEDIAN (CASE
                                      WHEN VALOR > MEDIANA THEN VALOR
                                END) TERCER_CUARTIL, 
                         AVG(VALOR) MEDIA
                FROM     (SELECT     VALOR,
                                     MEDIAN(VALOR) OVER () MEDIANA
                          FROM       TABLE(P_DATA_SET))
                GROUP BY MEDIANA);
        -- CALCULANDO VALOR MINIMO QUE NO SEA CONSIDERADO UN OUTLIER.
        SELECT     MIN(VALOR)
        INTO       V_MINIMO
        FROM       TABLE(P_DATA_SET)
        WHERE          VALOR >= V_LIMITE_INFERIOR_OUTLIER
                   AND VALOR IS NOT NULL;
        -- CALCULANDO VALOR MAXIMO QUE NO SEA CONSIDERADO UN OUTLIER.
        SELECT     MAX(VALOR)
        INTO       V_MAXIMO
        FROM       TABLE(P_DATA_SET)
        WHERE          VALOR <= V_LIMITE_SUPERIOR_OUTLIER
                   AND VALOR IS NOT NULL;
        -- ENCONTRANDO LOS OUTLIERS TANTO INFERIORES COMO SUPERIORES.
        FOR OUTLIER IN (SELECT     VALOR
                        FROM       TABLE(P_DATA_SET)
                        WHERE          VALOR IS NOT NULL
                                   AND (   VALOR < V_LIMITE_INFERIOR_OUTLIER
                                        OR VALOR > V_LIMITE_SUPERIOR_OUTLIER)) LOOP 
            -- AGREGAMOS OUTLIER A LA LISTA.
            JSON_LIST.APPEND (V_OUTLIERS, OUTLIER.VALOR);
        END LOOP;
        JSON.PUT(V_BODY, 'nombreDataSet', P_NOMBRE_DATA_SET);
        JSON.PUT(V_BODY, 'valorMinimo', V_MINIMO);
        JSON.PUT(V_BODY, 'primerCuartil', V_PRIMER_CUARTIL);
        JSON.PUT(V_BODY, 'mediana', V_MEDIANA);
        JSON.PUT(V_BODY, 'tercerCuartil', V_TERCER_CUARTIL);
        JSON.PUT(V_BODY, 'valorMaximo', V_MAXIMO);  
        JSON.PUT(V_BODY, 'outliers', V_OUTLIERS); 
        RETURN V_BODY;
    EXCEPTION 
        WHEN OTHERS THEN
            V_ERROR := JSON (); 
            JSON.PUT (V_ERROR, 'status', 'Error');
            JSON.PUT (V_ERROR, 'message', SQLCODE || ' --- ' || SUBSTR (SQLERRM, 1, 200));
            RETURN V_ERROR;        
	END GET_ESTADISTICAS_DATA_SET;
END PKG_CTI_DASHBOARD_POSGRADOS;