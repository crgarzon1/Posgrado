create or replace Procedure ls_menu_estudiante
  (
    p_usuario varchar2 default null,
    p_clave varchar2 default null,
    p_boton varchar2 default null,
    p_cod varchar2 default nulL
  )
IS
  CVPERCUPO                  varchar2(500) default null;
  VPEVALUACION               varchar2(500) default null;
  VPPERCUPO                  varchar2(500) default null;
  VPDOCUMENTOS               varchar2(500) default null;
  VPFECHAS                   varchar2(500) default null;
  VPDATOSPER                 varchar2(500) default null;
  VPDEUDAFIN                 varchar2(500) default null;
  VPDEUDABIB                 varchar2(500) default null;
  VPDOCUEX                   varchar2(1000) default null;
  VPACTDAT                   varchar2(1000) default null;
  VPDDESCARGAGUIA            varchar2(1000) default null;
  VPMATRICULADO              varchar2(1000) default null;
  VPCARACTERIZACION          varchar2(1000) default null;
  v_tipoest                  varchar2(7) default null;
  v_TIENE_NOTAS              number default 0;
  v_nombre_usuario           a_usuarios.nombre_usuario%type default null;
  v_usuario                  varchar2(4) := P_USUARIO;
  v_clave                    varchar2(4) := P_clave;
  vconsultas                 a_usuarios.nconsultas%type default null;
  v_indicador_pago           b_estudiantes.indicador_pago%type default null;
  p_codigo                   b_estudiantes.codigo%type default null;
  v_numero_acta              a_graduados.numero_acta%type default null;
  v_fecha_grado              a_graduados.fecha_grado%type default null;
  v_existe_egresado          number default 0;
  v_ultimo_ciclo_cursado     varchar2(6) default null;
  v_ultimo_anio              number default 0;
  v_ultimo_ciclo             number default 0;
  v_inicio                   number default 0;
  v_final                    number default 0;
  v_cancelo_despues          number default 0;
  v_plan_creditos            number default 0;
  v_ciclo_de_ingreso         b_estudiantes.ciclo_de_ingreso%type default null;
  v_tipo_de_ingreso          b_estudiantes.tipo_de_ingreso%type default null;
  v_fecha_ingles_inicial     varchar2(8) default NULL;
  v_fecha_ingles_final       varchar2(8) default NULL;
  v_fecha_sistemas_inicial   varchar2(8) default NULL;
  v_fecha_sistemas_final     varchar2(8) default NULL;
  v_fecha                    varchar2(15);
  v_fecha_iniciori           DATE DEFAULT NULL;
  v_fecha_finalizacionri     DATE DEFAULT NULL;
  v_fecha_publicacion        DATE DEFAULT NULL;
  v_hizo_reintegro           NUMBER DEFAULT 0;
  v_inscrito_csi             number default 0;
  v_fecha_iniciohorcurvac    DATE DEFAULT NULL;
  v_fecha_iniciocv           DATE DEFAULT NULL;
  v_fecha_finalizacioncv     DATE DEFAULT NULL;
  v_fecha_iniconhorcurvac    DATE DEFAULT NULL;
  v_fecha_finconhorcurvac    DATE DEFAULT NULL;
  v_cambio_jornada           number default 0;
  v_mensaje                  varchar2(1000);
  v_fechapublireint_ini      a_fechas_de_corte.fecha_inicio%type default null;
  v_fechapublireint_fin      a_fechas_de_corte.fecha_finalizacion%type default null;
  v_solicito_reintegro       number default 0;
  v_fecha_concepto_facultad  DATE DEFAULT NULL;
  v_fecha_concepto_vrac      DATE DEFAULT NULL;
  v_concepto_facultad        A_SOLICITUD_REINTEGRO.CONCEPTO_FACULTAD%TYPE DEFAULT NULL;
  v_jornada_solicitada       varchar2(10) DEFAULT NULL;
  v_plan_CARACTER            varchar2(20) DEFAULT NULL;
  v_jor_actual               varchar2(20) DEFAULT NULL;
  v_jor_aprobada             varchar2(20) DEFAULT NULL;
  v_concepto_vrac            a_solicitud_reintegro.concepto_vrac%type default null;
  v_jornada_actual           a_estudiantes.jornada_facultad%type default null;
  v_plan_estudio             a_solicitud_reintegro.plan_estudio%type default null;
  v_jornada_aprobada         a_solicitud_reintegro.jornada_aprobada%type default null;
  V_TIPO_REINTEGRO           A_SOLICITUD_REINTEGRO.TIPO_REINTEGRO%TYPE DEFAULT NULL;
  v_plan_char varchar2(30)   default null;
  v_jornada_aprobada_char    varchar2(30) default null;
  v_ciclo_nuevos varchar2(5) default null;
  v_fechapub_cambiojorini    a_fechas_de_corte.fecha_inicio%type default null;
  v_fechapub_cambiojorfin    a_fechas_de_corte.fecha_finalizacion%type default null;
  v_indicador                number default 0;
  v_maximainscrip_idiomas    varchar2(10) DEFAULT NULL;
  v_minimainscrip_idiomas    varchar2(10) DEFAULT NULL;
  v_EJEMPLO VARCHAR2(10)     DEFAULT NULL;
  v_materias_pendientes      number default 0;
  v_NumeroError              NUMBER;
  v_TextoError               varchar2(200);
  v_cicloNEW varchar2(5)     default null;
  v_esextranjero             number default 0;
  v_aviso1_extranjeros       varchar2(1000);
  v_aviso2_extranjeros       varchar2(1000);
  v_aviso3_extranjeros       varchar2(1000);
  v_aviso4_extranjeros       varchar2(1000);
  v_debedocext1              number default 0;
  v_debedocext2              number default 0;
  v_debedocext3              number default 0;
  v_fechainigui_antiguos     varchar2(8) default null;
  v_fechafingui_antiguos     varchar2(8) default null;
  v_fechaini_curvac          varchar2(8) default null;
  v_fechafin_curvac          varchar2(8) default null;
  v_tiene_cursos             number default 0;
  v_guia_semestre            number default 0;
  v_expulsado                number default 0;
  v_final_prematricula       a_ciclos_academicos.final_prematricula%TYPE;
  v_reintegro                NUMBER(2);
  v_existe_cr                PLS_INTEGER;
  v_existe_hr                PLS_INTEGER;
  v_fecha_eliminacion        varchAr2(14) DEFAULT NULL;
  v_usuarioq_modifico        b_prematricula_invalidos.nombre_usuario%type default null;
  p_opcion                   varchar2(50) default null;
  v_Inicio_Nuevos            A_CICLOS_ACADEMICOS.INICIO_NUEVOS%TYPE DEFAULT NULL;
  v_Final_Nuevos             A_CICLOS_ACADEMICOS.FINAL_NUEVOS%TYPE DEFAULT NULL;
  v_ind_pago                 b_estudiantes.indicador_pago%type default null;
  v_ciclo_ingre              b_estudiantes.ciclo_de_ingreso%type default null;
  v_tipo_ingreso             b_estudiantes.tipo_de_ingreso%type default null;
  v_mater_pend               b_estudiantes.materias_pendientes%type default null;
  v_yavoto                   number default 0;
  V_MATRICULADOANTES         B_ESTUDIANTES.INDICADOR_PAGO%TYPE DEFAULT NULL;
  v_tiene_prematricula       number default 0;
  v_codfac b_estudiantes.codigo_facultad%type default null;
  v_indjor b_estudiantes.jornada_facultad%type default null;
  v_joraprob NUMBER DEFAULT 0;
  v_inivot a_fechas_de_corte.fecha_inicio%type default null;
  v_finvot a_fechas_de_corte.fecha_finalizacion%type default null;
  v_ciclo  varchar2(5) default null;
  v_homologado number default 0;
  v_indpagovot B_ESTUDIANTES.INDICADOR_PAGO%TYPE DEFAULT NULL;
  v_maximafechainscripc_idiomas varchar2(10) default null;
  v_cicloactual number;
  v_noprem number default 0;
  V_EXISTE_GRAD NUMBER DEFAULT 0;
  v_turno       number default 0;
  v_esta_en_turnos       number default 0;
  V_ES_NUEVO             number default 0;
  V_SASD             number default 0;
  V_ESTADO_SASD      A_PERIODO_PRUEBA.INDICADOR%TYPE DEFAULT NULL;
  V_PER1             NUMBER                          DEFAULT 0;
  V_NIW              A_ASPIRANTES.CODIGO%TYPE DEFAULT NULL;
  V_HAY_ASPIRANTES   NUMBER                   DEFAULT 0;
  v_tipo_doc         varchar2(5);
  v_numdoc           datos_personales.numero_documento%type default null;
  v_fecha_nacimiento datos_personales.fecha_nacimiento%type default null;
  v_tiene_datosper   number default 0;
  v_tiene_matricula  number default 0;
  V_Ciclo_Bak        Varchar2(100) Default Null;
  V_GRADUADO         NUMBER DEFAULT 0;
  
  
  cursor turnos is
  select
  SUBSTR(T.FECHA,7,2)||'-'||DECODE(SUBSTR(T.FECHA,5,2),'01','ENE','02','FEB','03','MAR','04','APR','05','MAY','06','JUN','07','JUL','08','AUG','09','SEP','10','OCT','11','NOV','12','DIC')||'-'||SUBSTR(T.FECHA,1,4) FECHA,
  SUBSTR(T.HORA,1,2)||'-'||SUBSTR(T.HORA,3,2) HORA
  from turnos_estudiantes t
  where  t.codigo=p_coDIGO;

  v_yndpago varchar2(100) default '';
  v_plan    varchar2(100) default '';
  v_correo_institucional                correos_institucionales.correo%type default null;
  v_tiene_correo_institucional          number                              default 0;
  v_tiene_turno       number default 0;
  v_esri              number default 0;
  v_egresado_no_graduado number default 0;
  v_ind_ing number;
  v_anio_act varchar2(4);
  v_ciclo_act varchar2(2);
  v_esquema_act varchar2(32);
    v_sem_inf number;
    v_cred_max number;
    v_cred_ins number;
  v_enc_plan_estra number default 0;

    v_ipago b_estudiantes.indicador_pago%type;
    
    c_usuario a_usuarios.usuario%type;
    c_clave a_usuarios.clave%type;
    c_documento a_usuarios.numero_documento%type;
    c_codigo a_usuarios.codigo%type;
    c_nombre a_usuarios.nombre_usuario%type;
    
    c_tiene_summer number;
    c_ins_clus number;

    n_es_postgradual number;

