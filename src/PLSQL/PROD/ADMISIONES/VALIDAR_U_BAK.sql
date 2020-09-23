create or replace Procedure VALIDAR_U_BAK
(p_usuario varchar2 DEFAULT null,
 p_clave   varchar2 DEFAULT null,
 p_opcion  varchar2  DEFAULT null,
 p_boton   varchar2 default null)
is
    v_us          A_USUARIOS.codigo%type default null;
    V_TIPO        VARCHAR2(2);
    v_usuario     A_USUARIOS.USUARIO%TYPE;
    v_clave       A_USUARIOS.CLAVE%TYPE;
    v_clase       VARCHAR2(12) := null;
    v_codigo      NUMBER := null;  -- Codigo estudiantil, de facultad o del rector
    v_nombre      a_usuarios.nombre_usuario%type default null;
    v_cargo       a_usuarios.cargo_usuario%type default null;
    v_codigoe     varchar2(8):=null;
    v_NumeroError NUMBER;
    v_TextoError  VARCHAR2(200);
    v_hora        VARCHAR2(15);
    v_existe      number default 0;
    ------------------------------
    FECHA_ULT     VARCHAR2(8) DEFAULT NULL;
    DIAS_ULT      NUMBER      DEFAULT 0;
    FECHA_HOY     VARCHAR2(8) DEFAULT NULL;
    DIAS_HOY      NUMBER      DEFAULT 0;
    ------------------------------
    v_conexion              number        default 0;
    v_conexion_xchar        char(100)     default null;--es la conexion en b(x) con orden y opcion
    v_conexion_xotroformato char(100)     default null;--es la conexion en b(x) con orden y opcion en otro formato
    v_existe_conexion       number        default 0;
    v_ultima_conexion       date          default  null;
    v_doepcdxtuixtnm        number        default 0;
    V_Fecha_Grabar          Date          Default Null;
    v_numero_documento      varchar2(100) default null;
    v_fecha_conexion        varchar2(20)  default null;
    v_clave2                varchar2(4)   default null;
    v_usuario_clave varchar2(8) default null;
    v_facultad_origen varchar2(2) default null;
    v_fecha_captura_inicial2 date;
    v_fecha_captura_final2   date;
    v_cedula a_usuarios.numero_documento%TYPE;
    v_autoevaluacion NUMBER(3);--11-03-2005 Variable para saber si hizo autoevaluacion
    P_DOCUMENTO a_usuarios.numero_documento%type default null;
    v_bloquear_prematricula number default 0;
    v_tiene_datosper number default 0;
    v_jornada_facultad varchar2(1) default null;
    --v_fecha_cierre_sistema  VARCHAR2(8) DEFAULT '20060114';
      v_ipautorizada PLS_INTEGER;
      v_ciclo_de_ingreso b_estudiantes.ciclo_de_ingreso%TYPE DEFAULT NULL;
      v_tipo_de_ingreso  b_estudiantes.tipo_de_ingreso%TYPE  DEFAULT NULL;
      v_maxper a_ciclos_academicos.ciclo%type default null;
      V_CIERRE_PREMATRICULA NUMBER DEFAULT 0;
      v_existe_clave number default 0;
      v_codigo_usuario a_usuarios.codigo%type default null;
      v_mensaje varchar2(200) default null;
      v_grupo_cancelado number default 0;
      v_codfac  varchar2(2) default null;
      v_control number default 0;
      V_ACTIVAR_FACULTAD  number default 0;
      V_perfil      varchar2(3) default null;
      doc_actualizado  number default 0;
      v_ipautorizada2 VARCHAR2(100)  default NULL;
      V_MAXCICLO      VARCHAR2(5)    DEFAULT NULL;
      V_MAXCICLO_NV      VARCHAR2(5)    DEFAULT NULL;
      v_indpago       b_estudiantes.indicador_pago%type default null;
      v_usua VARCHAR2(100)  default NULL;
      v_boton varchar2(10) default null;
      existeprueba         number default 0;
      V_CICLO_NUEVOS       VARCHAR2(5)    DEFAULT NULL;
      V_MOSTRAR_VENTANA  NUMBER DEFAULT 0;
      V_TIENE_PREM       NUMBER DEFAULT 0;
      v_plan             b_estudiantes.plan_estudio%type default null;
      v_modernizacion    number                          default 0;
      v_yndpago          b_estudiantes.matriculados_ciclo_anterior%type default null;
      V_CODCHAR          VARCHAR2(2)                                    DEFAULT NULL;
      v_notas_parciales  number                                         default 0;
      V_ENCUESTA_ANT     number                                         default 0;
      v_esta_en_turnos   NUMBER                                         DEFAULT 0;
      V_NIW              A_ASPIRANTES.CODIGO%TYPE DEFAULT NULL;
      VPCARACTERIZACION        varchar2(1000) default null;
      v_tipoest                varchar2(7) default null;
      V_ACCESO                       number      default 0;
      v_conteo                       number      default 0;
      v_conteo1                      number      default 0;
      v_conteo2                      number      default 0;
       V_ESJURADO                     number      default 0;
       v_encuesta                     number      default 0;
       V_CONTEO_CIERREPREM            NUMBER      DEFAULT 0;
    v_datos varchar2(2048);
    v_cookie owa_cookie.cookie;
BEGIN

if length(p_usuario) != 4 or length(p_clave) != 4 then
    raise_application_error(-20008, 'Usuario o clave mal digitados.');
end if;

v_usuario := upper(p_usuario);
v_clave := upper(p_clave);

--19DEC2016
C_ACTNUMDOC_USUARIOS;

begin
    v_cookie := owa_cookie.get('dOe7LafrI8ph');
    v_datos := pkg_utils.f_leertoken(v_cookie.vals(1), 1/24, '3764613438353137');
    v_usuario := upper(regexp_substr(v_datos,'[^;]+',1,1));
    v_clave := upper(regexp_substr(v_datos,'[^;]+',1,2));
exception
when others then
    v_usuario := upper(p_usuario);
    v_clave := upper(p_clave);
end;

--CERRAR PREMATRICULA
SELECT COUNT(*)
INTO   V_CONTEO_CIERREPREM
FROM   a_ciclos_academicos ca
WHERE  ca.activacion_prematricula='N'
AND    ca.ciclo='20152';
IF V_CONTEO_CIERREPREM=0 THEN
IF TO_CHAR(SYSDATE,'RRRRMMDDHH24')='2015062612' THEN
   UPDATE  a_ciclos_academicos ca
   set     ca.activacion_prematricula='N'
   where   ca.ciclo='20152';
   COMMIT;
END IF;
END IF;
/*
htp.p('
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="/images/interna.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="/images/libreriaAjax.js"></script>
<link rel="stylesheet" type="text/css" href="/images/mootools/submodal.css" />
<script type="text/javascript" src="/images/mootools/submodalsource.js"></script>
<script type="text/JavaScript" src="/images/prototype.js"></script>
<script src="/assets/jsloader.js"></script>
<script type="text/javascript" src="/images/js/ventana-modal-1.1.1.js"></script>
<script type="text/javascript" src="/images/js/abrir-ventana-fija.js"></script>
<link href="/images/css/ventana-modal.css" rel="stylesheet" type="text/css">
<link href="/images/css/style.css" rel="stylesheet" type="text/css">
<script> JSLoader.load("ria","pro","1.6.0.1"); JSLoader.load("ria","pro","1.6.0.2"); JSLoader.load("ria","pro","1.9.9.9"); </script>
<script src="/images/scriptaculous.js?load=effects"></script>
</head>
<body>
');
*/
--htp.p(p_opcion);

--------------------------------------------------------------------------------------
C_ACTUALIZAR_DATOSPER;
--------------------------------------------------------------------------------------
--C_ACTUALIZAR_MATRICULADOS;
--------------------------------------------------------------------------------------



--SI HAY ALGUN NUEVO DE POSTGRADO MATRICULADO Y NO TIENE PREMATRICULA ENTONCES SE CREA
---POSTGRADO.GENERAR_PREMNUEVOS_BATCH;
---------------------------------------------------------------------------------------
--SI HAY ALGUN ESTUDIANTE MATRICULADO SIN % DE CREDITOS APROBADOS
C_BATCH_PORCREDAPROB;
--------------------------------------------------------------------------------------
update  a_prematricula_autorizados pa
set     pa.inde='S'
WHERE   PA.TOPE_CREDITOS>0
AND     pa.inde='N';
COMMIT;
--------------------------------------------------------------------------------------



IF TO_CHAR(SYSDATE,'RRRRMMDD')='20140627' THEN
   UPDATE  a_ciclos_academicos ca
   set     ca.activacion_prematricula='N'
   where   ca.ciclo='20142';
   COMMIT;
END IF;



