create or replace package pkg_utils as 
    function getTopes(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type
    )return json_list;
    function getBolsas(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type
    )return json_list;
    function getPlan(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type,
        p_bolsas number default 0,
        p_topes number default 0
    )return json;
    function getPlanes(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_bolsas number default 0,
        p_topes number default 0
    )return json_list;
    function getFacultad(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_planes number default 0,
        p_bolsas number default 0,
        p_topes number default 0
    )return json;
    function getMateria(
        p_codigo_facultad a_materias.codigo_facultad%type,
        p_jornada_facultad a_materias.jornada_facultad%type,
        p_plan_estudio a_materias.plan_estudio%type,
        p_codigo a_materias.codigo%type,
        p_facultad number default 0,
        p_plan number default 0
    )return json;
    function getMaterias(
        p_codigo_facultad a_materias.codigo_facultad%type,
        p_jornada_facultad a_materias.jornada_facultad%type,
        p_plan_estudio a_materias.plan_estudio%type,
        p_semestre number default 1
    )return json_list;
    function getGrupo(
        p_consecutivo a_horario_horizontal.consecutivo%type,
        p_abierto number default 1
    )return json;    
    FUNCTION EVALUAR_PAGO_ESTUDIANTE (
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN NUMBER;
    FUNCTION EVALUAR_PAGO (
        P_INDICADOR B_ESTUDIANTES.INDICADOR_PAGO%TYPE
    ) RETURN NUMBER;
    FUNCTION GET_INDICADOR_PAGO(
        P_ID_PERIODO CTI_PERIODO.ID_PERIODO%TYPE
    ) RETURN CTI_PERIODO.INDICADOR_PAGO%TYPE;
    function getEstudiante(
        p_codigo b_estudiantes.codigo%type
    ) return json;
    function getTipoMatricula(
        p_codigo b_estudiantes.codigo%type
    ) return json;
    procedure getPerfiles (
        token varchar2
    );
    PROCEDURE GETMENU(
        TOKEN VARCHAR2
    );
    
    FUNCTION GETMENUITEM(
        P_ID_PROCESO NUMBER
    ) RETURN JSON;
    
    PROCEDURE GET_CODIGO_ESTUDIANTE (
        TOKEN VARCHAR2
    );
    
    PROCEDURE GET_PORTAL_INFO;
    
end pkg_utils;