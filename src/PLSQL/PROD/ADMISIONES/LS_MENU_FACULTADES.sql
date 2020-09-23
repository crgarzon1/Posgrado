create or replace Procedure LS_MENU_FACULTADES
( p_usuario varchar2, p_clave varchar2, p_fac varchar2
    )

  IS
v_nombre_usuario             a_usuarios.nombre_usuario%type default null;
v_usuario     varchar2(4) := P_USUARIO;
vconsultas    number;
v_fecha_bloqueo   varchar2(12) default NULL;
v_cargo           varchar2(30) default null;
v_nomfac        a_maestro_facultades.nombre%type default null;
v_apertura_plantilla number default 0;
v_fechaini_horarios varchar2(8) default null;   
v_fechafin_horarios varchar2(8) default null;

v_fechaini_plantilla varchar2(8) default null;   
v_fechafin_plantilla varchar2(8) default null;

v_fechaini_bloqueoprem varchar2(12) default NULL;  
v_fechafin_bloqueoprem varchar2(12) default NULL;  
v_tipo varchar2(100) default NULL;  
V_CICLO varchar2(100) default NULL;  
v_ced_us varchar2(100) default NULL;  
v_codigo varchar2(100) default NULL;  
V_FAC_AUX VARCHAR2(100) DEFAULT '';


CURSOR FACULTADES IS
select unique fu.codigo_facultad codigo,fu.nombre 
from   a_programas p,a_facultades_unica fu
where  p.codigo=fu.codigo_facultad
and    p.facultad=SUBSTR(p_fac,2,2)
AND    P.CODIGO BETWEEN '10' AND '70'
and    p.codigo not in('21','35','15','22','28','29')
order   by 2;
V_BANDERA                     A_FECHAS_DE_CORTE.IND_CIERRE%TYPE DEFAULT '0';

BEGIN 
--Htp.p('LS_MENU_FACULTADES');
/*htp.p(p_usuario);
htp.p(p_clave);
htp.p(p_fac);
*/


SELECT UNIQUE P.CODIGO
INTO V_FAC_AUX 
FROM A_PROGRAMAS P 
WHERE P.FACULTAD = substr(p_fac,2,3) 
AND P.CODIGO LIKE '0%';

--HTP.P(V_FAC_AUX);

SELECT FC.IND_CIERRE
INTO   V_BANDERA
FROM   A_FECHAS_DE_CORTE FC
WHERE  SUBSTR(FC.PROCESO,1,21)='CIERRE NOTAS PREGRADO';  

SELECT me.nombre
INTO   v_nomfac
FROM   a_maestro_facultades me
where  me.codigo_unidad=SUBSTR(p_fac,2,2);



select to_char(fc.fecha_finalizacion,'YYYYMMDDHH24MI')
into   v_fecha_bloqueo
from   a_fechas_de_corte fc
where  SUBSTR(fc.proceso,1,43)='BLOQUEAR FACULTADES POR IMPRESION DE LISTAS';


select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
INTO   v_fechaini_bloqueoprem,v_fechafin_bloqueoprem
from   a_fechas_de_corte fc
where  SUBSTR(fc.proceso,1,30)='BLOQUEAR OPCIONES PREMATRICULA';

select u.nombre_usuario,DECODE(substr(u.codigo,1,1),'D','-DECANO','S','-SECRETARIO ACADEMICO',NULL)
into   v_nombre_usuario,v_cargo
from   a_usuarios u
where  u.usuario=v_usuario
and    u.clave=p_clave;
----------------------------
SELECT nvl(u.NCONSULTAS,0)+1
INTO   VCONSULTAS
FROM   A_USUARIOS u
WHERE  u.usuario = p_usuario
and    u.clave=p_clave;
----------------------------
update a_usuarios u
set    u.nconsultas = vconsultas,u.uconsulta = sysdate
where  u.usuario = p_usuario
and    u.clave=p_clave;