Begin
    --SUBIR_NOTAS.conteo_materias_pendientes(p_codigo);
    pkg_utils.getAnioCicloEsquema(1, v_anio_act, v_ciclo_act, v_esquema_act);

    /*
    Es if contiene la logica para autenticar por cookie.
    Si el usuario tiene perfil 007 es la OAR.
    */
    if v_usuario is null then
        pkg_utils.p_leer_cookie(c_usuario, c_clave, c_documento, c_codigo, c_nombre);
        if c_codigo in ('007') and p_cod is not null and regexp_like(p_cod, '^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$') then
            begin
                select u.usuario,
                    u.clave,
                    u.codigo
                into v_usuario,
                    v_clave,
                    p_codigo
                from a_usuarios u
                where u.codigo = p_cod;
            exception
            when no_data_found then
                raise_application_error(-20000, 'Estudiante no valido.');
            end;
        else
            raise_application_error(-20000, 'Usuario no autorizado: ' || c_nombre);
        end if;
    end if;

  -- Votaciones estudiantes
  SELECT fc.fecha_inicio,fc.fecha_finalizacion
  into   v_inivot,v_finvot
  FROM   A_FECHAS_DE_CORTE FC
  where  SUBSTR(fc.proceso,1,26) like '%VOTACIONES ESTUDIANTES%';

  -- Guias antiguos
  select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
  into   v_fechainigui_antiguos,v_fechafingui_antiguos
  from   a_fechas_de_corte fc
  where  SUBSTR(fc.proceso,1,23)='GUIAS ANTIGUOS PREGRADO';

  -- Guias intersemestrales
  /*select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
  into   v_fechaini_curvac,v_fechafin_curvac
  from   a_fechas_de_corte fc
  where  SUBSTR(fc.proceso,1,22)='GUIAS INTERSEMESTRALES';*/

  -- Documentos extranjeros
  v_aviso1_extranjeros:='A la fecha su Visa, Cédula de Extranjería y Autorización para adelantar estudios en la universidad se encuentran vencidos. Recuerde que la renovación de estos documentos debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalización de los estudios y la obtención del título respectivo. De lo contrario no podrá realizar ningún trámite Académico (reintegro, inscripción de asignaturas, etc.).\nPara renovar la autorización debe acercarse a la Oficina de Admisiones y Registro la cuál le expedirá una constancia de estudio y una fotocopia de la Personería Jurídica de la Universidad, dicho trámite debe realizarlo en el Ministerio de Relaciones Exteriores en la Cra. 13 No. 93-68 Of.203 Coordinacion de Visas e Inmigración.\nUna vez realizados los trámites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
  --ESTE AVISO ES SOLO PARA AUTORIZACION
  v_aviso2_extranjeros:='A la fecha su Autorización para adelantar estudios en la universidad se encuentra vencida. Recuerde que la renovación de esta autorización debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalización de los estudios y la obtención del título respectivo. De lo contrario no podrá inscribir las asignaturas correspondientes al II período de 2012.\nPara renovar la autorización debe acercarse a la Oficina de Admisiones y Registro la cuál le expedirá una constancia de estudio y una fotocopia de la Personería Jurídica de la Universidad, dicho trámite debe realizarlo en el Ministerio de Relaciones Exteriores en la Cra. 13 No. 93-68 Of.203 Coordinacion de Visas e Inmigración.\nUna vez realizados los trámites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
  --ESTE AVISO ES SOLO PARA VISA
  v_aviso3_extranjeros:='A la fecha su Visa se encuentra vencida. Recuerde que la renovación de este documento debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalización de los estudios y la obtención del título respectivo. De lo contrario no podrá inscribir las asignaturas correspondientes al I período de 2012.\nDebe acercarse a la Oficina de Admisiones y Registro donde se le entregará carta informativa.\nUna vez realizados los trámites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
  --ESTE AVISO ES SOLO PARA CEDULA
  v_aviso4_extranjeros:='A la fecha su Cédula de Extranjería se encuentra vencida. Recuerde que la renovación de este documento debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalización de los estudios y la obtención del título respectivo. De lo contrario no podrá inscribir las asignaturas correspondientes.\nDebe acercarse a la Oficina de Admisiones y Registro donde se le entregará carta informativa.\nUna vez realizados los trámites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';

  -- Reintegros pregrado
  select fc.Ciclo_Nuevos_Ri
  into   v_ciclo_nuevos
  from   a_fechas_de_corte fc
  where  (rtrim(SUBSTR(fc.proceso,1,19)))='REINTEGROS PREGRADO';

  v_fecha:=TO_CHAR(SYSDATE(),'YYYYMMDD');

  -- Inscripciones cursos sistemas
  SELECT TO_CHAR(FECHA_INICIO,'YYYYMMDD'),TO_CHAR(FECHA_FINALIZACION,'YYYYMMDD')
  iNTO   v_fecha_sistemas_inicial,v_fecha_sistemas_final
  FROM   A_FECHAS_DE_CORTE FC
  WHERE  SUBSTR(FC.PROCESO,1,29)='INSCRIPCIONES_CURSOS_SISTEMAS';

  -- Inscripciones cursos ingles
  SELECT TO_CHAR(FECHA_INICIO,'YYYYMMDD'),TO_CHAR(FECHA_FINALIZACION,'YYYYMMDD')
  INTO   v_fecha_ingles_inicial,v_fecha_ingles_final
  FROM   A_FECHAS_DE_CORTE FC
  WHERE  SUBSTR(FC.PROCESO,1,27)='INSCRIPCIONES_CURSOS_INGLES';

  -- Publicacion cambios de jornada
  select fc.fecha_inicio,fc.fecha_finalizacion
  into   v_fechapub_cambiojorini,v_fechapub_cambiojorfin
  from   a_fechas_de_corte fc
  where  fc.proceso LIKE '%PUBLICACION CAMBIOS DE JORNADA%';

  select fc.fecha_inicio,fc.fecha_finalizacion
  into   v_fecha_iniciocv,v_fecha_finalizacioncv
  from   a_fechas_de_corte fc
  where  rtrim(fc.proceso)='CURVAC';

  select fc.fecha_inicio,fc.fecha_finalizacion
  into   v_fecha_iniconhorcurvac,v_fecha_finconhorcurvac
  from   a_fechas_de_corte fc
  where  rtrim(fc.proceso)='CONSULTAR HINTERSEMESTRALES PARA ESTUDIANTES';

  -- Usuario y codigo
  select nombre_usuario,codigo
  into v_nombre_usuario,p_codigo
  from a_usuarios u where u.usuario=v_usuario and u.clave=v_clave;

  -- Correo institucional
  select count(*)
  into   v_tiene_correo_institucional
  from   correos_institucionales ci
  where  ci.codigo=p_codigo;
  if v_tiene_correo_institucional>0 then
     select ci.correo
    into   v_correo_institucional
    from   correos_institucionales ci
    where  ci.codigo=p_codigo;
  else
    v_correo_institucional:='No disponible';
  end if;

  -- Graduados
  SELECT COUNT(*)
  into   v_existe_grad
  from   a_graduados g
  where  g.codigo_estudiante=p_codigo;
  if v_existe_grad>0 then
     v_numero_acta:=NUMERO_ACTA(p_codigo);
  end if;

  -- Estudiante expulsado
  v_expulsado:=existe_expulsion(p_codigo);

  -- Datos del estudiante
  select be.indicador_pago,be.ciclo_de_ingreso,be.tipo_de_ingreso,be.materias_pendientes,be.codigo_facultad,be.jornada_facultad
  into   v_indicador_pago,V_CICLO_DE_iNGRESO,V_TIPO_DE_INGRESO,v_materias_pendientes,v_codfac,v_indjor
  from   b_estudiantes be
  where  be.codigo=p_codigo;

    v_ipago := v_indicador_pago;

  SELECT nvl(u.NCONSULTAS,0)+1
  INTO   VCONSULTAS
  FROM   A_USUARIOS u
  WHERE  u.usuario = v_usuario and u.clave=v_clave;

  select count(*)
  into   v_tiene_datosper
  from   datos_personales dp
  where  dp.codigo_estudiante=p_codigo;
  if v_tiene_datosper>0 then
     SELECT td.tipo, dp.numero_documento, dp.fecha_nacimiento
      INTO v_tipo_doc, v_numdoc, v_fecha_nacimiento
      FROM datos_personales dp
     INNER JOIN a_tipo_documento td
        ON dp.codtipo_documento = td.codigo
     WHERE dp.codigo_estudiante = p_codigo;
  end if;
  
  SELECT COUNT(*)
    INTO v_tiene_matricula
    FROM b_estudiantes be
   WHERE be.codigo = p_codigo
     AND be.indicador_pago IN ('P', 'V');

  select count(*) into v_tiene_turno from turnos_estudiantes where codigo=p_codigo;

  --Por solicitud de la oar se desactiva la encuesta
  --v_enc_plan_estra := 0;
  begin
      select count(*)
      into v_enc_plan_estra
      --from sie.sie_vw_encu_satis_estu@uvirtual.lasalle.edu.co
      from sie.sie_vw_encu_auto_pre_sall_estu@uvirtual.lasalle.edu.co
      where codigo = p_codigo and contesto = 'NO';
  exception
  when others then
    htp.p('<!-- ' || sqlerrm || ' -->');
  end;

  --v_tiene_turno:=0;

    --Es egresado no graduado?
    SELECT COUNT(*)
    INTO v_egresado_no_graduado
    FROM A_GRADUADOS gra
    WHERE gra.CODIGO_ESTUDIANTE = p_codigo AND
    gra.NUMERO_ACTA = 0 AND
    gra.NUMERO_DOCUMENTO NOT IN (
        SELECT sfa.DOCUMENTO FROM SIEG_FECHA_ACTUALIZACION_TEMP sfa where round((sysdate - sfa.FECHA) / 365, 1) < 1
        union
        SELECT sdb.DOCUMENTO FROM sieg.sieg_datos_basicos@uvirtual.lasalle.edu.co sdb
    );
