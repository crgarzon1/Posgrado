set define off;

create or replace Procedure PINTAR_ESTADISTICA_NOTAS
(p_codigo varchar2 default null
)
Is
v_profesor varchar2(1000) default null;
v_apellidos ah_horizontal_actual.apedoc%type default null;
v_nombres   ah_horizontal_actual.nombre%type default null;
v_nombre_materia a_materias.nombre%type default null;
v_codigo_facultad varchar2(2) default p_codigo;
v_total_matriculados     number       default 0;
v_aprobaron1pt           number       default 0;
v_reprobaron1pt          number       default 0;
v_por_aprobaron1pt       number       default 0;
v_por_reprobaron1pt      number       default 0;
v_aprobaron1pp           number       default 0;
v_reprobaron1pp          number       default 0;
v_por_aprobaron1pp       number       default 0;
v_por_reprobaron1pp      number       default 0;
v_aprobaron2pt           number       default 0;
v_reprobaron2pt          number       default 0;
v_por_aprobaron2pt       number       default 0;
v_por_reprobaron2pt      number       default 0;
v_aprobaron2pp           number       default 0;
v_reprobaron2pp          number       default 0;
v_por_aprobaron2pp       number       default 0;
v_por_reprobaron2pp      number       default 0;
v_aprobaronexft           number       default 0;
v_reprobaronexft          number       default 0;
v_por_aprobaronexft       number       default 0;
v_por_reprobaronexft      number       default 0;
v_aprobaronexfp           number       default 0;
v_reprobaronexfp          number       default 0;
v_por_aprobaronexfp       number       default 0;
v_por_reprobaronexfp      number       default 0;

v_estado_captura number default 0;
v_nota_minaprobatoria number default 0;
v_por_practica        number default 0;

v_facultad        b_prematricula_notas_depurada.facultad%type default null;
v_codigo_materia  b_prematricula_notas_depurada.materia_plan%type default null;
v_grupo_materia   b_prematricula_notas_depurada.grupo%type default null;
V_MATRICULADOS    NUMBER DEFAULT 0;

CURSOR C_PROFESORES IS
SELECT DISTINCT(HA.APEDOC||HA.NOMBRE) NOMPRO,HA.APEDOC,HA.NOMBRE
FROM   AH_HORIZONTAL_ACTUAL  HA
--FROM   cactualpos.a_horario_horizontal  ha
where  ha.codigo_facultad in(v_codigo_facultad)
AND    ha.MATRICULADOS>0
AND    ha.numero_documento not in('0','99')

ORDER  BY ha.APEDOC||ha.NOMBRE;

Cursor C_Horario Is
SELECT *
FROM   AH_HORIZONTAL_ACTUAL  HA
--FROM   cactualpos.a_horario_horizontal  ha
where  ha.APEDOC=v_apellidos 
and    ha.NOMBRE=v_nombres
and    ha.codigo_facultad in(v_codigo_facultad,'02')
AND    ha.MATRICULADOS>0
AND    ha.numero_documento not in('0','99')

ORDER  BY ha.CODIGO_FACULTAD,ha.CODIGO_MATERIA,ha.GRUPO_MATERIA;
v_n1 number default 0;
v_n2 number default 0;
v_n3 number default 0;
indicador_n1 varchar2(1) default null;
indicador_n2 varchar2(1) default null;
indicador_n3 varchar2(1) default null;
v_reprobados_primera    number default 0;
v_reprobados_segunda    number default 0;
v_reprobados_examen     number default 0;
v_reprobados_definitiva number default 0;
v_por_aprodef           number default 0;
v_por_reprodef          number default 0;
V_CONTEO NUMBER DEFAULT 0;
PERMAX    VARCHAR2(6);
V_PAGOS  NUMBER DEFAULT 0;
V_ANIO   MATRICULADOS.ANIO%TYPE DEFAULT NULL;
V_CICLO   MATRICULADOS.CICLO%TYPE DEFAULT NULL;
CICLO_REAL VARCHAR2(2) DEFAULT NULL;
TYPE TYP_REF_CUR IS REF CURSOR;     --TIPO REF CURSOR
TYPE typE_PROF IS RECORD
    (
      NOMPRO  VARCHAR2(1000),
      APEDOC  VARCHAR2(1000),
      NOMBRE VARCHAR2(1000)
    );
