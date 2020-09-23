create or replace PACKAGE SP_CE_ACADEMICO_UTIL IS
  /**
   * Paquete de utilidades para las fuentes de las bandas de los certificados de estudios academicos
   * @author jvelasquezv
   * @since 2015-08-19
   * @modified 2015-08-26 Se quitan tildes
   */

  -------------------------------------------------------------------------------------------------------------------------
  -- ATRIBUTOS
  -------------------------------------------------------------------------------------------------------------------------
  --Registro para almacenar informacion obtenidad desde cursores de sanciones academicas
  TYPE SANCIONES IS RECORD(
    tipo_sancion       admisiones.a_sanciones.tipo_sancion%TYPE,
    descripcion        admisiones.sanciones.descripcion%TYPE,
    observaciones      admisiones.a_sanciones.observaciones%TYPE,
    resolucion         admisiones.a_sanciones.numero_resolucion%TYPE,
    fecha_resolucion   VARCHAR2(50),
    ciclo_sancion      admisiones.a_sanciones.ciclo_sancion%TYPE,
    num_ciclos_sancion admisiones.a_sanciones.num_ciclos_sancion%TYPE,
    total_filas        NUMBER);

  --Instancia de una sancion
  v_sancion SANCIONES;

  -------------------------------------------------------------------------------------------------------------------------
  -- FUNCIONES
  -------------------------------------------------------------------------------------------------------------------------
  /**
   * Retorna el periodo de un programa en letras
   * @author jvelasquezv
   * @since 2015-04-29
   */
  FUNCTION FN_PERIODO_PROGRAMA_LETRAS(p_periodo VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna el nombre de un ciclo academico
   * @author jvelasquezv
   * @since 2015-07-27
   * @param p_numero_ciclo Numero de ciclo conformado por dos numeros, si es un solo digito a la izquierda debe tener un cero
   */
  FUNCTION FN_CICLO_ACADEMICO_LETRAS(p_numero_ciclo VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna el n siguiente periodo "año de cuatro digitos concatenado con el numero del ciclo de dos digitos" al que llega como parametro
   * @author jvelasquezv
   * @since 2015-07-27
   * @param p_anio Año
   * @param p_numero_ciclo Ciclo
   * @param p_numero_periodos_anio Numero de periodos en el año del tipo de programa
   * @param p_siguiente Numero que indica el n siguiente periodo se desea obtener
   */
  FUNCTION FN_SIGUIENTE_N_PERIODO(p_anio                 VARCHAR2,
                                  p_numero_ciclo         VARCHAR2,
                                  p_numero_periodos_anio NUMBER,
                                  p_siguiente            NUMBER)
    RETURN VARCHAR2;

  /**
   * Retorna las sanciones que ha tenido un estudiante de cualquier esquema, si tiene mas de una sancion
   * cada sancion termina con la etiqueta html de fin de linea <BR/>
   * @author jvelasquezv
   * @since 2015-07-27
   * @param p_codigo_estudiante Codigo del estudiante
   * @param p_periodos_anio Numero de periodos que tiene al año el progama del estudiante
   */
  FUNCTION FN_SANCIONES(p_codigo_estudiante VARCHAR2,
                        p_periodos_anio     NUMBER) RETURN VARCHAR2;

  /**
   * Retorna el nombre del periodo academico semestral en letras, solo semestres 01 y o2
   * @author jvelasquezv
   * @since 2015-08-20
   * @param p_anio Año academico
   * @param p_semestre Semestre academico (01, 02)
   */

  FUNCTION FN_PERIODO_SEMESTRAL_LETRAS(p_anio     VARCHAR2,
                                       p_semestre VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna el nombre de periodo academico semestral en letras,
   * para cualquiera de los ciclos: 01, 02, 03 y 04
   * @author jvelasquezv
   * @since 2015-09-29
   * @param p_anio Año academico
   * @param p_ciclo Ciclo academico en programas semestrales (01, 02, 03, 04)
   */
  FUNCTION FN_PERIODO_SEMESTRAL_T_LETRAS(p_anio  VARCHAR2,
                                         p_ciclo VARCHAR2) RETURN VARCHAR2;


  /**
   * Retorna el periodo academico cuatrimestral en letras
   * @author jvelasquezv
   * @since 2015-08-20
   * @param p_anio Año academico
   * @param p_cuatrimestre Cuatrimestre academico
   */

  FUNCTION FN_PERIODO_CUATRIMES_LETRAS(p_anio         VARCHAR2,
                                       p_cuatrimestre VARCHAR2) RETURN VARCHAR2;


  /**
   * Retorna el periodo academico cuatrimestral en letras
   * @author jhfonseca
   * @since 2016-09-09
   * @param p_anio Año academico
   * @param p_cuatrimestre Cuatrimestre academico
   */
  FUNCTION FN_CICLO_REAL_CUATRIMESTRAL(p_anio VARCHAR2,  p_cuatrimestre VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna el ciclo trasformado a ciclo semestral (01, 02) si el ciclo que llega es alguno de los siguientes
   * (01, 02, 03, 04), en caso contrario es un ciclo de homologacion y no se trasformara, retornandose tal cual.
   * @author jvelasquezv
   * @since 2015-08-31
   * @param p_ciclo Ciclo academico semestral, puede ser alguno de los siguientes: (01,02,03,04,00,.,*,**)
   */
  FUNCTION FN_TRANSFORMAR_CICLO_SEMESTRAL(p_ciclo VARCHAR2) RETURN VARCHAR2;

  /**
   * Reemplaza la expresion: "[A-Z]\s*(\([A|O]\))" del titulo a otorgar por el valor correspondiente segun genero
   * @author jvelasquezv
   * @since 2015-09-02
   * @param p_titulo_otorgar Titulo a otorgar
   * @param p_genero Genero, puede ser alguno de los siguientes: (F,M)
   */
  FUNCTION FN_REEMPLAZAR_EXPRESION_TITULO(p_titulo_otorgar VARCHAR2,
                                          p_genero VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna titulo de asignaturas para el grupo de matricula en que se clasifica el estudiante
   * @author jvelasquezv
   * @since 2015-09-14
   * @param p_grupo_matricula (MATRICULADO_NUEVO_SIN_PREMATRICULA, MATRICULADO_CON_PREMATRICULA, RETIRADO)
   * @param p_codigo_tipo_programa Codigo del tipo de programa (004 es DOCTORADO)
   * @modified jvelasquezv 2015-09-16 Se adiciono el parametro p_codigo_tipo_programa ya que para doctorado cambia el texto
   * @modified jvelasquezv 2015-10-26 Se adiciono el parametro p_cursando, pues para el modelo 18 "Certificado para Colpensiones", en lugar de CURSA se coloca CURSANDO
   */
  FUNCTION FN_TITULO_ASIGNATURAS(p_grupo_matricula      VARCHAR2,
                                 p_codigo_tipo_programa VARCHAR2,
                                 p_cursando             VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /**
   * Retorna la fecha actual en el formato que requiere la fecha de expedicion de certificados
   * @author jvelasquezv
   * @since 2015-09-16
   */
  FUNCTION FN_FECHA_EXPEDICION RETURN VARCHAR2;

   /**
   * Retorna la fecha actual en el formato que requiere la fecha de expedicion de certificados
   * @author jhfonseca
   * @since 2017-07-21
   */
  FUNCTION FN_FECHA_EXPEDICION_LOWER RETURN VARCHAR2;

  /**
   * Devuelve DEL o DE LA segun genero
   * @author jvelasquezv
   * @since 2015-09-17
   * @param p_genero Genero, puede ser alguno de los siguientes: (F,M)
   */
  FUNCTION FN_EXPRESION_DEL_A(p_genero VARCHAR2) RETURN VARCHAR2;

  /**
   * Devuelve INTERESADO o INTERESADA segun genero
   * @author jvelasquezv
   * @since 2015-09-17
   * @param p_genero Genero, puede ser alguno de los siguientes: (F,M)
   */
  FUNCTION FN_EXPRESION_INTERESADO_A(p_genero VARCHAR2) RETURN VARCHAR2;

  /**
   * Devuelve IDENTIFICADO o IDENTIFICADA segun genero
   * @author jvelasquezv
   * @since 2015-09-17
   * @param p_genero Genero, puede ser alguno de los siguientes: (F,M)
   */
  FUNCTION FN_EXPRESION_IDENTIFICADO_A(p_genero VARCHAR2) RETURN VARCHAR2;

  /**
   * Devuelve MATRICULADO o MATRICULADA segun genero
   * @author jvelasquezv
   * @since 2015-09-17
   * @param p_genero Genero, puede ser alguno de los siguientes: (F,M)
   */
  FUNCTION FN_EXPRESION_MATRICULADO_A(p_genero VARCHAR2) RETURN VARCHAR2;

  /**
   * Devuelve el tipo al que pertecene el plan de estudios (H para Horas, C para creditos)
   * @author jvelasquezv
   * @since 2015-10-07
   * @param p_plan_estudio Plan de estudio
   */
  FUNCTION FN_TIPO_PLAN_ESTUDIO(p_plan_estudio VARCHAR2) RETURN VARCHAR2;

  /**
   * Convierte el valor del nivel en letras
   * @author jvelasquezv
   * @since 2015-10-07
   * @param p_plan_estudio Plan de estudio
   */
  FUNCTION FN_NIVELES_IDIOMA_LETRAS(p_nivel VARCHAR2) RETURN VARCHAR2;

  /**
   * Genera el texto indicando el articulo correspondiente para Reintegro
   * @author jhfonseca
   * @since 2015-11-18
   * @param p_tipo_de_ingreso Tipo de ingreso del estudiante
   * @param p_codigo_estudiante codigo de estudiante
   * @param p_codigo_estudiante codigo de estudiante
   */
  FUNCTION FN_TITULO_REINTEGRO(p_tipo_de_ingreso VARCHAR2,
                               p_codigo_estudiante VARCHAR2,
                               p_grupo_certificado NUMBER) RETURN VARCHAR2;

  /**
   * Devuelve  una promedio en texto 4,5 Cuatro Cinco
   * @author lcsuarez
   * @since 2016-03-17
   */
  PROCEDURE PR_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2) ;

  /**
   * Devuelve  una promedio en texto 4,5 Cuatro Cinco
   * @author jhfonseca
   * @since 2016-09-06
   */
  FUNCTION FN_HISTORIA_ACAD_NUMERO(p_nota VARCHAR2) RETURN VARCHAR2;

    FUNCTION GET_ALPHABETIC_VALUE (
        P_NUMBER VARCHAR2
    ) RETURN VARCHAR2;

  /**
   *  Valida si una cadena es numerico
   */
  FUNCTION IS_NUMBER(str in varchar2) return NUMBER ;

  /**
   * Nombre de la jornada, si el programa tiene multiples jornadas se debe
   * enviar la jornada en caso contrario no debe aparecer en el certificado
   *
   * @author jhfonseca
   * @since 2016-01-30
   */
  FUNCTION FN_JORNADA(codigo_jornada in VARCHAR2, jornada_facultad  in VARCHAR2) RETURN VARCHAR2;

  /**
   * retorna la fecha con formato para certificados
   *
   * @author jhfonseca
   * @since 2017-02-23
   */
  FUNCTION FN_FORMAT_FECHA(fecha in DATE) RETURN VARCHAR2;

  /**
   * Retorna el nombre de un ciclo academico pero en lugar de ciclo dice PERIODO
   * @author jhfonseca
   * @since 2017-03-07
   * @param p_numero_ciclo Numero de ciclo conformado por dos numeros, si es un solo digito a la izquierda debe tener un cero
   */
  FUNCTION FN_CICLO_ACADEMICO_LPERIODO(p_numero_ciclo VARCHAR2, p_ciclo_real VARCHAR2) RETURN VARCHAR2;


  /**
   * Retorna el codigo correcto segun el servicio
   * @author jhfonseca
   * @since 2017-05-31
   * @param p_id_tipo_documento id del tipo de documento
   */
  FUNCTION FN_TIPO_DOCUMENTO(p_id_tipo_documento VARCHAR2) RETURN VARCHAR2;
  
  /**
   * Retorna el codigo correcto segun el servicio
   * @author jdcarranza
   * @since 2018-09-11
   * @param p_valor valor del tipo de documento
   */
  FUNCTION FN_TIPO_DOCUMENTO_TILDE(p_valor VARCHAR2) RETURN VARCHAR2;

   /**
   * Retorna ESTA, ESTUVO o null para el grupo de matricula en que se clasifica el estudiante
   * @author jvelasquezv
   * @since 2015-09-14
   * @param p_grupo_matricula (MATRICULADO_NUEVO_SIN_PREMATRICULA, MATRICULADO_CON_PREMATRICULA, RETIRADO)
   */
  FUNCTION FN_ESTADO_MATRICULA(p_grupo_matricula VARCHAR2) RETURN VARCHAR2;

   /**
   * Retorna EN, HASTA o null para el grupo de matricula en que se clasifica el estudiante
   * @author jvelasquezv
   * @since 2015-09-14
   * @param p_grupo_matricula (MATRICULADO_NUEVO_SIN_PREMATRICULA, MATRICULADO_CON_PREMATRICULA, RETIRADO)
   */
  FUNCTION FN_PREPOSICION_MATRICULA(p_grupo_matricula VARCHAR2) RETURN VARCHAR2;

  /**
   * Retorna el id del estado cliente segun las validaciones que determinan el tipo de estudiante
   * @author jhfonseca
   * @since 2017-06-09
   * @param p_codigo_estudiante codigo de estudiante
   */
   FUNCTION FN_TIPO_ESTUDIANTE(p_codigo_estudiante VARCHAR2, v_grupo_estudiante VARCHAR2) RETURN NUMBER;

   /**
   * Retorna el id del estado cliente segun las validaciones que determinan el tipo de estudiante
   * @author jhfonseca
   * @since 2018-01-24
   * @param p_codigo_estudiante codigo de estudiante
   */
   FUNCTION FN_CICLO_EN_REINTEGRO(p_ciclo_terminacion VARCHAR2, p_anio_terminacion VARCHAR2, p_ciclo_cursado VARCHAR2, p_anio_cursado VARCHAR2) RETURN NUMBER;
   
   /**
   * Retorna el un contador indicando si el estudiante de pregrado está registrado como graduado pero tiene materias pendientes
   * @author jdcarranza
   * @since 2018-08-06
   * @param p_codigo_estudiante codigo de estudiante
   */
   FUNCTION FN_GRADUADO_MAT_PEND(p_codigo_estudiante VARCHAR2,v_esquema VARCHAR2) RETURN NUMBER;

   /**
   * Retorna el periodo de un programa en letras
   * @author jdcarranza
   * @since 2019-03-14
   */
  FUNCTION FN_NUMEROS_ORDINALES(p_numero VARCHAR2) RETURN VARCHAR2;

END SP_CE_ACADEMICO_UTIL;