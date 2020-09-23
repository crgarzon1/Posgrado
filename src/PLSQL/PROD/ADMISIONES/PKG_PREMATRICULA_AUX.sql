create or replace package body PKG_PREMATRICULA_AUX
as


-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE LOS GRUPOS DE ACUERDO AL CONSECUTIVO. DEVUELVE UN OBJETO JSON.
-- ****************************************************************************************************************************
	PROCEDURE GRUPO_JSON_OBJECT(
		P_JSON_OBJECT OUT JSON,
		P_CONSECUTIVO IN INTEGER,
		P_ELIMINABLE  IN INTEGER,
		P_YOPAL       IN INTEGER DEFAULT 0)
	AS
		V_CONSECUTIVO	 		NUMBER;
		V_COD_FACU   	 		VARCHAR2(4);
		V_FACU       	 		VARCHAR2(128);
		V_SEDE       			VARCHAR2(64);
		V_COD_MATE   	 		VARCHAR2(8);
		V_MATE       	 		VARCHAR2(128);
		V_GRUPO      	 		NUMBER;
		V_CUPO       			NUMBER;
		V_DISPONIBLE 			NUMBER;
		V_I           			NUMBER DEFAULT 1;
		V_J            			NUMBER DEFAULT 1;
        V_ISCANCELADO   		VARCHAR2(2) DEFAULT NULL;
		P_JSON_AUXILIAR1 		JSON;
		P_JSON_AUXILIAR2 		JSON;
        P_JSON_AUXILIAR1_LIST   JSON_LIST;
        P_JSON_AUXILIAR2_LIST   JSON_LIST; 
        V_INDICADOR_ESQUEMA     NUMBER;
        V_INDICADOR_PREGRADO    NUMBER DEFAULT 1;
        V_INDICADOR_POSTGRADO   NUMBER DEFAULT 2;
        V_INDICADOR_YOPAL       NUMBER DEFAULT 3;
        v_anio          varchar2(4) default null;
        v_ciclo         varchar2(2) default null;
        v_esquema       varchar2(256) default null;
        v_tipo_prg      number default 1;
	BEGIN
		BEGIN
			P_JSON_OBJECT := JSON();
			IF P_CONSECUTIVO <= 0 THEN
				RETURN;
			END IF;
			IF P_YOPAL <= 0 THEN
				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_PREGRADO
				INTO 		V_CONSECUTIVO,
							V_COD_FACU,
							V_FACU,
							V_SEDE,
							V_COD_MATE,
							V_MATE,
							V_GRUPO,
							V_CUPO,
							V_DISPONIBLE,
							V_ISCANCELADO,
                            V_INDICADOR_ESQUEMA
				FROM 		A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_PREGRADO
				FROM 		CACTUALPRE.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO    = P_CONSECUTIVO

				UNION

				SELECT		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_POSTGRADO
				FROM 		POSTGRADO.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_POSTGRADO
				FROM 		CACTUALPOS.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE		AH.CONSECUTIVO = P_CONSECUTIVO;
			ELSE
				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_YOPAL
				INTO 		V_CONSECUTIVO,
							V_COD_FACU,
							V_FACU,
							V_SEDE,
							V_COD_MATE,
							V_MATE,
							V_GRUPO,
							V_CUPO,
							V_DISPONIBLE,
							V_ISCANCELADO,
                            V_INDICADOR_ESQUEMA
				FROM 		YOPAL.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	YOPAL.A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
											     AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO,
                            V_INDICADOR_YOPAL
				FROM		CACTUALYOP.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	YOPAL.A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
												 AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO;
			END IF;
		EXCEPTION
		WHEN OTHERS THEN
            P_JSON_OBJECT := NULL;
			RETURN;
		END;

        P_JSON_AUXILIAR1_LIST := JSON_LIST();
        IF (V_ISCANCELADO NOT IN ('S')) THEN
			JSON.PUT(P_JSON_OBJECT, 'cancelado', '1');
        END IF;
		JSON.PUT(P_JSON_OBJECT, 'consecutivo', V_CONSECUTIVO);
		JSON.PUT(P_JSON_OBJECT, 'grupo', V_GRUPO);
		JSON.PUT(P_JSON_OBJECT, 'cupo', V_CUPO);
		JSON.PUT(P_JSON_OBJECT, 'cupoDisponible', V_DISPONIBLE);
		JSON.PUT(P_JSON_OBJECT, 'eliminable', P_ELIMINABLE);

		P_JSON_AUXILIAR2 := JSON();
		JSON.PUT(P_JSON_AUXILIAR2, 'sede', V_SEDE);

		P_JSON_AUXILIAR1 := JSON();
		JSON.PUT(P_JSON_AUXILIAR1, 'codFacultad', V_COD_FACU);
		JSON.PUT(P_JSON_AUXILIAR1, 'nombreFacultad', TRIM(V_FACU));
		JSON.PUT(P_JSON_AUXILIAR1, 'sede', P_JSON_AUXILIAR2);
		JSON.PUT(P_JSON_OBJECT, 'facultadCursar', P_JSON_AUXILIAR1);

        IF V_COD_FACU = '46' THEN
            V_TIPO_PRG := 4;
        ELSIF V_COD_FACU < '71' THEN
            V_TIPO_PRG := 1;
        ELSIF V_COD_FACU >= '71' THEN
            V_TIPO_PRG := 2;
        END IF;
        PKG_UTILS.GETANIOCICLOESQUEMA(V_TIPO_PRG, V_ANIO, V_CICLO, V_ESQUEMA);

		P_JSON_AUXILIAR1 := JSON();
		JSON.PUT(P_JSON_AUXILIAR1, 'codMateria', V_COD_MATE); 
		JSON.PUT(P_JSON_AUXILIAR1, 'nombreMateria',  V_MATE);
		JSON.PUT(P_JSON_AUXILIAR1, 'syllabus', 'http://apps.lasalle.edu.co/Syllabus-web/VerSyllabusPrematricula?token=' 
        || xamplecripto(
            TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
            || ';XX;'
            || V_COD_FACU || ';'
            || V_COD_MATE || ';'
            || TRIM(to_char(V_GRUPO, '00')) || ';' 
            || v_anio || ';' 
            || v_ciclo,'3764613438353137'));
		JSON.PUT(P_JSON_OBJECT, 'materiaCursar', P_JSON_AUXILIAR1);


        IF(V_INDICADOR_ESQUEMA = V_INDICADOR_POSTGRADO) THEN
            JSON.PUT(P_JSON_OBJECT, 'horario', GET_HORARIO_POSTGRADO(V_CONSECUTIVO));
        ELSE
            JSON.PUT(P_JSON_OBJECT, 'horario', GET_HORARIO_PREGRADO(V_CONSECUTIVO));
        END IF;
	EXCEPTION
	WHEN OTHERS THEN
		JSON.PUT(P_JSON_OBJECT, 'exception',  SQLCODE || ' - grupo - ' || SQLERRM || ': ' || P_CONSECUTIVO);
	END GRUPO_JSON_OBJECT;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE HORARIO PARA MATERIAS DE PREGRADO. LO OBTIENE DE A_HORARIO_VERTICAL