TYPE typE_horario IS RECORD
    (
CODIGO_FACULTAD VARCHAR2(1000),
JORNADA_FACULTAD VARCHAR2(1000),
CODIGO_MATERIA VARCHAR2(1000),
GRUPO_MATERIA VARCHAR2(1000),
NOMBRE_PROFESOR VARCHAR2(1000),
LUNES VARCHAR2(1000),
MARTES VARCHAR2(1000),
MIERCOLES VARCHAR2(1000),
JUEVES VARCHAR2(1000),
VIERNES VARCHAR2(1000),
SABADO VARCHAR2(1000),
CUPO VARCHAR2(1000),
PROFESOR_PRACTICA VARCHAR2(1000),
TEORIA_INTEGRADA VARCHAR2(1000),
FACINT VARCHAR2(1000),
CODMATINT VARCHAR2(1000),
GRUPINT VARCHAR2(1000),
CUPO_UTILIZADO VARCHAR2(1000),
MATRICULADOS VARCHAR2(1000),
ABIERTO VARCHAR2(1000),
TIPO_MATERIA VARCHAR2(1000),
NUMERO_DOCUMENTO VARCHAR2(1000),
APEDOC VARCHAR2(1000),
NOMBRE VARCHAR2(1000),
POR_TEORIA VARCHAR2(1000),
POR_PRACTICA VARCHAR2(1000),
SEDE VARCHAR2(1000),
ANIO VARCHAR2(1000),
CICLO VARCHAR2(1000),
FECHA_INICIO_CLASES VARCHAR2(1000),
FECHA_INICIO_NOTAS VARCHAR2(1000),
FECHA_FIN_NOTAS VARCHAR2(1000),
SEMANAS VARCHAR2(1000),
PLAN_ESTUDIO VARCHAR2(1000),
NOMBRE_MATERIA VARCHAR2(1000),
INTENSIDAD_HORARIA VARCHAR2(1000),
SEMESTRE VARCHAR2(1000),
CREDITOS VARCHAR2(1000),
ABREVIATURA_NOMBRE VARCHAR2(1000),
AREA VARCHAR2(1000),
HOR_TRABAJO_INDEPENDIENTE VARCHAR2(1000),
PLAN_CARACTER VARCHAR2(1000),
CONSECUTIVO VARCHAR2(1000),
GRAN_FACULTAD VARCHAR2(1000),
FECHA_FIN_CLASES VARCHAR2(1000),
FECHA VARCHAR2(1000),
NUMERO_DOCUMENTO2 VARCHAR2(1000),
INDICADOR_CIERRE VARCHAR2(1000),
APROBARON_DEF VARCHAR2(1000),
REPROBARON_DEF VARCHAR2(1000),
POR_APROBARON_DEF VARCHAR2(1000),
POR_REPROBARON_DEF VARCHAR2(1000),
FECHA_EXAMEN_FINAL VARCHAR2(1000),
FECHA_TERCER_INGRESO VARCHAR2(1000)
);  
V_PROFE TYPE_PROF;
v_datos typE_horario;
V_REF_CUR TYP_REF_CUR;    ---VARIABLE REF CURSOR;
V_REF_CUR2 TYP_REF_CUR;    ---VARIABLE REF CURSOR;

BEGIN
--HTP.P('PINTAR_ESTADISTICA_NOTAS');
--HTP.P(P_CODIGO);
/*SELECT MAX(M.ANIO||M.CICLO)
INTO PERMAX
FROM POSTGRADO.MATRICULADOS M;*/



SELECT MAX(HA.ANIO||HA.CICLO)
INTO PERMAX
FROM AH_HORIZONTAL_ACTUAL HA;



V_ANIO:=SUBSTR(PERMAX,1,4);
V_CICLO:='0'||SUBSTR(PERMAX,6,1);

SELECT DECODE(V_CICLO,'01','I','02','II')
INTO CICLO_REAL
FROM DUAL;

v_codigo_facultad:=p_codigo;

