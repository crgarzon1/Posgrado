create or replace package pkg_admisiones
as
  function getPeriodo(p_programa varchar2) return varchar2;

  function getTexto(p_clave varchar2) return varchar2;

  function estaInscrito(p_documento varchar2, p_programa varchar2, p_jornada varchar2) return number;

  function fueEstudiante(p_documento varchar2, p_snp varchar2 default '-') return number;
  
  procedure getInteresado(p_parametro in nclob);

  function esAutorizadoPrograma(p_documento varchar2, p_programa varchar2, p_jornada varchar2, p_anio varchar2, p_ciclo varchar2) return number;

  function esSPPxDocumento(p_documento varchar2, p_facultad varchar2) return number;

  function esSPP(p_documento varchar2) return number;
  
  Function Tieneinscripcionsnp(P_Numsnp Varchar2, P_Programa Varchar2, P_Jornada Varchar2) Return Number;
  
  Procedure Validarparte1(P_Numdoc Varchar2, P_Tipdoc Varchar2, P_Programa Varchar2, P_Jornada Varchar2);
  
  procedure validarParte2(p_numdoc varchar2, p_tipdoc varchar2, p_programa varchar2, p_jornada varchar2, p_numsnp Varchar2);

  procedure saveAspiratOnePre(
        p_tipdoc varchar2,
        p_numdoc varchar2,
        p_codigo_facultad varchar2,
        p_jornada_facultad varchar2,
        p_primer_nombre varchar2,
        p_segundo_nombre varchar2,
        p_primer_apellido varchar2,
        p_segundo_apellido varchar2,
        p_celular varchar2,
        p_email varchar2,
        p_origen varchar2,
        p_anio varchar2,
        p_ciclo varchar2);

  procedure savePartOne(
        p_tipdoc varchar2,
        p_numdoc varchar2,
        p_codigo_facultad varchar2,
        p_jornada_facultad varchar2,
        p_primer_nombre varchar2,
        p_segundo_nombre varchar2,
        p_primer_apellido varchar2,
        p_segundo_apellido varchar2,
        p_celular varchar2,
        p_email varchar2,
        p_origen varchar2,
        p_anio varchar2,
        p_ciclo varchar2);

  procedure salvarParte1(p_parametro in nclob);

  procedure getAspirante(p_parametro in nclob);

  function fnc_getnombrecolegio(
        p_vc_codigo in varchar2)
    return varchar2;

  function fnc_getcodigoinscripcion(
        p_vc_programa  in varchar2,
        p_vc_jornada   in varchar2,
        p_vc_documento in varchar2)
    return varchar2;

  function fnc_getnombrepais(
        p_vc_codigo in varchar2)
    return varchar2;

  procedure salvarDatosComplemen(
        p_parametro in nclob);

  procedure getTimeline(p_codigo number, p_programa varchar2);

  procedure getPaises;

  procedure getDepartamentos(
        id_pais doctorados.doc_paises.id_pais%type
    );

  procedure getMunicipios(
        p_codigo_departamento a_divipola.codigo_departamento%type
    );

  procedure getEntrevistas(
        p_programa a_programacion_entrevistas.codigo_facultad%type
    );

  Function Tienedatosfacturacompletos(P_Vc_Codigo Varchar2) Return Number;
  
  Function Tienepagoincripcion(P_Vc_Codigo Varchar2) Return Number;
  
  Procedure Validarfacturainscripcion(P_Codigo Varchar2, P_Programa Varchar2, P_Jornada Varchar2);
  
  procedure getDatosFactura(P_Parametro In Nclob) ;
  
  Function Tieneinscripcionspp(P_Vc_Documento Varchar2) Return Number;
  
  Function EstaMatriculado (P_Vc_Documento Varchar2) Return Number;
  
  procedure continuarProceso(
        p_parametro in nclob
    );
  
  procedure getMundo;

  procedure getEncSatisfaccion (
        p_id_encuesta number default 1
    );
  
  procedure guardarEncuesta(
    p_codigo varchar2,
    p_parametro varchar2
    );

  procedure getResultado(
    p_codigo in number,
    o_mensaje out number,
    o_encuesta out number,
    o_guia_activa out number
);

  function getStatusPrograma(p_programa varchar2, p_jornada varchar2, p_status varchar2) return number;

  function cerradoExtemporaneo(p_programa varchar2, p_jornada varchar2) return number;

  function estaCerrado(p_programa varchar2, p_jornada varchar2) return number;

  function estaAbierto(p_programa varchar2, p_jornada varchar2) return number;

  function esAutorizadoExtranjero(p_documento varchar2, p_anio varchar2, p_ciclo varchar2) return number;

  function getString(
    p_campo varchar2,
    p_json Json,
    obligatorio number default 1) return varchar2;

  function admisionAbierta(
    p_facultad a_admision_anticipada.codigo_facultad%type,
    p_jornada a_admision_anticipada.jornada_facultad%type
) return number;

procedure salvarFoto (
    p_codigo number,
    p_ruta a_carnet_url.url%type
);

procedure crearUC (
    p_token in varchar2,
    p_tipo out numeric,
    p_uc out varchar2
);

procedure consultarUC(
    p_token varchar2
);

Function Estaentransferencias(P_Documento Varchar2, p_anio Varchar2, p_ciclo Varchar2) Return Number;

FUNCTION ESAUTORIZADOTRANSFERENCIAS(P_DOCUMENTO VARCHAR2, P_ANIO VARCHAR2, P_CICLO VARCHAR2) RETURN NUMBER;

FUNCTION tieneAutorizacionPadres(P_DOCUMENTO VARCHAR2) RETURN NUMBER;

end pkg_admisiones;