-- ****************************************************************************************************************************
    FUNCTION GET_HORARIO_PREGRADO(
		P_CONSECUTIVO NUMBER
    ) RETURN JSON_LIST IS
		P_JSON_AUXILIAR1 		JSON;
		P_JSON_AUXILIAR2 		JSON;
        P_JSON_AUXILIAR1_LIST   JSON_LIST;
        P_JSON_AUXILIAR2_LIST   JSON_LIST;
		V_I           			NUMBER DEFAULT 1;
		V_J            			NUMBER DEFAULT 1;
    BEGIN
        P_JSON_AUXILIAR1_LIST := JSON_LIST();
		FOR DIA IN
			(
				SELECT 		X.DIA,
							X.DTXT,
							COUNT(*) OVER () TOT_ROWS
				FROM 		(
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				A_HORARIO_VERTICAL
								WHERE 				CONSECUTIVO = P_CONSECUTIVO
								UNION
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				CACTUALPRE.A_HORARIO_VERTICAL
								WHERE CONSECUTIVO = P_CONSECUTIVO
							) X
				ORDER BY X.DIA
			) LOOP
			P_JSON_AUXILIAR1 := JSON();
			P_JSON_AUXILIAR2_LIST := JSON_LIST();
			JSON.PUT(P_JSON_AUXILIAR1, 'idDia', (DIA.DIA - 1));
			JSON.PUT(P_JSON_AUXILIAR1, 'dia', DIA.DTXT);
			V_I := 1;
			FOR HR IN
				(
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM		A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO, 
								SALON
					UNION
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM 		CACTUALPRE.A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO, 
								SALON
				) LOOP
				P_JSON_AUXILIAR2 := JSON();
				JSON.PUT(P_JSON_AUXILIAR2, 'inicio', TRIM(HR.HMIN) || ':00');
				JSON.PUT(P_JSON_AUXILIAR2, 'fin', TRIM(HR.HMAX) || ':00');
				JSON.PUT(P_JSON_AUXILIAR2, 'practica', HR.TIPO);
				JSON.PUT(P_JSON_AUXILIAR2, 'salon', HR.SALON);				
				JSON_LIST.APPEND(P_JSON_AUXILIAR2_LIST, P_JSON_AUXILIAR2.TO_JSON_VALUE);
				V_I := V_I + 1;
			END LOOP;
			JSON.PUT(P_JSON_AUXILIAR1, 'hora', P_JSON_AUXILIAR2_LIST);
			V_J := V_J + 1;

            JSON_LIST.APPEND(P_JSON_AUXILIAR1_LIST, P_JSON_AUXILIAR1.TO_JSON_VALUE);
		END LOOP;
		RETURN P_JSON_AUXILIAR1_LIST;
    END;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE HORARIO PARA MATERIAS DE POSTGRADO. LO OBTIENE DE A_HORARIO_HORIZONTAL.