HTP.P('
<!DOCTYPE HTML>
<html>
<head>
<title>Universidad de La Salle - Sistema de Información Académica</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script> -->
<link rel="stylesheet" href="http://zeus.lasalle.edu.co/oar/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.0/animate.min.css">
<style type="text/css">body {padding-right: 0px !important;} .modal-dialog.ancho {min-width: 98vw;} .modal-dialog.ancho .modal-body {max-height: 84vh; margin-bottom: 1vh; overflow: auto;}</style>
<script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/jquery/js/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/underscore/js/underscore-min.js"></script>
');

htp.p('<style type="text/css">
  #anuncios {
    background: url(http://zeus.lasalle.edu.co/oar/prematricula/bg_chapinero.jpg) 50% 0 fixed;
    height: auto;
    margin: 0 auto;
    width: 100%;
    position: relative;
    box-shadow: 0 0 50px rgba(0,0,0,0.8);
    padding: 5em;
  }
  #anuncios textarea {
    width: 100%;
    height: 30em;
    background-color: rgba(209,209,209,0.75);
    color: #000;
    border: none !important;
    font-weight: bolder;
    resize: none;
  }
  .thumbnail:hover{
  height: 20%;
  }

  .center {
    margin: auto;
    width: 60%;
    padding: 10px;
  }

  .label{
    background: #002547;
    color: white;
    height: 44px;
    text-align: center;
    }
</style>');
htp.p('
<script type="text/javascript">
  (function(i,s,o,g,r,a,m){i[''GoogleAnalyticsObject'']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,''script'',''//www.google-analytics.com/analytics.js'',''ga'');
  ga(''create'', ''UA-64300266-1'', ''auto'');
  ga(''send'', ''pageview'');
  if (!navigator.cookieEnabled) {
    ga(''send'', ''event'', ''estudiante'', ''cookies'', ''false'', 1);
  }
</script>
');
htp.p('<script type="text/javascript">
$(document).ready(function(){
  var waitModal;
  waitModal = waitModal || (function() {
    var pleaseWaitDiv = $(''<div class="modal fade" id="pleaseWaitDialog" data-backdrop="static" data-keyboard="false" aria-hidden="true"> <div class="modal-dialog modal-sm"> <div class="modal-content"> <div class="modal-header"> <h4 class="modal-title">Cargando...</h4> </div> <div class="modal-body"> <div class="progress progress-striped active"> <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div> </div> </div> </div> </div> </div>'');
    return {
      show: function () {
        pleaseWaitDiv.modal();
      },
      hide: function () {
        pleaseWaitDiv.modal(''hide'');
        var back = $(''.modal-backdrop'');
        if (back && back !== ''undefined'') {
          back.remove();
        }
      }
    };
  })();
  var alerta = function (tipo, txt) {
    var divalert = $(''<div class="alert alert-'' + tipo + '' fade in"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">x</button><p>'' + txt + ''</p></div>'');
    $(''#msg'').html('''');
    $(''#msg'').append(divalert);
    divalert.alert();
  };
  var cerrarAlerta = function () {
    var alerta = $(''.alert'');
    if (alerta && alerta !== ''undefined'') {
      $(''.alert'', ''#msg'').alert(''close'');
    }
  };
  var crearModal = function (titulo, url, urlclose) {
    $(''#fr-close'').attr(''src'', ''about:blank'');
    waitModal.show();
    $(''#p_codigo'').val($.trim($(''#p_codigo'').val()));
    $.ajax({
      url: ''validar_e_copia_bak'',
      data: $("#oarform").serialize() + "&p_boton=",
      type: ''post'',
      success: function (data) {
        var regex = /^[A-Fa-f0-9]+$/g;
        var dato = $.trim(data);
        if (dato == "SINTURNO" || dato == "UA26") {
          url = "http://oar.lasalle.edu.co/matricula/";
          data = "prematricula.php?arg=' || xamplecripto(trim(p_codigo), 'b9e7ad5849a30e37') || '";
          urlclose = null;
        } else if (dato == "ING1" || dato == "ING2") {
          alerta(''warning'', ''Apreciado estudiante, teniendo en cuenta que usted se encuentra en prueba académica y/o matrícula académica condicionada, y la con la intención de favorecer su permanencia en la Universidad, queremos orientarlo en su proceso de prematrícula buscando que le permita superar durante el próximo ciclo académico esta condición de prueba académica y/o matrícula académica condicionada y así continuar con su formación profesional. Por favor agendar una cita con el Asistente Académico de su programa antes del 5 de diciembre de 2019.'');
          waitModal.hide();
          return;
        }
        
        else if (dato == "fact_sab_pro") {
          alerta(''info'', ''Señor estudiante ha generado su factura de pago para Saber Pro'');
        }
        
        else if (dato == "NOCUMPLEPORC") {
          alerta(''danger'', ''Porcentaje de Creditos Aprobados debe ser mayor o igual al 75% del plan del estudiante'');
          waitModal.hide();
          return;
        }
        
        else if (!data || data == '''' || !regex.test(dato)) {
          alerta(''danger'', titulo + '': Opcion no disponible aun.'');
          waitModal.hide();
          return;
        }
        waitModal.hide();
        var ancho = $(window).width() > 1024 ? Math.ceil($(window).width() * 0.8) : $(window).width();
        var alto = Math.ceil($(window).height() * 0.8);
        var modPrem = $(''<div id="modalPrematricula" class="modal fade" role="dialog" aria-labelledby="modalPrematriculaLbl" aria-hidden="true" data-backdrop="static" data-keyboard="false"> <div class="modal-dialog ancho"> <div class="modal-content"> <div class="modal-header"><h4 id="modalPrematriculaLbl" class="modal-title"><button type="button" class="btn btn-xs btn-danger" data-dismiss="modal" aria-hidden="true" data-toggle="tooltip" data-placement="right" title="'' + titulo + '': Finalizar sesion"><span class="glyphicon glyphicon-off" aria-hidden="true"></span></button> '' + titulo + ''</h4> </div> <div class="modal-body"><iframe id="fr-prematricula" name="fr-prematricula" src="'' + url + (data == ''ABCDEF'' ? '''' : data) + ''" style="height: 75vh; width: 100%; border: none;"></iframe> </div> </div> </div> </div>'');
        modPrem.modal({keyboard: false});
        modPrem.on(''hidden.bs.modal'', function (e) {
          if (urlclose) {
            $.ajax({
              url: urlclose,
              type: ''get'',
              dataType: ''json'',
              success: function (data) {
                alerta(''success'', titulo + '': Sesion finalizada.'');
              },
              error: function (jqXHR, textStatus, errorThrown) {
                alerta(''danger'', titulo + '': Sesion finalizada. ['' + errorThrown + '']'');
              }
            });
          } else {
            if (dato == "UA26") {
              alerta(''danger'', titulo + '': Su prematricula sera realizada por la Unidad Academica.'');
            } else {
              alerta(''success'', titulo + '': Sesion finalizada.'');
            }
          }
          $(''#modalPrematricula'').remove();
        });
      },
      error: function (jqXHR, textStatus, errorThrown) {
        alerta(''danger'', errorThrown);
        waitModal.hide();
      }
    });
  };
  $("#oarform").submit(function(){
    if ($(''#p_codigo'').val() == '''') {
      alerta(''danger'', ''Digite su codigo.'');
      return false;
    }
    cerrarAlerta();
    ga(''send'', ''event'', ''estudiante'', $(''input[name=p_opcion]:checked'', ''#oarform'').val(), ''opcion'', 1);
    if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''formativas'') {
      crearModal(''Inscripcion a cursos de practicas formativas'', ''http://jupiter.lasalle.edu.co/prematriculalibres/oar/'', ''http://jupiter.lasalle.edu.co/prematriculalibres/oar/exit.oar'');
      return false;
    } else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''prematricula'') {
      crearModal(''Prematricula'', ''http://prematricula.lasalle.edu.co:8080/prematricula-nv/app/init/'', null);
      return false;
    } else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''consulta_prematricula'') {
      crearModal(''Consulta prematricula'', ''http://zeus.lasalle.edu.co/oar/prematricula/?arg=' || xamplecripto(p_codigo, 'b9e7ad5849a30e37') || ''', null);
      return false;
        } else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''curvac'') {
      crearModal(''Instersemestales'', ''http://apps.lasalle.edu.co/prematricula-curvac/oar/'', ''http://apps.lasalle.edu.co/prematricula-curvac/oar/exit.json'');
      return false;
    } else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''imprimir_guias_antiguos'') {
      crearModal(''Guia de matricula'', ''https://jupiter.lasalle.edu.co:8181/guias/oar/'', null);
      return false;
    } else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''notas_enc_plan_estra'') {
      crearModal(''Encuesta'', ''http://tigris.lasalle.edu.co/siencuestas-war/faces/index_es.xhtml'', null);
            $(''input[name=p_opcion]:checked'', ''#oarform'').val(''notas_prometeo'');
      return false;
    }
    else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''certificados'') {
			crearModal(''Certificados'', ''http://jupiter.lasalle.edu.co/certificados/sia'', null);
      return false;
	  }
    else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''fact_saber_pro'') {
      crearModal(''Factura Saber Pro'', ''http://oarglass.lasalle.edu.co:8080/administracionOAR-war/generarFactSabPro?token='', null);
      return false;
    }
    else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''inscripcion_ingles'') {
			crearModal(''CLUS'', ''http://zeus.lasalle.edu.co/oar/clus/?v=1.3'', null);
      return false;
	  }
    else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''actualizar_datos_personales'') {
			crearModal(''Actualizar datos personales'', ''http://jupiter.lasalle.edu.co/SGE-web/IndexEstudiante'', null);
      return false;
	  }
    else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''plan_acompaniamiento'') {
			crearModal(''Sistema de Acompa&ntilde;amiento Integral'', ''http://apps.lasalle.edu.co/PlanAcompanamientoIntegral/AutenticacionSIA'', ''http://apps.lasalle.edu.co/PlanAcompanamientoIntegral/LogoutSIA'');
      return false;
	  }
    
    /* else if ($(''input[name=p_opcion]:checked'', ''#oarform'').val() == ''notas_prometeo_aviso'') {
      $(''#avisoPremModal'').modal();
      $(''#avisoPremModal #btn-continuar-aviso'').click(function(){
        $(this).button(''loading'');
        $(''input[name=p_opcion]:checked'', ''#oarform'').attr(''value'', ''notas_prometeo'');
        $(''#oarform'').append(''<input type="hidden" name="p_boton" value="s">'');
        $(''#oarform'').submit();
      });
      return false;
    }*/
    return true;
  });
  if (document.all && !window.atob) {
    alerta(''danger'', ''El Sistema de Información Académica no es compatible con Internet Explorer 9 o inferior, debe actualizar su navegador a una versión más reciente.'');
  }
  waitModal.show();
  $.ajax({
    url: ''http://oar.lasalle.edu.co/matricula/turno.php?arg='' + $(''#cid'').text(),
    type: ''get'',
    dataType: ''json'',
    success: function (data) {

      if (_.isArray(data) && !_.isEmpty(data)) {
          $.each(data, function (i, turno) {
            $(''#tturno tbody'').append(''<tr><td>'' + turno.fecha + ''</td><td>'' + turno.inicio + '' - '' + turno.fin + ''</td></tr>'');
          });
      } else {
          $(''#capturn'').hide();
          ');
v_ind_ing := pkg_utils.esIngSinTurno(p_codigo, v_anio_act, v_ciclo_act);
if v_ind_ing between 1 and 2 then
    htp.prn('$(''#modalTurno'').append(''<p>Apreciado estudiante, teniendo en cuenta que usted se encuentra en prueba académica y/o matrícula académica condicionada (nuevo), y la con la intención de favorecer su permanencia en la Universidad, queremos orientarlo en su proceso de prematrícula buscando que le permita superar durante el próximo ciclo académico esta condición de prueba académica y/o matrícula académica condicionada y así continuar con su formación profesional. Por favor agendar una cita con el Asistente Académico de su programa antes del 5 de diciembre de 2019.</p>'');');
else
    htp.prn('$(''#modalTurno'').append(''<p>APRECIADO ESTUDIANTE:  USTED NO PUEDE REALIZAR LA PREMATRICULA POR ALGUNO DE LOS SIGUIENTES MOTIVOS:</p><ul><li>AÚN NO LE CORRESPONDE EL TURNO</li><li>SE ENCUENTRA EN RETIRO DEFINITIVO DEL PROGRAMA</li><li>SE ENCUENTRA SANCIONADO ACADÉMICO-DISCIPLINARIO</li><li>TIENE DEUDA EN BIBLIOTECA O FINANCIERA</li><li>DEBE DOCUMENTOS</li><li>NO TIENE PENDIENTES MATERIAS</li></ul><p>SI SOLICITÓ REINTEGRO O CAMBIO DE JORNADA CONSULTE EL RESULTADO POR EL MENU DE ESTUDIANTE.</p>'');');
end if;
htp.p('
      }
      waitModal.hide();
      $(''#avisoPremModal'').modal();
    },
    error: function (jqXHR, textStatus, errorThrown) {
      console.log(errorThrown);
      waitModal.hide();
      //alerta(''danger'', ''Error al consultar turno. ['' + errorThrown + '']'');
    }
  });
      $window = $(window);
   $(''section[data-type="background"]'').each(function(){
     // declare the variable to affect the defined data-type
     var $scroll = $(this);
      $(window).scroll(function() {
        // HTML5 proves useful for helping with creating JS functions!
        // also, negative value because we''re scrolling upwards
        var yPos = -($window.scrollTop() / $scroll.data(''speed''));
        // background position
        var coords = ''50% ''+ yPos + ''px'';
        // move the background
        $scroll.css({ backgroundPosition: coords });
      }); // end window scroll
   });  // end section function
});

</script>
</head>
<body>
');


htp.p('
<form id="oarform" name="formA1" method="post" action="validar_e_copia_bak" class="form-horizontal" role="form">
<div class="container-fluid">');
--v_tiene_turno := 0;
SELECT be.ciclo_de_ingreso,be.tipo_de_ingreso, be.anio||TO_NUMBER(be.ciclo)
into   v_ciclo_ingre,v_tipo_ingreso,V_CICLO_BAK
FROM   B_ESTUDIANTES BE
where  be.codigo=p_codigo;
SELECT be.matriculados_ciclo_anterior
into   V_MATRICULADOANTES
FROM   B_ESTUDIANTES BE
WHERE  BE.CODIGO=p_codigo;

if (pkg_utils.estaVigente('TURNO PREM. ESTUDIANTES') = 1 /*or p_codigo in ('10141032')*/) and (v_ind_ing > 0 or (V_CICLO_BAK <> v_ciclo_ingre and to_number(V_CICLO_BAK) >= to_number(v_ciclo_ingre) and (v_indpagovot in ('P', 'V') or V_MATRICULADOANTES in ('P','V')))) then
  htp.p('
  <div class="modal fade" id="avisoPremModal" tabindex="-1" aria-labelledby="avisoPremModalLabel" role="dialog" aria-hidden="true" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header bg-danger">
          <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
          <h4 class="modal-title" id="avisoPremModalLabel">AVISO IMPORTANTE</h4>
        </div>
        <div class="modal-body" id="modalTurno">
        <h4 class="text-center">'||v_nombre_usuario||'</h4>
        <h4 class="text-center">'||initcap(replace(nombre_facultad(v_codfac,v_indjor),'-',' '))||'</h4>
          <div id="capturn">
          <p>LOS TURNOS PARA REALIZAR SU PREMATRICULA SON:</p>
          <table id="tturno" class="table table-striped">
            <thead>
              <tr>
                <th>DIA</th>
                <th>HORA</th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
          <p>Si usted quedó en prueba académica y/o matrícula académica condicionada, deberá priorizar en su prematrícula, los espacios académicos que no fueron aprobados.</p>
          <p>Impresión de guías de matrícula a partir del 11 de diciembre de 2019 después de las 4:00 p.m.</p>
          </div>
        </div>
      </div>
    </div>
  </div>');
end if;
--30/01/15 JDRJ
v_tiene_prematricula:=tiene_prematricula(p_codigo);


htp.p('
  <div class="row">
    <div class="col-md-6">
      <img src="/images/LOGOSALLE.gif" class="img-responsive" alt="Universidad de La Salle" style="width: 177px; height: 80px;">
    </div>
    <div class="col-md-6">
      <div class="pull-right">
        <h3>SISTEMA DE INFORMACIÓN ACADÉMICA</h3>
        <h5>&nbsp;Universidad de La Salle - Oficina de Admisiones y Registro</h5>
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-md-12">
      <div class="panel panel-info">
        <div class="panel-heading"><strong>MENÚ DE ESTUDIANTES</strong></div>
        <div class="panel-body">
          <p class="bg-warning text-center"><strong>BIENVENIDO(A): '||v_nombre_usuario||' - Esta es su consulta No: '||vconsultas||'');
          if v_tiene_datosper>0 then
            htp.p('<br />Número documento: '||v_tipo_doc||' - ' ||v_numdoc);
            htp.p('<br />Fecha de nacimiento: '||to_char(v_fecha_nacimiento,'dd/mm/RRRR'));
          end if; 
          htp.p('<br />Correo institucional: '||v_correo_institucional); 
          htp.p('<br />');
          if v_tiene_matricula>0 then
             htp.p('MATRICULADO');
          else 
              htp.p('NO MATRICULADO');
          end if;
          htp.p('          </strong></p>
          <input type=hidden name=p_usuario value='||v_usuario||'>
          <input type=hidden name=p_clave   value='||v_clave||'>
          <div id="msg"></div>
          <label for="p_codigo">CÓDIGO ESTUDIANTIL:</label>
          <input id="p_codigo" type="text" class="form-control" name="p_codigo" maxlength="9" placeholder="Escriba su código estudiantil aquí y luego seleccione una opción" autocomplete="off">');
          htp.p('<!-- ' || v_ciclo_de_ingreso || ',' || v_ciclo_nuevos || ' -->');
          if v_tiene_prematricula <= 0 and not (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NV','GM','HM','IH','PI','SA','SL')) and to_char(sysdate,'DDMMRRRRHH24') >= '1512201608' then
              htp.p('
              <hr/>
              <div class="well">
                Estimado estudiante, si usted no ha realizado la inscripción de materias (prematrícula), por favor comuníquese  con su Programa Académico, ingresando por la opción Directorio de Programas.
              </div>');
          elsif v_tiene_prematricula > 0 and not (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NV','GM','HM','IH','PI','SA','SL')) and to_date('1502201708','DDMMRRRRHH24') >= sysdate then
             htp.p('
              <hr/>
              <div class="well">
                Si usted realizó prematrícula ingrese por la opción "Imprimir guía de matrícula" y descargue su guía de matrícula a partir del 16 de diciembre de 2016 a las 5:00 p.m.
              </div>');
          elsif (sysdate between to_date('2017-07-18 08:00:00','RRRR-MM-DD HH24:MI:SS') and to_date('2017-07-19 23:59:59','RRRR-MM-DD HH24:MI:SS')) and b_prematricula_spring.f_tiene_turno(p_codigo,'AN',v_anio_act, v_ciclo_act) <= 0 AND (v_ciclo_de_ingreso!=v_ciclo_nuevos OR (v_ciclo_de_ingreso=v_ciclo_nuevos AND v_tipo_de_ingreso in('RI','RA','DT')) or (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_de_ingreso='TI' AND v_codfac = '18')) then
              htp.p('
              <br/>
              <div class="alert alert-danger" role="alert">
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
                <p>Recuerde que Usted debe cumplir con los siguientes requisitos para inscribir cr&eacute;ditos adicionales:</p>
                <ol>
                    <li>Estar matriculado.</li>
                    <li>Cumplir con los requisitos de su programa académico, mayor información en su programa.</li>
                    <li>Cumplir con los requisitos del Artículo 47.</li>
                </ol>
              </div>
              ');
          end if;
          if v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NV','GM','HM','IH','PI','SA','SL') and regexp_like(substr(p_codigo, 1, 2), '^(26|37|11|17|13|18)$') then  --Se elimina la facultad 14(veterinaria) por petición de admisiones y registro 14/01/2020
          htp.p('
          <hr/>
          <div class="alert alert-danger" role="alert">
            <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
            <span class="sr-only">Atenci&oacute;n:</span>
            Apreciado Estudiante, Su prematricula sera realizada por la Unidad Academica.
          </div>
          ');
          end if;
    if pkg_prematricula.tieneMarcaNoPago(p_codigo) > 0 then
        htp.p('<script type="text/javascript">ga(''send'', ''event'', ''estudiante'', ''marca No Pago'', '''', 1);</script>');
        htp.prn('<hr/>');
        htp.prn('<div class="alert alert-info" role="alert">');
        htp.prn('<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>');
        htp.prn('<p>Apreciado(a) estudiante:</p>');
        htp.prn('<p>Hemos evidenciado que a la fecha no se encuentra paga la gu&iacute;a de matr&iacute;cula por concepto de cr&eacute;ditos adicionales para el ciclo lectivo en curso. Le agradecemos por favor generarla nuevamente desde el sistema acad&eacute;mico con su usuario y contrase&ntilde;a y proceder a realizar el pago en la Caja ubicada en la Sede Chapinero de La Universidad, en el horario de 8 am a 7 pm. La fecha l&iacute;mite de pago es el pr&oacute;ximo <b>viernes 17 de marzo</b>. Si el pago no es realizado, quedar&aacute; marcado en el sistema como deudor y no podr&aacute; realizar prematr&iacute;cula en el ciclo lectivo siguiente.</p>');
        htp.prn('<p>Si ya realiz&oacute; el pago y este no se ve reflejado en nuestro sistema, le agradecemos por favor remitir el soporte de la transacci&oacute;n al correo <a href="mailto:soporteguia@lasalle.edu.co">soporteguia@lasalle.edu.co</a>.</p>');
        htp.prn('<p>Cordialmente,</p>');
        htp.prn('<p>Divisi&oacute;n Financiera</p>');
        htp.prn('</div>');
    end if;
          htp.p('<table class="table">
            <tr>
              <td style="width: 35%">
                <table>');
---------------------------------------------------------------------------
--REINTEGROS201401
--ABRIR FECHAS DE CORTE
---------------------------------------------------------------------------

--if p_codigo IN ('XXXXXXXX')then

v_indicador:=MAXINDICA_PERPRUEBA(p_codigo);
v_numero_acta:=NUMERO_ACTA(P_CODIGO);
--if v_indicador<3 AND V_INDICADOR_PAGO NOT IN('P','V') and v_numero_acta=0  then
--VENTANA_INF_REINTEGRO;
--end if;

SELECT fc.fecha_inicio,fc.fecha_finalizacion
INTO   v_fecha_iniciori,v_fecha_finalizacionri
FROM   a_fechas_de_corte fc
WHERE  rtrim(SUBSTR(fc.proceso,1,19))='REINTEGROS PREGRADO';

SELECT be.ciclo_de_ingreso,be.tipo_de_ingreso
INTO   v_ciclo_ingre,v_tipo_ingreso
FROM   b_estudiantes BE
WHERE  be.codigo=p_codigo;

SELECT FC.ANIO||DECODE(FC.CICLO,'01','1','02','2')
INTO   V_CICLONEW
FROM   a_fechas_de_corte fc
WHERE  fc.proceso like '%ADMISION ESTUDIANTES NUEVOS-PREGRADO%';

/*--TODO: Verficar este comportamiento.
--- ANTES DEL CIERRE DE NOTAS ACTIVAR ESTA CONSULTA
SELECT be.Indicador_Pago,be.ciclo_de_ingreso,be.tipo_de_ingreso,be.materias_pendientes
INTO   V_INDICADOR_PAGO,V_CICLO_DE_INGRESO,V_TIPO_DE_INGRESO,V_MATERIAS_PENDIENTES
FROM   b_estudiantes be
WHERE  be.codigo=p_codigo;*/

--ACTIVADO EL 23NOV2019 DESPUES DEL CIERRE DE NOTAS ACTIVAR ESTA CONSULTA 
sELECT be.matriculados_ciclo_anterior,be.ciclo_de_ingreso,be.tipo_de_ingreso,be.materias_pendientes
INTO   v_indicador_pago,V_CICLO_DE_iNGRESO,V_TIPO_DE_INGRESO,v_materias_pendientes
FROM   b_estudiantes be
WHERE  be.codigo=p_codigo;

VPDEUDAFIN:=VERIFICAR_DEUDA_FINANCIERA(p_codigo);
VPDEUDABIB:=VERIFICAR_DEUDA_BIBLIOTECA(p_codigo);
VPDOCUMENTOS:=REVISAR_DOCUMENTOS(p_codigo,v_mensaje);

v_esextranjero:=existe_extranjero(p_codigo);
if v_esextranjero>0 then
   VPDOCUEX:=REVISAR_DOCEXTRANJERO(p_codigo);
   ELSE
   VPDOCUEX:=REVISAR_DOCUMENTOS(p_codigo,V_MENSAJE);
end if;
VPACTDAT:=REVISAR_ACTDAT(p_codigo,v_mensaje);
VPDATOSPER:=VERIFICAR_DATOSPER(p_codigo);



-----------------------------------------------------------------------------------------------------------------------------------------
--REINTEGROS
--ACTUALIZACION DE DATOS NO SE PIDE PARA INSCRIPCION SE PIEDE PARA CUANDO DESCARGUEN GUIA
--HTP.P(VPDOCUEX);
--HTP.P(VPDATOSPER);
--HTP.P(VPACTDAT);
--HTP.P(VPDEUDABIB);
--HTP.P(VPVPDEUDABIB);
--HTP.P('1');

IF (VPDOCUEX NOT IN('OK') OR VPDATOSPER NOT IN('OK') OR VPDEUDAFIN NOT IN('OK') OR  VPDEUDABIB NOT IN('OK')) THEN
   IF  (v_ciclo_ingre = v_cicloNEW AND v_tipo_ingreso NOT IN ('NV','HM','IH','SA','PI','GM','LB')) THEN
      htp.p('
                  <tr>
                    <td>Solicitud de Reintegro</td>
                    <td><p align="center"><font size="3"></font></td>
                  </tr>
      ');
   END IF;
   ELSE
   --HTP.P(v_expulsado);
      IF v_expulsado!=1 THEN
      --HTP.P(v_expulsado);
         IF (TO_CHAR(SYSDATE,'YYYYMMDD') BETWEEN TO_CHAR(V_FECHA_INICIORI,'YYYYMMDD') AND TO_CHAR(V_FECHA_FINALIZACIONRI,'YYYYMMDD')) THEN
           --HTP.P('4');
            if substr(p_codigo,1,2) not in('21','22','32','23','24','31','28','29','34','44') then
               v_existe_egresado:=existe_egresado(p_codigo);
               V_INDICADOR:=MAXINDICA_PERPRUEBA(P_CODIGO);
              --HTP.P(v_indicador);
               IF V_INDICADOR>=3 THEN
                  V_MENSAJE:='USTED NO PUEDE SOLICITAR REINTEGRO ESTA SUSPENDIDO DEFINITIVAMENTE DE LA UNIVERSIDAD.';
                  --alerta_continua(V_MENSAJE);
                  ELSE
                             --HTP.P(v_ciclo_de_ingreso);
                             --HTP.P(v_tipo_de_ingreso);
                             --HTP.P(v_ciclo_nuevos);
                             --HTP.P(v_existe_egresado);
                      --HTP.P('5');
                      --if v_existe_egresado>0 then                  
                        
                         v_numero_acta:=NUMERO_ACTA(p_codigo); 
                         --HTP.P(v_numero_acta);
                         --if  v_numero_acta=0 then
                             --HTP.P(v_ciclo_de_ingreso);
                             --HTP.P(v_ciclo_nuevos);
                             --HTP.P(v_numero_acta);
                             if (((v_indicador_pago not in('P','V') and (v_ciclo_de_ingreso!=v_ciclo_nuevos))) or ((v_indicador_pago not in('P','V')  and v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_de_ingreso='RA'))) AND PKG_REINTEGROS.FNC_MAT_PENDIENTES(P_CODIGO)='NO'  Then
                                 --HTP.P('6');
                                       HTP.P('
                                       <tr>
                                         <td>Solicitud de Reintegro</td>
                                         <td><p align="center"><input type="radio" name="p_opcion" value="solicitud_reintegro"></xtd>
                                       </tr>
                                       ');
                                  else
                                      V_CANCELO_DESPUES:=EXISTE_CANCELO_DESPUES(P_CODIGO);
                                    iF V_CANCELO_DESPUES>0 THEN
                                           HTP.P('
                                           <tr>
                                             <td>Solicitud de Reintegro</td>
                                             <td><p align="center"><input type="radio" name="p_opcion" value="solicitud_reintegro"></td>
                                           </tr>
                                           ');
                                    END IF;      
                             End If;
                             --end if;
                             --HTP.P(v_materias_pendientes);
                             --else
 
                            --HTP.P(v_materias_pendientes);
                            --HTP.P('xxx');                          
                            select NVL(max(n.ano||decode(n.ciclo,'01','01','03','02')),0)
                            into   v_ultimo_ciclo_cursado
                            from   a_notas n
                            where  n.codigo_estudiante=p_codigo
                            and    n.ciclo in('01','03');
                                                
                              If V_Materias_Pendientes=0 Then
                                V_Mensaje:='Si usted va a solicitar reintegro para actualización, primero debe actualizar datos para grado. Después ingrese nuevamente y seleccione la opción solicitud de reintegro.';
                                --htp.p(v_mensaje);
                                alerta_CONTINUA(v_mensaje);
                                ELSE
                               
                                --HTP.P('6');
                              --HTP.P(v_indicador_pago);
                              --HTP.P(v_ciclo_de_ingreso);
                              --HTP.P(v_ciclo_nuevos);
                                    if (v_indicador_pago not in('P','V') and (v_ciclo_de_ingreso=v_ciclo_nuevos) and v_tipo_de_ingreso='RI') OR ( v_indicador_pago not in('P','V') and (v_ciclo_de_ingreso!=v_ciclo_nuevos)  OR (v_indicador_pago not in('P','V') and substr(p_codigo,1,2)='45' and v_ciclo_de_ingreso||v_tipo_de_ingreso=v_ciclo_nuevos||'TI')) AND PKG_REINTEGROS.FNC_MAT_PENDIENTES(P_CODIGO)='SI' then
                                       --HTP.P(v_ciclo_de_ingreso);
                                       HTP.P('
                                       <tr>
                                         <td>Solicitud de Reintegro</td>
                                         <td><p align="center"><input type="radio" name="p_opcion" value="solicitud_reintegro"></td>
                                       </tr>
                                       ');
                                        else
                                          --HTP.P('7');
                                           v_cancelo_despues:=existe_cancelo_despues(p_codigo);
                                           IF V_CANCELO_DESPUES>0 THEN
                                               htp.p('
                                               <tr>
                                                 <td>Solicitud de Reintegro</td>
                                                 <td><p align="center"><input type="radio" name="p_opcion" value="solicitud_reintegro"></td>
                                               </tr>
                                               ');
                                           end if;
                                    end if;
                        end if;
                end if;
           --end if;
END IF;
             ELSE
                --SE VENCIERON LAS FECHAS DE INSCRIPCION DE REINTEGROS ENTONCES SI SOLICITO REINTEGRO
                --LE APRECE LA OPCION PARA QUE PUEDA HACER CONSULTAS
                V_SOLICITO_REINTEGRO:=EXISTE_REINTEGRO(P_CODIGO);
                --htp.p(v_solicito_reintegro);
                IF V_SOLICITO_REINTEGRO>0 THEN
                            
                                       htp.p('
                                       <tr>
                                         <td>Solicitud de Reintegro</td>
                                         <td><p align="center"><input type="radio" name="p_opcion" value="solicitud_reintegro"></td>
                                       </tr>
                                       ');

                end if;
         END IF;
      END IF;
END IF;
--end if;
-------------------------------------------------------------------------------------------------
--CAMBIOS DE JORNADA
-------------------------------------------------------------------------------------------------
if to_char(sysdate,'YYYYMMDD') BETWEEN TO_CHAR(v_fechapub_cambiojorini,'YYYYMMDD') AND TO_CHAR(v_fechapub_cambiojorfin,'YYYYMMDD') THEN
    select count(1)
    into   v_cambio_jornada
    from   a_solicitudes_jornadas sj
    where  sj.codigo_estudiante=p_codigo;
    if v_cambio_jornada>0 then
       htp.p('
       <tr>
         <td>Consultar Cambio de Jornada</td>
         <td><p align="center"><input type="radio" name="p_opcion" value="cambio_jornada"></td>
       </tr>
       ');
    end if;
END IF;

select count(*)
into c_tiene_summer
from a_materias m
    inner join
b_prematricula_intersemestral p
    on m.codigo = p.materia_cursar and m.codigo_facultad = p.facultad_cursar
where p.codigo_estudiante = p_codigo
and m.area in ('Z')
and pkg_utils.estaVigente('SUMMER') >= 1
and p.anio || to_number(p.ciclo) in (select f.ciclo_nuevos_ri from a_fechas_de_corte f where f.proceso = 'CURVAC')
--and p.anio || to_number(p.ciclo) in ('20191')
;

if (sysdate between v_fecha_iniciocv and v_fecha_finalizacioncv) or c_tiene_summer > 0 then
    htp.p('
    <tr>
      <td><label for="opt-curvac">Inscripción/Modificación Cursos Intersemestrales</label></td>
      <td><input id="opt-curvac" type="radio" name="p_opcion" value="curvac" /></td>
    </tr>');
end if;

/*
----------------------------------------------------------------------------------------------------------------------------
--INTERSEMESTRALES
----------------------------------------------------------------------------------------------------------------------------
--04-JUN-2011

--IF P_CODIGO IN('40121025') THEN
--CVPERCUPO:=VERIFICAR_INTERSEMESTRALES(p_codigo);


IF v_expulsado!=1 AND v_ciclo_de_ingreso||v_tipo_ingreso NOT IN('20152NV') THEN
if to_char(sysdate,'YYYYMMDD') BETWEEN TO_CHAR(v_fecha_iniciocv,'YYYYMMDD') AND TO_CHAR(v_fecha_finalizacioncv,'YYYYMMDD') THEN
if CVPERCUPO not in('OK') then
htp.p('
<tr>
  <td>Inscripción/Modificación Cursos Intersemestrales</td>
  <td><p align="center">.</td>
</tr>'
);
else
IF p_codigo IN (
'63102040',
'63102119',
'63102176',
'63102034',
'63102177',
'63082038',
'63091039',
'63111103',
'63102097',
'63102120',
'63102098',
'63092085',
'63092051',
'63102000',
'63102145',
'63092061',
'63102072',
'63101102'

) THEN
htp.p('
<tr>
  <td>Inscripción/Modificación Cursos Intersemestrales</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="curvac" /></p></td>
</tr>');
htp.p('
<tr>
  <td>Imprimir Guía de Matrícula Intersemestral</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="guia_curvac"></td>
</tr>');
END IF;
end if;
end if;
END IF;
--END IF;
*/

/*IF P_CODIGO IN('XXXXXXXX') THEN
htp.p('
<tr>
<td>Inscripción/Modificación Cursos Intersemestrales</td>
<td><p align="center"><input type="radio" name="p_opcion" value="curvac"></p></td>
</tr>
');
END IF;
htp.p('
<tr>
<td>Inscripción/Modificación Cursos Intersemestrales</td>
<td><p align="center">.</p></td>
</tr>
');*/



--BLOQUEADO EL 08JUL2014
--if p_codigo='XXXXXXXX' then
/*
htp.p('
<tr>
<td>Imprimir Guía de Matrícula Intersemestral</td>
<td><p align="center"><input type="radio" name="p_opcion" value="guia_curvac"></td>
</tr>
');*/
/*else
htp.p('
<tr>
<td>Imprimir Guía de Matrícula Intersemestral</td>
<td><p align="center"><font>.</font></p></td>
</tr>
');*/
--end if;


--END IF;
SELECT FC.ANIO||DECODE(FC.CICLO,'01','1','02','2')
INTO   V_CICLONEW
FROM   a_fechas_de_corte fc
WHERE  fc.proceso like '%ADMISION ESTUDIANTES NUEVOS-PREGRADO%';
IF  (v_ciclo_ingre!= v_cicloNEW OR (v_ciclo_ingre= v_cicloNEW AND V_TIPO_DE_INGRESO IN('RI')))  THEN
    if to_char(sysdate,'YYYYMMDD') BETWEEN TO_CHAR(v_fecha_iniconhorcurvac,'YYYYMMDD') AND TO_CHAR(v_fecha_finconhorcurvac,'YYYYMMDD') THEN
    HTP.P('
          <tr>
            <td>Consultar horarios Cursos Intersemestrales</td>
            <td><input type="radio" name="p_opcion" value="consulta_horcurvac"></td>
          </tr>
    ');
    end if;
END IF;
/*HTP.P('
      <tr>
        <td>Consultar horarios Cursos Intersemestrales</td>
        <td><p align="center"><font>.</font></p></td>
      </tr>
');*/

----------------------------------------------------------------------------------------------------------------------------
/*select be.indicador_pago
into   v_indicador_pago
from   b_estudiantes be
where  be.codigo=p_codigo;

IF TO_CHAR(sysdate,'RRRRMMDD') between TO_CHAR(v_inivot,'RRRRMMDD') and TO_CHAR(v_finvot,'RRRRMMDD') THEN
    --if p_codigo in('41062054') then
      v_yavoto:=existe_votacion(p_codigo);
      if (substr(p_codigo,1,2)='41' and v_yavoto=0 AND v_indicador_pago='P') then
      HTP.P('
      <tr >
      <td>Votaciones al consejo estudiantil (CONPIAS)</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="votaciones" checked></td>
      </tr>
      ');
      end if;
    --end if;
end if;*/

/*IF to_char(sysdate,'YYYYMMDD')='20090217' THEN
if (substr(p_codigo,1,2)='50' AND v_indicador_pagoz ='P') then
HTP.P('
/
<tr>
<td>Resultados elecciones</td>
<td><p align="center"><input type="radio" name="p_opcion" value="elecciones" checked></p></td>
</tr>
');
end if;
END IF;*/

--IF P_CODIGO='47112010' THEN
HTP.P('
<tr >
  <td>Resultados elecciones</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="elecciones"></p></td>
</tr>
');
--END IF;

SELECT BE.INDICADOR_PAGO
INTO   v_indpagovot
FROM   b_estudiantes be
WHERE  be.codigo=p_codigo;

SELECT COUNT(*)
INTO   V_YAVOTO
FROM   A_VOTACIONES V
WHERE  V.CODEST_VOTANTE=P_CODIGO;


--15FEB2018
IF  TO_CHAR(sysdate,'RRRRMMDDHH24MI') between TO_CHAR(v_inivot,'RRRRMMDDHH24MI') and TO_CHAR(v_finvot,'RRRRMMDDHH24MI')  AND v_indpagovot IN('P','V') AND V_YAVOTO=0 THEN
--if P_CODIGO='XXXXXXXX' THEN
HTP.P('
<tr>
<td>Votaciones</td>
<td><p align="center"><input type="radio" name="p_opcion" value="votaciones" checked></p></td>
</tr>
');
/*else
HTP.P('
<tr >
  <td>Votaciones</td>
  <td><p align="center">.</p></td>
</tr>
');
end if;*/
END IF;


/*
HTP.P('
<tr >
<td>Resultados elecciones</td>
<td><p align="center"><input type="radio" name="p_opcion" value="votaciones" checked></p></td>
</tr>
');*/

-----------------------------------------------------------------------------------------------------------------------
HTP.P('
<tr >
  <td>Consulta General</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="c" checked></td>
</tr>
');

select count(*)
into   v_inscrito_csi
from   a_inscripciones_sistemas csi
where  csi.codigo_estudiante=p_codigo;
v_inscrito_csi:=0;
if v_inscrito_csi>0 then
htp.p('
<tr>
  <td>Consulta notas de Sistemas</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="notascsi"></p></td>
</tr>
');
end if;
IF v_expulsado!=1 and v_enc_plan_estra = 0 THEN
    htp.p('
    <tr>
      <td>Consulta Notas parciales</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="notas_prometeo"></p></td>
    </tr>
    ');
elsif v_enc_plan_estra > 0 then
    htp.p('
    <tr>
      <td>Consulta Notas parciales</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="notas_enc_plan_estra"></p></td>
    </tr>
    ');
END IF;

v_TIENE_NOTAS:=existe_nota(P_CODIGO);

IF v_TIENE_NOTAS>0 AND v_expulsado=0 and v_materias_pendientes < 1 /*and v_egresado_no_graduado > 0 and p_codigo = '26112751'*/ THEN
htp.p('
<tr>
  <td>Actualizaci&oacute;n de datos para grado</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="act_datos_grado"></p></td>
</tr>
');
/*htp.p('
<tr>
  <td>Paz y Salvo de Egresado</td>
  <td>&nbsp;</td>
</tr>
');*/
END IF;

-----------------------------------------------------
--DEBE ESTAR OK PARA QUE DEJE A LOS CONVENIOS HACER PREMATRICULA
IF v_ciclo_de_ingreso=V_CICLONEW and v_tipo_de_ingreso IN('NV','IH','HM','SA','TI','TE','PI','GM','SE','DT','HO') THEN
   VPPERCUPO:='OK';
ELSE
   VPPERCUPO:=verificar_perdida_cupo(p_codigo);
END IF;

-----------------------------------------------------
VPDOCUMENTOS:=REVISAR_DOCUMENTOS(p_codigo,v_mensaje);
-----------------------------------------------------
SELECT COUNT(*)
INTO   v_joraprob
FROM   a_solicitudes_jornadas sj
WHERE  sj.codigo_estudiante=p_codigo;

-----------------------------------------------------
VPDATOSPER:=VERIFICAR_DATOSPER(p_codigo);
-----------------------------------------------------
VPDEUDAFIN:=VERIFICAR_DEUDA_FINANCIERA(p_codigo);
-----------------------------------------------------
VPDEUDABIB:=VERIFICAR_DEUDA_BIBLIOTECA(p_codigo);
-----------------------------------------------------
VPACTDAT:=REVISAR_ACTDAT(p_codigo,v_mensaje);
-----------------------------------------------------
v_esextranjero:=existe_extranjero(p_codigo);



if v_esextranjero>0 then
   VPDOCUEX:=REVISAR_DOCEXTRANJERO(p_codigo);
   select instr(vpdocuex,'-VISA',1,1)         into v_debedocext1 from dual;
   select instr(vpdocuex,'-CEDULA',1,1)       into v_debedocext2 from dual;
   select instr(vpdocuex,'-AUTORIZACION',1,1) into v_debedocext3 from dual;
   if VPDOCUEX not in ('OK') then
      if (v_debedocext1>0 and v_debedocext2>0 and v_debedocext3>0) then
         alerta_continua(v_aviso1_extranjeros);
      end if;
      if (v_debedocext1=0 and v_debedocext2=0 and v_debedocext3>0) then
         alerta_continua(v_aviso2_extranjeros);
      end if;
      if (v_debedocext1>0 and v_debedocext2=0 and v_debedocext3=0) then
         alerta_continua(v_aviso3_extranjeros);
      end if;
      if (v_debedocext1=0 and v_debedocext2>0 and v_debedocext3=0) then
         alerta_continua(v_aviso4_extranjeros);
      end if;
   end if;
   else
      VPDOCUEX:='OK';
end if;
-----------------------------------------------------
SELECT c.ciclo,c.inicio_nuevos,c.final_nuevos
INTO   v_ciclo_NUEVOS,v_Inicio_Nuevos,v_Final_Nuevos
FROM   a_ciclos_academicos c
WHERE  c.tipo = 'P'
AND    c.ciclo = (SELECT MAX(a.ciclo)
FROM   a_ciclos_academicos a
WHERE  a.tipo = 'P');

SELECT be.ciclo_de_ingreso,be.tipo_de_ingreso
into   v_ciclo_ingre,v_tipo_ingreso
FROM   B_ESTUDIANTES BE
where  be.codigo=p_codigo;

-----------------------------
SELECT be.matriculados_ciclo_anterior
into   V_MATRICULADOANTES
FROM   B_ESTUDIANTES BE
WHERE  BE.CODIGO=p_codigo;

if V_MATRICULADOANTES  in('P','V') THEN
   VPMATRICULADO:='OK';
   ELSE
   VPMATRICULADO:='XX';
END  IF;


IF v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('RI','RA') THEN
VPMATRICULADO:='OK';
END IF;
--------------------------------------------------------------------------------------------------------------
--25-NOV-2013
--PREMATRICULA ANTIGUOS TURNOS NORMALES
--------------------------------------------------------------------------------------------------------------
/*
select count(*)
into   v_esta_en_turnos
from   turnos_estudiantes te
where  te.codigo=p_codigo;
if v_esta_en_turnos>0 then
  select count(*)
  into   v_turno
  from   turnos_estudiantes te
  where  te.codigo=p_codigo
  and    te.fecha=TO_CHAR(SYSDATE,'RRRRMMDD')
  and    TO_CHAR(SYSDATE,'HH24MI')>=substr(te.hora,1,4) and TO_CHAR(SYSDATE,'HH24MI')<=substr(te.hora,5,4);
IF v_ciclo_de_ingreso!=v_ciclo_nuevos  THEN
if (VPPERCUPO     NOT IN('OK') OR
    VPDOCUMENTOS  NOT IN('OK') OR
    VPDEUDAFIN    NOT IN('OK') OR
    VPDEUDABIB    NOT IN('OK') OR
    VPDOCUEX      NOT IN('OK') OR
    V_EXPULSADO!=0 OR
    VPDATOSPER    NOT IN('OK') OR
    VPMATRICULADO NOT IN('OK')
    OR V_TURNO=0
    ) then
    HTP.P('
     <tr>
        <td>Registrar Prematrícula</td>
        <td><p align="center">-</p></td>
      </tr>
      <tr>
      <td>Manual Prematrícula 2014</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="manuales_prematricula"></td>
     </tr>

    ');
    else
    htp.p('
    <tr>
      <td>Registrar Prematrícula</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="prematricula_2014"></p></td>
    </tr>
    ');
    htp.p('
    <tr>
      <td>Manual Prematrícula 2014</td>
      <td><p align="center"><input type="radio" name="p_opcion" value="manuales_prematricula"></p></td>
    </tr>
    ');
end if;
END IF;
END IF;
*/
--------------------------------------------------------------------------------------------------------------
-- PREMATRICULA ANTIGUOS TURNOS NORMALES
--------------------------------------------------------------------------------------------------------------

/* OJO CON ESTO: se fue otra opción duplicada...
IF TO_date('20150625060000','RRRRMMDDHH24MISS') <= sysdate THEN
   select count(*)
   into   v_cambio_jornada
   from   a_solicitudes_jornadas sj
   where  sj.codigo_estudiante=p_codigo;
   IF v_ciclo_de_ingreso||v_tipo_ingreso IN('20152RI','20152RA') OR v_cambio_jornada>0  THEN
    --htp.p(VPDEUDAFIN);
      IF (VPPERCUPO     NOT IN('OK') OR VPDOCUMENTOS  NOT IN('OK') OR VPDEUDAFIN    NOT IN('OK') OR
          VPDEUDABIB    NOT IN('OK') OR VPDOCUEX      NOT IN('OK') OR V_EXPULSADO!=0 OR  VPDATOSPER    NOT IN('OK') OR
          VPMATRICULADO NOT IN('OK')
         ) THEN
         HTP.P('
               <tr>
                 <td width="336">Registrar/Consultar Prematrícula</td>
                 <td width="37"><p align="center">.</td>
         ');
      ELSE
         HTP.P('
              <tr>
                 <td width="336">Registrar/Consultar Prematrícula</td>
                 <td width="37"><p align="center"><input type="radio" name="p_opcion" value="prematricula"></td>
         ');
      END IF;
   END IF;
END IF;*/
--------------------------------------------------------------------------------------------------------------
--PREMATRICULA NUEVA DE JULIAN INSERTAR CODIGO NUEVO
--------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
--PREMATRICULA ANTIGUOS CUANDO ENTRAN TODOS -- danramirez
--------------------------------------------------------------------------------------------------------------

if pkg_utils.estaVigente('OPC. PREMATRICULA EST') > 0 THEN
  select count(*)
  into   v_esta_en_turnos
  from   cti_turnos_prematricula tp
  where  tp.codigo_estudiante=p_codigo;
  if v_esta_en_turnos>0 then
    IF v_ciclo_de_ingreso!=v_ciclo_nuevos or v_ciclo_de_ingreso||v_tipo_ingreso IN(v_anio_act || to_number(v_ciclo_act) || 'RI') THEN
      if (VPPERCUPO     NOT IN('OK') OR
          VPDOCUMENTOS  NOT IN('OK') OR
          VPDEUDAFIN    NOT IN('OK') OR
          VPDEUDABIB    NOT IN('OK') OR
          VPDOCUEX      NOT IN('OK') OR
          V_EXPULSADO   !=0          OR
          VPDATOSPER    NOT IN('OK') OR
          VPMATRICULADO NOT IN('OK')
          ) then
          HTP.P('
          <tr>
            <td>Registrar/consultar prematrícula</td>
            <td>&nbsp;</td>
          </tr>
          ');
        else
          HTP.P('
          <tr>
            <td><label for="prematricula_op">Registrar/consultar prematrícula</label></td>
            <td class="text-center"><input id="prematricula_op" type="radio" name="p_opcion" value="prematricula"></td>
          </tr>
          ');
      end if;
    else
      HTP.P('
        <tr>
          <td>Consultar prematrícula</td>
          <td><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
        </tr>
        ');
    end if;
  elsif v_tiene_prematricula > 0 then
    HTP.P('
        <tr>
          <td>Consultar prematrícula</td>
          <td><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
        </tr>
        ');
  end if;
--Fuera de fechas
elsif not (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NV','GM','HM','IH','PI','SA','SL')) then
    HTP.P('
        <tr>
          <td>Consultar prematrícula</td>
          <td><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
        </tr>
        ');
END IF;

--------------------------------------------------------
--PARA REINTEGROS Y CAMBIOS DE JORNADA
--------------------------------------------------------
--25JUN2014.
/*--JDRJ
IF TO_CHAR(SYSDATE,'RRRRMMDD')>='20151215' THEN
select count(*)
into   v_cambio_jornada
from   a_solicitudes_jornadas sj
where  sj.codigo_estudiante=p_codigo;
IF v_ciclo_de_ingreso||v_tipo_ingreso IN('20162RI','20162RA') OR v_cambio_jornada>0  THEN
if (VPPERCUPO     NOT IN('OK') OR
    VPDOCUMENTOS  NOT IN('OK') OR
    VPDEUDAFIN    NOT IN('OK') OR
    VPDEUDABIB    NOT IN('OK') OR
    VPDOCUEX      NOT IN('OK') OR
    V_EXPULSADO!=0 OR
    VPDATOSPER    NOT IN('OK')
    ) then
    HTP.P('
    <tr>
      <td>Registrar Prematricula</td>
      <td><p align="center"></td>
    </tr>
    <tr>
      <td>Modificar Prematricula</td>
      <td><p align="center"></td>
    </tr>
    ');
    else
      HTP.P('
      <tr>
        <td>Registrar/consultar prematrícula</td>
        <td><p align="center"><input id="prematricula_op" type="radio"  name="p_opcion" value="prematricula"></p></td>
      </tr>
      ');
      --<tr>
      --  <td>Modificar Prematricula</td>
      --  <td><p align="center"><input  id="prematricula_op" type="radio"  name="p_opcion" value="modificar_prematricula"></p></td>
      --</tr>

end if;
END IF;
end if;
--JDRJ*/
-----------------------------------------
--INSCRIPCION A CURSOS DE PRACTICAS FORMATIVAS
/*htp.p(v_ciclo_de_ingreso);
htp.p(v_ciclo_nuevos);
htp.p(VPPERCUPO);
htp.p(VPDOCUMENTOS);
htp.p(VPDEUDAFIN);
htp.p(VPDEUDABIB);
htp.p(VPDOCUEX);
htp.p(V_EXPULSADO);
htp.p(VPDATOSPER);
htp.p(VPMATRICULADO );*/

--03FEB2014
IF v_ciclo_de_ingreso!=v_ciclo_nuevos or (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso in ('RI')) THEN
    if (VPPERCUPO     NOT IN('OK') OR
        VPDOCUMENTOS  NOT IN('OK') OR
        VPDEUDAFIN    NOT IN('OK') OR
        VPDEUDABIB    NOT IN('OK') OR
        VPDOCUEX      NOT IN('OK') OR
        V_EXPULSADO!=0 OR
        VPDATOSPER    NOT IN('OK') OR
        v_ind_pago NOT IN('P')
        ) then
        null;
    --TODO: ver que pasa con esta opcion
    elsif pkg_utils.estaVigente('CLUSTER ESTUDIANTE') = 1 then
        HTP.P('
        <tr>
        <td><label for="opt_formativas" class="text-danger">Inscripción a cursos<br>de prácticas formativa</label></td>
        <td><input id="opt_formativas" type="radio" name="p_opcion" value="formativas"></td>
        ');
    end if;
end if;
----------------------------------------------------------------------
--PARA PREMATRICULA NUEVOS
----------------------------------------------------------------------
/*begin
    select 'NV'
    into v_tipo_ingreso
    from dual
    where v_ciclo_de_ingreso = v_ciclo_nuevos and
    v_tipo_ingreso in (Select T.Tipo From A_Tipo_Estudiante T ,Cti_Grupo_Tipo_Est Gr WHERE T.Codigo = Gr.Codigo_Tipo AND Gr.Id_Grupo = 1 Union Select 'NV' From Dual);
exception when no_data_found then
    htp.p('<!-- tipo de ingreso: ' || v_tipo_ingreso || ' -->');
end;*/

--IF P_CODIGO IN('40162001') THEN  -- IF DE TEST, QUITAR PARA PASO A PRODUCCION
IF SYSDATE BETWEEN to_date('20170116060000','RRRRMMDDHH24MISS') AND to_date('20170130235959','RRRRMMDDHH24MISS') THEN
--IF TO_CHAR(SYSDATE,'RRRRMMDDHH24MISS') BETWEEN '20150710080000' AND '20150803235959' AND P_CODIGO='42152002' THEN
IF v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NV','GM','HM','IH','PI','SA','SL') THEN
    V_ES_NUEVO:=1;
    SELECT be.indicador_pago
    into   v_ind_pago
    FROM   B_ESTUDIANTES BE
    WHERE  BE.CODIGO=p_codigo;
    if v_ind_pago in('P','V') then
       VPMATRICULADO:='OK';
       VPPERCUPO:='OK';
       SELECT COUNT(*)
       INTO   V_HAY_ASPIRANTES
       FROM   B_ESTUDIANTES BE
       WHERE  BE.CICLO_DE_INGRESO||BE.TIPO_DE_INGRESO IN(v_ciclo_nuevos||'NV',v_ciclo_nuevos||'GM',v_ciclo_nuevos||'HM',v_ciclo_nuevos||'IH',v_ciclo_nuevos||'PI',v_ciclo_nuevos||'SA',v_ciclo_nuevos||'SL',v_ciclo_nuevos||'SE');
       IF V_HAY_ASPIRANTES>0 THEN
          SELECT AP.CODIGO,AP.TIPOEST
          INTO   V_NIW,V_TIPOEST
          FROM   A_ASPIRANTES AP
          WHERE  AP.COD_DEF=P_CODIGO;
          IF V_TIPOEST='NUEVO' THEN
             VPCARACTERIZACION:=ENCUESTAS.CONTESTO_ENCUESTA(V_NIW,P_CODIGO);
             ELSE
             VPCARACTERIZACION:='1';
          END IF;
       END IF;
       else
       VPMATRICULADO:='XX';
    end if;
END IF;
END IF;
---------------------------------------------------

--IF p_codigo='26142024' then
  VPACTDAT:='OK';

--PREMATRICULA NUEVOS 201402
--IF TO_CHAR(SYSDATE,'RRRRMMDDHH24MISS') BETWEEN '20150713080000' AND '20150804235959' THEN
--IF TO_CHAR(SYSDATE,'RRRRMMDDHH24MISS') BETWEEN '20150710080000' AND '20150803235959' AND P_CODIGO='42152002' THEN
if  v_ciclo_de_ingreso||v_tipo_ingreso IN(v_ciclo_nuevos||'ME',v_ciclo_nuevos||'NV',v_ciclo_nuevos||'GM',v_ciclo_nuevos||'HM',v_ciclo_nuevos||'IH',v_ciclo_nuevos||'PI',v_ciclo_nuevos||'SA',v_ciclo_nuevos||'CA',v_ciclo_nuevos||'SL',v_ciclo_nuevos||'SE') THEN
  --IF P_CODIGO IN('26141000') THEN  -- IF DE TEST, QUITAR PARA PASO A PRODUCCION
  IF pkg_utils.estaVigente('OPC. PREMATRICULA NUEVOS') > 0 and v_tipo_ingreso not in ('ME') THEN
    if (VPPERCUPO     NOT IN('OK') OR
        VPDOCUMENTOS  NOT IN('OK') OR
        VPDEUDAFIN    NOT IN('OK') OR
        VPDEUDABIB    NOT IN('OK') OR
        VPDOCUEX      NOT IN('OK') OR
        VPACTDAT      NOT IN('OK') OR
        V_EXPULSADO!=0 OR
        VPCARACTERIZACION NOT IN('1') OR
        VPDATOSPER    NOT IN('OK')
        ) then
            --htp.p('<!-- ' || VPPERCUPO || ',' || VPDOCUMENTOS || ',' || VPDEUDAFIN || ',' || VPDEUDABIB || ',' || VPDOCUEX || ',' || VPACTDAT || ',' || V_EXPULSADO || ',' || VPCARACTERIZACION || ',' || VPDATOSPER || ' -->');
          HTP.P('
            <tr>
              <td>Inscripción a cursos de prácticas formativa</td>
              <td>&nbsp;</td>
            </TR>
            ');
          HTP.P('
            <tr>
              <td>Consultar prematrícula</td>
              <td><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
            </tr>
            ');
        else
            if pkg_utils.estaVigente('CLUSTER ESTUDIANTE') = 1 then
                HTP.P('
                <tr>
                <td>Inscripción a cursos de prácticas formativa</td>
                <td><input type="radio" name="p_opcion" value="formativas"></td>
                </TR>
                ');
            end if;
          --16JAN2017
          HTP.P('
          <tr>
          <td><label for="opt_prem_new">Registrar/consultar prematrícula</label></td>
          <td>');
          htp.p('<p><input id="opt_prem_new" type="radio" name="p_opcion" value="prematricula"></p>');
          --htp.p('<p align="center">&nbsp;</p>');
          htp.p('</td>
          </tr>
          ');

          HTP.P('
          <tr>
            <td>Consultar horario y salones</td>
            <td><p align="center"><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
          </tr>
          ');
      end if;
    else -- Si el nuevo esta fuera de fechas
        if pkg_utils.estaVigente('CLUSTER ESTUDIANTE') = 1 then
            HTP.P('
            <tr>
            <td>Inscripción a cursos de prácticas formativa</td>
            <td><input type="radio" name="p_opcion" value="formativas"></td>
            </tr>
            ');
        end if;
        if v_tipo_ingreso not in ('ME') then
              HTP.P('
                <tr>
                  <td><label for="consulta_prematricula_id">Consultar prematrícula</label></td>
                  <td><input id="consulta_prematricula_id" type="radio" name="p_opcion" value="consulta_prematricula"></td>
                </tr>
                ');
        end if;
  end if; --ENDIF FECHA
--END IF; -- FIN IF DE TEST, QUITAR PARA PASO A PRODUCCION
--------------------------------------------------------------------------------
-- FIN PREMATRICULA NUEVOS
--------------------------------------------------------------------------------
--END IF;--ENDIF TIPO DE INGRESO
--prematricula transferencias
elsif v_ciclo_de_ingreso||v_tipo_ingreso IN(v_ciclo_nuevos||'TI',v_ciclo_nuevos||'TE') THEN
    if pkg_utils.estaVigente('CLUSTER ESTUDIANTE') = 1 then
        HTP.P('
        <tr>
        <td>Inscripción a cursos de prácticas formativa</td>
        <td><input type="radio" name="p_opcion" value="formativas"></td>
        </TR>
        ');
    end if;
  HTP.P('
    <tr>
      <td>Consultar prematrícula</td>
      <td><input type="radio" name="p_opcion" value="consulta_prematricula"></td>
    </tr>
    ');
end if;
--fin transferencias
------------------------------------------------------------------------
--22-JUN-2015
--IMPRIMIR_GUIAS
--VALIDACIONES PREVIAS
------------------------------------------------------------------------
--IF  P_CODIGO IN('41152019')THEN
v_tiene_prematricula:=tiene_prematricula(p_codigo);

IF v_tiene_prematricula>0 THEN
    if (VPPERCUPO     NOT IN('OK') OR
        VPDOCUMENTOS  NOT IN('OK') OR
        VPDEUDAFIN    NOT IN('OK') OR
        VPDEUDABIB    NOT IN('OK') OR
        VPDOCUEX      NOT IN('OK') OR
        v_expulsado!=0             OR
        VPDATOSPER NOT IN ('OK')
         ) then
            htp.p('
            <tr>
            <td>Imprimir Guía de matricula</td>
            <td>*</td>
            </tr>
            ');
    Else
        /*htp.p('<!-- ' || pkg_utils.estaVigente('OPC. GUIAS') || ' -->');
        htp.p('<!-- ' || v_ciclo_de_ingreso || ' -->');
        htp.p('<!-- ' || v_ciclo_nuevos || ' -->');
        htp.p('<!-- ' || v_tipo_de_ingreso || ' -->');*/
       if ((pkg_utils.estaVigente('OPC. GUIAS') > 0 /*and v_ipago in ('X')*/) and (v_ciclo_de_ingreso!=v_ciclo_nuevos OR (v_ciclo_de_ingreso=v_ciclo_nuevos AND v_tipo_de_ingreso in('RI','RA','DT')) or (v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_de_ingreso='TI' /*AND v_codfac = '18'*/))) THEN
            --pkg_utils.getResumenCreditos(p_codigo, v_anio_act, v_ciclo_act, v_sem_inf, v_cred_max, v_cred_ins);
            /*if v_cred_ins > v_cred_max and pkg_utils.aplicaArt47(p_codigo) = 1 then
                htp.p('
                <tr>
                <td>Imprimir Guía de matricula-</td>
                <td>&nbsp;</td>
                </tr>
                ');*/
            htp.p('
                <tr>
                <td><label for="opt_guias">Imprimir Guía de matricula</label></td>
                <td><input id="opt_guias" type="radio" name="p_opcion" value="imprimir_guias_antiguos"></td>
                </tr>
                ');
        else
                /*htp.p('
                <tr>
                <td>Imprimir Guía de matricula</td>
                <td><input type="radio" name="p_opcion" value="imprimir_guias_antiguos"></td>
                </tr>
                ');*/
                htp.p('
                <tr>
                <td>Imprimir Guía de matricula.</td>
                <td>&nbsp;</td>
                </tr>
                ');
            --end if;
      end if;
end if;
END IF;
--END IF;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
/*
htp.p('
<tr>
  <td>Consultar Prematrícula</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="consulta_prematricula"></p></td>
</tr>
');
*/
/*
if  p_codigo in ('12081025') then
htp.p('
<tr>
  <td>Registrar Prematrícula</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="prematricula_2014"></p></td>
</tr>
');
htp.p('
<tr>
  <td>Manual  Prematrícula 2014</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="manuales_prematricula"></p></td>
</tr>
');
end if;*/
--htp.p('
--<tr>
--<td>Consultar Historico Idiomas</td>
--<td><p align="center"><input type="radio" name="p_opcion" value="consulta_hidiomas"></p></td>
--</tr>
--');


--13-JAN-2012
--SE COLOCO ESTA OPCION PARA Q LOS ESTUDIANTES NUEVOS PUEDAN CONSULTAR SUS RESULTADOS DE IDONEIDAD
if v_ciclo_de_ingreso=v_ciclo_nuevos and v_tipo_ingreso IN('NR','NV','HM','SA','IH','PI','GM') THEN
htp.p('
<tr>
  <td>Consultar resultados prueba de idioma</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="consulta_idoneidad"></p></td>
</tr>
');
end if;

IF  v_expulsado=0 THEN
HTP.P('
<tr>
  <td>Consultar Horario</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="horario"></p></td>
</tr>
');
END IF;




IF (V_fecha>=v_fecha_sistemas_inicial AND V_fecha<=v_fecha_sistemas_final AND v_expulsado!=1) THEN
   htp.p('
   <tr>
     <td>Inscripci&oacute;n Cursos de Sistemas</td>
     <td><p align="center"><input type="radio" name="p_opcion" value="inscripcion"></p></td>
   </tr>
   <tr>
   ');
END IF;

IF v_expulsado!=1 THEN
HTP.P('
<tr>
  <td>Actualización de datos</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="actualizar_datos_personales"></p></td>
</tr>
');
END IF;
-------------------------------
 --v_per1= no hay ningun ciclo activo
 --v_per1>1=hay mas de un ciclo activo
 SELECT count(*)
 INTO   v_per1
 FROM   a_periodo p
 Where  p.estado = 'A';
-------------------------------
 if (v_per1=0 or v_per1>1) then
    null;
    else
    v_cicloactual := cicloactual;
 end if;

/*HTP.P(v_cicloactual);
HTP.P(v_cicloactual);
HTP.P(v_cicloactual);
HTP.P(v_cicloactual);
HTP.P(v_cicloactual);*/


SELECT RTRIM(LTRIM(decode(max(TO_CHAR(t.fecha_final,'RRRRMMDD')),null,'0',max(TO_CHAR(t.fecha_final,'RRRRMMDD')))))
into   v_maximainscrip_idiomas
FROM   sii_fechas_cursos t
where  t.periodo = v_cicloactual and t.para = 1
and    nvl(t.activo,'S') <> 'N';

SELECT RTRIM(LTRIM(decode(min(TO_CHAR(t.fecha_inicial,'RRRRMMDD')),null,'0',min(TO_CHAR(t.fecha_inicial,'RRRRMMDD')))))
into   v_minimainscrip_idiomas
FROM   sii_fechas_cursos t
where t.periodo = v_cicloactual and t.para = 1
and    nvl(t.activo,'S') <> 'N' ;

select count(*)
into c_ins_clus
from
    a_horario_ingles hi
        inner join
    sii_fechas_cursos fc
        on hi.fec_inscripcion = fc.id
where
    sysdate between fc.fecha_inicial and fc.fecha_final;
if pkg_utils.estaVigente('INSCRIPCION CLUS') >= 1 and c_ins_clus > 0 then
    htp.p('
    <tr>
        <td><label for="opt-ins_ingles">Cursos de Ingles</label></td>
        <td><input id="opt-ins_ingles"type="radio" name="p_opcion" value="inscripcion_ingles"></td>
    </tr>
    ');
end if;

IF v_expulsado!=1 THEN
HTP.P('
<tr>
  <td>Consultar el Plan de Estudios</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="consulta_plan"></p></td>
</tr>
');
END IF;
HTP.P('
<tr>
  <td>Directorio de programas</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="directorio"></p></td>
</tr>
');

HTP.P('
<tr>
  <td>Evaluación a docentes</td>
  <td><p align="center"><input type="radio" name="p_opcion" value="evaldoc"></p></td>
</tr>
');
--factura saber pro --mariano rua mejia  03/04/2018
SELECT COUNT(*)
Into   V_Graduado
FROM   a_graduados g
Where  G.Numero_Acta                  <>0
And    To_Char(G.Fecha_Grado,'DDMMYYYY')<>'01011960'
And    G.Codigo_Estudiante              = P_Codigo;
if V_Graduado = 0 AND pkg_utils.estaVigente('FACTURAS SABER PRO') >0 then
  HTP.P('
  <tr>
    <td>Recibo de Pago Saber Pro</td>
    <td><p align="center"><input type="radio" name="p_opcion" value="fact_saber_pro"></p></td>
  </tr>
  ');
End If;
---------------------------------------------------------
--opcion deshabilitada el 23SEP2013
--HTP.P('
--<tr bgcolor="gray">
--<td>Cambio contraseña</td>
--<td><p align="center"><input type="radio" name="p_opcion" value="cambiocon"></p></td>
--</tr>
--');
htp.p('
<tr>
  <td><label for="opt-plan_aco">Sistema de Acompa&ntilde;amiento Integral</label></td>
  <td><input id="opt-plan_aco" type="radio" name="p_opcion" value="plan_acompaniamiento" /></td>
</tr>');

IF pkg_utils.estaVigente('GENERACION_CERTIFICADOS') >0 THEN
--jdcarranza 30/07/2018 value=certificados
HTP.P('
<tr id="certificado-row">
  <td >Solicitud Certificados</td>
  <td>
      <p align="center">
      <input type="radio" name="p_opcion" value="certificados">
  </td>
</tr>
');
END IF;


select count(*)
into   v_noprem
from   b_prematricula bp
where  bp.codigo_estudiante=p_codigo;

SELECT be.ciclo_de_ingreso,be.tipo_de_ingreso, be.anio||TO_NUMBER(be.ciclo)
into   v_ciclo_ingre,v_tipo_ingreso,V_CICLO_BAK
FROM   B_ESTUDIANTES BE
where  be.codigo=p_codigo;

HTP.P('
  </table>
</td>
<td align="center" style="font-family:Verdana; font-style:oblique; font-weight:bold; font-size:12px;">
  <p class="text-danger text-center">AVISOS IMPORTANTES</p>
  <section id="anuncios" data-speed="4" data-type="background">
  <textarea class="text-center" readonly="true">
');
--FIXME: Agregar para reintegros.

HTP.P('Si la información relacionada con apellidos y nombres, tipo de documento, número de documento y fecha de nacimiento, 
       presentan alguna inconsistencia, favor enviar copia del documento de identidad al correo: actualizardocumento@lasalle.edu.co
       ');                                                                   
IF to_number(V_CICLO_BAK) > to_number(v_ciclo_ingre) and (v_indpagovot in ('P', 'V') or V_MATRICULADOANTES in ('P','V')) THEN
    /*htp.p('Apreciado estudiante: para el proceso de prematrícula tenga en cuenta las siguientes fechas:');
    htp.p('Consulta turnos de prematrícula: 8 de junio de 2019 a partir de las 6:00 p.m.');
    htp.p('Prematrícula según programación de turnos: del 10 al 18 de junio de 2019.');
    htp.p('Prematrícula con solicitud de Reintegro y cambios de jornada: 19 de junio de 2019.');
    htp.p('Inscripción de créditos adicionales y modificaciones de prematrícula: 19 y 20 de junio de 2019.');
    htp.p('Impresión de guías de matrícula: a partir del 25 de junio de 2019 después de las 4:00 p.m.');*/
  --htp.p('El estudiante que inscriba más de seis (6) créditos adicionales no podrá generar la guía de matrícula.');
  --htp.p('La inscripción de los créditos adicionales está sujeta a la disponibilidad de cupos de la Unidad Académica que ofrece el espacio académico.');
  --htp.p('Generación guía de matrícula: el 14 de diciembre a partir de las 5:00 p.m., allí se reflejará el valor de la matrícula y de los créditos adicionales  (una sola guía).');
  --HTP.P('Apreciados Estudiantes:');
  --HTP.P('Informamos que podrán descargar su guía de matrícula a partir del viernes 18 de Diciembre desde de las 8:00 am. Si presenta algún inconveniente podrá comunicarse al teléfono 3488000 Ext 1207 donde se brindará soporte únicamente el día viernes en el horario de 8:00 am a 6:00 pm.');
  --htp.p('Señor estudiante, recuerde que puede pagar su matrícula en Banco Davivienda o Banco de Bogotá');
  null;
END IF;
If Vpdocumentos = 'OK' And V_Mensaje Is Not Null Then
htp.p(V_MENSAJE);
END IF;


--HTP.P(VPPERCUPO);
--HTP.P(VPDOCUMENTOS);
--HTP.P(VPFECHAS);
--HTP.P(VPDEUDAFIN);
--HTP.P(VPDEUDABIB);
--HTP.P(VPDOCUEX);
--HTP.P(VPACTDAT);
--HTP.P(v_expulsado);
--HTP.P(VPDATOSPER);
--HTP.P(VPMATRICULADO);

------------------------------------------------------------------------------------
--para prematricula cuando estan en turno normal
--------------------------------------------------------------------------------
/*
SELECT COUNT(*)
INTO   V_SASD
FROM   A_PERIODO_PRUEBA PP
WHERE  PP.ANO='2015'
AND    PP.CICLO='02'
AND    PP.INDICADOR>1
AND    PP.CODIGO_ESTUDIANTE=p_codigo;
IF v_sasd>0 then
   SELECT PP.INDICADOR
   INTO   V_ESTADO_SASD
   FROM   A_PERIODO_PRUEBA PP
   WHERE  PP.ANO='2015'
   AND    PP.CICLO='02'
   AND    PP.CODIGO_ESTUDIANTE=p_codigo;
END IF;
--23NOV2013
select count(*)
into   v_esta_en_turnos
from   turnos_estudiantes te
where  te.codigo=p_codigo;
IF v_esta_en_turnos>0 THEN
  --IF P_CODIGO IN('XXXXXXXX') THEN
  select count(*)
  into   v_turno
  from   turnos_estudiantes te
  where  te.codigo=p_codigo
  and    te.fecha=TO_CHAR(SYSDATE,'RRRRMMDD')
  and    TO_CHAR(SYSDATE,'HH24MI')>=substr(te.hora,1,4) and TO_CHAR(SYSDATE,'HH24MI')<=substr(te.hora,5,4);
    if (VPPERCUPO     NOT IN('OK') OR VPDOCUMENTOS NOT IN('OK')
        OR VPDEUDAFIN   NOT IN('OK')
        OR VPDEUDABIB NOT IN('OK') OR VPDOCUEX     NOT IN('OK')
        OR v_expulsado!=0 OR VPDATOSPER NOT IN ('OK')
        OR VPMATRICULADO NOT IN('OK')
        OR v_turno=0
         ) then
        if v_ciclo_de_ingreso!=v_ciclo_nuevos then
           HTP.P('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS:');
        end if;
        IF VPPERCUPO NOT IN('OK') THEN
             htp.p(VPPERCUPO);
        END IF;
        IF VPDATOSPER NOT IN('OK') THEN
        htp.p('');
        htp.p(VPDATOSPER);
        END IF;
        IF VPDOCUMENTOS NOT IN('OK')   THEN
            htp.p(VPDOCUMENTOS);
        END IF;
        IF  VPDEUDAFIN NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDAFIN);
        END IF;
        IF VPDEUDABIB NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDABIB);
        END IF;
        IF VPDOCUEX NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDOCUEX);
        END IF;
        IF VPMATRICULADO NOT IN('OK')  THEN
        htp.p('');
        htp.p('NO ESTUVO MATRICULADO EN EL CICLO ANTERIOR');
        END IF;
        IF v_turno=0 AND V_SASD=0 THEN
        htp.p('');
        --htp.p('AUN NO LE CORRESPONDE SU TURNO.');
        END IF;
    end if;
--END IF;
END IF;
IF v_esta_en_turnos=0 THEN
SELECT COUNT(*)
INTO   V_SASD
FROM   A_PERIODO_PRUEBA PP
WHERE  PP.ANO='2015'
AND    PP.CICLO='02'
AND    PP.INDICADOR>1
AND    PP.CODIGO_ESTUDIANTE=p_codigo;
IF v_sasd>0 then
   SELECT PP.INDICADOR
   INTO   V_ESTADO_SASD
   FROM   A_PERIODO_PRUEBA PP
   WHERE  PP.ANO='2015'
   AND    PP.CICLO='02'
   AND    PP.CODIGO_ESTUDIANTE=p_codigo;

   IF V_ESTADO_SASD='2' THEN
      htp.p('');
      htp.p('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS: ENTRÓ EN SUSPENSIÓN ACADÉMICA');
   END IF;
   IF V_ESTADO_SASD='3' THEN
      htp.p('');
      htp.p('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS: USTED ENTRÓ EN SUSPENSIÓN DEFINITIVA');
   END IF;
END IF;
END IF;*/
------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--para prematricula cuando entran todos
------------------------------------------------------------------------------------
/*
SELECT COUNT(*)
INTO   V_SASD
FROM   A_PERIODO_PRUEBA PP
WHERE  PP.ANO='2013'
AND    PP.CICLO='02'
AND    PP.INDICADOR>1
AND    PP.CODIGO_ESTUDIANTE=p_codigo;
IF v_sasd>0 then
   SELECT PP.INDICADOR
   INTO   V_ESTADO_SASD
   FROM   A_PERIODO_PRUEBA PP
   WHERE  PP.ANO='2013'
   AND    PP.CICLO='02'
   AND    PP.CODIGO_ESTUDIANTE=p_codigo;
END IF;
select count(*)
into   v_esta_en_turnos
from   turnos_estudiantes te
where  te.codigo=p_codigo;
IF v_esta_en_turnos>0 THEN
  --IF P_CODIGO IN('63121094') THEN
    if (VPPERCUPO     NOT IN('OK') OR VPDOCUMENTOS NOT IN('OK')
        OR VPDEUDAFIN   NOT IN('OK')
        OR VPDEUDABIB NOT IN('OK') OR VPDOCUEX     NOT IN('OK')
        OR v_expulsado!=0 OR VPDATOSPER NOT IN ('OK')
        OR VPMATRICULADO NOT IN('OK')
         ) then
        if v_ciclo_de_ingreso!=v_ciclo_nuevos then
           HTP.P('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS:');
        end if;
        IF VPPERCUPO NOT IN('OK') THEN
             htp.p(VPPERCUPO);
        END IF;
        IF VPDATOSPER NOT IN('OK') THEN
        htp.p('');
        htp.p(VPDATOSPER);
        END IF;
        IF VPDOCUMENTOS NOT IN('OK')   THEN
            htp.p(VPDOCUMENTOS);
        END IF;
        IF  VPDEUDAFIN NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDAFIN);
        END IF;
        IF VPDEUDABIB NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDABIB);
        END IF;
        IF VPDOCUEX NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDOCUEX);
        END IF;
        IF VPMATRICULADO NOT IN('OK')  THEN
        htp.p('');
        htp.p('NO ESTUVO MATRICULADO EN EL CICLO ANTERIOR');
        END IF;
        IF v_turno=0 AND V_SASD=0 THEN
        htp.p('');
        --htp.p('AUN NO LE CORRESPONDE SU TURNO.');
        END IF;
    end if;
--END IF;
END IF;

IF v_esta_en_turnos=0 THEN
SELECT COUNT(*)
INTO   V_SASD
FROM   A_PERIODO_PRUEBA PP
WHERE  PP.ANO='2013'
AND    PP.CICLO='02'
AND    PP.INDICADOR>1
AND    PP.CODIGO_ESTUDIANTE=p_codigo;
IF v_sasd>0 then
   SELECT PP.INDICADOR
   INTO   V_ESTADO_SASD
   FROM   A_PERIODO_PRUEBA PP
   WHERE  PP.ANO='2013'
   AND    PP.CICLO='02'
   AND    PP.CODIGO_ESTUDIANTE=p_codigo;
   IF V_ESTADO_SASD='2' THEN
      htp.p('');
      htp.p('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS: ENTRÓ EN SUSPENSIÓN ACADÉMICA');
   END IF;
   IF V_ESTADO_SASD='3' THEN
      htp.p('');
      htp.p('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS: USTED ENTRÓ EN SUSPENSIÓN DEFINITIVA');
   END IF;
END IF;
END IF;
*/
------------------------------------------------------------------------------------
--para prematricula reintegros y cambios de jornada
------------------------------------------------------------------------------------
--05DEC2013
/*
select count(*)
into   v_cambio_jornada
from   a_solicitudes_jornadas sj
where  sj.codigo_estudiante=p_codigo;
IF v_ciclo_de_ingreso||v_tipo_ingreso IN('20141RI','20141RA') OR v_cambio_jornada>0  THEN
    if (VPPERCUPO     NOT IN('OK') OR VPDOCUMENTOS NOT IN('OK')
        OR VPDEUDAFIN   NOT IN('OK')
        OR VPDEUDABIB NOT IN('OK') OR VPDOCUEX     NOT IN('OK')
        OR v_expulsado!=0 OR VPDATOSPER NOT IN ('OK')

         ) then
        if v_ciclo_de_ingreso!=v_ciclo_nuevos then
           HTP.P('NO PUEDE REALIZAR SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS:');
        end if;
        IF VPPERCUPO NOT IN('OK') THEN
             htp.p(VPPERCUPO);
        END IF;
        IF VPDATOSPER NOT IN('OK') THEN
        htp.p('');
        htp.p(VPDATOSPER);
        END IF;
        IF VPDOCUMENTOS NOT IN('OK')   THEN
            htp.p(VPDOCUMENTOS);
        END IF;
        IF  VPDEUDAFIN NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDAFIN);
        END IF;
        IF VPDEUDABIB NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDABIB);
        END IF;
        IF VPDOCUEX NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDOCUEX);
        END IF;
        IF VPACTDAT NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPACTDAT);
        END IF;
    end if;
END IF;
*/
---------------------------------------------------------------------------------
--21-JUN-2013
--para descarga de guias
------------------------------------------------------------------------------------
  v_tiene_prematricula:=tiene_prematricula(p_codigo);
   IF V_ES_NUEVO=0 THEN
      VPACTDAT:='OK';
   END IF;
   --htp.p(v_ciclo_de_ingreso);
   if ( VPPERCUPO  NOT IN('OK')
        OR VPDOCUMENTOS  NOT IN('OK')
        OR VPDEUDAFIN    NOT IN('OK')
        OR VPDEUDABIB    NOT IN('OK')
        OR VPDOCUEX      NOT IN('OK')
        OR V_EXPULSADO!=0
        OR VPDATOSPER    NOT IN ('OK')
        OR VPACTDAT    NOT IN ('OK')
        OR v_tiene_prematricula=0
         ) then
        if v_ciclo_de_ingreso!=v_ciclo_nuevos then
           HTP.P('NO PUEDE DESCARGAR SU GUIA DE MATRICULA POR LOS SIGUIENTES MOTIVOS:');
           NULL;
        end if;
        IF VPPERCUPO NOT IN('OK') THEN
           htp.p(VPPERCUPO);
        END IF;
        IF VPDOCUMENTOS NOT IN('OK')   THEN
            htp.p(VPDOCUMENTOS);
        END IF;
        IF  VPDEUDAFIN NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDAFIN);
        END IF;
        IF VPDEUDABIB NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDABIB);
        END IF;
        IF VPDOCUEX NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDOCUEX);
        END IF;
        IF V_EXPULSADO>0 THEN
        htp.p('SE ENCUENTRA EXPULSADO DE LA UNIVERSIDAD');
        END IF;
        IF VPDATOSPER NOT IN('OK') THEN
        htp.p('');
        htp.p(VPDATOSPER);
        END IF;
        IF  v_tiene_prematricula=0 THEN
        htp.p('');
        --htp.p('NO TIENE ASIGNATURAS PREMATRICULADAS.');
        END IF;
        IF V_ES_NUEVO=1 THEN
        IF VPACTDAT NOT IN('OK')  THEN
        htp.p('');
       -- htp.p(VPACTDAT);
        END IF;
        END IF;
    elsif v_tiene_prematricula > 0 and pkg_utils.estaVigente('OPC. PREMATRICULA EST') > 0 then
        htp.p('A partir del 22 de junio ingrese por la opción "Imprimir guía de matrícula" desde las 4:00 p.m.');
    end if;

------------------------------------------------------------------------------------
--10JUL2014
--PARA PREMATRICULA NUEVOS
------------------------------------------------------------------------------------
--IF P_CODIGO IN('14151113') THEN

IF TO_CHAR(SYSDATE,'RRRRMMDDHH24MISS') BETWEEN '20150713080000' AND '20170130235959' THEN
--IF TO_CHAR(SYSDATE,'RRRRMMDDHH24MISS') BETWEEN '20150710080000' AND '20150803235959' AND P_CODIGO='42152002' THEN
IF V_ES_NUEVO>0 THEN
   v_tiene_prematricula:=tiene_prematricula(p_codigo);
   --16JAN2017
   --VPACTDAT:='Apreciado estudiante Neolasallista en el momento nos encontramos realizando actividades de mantenimiento en el sistema. Esté atento en horas de la tarde para que pueda relizar su preinscripción de materias.';

   --IF V_ES_NUEVO=0 THEN
      --VPACTDAT:='OK';



   --END IF;
   if ( VPPERCUPO  NOT IN('OK')
        OR VPDOCUMENTOS  NOT IN('OK')
        OR VPDEUDAFIN    NOT IN('OK')
        OR VPDEUDABIB    NOT IN('OK')
        OR VPDOCUEX      NOT IN('OK')
        OR V_EXPULSADO!=0
        OR VPDATOSPER    NOT IN ('OK')
        OR VPACTDAT    NOT IN ('OK')
        OR VPCARACTERIZACION NOT IN('1')
         ) then
           --16JAN2017 HTP.P('NO PUEDE HACER SU PREMATRICULA POR LOS SIGUIENTES MOTIVOS:');
           IF VPCARACTERIZACION NOT IN('1') THEN
              HTP.P('La encuesta de caracterizacion para estudiantes nuevos no ha sido contestada o la contesto parcialmente, por favor acceda a dicha encuesta desde el vinculo existente en el proceso de inscripcion y diligenciela completamente');
           END IF;
        IF VPPERCUPO NOT IN('OK') THEN
           htp.p(VPPERCUPO);
        END IF;
        IF VPDOCUMENTOS NOT IN('OK')   THEN
            htp.p(VPDOCUMENTOS);
        END IF;
        IF  VPDEUDAFIN NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDAFIN);
        END IF;
        IF VPDEUDABIB NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDEUDABIB);
        END IF;
        IF VPDOCUEX NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPDOCUEX);
        END IF;
        IF V_EXPULSADO>0 THEN
        htp.p('SE ENCUENTRA EXPULSADO DE LA UNIVERSIDAD');
        END IF;
        IF VPDATOSPER NOT IN('OK') THEN
        htp.p('');
        htp.p(VPDATOSPER);
        END IF;
        IF V_ES_NUEVO=1 THEN
        IF VPACTDAT NOT IN('OK')  THEN
        htp.p('');
        htp.p(VPACTDAT);
        END IF;
        END IF;
    end if;
END IF;
END IF;
--end if;
--------------------------------------------------------------------------------
--17-FEB-2015 SE DEJO QUEMADO AVISO PROVISIONALMENTE
--IF v_maximainscrip_idiomas>0 AND TO_CHAR(SYSDATE,'RRRRMMDD')<= v_maximainscrip_idiomas THEN
--HTP.P('
--INSCRIPCIONES A CURSOS DE IDIOMAS HASTA: '||TO_DATE(v_maximainscrip_idiomas,'RRRR-MM-DD')||'
--');
--htp.p('
--Próximas inscripciones a cursos de idiomas del 30 de marzo al 15 de abril.
--');
--END IF;
SELECT COUNT(*)
INTO   v_esri
FROM   A_SOLICITUD_REINTEGRO SR
WHERE  SR.CODIGO_ESTUDIANTE=p_codigo;

/*IF v_esta_en_turnos>0 or v_esri>0 THEN
--HTP.P('Usted podrá consultar su turno para realizar la prematricula a partir del 04 de diciembre de 2014 a partir de las 4:00 p.m.');
HTP.P('
Si usted realizó prematrícula ingrese por la opción "Imprimir guía de matrícula" y descargue su guía de matrícula a partir
del 16 de diciembre de 2015 a las 4:00 p.m.
');
END IF;*/
/*
if v_esri>0 then
HTP.P('
Si usted realizó prematrícula ingrese por la opción "Imprimir guía de matrícula" y descargue su guía de matrícula a partir
del 26 de junio de 2015 a las 4:00 p.m.
');
end if;
*/
IF v_expulsado>0 THEN
 htp.p('');
 htp.p('USTED SE ENCUENTRA SANCIONADO.');
END IF;
if v_egresado_no_graduado > 0 then
    htp.p('Recuerde que, si su fecha de actualización de datos de grado es superior a un año, debe nuevamente ingresar a actualizar la información para continuar con su proceso.');
end if;

htp.p('A partir del 19 de noviembre de 2018, se podrá realizar la solicitud de certificados de estudio en la opción “SOLICITUD CERTIFICADOS” del menú del estudiante.');

htp.p('
</textarea>
</section>
</TD>
</TR>
');

htp.p('
</TABLE>
');

htp.p('
          <p class="text-center"><input type="submit" name="p_boton" value="Enviar Datos" class="btn btn-primary"></p>
        </div>
      </div>
    </div>
  </div>
');

htp.p('<div class="row">
            <div class="col-md-12">
                <div class="panel panel-info">
                    <div class="panel-heading"><strong>BASE DE DATOS SISTEMA DE BIBLIOTECAS</strong></div>
                    <div class="panel-body text-center">
                        <br /><br />

                        <div class="col-md-4">
                            <div class="thumbnail">
                                <a href="http://search.ebscohost.com/login.aspx?profile=eds&custid=s9800254&groupid=main&authtype=ip,guest" target="_blank">
                                    <img src="http://zeus.lasalle.edu.co/images/salle/biblioteca/2BibliotecaAcademica.jpg" alt="BASE DE DATOS ACADÉMICAS" style="height:65%;">
                                </a>
                                <a href="http://search.ebscohost.com/login.aspx?profile=eds&custid=s9800254&groupid=main&authtype=ip,guest" target="_blank">
                                        <div class="center label">BASE DE DATOS ACADÉMICAS</div>
                                </a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="thumbnail">
                                <a href="http://hemeroteca.lasalle.edu.co/login?url=http://search.ebscohost.com/login.aspx?profile=eds&custid=s9800254&groupid=main&authtype=ip,guest" target="_blank">
                                    <img src="http://zeus.lasalle.edu.co/images/salle/biblioteca/1%20SiatemaIntegradoBusqueda-EDS.jpg" alt="SISTEMA INTEGRADO DE BÚSQUEDA" style="height:65%">
                                </a>
                                <a href="http://hemeroteca.lasalle.edu.co/login?url=http://search.ebscohost.com/login.aspx?profile=eds&custid=s9800254&groupid=main&authtype=ip,guest" target="_blank">
                                      <div class="center label">SISTEMA INTEGRADO DE BÚSQUEDA</div>
                                </a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="thumbnail">
                                <a href="http://sibbila.lasalle.edu.co/janium-bin/janium_login_opac.pl" target="_blank">
                                    <img src="http://zeus.lasalle.edu.co/images/salle/biblioteca/3%20janiumsibbila.jpg" alt="CATÁLOGO SIBBILA" style="height:65%">
                                </a>
                                <a href="http://sibbila.lasalle.edu.co/janium-bin/janium_login_opac.pl" target="_blank">
                                      <div class="center label">CATÁLOGO SIBBILA</div>
                                </a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="thumbnail">
                                <a href="https://ciencia.lasalle.edu.co/" target="_blank">
                                    <img src="http://zeus.lasalle.edu.co/images/salle/biblioteca/4%20Repositoriocienciaunisalle.jpg" alt="REPOSITORIO CIENCIA UNISALLE" style="height:65%">
                                </a>
                                <a href="https://ciencia.lasalle.edu.co/" target="_blank">
                                      <div class="center label">REPOSITORIO CIENCIA UNISALLE</div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
      </div>');

select be.matriculados_ciclo_anterior,be.plan_estudio
                 into   v_yndpago,v_plan
                 from   b_estudiantes be
                 where  be.codigo=to_char(p_codigo);

                  select count(*)
                  into   v_esta_en_turnos
                  from   turnos_estudiantes te
                  where  te.codigo=p_codigo;
                  --VENTANA PARA INFORMAR LOS TURNOS
                  --MARIANO
                  -------------------------------------------------------------------
                  /*if v_yndpago in('P','V') AND v_plan>='3' AND v_esta_en_turnos>0 AND TO_CHAR(SYSDATE,'RRRRMMDDHH24MI')>='201506131400' then
                  htp.p('
                  <div id="modalAviso" class="modal fade" role="dialog" aria-labelledby="modalAvisoLbl" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                      <div class="modal-content">
                        <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 id="modalAvisoLbl" class="modal-title">AVISO</h4>
                        </div>
                        <div class="modal-body">

                  ');
                  --BLOQUEADO EL 08JUL2014
                  PAGINA_PGMCIONPREM_NUEVA_PREM(p_codigo);
                  htp.p('

                        </div>
                      </div>
                    </div>
                  </div>
                  <script type="text/javascript">
                    $(document).ready(function(){
                      $("#modalAviso").modal("show");
                    });
                  </script>
                  ');
                  END IF;*/

CTI_MODAL_DOCUMENTO(p_codigo);

htp.p('
</div>
<iframe id="fr-close" name="fr-close" src="about:blank" class="hide"></iframe>
<div id="cid" class="hide">' || xamplecripto(p_codigo, 'b9e7ad5849a30e37') || '</div>
</form>
');

desarrollospre.pkg_mensajes.html(p_codigo);

htp.p('
</body>
</html>
');

exception
when others then
    cti_pantalla_error('No puede acceder', sqlerrm);
END ls_menu_estudiante;