HTP.P('
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
    <link rel="stylesheet" href="http://zeus.lasalle.edu.co/oar/bootstrap/css/bootstrap.min.css">
</head>
<body class="container-fluid">
<P align=center><B>ESTADISTICA DE NOTAS '||CICLO_REAL||' PERIODO DE '||V_ANIO||'</B><BR/>
<B>'||SYSDATE||'</B>
</p>
');
V_REF_CUR := POSTGRADO.PKG_NOTAS.PRC_GET_DOCENTES_CURSOR (v_codigo_facultad); 
LOOP FETCH V_REF_CUR INTO V_PROFE;
EXIT  WHEN  V_REF_CUR%NOTFOUND;
--for v_profe in c_profesores loop
htp.p('
<br>
');
v_apellidos:=v_profe.apedoc;
V_NOMBRES:=V_PROFE.NOMBRE;
htp.p('
<center>
<table  class="table table-bordered table-condensed table-hover" cellspacing="0" style="width:50%">
<thead>
    <tr>
        <th rowspan="3">
            <p align="center">MATERIA</p>
        </th>
        <th rowspan="3">
            <p align="center">GR</p>
        </th>
        <th rowspan="3">
            <p align="center">MAT.</p>
        </th>
        <th colspan="4" rowspan="2">
            <p align="center">DEFINITIVA</p>
        </th>
    </tr>
    <tr>
    </tr>
    <tr>
        <th>
            <p>APR</p>
        </th>
        <th>
            <p>REPR</p>
        </th>
        <th>
            <p>%APR</p>
        </th>
        <th>
            <p>%REPR</p>
        </th>
    </tr>
</thead>
<tbody>
');

V_REF_CUR2 := POSTGRADO.PKG_NOTAS.PRC_GET_HORARIOS_CURSOR(V_CODIGO_FACULTAD, V_APELLIDOS, V_NOMBRES);
LOOP FETCH V_REF_CUR2 INTO V_DATOS;
EXIT  WHEN  V_REF_CUR2%NOTFOUND;
--FOR V_DATOS IN c_horario loop
    v_por_practica:=v_datos.por_practica;
    v_facultad:=v_datos.codigo_facultad;
    v_codigo_materia:=v_datos.codigo_materia;
    v_grupo_materia:=v_datos.grupo_materia;

    SELECT nombre
    into   v_nombre_materia
    from   a_materias m
    where  m.codigo_facultad=v_datos.codigo_facultad and
           m.jornada_facultad=v_datos.jornada_facultad and
           m.codigo=v_datos.codigo_materia;
           
           --AND V_DATOS.PLAN_ESTUDIO=M.PLAN_ESTUDIO;
    htp.p('
    <tr>
    ');
    if v_por_practica>0 then
       htp.p('
       <td>
       <a href="javascript:enviar1('||''''||v_datos.codigo_facultad||''''||','||''''||v_datos.codigo_materia||''''||','||''''||v_datos.grupo_materia||''''||','||''''||p_codigo||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_nombre_materia||'</a>
       </td>
       ');
      else
       htp.p('
       <td>
       <a class="btn btn-outline-secondary active" role="button" href="javascript:enviar2('||''''||v_datos.codigo_facultad||''''||','||''''||v_datos.codigo_materia||''''||','||''''||v_datos.grupo_materia||''''||','||''''||p_codigo||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_codigo_materia || ' ' || v_nombre_materia||'</a>
       </td>
       ');
    end if;
    if v_datos.grupo_materia is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</span></p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">'||v_datos.grupo_materia||'</span></p>
        </td>
    ');
    end if;
    
    
select count(*)
into   v_matriculados
from   b_prematricula_notas_depurada ins
where  ins.facultad_cursar=v_facultad and ins.materia_cursar=v_codigo_materia
and    to_number(ins.grupo)=to_number(v_grupo_materia)
and    ins.indicador_pago in('P','V','C');
    
    
    
    
    if v_datos.matriculados is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center">'||v_matriculados||'</p>
        </td>
    ');
    end if;
    if v_datos.aprobaron_def is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</span></p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">'||v_datos.aprobaron_def||'</span></p>
        </td>
    ');
    end if;
    if v_datos.reprobaron_def is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</span></p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">'||v_datos.reprobaron_def||'</span></p>
        </td>
    ');
    end if;
    if v_datos.por_aprobaron_def is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</span></p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">'||v_datos.por_aprobaron_def||'</span></p>
        </td>
    ');
    end if;
    if v_datos.por_reprobaron_def is null then
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">&nbsp;</span></p>
        </td>
    ');
    else
    htp.p('
        <td>
            <p align="center"><span style="font-size:8pt;">'||v_datos.por_reprobaron_def||'</span></p>
        </td>
    ');
    end if;
    htp.p('
    </tr>
      ');
END LOOP;
CLOSE    V_REF_CUR2;
HTP.P('
</tbody>
</table>
</CENTER>
');
END LOOP;
CLOSE    v_ref_cur;
pintar_grupos_sinnota(p_codigo);

htp.p('
<form name="formulario1" action="consulta_notastp" method="post">
<input type=hidden name="p_facultad"        value='||v_facultad||'>
<input type=hidden name="p_codigo_materia"  value='||v_codigo_materia||'>
<input type=hidden name="p_grupo_materia"   value='||v_grupo_materia||'>
<input type=hidden name="p_facultad_origen" value='||p_codigo||'>
</form>
');
htp.p('
<form name="formulario2" action="consulta_notast" method="post">
<input type=hidden name="p_facultad"       value='||v_facultad||'>
<input type=hidden name="p_codigo_materia" value='||v_codigo_materia||'>
<input type=hidden name="p_grupo_materia"  value='||v_grupo_materia||'>
<input type=hidden name="p_facultad_origen" value='||p_codigo||'>
</form>
');




htp.p('
<script>
function enviar1(a,b,c,d)
{
document.formulario1.p_facultad.value=a;
document.formulario1.p_codigo_materia.value=b;
document.formulario1.p_grupo_materia.value=c;
document.formulario1.p_facultad_origen.value=d;
document.formulario1.submit();
}
function enviar2(a,b,c,d)
{
document.formulario2.p_facultad.value=a;
document.formulario2.p_codigo_materia.value=b;
document.formulario2.p_grupo_materia.value=c;
document.formulario2.p_facultad_origen.value=d;
document.formulario2.submit();
}
</script>
</body>
</html>
');
exception
WHEN OTHERS THEN
cti_pantalla_error('Mensaje importante', sqlerrm);
END;