SELECT COUNT(*)
INTO   V_ACCESO
FROM   A_USUARIOS U
WHERE  SUBSTR(U.USUARIO,1,2)='ZR'
AND    SUBSTR(U.CODIGO,1,1) IN('a','d')
AND    U.USUARIO=v_usuario
AND    U.CLAVE=v_clave;

-----------------------------------------------------------------------------------
--MODIFICADO EL 15JAN2014 PARA QUE EL DR SNEYDER PUEDA INGRESAR CON EL MENU MERKABA
if p_boton='CONSULTAR' then
  V_ACCESO:=0;
end if;
-----------------------------------------------------------------------------------



IF V_ACCESO=0 THEN
---HTP.P(p_opcion);
--10-MAY-2011
--SE IMPLEMENTO ESTE PROCEDIMIENTO PARA PODER DETERMINAR CUANDO HAYA MAS DE 300 SESIONES
--QUIENES ESTAN CONECTADOS
----------------------
--MONITOREAR_SESIONES;
-----------------------


/*HTP.P('
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>
<head>
<script type="text/javascript" src="/images/js/ventana-modal-1.1.1.js"></script>
<script type="text/javascript" src="/images/js/abrir-ventana-fija.js"></script>
<link href="/images/css/ventana-modal.css" rel="stylesheet" type="text/css">
<link href="/images/css/style.css" rel="stylesheet" type="text/css">
</head>
</body>
');*/

INSERT INTO A_ENTRADAS VALUES(v_usuario,v_clave,p_opcion,sysdate);
COMMIT;

--16-JUN-2009
select SUBSTR(U.codigo,1,3), U.codigo
into   v_perfil, v_us
from   a_usuarios u
where upper(U.USUARIO)=UPPER(v_usuario) AND UPPER(U.CLAVE)=UPPER(v_clave);

if regexp_like(v_perfil, '^(&)+$') then
    raise_application_error(-20009, 'Usuario no activo');
end if;

owa_util.mime_header('text/html', FALSE, 'ISO-8859-1');
--owa_cookie.send('wUFAnew4', '0', sysdate - 1/3600, '/', '.lasalle.edu.co', null);
owa_cookie.send('wUFAnew4', pkg_utils.f_crear_token_cookie(upper(v_usuario), upper(v_clave)), sysdate + 1/24, '/', '.lasalle.edu.co', null);
owa_util.http_header_close;
--HTP.P(v_perfil);
--MODIFICADO EL 04DEC2012 PARA QUE LOS ESTUDINATES DE DOCTORADOS PUEDAN ACCEDER A SU PERFIL COMO ESTUDIANTES
--SE AGREGO LA SIGUIENTE CONDICION:AND V_PERFIL NOT IN('DE1')

