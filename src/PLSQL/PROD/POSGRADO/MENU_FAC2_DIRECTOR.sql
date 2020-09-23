create or replace Procedure MENU_Fac2_DIRECTOR
(p_usuario varchar2,p_clave varchar2,p_codigo varchar2 ,v_tipo varchar2)
IS
v_fecha_bloqueo_ini   varchar2(08) default NULL;
v_fecha_bloqueo_fin   varchar2(08) default NULL;
v_bloqueo             varchar2(02) := 'NO';
v_nombre_usuario      admisiones.a_usuarios.nombre_usuario%type default null;
v_ciclo_char      varchar2(50) default null;
v_perfil admisiones.a_usuarios.codigo%type default null;
v_nombre_programa a_facultades.nombre%type default null;
v_fechaini_horarios varchar2(8) default null;   
v_fechafin_horarios varchar2(8) default null;
CURSOR FACULTADES IS
select unique fu.codigo_facultad codigo,fu.nombre 
from   admisiones.a_programas p,a_facultades_unica fu
where  p.codigo=fu.codigo_facultad
and    p.facultad=SUBSTR(v_perfil,2,2)
AND    P.CODIGO>='72'
order   by 2;
Begin
--htp.p('menu_fac2_director');
/*
Htp.P('.........123');
htp.p(p_usuario);
htp.p(p_clave);
Htp.P(P_Codigo);
htp.p(v_tipo);*/

--HTP.P('MENU_FAC2_DIRECTOR'||V_TIPO);
select u.nombre_usuario,u.codigo
into   v_nombre_usuario,v_perfil
from   admisiones.a_usuarios u
where  u.usuario=p_usuario
and    u.clave=p_clave;



/*select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
into   v_fecha_bloqueo_ini,v_fecha_bloqueo_fin
from   a_fechas_de_corte fc
where  fc.proceso like('%BLOQUEAR POSTGRADO POR IMPRESION DE GUIAS%');
if to_char(sysdate,'YYYYMMDD') not between v_fecha_bloqueo_ini and v_fecha_bloqueo_fin then
   V_BLOQUEO:='SI';
END IF;*/

/*htp.p('
<html>
<body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
<a href="http://www.lasalle.edu.co" "onmouseover = "status= ''.''; return true" onmouseout="status = ''.''"><font color=red>CERRAR SESION</font></A>
<BR>
');*/
htp.p('
<html>
<head>
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
          
        
             if($("input[name=p_opcion]:radio:checked").val() == "credenciales_docentes"){
       
              var url = "http://registro.lasalle.edu.co/pls/regadm/pg_cred_doc2?P_CODIGO='||p_codigo||'";
              $("#prem_nuevos").attr("src", url);
              $("#datos").dialog("open");  
              $("#datos").dialog("option", "title", "CREDENCIALES DOCENTES");
      
             
             }
            
            if($("input[name=p_opcion]:radio:checked").val() != "credenciales_docentes"){
       
              $("form[name=forma1]").submit();
      
             
             }
            
             
            }
            
           
            
            
        </script>
</head>
<body>
');

