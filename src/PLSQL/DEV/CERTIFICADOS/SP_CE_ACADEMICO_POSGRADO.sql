create or replace PACKAGE SP_CE_ACADEMICO_POSGRADO IS
  /**
  * Paquete con consultas para usar como fuente de datos de las bandas de los certificados de estudios academicos de posgrado
  * @author: jvelasquezv
  * @since: 2015-07-31
  * @modified 2015-10-26 El tipo de docuemnto en todas las fuentes, se toma de admisiones.a_tipo_documento, convitiendo previamnete las contraseñas a cedula
  */

  -------------------------------------------------------------------------------------------------------------------------
  -- ATRIBUTOS
  -------------------------------------------------------------------------------------------------------------------------

  --Registro para almacenar informacion obtenida desde cursores de asignaturas
  TYPE ASIGNATURA IS RECORD(
    codigo                       admisiones.a_materias.codigo%TYPE,
    nombre                       admisiones.a_materias.nombre%TYPE,
    semestre                     admisiones.a_materias.semestre%TYPE,
    creditos                     admisiones.a_materias.creditos%TYPE,
    intensidad_horaria           admisiones.a_materias.intensidad_horaria%TYPE,
    horas_trabajo_independiente  admisiones.a_materias.hor_trabajo_independiente%TYPE,
    total_filas                  NUMBER,
    total_hti           NUMBER,
    total_creditos         NUMBER,
    total_ih           NUMBER);

  --Instancia del registro ASIGNATURA
  v_asignatura ASIGNATURA;


  -------------------------------------------------------------------------------------------------------------------------
  -- PROCEDIMIENTOS
  -------------------------------------------------------------------------------------------------------------------------
  /**
  * Escribe en formato JSON el texto de encabezado de la certificacion de terminacion de materias en posgrado del codigo de estudiante de que llega como parametro
  * @author jvelasquezv
  * @since 2015-07-31
  */
  PROCEDURE PR_TERMINACION_PLAN_JSON(p_codigo_estudiante varchar2);

  /**
  * Escribe en formato JSON el texto de encabezado de la certificacion de terminacion de materias con fecha de graduacion y titulo a otorgar en posgrado del codigo de estudiante de que llega como parametro
  * @author jvelasquezv
  * @since 2015-08-10
  * @modified 2015-08-26 Se agrega condicion para no tener en cuenta los graduados
  * @modified 2015-08-27 Si el programa no tiene titulo a otorgar se lanza la excepcion personalizada: -20003, 'Programa sin título a otorgar.'
  * @modified 2015-08-27 El cursor se recorre con FETCH para poder lanzar excepcion dentro del bucle
  * @modified 2015-09-14 Se reemplazan expresiones del titulo a otorgar
  */
  PROCEDURE PR_TERMINACION_PLAN_FGRAD_JSON(p_codigo_estudiante varchar2);

  /**
   * Escribe en formato JSON el texto de encabezado para un certificado de estudios de cualquier estudiante de posgrado que cursa o ha cursado algun periodo academico
   * @author jhfonseca
   * @since  2015-08-26
   * @modified jvelasquezv 2015-09-14 Se adiciona el grupo MATRICULADO_NUEVO_SIN_PREMATRICULA porque tienen un tratamiento diferente y al grupo MATRICULADO_CON_PREMATRICULA se le adiciona relacion con la prematricula del esquema cactualpos
   * @modified jvelasquezv 2015-10-07 Si es un estudiante retirado se toma el maximo plan del maximo periodo: Como existen planes cuyo valor es una letra,
   * y estos planes son anteriores a los numericos, se convierte el plan a ascci y si es numerico se multiplica por 1000 para que los planes numericos sean mayores a los de letras,
   * luego de obtener el maximo plan se hace lo contrario que es obtener el valor original
   */
  PROCEDURE PR_CERTIFICADO_ESTUDIO_JSON(p_codigo_estudiante VARCHAR2);

  /**
   * Escribe en formato JSON el texto de encabezado para un certificado de estudios de un estudiante activo de posgrado "estudiante matriculado en el ciclo actual"
   * @author jvelasquezv
   * @since  2015-09-14
   */
  PROCEDURE PR_CERTIFICADO_ESTUDIO_AC_JSON(p_codigo_estudiante VARCHAR2);

  /**
   * Escribe en formato JSON el texto de encabezado para un certificado de estudios de un estudiante inactivo de posgrado "estudiante que curso materias pero no esta matriculado en el ciclo actual"
   * @author jvelasquezv
   * @since  2015-09-22
   * @modified jvelasquezv 2015-10-07 Se toma el maximo plan del maximo periodo: Como existen planes cuyo valor es una letra,
   * y estos planes son anteriores a los numericos, se convierte el plan a ascci y si es numerico se multiplica por 1000 para que los planes numericos sean mayores a los de letras,
   * luego de obtener el maximo plan se hace lo contrario que es obtener el valor original
   */
  PROCEDURE PR_CERTIFICADO_ESTUDIO_IN_JSON(p_codigo_estudiante VARCHAR2);

  /**
   * Escribe en formato JSON la informacion de horario de las materias que prematriculo un estudiante de posgrado
   * @author jhfonseca
   * @since  2015-09-01
   * @modificacion jvelasquezv 2015-09-14 Se modifica para que tambien relacione con la prematricula y horario de cactualpre ya que cuando se hace cierre para horarios mueven informacion a este esquema
   */
  PROCEDURE PR_HORARIO_ESTUDIO_JSON(p_codigo_estudiante VARCHAR2);

  /**
   * Escribe en formato JSON las materias de primer semestre del maximo plan de un programa
   * @author jvelasquezv
   * @since  2015-09-11
   */
  PROCEDURE PR_MATERIAS_PRIMER_SEM_JSON(p_codigo_programa VARCHAR2,
                                        p_jornada         VARCHAR2);

   /**
    * Escribe en formato JSON las materias que cursa un estudiante matriculado de posgrado
    * @author jvelasquezv
    * @since  2015-09-11
    * @modified jvelasquezv 2015-10-27 En lugar de hacer left join con postgrado.b_prematricula y con cactualpos.b_prematricula
    * se hace union entre postgrado.b_prematricula y cactualpos.b_prematricula, pues despues de un cierre para horarios la prematricula
    * del estudiante estara en las dos tablas generando un producto cartesioano
    */
  PROCEDURE PR_MATERIAS_MATRICULO_ACT_JSON(p_codigo_estudiante VARCHAR2);

   /**
    * Escribe en formato JSON las materias del ultimo periodo cursado  de un estudiante retirado de posgrado
    * @author jvelasquezv
    * @since  2015-09-11
    */
  PROCEDURE PR_MATERIAS_MATRICULO_RET_JSON(p_codigo_estudiante VARCHAR2);

  /**
   * Escribe en formato JSON una asignatura
   * @author jvelasquezv
   * @since 2015-09-11
   * @param p_asignatura Registro con los campos necesarios para armar objeto asignatura en estructura JSON
   */
  PROCEDURE PR_ESCRIBIR_ASIGNATURA_JSON(p_asignatura ASIGNATURA);

  /**
   * Devuelve en formato JSON el texto de la historia academica del estudiante
   * @author jhfonseca
   * @since 2016-06-15
   */
  PROCEDURE PR_HISTORIA_ACAD_JSON(p_codigo_estudiante VARCHAR2);

    FUNCTION GET_NOTAS_BOLSA_CREDITOS(P_CODIGO_ESTUDIANTE VARCHAR2) RETURN JSON_LIST;
    
    /**
   * Devuelve en formato JSON los annos y ciclos en que el estudiante vio materias
   * @author jhfonseca
   * @since 2016-06-15
   */
  FUNCTION PR_HISTORIA_ACAD_PERIODOS(p_codigo_estudiante VARCHAR2) RETURN JSON_LIST;

   /**
   * Devuelve el listado de materias para un anno y ciclo
   * @author jhfonseca
   * @since 2016-06-15
   */
  FUNCTION PR_HISTORIA_ACAD_MATERIAS(p_codigo_estudiante VARCHAR2, p_ano VARCHAR2, p_ciclo VARCHAR2) RETURN JSON_LIST;
  
   /**
   * Recupera en formato JSON las materias del plan de estudios
   * 
   * @author jdcarranza
   */
  PROCEDURE PR_PLAN_DE_ESTUDIO(p_codigo_estudiante VARCHAR2);
  
   /**
   * Recupera el puesto ocupado por el estudiante en su cohorte de grado y el número de egresados en formato JSON
   * 
   * @author jdcarranza
   * @since  11-03-2019
   */
  PROCEDURE PR_PUESTO_OCUPADO(p_codigo_estudiante VARCHAR2);

END SP_CE_ACADEMICO_POSGRADO;