htp.p('
<html>
<head>
<p align="center"><img src="/images/LOGOSALLE.gif" border="0"><br></p>
<link href="/images/interna.css" rel="stylesheet" type="text/css">
<title>oar</title>
<link rel="stylesheet" href="http://zeus.lasalle.edu.co/oar/css/ui/lasalle/jquery-ui-1.10.0.custom.min.css" type="text/css" />
        <link rel="stylesheet" href="http://zeus.lasalle.edu.co/oar/css/modal/mod_modalpopup.css" type="text/css" />
        <script src="http://zeus.lasalle.edu.co/oar/js/jquery/jquery-1.9.1.js" type="text/javascript"></script> 
        <script src="http://zeus.lasalle.edu.co/oar/js/jquery/ui/jquery-ui.js" type="text/javascript"></script>
 
        <script>
         $(function() {
         
                         var getValue = function (valor, ancho) {
                               if (valor.indexOf("%") > 0) {
                                               valor = valor.substring(0, valor.indexOf("%"));
                                               valor = Math.ceil((ancho ? $(window).width() : $(window).height()) * valor / 100);
                                               if (valor < 510 && ancho) {
                                                               return 510;
                                               } else if (valor < 430 && !ancho) {
                                                               return 430;
                                               }
                               }
                               return valor;
                       }
         
                       var onclose = "http://prematricula.lasalle.edu.co:8080/prematricula-ua/exit.oar";
                       var alto = getValue("87%", false);
                       var ancho = getValue("87%", true);
                        $("#datos").dialog({
                        autoOpen: false,
                        width: 1100,
                        height: 768,
                        modal: true,
                        resizable: false,
                        beforeClose: function(event, ui) {
                            if($("input[name=p_opcion]:radio:checked").val() !="credenciales_docentes"){
                            if (onclose) {
                               $("#prem_nuevos").attr("src", onclose); 
                                  $("#prem_nuevos").attr("src", "");
                                }
                                
                                }
                            if($("input[name=p_opcion]:radio:checked").val() =="credenciales_docentes"){
                                   $("#prem_nuevos").attr("src", "http://jupiter.lasalle.edu.co/credenciales/exit.oar"); 
                                   
                                }
                         
                        }
                        });
                       });
         function enviarForma1(){
            if($("input[name=p_opcion]:radio:checked").val() == "postgrado"){
                var win = window.open("http://zeus.lasalle.edu.co/oar/sia/postgrado/", "_blank");
            }
            else {
                if($("input[name=p_opcion]:radio:checked").val() != "credenciales_docentes"){
                    $("form[name=forma1]").submit();
                }
                if($("input[name=p_opcion]:radio:checked").val() == "credenciales_docentes"){
                    var url = "http://registro.lasalle.edu.co/pls/regadm/pg_cred_doc?P_CODIGO=D'||V_FAC_AUX||'";
                    $("#prem_nuevos").attr("src", url);
                    $("#datos").dialog("open");  
                    $("#datos").dialog("option", "title", "CREDENCIALES DOCENTES");                                
                }
            }
        } 
        </script>
</head>
<body>
<p align="center"><font color="navy"><b>BIENVENIDO(A):</b></font>
'); 
htp.p('
<font color="red">
'); 
htp.p('
'||v_nombre_usuario||' '||V_CARGO||' '||V_NOMFAC||'
'); 
htp.p('
</font><font  color="navy"><b><BR>Esta es su consulta No: </b></font>
'); 
htp.p('
<font  color="red">
'); 
htp.p('
'||vconsultas||'
'); 
htp.p(' 
</font></p>

<form name="forma1" method="post" action="LS_validar_FACULTAD_V2">
<p align="center">
<input type=hidden name=p_usuario value='||p_usuario||'>
<input type=hidden name=p_clave   value='||p_clave||'>
<input type=hidden name=p_boton   value="ACEPTAR">

<table border="0" cellpadding="2">
<tr>
<td width="133" height="4" bgcolor="navy"><p><font color="white"><b>CODIGO ESTUDIANTIL:</b></font></td>
<td width="80" height="4"><p align="center"><input type="text" name="p_codigo" maxlength="8" size="9" class="navegador"></td>
</tr>
</table>

<font color="navy"><b>Consulta por estudiante</b></font>
<table border="0" cellpadding="2" align="center">
<tr>
<td width="112" height="4" bgcolor="navy"><p align="left"><font >&nbsp;</font><font color="white"><b>Consulta General</b></font></td>
<td width="16" height="4"><p align="left"><font size="2"><input type="radio" name="p_opcion" value="consulta"></font></td>
');
/*
--ELIMNADA EL 20APR2016 A DE ACUERDO CON CORREO DE DORIS EL miércoles, 20 de abril de 2016 2:27 p. m.
<td width="160" height="4" bgcolor="navy"><p align="left"><font >&nbsp;</font><font color="white"><b>Paz y Salvo de Egresado</b></font></td>
<td width="16" height="4"><p align="left"><font ><input type="radio" name="p_opcion" value="pysegresado"></font></td>
*/
HTP.P('
<!--<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Consultar Prematricula</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="consulta_prematricula"></font></td>-->
</tr>
');


/*IF V_BANDERA=0 THEN
HTP.P('
<tr>
<td width="160" height="4" bgcolor="navy"><p align="left"><font color="white"><b>Captura Prematricula</b></font></td>
<td width="16" height="4"><p align="left"><font>.</font></td>
');

HTP.P('
<td width="160" height="4" bgcolor="navy"><p><font color="white"><b>Modificar Prematricula</b></font></td>
<td width="16" height="4"><p><font>.</font></td>
');


ELSE*/

/*HTP.P('
<tr>
<td width="160" height="4" bgcolor="navy"><p align="left"><font color="white"><b>Captura Prematricula</b></font></td>
<td width="16" height="4"><p align="left"><font>-</font></td>
');
HTP.P('
<td width="160" height="4" bgcolor="navy"><p><font color="white"><b>Modificar Prematricula</b></font></td>
<td width="16" height="4"><p><font>-</font></td>
');
*/
--activado el 04dec2014
/*
HTP.P('
<tr>
<td width="160" height="4" bgcolor="navy"><p align="left"><font color="white"><b>Registrar/Consultar Prematricula</b></font></td>
<td width="16" height="4"><p align="left"><font><input type="radio" name="p_opcion" value="prematricula"></font></td>
');*/
/*HTP.P('
<td width="160" height="4" bgcolor="navy"><p><font color="white"><b>Modificar Prematricula</b></font></td>
<td width="16" height="4"><p><font><input type="radio" name="p_opcion" value="modificar_prematricula"></font></td>
');*/

/*END IF;
*/
HTP.P('
<td width="160" height="9" bgcolor="navy"><p><font color="white"><b>Notas Ciclo Actual</b></font></td>
<td width="27" height="9"><p><font><input type="radio" name="p_opcion" value="notas_prometeo"></font></td>
');


HTP.P('
<div align="center">
<tr>
<td width="619" height="4" bgcolor="navy" colspan="5"><p><font>&nbsp;</font><font color="white"><b>Reintegros extemporaneos</b></font></td>
<td width="27" height="9"><p><font size="2"><input type="radio" name="p_opcion" value="reintegros_extemporaneos"></font></td>
</tr>
<TR>
  <td height="8" bgcolor="navy" colspan="5"><p><font size="2"><font color="white"><b>Credenciales Docentes</b></font></font></td>
    <td width="29" height="8"><p><font size="2" color="red"><input type="radio" name="p_opcion" value="credenciales_docentes" ></font></td>
</TR>
</table>
<BR>
');
/*
HTP.P('
<div align="center">
<tr>
<td width="619" height="4" bgcolor="navy" colspan="5"><p><font>&nbsp;</font><font color="white"><b>Reintegros extemporaneos</b></font></td>
<td width="27" height="9"><p><font size="2">.</font></td>
</tr>
</table>
<BR>
');
*/

HTP.P('
<font color="navy"><b>Simulacion para Cambio de Plan de Estudios</b></font>
<table border="0" cellpadding="2" align="center">
');
--HTP.P('
--<tr>
--<td width="619" height="4" bgcolor="navy" colspan="5"><p><font color="white"><b>Estudiantes de Reintegro Articulo 10.</b></font></td>
--<td width="27" height="9"><p><font><input type="radio" name="p_opcion" value="simulacion_ri"></font></td>
--</tr>
--</table>
--<BR>
--');

HTP.P('
<tr>
<td width="619" height="4" bgcolor="navy" colspan="5"><p><font color="white"><b>Estudiantes de Reintegro Articulo 10.</b></font></td>
<td width="27" height="9"><p><font>.</font></td>
</tr>
</table>
<BR>
');




htp.p('
<table>
<tr>
<td colspan="6">
<p align="center">
<font color="navy"><b>Procesos ciclo actual</b></font>
</p>
</td>
</tr>
');
select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
into   v_fechaini_horarios,v_fechafin_horarios
from   a_fechas_de_corte fc
where  SUBSTR(fc.proceso,1,25)='CAPTURA HORARIOS-PREGRADO';

HTP.P('
<tr>
<td width="160" height="4" bgcolor="gray"><p><font  color="white"><b>Carga académica de la facultad ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="cacicloactual"></font></td>
');



select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
into   v_fechaini_plantilla,v_fechafin_plantilla
from   a_fechas_de_corte fc
where  SUBSTR(fc.proceso,1,19)='PLANTILLA ACADEMICA';


--IF to_char(sysdate,'RRRRMMDD') between  v_fechaini_horarios and v_fechafin_horarios THEN
HTP.P('
<td width="160" height="4" bgcolor="red"><p><font  color="white"><b>Carga académica de la facultad próximo ciclo</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="crear_horario"></font></td>
');

HTP.P('
<td width="160" height="4"><p><font  color="red"><b>Carga académica de la facultad próximo ciclo (yopal)</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="yop_crear_horario"></font></td>
');
--ELSE
--HTP.P('
--<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Carga académica de la facultad próximo ciclo</b></font></td>
--<td width="16" height="4"><p><font size="2">.</font></td>
--');
--END IF;

--IF to_char(sysdate,'RRRRMMDD') between  v_fechaini_horarios and v_fechafin_horarios THEN
htp.p('
</tr>
');
htp.p('
<td width="160" height="4" bgcolor="red"><p><font  color="white"><b>Asignar gestión académica próximo ciclo</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gestion_academica"></font></td>
');

htp.p('
<td width="160" height="4"><p><font  color="red"><b>Asignar gestión académica próximo ciclo (YOPAL)</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gestion_academica_yopal"></font></td>
');
--ELSE
--htp.p('
--<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Asignar Gestión Académica y novedades próximo ciclo</b></font></td>
--<td width="16" height="4"><p><font size="2">.</font></td>
--');
--END IF;
htp.p('
</tr>
');

htp.p('
<td width="160" height="4" bgcolor="RED"><p><font  color="white"><b>Asignar Extensión próximo ciclo</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="extension_academica"></font></td>
');

htp.p('
</tr>
');


htp.p('
<td width="160" height="4"><p><font  color="red"><b>Asignar Extensión próximo ciclo (YOPAL)</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="yop_extension_academica"></font></td>
');

htp.p('
<td width="160" height="4" bgcolor="gray"><p><font  color="white"><b>Asignar Extensión ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="extensioncactual"></font></td>
');


htp.p('
</tr>

<td width="160" height="4" bgcolor="gray"><p><font  color="white"><b>Asignar gestión académica ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gacicloactual"></font></td>
');

--if p_fac in('DCA') then
--htp.p('
--<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Asignar Gestión Académica\Investigación (YOPAL)</b></font></td>
--<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gestiaca_inv"></font></td>
--');
--end if;

htp.p('
<tr>
<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Crear materias</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="creamater"></font></td>
');
HTP.P('
<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Syllabus histórico</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="syllabush"></font></td>
');

IF SUBSTR(p_fac,2,2) IN('AC','CE','ES') then
htp.p('
<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Cambios de jornada</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="cambiojor"></font></td>
</tr>
');
END IF;


-----PROFESORES DE SERVICIOS 4 DE NOVIEMBRE DE 2010
HTP.P('
<TR>
<td width="160" height="4" bgcolor="green"><p><font  color="white"><b>Asignar profesores a otras Unidades de pregrado</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="profes_servicios"></font></td>
<td width="160" height="4" bgcolor="green"><p><font  color="white"><b>Asignar profesores a Unidades de postgrado</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="profes_servicios_pos"></font></td>
<td width="160" height="4" bgcolor="green"><p><font  color="white"><b>Asignar profesores a Unidades de postgrado ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="profes_servicios_posca"></font></td>
</TR>
');
--10NOV2015
HTP.P('
<TR>
<td width="160" height="4" bgcolor="green"><p><font  color="white"><b>Asignar profesores a otras Unidades de pregrado ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="profes_servicios_ca"></font></td>
</TR>
');
----------------------------------------------------



/*--iF to_char(sysdate,'YYYYMMDD') BETWEEN V_FECHAINI_CURVAC AND V_FECHAFIN_CURVAC THEN
HTP.P('
<TR>
<table border="0" cellpadding="2">
<TR>
<TD COLSPAN="6">
<p align="center"><font color="navy"><b>CAPTURA HORARIOS CURSOS INTERSEMESTRALES</b></font>
</TD>
<tr>
<td width="112" height="5" bgcolor="navy"><p><font color="white"><b>Crear horario para un grupo</b></font></td>
<td width="16" height="5"><p><font><input type="radio" name="p_opcion" value="crear_horariocv"></font></td>

<td width="160" height="5" bgcolor="navy"><p><font color="white"><b>Eliminar horario de un grupo</b></font></td>
<td width="16" height="5"><p><font><input type="radio" name="p_opcion" value="eliminar_horariocv"></font></td>

<td width="160" height="5" bgcolor="navy"><p><font color="white"><b>Consultar cursos</b></font></td>
<td width="16" height="5"><p><font><input type="radio" name="p_opcion" value="consultacv"></font></td>
</tr>
<tr>
</table>
<TR>
');
--END IF;*/








IF p_usuario IN('NSMQ','PWDU') THEN
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">CONSULTA POR PROGRAMA</p>
<p align="center"><font"><select name="FACULTAD">
<option selected value="80">------- Seleccione un programa ----------</option>
<option value="23">LIC. LENGUAS MODERNAS</option>
<option value="24">LIC. CIENCIAS RELIGIOSAS</option>
<option value="26">LIC. LENGUA CASTELLANA</option>
<option value="27">LIC. EDUCACION RELIGIOSA</option>
<option value="28">LIC. CIENCIAS NATURALES</option>
<option value="29">LIC. EN MATEMATICAS  </option>
</table>
');
END IF;
IF p_usuario='RAKM' THEN
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">CONSULTA POR PROGRAMA</p>
<p align="center"><font><select name="FACULTAD">
<option selected value="80">------- Seleccione un programa ----------</option>
<option value="24">LIC. CIENCIAS RELIGIOSAS</option>
<option value="27">LIC. EDUCACION RELIGIOSA</option>
<option value="31">LICENCIATURA EN FILOSOFIA Y LETRAS ANT.</option>
<option value="34">LIC.EN FILOSOFIA Y LETRAS-DIURNA   NVA.</option>
</table>
');
END IF;

IF p_usuario IN ('CGVW','CCRJ','WWWW') THEN
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">CONSULTA POR PROGRAMA</p>
<p align="center"><font><select name="FACULTAD">
<option selected value="80">------- Seleccione un programa ----------</option>
<option value="30">FILOSOFIA Y LETRAS.</option>
<option value="31">LICENCIATURA EN FILOSOFIA Y LETRAS ANT.</option>
<option value="34">LIC.EN FILOSOFIA Y LETRAS-DIURNA   NVA.</option>
</table>
');
END IF;

/*-------FACULTADES
IF P_FAC IN('DIN') THEN
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">CONSULTA POR PROGRAMA</p>
<p align="center"><font size="1"><select name="FACULTAD">
<option selected value="80">------- Seleccione un programa ----------</option>
<option value="40">ING. CIVIL</option>
<option value="41">ING. AMBIENTAL</option>
<option value="44">ING. DE DISEÑO Y AUTOMATIZACION</option>
<option value="42">ING. ELECTRICA</option>
<option value="43">ING. ALIMENTOS</option>

</table>
');
END IF;
-------*/
/*
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">PROGRAMAS PREGRADO</p>
<p align="center"><font size="1"><select name="FACULTAD">
<option selected value="80">------- Seleccione un programa ----------</option>
');
for v_datos in facultades loop
htp.p('
<option value="d'||v_datos.codigo||'">'||v_datos.nombre||'</option>
');
end loop;
htp.p('
</table>
');*/



htp.p('

<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Grupos sin nota</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="matricxmgr"></font></td>

');
IF TO_CHAR(SYSDATE,'RRRRMMDD')>'20140311' THEN
htp.p('
<td bgcolor="#C2E8C7" width="160" height="4" bgcolor="navy"><p><font  color="navy"><b>Resultados votaciones</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="resultvot"></font></td>
');
ELSE
htp.p('
<td bgcolor="#C2E8C7" width="160" height="4" bgcolor="navy"><p><font  color="navy"><b>Resultados votaciones</b></font></td>
<td width="16" height="4"><p>.</td>
');
END IF;

if p_fac in('DCA') then
htp.p('
<TR>
<td width="160" height="4" bgcolor="navy"><p><font  color="white"><b>Asignar Gestión Académica\Investigación (YOPAL) proximo ciclo</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gestiacainv_proxiclo"></font></td>
');
end if;

if p_fac in('DCA') then
htp.p('

<td width="160" height="4" bgcolor="gray"><p><font  color="white"><b>Asignar Gestión Académica\Investigación (YOPAL) ciclo actual</b></font></td>
<td width="16" height="4"><p><font size="2"><input type="radio" name="p_opcion" value="gestiacainv_cactual"></font></td>
<tr>
');
end if;


HTP.P('
<table align="center"> 
<td>
<p align="center"><input type="radio" name="p_opcion" value="cfacultad" class="navegador">PROGRAMAS DE PREGRADO</p>
<p align="center"><select name="FACULTAD"  class="navegador">
<option selected value="80">------- Seleccione un programa ----------</option>
');
for v_datos in facultades loop
htp.p('
<option value="d'||v_datos.codigo||'">'||v_datos.nombre||'</option>
');
end loop;
htp.p('
</td>
</table>
');
HTP.P('
<!--<p align="center"><input type="submit" name="p_boton" value="Enviar Datos Pregrado" class="navegador"></p>-->
<p align="center"><input type="button" name="p_boton" value="Enviar Datos Pregrado" id="btn_enviar" onclick="enviarForma1();" class="navegador"></p>
');


HTP.P('
<p align="center"><input type="radio" name="p_opcion" value="postgrado">PROGRAMAS DE POSTGRADO</p>
');
HTP.P('
<!--<p align="center"><input type="submit" name="p_boton" value="Enviar Datos Postgrado" class="navegador"></p>-->
<p align="center"><input type="button" name="p_boton" value="Enviar Datos Postgrado" id="btn_enviar" onclick="enviarForma1();" class="navegador"></p>

<div id="datos" title="" style="display:none;">
     <iframe src="" id="prem_nuevos" frameborder="0" style="height: 100%; width: 100%; border: none;" />                       
    </div>


</form>

');




HTP.P('
<SCRIPT>
function abrir()
{
alert("APRECIADO DECANO/DIRECTOR/SECRETARIO ACADEMICO:\nLAS OPCIONES DE MODIFICACION DE PREMATRICULA Y HORARIOS SERAN SUSPENDIDAS A PARTIR DE LAS 8:00 A.M. DEL DIA 18 DE SEPTIEMBRE, DEBIDO A QUE EL REGISTRO DE PRIMERA NOTA INICIA EL DIA 22 DE SEPTIEMBRE.");

}
</SCRIPT>
');


HTP.P('
<SCRIPT>
function abrir()
{
var aviso="DEBIDO A QUE EL PROCESO DE CAPTURA DE NOTAS INICIA EL DIA 21-SEP-2009 LAS OPCIONES DE CAPTURA Y MODIFICACION DE PREMATRICULA SE DESHABILITARAN EL DIA 18-SEP-2009.";
alert(aviso,"IMPORTANTE");
}
</SCRIPT>

</body>
</html>
'

);

END LS_MENU_FACULTADES;
/*
<body onLoad="abrir()" background="/images/arena.gif" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
--<body onLoad="abrir()" background="/images/arena.gif" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<tr>
            <td width="145" height="9" bgcolor="navy"><p align="left"><font size="2" color="white"><b>Simulación cambio de plan</b></font></td>
            <td width="21" height="9"><p><font size="2" color="red"><input type="radio" name="p_opcion" value="homologaciones"></font></td>
</tr>
*/