IF SUBSTR(v_perfil,1,1) IN('D','S') THEN
HTP.P('
<a href="http://registro.lasalle.edu.co/pls/regadm/LS_MENU_FACULTADES?p_usuario='||p_usuario||'&p_clave='||p_clave||'&p_fac='||v_perfil||'">PREGRADO</a>
');
END IF;

HTP.P('
<center>
<table>
<img src="/images/LOGOSALLE.gif" border="0">
</table>
</center>
<p align="center">
');
IF V_TIPO!='9' THEN
HTP.P('
<b>BIENVENIDO(A):'||v_nombre_usuario||'</b>
');
end if;
if v_tipo='9' then
select p.nombre
into   v_nombre_programa
from   admisiones.a_programas p
where  p.codigo=p_codigo;
HTP.P('
<b>PROGRAMA:'||v_nombre_programa||'</b>
');
END IF;



HTP.P('
<link href="/images/interna.css" rel="stylesheet" type="text/css">

<center>
<table align="center" border="0" width="50%">
<form name="forma1" method="post" action="validar_f2">
<input type=hidden name=p_usuario value='||p_usuario||'>
<input type=hidden name=p_clave   value='||p_clave  ||'>
<input type=hidden name=p_codigo  value='||p_codigo ||'>
<input type=hidden name=p_tipo    value='||v_tipo ||'>

');
IF V_TIPO NOT IN('3') THEN
HTP.P('
    <tr>
        <td colspan="3" bgcolor="#4791C5">
            <p align="center"><font color="white">CODIGO ESTUDIANTIL</font></p>
        </td>
        <td colspan="3" bgcolor="#4791C5">
                <p align="center"><input type="text" name="p_codest" maxlength="9" size="9"  class="navegador"></p>
        </td>
    </tr>
    <tr>
        <td bgcolor="#EFEFF7">
            <p>Consulta de Notas</p>
        </td>
        <td bgcolor="#EFEFF7">
                <p><input type="radio" name="p_opcion" value="consulta_general" checked></p>
        </td>
        <td bgcolor="#EFEFF7">
            <p>Estudio Academico</p>
        </td>
        <td bgcolor="#EFEFF7">
                <p><input type="radio" name="p_opcion" value="estudio_academico"></p>
        </td>
    </tr>
    <!--
    <tr>
    <td  bgcolor="#EFEFF7"><p>Consultar usuario y clave</font>
    <td>
    <input type="radio" name="p_opcion" value="consultar_uc">
    </td>
    </tr>
    -->

     <tr>
    <td  bgcolor="#EFEFF7"><p>Credenciales Docentes y/o Estudiantes</font>
    <td>
    <input type="radio" name="p_opcion" value="credenciales_docentes">
    
    </td>
     <td bgcolor="#EFEFF7">
                <p>Imprimir Guía de Pago</p>
            </td>
            <td bgcolor="#EFEFF7">
                   <p><input type="radio" name="p_opcion" value="guia_de_pago"></p>
            </td>
    </tr>
    
    ');
htp.p('
    <tr>
    <td colspan="6">
    <p align="center">ESTADISTICAS GENERALES DE LA UNIVERSIDAD
    </p>
    </td>
    </tr>
        <tr>
            <td bgcolor="#EFEFF7">
                <p>Matricula por tipo de Est</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="matricula_xtipo"></p>
            </td>
            <td bgcolor="#EFEFF7">
                <p>Matriculados por genero</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="genero"></p>
            </td>
        </tr>
    </tr>

    </tr>
    ');
            
            
            /*
            --BLOQUEADO EL 27FEB2018
            --DE ACUERDO CON COMUNICACION SR29067
            <td bgcolor="#EFEFF7">
                <p>Matricula por semestre</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="matriculaxsemestre"></p>
            </td>
            */
            HTP.P('
            <tr bgcolor="#EFEFF7">
            <td>Matriculados por semestre</td>
            <td><p>.</p></td>
            </tr>
            ');
--13NOV2012        
/*        HTP.P('
            <td bgcolor="#EFEFF7">
                <p>Crear materias1234</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="crearmat"></p>
            </td>
        </TR>    
        ');    
*/            

    HTP.P('
        <tr>
            <td bgcolor="#EFEFF7">
                <p>Proceso de admisión</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="admisiones"></p>
            </td>


    
</table>
</center>

');
END IF;   



IF SUBSTR(v_perfil,1,1) NOT IN('D','S') OR V_PERFIL IN('122','125','126') THEN

   htp.p('
    <p align="center"><font size="3" color="navy"><b>LISTADOS</b></font> 
    <table align="center" border="0" width="50%">
    <tr>
    <td colspan="6">
    </p>
    </td>
    </tr>
        <tr>
            <td bgcolor="#EFEFF7">
                <p>Planes de estudio</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="planes"></p>
            </td>
             <td bgcolor="#EFEFF7">
                <p>Egresados no Graduados</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="egresado"></p>
            </td>
        </tr>
    </tr>
    <td colspan="6">
    </p>
    </td>
    </tr>
        <tr>
            <td bgcolor="#EFEFF7">
                <p>Consulta por apellidos</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="apellidos"></p>
            </td>
        </tr>



        <tr>
            <td bgcolor="#EFEFF7">
                <p>Syllabus historico</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="syllabush"></p>
            </td>
            ');
        --bloqueado el 20feb2017 de acuerdo con caso: SR12695
        --</tr>
        -- <tr>
        --  <td>Graduados</td>
        --  <td><input type="radio" name="p_opcion" value="graduado"></td>
        --  <!--<td>Información graduados</td>
        --  <td><input type="radio" name="p_opcion" value="consulta_egresado"></td> --> 
        --</tr>


/*    <tr>
    <td  bgcolor="#EFEFF7"><p>Consultar usuario y clave estudiantes nuevos</font>
    <td>
    <input type="radio" name="p_opcion" value="consultar_uc">
    </td>*/

    htp.p('
   
    </table>
    ');



   htp.p('
   
    <p align="center"><font size="3" color="navy"><b>PROCESOS DEL PERIODO</b></font> 
    <table align="center" border="0" width="50%">

   ');


 
select to_char(fc.fecha_inicio,'YYYYMMDD'),to_char(fc.fecha_finalizacion,'YYYYMMDD')
into   v_fechaini_horarios,v_fechafin_horarios
from   a_fechas_de_corte fc
where  SUBSTR(fc.proceso,1,26)='CAPTURA HORARIOS-POSTGRADO';
--IF to_char(sysdate,'RRRRMMDD') between  v_fechaini_horarios and v_fechafin_horarios THEN   
    HTP.P('
    <td height="5" bgcolor="navy"><p><font color="white">Carga académica próximo ciclo</font></td>
    <td height="5"><p><font><input type="radio" name="p_opcion" value="crear_horario"></td>
    ');
    --ELSE
    --HTP.P('
    --<td height="5" bgcolor="navy"><p><font color="white">Carga académica próximo ciclo</font></td>
    --<td height="5"><p>.</td>
    --');
--END IF;
/*    HTP.P('
    <td height="5" bgcolor="navy"><p><font color="white">Carga académica próximo ciclo</font></td>
    <td height="5"><p><font>.</td>
    ');
    */
    HTP.P('
    <td height="5" bgcolor="gray"><p>Carga académica ciclo actual</td>
    <td height="5"><p><font><input type="radio" name="p_opcion" value="cacicloactual"></td>
    ');
    
   --22FEB2013
    /*SELECT DISTINCT(DECODE(BP.CICLO,'01','I','02','II'))||' Período de '||BP.ANIO
    INTO   v_ciclo_char
    FROM B_PREMATRICULA_NOTAS_DEPURADA BP
    WHERE  BP.ANIO||BP.CICLO IN(
    SELECT MAX(BP.ANIO||BP.CICLO)
    FROM   B_PREMATRICULA_NOTAS_DEPURADA
    );
*/
    HTP.P('
    <tr>
    <td bgcolor="#EFEFF7">
    <p>Notas '||v_ciclo_char||'</p>
   
    </td>
    
    <td bgcolor="#EFEFF7">
    <p><input type="radio" name="p_opcion" value="matricxmgr"></p>
    </td>
    ');

    --bloqueado el 20feb2017 de acuerdo con caso: SR12695
    --HTP.P('
    --<td height="5" bgcolor="#EFEFF7"><p>Consultar interesados</font></td>
    --<td height="5"><p><input type="radio" name="p_opcion" value="consulta_interesados"></td>

    HTP.P('
    </tr>
    <hr>
    <td  bgcolor="#EFEFF7"><p>Aspirantes Inscritos por Internet</font>
    <td>
    <input type="radio" name="p_opcion" value="consulta_internet">
    </td>
    ');
    
    
    IF TO_CHAR(SYSDATE,'RRRRMMDD')>'20140311' THEN
    HTP.P('
    <td  bgcolor="#EFEFF7"><p>Resultados elecciones</font>
    <td>
    <input type="radio" name="p_opcion" value="elecciones">
    </td>
    ');
    ELSE
    HTP.P('
    <td  bgcolor="#EFEFF7"><p>Resultados elecciones</font>
    <td>
    .
    </td>
    ');
    END IF;
    --htp.p('
    --<td  bgcolor="#EFEFF7"><p>Resultados elecciones</font>
    --<td>
    --.
    --</td>
    --');

    --bloqueado el 20feb2017 de acuerdo con caso: SR12695
    --htp.p('
    --<tr>
    --<td  bgcolor="#0099FF"><p><font color="white">Listado contactos</font>
    --<td>
    --<input type="radio" name="p_opcion" value="contactos">
    --</td>
    --');
    if p_usuario in('ZR73') THEN
    htp.p('
    <td  bgcolor="#EFEFF7"><p><font>Homologar creditos a redimensión</font>
    <td>
    <input type="radio" name="p_opcion" value="mp4p5">
    </td>
    ');
    end if;
    
    
    
    
    htp.p('
    </tr>
    <tr>
    <td  bgcolor="#EFEFF7"><p>Registrar solicitudes de reintegro</font>
    <td>
    <input type="radio" name="p_opcion" value="reintegros_extemporaneos">
    </td>
    <td  bgcolor="#EFEFF7"><p>Listado de reintegro</font>
    <td>
    <input type="radio" name="p_opcion" value="lreintegros">
    </td>
    </hr>
    ');
        HTP.P('
        <TR>
            <td bgcolor="#EFEFF7">
                <p>Crear materias</p>
            </td>
            <td bgcolor="#EFEFF7">
                    <p><input type="radio" name="p_opcion" value="crearmat"></p>
            </td>
        </TR> 
        
        ');    
  
    


end if;

IF SUBSTR(v_perfil,1,1) IN('D','S') THEN
HTP.P('
<table align="center"> 
<p align="center"><input type="radio" name="p_opcion" value="cfacultad">CONSULTA POR PROGRAMA</p>
<p align="center"><font size="1"><select name="p_facultad">
<option selected value="80">------- Seleccione un programa ----------</option>
');
for v_datos in facultades loop
htp.p('
<option value="d'||v_datos.codigo||'">'||v_datos.nombre||'</option>
');
end loop;
htp.p('
</table>

');
END IF;



HTP.P('
<tr>
<td colspan="6">
<br>
<p align="center"><input type="button" name="p_boton" value="Enviar datos" class="navegador" onclick="enviarForma1();"></p>
</td>
</tr>
');



htp.p('
 <div id="datos" title="" style="display:none;">
     <iframe src="" id="prem_nuevos" frameborder="0" style="height: 100%; width: 100%; border: none;" />                       
    </div>
<p>
</p>

</html>
');
HTP.P('
<center>
<table>
</table>
</center>
');

htp.p('
</form>
<p>
</p>

</html>
');

htp.p('
<script language="JavaScript">
function validar()
{

');
for i in 1..3
loop
htp.p('
v_ingreso=false;
for (j=0;j<2;j++){
if (document.forma1.p_opcion[j].checked)
v_ingreso=true;
}
if (!v_ingreso){
alert("Seleccione una opcion");
return false;
}
');
end loop;
htp.p('
document.forma1.submit();
}
</script>  
');




IF P_CODIGO IN('76','77','78','87','90') AND P_USUARIO IN('APBS') THEN
htp.p('
<html>
<head>
<link href="/images/interna.css" rel="stylesheet" type="text/css">
</head>
<center>
<p align="center"><input type="button" class="navegador" value="<---REGRESAR" onclick=enviar()></td>
</center>
<form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/MENU_FAC2_DECANO_PRUEBAS" method="post">
<input type=hidden name=p_usuario value='||p_usuario||'>
<input type=hidden name=p_clave   value='||P_clave||'>
<input type=hidden name=p_codigo  value='||P_codigo||'>
<input type=hidden name=v_tipo    value='||v_tipo||'>
<SCRIPT>
function enviar()
{
document.ensayo.submit();
}
</SCRIPT>
</form>
</html>
'); 

END IF;


IF P_CODIGO IN('76','77','78','87','90') AND P_USUARIO IN('APBS') THEN
htp.p('
<html>
<head>
<link href="/images/interna.css" rel="stylesheet" type="text/css">
</head>
<center>
<p align="center"><input type="button" class="navegador" value="<---REGRESAR" onclick=enviar()></td>
</center>
<form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/MENU_FAC2_DECANO_PRUEBAS" method="post">
<input type=hidden name=p_usuario value='||p_usuario||'>
<input type=hidden name=p_clave   value='||P_clave||'>
<input type=hidden name=p_codigo  value='||P_codigo||'>
<input type=hidden name=v_tipo    value='||v_tipo||'>
<SCRIPT>
function enviar()
{
document.ensayo.submit();
}
</SCRIPT>
</form>
</html>
'); 
END IF;

IF P_CODIGO IN('81','83') AND P_USUARIO IN('KQMD','RRKI','BQZR','DHJJ') THEN
htp.p('
<html>
<head>
<link href="/images/interna.css" rel="stylesheet" type="text/css">
</head>
<center>
<p align="center"><input type="button" class="navegador" value="<---REGRESAR" onclick=enviar()></td>
</center>
<form name="ensayo" action="http://registro.lasalle.edu.co/pls/postgrado/MENU_FAC2_DECANO_PRUEBAS" method="post">
<input type=hidden name=p_usuario value='||p_usuario||'>
<input type=hidden name=p_clave   value='||P_clave||'>
<input type=hidden name=p_codigo  value='||P_codigo||'>
<input type=hidden name=v_tipo    value='||v_tipo||'>
<SCRIPT>
function enviar()
{
document.ensayo.submit();
}
</SCRIPT>
</form>
</body>
</html>
'); 
END IF;


END MENU_Fac2_DIRECTOR;
