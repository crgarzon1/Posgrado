create or replace PACKAGE BODY SP_CE_ACADEMICO_UTIL IS

  /**
   *
   */
  FUNCTION FN_PERIODO_PROGRAMA_LETRAS(p_periodo VARCHAR2) RETURN VARCHAR2 IS
    v_periodo_letras VARCHAR2(10);
  BEGIN
    SELECT (CASE
             WHEN p_periodo IN ('1', '01') THEN
              'UN'
             WHEN p_periodo IN ('2', '02') THEN
              'DOS'
             WHEN p_periodo IN ('3', '03') THEN
              'TRES'
             WHEN p_periodo IN ('4', '04') THEN
              'CUATRO'
             WHEN p_periodo IN ('5', '05') THEN
              'CINCO'
             WHEN p_periodo IN ('6', '06') THEN
              'SEIS'
             WHEN p_periodo IN ('7', '07') THEN
              'SIETE'
             WHEN p_periodo IN ('8', '08') THEN
              'OCHO'
             WHEN p_periodo IN ('9', '09') THEN
              'NUEVE'
             WHEN p_periodo IN ('10') THEN
              'DIEZ'
             WHEN p_periodo IN ('11') THEN
              'ONCE'
             WHEN p_periodo IN ('12') THEN
              'DOCE'
             ELSE
              ''
           END)
      INTO v_periodo_letras
      FROM DUAL;
    RETURN v_periodo_letras;
  END FN_PERIODO_PROGRAMA_LETRAS;

  /**
   *
   */
  FUNCTION FN_CICLO_ACADEMICO_LETRAS(p_numero_ciclo VARCHAR2) RETURN VARCHAR2 IS
    v_ciclo_letras VARCHAR2(30);
  BEGIN
    CASE
      WHEN p_numero_ciclo = '01' THEN
        v_ciclo_letras := 'PRIMER PERIODO';
      WHEN p_numero_ciclo = '02' THEN
        v_ciclo_letras := 'SEGUNDO PERIODO';
      WHEN p_numero_ciclo = '03' THEN
        v_ciclo_letras := 'TERCER PERIODO';
      WHEN p_numero_ciclo = '04' THEN
        v_ciclo_letras := 'CUARTO PERIODO';
      ELSE
        v_ciclo_letras := p_numero_ciclo;
    END CASE;
    RETURN v_ciclo_letras;
  END FN_CICLO_ACADEMICO_LETRAS;


   /**
   *
   */
  FUNCTION FN_CICLO_ACADEMICO_LPERIODO(p_numero_ciclo VARCHAR2, p_ciclo_real VARCHAR2) RETURN VARCHAR2 IS
    v_ciclo_letras VARCHAR2(500);
  BEGIN
    CASE
      WHEN p_numero_ciclo = '01' THEN
        v_ciclo_letras := 'PRIMER PERIODO';
      WHEN p_numero_ciclo = '02' THEN
        v_ciclo_letras := 'CURSO INTERSEMESTRAL PRIMER PERIODO';
      WHEN p_numero_ciclo = '03' THEN
        v_ciclo_letras := 'SEGUNDO PERIODO';
      WHEN p_numero_ciclo = '04' THEN
        v_ciclo_letras := 'CURSO INTERSEMESTRAL SEGUNDO PERIODO';
      ELSE
        v_ciclo_letras := p_ciclo_real;
    END CASE;
    RETURN v_ciclo_letras;
  END FN_CICLO_ACADEMICO_LPERIODO;

  /**
   *
   */
  FUNCTION FN_SIGUIENTE_N_PERIODO(p_anio                 VARCHAR2,
                                  p_numero_ciclo         VARCHAR2,
                                  p_numero_periodos_anio NUMBER,
                                  p_siguiente            NUMBER)
    RETURN VARCHAR2 IS
    v_fila  NUMBER DEFAULT 0;
    v_anio  NUMBER;
    v_ciclo NUMBER;
  BEGIN
    v_anio  := TO_NUMBER(p_anio);
    v_ciclo := TO_NUMBER(p_numero_ciclo);
    WHILE v_fila < p_siguiente LOOP
      IF v_ciclo < p_numero_periodos_anio THEN
        v_ciclo := v_ciclo + 1;
      ELSE
        v_anio  := v_anio + 1;
        v_ciclo := 1;
      END IF;
      v_fila := v_fila + 1;
    END LOOP;
    RETURN TO_CHAR(v_anio) || LPAD(TO_CHAR(v_ciclo), 2, '0');
  END FN_SIGUIENTE_N_PERIODO;

  /**
   *
   */
  FUNCTION FN_SANCIONES(p_codigo_estudiante VARCHAR2, p_periodos_anio NUMBER) RETURN VARCHAR2 IS

    v_ciclo_inicio_sancion        VARCHAR2(10);
    v_sanciones                   VARCHAR2(20000);
    v_fila                        NUMBER DEFAULT 1;
    v_sancionado                VARCHAR2(30);

    CURSOR c_sanciones IS
    SELECT se.tipo_sancion,
           UPPER(TRIM(s.descripcion)) AS descripcion,
           UPPER(TRIM(se.observaciones)) AS  observaciones,
           UPPER(TRIM(se.numero_resolucion)) AS resolucion,
           UPPER(
             TRIM(TO_CHAR(se.fecha_resolucion, 'DD', 'NLS_DATE_LANGUAGE=spanish')) || ' de ' ||
             TRIM(INITCAP(to_char(se.fecha_resolucion,'MONTH','NLS_DATE_LANGUAGE=spanish'))) || ' de ' ||
             (TO_CHAR(se.fecha_resolucion, 'IYYY','NLS_DATE_LANGUAGE=spanish'))
           ) AS fecha_resolucion,
           UPPER(se.ciclo_sancion) AS ciclo_sancion,
           se.num_ciclos_sancion,
           se.codigo_estudiante,
           f.nombre AS nombre_facultad,
           COUNT(*) OVER() AS total_filas
    FROM admisiones.a_sanciones se
    JOIN admisiones.sanciones s
      ON se.tipo_sancion = s.codigo
    JOIN admisiones.b_estudiantes e
      ON e.codigo = se.codigo_estudiante
    JOIN admisiones.a_facultades_unica f
      ON f.codigo_facultad = e.codigo_facultad
     WHERE se.codigo_estudiante = p_codigo_estudiante;
  BEGIN

    --Recuperamos el sexo del estudiante para determinar la palabra SANCIONADO O SANCIONADA
   SELECT CASE WHEN e.sexo = 'M' THEN 'SANCIONADO' ELSE 'SANCIONADA' END
     INTO v_sancionado
     FROM admisiones.b_estudiantes e
    WHERE e.codigo = p_codigo_estudiante;

   v_sancion := NULL;

   --Recorremos cada sancion del estudiante
     FOR v_sancion IN c_sanciones LOOP

   v_ciclo_inicio_sancion := LPAD(SUBSTR(v_sancion.ciclo_sancion, 5, 2), 2, '0');
   v_sancion.descripcion := REPLACE(v_sancion.descripcion, 'SANCIONADO CON:');

   DBMS_OUTPUT.PUT_LINE(CHR(9) || ' Ciclo: ' ||  v_ciclo_inicio_sancion);

   v_sanciones := v_sanciones || 'FUE ' || v_sancionado || ' CON:' || v_sancion.descripcion;

   IF v_ciclo_inicio_sancion IS NOT NULL THEN
      v_sanciones := v_sanciones || ': ' || FN_CICLO_ACADEMICO_LETRAS(v_ciclo_inicio_sancion) || ' DE ' || SUBSTR(v_sancion.ciclo_sancion, 1, 4);
   END IF;

   IF v_sancion.resolucion IS NOT NULL AND v_sancion.resolucion <> '0' THEN
      v_sanciones := v_sanciones || ', SEGÚN RESOLUCIÓN No.' || v_sancion.resolucion || ' DE FECHA ' || v_sancion.fecha_resolucion ;
   ELSE
      v_sanciones := v_sanciones || '.';
   END IF;

   IF v_fila < v_sancion.total_filas THEN
      v_sanciones := v_sanciones || ', ';
   ELSE
      v_sanciones := v_sanciones || '.';
     END IF;

     v_fila :=  v_fila + 1;

   END LOOP;

     IF v_sanciones IS NULL THEN
        RETURN 'NO TIENE SANCIONES DISCIPLINARIAS ESTABLECIDAS EN EL REGLAMENTO ESTUDIANTIL.';
     ELSE
        RETURN v_sanciones;
     END IF;

  END FN_SANCIONES;

  /**
   *
   */
  FUNCTION FN_PERIODO_SEMESTRAL_LETRAS(p_anio     VARCHAR2,
                                       p_semestre VARCHAR2) RETURN VARCHAR2 IS
    v_periodo VARCHAR2(50) DEFAULT NULL;
  BEGIN
    IF p_anio IS NOT NULL AND p_semestre IS NOT NULL THEN
      IF p_semestre IN ('01', '1', 'PRIMER') THEN
        v_periodo := 'PRIMER PERÍODO ACADÉMICO SEMESTRAL' || ' DE ' || p_anio;
      ELSIF p_semestre IN ('02', '2', 'SEGUNDO') THEN
        v_periodo := 'SEGUNDO PERÍODO ACADÉMICO SEMESTRAL' || ' DE ' || p_anio;
      ELSE
        v_periodo := NULL;
      END IF;
    END IF;
    RETURN v_periodo;
  END FN_PERIODO_SEMESTRAL_LETRAS;

  /**
   *
   */
  FUNCTION FN_PERIODO_SEMESTRAL_T_LETRAS(p_anio  VARCHAR2,
                                         p_ciclo VARCHAR2) RETURN VARCHAR2 IS

  v_periodo VARCHAR2(50) DEFAULT NULL;
  BEGIN
    IF p_anio IS NOT NULL AND p_ciclo IS NOT NULL THEN
      IF p_ciclo IN ('01', '1', 'PRIMER') THEN
        v_periodo := 'PRIMER PERÍODO ACADÉMICO SEMESTRAL' || ' DE ' || p_anio;
      ELSIF p_ciclo IN ('03', '3', 'SEGUNDO') THEN
        v_periodo := 'SEGUNDO PERÍODO ACADÉMICO SEMESTRAL' || ' DE ' || p_anio;
      ELSIF p_ciclo IN ('02', '2') THEN
        v_periodo := 'PRIMER PERÍODO INTERSEMESTRAL' || ' DE ' || p_anio;
      ELSIF p_ciclo IN ('04', '4') THEN
        v_periodo := 'SEGUNDO PERÍODO INTERSEMESTRAL' || ' DE ' || p_anio;
      ELSE
        v_periodo := NULL;
      END IF;
    END IF;
    RETURN v_periodo;
  END FN_PERIODO_SEMESTRAL_T_LETRAS;

  /**
   *
   */
  FUNCTION FN_PERIODO_CUATRIMES_LETRAS(p_anio         VARCHAR2,
                                       p_cuatrimestre VARCHAR2) RETURN VARCHAR2 IS
    v_periodo VARCHAR2(50) DEFAULT NULL;
  BEGIN
    IF p_anio IS NOT NULL AND p_cuatrimestre IS NOT NULL THEN
      IF p_cuatrimestre IN ('01', '1', 'PRIMER') THEN
        v_periodo := 'PRIMER PERÍODO ACADÉMICO CUATRIMESTRAL' || ' DE ' || p_anio;
      ELSIF p_cuatrimestre IN ('02', '2', 'SEGUNDO') THEN
        v_periodo := 'SEGUNDO PERÍODO ACADÉMICO CUATRIMESTRAL' || ' DE ' || p_anio;
      ELSIF p_cuatrimestre IN ('03', '3', 'TERCER') THEN
        v_periodo := 'TERCER PERÍODO ACADÉMICO CUATRIMESTRAL' || ' DE ' || p_anio;
      ELSE
        v_periodo := 'AÑO ' || p_anio;
      END IF;
    END IF;
    RETURN v_periodo;
  END FN_PERIODO_CUATRIMES_LETRAS;

  /**
   *
   */
  FUNCTION FN_CICLO_REAL_CUATRIMESTRAL(p_anio         VARCHAR2,
                                       p_cuatrimestre VARCHAR2) RETURN VARCHAR2 IS
    v_periodo VARCHAR2(50) DEFAULT NULL;
  BEGIN
    IF p_cuatrimestre IS NOT NULL THEN
      IF p_cuatrimestre IN ('01', '1', 'PRIMER') THEN
        v_periodo := 'PRIMER PERÍODO ACADÉMICO CUATRIMESTRAL';
      ELSIF p_cuatrimestre IN ('02', '2', 'SEGUNDO') THEN
        v_periodo := 'SEGUNDO PERÍODO ACADÉMICO CUATRIMESTRAL';
      ELSIF p_cuatrimestre IN ('03', '3', 'TERCER') THEN
        v_periodo := 'TERCER PERÍODO ACADÉMICO CUATRIMESTRAL';
      ELSE
        v_periodo := 'PERÍODO CUATRIMESTRAL';
      END IF;
    END IF;
    RETURN v_periodo;
  END FN_CICLO_REAL_CUATRIMESTRAL;


  /**
   *
   */
  FUNCTION FN_TRANSFORMAR_CICLO_SEMESTRAL(p_ciclo VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_ciclo IN ('01', '1', '02', '2') THEN --01 es el primer periodo academico, 02 es el curso intersemestral del primer periodo
      RETURN '01';
    ELSIF p_ciclo IN ('03', '3', '04', '4') THEN --03 es el segundo periodo academico, 04 es el curso intersemestral del segundo periodo
      RETURN '02';
    ELSE
      RETURN p_ciclo;
    END IF;
  END FN_TRANSFORMAR_CICLO_SEMESTRAL;

  /**
   *
   */
  FUNCTION FN_REEMPLAZAR_EXPRESION_TITULO(p_titulo_otorgar VARCHAR2,
                                          p_genero VARCHAR2) RETURN VARCHAR2 IS
    v_expresion_regular CONSTANT VARCHAR2(20) := '[A-Z]\s*(\([A|O]\))'; --Expresion a buscar dentro del titulo a otorgar
    v_texto_expresion   VARCHAR2(100); --Texto que cumple la expresion
    v_ocurrencias       NUMBER; --Ocurrencias de la expresion
    v_titulo_otorgar    admisiones.a_facultades.titulo_a_otorgar%TYPE;

  BEGIN
    v_titulo_otorgar := UPPER(TRANSLATE(p_titulo_otorgar, 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU'));

    SELECT REGEXP_COUNT(v_titulo_otorgar, v_expresion_regular)
      INTO v_ocurrencias
    FROM DUAL;

    FOR ocurrencia IN 1..v_ocurrencias LOOP
      SELECT REGEXP_SUBSTR(v_titulo_otorgar,v_expresion_regular,1,ocurrencia)
        INTO v_texto_expresion
      FROM DUAL;

    IF (SUBSTR(v_texto_expresion,1,1) IN ('A','E','I','O','U','Á','É','Í','Ó','Ú','a','e','i','o','u','á','é','í','ó','ú')) THEN
      v_titulo_otorgar := REPLACE(v_titulo_otorgar, v_texto_expresion, CASE WHEN UPPER(p_genero) = 'M' THEN 'O' ELSE 'A' END);
    ELSE
      v_titulo_otorgar := REPLACE(v_titulo_otorgar, SUBSTR(v_texto_expresion,2), CASE WHEN UPPER(p_genero) = 'M' THEN '' ELSE 'A' END);
    END IF;

  END LOOP;

  RETURN v_titulo_otorgar;

  EXCEPTION WHEN OTHERS THEN
    RETURN v_titulo_otorgar;

  END FN_REEMPLAZAR_EXPRESION_TITULO;

  /**
   *
   */
  FUNCTION FN_FECHA_EXPEDICION RETURN VARCHAR2 IS
    v_fecha VARCHAR2(50) DEFAULT NULL;
  BEGIN
    SELECT 'BOGOTÁ, ' || TO_CHAR(SYSDATE, 'DD') || ' DE ' || TRIM(UPPER(to_char(SYSDATE, 'MONTH','NLS_DATE_LANGUAGE=spanish'))) || ' DE ' || TO_CHAR(SYSDATE, 'YYYY')
      INTO v_fecha
    FROM DUAL;

    RETURN v_fecha;

  END FN_FECHA_EXPEDICION;

   /**
   *
   */
  FUNCTION FN_FECHA_EXPEDICION_LOWER RETURN VARCHAR2 IS
    v_fecha VARCHAR2(50) DEFAULT NULL;
  BEGIN
    SELECT 'Bogotá, ' || TO_CHAR(SYSDATE, 'DD') || ' de ' || TRIM(INITCAP(to_char(SYSDATE, 'MONTH','NLS_DATE_LANGUAGE=spanish'))) || ' de ' || TO_CHAR(SYSDATE, 'YYYY')
      INTO v_fecha
    FROM DUAL;

    RETURN v_fecha;

  END FN_FECHA_EXPEDICION_LOWER;


  FUNCTION FN_EXPRESION_DEL_A(p_genero VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_genero = 'M' THEN
      RETURN 'DEL';
    ELSE
      RETURN 'DE LA';
    END IF;
  END FN_EXPRESION_DEL_A;

  FUNCTION FN_EXPRESION_INTERESADO_A(p_genero VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_genero = 'M' THEN
      RETURN 'INTERESADO';
    ELSE
      RETURN 'INTERESADA';
    END IF;
  END FN_EXPRESION_INTERESADO_A;

  FUNCTION FN_EXPRESION_IDENTIFICADO_A(p_genero VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_genero = 'M' THEN
      RETURN 'IDENTIFICADO';
    ELSE
      RETURN 'IDENTIFICADA';
    END IF;
  END FN_EXPRESION_IDENTIFICADO_A;

  FUNCTION FN_EXPRESION_MATRICULADO_A(p_genero VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_genero = 'M' THEN
      RETURN 'MATRICULADO';
    ELSE
      RETURN 'MATRICULADA';
    END IF;
  END FN_EXPRESION_MATRICULADO_A;

  FUNCTION FN_TIPO_PLAN_ESTUDIO(p_plan_estudio VARCHAR2) RETURN VARCHAR2 IS
    v_tipo_plan VARCHAR2(1) DEFAULT NULL;
    v_plan_estudio NUMBER;
  BEGIN
    --\D Expresion regular que representa cualquier carácter que no sea un dígito del 0 al 9
   CASE
      WHEN p_plan_estudio IS NOT NULL AND (REGEXP_SUBSTR(p_plan_estudio, '\D') IS NOT NULL)
        THEN v_plan_estudio := -1;
      WHEN p_plan_estudio IS NOT NULL AND (REGEXP_SUBSTR(p_plan_estudio, '\D') IS NULL)
        THEN v_plan_estudio := TO_NUMBER(p_plan_estudio);
      ELSE
        v_plan_estudio := NULL;
   END CASE;
   IF v_plan_estudio IS NOT NULL AND v_plan_estudio < 3 THEN
     v_tipo_plan := 'H';

   ELSIF v_plan_estudio IS NOT NULL AND v_plan_estudio > 2 THEN
     v_tipo_plan := 'C';
   ELSE
     v_tipo_plan := NULL;
   END IF;

   RETURN v_tipo_plan;
  END;

   /**
    * @see SP_CE_ACADEMICO_UTIL.PR_IDIOMA_EXTRANJERO_JSON(p_codigo_estudiante VARCHAR2);
    */
   FUNCTION FN_NIVELES_IDIOMA_LETRAS(p_nivel VARCHAR2) RETURN VARCHAR2 IS
      v_nivel_letras VARCHAR2(20);
   BEGIN
      SELECT (CASE
             WHEN p_nivel IN ('1') THEN
              'UN (' || p_nivel || ')'
             WHEN p_nivel IN ('2') THEN
              'DOS (' || p_nivel || ')'
             WHEN p_nivel IN ('3') THEN
              'TRES (' || p_nivel || ')'
             WHEN p_nivel IN ('4') THEN
              'CUATRO (' || p_nivel || ')'
             WHEN p_nivel IN ('5') THEN
              'CINCO (' || p_nivel || ')'
             WHEN p_nivel IN ('6') THEN
              'SEIS (' || p_nivel || ')'
             WHEN p_nivel IN ('7') THEN
              'SIETE (' || p_nivel || ')'
             ELSE ''
           END)
      INTO v_nivel_letras
      FROM DUAL;

      IF TO_NUMBER(p_nivel) > 1 THEN
        v_nivel_letras := v_nivel_letras || ' NIVELES';
      ELSE
        v_nivel_letras := v_nivel_letras || ' NIVEL';
      END IF;

    RETURN v_nivel_letras;
  END FN_NIVELES_IDIOMA_LETRAS;

  /**
    * @see SP_CE_ACADEMICO_UTIL.FN_TITULO_REINTEGRO(p_tipo_de_ingreso VARCHAR2, p_codigo_estudiante VARCHAR2, p_grupo_certificado NUMBER);
    */
  FUNCTION FN_TITULO_REINTEGRO(p_tipo_de_ingreso VARCHAR2, p_codigo_estudiante VARCHAR2, p_grupo_certificado NUMBER) RETURN VARCHAR2 IS
      v_grupo_estudiante VARCHAR2(20);
  BEGIN

   IF p_tipo_de_ingreso <> 'RA' OR p_codigo_estudiante IS NULL THEN
     RETURN '.';
   END IF;

   SELECT g.nombre_grupo
     INTO v_grupo_estudiante
     FROM CE_GRUPO_CERTIFICADO g
    WHERE g.id_grupo_certificado = p_grupo_certificado;

   IF v_grupo_estudiante = 'PREGRADO' THEN
     RETURN ', EN REINTEGRO DE ACTUALIZACIÓN, EN LOS TERMINOS DEL REGLAMENTO ESTUDIANTIL.';
   END IF;

     IF v_grupo_estudiante = 'POSGRADO' THEN
       RETURN ', EN REINTEGRO DE ACTUALIZACIÓN, EN LOS TERMINOS DEL REGLAMENTO ESTUDIANTIL.';
     END IF;

     RETURN '.';
  END FN_TITULO_REINTEGRO;


  /**
   * @see SP_CE_ACADEMICO.PR_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2 );
   */
  PROCEDURE PR_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2) IS

     v_texto VARCHAR2(500);

  BEGIN
     v_texto :=  FN_HISTORIA_ACAD_NUMERO(p_nota);
       htp.prn(v_texto);
  END PR_HISTORIA_ACAD_NUMERO;

  /**
   * @see SP_CE_ACADEMICO.FN_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2 );
   */
  FUNCTION FN_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2) RETURN VARCHAR2 IS

     TYPE numbersarray IS VARRAY(10) OF VARCHAR2(10);
     numbers numbersarray;
     num NUMBER := IS_NUMBER(SUBSTR(p_nota, 0,1 ));
     de NUMBER := IS_NUMBER(SUBSTR(p_nota, 3,3 ));
     v_texto VARCHAR2(150);

  BEGIN
     numbers := numbersarray('CERO', 'UNO', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE');
     v_texto :=  '"notadigito":"';

     IF num IS NOT NULL THEN
        v_texto := v_texto||numbers(num+1)||'", ';
     ELSE
        v_texto := v_texto||'", ';
     END IF;

     v_texto := v_texto|| '"notadecimal":"';

     IF de IS NOT NULL THEN
       v_texto := v_texto||numbers(de+1)||'"';
     ELSE
       v_texto := v_texto||'"';
     END IF;

     RETURN v_texto;

  END FN_HISTORIA_ACAD_NUMERO;

    FUNCTION GET_ALPHABETIC_VALUE (
        P_NUMBER VARCHAR2
    ) RETURN VARCHAR2 IS
        TYPE numbersarray IS VARRAY(10) OF VARCHAR2(10);
        NUM NUMBER := IS_NUMBER(SUBSTR(P_NUMBER, 0,1 ));
        NUMBERS NUMBERSARRAY;
        RETURNABLE VARCHAR2(25) DEFAULT '';
    BEGIN
        NUMBERS := NUMBERSARRAY('CERO', 'UNO', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE');
        IF NUM IS NOT NULL THEN
            RETURNABLE := NUMBERS(NUM + 1);
        END IF;
        RETURN RETURNABLE;
    END GET_ALPHABETIC_VALUE;

  /**
   * @see SP_CE_ACADEMICO.IS_NUMBER(str in varchar2);
   */
  FUNCTION IS_NUMBER(str in varchar2) RETURN NUMBER IS
       N number;
  BEGIN
       N := TO_NUMBER(str);
       RETURN (N);
  EXCEPTION WHEN OTHERS THEN
       RETURN (NULL);
  END IS_NUMBER;

  /**
   * @see SP_CE_ACADEMICO.FN_JORNADA(codigo_jornada in varchar2);
   */
  FUNCTION FN_JORNADA(codigo_jornada in VARCHAR2, jornada_facultad  in VARCHAR2) RETURN VARCHAR2 IS
       v_jornada VARCHAR2(60);
       v_cantidad_jornadas NUMBER;
  BEGIN

   v_jornada := '';

     SELECT COUNT(a.codigo)
       INTO v_cantidad_jornadas
       FROM admisiones.a_facultades a
      WHERE a.codigo = codigo_jornada;

      IF v_cantidad_jornadas > 1 THEN
         v_jornada := ' JORNADA ';
         v_jornada := v_jornada || '<b>';
         v_jornada := v_jornada || CASE jornada_facultad WHEN 'D' THEN 'DIURNA' WHEN 'N' THEN 'NOCTURNA' ELSE '' END;
        v_jornada := v_jornada || '</b>';
      END IF;

      RETURN v_jornada;
  END FN_JORNADA;


  /**
   * @see SP_CE_ACADEMICO.FN_FORMAT_FECHA(fecha in DATE);
   */
  FUNCTION FN_FORMAT_FECHA(fecha in DATE) RETURN VARCHAR2 IS
       v_fecha VARCHAR2(1000);
  BEGIN

     v_fecha := '';

     IF NOT fecha IS NULL THEN
         v_fecha := UPPER(TRIM(TO_CHAR(fecha, 'DAY', 'NLS_DATE_LANGUAGE=spanish'))            || ' '    ||
                     TRIM(TO_CHAR(fecha, 'DD', 'NLS_DATE_LANGUAGE=spanish'))             || ' de ' ||
                    TRIM(INITCAP(to_char(fecha, 'MONTH', 'NLS_DATE_LANGUAGE=spanish'))) || ' de ' ||
                    TO_CHAR(fecha, 'YYYY', 'NLS_DATE_LANGUAGE=spanish'));
     END IF;

       RETURN v_fecha;
  END FN_FORMAT_FECHA;


   /**
    * CC, CE, NIT, RC, TI, PS, VI, EXT
   * @see SP_CE_ACADEMICO.FN_FORMAT_FECHA(fecha in DATE);
   */
  FUNCTION FN_TIPO_DOCUMENTO(p_id_tipo_documento VARCHAR2) RETURN VARCHAR2 IS
       v_tipo_documento VARCHAR2(1000);
  BEGIN

     v_tipo_documento := '';

     IF p_id_tipo_documento = '00' THEN
          v_tipo_documento := 'EXT';
     END IF;

     IF p_id_tipo_documento = '01' THEN
          v_tipo_documento := 'CC';
     END IF;

     IF p_id_tipo_documento = '02' THEN
          v_tipo_documento := 'CE';
     END IF;

     IF p_id_tipo_documento = '03' THEN
          v_tipo_documento := 'TI';
     END IF;

     IF p_id_tipo_documento = '04' THEN
          v_tipo_documento := 'VI';
     END IF;

     IF p_id_tipo_documento = '05' THEN
          v_tipo_documento := 'PS';
     END IF;

     IF p_id_tipo_documento = '07' THEN
          v_tipo_documento := 'CC';
     END IF;

     IF p_id_tipo_documento = '08' THEN
          v_tipo_documento := '';
     END IF;

     IF p_id_tipo_documento = '09' THEN
          v_tipo_documento := '';
     END IF;

       RETURN v_tipo_documento;
  END FN_TIPO_DOCUMENTO;
  
  /**
    *
   * @see SP_CE_ACADEMICO.FN_TIPO_DOCUMENTO_TILDE(p_valor in VARCHAR2);
   */
  FUNCTION FN_TIPO_DOCUMENTO_TILDE(p_valor VARCHAR2) RETURN VARCHAR2 IS
     v_valor varchar2(30) := p_valor;
  BEGIN
     IF v_valor = 'Cedula de ciudadania' THEN
       v_valor := 'Cédula de ciudadanía';
     ELSIF v_valor = 'Cedula de Extranjeria' THEN
       v_valor := 'Cédula de Extranjería';       
     ELSIF v_valor = 'Contraseña Cedula' THEN
       v_valor := 'Contraseña Cédula';
     ELSIF v_valor = 'Carne de Identificacion' THEN
       v_valor := 'Carné de Identificación';
     END IF;

     RETURN v_valor;
  END FN_TIPO_DOCUMENTO_TILDE;

  /**
   * @see SP_CE_ACADEMICO_UTIL#FN_ESTADO_MATRICULA(p_grupo_matricula VARCHAR2)
   */
  FUNCTION FN_ESTADO_MATRICULA(p_grupo_matricula VARCHAR2) RETURN VARCHAR2 IS
    v_fecha_limite VARCHAR2(10) DEFAULT NULL;
    v_estado VARCHAR2(10) DEFAULT NULL;
    --b_fecha BOOLEAN DEFAULT FALSE;
  BEGIN

    IF p_grupo_matricula = 'RETIRADO' THEN
       RETURN 'ESTUVO';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' THEN
       RETURN 'ESTÁ';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA'THEN
       RETURN 'ESTÁ';
    END IF;

    /*SELECT fecha
      INTO v_fecha_limite
      FROM admisiones.ls_fecha_constancias;

    b_fecha := TRUNC(SYSDATE) < TRUNC(TO_DATE(TO_CHAR(v_fecha_limite),'RRRRMMDD'));

    IF p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' AND b_fecha THEN
       RETURN 'ESTA';
    ELSE
       RETURN 'ESTUVO';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA' AND b_fecha THEN
       RETURN 'ESTA';
    ELSE
       RETURN 'ESTUVO';
    END IF;*/

  RETURN NULL;

  EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
  END FN_ESTADO_MATRICULA;

  /**
   * @see SP_CE_ACADEMICO_UTIL#FN_PREPOSICION_MATRICULA(p_grupo_matricula VARCHAR2)
   */
  FUNCTION FN_PREPOSICION_MATRICULA(p_grupo_matricula VARCHAR2) RETURN VARCHAR2 IS
    v_fecha_limite VARCHAR2(10) DEFAULT NULL;
    v_preposicion VARCHAR2(10) DEFAULT NULL;
    --b_fecha BOOLEAN DEFAULT FALSE;
  BEGIN

    IF p_grupo_matricula = 'RETIRADO' THEN
       RETURN 'HASTA';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' THEN
       RETURN 'EN';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA' THEN
       RETURN 'EN';
    END IF;

    /*SELECT fecha
      INTO v_fecha_limite
      FROM admisiones.ls_fecha_constancias;

    b_fecha := TRUNC(SYSDATE) < TRUNC(TO_DATE(TO_CHAR(v_fecha_limite),'RRRRMMDD'));

    IF p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' AND b_fecha THEN
       RETURN 'EN';
    ELSE
       RETURN 'HASTA';
    END IF;

    IF p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA' AND b_fecha THEN
       RETURN 'EN';
    ELSE
       RETURN 'HASTA';
    END IF;*/

  RETURN NULL;

  EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
  END FN_PREPOSICION_MATRICULA;


  /**
   *
   */
  FUNCTION FN_TITULO_ASIGNATURAS(p_grupo_matricula VARCHAR2, p_codigo_tipo_programa VARCHAR2, p_cursando VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
     v_fecha_limite VARCHAR2(10)  DEFAULT NULL;
     v_titulo      VARCHAR2(255) DEFAULT NULL;
     v_cursa        VARCHAR2(255) DEFAULT NULL;
     v_curso        VARCHAR2(255) DEFAULT NULL;
  BEGIN

     IF p_grupo_matricula = 'RETIRADO' THEN
       RETURN 'EN EL ULTIMO PERIODO CURSO LAS SIGUIENTES ASIGNATURAS:';
     END IF;

     IF p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' THEN
       RETURN 'CURSA LAS SIGUIENTES ASIGNATURAS:';
     END IF;

     IF p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA' THEN
       RETURN 'CURSA LAS SIGUIENTES ASIGNATURAS:';
     END IF;



    /*
      SELECT fecha INTO v_fecha_limite FROM admisiones.ls_fecha_constancias;
    IF p_codigo_tipo_programa = 004 THEN --Para doctorado
      IF p_cursando IS NULL THEN
        v_cursa := 'CURSA LOS SIGUIENTES COMPONENTES CURRICULARES:';
      ELSE
        v_cursa := 'CURSANDO LOS SIGUIENTES COMPONENTES CURRICULARES:';
      END IF;
      v_curso := 'EN EL ULTIMO PERIODO CURSO LOS SIGUIENTES COMPONENTES CURRICULARES:';
    ELSE --Para los demas tipos de programa
      IF p_cursando IS NULL THEN
        v_cursa := 'CURSA LAS SIGUIENTES ASIGNATURAS:';
      ELSE
        v_cursa := 'CURSANDO LAS SIGUIENTES ASIGNATURAS:';
      END IF;

      v_curso := 'EN EL ULTIMO PERIODO CURSO LAS SIGUIENTES ASIGNATURAS:';
    END IF;


    CASE WHEN p_grupo_matricula = 'MATRICULADO_CON_PREMATRICULA' THEN
      IF (TRUNC(SYSDATE) < TRUNC(TO_DATE(TO_CHAR(v_fecha_limite),'RRRRMMDD'))) THEN
         v_titulo := v_cursa;
      ELSE
         v_titulo := v_curso;
      END IF;

       WHEN p_grupo_matricula = 'MATRICULADO_NUEVO_SIN_PREMATRICULA' THEN
          v_titulo := NULL;

       WHEN p_grupo_matricula = 'RETIRADO' THEN
         v_titulo := v_curso;
       ELSE
         v_titulo := NULL;
    END CASE;

    RETURN v_titulo;*/

    --Cuando no se dan ninguna de las condiciones no estaba retornando nada.
    RETURN NULL;

  EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
  END FN_TITULO_ASIGNATURAS;


  /**
   * @see SP_CE_ACADEMICO_UTIL#FN_TIPO_ESTUDIANTE(p_codigo_estudiante VARCHAR2)
   */
  FUNCTION FN_TIPO_ESTUDIANTE(p_codigo_estudiante VARCHAR2, v_grupo_estudiante VARCHAR2) RETURN NUMBER IS
      n_materias_pendientes admisiones.b_estudiantes.materias_pendientes%TYPE DEFAULT NULL;
      v_indicador_pago   admisiones.b_estudiantes.indicador_pago%TYPE DEFAULT NULL;
      d_fecha_grado admisiones.a_graduados.fecha_grado%TYPE DEFAULT NULL;
      V_BOLSAS_PENDIENTES NUMBER;
  BEGIN
    --RECUPERA INFORMACION BASICA PARA DETERMINAR EL TIPO DE ESTUDIANTE
    IF v_grupo_estudiante = 'PREGRADO' THEN
      SELECT e.materias_pendientes
             , e.indicador_pago
             , h.fecha_grado
          INTO n_materias_pendientes
             , v_indicador_pago
             , d_fecha_grado
          FROM admisiones.b_estudiantes e
     LEFT JOIN admisiones.a_graduados h
            ON (e.codigo = h.codigo_estudiante)
         WHERE e.codigo = p_codigo_estudiante;
    END IF;

    IF v_grupo_estudiante = 'POSGRADO' THEN
      SELECT e.materias_pendientes
             , e.indicador_pago
             , h.fecha_grado
          INTO n_materias_pendientes
             , v_indicador_pago
             , d_fecha_grado
          FROM postgrado.b_estudiantes e
     LEFT JOIN admisiones.a_graduados h
            ON (e.codigo = h.codigo_estudiante)
         WHERE e.codigo = p_codigo_estudiante;
                 
        SELECT COUNT(*)
        INTO   V_BOLSAS_PENDIENTES
        FROM   (SELECT     BC.TOPE TOPE,
                           COUNT(M.CREDITOS) CREDITOS_CURSADOS
                FROM       POSTGRADO.CTI_BOLSAS_CREDITOS BC
                INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.ID_BOLSA = BC.ID_BOLSA
                INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                LEFT JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                 AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                 AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                 AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                 AND N.CODIGO_ESTUDIANTE = BE.CODIGO
                                                 AND N.VALOR > 3.5
                -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                LEFT JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                    AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                    AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                    AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                WHERE    BE.CODIGO = p_codigo_estudiante
                GROUP BY BC.TOPE) A
        WHERE CREDITOS_CURSADOS < TOPE;
        
        n_materias_pendientes:= n_materias_pendientes + V_BOLSAS_PENDIENTES;
    END IF;

    IF v_grupo_estudiante = 'YOPAL' THEN
      SELECT e.materias_pendientes
             , e.indicador_pago
             , h.fecha_grado
          INTO n_materias_pendientes
             , v_indicador_pago
             , d_fecha_grado
          FROM yopal.b_estudiantes e
     LEFT JOIN admisiones.a_graduados h
            ON (e.codigo = h.codigo_estudiante)
         WHERE e.codigo = p_codigo_estudiante;
    END IF;

    -- ESTUDIANTE MATRICULADO
    IF (n_materias_pendientes > 0 OR n_materias_pendientes IS NULL) AND v_indicador_pago IN ('P','V') THEN
       RETURN 1;
    END IF;

    -- ESTUDIANTE REINTEGRO ACTUALIZACION
    IF n_materias_pendientes <= 0 AND v_indicador_pago IN ('P','V') THEN
       RETURN 2;
    END IF;

    -- ESTUDIANTE RETIRADO
    IF (n_materias_pendientes > 0 OR n_materias_pendientes IS NULL) AND v_indicador_pago NOT IN ('P','V') THEN
       RETURN 3;
    END IF;

    -- EGRESADO GRADUADO
    IF n_materias_pendientes <= 0 AND (d_fecha_grado < TRUNC(SYSDATE) AND d_fecha_grado > TO_DATE('01/01/1960', 'DD/MM/YYYY')) THEN
       RETURN 4;
    END IF;

    -- EGRESADO NO GRADUADO
    IF n_materias_pendientes <= 0 AND (d_fecha_grado IS NULL OR d_fecha_grado <= TO_DATE('01/01/1960', 'DD/MM/YYYY')) THEN
       RETURN 5;
    END IF;

    -- TODO: AGREGAR CONDICIONES NECESARIAS PARA - ASPIRANTE

    -- EGRESADO NO GRADUADO CON FECHA DE GRADO PROGRAMADA
    IF n_materias_pendientes <= 0 AND (d_fecha_grado >= TRUNC(SYSDATE) AND d_fecha_grado > TO_DATE('01/01/1960', 'DD/MM/YYYY')) THEN
       RETURN 7;
    END IF;

    RETURN 0;

  EXCEPTION WHEN OTHERS THEN
      RETURN NULL;
  END FN_TIPO_ESTUDIANTE;


  /**
   * @see SP_CE_ACADEMICO_UTIL#FN_TIPO_ESTUDIANTE(p_codigo_estudiante VARCHAR2)
   */
  FUNCTION FN_CICLO_EN_REINTEGRO(p_ciclo_terminacion VARCHAR2, p_anio_terminacion VARCHAR2, p_ciclo_cursado VARCHAR2, p_anio_cursado VARCHAR2) RETURN NUMBER IS
      v_periodo_terminacion VARCHAR2(100);
      v_periodo_cursado VARCHAR2(100);
  BEGIN

    v_periodo_terminacion := TRIM(p_ciclo_terminacion) || '' || TRIM(p_anio_terminacion);
    v_periodo_cursado := TRIM(p_ciclo_cursado) || '' || TRIM(p_anio_cursado);
    IF v_periodo_terminacion = v_periodo_cursado THEN
      RETURN 1;
    END IF;

    RETURN 0;

  EXCEPTION WHEN OTHERS THEN
      RETURN 0;
  END FN_CICLO_EN_REINTEGRO;
  
    /**
   * @see SP_CE_ACADEMICO_UTIL#FN_GRADUADO_MAT_PEND(p_codigo_estudiante VARCHAR2)
   */
  FUNCTION FN_GRADUADO_MAT_PEND(p_codigo_estudiante VARCHAR2,v_esquema VARCHAR2) RETURN NUMBER IS
    n_graduado_mat_pend number default 0;
  BEGIN
     IF v_esquema = 'ADMISIONES' THEN
       SELECT COUNT(*)
       INTO n_graduado_mat_pend
       FROM admisiones.b_estudiantes e
       JOIN admisiones.a_graduados a
       ON(e.codigo                 = a.codigo_estudiante)
       WHERE(e.materias_pendientes <> 0
       OR e.porcred_aprobado     < 100)
       AND a.fecha_grado         <= trunc(sysdate)
       AND a.fecha_grado         > to_date('01/01/1960', 'DD/MM/YYYY')
       AND (upper(a.tipo_grado)  <> 'POS'
       OR a.tipo_grado           IS NULL)
       AND e.codigo                = p_codigo_estudiante;      
     /*ELSIF v_esquema = 'POSTGRADO' THEN
       SELECT COUNT(*)
       INTO n_graduado_mat_pend
       FROM postgrado.b_estudiantes e
       JOIN admisiones.a_graduados a
       ON(e.codigo                 = a.codigo_estudiante)
       WHERE e.materias_pendientes <> 0
       AND a.fecha_grado           <= trunc(sysdate)
       AND a.fecha_grado           > to_date('01/01/1960', 'DD/MM/YYYY')
       AND (upper(a.tipo_grado)    <> 'POS'
       OR a.tipo_grado             IS NULL)
       AND e.codigo                = p_codigo_estudiante;
     ELSIF v_esquema = 'YOPAL' THEN
       SELECT COUNT(*)
       INTO n_graduado_mat_pend
       FROM yopal.b_estudiantes e
       JOIN admisiones.a_graduados a
       ON(e.codigo                 = a.codigo_estudiante)
       WHERE e.materias_pendientes <> 0
       AND a.fecha_grado         <= trunc(sysdate)
       AND a.fecha_grado         > to_date('01/01/1960', 'DD/MM/YYYY')
       AND (upper(a.tipo_grado)  <> 'POS'
       OR a.tipo_grado           IS NULL)
       AND e.codigo                = p_codigo_estudiante;*/      
     END IF;

    RETURN n_graduado_mat_pend;
  EXCEPTION WHEN OTHERS THEN
      RETURN 0;
  END FN_GRADUADO_MAT_PEND;
  
   /**
   * @see SP_CE_ACADEMICO_UTIL#FN_NUMEROS_ORDINALES(p_codigo_estudiante VARCHAR2)
   */
  FUNCTION FN_NUMEROS_ORDINALES(p_numero VARCHAR2) RETURN VARCHAR2 IS
    v_numero_ordinal VARCHAR2(10);
  BEGIN
    SELECT (CASE
             WHEN p_numero IN ('1', '01') THEN
              'PRIMER'
             WHEN p_numero IN ('2', '02') THEN
              'SEGUNDO'
             WHEN p_numero IN ('3', '03') THEN
              'TERCER'
             WHEN p_numero IN ('4', '04') THEN
              'CUARTO'
             WHEN p_numero IN ('5', '05') THEN
              'QUINTO'
             WHEN p_numero IN ('6', '06') THEN
              'SEXTO'
             WHEN p_numero IN ('7', '07') THEN
              'SÉPTIMO'
             WHEN p_numero IN ('8', '08') THEN
              'OCTAVO'
             WHEN p_numero IN ('9', '09') THEN
              'NOVENO'
             WHEN p_numero IN ('10') THEN
              'DÉCIMO'
             WHEN p_numero IN ('11') THEN
              'UNDÉCIMO'
             WHEN p_numero IN ('12') THEN
              'DUODÉCIMO'
             WHEN p_numero IN ('13') THEN
              'DECIMOTERCER'
             WHEN p_numero IN ('14') THEN
              'DECIMOCUARTO'
             WHEN p_numero IN ('15') THEN
              'DECIMOQUINTO'
             WHEN p_numero IN ('16') THEN
              'DECIMOSEXTO'
             WHEN p_numero IN ('17') THEN
              'DECIMOSÉPTIMO'
             WHEN p_numero IN ('18') THEN
              'DECIMOCTAVO'
             WHEN p_numero IN ('19') THEN
              'DECIMONOVENO'
             WHEN p_numero IN ('20') THEN
              'VIGÉSIMO'
             ELSE
              ''
           END)
      INTO v_numero_ordinal
      FROM DUAL;
    RETURN v_numero_ordinal;
  END FN_NUMEROS_ORDINALES;

END SP_CE_ACADEMICO_UTIL;