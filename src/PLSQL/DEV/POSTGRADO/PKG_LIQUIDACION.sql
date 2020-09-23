create or replace package pkg_liquidacion as 

    function parametroToJSON(
        r_param admisiones.a_parametros%rowtype
    ) return json;
    procedure validarLiquidacion(
        p_codigo b_estudiantes.codigo%type,
        p_id_periodo cti_periodo.id_periodo%type
    );
    procedure liquidar(
        p_codigo b_estudiantes.codigo%type,
        p_periodo cti_periodo.id_periodo%type,
        p_creditos_add admisiones.g_guias_de_pago.total_cred_adicionales%type default 0,
        p_semestre cti_creditos_periodo.semestre%type default 1
    );
    procedure liquidar_aspirante(
        p_codigo in a_aspirantes.cod_def%type,
        p_periodo in cti_periodo.id_periodo%type,
        p_creditos_add in admisiones.g_guias_de_pago.total_cred_adicionales%type,
        p_semestre in cti_creditos_periodo.semestre%type,
        o_parametro out admisiones.a_parametros%rowtype
    );
    procedure liquidar_estudiante(
        p_codigo in b_estudiantes.codigo%type,
        p_periodo in cti_periodo.id_periodo%type,
        p_creditos_add in admisiones.g_guias_de_pago.total_cred_adicionales%type,
        p_semestre in cti_creditos_periodo.semestre%type,
        o_parametro out admisiones.a_parametros%rowtype
    );
    procedure marcar(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type,
        p_codigo_est admisiones.g_guias_de_pago.codigo_est%type,
        p_cod_transac admisiones.g_guias_de_pago.cod_transac%type,
        p_creds admisiones.g_guias_de_pago.total_creditos_ins%type,
        p_creds_add admisiones.g_guias_de_pago.total_cred_adicionales%type,
        p_ind_1 admisiones.g_guias_de_pago.indicador_pago%type,
        p_ind_2 admisiones.g_guias_de_pago.indicador_pago%type,
        p_anio admisiones.g_guias_de_pago.anio%type,
        p_ciclo admisiones.g_guias_de_pago.ciclo%type
    );
    procedure desactivarGuia(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type
    );
    procedure marcarGuiaDesactivada(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type
    );
    function trimestreActual(
        p_admision number default 0
    ) return number;
    procedure listadoPeriodos(
        p_codigo b_estudiantes.codigo%type
    );
    FUNCTION PuedeEmitirGuiaDePago(P_CODIGO_ESTUDIANTE VARCHAR2) RETURN NUMBER;
    PROCEDURE GETGUIADEPAGOACTIVA(P_CODIGO_ESTUDIANTE VARCHAR2);
    
    FUNCTION GET_DESCUENTO(P_CODIGO_ESTUDIANTE VARCHAR2) RETURN NUMBER;
    
end pkg_liquidacion;