-- ****************************************************************************************************************************
    FUNCTION GET_HORARIO_POSTGRADO(
		P_CONSECUTIVO NUMBER
    ) RETURN JSON_LIST IS
		P_JSON_AUXILIAR1 		JSON;
		P_JSON_AUXILIAR2 		JSON;
        P_JSON_AUXILIAR1_LIST   JSON_LIST;
        P_JSON_AUXILIAR2_LIST   JSON_LIST;
        V_DIA               VARCHAR2(20) DEFAULT NULL;
        HORARIO_SERIALIZADO VARCHAR2(4); 
        HORA_INICIO         NUMBER; 
        HORA_FIN            NUMBER;   
    BEGIN
        P_JSON_AUXILIAR1_LIST := JSON_LIST();
		FOR HORARIO IN (SELECT     DISTINCT TRIM(TO_CHAR(TRIM(REPLACE(HORARIO, 'P', '')), '000000000000')) HORARIO_SERIALIZADO, 
                                   DIA,
                                   ID_DIA
                        FROM       POSTGRADO.A_HORARIO_HORIZONTAL
                        INNER JOIN (SELECT CONSECUTIVO, TRIM(LUNES) HORARIO, 'lunes' DIA, '1' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(MARTES) HORARIO, 'martes' DIA, '2' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(MIERCOLES) HORARIO, 'miercoles' DIA, '3' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(JUEVES) HORARIO, 'jueves' DIA, '4' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(VIERNES) HORARIO, 'viernes' DIA, '5' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(SABADO) HORARIO, 'sabado'DIA, '6' ID_DIA FROM POSTGRADO.A_HORARIO_HORIZONTAL) HORARIO ON A_HORARIO_HORIZONTAL.CONSECUTIVO = HORARIO.CONSECUTIVO
                        WHERE           A_HORARIO_HORIZONTAL.CONSECUTIVO = P_CONSECUTIVO
                                    AND HORARIO IS NOT NULL
                        UNION
                        SELECT     DISTINCT TRIM(TO_CHAR(TRIM(REPLACE(HORARIO, 'P', '')), '000000000000')) HORARIO_SERIALIZADO, 
                                   DIA,
                                   ID_DIA
                        FROM       CACTUALPOS.A_HORARIO_HORIZONTAL
                        INNER JOIN (SELECT CONSECUTIVO, TRIM(LUNES) HORARIO, 'lunes' DIA, '1' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(MARTES) HORARIO, 'martes' DIA, '2' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(MIERCOLES) HORARIO, 'miercoles' DIA, '3' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(JUEVES) HORARIO, 'jueves' DIA, '4' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(VIERNES) HORARIO, 'viernes' DIA, '5' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL
                                    UNION
                                    SELECT CONSECUTIVO, TRIM(SABADO) HORARIO, 'sabado'DIA, '6' ID_DIA FROM CACTUALPOS.A_HORARIO_HORIZONTAL) HORARIO ON A_HORARIO_HORIZONTAL.CONSECUTIVO = HORARIO.CONSECUTIVO
                        WHERE           A_HORARIO_HORIZONTAL.CONSECUTIVO = P_CONSECUTIVO
                                    AND HORARIO IS NOT NULL)
        LOOP 
			P_JSON_AUXILIAR1 := JSON();
			P_JSON_AUXILIAR2_LIST := JSON_LIST();
			JSON.PUT(P_JSON_AUXILIAR1, 'idDia', HORARIO.ID_DIA - 1);
			JSON.PUT(P_JSON_AUXILIAR1, 'dia', HORARIO.DIA);

            FOR V_INDEX IN 0..2
            LOOP
                HORARIO_SERIALIZADO := SUBSTR(HORARIO.HORARIO_SERIALIZADO, V_INDEX * 4 + 1, 4);

                IF(HORARIO_SERIALIZADO != '0000') THEN
                    HORA_INICIO := TO_NUMBER(SUBSTR(HORARIO_SERIALIZADO, 1, 2));
                    HORA_FIN := TO_NUMBER(SUBSTR(HORARIO_SERIALIZADO, 3, 2));

                    P_JSON_AUXILIAR2 := JSON();
                    JSON.PUT(P_JSON_AUXILIAR2, 'inicio', HORA_INICIO || ':00');
                    JSON.PUT(P_JSON_AUXILIAR2, 'fin', HORA_FIN|| ':00');	
				JSON.PUT(P_JSON_AUXILIAR2, 'practica', '');
				JSON.PUT(P_JSON_AUXILIAR2, 'salon', '');						
                    JSON_LIST.APPEND(P_JSON_AUXILIAR2_LIST, P_JSON_AUXILIAR2.TO_JSON_VALUE);
                END IF;
            END LOOP;
			JSON.PUT(P_JSON_AUXILIAR1, 'hora', P_JSON_AUXILIAR2_LIST);
            JSON_LIST.APPEND(P_JSON_AUXILIAR1_LIST, P_JSON_AUXILIAR1.TO_JSON_VALUE);
        END LOOP;
		RETURN P_JSON_AUXILIAR1_LIST;
    END;
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE MATERIAS, HORARIO, NOTAS Y FALLAS DE PREMATRICULA.
-- ****************************************************************************************************************************
    PROCEDURE PREMATRICULA (
        P_CODIGO   		VARCHAR2,
        P_ANIO     		VARCHAR2,
		P_CICLO    		VARCHAR2,
        P_TIPO     		NUMBER DEFAULT 0,
		P_MOSTRAR_NOTAS NUMBER DEFAULT 0
    ) AS

        TYPE T_OFERTA IS REF CURSOR;
        TYPE CUR_TYP IS REF CURSOR;
		-- JSON VARIABLES.
        V_CODIGO_CONTRARIO       VARCHAR2(50);
        V_JSON_BODY              JSON;
        V_JSON_MATERIAS          JSON_LIST;
        V_JSON_MATERIA           JSON;
		V_JSON_NOTAS_FALLAS		 JSON;
        V_JSON_GRUPOS          	 JSON_LIST;
		V_JSON_GRUPO			 JSON;
        V_OFERTA                 T_OFERTA;
		V_OPCION_NO_VALIDA       NUMBER DEFAULT 0;
        V_COD_MATE               VARCHAR2(8);
        V_SEMESTRE               NUMBER;
        V_CREDITOS         		 NUMBER;
		V_IHORARIA               NUMBER;
		V_MATERIA          		 VARCHAR2(256);
		V_CONSECUTIVO            NUMBER;
        V_POST                   NUMBER;
		V_PROPIA                 NUMBER;
		V_COD_MATE_ACT           VARCHAR2(8) DEFAULT 'X';
        V_COD_FACU               VARCHAR2(8);
		V_FACU                   VARCHAR2(256);
        V_JORNADA_FACU           VARCHAR2(4);
		V_SEDE                   VARCHAR2(68);
        V_AL_MENOS_UNO           NUMBER DEFAULT 0;
        V_ISPOSTGRADO            NUMBER DEFAULT 0;
		V_ISCANCELADO            VARCHAR2(2) DEFAULT NULL;
        V_INDPAGO                VARCHAR2(2) DEFAULT NULL;
		V_COD_EST          		 VARCHAR2(8);
        V_ANIO                   VARCHAR2 (4);
        V_CICLO                  VARCHAR2(2);
        V_ESQUEMA                VARCHAR2(32);
		V_SELECT_FILLED 		 VARCHAR2 (4000);
        V_SELECT                 VARCHAR2(4000);
        V_NOTA_UNICA             NUMBER DEFAULT 0;
		V_PREMATRICULA_DEP       NUMBER DEFAULT 0;
        V_DEFINITIVA			 NUMBER(3, 1);
        V_NOTA_PRIMER_CORTE      NUMBER(3, 1);
        V_NOTA_SEGUNDO_CORTE     NUMBER(3, 1);
        V_NOTA_TERCER_CORTE      NUMBER(3, 1);
        V_FALLAS_PRIMER_CORTE    NUMBER(3, 1);
        V_FALLAS_SEGUNDO_CORTE   NUMBER(3, 1);
		V_FALLAS_TERCER_CORTE    NUMBER(3,1);
		V_FALLAS_TOTALES	     NUMBER(3,1);
        V_COLUMNA_VALIDA         NUMBER;
		V_ENC_PLAN_ESTRA		 NUMBER DEFAULT 0;
        C                        CUR_TYP;
        V_ANIO_C                 VARCHAR2(4);
        V_CICLO_C                VARCHAR2(2);
        V_ESQUEMA_C              VARCHAR2(32);
    BEGIN
        V_JSON_BODY := JSON();
        V_JSON_MATERIAS := JSON_LIST();

		-- SE VERIFICA SI EL CODIGO DEL ESTUDIANTE ACTUAL CORRESPONDE A UN PROGRAMA DE PREGRADO, POSGRADO O YOPAL (PREGRADO POR DEFECTO).
        IF SUBSTR(P_CODIGO, 0, 2) >= '71' THEN
			-- POSTGRADO.
            V_ISPOSTGRADO := 1;
        ELSIF SUBSTR(P_CODIGO, 0, 2) IN (
            '46'
        ) THEN
			-- YOPAL.
            V_ISPOSTGRADO := 2;
		END IF;

        SELECT NVL(B_PREMATRICULA_SPRING.F_GET_CODIGO_CONTRARIO(P_CODIGO, P_ANIO, P_CICLO), 'abcdefgh')
        INTO V_CODIGO_CONTRARIO
        FROM DUAL;

		--SI ES PREGRADO.
		---------------------------------------------------------------------------------------------------------------------------------
        IF (V_ISPOSTGRADO = 0) THEN
            PKG_UTILS.GETANIOCICLOESQUEMA('1', V_ANIO_C, V_CICLO_C, V_ESQUEMA_C);
           SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
            INTO        V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
            FROM 		B_ESTUDIANTES E
			INNER JOIN  A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
                                       AND E.JORNADA_FACULTAD = F.JORNADA 
            WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR 
                q'!
                -- ADMISIONES: INFORMACION ESTUDIANTE ACTUAL.
                SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN (P.FACULTAD_CURSAR >= '71') THEN
									1 
								ELSE 
									0
							END POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM		ADMISIONES.B_ESTUDIANTES E
				INNER JOIN 	!' || V_ESQUEMA_C || q'!.B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                             AND E.ANIO   = P.ANIO
                                             AND E.CICLO  = P.CICLO 
				INNER JOIN 	ADMISIONES.A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
										 AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
										 AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
				WHERE 			E.CODIGO = :codigoEstudiante
                            AND E.ANIO   = :ano
                            AND E.CICLO  = :ciclo
                            AND ESTA_MATRICULADO(E.INDICADOR_PAGO) = '1'

				UNION

				-- ADMISIONES: INFORMACION ESTUDIANTE CODIGO ALTERNO (DOBLE PROGRAMA).
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
                            M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN P.FACULTAD_CURSAR >= '71' THEN
									1
								ELSE
									 0
							END POSTGRADUAL,
							0 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM		ADMISIONES.B_ESTUDIANTES E
				INNER JOIN 	!' || V_ESQUEMA_C || q'!.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE
                                             AND E.ANIO  = P.ANIO
                                             AND E.CICLO = P.CICLO 
				INNER JOIN 	ADMISIONES.A_MATERIAS M ON M.CODIGO            = P.MATERIA_PLAN
                                         AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                         AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
				WHERE   		E.CODIGO = :codigoContrario
                            AND E.ANIO   = :ano
                            AND E.CICLO  = :ciclo
                            AND ESTA_MATRICULADO(E.INDICADOR_PAGO) = '1'
                ORDER BY 1!' USING P_CODIGO, P_ANIO, P_CICLO, V_CODIGO_CONTRARIO, P_ANIO, P_CICLO;

		--SI ES POSTGRADO
		---------------------------------------------------------------------------------------------------------------------------------
        ELSIF (V_ISPOSTGRADO = 1) THEN
            PKG_UTILS.GETANIOCICLOESQUEMA('2', V_ANIO_C, V_CICLO_C, V_ESQUEMA_C);
			SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
			INTO 		V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
			FROM 		POSTGRADO.B_ESTUDIANTES E
			INNER JOIN  A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
									   AND E.JORNADA_FACULTAD = F.JORNADA
			WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR
                q'!			
				-- POSTGRADO: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							NVL((
								SELECT		TO_NUMBER(HH.CONSECUTIVO)
								FROM		!' || V_ESQUEMA_C || q'!.A_HORARIO_HORIZONTAL HH
								WHERE       	HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
							), 0) ID_CURSO,
							0 POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM        POSTGRADO.B_ESTUDIANTES E
				INNER JOIN  !' || V_ESQUEMA_C || q'!.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE
                                                       AND E.ANIO  = P.ANIO
                                                       AND E.CICLO = P.CICLO 
                INNER JOIN POSTGRADO.A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
                                                  AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                                  AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
                                                  AND (	  M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
													  OR (	 E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME')
											             AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO))) 
				WHERE   		E.CODIGO = :codigoEstudiante
                            AND E.ANIO   = :ano
                            AND E.CICLO  = :ciclo
                            AND ESTA_MATRICULADO(E.INDICADOR_PAGO) = '1'
                UNION

                SELECT     M.CODIGO,
						   TO_NUMBER(M.SEMESTRE) SEM,
						   M.CREDITOS,
						   M.INTENSIDAD_HORARIA,
						   '(Electiva) ' || M.NOMBRE AS NOMBRE,
						   NVL((
								SELECT		TO_NUMBER(HH.CONSECUTIVO)
								FROM		POSTGRADO.A_HORARIO_HORIZONTAL HH
								WHERE       	HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
                           ), 0) ID_CURSO,
						   0 POSTGRADUAL,
						   1 PROPIA,
						   P.INDICADOR_REGLAMENTO,
						   P.INDICADOR_PAGO,
						   E.CODIGO
                FROM       POSTGRADO.B_ESTUDIANTES E 
                INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
				INNER JOIN POSTGRADO.B_PREMATRICULA P ON     E.CODIGO = P.CODIGO_ESTUDIANTE
                                                         AND E.ANIO  = P.ANIO
                                                         AND E.CICLO = P.CICLO 
                INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON     BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                                                              AND BEM.CODIGO_MATERIA   = P.MATERIA_CURSAR
                                                              AND BEM.CODIGO_FACULTAD  = P.FACULTAD_CURSAR
                                                              AND BEM.JORNADA_FACULTAD = P.JORNADA_FACULTAD
                -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = BEM.CODIGO_MATERIA
                                                     AND M.PLAN_ESTUDIO     = BEM.PLAN_ESTUDIO
                                                     AND M.CODIGO_FACULTAD  = BEM.CODIGO_FACULTAD
                                                     AND M.JORNADA_FACULTAD = BEM.JORNADA_FACULTAD
                WHERE      E.CODIGO = :codigoEstudiante
                            AND ESTA_MATRICULADO(E.INDICADOR_PAGO) = '1'
                ORDER BY 1!' USING P_CODIGO, P_ANIO, P_CICLO, P_CODIGO;

		--SI ES YOPAL
		---------------------------------------------------------------------------------------------------------------------------------
		ELSIF V_ISPOSTGRADO = 2 THEN
            PKG_UTILS.GETANIOCICLOESQUEMA('4', V_ANIO_C, V_CICLO_C, V_ESQUEMA_C);
            SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
            INTO 		V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
            FROM 		YOPAL.B_ESTUDIANTES   E
			INNER JOIN 	A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
                                       AND E.JORNADA_FACULTAD = F.JORNADA
            WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR 
                q'!			
				-- YOPAL: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							NVL((
								SELECT 		TO_NUMBER(HH.CONSECUTIVO)
								FROM 		YOPAL.A_HORARIO_HORIZONTAL HH
								WHERE 		    HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
							), 0) ID_CURSO,
							0 POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM 		YOPAL.B_ESTUDIANTES E
				INNER JOIN YOPAL.B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                                  AND E.ANIO   = P.ANIO
                                                  AND E.CICLO  = P.CICLO
				INNER JOIN YOPAL.A_MATERIAS M ON  M.CODIGO = P.MATERIA_PLAN
                                              AND M.CODIGO_FACULTAD = E.CODIGO_FACULTAD
											  AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
											  AND (   M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
											      OR (   E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME') 
												     AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)))
				WHERE   		E.CODIGO = :codigoEstudiante
                            AND E.ANIO   = :ano
                            AND E.CICLO  = :ciclo
                            AND ESTA_MATRICULADO(E.INDICADOR_PAGO) = '1'
                ORDER BY 1!' USING P_CODIGO, P_ANIO, P_CICLO;
        END IF;

        SELECT SUM (A)
		INTO V_ENC_PLAN_ESTRA
        FROM (SELECT COUNT (*) A
              FROM (SELECT SIIS.VALIDAR_CONSULTA_ESTUDIANTE@UVIRTUAL.LASALLE.EDU.CO (P_CODIGO) A
                    FROM DUAL T
                   )
              WHERE A != 'S'
              UNION ALL
              SELECT COUNT (*) A
              FROM SIE.SIE_VW_ENCU_AUTO_PRE_SALL_ESTU@UVIRTUAL.LASALLE.EDU.CO
              WHERE CODIGO = P_CODIGO
                    AND CONTESTO = 'NO'
              UNION ALL
              SELECT FALTA_ENCUESTA_SATISFACCION (P_CODIGO) A
              FROM DUAL
        );

        JSON.PUT(V_JSON_BODY, 'codFacultad', V_COD_FACU);
        JSON.PUT(V_JSON_BODY, 'nombreFacultad', TRIM(V_FACU));
        JSON.PUT(V_JSON_BODY, 'jornadaFacultad', V_JORNADA_FACU);
        LOOP
            FETCH V_OFERTA INTO
                V_COD_MATE,
                V_SEMESTRE,
                V_CREDITOS,
                V_IHORARIA,
                V_MATERIA,
                V_CONSECUTIVO,
                V_POST,
                V_PROPIA,
                V_ISCANCELADO,
                V_INDPAGO,
                V_COD_EST;

            EXIT WHEN V_OFERTA%NOTFOUND;
            IF ( V_COD_MATE <> V_COD_MATE_ACT ) THEN
                V_JSON_MATERIA := JSON();
				V_JSON_GRUPOS := JSON_LIST();
                JSON.PUT(V_JSON_MATERIA, 'codMateria', V_COD_MATE);
                JSON.PUT(V_JSON_MATERIA, 'semestre', V_SEMESTRE);
                JSON.PUT(V_JSON_MATERIA, 'creditos', V_CREDITOS);
                JSON.PUT(V_JSON_MATERIA, 'intencidadHoraria', V_IHORARIA);
                JSON.PUT(V_JSON_MATERIA, 'post', V_POST);
                JSON.PUT(V_JSON_MATERIA, 'propia', V_PROPIA);
                --JSON.PUT(V_JSON_MATERIA, 'nombreMateria', PKG_PREMATRICULA.F_ACENTOS(V_MATERIA));
                JSON.PUT(V_JSON_MATERIA, 'nombreMateria', V_MATERIA);
                IF ( V_ISCANCELADO IS NOT NULL ) THEN
                    JSON.PUT(V_JSON_MATERIA, 'cancelado', '1');
                END IF;

                JSON.PUT(V_JSON_MATERIA, 'indicador', V_INDPAGO);

				IF(P_MOSTRAR_NOTAS <> 0) THEN
					BEGIN
						V_SELECT_FILLED := '';
						-- SE OBTIENE EL AÑO, CICLO Y ESQUECA ACTUAL DE ACUERDO AL TIPO DE PROGRAMA.
						--SI ES PREGRADO
						IF (V_ISPOSTGRADO = 0) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(1, V_ANIO, V_CICLO, V_ESQUEMA);
						--SI ES POSTGRADO
						ELSIF (V_ISPOSTGRADO = 1) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(2, V_ANIO, V_CICLO, V_ESQUEMA);
                            V_ESQUEMA := 'POSTGRADO';
						--SI ES YOPAL
						ELSIF (V_ISPOSTGRADO = 2) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(3, V_ANIO, V_CICLO, V_ESQUEMA);
						END IF;

						-- SE VERIFICA SI EXISTE LA TABLA 'B_PREMATRICULA_NOTAS_DEPURADA' EN EL ESQUEMA ACTUAL.
						SELECT 	COUNT(*)
						INTO 	V_PREMATRICULA_DEP
						FROM 	ALL_TABLES
						WHERE 		LOWER(OWNER) = LOWER(V_ESQUEMA)
								AND TABLE_NAME LIKE 'B_PREMATRICULA_NOTAS_DEPURADA';

						-- SI EXISTE LA TABLA, SE EMPIEZA A CREAR EL QUERY DINAMICO.

						IF ( V_PREMATRICULA_DEP > 0 ) THEN
							V_SELECT_FILLED := V_SELECT_FILLED || '						
									SELECT 					
							';
							-- SE VERIFICA QUE EXISTA CADA UNA DE LAS COLUMAS PARA EL QUERY.
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'DEFINITIVA_DEPURADA';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(DEFINITIVA_DEPURADA, NVL(DEFINITIVA, 0)) DEFINITIVA, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(DEFINITIVA, 0) DEFINITIVA, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'PRIMER_PARCIAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(PRIMER_PARCIAL, 0) PRIMER_PARCIAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 PRIMER_PARCIAL, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'SEGUNDO_PARCIAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || '  NVL(SEGUNDO_PARCIAL, 0) SEGUNDO_PARCIAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 SEGUNDO_PARCIAL, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'EXAMEN_FINAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(EXAMEN_FINAL, 0) EXAMEN_FINAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 EXAMEN_FINAL, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_PRIMER_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(FALLAS_PRIMER_CORTE, 0) FALLAS_PRIMER_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_PRIMER_CORTE, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_SEGUNDO_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || 'NVL(FALLAS_SEGUNDO_CORTE, 0) FALLAS_SEGUNDO_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_SEGUNDO_CORTE, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_TERCER_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(FALLAS_TERCER_CORTE, 0) FALLAS_TERCER_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_TERCER_CORTE, ';
							END IF;

							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'TOTAL_FALLAS';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(TOTAL_FALLAS, 0) TOTAL_FALLAS ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 TOTAL_FALLAS ';
							END IF;

							V_SELECT_FILLED := V_SELECT_FILLED || '	
									FROM 	' || V_ESQUEMA || '.B_PREMATRICULA_NOTAS_DEPURADA
									WHERE 	CODIGO_ESTUDIANTE = ''' || V_COD_EST ||''' AND
											MATERIA_PLAN = ''' || V_COD_MATE || ''' AND
											ANIO = ''' || V_ANIO || ''' AND
											CICLO = ''' || V_CICLO || '''		
							';

							V_SELECT := '
								SELECT  MAX(DEFINITIVA),
										MAX(PRIMER_PARCIAL),
										MAX(SEGUNDO_PARCIAL),
										MAX(EXAMEN_FINAL),
										MAX(FALLAS_PRIMER_CORTE),
										MAX(FALLAS_SEGUNDO_CORTE),
										MAX(FALLAS_TERCER_CORTE),
										MAX(TOTAL_FALLAS)
								FROM	(
											{0}
										) A
							';

							V_SELECT := REPLACE(V_SELECT, '{0}', V_SELECT_FILLED);

							SELECT 	COUNT(INDICADOR_CIERRE)
							INTO	V_NOTA_UNICA
							FROM	(
										SELECT 	INDICADOR_CIERRE
										FROM 	ADMISIONES.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
										UNION ALL
										SELECT 	INDICADOR_CIERRE
										FROM 	POSTGRADO.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
										UNION ALL
										SELECT 	INDICADOR_CIERRE
										FROM 	YOPAL.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
									) A
							WHERE	TRIM(INDICADOR_CIERRE) = 'NU';

							OPEN C FOR V_SELECT;	
							LOOP
								FETCH C INTO 	V_DEFINITIVA,
												V_NOTA_PRIMER_CORTE,
												V_NOTA_SEGUNDO_CORTE,
												V_NOTA_TERCER_CORTE,
												V_FALLAS_PRIMER_CORTE,
												V_FALLAS_SEGUNDO_CORTE,
												V_FALLAS_TERCER_CORTE,
												V_FALLAS_TOTALES;
								EXIT WHEN C%NOTFOUND;
								--SI ES NOTA UNICA.
								IF (V_NOTA_UNICA > 0 OR V_ISPOSTGRADO = 1) THEN
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'definitiva', CASE WHEN V_ENC_PLAN_ESTRA > 0 THEN '0' ELSE V_DEFINITIVA END);
									JSON.PUT(V_JSON_MATERIA, 'notas', V_JSON_NOTAS_FALLAS);
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'fallasTotales', V_FALLAS_TOTALES);
									IF (V_FALLAS_TOTALES > (V_IHORARIA * 16 * 0.25)) THEN
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '1');
									ELSE
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '0');
									END IF;
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
								--SI TIENE NOTAS PARCIALES.
								ELSE
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'definitiva', CASE WHEN V_ENC_PLAN_ESTRA > 0 THEN '0' ELSE V_DEFINITIVA END);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'primerCorte',  CASE WHEN V_ENC_PLAN_ESTRA > 0 THEN '0' ELSE V_NOTA_PRIMER_CORTE END);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'segundoCorte',  CASE WHEN V_ENC_PLAN_ESTRA > 0 THEN '0' ELSE V_NOTA_SEGUNDO_CORTE END);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'tercerCorte',  CASE WHEN V_ENC_PLAN_ESTRA > 0 THEN '0' ELSE V_NOTA_TERCER_CORTE END);
									JSON.PUT(V_JSON_MATERIA, 'notas', V_JSON_NOTAS_FALLAS);
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'fallasTotales', V_FALLAS_TOTALES);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'primerCorte', V_FALLAS_PRIMER_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'segundoCorte', V_FALLAS_SEGUNDO_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'tercerCorte', V_FALLAS_TERCER_CORTE);
									IF (V_FALLAS_TOTALES > (V_IHORARIA * 16 * 0.25)) THEN
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '1');
									ELSE
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '0');
									END IF;
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
								END IF;
							END LOOP;
							CLOSE C;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							JSON.PUT(V_JSON_BODY, 'exception',  SQLCODE || ' --- ' || SUBSTR(SQLERRM, 1, 200));
							V_SELECT := '';
					END;
				END IF;
                V_COD_MATE_ACT := V_COD_MATE;
            END IF;

            IF (V_ISPOSTGRADO <> 2) THEN
                IF 	  (V_PROPIA = 1 AND V_POST = 0)                  THEN PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 1);
                ELSIF (V_PROPIA = 1 AND P_TIPO = 777 AND V_POST = 1) THEN PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, -1);
                ELSE                                                      PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 0);
				END IF;
            ELSE
                IF (V_PROPIA = 1 AND V_POST = 0) 			         THEN PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 1, 1);
                ELSIF (V_PROPIA = 1 AND P_TIPO = 777 AND V_POST = 1) THEN PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, -1, 1);
                ELSE 													  PKG_PREMATRICULA_AUX.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 0, 1);
                END IF;
            END IF;

            IF(V_JSON_GRUPO IS NOT NULL) THEN
                JSON_LIST.APPEND(V_JSON_GRUPOS, V_JSON_GRUPO.TO_JSON_VALUE);
            END IF;
			JSON.PUT(V_JSON_MATERIA, 'grupos', V_JSON_GRUPOS);
            JSON_LIST.APPEND(V_JSON_MATERIAS, V_JSON_MATERIA.TO_JSON_VALUE);
        END LOOP;
        CLOSE V_OFERTA;
        JSON.PUT(V_JSON_BODY, 'materias', V_JSON_MATERIAS);
        JSON.HTP(V_JSON_BODY);
    EXCEPTION
        WHEN OTHERS THEN
			JSON.PUT(V_JSON_BODY, 'exception',  SQLCODE || ' --- ' || SUBSTR(SQLERRM, 1, 200));
			JSON.HTP(V_JSON_BODY);
    END PREMATRICULA;
end PKG_PREMATRICULA_AUX;