IF  not regexp_like(v_us, '^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$') and SUBSTR(v_perfil,1,1) in('D','S','d','a','E','P','Q','R','W') AND V_PERFIL NOT IN('DE1','DA1','EI1','ES1') then
           select SUBSTR(U.codigo,1,3)
           into   v_perfil
           from   a_usuarios u
           where U.USUARIO=v_usuario AND U.CLAVE=v_clave;
           if substr(v_perfil,1,1) in ('S','D') THEN


        /* HTP.P(v_usuario);
           HTP.P(v_clave);
           HTP.P(v_perfil);
           --HTP.P('XXXX');*/
           LS_MENU_FACULTADES(v_usuario,v_clave,v_perfil);
           END IF;
           if substr(v_perfil,1,1) in ('d','a') and substr(v_perfil,2,2)='46'  THEN
           htp.p('
           <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
           <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
           <form name="ensayo" action="http://registro.lasalle.edu.co/pls/yopal/LS_MENU_FAC" method="post">
           <input type="hidden" name="p_usuario" value='||v_usuario||'>
           <input type="hidden" name="p_clave"   value='||v_clave||'>
           <input type="hidden" name="v_tipo"    value='||substr(v_perfil,2,2)||'>
           <SCRIPT>
           function enviar()
           {
           document.ensayo.submit();
           }
           </SCRIPT>
           </form>
           ');
           END IF;
           if (substr(v_perfil,1,1) in ('d','a') and substr(v_perfil,2,2)='EP')  THEN
           --  LS_MENU_FAC(v_usuario,v_clave,substr(v_perfil,2,2));
           --END IF;
               --HTP.P('...');
               V_TIPO:=1;
               htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/MENU_Fac2_DECANO_pruebas" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||substr(v_perfil,2,2)||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');
               END IF;
           if (substr(v_perfil,1,1) in ('d','a') and substr(v_perfil,2,2)<'71') AND substr(v_perfil,2,2)!='46'  THEN
             LS_MENU_FAC(v_usuario,v_clave,substr(v_perfil,2,2));
           END IF;
           if substr(v_perfil,1,1) in ('d','a') and substr(v_perfil,2,2)>'71' THEN
               V_TIPO:=1;
               htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/MENU_Fac2_DECANO_pruebas" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||substr(v_perfil,2,2)||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');
            END IF;
            IF v_perfil='EXT' then
                select U.codigo
                into   v_us
                from   a_usuarios u
                where upper(U.USUARIO)=UPPER(v_usuario) AND UPPER(U.CLAVE)=UPPER(v_clave);
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://glass2.lasalle.edu.co:8080/extension/index.jsp" method="post">
                <input type="hidden" name="us"  value='||v_us||'>
                <input type="hidden" name="pas" value='||v_clave||'>
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            IF v_perfil='QDR' then
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://tigris.lasalle.edu.co:8080/InscripcionDoctorados/listadoAspirantes.jsp" method="post">
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            IF v_perfil='RDR' then
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://tigris.lasalle.edu.co:8080/InscripcionDoctorados/listadoAspirantes2.jsp" method="post">
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            IF v_perfil='WDR' AND v_clave in ('ZBWK','PFTV','XMLG','RAMN','JDR9') then
            --IF v_perfil='WDR' AND v_clave='DIAG' then BLOQUEADO EL 21FEB2019
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://tigris.lasalle.edu.co:8080/InscripcionDoctorados/listadoAspirantes1.jsp" method="post">
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            IF v_perfil='WDR' AND v_clave IN('VILL','ARIO','NHNT') then
              --HTP.P('NUEVO');
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://tigris.lasalle.edu.co:8080/InscripcionDoctorados/listadoAspirantes3.jsp" method="post">
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;



            IF v_perfil='EFI' then
                select U.codigo
                into   v_us
                from   a_usuarios u
                where upper(U.USUARIO)=UPPER(v_usuario) AND UPPER(U.CLAVE)=UPPER(v_clave);
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://glass2.lasalle.edu.co:8080/extension/index.jsp" method="post">
                <input type="hidden" name="us"  value='||v_us||'>
                <input type="hidden" name="pas" value='||v_clave||'>
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            /*
            IF v_perfil='PRE' then
                select U.codigo
                into   v_us
                from   a_usuarios u
                where upper(U.USUARIO)=UPPER(v_usuario) AND UPPER(U.CLAVE)=UPPER(v_clave);
                htp.p('
                <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                <form name="ensayo" action="http://oar.lasalle.edu.co:8085/extension/index.jsp" method="post">
                <input type="hidden" name="us"  value='||v_us||'>
                <input type="hidden" name="pas" value='||v_clave||'>
                </form>
                <SCRIPT>
                function enviar()
                {
                document.ensayo.submit();
                }
                </SCRIPT>
                ');
            END IF;
            */




ELSE
--19-JAN-2009
--monitorear entradas de usuarios en vacaciones

select count(*)
into   v_existe_clave
from   a_usuarios u
where  UPPER(u.usuario)=UPPER(v_usuario) and UPPER(u.clave)=UPPER(v_clave);
if v_existe_clave>0 then
    select u.codigo
    into   v_codigo_usuario
    from   a_usuarios u
    where  UPPER(u.usuario)=UPPER(v_usuario) and UPPER(u.clave)=UPPER(v_clave);
end if;


v_hora:=TO_CHAR(SYSDATE(),'YYYY HH24:MI:SS');
v_fecha_grabar:=sysdate();
v_fecha_conexion:=to_char(v_fecha_grabar,'YYYYMMDD HH24:MI:SS');

select SUBSTR(U.codigo,1,2)
into   V_CODCHAR
from   a_usuarios u
where  UPPER(v_usuario) = UPPER(USUARIO) AND UPPER(CLAVE)=UPPER(v_clave);

--04DEC2012
IF V_CODCHAR NOT IN('MI','EP','DE','DA','MY','MA','EI','ES','MP','MH','MD','OT','EV','MR','MG') THEN
select TO_NUMBER(U.codigo),numero_documento,clave2
into   v_codigo,v_numero_documento,v_clave2
From   A_Usuarios U
where  UPPER(v_usuario) = UPPER(USUARIO) AND UPPER(CLAVE)=UPPER(v_clave);
END IF;

v_tiene_datosper:=TIENE_DATOSPER(v_codigo);

    IF V_CODCHAR NOT IN('MI','EP','DE','DA','MY','MA','EI','ES','MP','MH','MD','OT','EV','MR','MG') THEN
    select TO_NUMBER(U.codigo)
    into   v_codigo
    from   a_usuarios u
    where  UPPER(v_usuario) = UPPER(USUARIO) AND UPPER(CLAVE)=UPPER(v_clave);
    END IF;



    --IF (v_codigo='9999' or v_codigo is null) then
    --   v_mensaje:='USUARIO NO VALIDO';
    --   alerta(v_mensaje);
    --END IF;

    IF (v_codigo>'10000000' and v_codigo<'71999999') then
       select be.codigo_facultad,be.jornada_facultad,be.ciclo_de_ingreso,be.tipo_de_ingreso,be.indicador_pago,be.plan_estudio
       into   v_codfac,v_jornada_facultad,v_ciclo_de_ingreso,v_tipo_de_ingreso,v_indpago,v_plan
       from   b_estudiantes be
       where  be.codigo=to_char(v_codigo)
       UNION
       select be.codigo_facultad,be.jornada_facultad,be.ciclo_de_ingreso,be.tipo_de_ingreso,be.indicador_pago,be.plan_estudio
       from   YOPAL.b_estudiantes be
       where  be.codigo=to_char(v_codigo);




       SELECT COUNT(*)
       INTO   v_grupo_cancelado
       FROM   b_prematricula bp
       WHERE  bp.codigo_estudiante=v_codigo
       AND    bp.facultad||bp.jornada_facultad=v_codfac||v_jornada_facultad
       AND    bp.indicador_reglamento='C';


      SELECT UNIQUE FC.ANIO||DECODE(FC.CICLO,'01','1','02','2')
      INTO   V_CICLO_NUEVOS
      FROM   A_FECHAS_DE_CORTE FC
      WHERE  SUBSTR(FC.PROCESO,1,36) LIKE '%ADMISION ESTUDIANTES NUEVOS-PREGRADO%';



     if v_codigo_usuario>='46000000' and v_codigo_usuario<='46999999' then
     doc_actualizado:=1;
     ELSE
     doc_actualizado:=TIENE_DOC_ACTUALIZADO(v_codigo_usuario);
     end if;

    doc_actualizado:=1;
    if doc_actualizado=0 then
    ACTUALIZAR_DOCUMENTO(v_codigo_usuario);
    else
    --select max(ca.ciclo)
    --INTO   V_MAXCICLO
    --from   a_ciclos_academicos ca;
    --select count(*)
    --into   v_encuesta
    --from   a_satisfaccion_aspir2 sa
    --where  sa.cod_def=v_codigo_usuario;
    --if ((v_ciclo_de_ingreso=V_MAXCICLO AND V_TIPO_DE_INGRESO IN('TI','TE','RI','RA') and v_indpago='P' and substr(v_codigo_usuario,1,2)!='45'))
    --or ((v_ciclo_de_ingreso=V_MAXCICLO AND V_TIPO_DE_INGRESO IN('TI','TE') and v_indpago='P' and substr(v_codigo_usuario,1,2)='45' and substr(v_codigo_usuario,6,3)>='600'))
    --or ((v_ciclo_de_ingreso=V_MAXCICLO AND V_TIPO_DE_INGRESO IN('RI','RA') and v_indpago='P' and substr(v_codigo_usuario,1,2)='45'))
    --THEN
    --   if v_encuesta=0 then
    --      encuesta_satisfaccion_tite2(v_codigo);
    --      ELSE
    --      LS_MENU_ESTUDIANTE(v_usuario,v_clave,p_boton);
    --   END IF;
    --   ELSE
       --HTP.P(v_codigo);
       if v_codigo>='46000000' and v_codigo<='46999999' then
            htp.p('
           <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
           <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
           <form name="ensayo" action="http://registro.lasalle.edu.co/pls/yopal/LS_MENU_ESTUDIANTE" method="post">
           <input type="hidden" name="p_usuario" value='||v_usuario||'>
           <input type="hidden" name="p_clave"   value='||v_clave||'>
           <input type="hidden" name="p_boton"   value='||v_boton||'>
           <SCRIPT>
           function enviar()
           {
           document.ensayo.submit();
           }
           </SCRIPT>
           </form>
           ');
          else
              select count(*)
              into   v_encuesta
              from   encuesta_aspirantes_resultados ec
              where  ec.cod_def=to_char(v_codigo);


              /*select COUNT(*)
              INTO   V_conteo1
              FROM   B_ESTUDIANTES BE,DATOS_PERSONALES DP
              where  dp.codigo_estudiante=be.codigo
              and    be.indicador_pago in('P','V')
              AND    TRUNC(MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'RRRR-MM-DD'),'RRRR-MM-DD'),
                     TO_DATE(TO_CHAR(dp.fecha_nacimiento,'RRRR-MM-DD'),'RRRR-MM-DD'))/12)>=18
              AND    DP.CODTIPO_DOCUMENTO='03'
              and    be.codigo=to_char(v_codigo);

              select COUNT(*)
              INTO   V_conteo2
              FROM   B_ESTUDIANTES BE,DATOS_PERSONALES DP
              where  dp.codigo_estudiante=be.codigo
              and    be.matriculados_ciclo_anterior in('P','V')
              AND    TRUNC(MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'RRRR-MM-DD'),'RRRR-MM-DD'),
                     TO_DATE(TO_CHAR(dp.fecha_nacimiento,'RRRR-MM-DD'),'RRRR-MM-DD'))/12)>=18
              AND    DP.CODTIPO_DOCUMENTO='03'
              and    be.codigo=to_char(v_codigo);
              v_conteo:=v_conteo1+v_conteo2;*/
              --jdrj Se retira por problemas de seguridad
              v_conteo := 0;
              if v_conteo>0 AND v_tiene_datosper>0 then
                 DOCU_VENTANA(v_codigo);
              else
                v_tiene_prem:=tiene_prematricula(v_codigo);
                select max(ca.ciclo)
                INTO   V_MAXCICLO
                from   a_ciclos_academicos ca;


                if ((v_ciclo_de_ingreso=V_MAXCICLO AND V_TIPO_DE_INGRESO IN('NV','GM','HM','IH','PI','SA')and v_indpago='P'and v_tiene_prem=0) )then
                 /*SELECT AP.CODIGO,AP.TIPOEST
                 INTO   V_NIW,V_TIPOEST
                 FROM   A_ASPIRANTES AP
                 WHERE  AP.COD_DEF=v_codigo;*/
                 --MODIFICADO EL 06JUL2012
                 --VPCARACTERIZACION:=ENCUESTAS.CONTESTO_ENCUESTA(V_NIW,V_CODIGO);
                 IF VPCARACTERIZACION='0' THEN
                    --VENTANA_ASPIRANTES;
                    null;
                 END IF;
                end if;



                 ---VENTANA_CALENDARIO_PREM;
                 --16NOV-2011

                 --BLOQUEADO EL 15-DEC-2011 POR DESCARGA DE GUIAS
                 --para modernizacion
                 select be.matriculados_ciclo_anterior,be.plan_estudio
                 into   v_yndpago,v_plan
                 from   b_estudiantes be
                 where  be.codigo=to_char(v_codigo);

                  select count(*)
                  into   v_esta_en_turnos
                  from   turnos_estudiantes te
                  where  te.codigo=V_codigo;
                  --VENTANA PARA INFORMAR LOS TURNOS
                  --MARIANO
                  -------------------------------------------------------------------
                  if v_yndpago in('P','V') AND v_plan>='3' AND v_esta_en_turnos>0 AND TO_CHAR(SYSDATE,'RRRRMMDDHH24MI')>='201406150800' then
                  --ventana_pgmcionprem_nueva_dos(v_codigo);

                  /*htp.p('
                  <html>
                  <head>
                  <script>
                  function toogle(a,b,c)
                  {
                    document.getElementById(b).style.display=a;
                    document.getElementById(c).style.display=a;
                  }
                  </script>
                  <style>
                  #modal
                  {
                    position: absolute;
                    padding: 0;
                    margin: 0;
                    width: 100%;
                    height: 800%;
                    z-index: 50;
                    filter: alpha(opacity=50);
                    opacity: 1.0;
                    -moz-opacity:1.0;
                    -webkit-opacity:1.0;
                    -o-opacity:1.0;
                    -ms-opacity:1.0;
                    background-color:rgb(242,242,242);
                    left: 0;
                    top: 0;
                    /*overflow: auto;*/
                 /* }

                  .contenedor
                  {
                    width: 680px;
                    background: #fff;
                    position: relative;
                    margin: 1% auto;
                    padding: 30px;
                    -moz-border-radius: 7px;
                    border-radius: 7px;
                    -webkit-box-shadow: 0 3px 20px rgba(0,0,0,0.9);
                    -moz-box-shadow: 0 3px 20px rgba(0,0,0,0.9);
                    box-shadow: 0 3px 20px rgba(0,0,0,0.9);
                    background: -moz-linear-gradient(#fff, #ccc);
                    background: -webkit-gradient(linear, right bottom, right top, color-stop(1, rgb(255,255,255)), color-stop(0.57,       rgb(230,230,230)));
                    text-shadow: 0 1px 0 #fff;
                  }

                  .contenedor h2 {
                    font-size: 36px;
                    padding: 0 0 20px;
                  }

                  .contenedor a[href="#close"] {
                    position: absolute;
                    right: 0;
                    top: 0;
                    color: transparent;
                  }

                  .contenedor a[href="#close"]:focus {
                    outline: none;
                  }

                  .contenedor a[href="#close"]:after {
                    content: ''X'';
                    display: block;
                    position: absolute;
                    right: -10px;
                    top: -10px;
                    width: 1.5em;
                    padding: 1px 1px 1px 2px;
                    text-decoration: none;
                    text-shadow: none;
                    text-align: center;
                    font-weight: bold;
                    background: #000;
                    color: #fff;
                    border: 3px solid #fff;
                    -moz-border-radius: 20px;
                    border-radius: 20px;
                    -webkit-box-shadow: 0 1px 3px rgba(0,0,0,0.5);
                    -moz-box-shadow: 0 1px 3px rgba(0,0,0,0.5);
                    box-shadow: 0 1px 3px rgba(0,0,0,0.5);
                  }

                  .contenedor a[href="#close"]:focus:after,
                  .contenedor a[href="#close"]:hover:after {
                    -webkit-transform: scale(1.1,1.1);
                    -moz-transform: scale(1.1,1.1);
                  }
                  </style>
                  </head>
                  <body>
                  ');
                /*  htp.p('
                  <div id="modal" style="display:none">
                  <div id="ventana" class="contenedor" style="display:none">
                  ');
                  PAGINA_PGMCIONPREM_NUEVA_DOS(V_CODIGO);

                  htp.p('
          <p>A continuación usted podrá ver el siguiente video con la nueva plataforma de la prematricula.</p>
          ');
         /* if to_char(SYSDATE+1,'DD/MM/YYYY HH24')>='15/06/2014 08' THEN
          htp.p('
          <p><a href="http://admisiones.lasalle.edu.co/turnos_prem_201402.htm" target="_blank">Consulte su turno de prematrícula aqu&iacute;</a></p>
          ');
          END IF;*/
          /*HTP.P('
          <center>
          <p><iframe width="560" height="315" src="//www.youtube.com/embed/yehfzCcH5rk" frameborder="0" allowfullscreen></iframe></p></center>
                  <a href="#close" title="Cerrar" onclick="toogle(''none'',''modal'',''ventana'');" >Close</a>
                  </div>
                  </div>
                  <script>
                  toogle(''block'',''modal'',''ventana'');
                  </script>
                  ');*/
                  NULL;
                  end if;
                  -------------------------------------------------------------------
                  v_notas_parciales:=existe_premnotasdep_pre(v_codigo);
                   --if v_notas_parciales>0 then
                    --SELECT COUNT(*)
                    --INTO   V_ENCUESTA_ANT
                    --FROM   A_SATISFACCION_ESTUDIANTES SE
                    --WHERE  SE.CODIGO=v_codigo;
                    --IF v_codigo='62042055' then
                    -- if V_ENCUESTA_ANT=0 then
                     --VENTANA_EVALOAR_ESTUDIANTES(v_codigo);
                     --end if;
                    --END IF;
                 --end if;

                SELECT COUNT(*)
                INTO   V_ESJURADO
                FROM   A_CITACIONES_JURADOS CJ
                WHERE  CJ.CODIGO=to_char(v_codigo)
                and    cj.anio||cj.ciclo in(
                select max(cj.anio||cj.ciclo)
                from   A_CITACIONES_JURADOS CJ
                );
                --DESHABILITADO EL 26MAY2014 A SOLICITUD DE OAR
                V_ESJURADO:=0;

                IF V_ESJURADO>0 THEN
                   VENTANA_JURADOS;

                END IF;
                --10-SEP-2014
                --AJUSTES DE ACUERDO CON LO ORDENADO POR LA OAR(CAMBIOS AL PROCESO DE ADMISIONES)
                -----------------------------------------------------------------------------------
                /*
                SELECT FC.ANIO||DECODE(FC.CICLO,'01','1','02','2')
                INTO   V_MAXCICLO_NV
                FROM   A_FECHAS_DE_CORTE FC
                WHERE  FC.PROCESO='ADMISION ESTUDIANTES NUEVOS-PREGRADO';
                if v_ciclo_de_ingreso=V_MAXCICLO_NV AND V_TIPO_DE_INGRESO IN('NV')and v_indpago='P' and v_encuesta=0 then
                   HTP.P('
                   <a href="#"
                   onclick="showPopWin(''ENCUESTA_SAT201501_NUEVOS?p_codigo='||V_codigo||''', 700, 400, ''HORARIO'');">
        	         xxx</a>
                   ');
                end if;
                */
                -----------------------------------------------------------------------------------
                LS_MENU_ESTUDIANTE(v_usuario,v_clave,p_boton);
              end if;
       end if;
    --END IF;
   END IF;

--------------------------------
   ELSIF (v_codigo>='72000000' and v_codigo<'98999999') OR V_CODCHAR IN('MI','DE','DA','MY','MA','EI','ES','MP','MH','MD','OT','EV','MR','MG') then
   htp.p('
   <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
   <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
   <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_estudiante" method="post" >
   <input type="hidden" name="p_usuario" value='||v_usuario||'>
   <input type="hidden" name="p_clave"   value='||v_clave||'>
   <SCRIPT>
   function enviar()
   {
   document.ensayo.submit();
   }
   </SCRIPT>
   </form>
   ');
-------------------------------
        ELSIF (v_codigo>'06' AND v_codigo< 71) and v_codigo IS NOT NULL then
        --BLOQUEADO EL 10NOV2014
        ---V_TIPO:=V_CODIGO;
        --MENU_FAC(v_usuario,v_clave,V_CODIGO);
        NULL;
        ELSIF (v_codigo>71 AND v_codigo< 99) and v_codigo IS NOT NULL then
        --HTP.P('http://registro.lasalle.edu.co/pls/postgrado/menu_fac2');
        --1 es la facultad
        --HTP.P('XXXX');
        -- V_TIPO:=1;
        --htp.p('
        --<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
        --<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
        --<form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_fac2" method="post">
        --<input type="hidden" name="p_usuario" value='||v_usuario||'>
        --<input type="hidden" name="p_clave"   value='||v_clave||'>
        --<input type="hidden" name=p_codigo  value='||v_codigo||'>
        --<input type="hidden" name="v_tipo"    value='||v_tipo||'>
        --<SCRIPT>
        --function enviar()
        --{
        --document.ensayo.submit();
        --}
        --</SCRIPT>
        --</form>
        --');
        NULL;
        ELSIF v_codigo in ('99','991','992','993','994') and V_usuario!='VRAC'then
            cti_redirect('menu_dir');
        ELSIF v_codigo in ('995')then
            cti_redirect('cti_menu_mercadeo');
        ELSIF v_codigo=100 THEN
           ---MENU_OPLA(v_usuario,v_clave);
           NULL;
         ELSIF v_codigo='103' THEN
          MENU_CONCEPTOS_TERMINACION(v_usuario,v_clave);
        ELSIF v_codigo in ('300') THEN
            cti_redirect('pkg_estudiantes.pr_arl_perfil_estudiantes');
        ELSIF v_codigo='513' THEN
           --15NOV2014
           M_VENTANILLA(v_usuario,v_clave);
        ELSIF v_codigo='514' THEN
           --20NOV2014
           M_VENTANILLA_TEMPORALES(v_usuario,v_clave);
        ELSIF v_codigo='199' THEN
           MENU_RELINTER(v_usuario,v_clave);
        ELSIF v_codigo='104' THEN
           MENU_BIBLIOTECA(v_usuario,v_clave);
        ELSIF v_codigo='105' THEN
           MENU_BIBLIOTECA(v_usuario,v_clave);
           --MENU_BIBLIOTECA_201601(v_usuario,v_clave);
        ELSIF v_codigo='106' THEN
           MENU_BIBLIOTECA(v_usuario,v_clave);
        ELSIF v_codigo='107' THEN
           MENU_BIBLIOTECA_GENERAL(v_usuario,v_clave);
        ELSIF v_codigo='108' THEN
           MENU_AUDIOVISUALES(v_usuario,v_clave);
        ELSIF v_codigo='119' THEN
        MENU_DIRFINAN(v_usuario,v_clave);
        NULL;
        /*ELSIF v_codigo=122 THEN

               V_TIPO:=2;
               htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_fac2" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||v_codigo||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');

               NULL;*/
        ELSIF v_codigo='125' THEN
              V_TIPO:=2;
              htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_fac2" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||v_codigo||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');

        ELSIF v_codigo='126' THEN
              V_TIPO:=2;
               htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_fac2" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||v_codigo||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');


        ELSIF v_codigo='124' THEN
              V_TIPO:=2;
               htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/menu_fac3" method="post">
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <input type="hidden" name=p_codigo  value='||v_codigo||'>
               <input type="hidden" name="v_tipo"    value='||v_tipo||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');
  --205 PROFESORES DE POSTGRADO
  elsif v_codigo = '201' then
    cti_redirect('cti_acceso_doc_summer');
  ELSIF v_codigo='205'   THEN
  SELECT u.numero_documento
  INTO   v_cedula
  FROM   a_usuarios u
  WHERE  UPPER(USUARIO) = UPPER(v_usuario)
  AND    UPPER(CLAVE)=UPPER(v_clave);
  v_autoevaluacion:=1;
  IF v_autoevaluacion = 0  THEN
     HTP.P('
     <script>
     alert("ESTIMADO PROFESOR LE SOLICITAMOS SU COLABORACION PARA EL DILIGENCIAMIENTO DE UNA ENCUESTA DENTRO DEL PROCESO DE ACREDITACION INSTITUCIONAL QUE ADELANTA LA UNIVERSIDAD.\nPARA TAL FIN DIRIJASE A LA PAGINA WEB DE LA UNIVERSIDAD (www.lasalle.edu.co) Y SELECCIONE EL ICONO ROJO LOCALIZADO EN LA PARTE INFERIOR DERECHA DE LA PAGINA Y LUEGO INGRESE COMO LO HA VENIDO HACIENDO PARA EL REGISTRO DE LAS NOTAS DEL EXAMEN FINAL.");
     </script>
     ');
     ir_home_page;
     ELSE
        select fecha_inicio,fecha_finalizacion
        into   v_fecha_captura_inicial2,v_fecha_captura_final2
        from   a_fechas_de_corte fc
        where  SUBSTR(fc.proceso,1,12)='CAPTURANOTAS'
        AND    SUBSTR(fc.menu,1,8)    ='NOTASPRE';
           v_conexion:=round(dbms_random.value*10000,0);
           --miro si la conexion EXISTE para ese usuario
           select count(*)
           into   v_existe_conexion
           from   a_conexiones cx
           where  cx.usuario=v_usuario and cx.clave=v_clave;
           if v_existe_conexion>0 then
              --la conexion existe para este usuario (entonces se elimina y se crea una nueva)
              delete a_conexiones cx
              where  cx.usuario=v_usuario and cx.clave=v_clave;
              commit;
              -----------------------------------------------------------
              v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
              insert into a_conexiones
              values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
              commit;
              -----------------------------------------------------------
              --pasa la conexion a hexadecimal
              v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
              --pasa la conexion a otro formato
              select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
              into   v_conexion_xotroformato from dual;

                    htp.p('
                   <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
                   <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
                   <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/FRAME_DOCENTES" method="post">;
                   <input type="hidden" name="p_usuario" value='||v_usuario||'>
                   <input type="hidden" name="p_clave"   value='||v_clave||'>
                   <SCRIPT>
                   function enviar()
                   {
                   document.ensayo.submit();
                   }
                   </SCRIPT>
                   </form>
                   ');


             else
                --la conexion no existe (entonces se crea una nueva)
                v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
                insert into a_conexiones
                values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
                commit;
                -----------------------------------------------------------
                --pasa la conexion a hexadecimal
                v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
                --pasa la conexion a otro formato
                select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
                into   v_conexion_xotroformato from dual;
              -----------------------------------------------------------
                htp.p('
                   <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
                   <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
                   <form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/FRAME_DOCENTES" method="post">;
                   <input type="hidden" name="p_usuario" value='||v_usuario||'>
                   <input type="hidden" name="p_clave"   value='||v_clave||'>
                   <SCRIPT>
                   function enviar()
                   {
                   document.ensayo.submit();
                   }
                   </SCRIPT>
                   </form>
                   ');
          end if;
         END IF;
         
  
-------------------------------------------------------------
--206 PROFESORES DE PREGRADO
  ELSIF v_codigo='206'  THEN
---------------------------------------------------------------------------------------
--20NOV2019
/*select count(*) into v_existe from HORACTUAL_NOVIEMBRE202019;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20191121' THEN
     insert into  HORACTUAL_NOVIEMBRE202019
     select * from ah_horizontal_actual;

     insert into  BPREMNOTASDEP_NOVIEMBRE202019
     select * from b_prematricula_notas_depurada;

     update ah_horizontal_actual ha
     set    ha.Fecha_Final_examen_final='22-NOV-19'
     where  ha.indicador_cierre IN ('C3','NU')
     and    ha.fecha_examen_final is not null;

     commit;
END IF;*/
---------------------------------------------------------------------------------------
/*--16OCT2019
select count(*) into v_existe from HORACTUAL_OCTUBRE162019;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20191017' THEN
     insert into  HORACTUAL_OCTUBRE162019
     select * from ah_horizontal_actual;

     insert into  BPREMNOTASDEP_OCTUBRE162019
     select * from b_prematricula_notas_depurada;

     update ah_horizontal_actual ha
     set    ha.Fecha_Final_Segundo_Corte='18-OCT-19'
     where  ha.indicador_cierre IN ('C2')
     and    ha.fecha_segundo_parcial is not null;

     commit;
END IF;*/
---------------------------------------------------------------------------------------
--03SEP2019
/*select count(*) into v_existe from HORACTUAL_SEPTIEMBRE032019;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20190904' THEN
     insert into  HORACTUAL_SEPTIEMBRE032019
     select * from ah_horizontal_actual;
     commit;
     insert into  BPREMNOTASDEP_SEPTIEMBRE032019
     select * from b_prematricula_notas_depurada;
     commit;
     update ah_horizontal_actual ha
     set    ha.fecha_final_primer_corte='05-SEP-19'
     where  ha.indicador_cierre IN ('C1')
     and    ha.fecha_primer_parcial is not null;
     commit;
     NULL;
END IF;
*/


--06JUN2017
/*select count(*) into v_existe from HORACTUAL_JUNIO062017;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20170607' THEN
     insert into  HORACTUAL_JUNIO062017
     select * from ah_horizontal_actual;

     insert into  BPREMNOTASDEP_JUNIO062017
     select * from b_prematricula_notas_depurada;

     update ah_horizontal_actual ha
     set    ha.Fecha_Final_examen_final='08-JUN-17'
     where  ha.indicador_cierre IN ('C3','NU')
     and    ha.fecha_examen_final is not null;

     commit;
END IF;*/




--28NOV2016
/*select count(*) into v_existe from HORACTUAL_NOVIEMBRE282016;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20161129' THEN
     insert into  HORACTUAL_NOVIEMBRE282016
     select * from ah_horizontal_actual;

     insert into  BPREMNOTASDEP_NOVIEMBRE282016
     select * from b_prematricula_notas_depurada;

     update ah_horizontal_actual ha
     set    ha.Fecha_Final_examen_final='30-NOV-16'
     where  ha.indicador_cierre IN ('C3','NU')
     and    ha.fecha_examen_final is not null;

     commit;
END IF;*/
/*--24OCT2016
select count(*) into v_existe from HORACTUAL_OCTUBRE252016;
IF   v_existe=0 and to_char(sysdate(),'YYYYMMDD')='20161026' THEN
     insert into  HORACTUAL_OCTUBRE252016
     select * from ah_horizontal_actual;

     insert into  BPREMNOTASDEP_OCTUBRE252016
     select * from b_prematricula_notas_depurada;

     update ah_horizontal_actual ha
     set    ha.Fecha_Final_Segundo_Corte='28-OCT-16'
     where  ha.indicador_cierre IN ('C2')
     and    ha.fecha_segundo_parcial is not null;

     commit;
END IF;*/


/*--18APR2017
select count(*) into v_existe from HORACTUAL_MAYO022017;
IF   v_existe=0 and sysdate >= to_date('201705030300','YYYYMMDDHH24MI') THEN
     insert into  HORACTUAL_MAYO022017
     select * from ah_horizontal_actual;
     commit;
     insert into  BPREMNOTASDEP_MAYO022017
     select * from b_prematricula_notas_depurada;
     commit;
     update ah_horizontal_actual ha
     set    ha.fecha_final_segundo_corte='05-MAY-17'
     where  ha.indicador_cierre IN ('C2')
     and    ha.fecha_segundo_parcial is not null;
     commit;
     NULL;
END IF;*/


--select DISTINCT to_char(ha.fecha_final_segundo_corte,'YYYYMMDD'),COUNT(*)
--from   ah_horizontal_actual ha
--GROUP BY to_char(ha.fecha_final_segundo_corte,'YYYYMMDD')
---------------------------------------------------------------------------------------
  SELECT u.numero_documento
  INTO   v_cedula
  FROM   a_usuarios u
  WHERE  UPPER(USUARIO) = UPPER(v_usuario)
  AND    UPPER(CLAVE)=UPPER(v_clave);
    v_autoevaluacion:=1;
    IF v_autoevaluacion = 0  THEN
       HTP.P('
       <script>
       alert("ESTIMADO PROFESOR LE SOLICITAMOS SU COLABORACION PARA EL DILIGENCIAMIENTO DE UNA ENCUESTA DENTRO DEL PROCESO DE ACREDITACION INSTITUCIONAL QUE ADELANTA LA UNIVERSIDAD.\nPARA TAL FIN DIRIJASE A LA PAGINA WEB DE LA UNIVERSIDAD (www.lasalle.edu.co) Y SELECCIONE EL ICONO ROJO LOCALIZADO EN LA PARTE INFERIOR DERECHA DE LA PAGINA Y LUEGO INGRESE COMO LO HA VENIDO HACIENDO PARA EL REGISTRO DE LAS NOTAS DEL EXAMEN FINAL.");
       </script>
       ');
       ir_home_page;
     ELSE
           v_conexion:=round(dbms_random.value*10000,0);
           --miro si la conexion EXISTE para ese usuario
           select count(*)
           into   v_existe_conexion
           from   a_conexiones cx
           where  cx.usuario=v_usuario and cx.clave=v_clave;
           if v_existe_conexion>0 then
              --la conexion existe para este usuario (entonces se elimina y se crea una nueva)
              delete a_conexiones cx
              where  cx.usuario=v_usuario and cx.clave=v_clave;
              commit;
              -----------------------------------------------------------
              v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
              insert into a_conexiones
              values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
              commit;
              -----------------------------------------------------------
              --pasa la conexion a hexadecimal
              v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
              --pasa la conexion a otro formato
              select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
              into   v_conexion_xotroformato from dual;
              -----------------------------------------------------------
              --FRAME_DOCENTES(V_USUARIO,V_CLAVE);
             else
                --la conexion no existe (entonces se crea una nueva)
                v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);htp.prn('<!-- cookie ' || v_existe_conexion || ' -->');
                insert into a_conexiones
                values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
                commit;
                -----------------------------------------------------------
                --pasa la conexion a hexadecimal
                v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
                --pasa la conexion a otro formato
                select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
                into   v_conexion_xotroformato from dual;
               -----------------------------------------------------------
               --frame_docentes(V_USUARIO,V_CLAVE);
          end if;
          cti_redirect('frame_docentes');
         END IF;--Fin de IF v_autoevaluacion = 0
        -------------------------------------------------------------
  ELSIF v_codigo='207'  THEN
     SELECT u.numero_documento INTO v_cedula FROM a_usuarios u
     WHERE UPPER(USUARIO) = UPPER(v_usuario) AND UPPER(CLAVE)=UPPER(v_clave);
     --HTP.P(v_cedula);

      --SELECT COUNT(*) INTO v_autoevaluacion FROM siis.sii_tbautoevaluacion@uvirtual.lasalle.edu.co e
      --WHERE e.ceddoc =v_cedula;
           v_conexion:=round(dbms_random.value*10000,0);
           --miro si la conexion EXISTE para ese usuario
           select count(*)
           into   v_existe_conexion
           from   a_conexiones cx
           where  cx.usuario=v_usuario and cx.clave=v_clave;
           if v_existe_conexion>0 then
              --la conexion existe para este usuario (entonces se elimina y se crea una nueva)
              delete a_conexiones cx
              where  cx.usuario=v_usuario and cx.clave=v_clave;
              commit;
              -----------------------------------------------------------
              v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
              insert into a_conexiones
              values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
              commit;
              -----------------------------------------------------------
              --pasa la conexion a hexadecimal
              v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
              --pasa la conexion a otro formato
              select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
              into   v_conexion_xotroformato from dual;
              -----------------------------------------------------------
              CV_frame_NOTAS_DEPURADO(rtrim(v_conexion_xotroformato));
              --htp.p('xxxxxxxxxx');
              else
                --la conexion no existe (entonces se crea una nueva)
                v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
                insert into a_conexiones
                values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
                commit;
                -----------------------------------------------------------
                --pasa la conexion a hexadecimal
                v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
                --pasa la conexion a otro formato
                select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
                into   v_conexion_xotroformato from dual;
              -----------------------------------------------------------
                CV_frame_NOTAS_DEPURADO(rtrim(v_conexion_xotroformato));
                --htp.p('xxxxxxx');
          end if;
        -------------------------------------------------------------
  ELSIF v_codigo='220'  THEN
---------------------------------------------------------------------------------------
  SELECT u.numero_documento
  INTO   v_cedula
  FROM   a_usuarios u
  WHERE  UPPER(USUARIO) = UPPER(v_usuario)
  AND    UPPER(CLAVE)=UPPER(v_clave);
    v_autoevaluacion:=1;
    IF v_autoevaluacion = 0  THEN
       HTP.P('
       <script>
       alert("ESTIMADO PROFESOR LE SOLICITAMOS SU COLABORACION PARA EL DILIGENCIAMIENTO DE UNA ENCUESTA DENTRO DEL PROCESO DE ACREDITACION INSTITUCIONAL QUE ADELANTA LA UNIVERSIDAD.\nPARA TAL FIN DIRIJASE A LA PAGINA WEB DE LA UNIVERSIDAD (www.lasalle.edu.co) Y SELECCIONE EL ICONO ROJO LOCALIZADO EN LA PARTE INFERIOR DERECHA DE LA PAGINA Y LUEGO INGRESE COMO LO HA VENIDO HACIENDO PARA EL REGISTRO DE LAS NOTAS DEL EXAMEN FINAL.");
       </script>
       ');
       ir_home_page;
     ELSE
           v_conexion:=round(dbms_random.value*10000,0);
           --miro si la conexion EXISTE para ese usuario
           select count(*)
           into   v_existe_conexion
           from   YOPAL.a_conexiones cx
           where  cx.usuario=v_usuario and cx.clave=v_clave;
           if v_existe_conexion>0 then
              --la conexion existe para este usuario (entonces se elimina y se crea una nueva)
              delete YOPAL.a_conexiones cx
              where  cx.usuario=v_usuario and cx.clave=v_clave;
              commit;
              -----------------------------------------------------------
              v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
              insert into YOPAL.a_conexiones
              values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
              commit;
              -----------------------------------------------------------
              --pasa la conexion a hexadecimal
              v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
              --pasa la conexion a otro formato
              select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
              into   v_conexion_xotroformato from dual;
              -----------------------------------------------------------
              htp.p('
             <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
             <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
             <form name="ensayo" action="http://registro.lasalle.edu.co/pls/yopal/FRAME_DOCENTES" method="post">;
             <input type="hidden" name="p_usuario" value='||v_usuario||'>
             <input type="hidden" name="p_clave"   value='||v_clave||'>
             <SCRIPT>
             function enviar()
             {
             document.ensayo.submit();
             }
             </SCRIPT>
             </form>
             ');
             else
                --la conexion no existe (entonces se crea una nueva)
                v_doepcdxtuixtnm:=round(dbms_random.value*1000000,0);
                insert into a_conexiones
                values(v_doepcdxtuixtnm,v_usuario,v_clave,v_codigo,v_fecha_grabar,v_numero_documento,v_clave2,v_clave2);
                commit;
                -----------------------------------------------------------
                --pasa la conexion a hexadecimal
                v_conexion_xchar:=TO_CHAR(v_doepcdxtuixtnm,'XXXXXXXXXXXX');
                --pasa la conexion a otro formato
                select translate(v_conexion_xchar,'0123456789ABCDEF','OTRUWYMPLQSXZVNK')
                into   v_conexion_xotroformato from dual;
               -----------------------------------------------------------
                htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="http://registro.lasalle.edu.co/pls/yopal/FRAME_DOCENTES" method="post">;
               <input type="hidden" name="p_usuario" value='||v_usuario||'>
               <input type="hidden" name="p_clave"   value='||v_clave||'>
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');
          end if;
         END IF;--Fin de IF v_autoevaluacion = 0
        -------------------------------------------------------------
       ELSIF v_codigo ='198' then
         --BLOQUEADO EL 11NOV2014
         --MENU_ASISTENTE(v_usuario,v_clave);
         --GGOA	KQCD	198	PATRICIA ORTIZ	11/05/2005 12:25:04 p.m.
         NULL;
        --ELSIF v_codigo=113 THEN
        --BLOQUEADO EL 11NOV2014
        --MENU_DOCENCIA(v_usuario,v_clave);
        --IDPC	DZIM	113	DRA. GLORIA PATRICIA		AAAS4eAAFAAAcISAAU
        --DEMO	DOCE	113	ADMISIONES		AAAS4eAAFAAAcJJABA
        --NULL;
        ELSIF v_codigo='114' THEN
          v_ipautorizada2:=Substr(owa_util.get_cgi_env('REMOTE_ADDR'), 1, 20);
          --desbloquado el 10dec2012 asolicitud del usuario
          --HTP.P(v_ipautorizada2);
          --IF v_ipautorizada2 IN('172.19.12.119','172.19.12.124') then
           ing_encabezado(v_usuario,v_clave);
          -- else
          -- aviso_general_fondo_gris('Usuario no autorizado.','white');
          -- end if;
        /*ELSIF v_codigo='223' THEN
          v_ipautorizada2:=Substr(owa_util.get_cgi_env('REMOTE_ADDR'), 1, 20);
          --desbloquado el 10dec2012 asolicitud del usuario
          --HTP.P(v_ipautorizada2);
          --IF v_ipautorizada2 IN('172.19.12.119','172.19.12.124') then
           ing_encabezado(v_usuario,v_clave);
          -- else
          -- aviso_general_fondo_gris('Usuario no autorizado.','white');
          -- end if;*/
        ELSIF v_codigo='223'  THEN
          v_ipautorizada2:=Substr(owa_util.get_cgi_env('REMOTE_ADDR'), 1, 20);
          --desbloquado el 10dec2012 asolicitud del usuario
          --HTP.P(v_ipautorizada2);
          --IF v_ipautorizada2 IN('172.19.12.119','172.19.12.124') then
           --ing_encabezado(v_usuario,v_clave);
          -- else
          -- aviso_general_fondo_gris('Usuario no autorizado.','white');
          -- end if;
          htp.p('
               <body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
               <form name="ensayo" action="https://jupiter.lasalle.edu.co:8181/IdiomasApp/jsp/usuario.action" method="post">;
               <SCRIPT>
               function enviar()
               {
               document.ensayo.submit();
               }
               </SCRIPT>
               </form>
               ');
        ELSIF v_codigo='8888' THEN
          v_ipautorizada2:=Substr(owa_util.get_cgi_env('REMOTE_ADDR'), 1, 20);
          --HTP.P(v_ipautorizada2);
          --HTP.P(v_ipautorizada2);
           --IF v_ipautorizada2='172.19.12.230' then
           --IF v_ipautorizada2='172.19.12.123' then
           --BLOQUEADO EL 11NOV2014
           --ing_encabezado(v_usuario,v_clave);
           NULL;
           --else
           --aviso_general_fondo_gris('Usuario no autorizado.','white');
           --end if;
        ELSIF v_codigo='115' THEN
          /*SELECT U.NUMERO_DOCUMENTO
          INTO   P_DOCUMENTO
          FROM   A_USUARIOS U
          WHERE  U.USUARIO=v_usuario AND U.CLAVE=V_CLAVE AND U.CODIGO='115';
          ing_encabezado(v_usuario,v_clave);*/
          NULL;
       ELSIF v_codigo IN('116') THEN
           v_usuario_clave:=v_usuario||v_claVE;
           --if v_usuario IN('TOEL','UM81','IRGR','UM88','UM94','UN02','DEHU') and v_clave in('CTKP','IW69','XFQR','UZ22','WH77','XN25','NX02','ZB99','HUMO') THEN
              MENU_HUMANIDADES(v_usuario,v_clave);
           /*ELSE
              if v_codigo<10 then
                 v_facultad_origen:='0'||v_codigo;
              end if;
              frame_mi_oar(v_facultad_origen,v_usuario_clave);
           end if;*/

        ELSIF v_codigo IN(120) THEN
         if v_usuario IN('QZWY','BIMA','KSGK','CMWY','YB46','YA98','YB43','YD14','YC55','JGYL','YYJB','ZCKS','TXSD','DECB','PAWI','DTJQ','HIRT') and v_clave in('QUJM','NCDD','ODQG','GHJM','ZG53','FF69','QL43','WY18','EG61','SQHP','HPBZ','BNTJ','CZVV','CBMO','LLJO','AKBQ','JCPF') THEN
            --HTP.P('AQUI');
            MENU_C_BASICAS(v_usuario,v_clave);
              ELSE
              if v_codigo<'10' then
                 v_facultad_origen:='0'||v_codigo;
              end if;
              --frame_mi_oar(v_facultad_origen,v_usuario_clave);
         END IF;
        ELSIF v_codigo IN('1202') THEN
            MENU_C_BASICAS(v_usuario,v_clave);
        ELSIF v_codigo ='112' THEN
           --09JUL2018 A SOLICITUD APLICACIONES ADMINISTRATIVAS
             cti_redirect('cti_informe_financiera_guias');
        ELSIF v_codigo ='113' THEN
           --13JAN2016 A SOLICITUD DE FINANCIERA
           MENU_FINANCIERA_III(v_usuario,v_clave);
        ELSIF v_codigo ='117' THEN
           --MENU_FINANCIERA(v_usuario,v_clave);
           cti_redirect('menu_financiera_ii');
        ELSIF v_codigo ='118' THEN
           --12AUG2015 A SOLICITUD DE FINANCIERA
           MENU_FINANCIERA_II(v_usuario,v_clave);
        ELSIF v_codigo ='121' THEN
           --22JUN2016 A SOLICITUD DE FINANCIERA
           MENU_FINANCIERA_IV(v_usuario,v_clave);
        ELSIF v_codigo ='122' THEN
           --22JUN2016 A SOLICITUD DE FINANCIERA
           MENU_FINANCIERA_V(v_usuario,v_clave);
        ELSIF v_codigo ='128' THEN
           --BLOQUEADO EL 11NOV2014
           --MENU_FINANCIERA_II(v_usuario,v_clave);
           --ZYIF	BPEE	128	MARTINEZ ALVAREZ JOSE ANTONIO	31/03/2014 10:59:54 a.m.
           NULL;
        ELSIF v_codigo ='130' THEN
        --BLOQUEADO EL 11NOV2014
        --MENU_AUXILIARES(v_usuario,v_clave);
        NULL;
        ELSIF v_codigo ='127' THEN
           --BLOQUEADO EL 11NOV2014
           ---MENU_TERCEROS(v_usuario,v_clave);
           --AVAT	ARRR	127	GONZALEZ EDUARD ANTHONY	07/05/2014 05:24:08 p.m.
          NULL;
        ELSIF v_codigo ='121' THEN
           --BLOQUEADO EL 11NOV2014
           --MENU_CURSOS_EXTENSION(v_usuario,v_clave);
           --BSWG	NDJC	121	DRA. MANUELA GOMEZ HURTADO	27/08/2013 11:23:30 a.m.
           NULL;
        ELSIF v_codigo in ('123','1231') then
            cti_redirect('menu_cultura_deporte');
        ELSIF v_codigo =203 then
           --BLOQUEADO EL 11NOV2014
           --MENU_consulta_horarios(v_usuario,v_clave);
           NULL;
        ELSIF v_codigo ='204' then
           --BLOQUEADO EL 11NOV2014
           --MENU_acreditacion(v_usuario,v_clave);
           NULL;
        ELSIF v_codigo ='208' then
           --BLOQUEADO EL 11NOV2014
           --C_ESTADISTICA_curvac_INTEGRADA;
           NULL;
        ELSIF v_codigo ='209' then
           menu_intersegsa(v_usuario,v_clave);
        ELSIF v_codigo ='218' then
           menu_intersegsa_RECEPCION(v_usuario,v_clave);
        ELSIF v_codigo in('212','214') then
           ----BLOQUEADO EL 11NOV2014
           --menu_TSOCIAL(v_usuario,v_clave);
           --MHWJ	YYJH	214	MARIA MONICA MONTAÑO	08/02/2011 03:02:55 p.m.
           NULL;
        ELSIF v_codigo ='213' then
           --BLOQUEADO EL 11NOV2014
           --menu_EXTENSION(v_usuario,v_clave);
           --JMJO	SHBK	213	ALCIDES MEDINA	10/07/2008 01:34:55 p.m.
           NULL;
        ELSIF v_codigo ='214' then
           ----BLOQUEADO EL 11NOV2014
           --m_archivo(v_usuario,v_clave);
           --MHWJ	YYJH	214	MARIA MONICA MONTAÑO	08/02/2011 03:02:55 p.m.
           NULL;
        ELSIF v_codigo ='215' then
           m_costos(v_usuario,v_clave);
        ELSIF v_codigo =217 then
           --BLOQUEADO EL 11NOV2014
           --MENU_COORD_DEPORTES(v_usuario,v_clave);
           --DEPO	DEPO	217			AAAS4eAARAAD7EYABW
           NULL;
        ELSIF v_codigo ='219' then
        --BLOQUEADO EL 11NOV2014
        --MENU_FIN_AUXINFO(v_usuario,v_clave);
        --RLNR	ROCR	219	GARCIA QUITIAN DIANA MRCEDES		AAAS4eAASAAL6SwAAq
        NULL;
        ELSIF v_codigo ='888' AND v_usuario in('OARX')then
           --BLOQUEADO EL 11NOV2014
           --1	OARX	OARX	888			AAAS4eAARAAD7EhAAe
           --HISPLA_barra_cca(v_usuario,v_clave);
           NULL;
        ELSIF v_codigo ='600'then
           --28-OCT-2009 ls_plantilla_vrac;
           barra_cca(v_usuario,v_clave);
           --AVISO_GENERAL_FONDO_AZUL('OPCION EN LABORES DE SUPERVISION Y MANTENIMIENTO','WHITE');
        ELSIF v_codigo ='601' then
        barra_planeacion_financiera(v_usuario,v_clave);
        --ELSIF v_codigo ='600' and v_usuario in('WNIG','SRMR','RLCB','WFHZ','ZUNI','CQIC','CEGU','CATO')then
        --barra_asistentes(v_usuario,v_clave);
        --AVISO_GENERAL_FONDO_AZUL('OPCION EN LABORES DE SUPERVISION Y MANTENIMIENTO','WHITE');
        --ELSIF v_codigo ='600'/* and v_usuario in('PFHO')*/then
        --PARA PERSONAL
           --28-OCT-2009 ls_plantilla_OFPER;
           --barra_ofper(v_usuario,v_clave);
             --AVISO_GENERAL_FONDO_AZUL('OPCION EN LABORES DE SUPERVISION Y MANTENIMIENTO','WHITE');
        ELSIF v_codigo ='602'then
            barra_ofper(v_usuario,v_clave);
        ELSIF v_codigo ='700' then
           --capa_financiera(v_usuario,v_clave);
           NULL;
        ELSIF v_codigo='800' then
          iframe_admisiones(v_usuario,v_clave);
        ELSIF v_codigo='801' then
          iframe_admisiones(v_usuario,v_clave);
        ELSIF v_codigo='802' then
          iframe_admisiones(v_usuario,v_clave);
        ELSIF v_codigo='803' then
          --BLOQUEADO EL 12NOV2014
          --iframe_admisiones(v_usuario,v_clave);
          NULL;
        ELSIF v_codigo='804'  then
        consulta_estudiantesxapellidos;
        ELSIF v_codigo='805' then
        HTP.P('
        <a href="correccion_notas.frame">Ingresar</a>
        ');
        --correccion_notas.frame;
        --HTP.P('HOLA');
        ELSIF v_codigo='876' then
           --HTP.P(v_usuario);
           --HTP.P(v_clave);
           CTI_SPADIES_BARRA_AUXILIOS(v_usuario,v_clave);
        ELSIF v_codigo='900' then
           --HTP.P('123');
           MENU_ASISTENTE_VRAC(v_usuario,v_clave);
        ELSIF v_codigo='902' then
           --HTP.P('123');
           MENU_FILANTROPIA(v_usuario,v_clave);
           ---menu_prem4445(v_usuario,v_clave);
        ELSIF v_codigo='903' then
        --28SEP2016
        cti_gestor_documental(v_usuario,v_clave);
        ELSIF v_codigo='918' THEN
        --20JAN2017
        M_GRABAR_NOTAS_NUEVOS(v_usuario,v_clave);
        ELSIF v_codigo='1000' then
        --BLOQUEADO EL 12NOV2014
        --admin_oar.CP_VALIDAR_USUARIO_CONTACTO(v_usuario,v_clave);
        NULL;
        ELSIF v_codigo='1100' then
        --BLOQUEADO EL 12NOV2014
        --ADMIN_OAR.expoestudiante(v_usuario,v_clave);
        NULL;
        ELSIF v_codigo='901' then
          --03MAR2017
          --aviso_general_fondo_azul('Opción en labores de supervisión y mantenimiento.','white');
          
          --27-MAY-2015
          --V_IPAUTORIZADA2:=SUBSTR(OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR'), 1, 20);
          --htp.p(V_IPAUTORIZADA2);
          --IF V_IPAUTORIZADA2 IN(
          --  '201.234.64.78','172.19.0.36'
          --  ) then
             IFRAME_DOCUMENTACION;
           -- ELSE
          --   AVISO_GENERAL_FONDO_ROJO('Usuario no autorizado','white');
         -- END IF;
          
          --ips que estaban activas al 14MAY2015
          --'200.31.91.78','192.168.56.1','172.19.3.9','172.18.6.180','172.16.6.185','172.19.3.14'
          /*IF v_ipautorizada2 IN(
            '172.18.6.110',
            '172.18.6.103',
            '172.18.6.172',
            '172.18.6.204',
            '192.168.56.1',
            '172.18.6.73'
            ) then
             IFRAME_DOCUMENTACION;
             ELSE
             AVISO_GENERAL_FONDO_ROJO('Usuario no autorizado','white');
          END IF;*/
      ELSIF v_codigo='9015' then
          cti_redirect('iframe_pdfs');
      ELSIF (v_perfil='806' OR v_perfil='807')  then
                --BLOQUEADO EL 12NOV2014
                --select U.codigo, u.NOMBRE_USUARIO, u.clave,U.USUARIO
                --into   v_us,v_usua,v_clave, V_USUARIO
                --from   a_usuarios u
                --where upper(U.USUARIO)=UPPER(v_usuario) AND UPPER(U.CLAVE)=UPPER(v_clave);
                --htp.p('
                --<body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
                --<form name="ensayo" action="http://oar.lasalle.edu.co:8085/certificaciones_final/indexCertifVentanilla.jsp" method="post">
                --<input type="hidden" name="us"  value='||v_us||'>
                --<input type="hidden" name=nom_us  value="'||v_usua||'">
                --<input type="hidden" name="pas" value='||v_clave||'>
                --<input type="hidden" name=usuario value='||v_USUARIO||'>
                --</form>
                --<SCRIPT>
                --function enviar()
                --{
                --document.ensayo.submit();
                --}
                --</SCRIPT>
                --');
                NULL;
        END IF;
END IF;
        IF v_codigo='2009'  then
           ADMIN_OAR.cp_admon_cursos;
        end if;
        IF V_CODIGO='1201' THEN
        MENU_CBASICAS_ASISTENTE(v_usuario,v_clave);
        END IF;

        IF v_codigo='808'  then
            --MODIFICADO EL 01-FEB-2012 POR SOLICITUD DE LA VRAC (DEBE VER LOS CONSOLIDADOS)
            BARRA_COORD_CUR(null,null);
        end if;
        IF v_codigo='809' then
        --BLOQUEADO EL 12NOV2014
        --trazabilidad(V_CODIGO);
        NULL;
        END IF;

        IF v_codigo='810' then
        --BLOQUEADO EL 12NOV2014
        --COMBO_PROMEDIOS_VRIT;
        NULL;
        END IF;

        IF v_codigo='811' then
        MENU_VPDH_COORDINADOR(v_usuario,v_clave);
        END IF;
        IF v_codigo='812' then
        --BLOQUEADO EL 12NOV2014
        ---trazabilidad(V_CODIGO);
        NULL;
        END IF;
        IF v_codigo in ('813','814','815','816','817','818') then
        --BARRA_AUTOEVALUACION(v_usuario,v_clave);
            cti_redirect('ls_menu_dir_v2');
        END IF;
        IF v_codigo in ('799') then
        --BARRA_AUTOEVALUACION(v_usuario,v_clave);
            cti_redirect('pkg_operador_sala.html');
        END IF;
        IF v_codigo in ('111') then
           --26OCT2017
           perfiles;
        END IF;
        IF v_codigo in ('005','006','007') then
            cti_redirect('pkg_menu_oar.html');
        END IF;
END IF;
/*htp.p('</body>
       </html>');*/

Exception
       WHEN no_data_found THEN
       /*v_mensaje:='USUARIO Y/O CLAVE NO VALIDOOOOOOOOOOOOOOOO';
       alerta(v_mensaje);

        htp.p('
        <script>
        window.open('''',''_parent'','''');
        window.close();
        </script>
        </body>
        </html>
        ');*/
        --pkg_utils.p_redirect('cti_pantalla_error', 'p_titulo=Usuario no valido&p_mensaje=Por favor reintente');
        cti_pantalla_error('Usuario no valido', 'Por favor reintente.');
WHEN OTHERS THEN
       /*v_NumeroError := SQLCODE;
       v_TextoError := SUBSTR(SQLERRM,1,200);
       INSERT INTO b_log(codigo,mensaje,informacion)
       VALUES(v_NumeroError,v_TextoError,'Error en validar_u el dia ' ||
       TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS'));*/
       cti_pantalla_error('Sin acceso', sqlerrm);
END VALIDAR_U_BAK;