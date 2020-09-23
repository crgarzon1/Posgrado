set define off;

create or replace PROCEDURE b_consulta_creditos_bak(p_codigo varchar2) is

ignore boolean;
V_ULTIMO_USUARIO   B_PREMATRICULA_INVALIDOS.NOMBRE_USUARIO%TYPE DEFAULT NULL;
V_MAXFECHA   DATE DEFAULT NULL;
V_PERPRE          VARCHAR2(6)default null;
lista_columnas    varchar2(2000) default null;
condicion         varchar2(1000) default null;
v_existe         varchar2(1000) default null;
v_horario      varchar2(10) default null;
v_pagos number default 0;
v_NumeroError NUMBER;
v_TextoError VARCHAR2(200);
v_nombre_estudiante b_estudiantes.nombre%type default null;
v_creditos number(3);
v_indicador_pago b_estudiantes.indicador_pago%type default NULL;
v_c8 number default 0;
v_total_creditos b_estudiantes.total_creditos%TYPE;
v_jornada b_estudiantes.jornada_facultad%TYPE;
nom_mat      a_materias.nombre%TYPE;
V_PLAN      b_estudiantes.PLAN_ESTUDIO%TYPE;
PLAN        VARCHAR2(50);
v_promedio_ponderado b_estudiantes.promedio_ponderado%TYPE;

slunes              varchar2(10) default null;
smartes             varchar2(10) default null;
smiercoles          varchar2(10) default null;
sjueves             varchar2(10) default null;
sviernes            varchar2(10) default null;
ssabado             varchar2(10) default null;
scodfac varchar2(2) default null;
scodmat varchar2(5) default null;
sgrupo varchar2(2) default null;


hlunes              varchar2(10) default null;
hmartes             varchar2(10) default null;
hmiercoles          varchar2(10) default null;
hjueves             varchar2(10) default null;
hviernes            varchar2(10) default null;
hsabado             varchar2(10) default null;
hcodfac varchar2(2) default null;
hcodmat varchar2(5) default null;
hgrupo varchar2(2) default null;


HAY_SALON           NUMBER DEFAULT 0;
hay_pdf             NUMBER DEFAULT 0;
V_EXISTE_INDICADOR  NUMBER DEFAULT 0;
v_mensaje_consulta a_ciclos_academicos.mensaje_consulta%TYPE;--09-12-2005 Se agrego esta variable para guardar un mensaje que se quiera mostrar cuando el estudiante consulte su prematricula
v_nomarc a_pdfs.nombre_archivo%type default null;
v_existebl  NUMBER DEFAULT 0;
v_existemat NUMBER DEFAULT 0;
v_ciclo_nuevos     a_ciclos_academicos.ciclo%type default null;
v_tiene_email        number                           default 0;
v_email              correos_institucionales.correo%type default null;
V_EXISTE1            NUMBER                              DEFAULT 0;
V_EXISTE2            NUMBER                              DEFAULT 0;

CURSOR c_Horario1 IS
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,m.intensidad_horaria,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
hh.lunes,hh.martes,hh.miercoles,hh.jueves,hh.viernes,hh.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha,hh.plan_estudio,
decode(hh.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede,
hh.grupo_materia
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      a_horario_horizontal hh, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
and   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   bp.facultad_cursar=hh.codigo_facultad
AND   bp.materia_cursar=hh.codigo_materia
AND   to_number(bp.grupo)=to_number(hh.grupo_materia)
UNION--29-11-2007 Se hizo esta UNION para pintar las materias integradas en posgrados
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,m.intensidad_horaria,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
'.','.','.','.','.','.',to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha,'.',
'.',
BP.GRUPO
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
and   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   BP.FACULTAD_CURSAR>='71'


/*SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,m.intensidad_horaria,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
hh.lunes,hh.martes,hh.miercoles,hh.jueves,hh.viernes,hh.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha,hh.plan_estudio,
decode(hh.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede,
hh.grupo_materia
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      postgrado.a_horario_horizontal hh, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
and   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   be.plan_estudio=m.plan_estudio
AND   bp.facultad_cursar=hh.codigo_facultad
AND   bp.materia_cursar=hh.codigo_materia
AND   to_number(bp.grupo)=to_number(hh.grupo_materia)*/
;


--MODIFICADO EL 12-OCT-2006
CURSOR c_Horario2 IS
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,M.INTENSIDAD_HORARIA,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
ha.lunes,ha.martes,ha.miercoles,ha.jueves,ha.viernes,ha.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') FECHA,ha.plan_estudio,
   decode(ha.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      ADMISIONES.A_HORARIO_HORIZONTAL ha, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
AND   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   bp.facultad_cursar=ha.codigo_facultad
AND   bp.materia_cursar=ha.codigo_materia
AND   to_number(bp.grupo)=to_number(ha.grupo_materia)
AND   HA.ANIO = BE.ANIO
and   HA.CICLO = BE.CICLO
UNION
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,M.INTENSIDAD_HORARIA,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
ha.lunes,ha.martes,ha.miercoles,ha.jueves,ha.viernes,ha.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') FECHA,ha.plan_estudio,
   decode(ha.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      CACTUALPRE.A_HORARIO_HORIZONTAL ha, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
AND   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   bp.facultad_cursar=ha.codigo_facultad
AND   bp.materia_cursar=ha.codigo_materia
AND   to_number(bp.grupo)=to_number(ha.grupo_materia)
AND   HA.ANIO = BE.ANIO
and   HA.CICLO = BE.CICLO
UNION--29-11-2007 Se hizo esta UNION para pintar las materias integradas en posgrados
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,m.intensidad_horaria,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
hh.lunes,hh.martes,hh.miercoles,hh.jueves,hh.viernes,hh.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha,hh.plan_estudio,
decode(hh.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      postgrado.A_HORARIO_HORIZONTAL hh, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
and   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   (be.plan_estudio=m.plan_estudio or (be.tipo_de_ingreso = 'RA' and be.anio || to_number(be.ciclo) = be.ciclo_de_ingreso))
AND   bp.facultad_cursar=hh.codigo_facultad
AND   bp.materia_cursar=hh.codigo_materia
AND   to_number(bp.grupo)=to_number(hh.grupo_materia)
AND   hh.ANIO = BE.ANIO
and   hh.CICLO = BE.CICLO
UNION
SELECT bp.codigo_estudiante,bp.facultad_cursar,bp.jornada_facultad,
bp.materia_plan,m.nombre nombre_materia,m.creditos,m.semestre,m.intensidad_horaria,
fu.nombre,bp.materia_cursar,DECODE(bp.grupo,'1','01','2','02','3','03','4','04','5','05','6','06','7','07','8','08','9','09',bp.grupo) grupo,bp.indicador_reglamento,bp.otros,
hh.lunes,hh.martes,hh.miercoles,hh.jueves,hh.viernes,hh.sabado,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha,hh.plan_estudio,
decode(hh.sede,'01','LA CANDELARIA','02','CHAPINERO','03','NORTE','04','LA CANDELARIA','05','CHAPINERO','06','NORTE','07','LA CANDELARIA','08','CHAPINERO','09','NORTE') sede
,bp.indicador_pago
FROM  b_prematricula bp,a_facultades_unica fu,a_materias m,
      CACTUALPOS.A_HORARIO_HORIZONTAL hh, b_estudiantes be
WHERE bp.codigo_estudiante=p_codigo
and   be.codigo=bp.codigo_estudiante
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.materia_plan=m.codigo
AND   be.jornada_facultad=m.jornada_facultad
AND   (be.plan_estudio=m.plan_estudio or (be.tipo_de_ingreso = 'RA' and be.anio || to_number(be.ciclo) = be.ciclo_de_ingreso))
AND   bp.facultad_cursar=hh.codigo_facultad
AND   bp.materia_cursar=hh.codigo_materia
AND   to_number(bp.grupo)=to_number(hh.grupo_materia)
AND   hh.ANIO = BE.ANIO
and   hh.CICLO = BE.CICLO

;


--MODIFICADO EL 12-OCT-2006
CURSOR c_premeliminadas IS
SELECT bp.materia_plan ,m.nombre nomat,m.intensidad_horaria,m.semestre,fu.nombre,
bp.materia_cursar,bp.grupo,to_char(bp.fecha,'YYYY/MM/DD   HH:MI:PM') fecha_PRE,
to_char(bp.feha_eliminacion,'YYYY/MM/DD   HH:MI:PM') fecha_eliminacion,
bp.nombre_usuario
FROM  b_prematricula_invalidos bp,a_facultades_unica fu,a_materias m,b_estudiantes be
WHERE bp.codigo_estudiante=be.codigo
AND   bp.facultad_cursar = fu.codigo_facultad
AND   bp.facultad=m.codigo_facultad
AND   bp.jornada_facultad=m.jornada_facultad
AND   bp.materia_plan=m.codigo
AND   m.plan_estudio=be.plan_estudio
AND   bp.codigo_estudiante=p_codigo
ORDER BY bp.feha_eliminacion;

v_ciclo a_ciclos_academicos.ciclo%TYPE;
v_batch a_ciclos_academicos.batch%TYPE;
V_ANIO_CICLO VARCHAR2(6) DEFAULT NULL;
V_ANIO_CICLO_HA VARCHAR2(6) DEFAULT NULL;
v_grupo varchar2(2) default null;
hay_pdf_nvo       number      default 0;
v_nomarc_real  varchar2(256)                             default null;

v_ciclo_de_ingreso                                       b_estudiantes.ciclo_de_ingreso%type default null;
v_tipo_de_ingreso                                        b_estudiantes.tipo_de_ingreso%type default null;
V_NUMDOC                                                 AH_HORIZONTAL_ACTUAL.NUMERO_DOCUMENTO%TYPE DEFAULT NULL;
V_MOSTRAR_SALONES                                        A_FECHAS_DE_CORTE.IND_CIERRE%TYPE DEFAULT NULL;
v_doc_id           documents.documents_new.documento_id%type;
n_es_postgradual    number  default 0;
begin
--HTP.P('b_consulta_creditos_bak');
SELECT FC.IND_CIERRE
INTO   V_MOSTRAR_SALONES
FROM   A_FECHAS_DE_CORTE FC
WHERE  SUBSTR(FC.PROCESO,1,15) ='MOSTRAR SALONES';



SELECT NVL(MAX(Ha.ANIO||Ha.CICLO),0)
into   v_anio_ciclo_ha
FROM   ah_horizontal_actual ha;


/*SELECT MAX(PI.NOMBRE_USUARIO)
INTO V_ULTIMO_USUARIO
FROM B_PREMATRICULA_INVALIDOS PI
WHERE PI.CODIGO_ESTUDIANTE=P_CODIGO
AND PI.FEHA_ELIMINACION IN
(
SELECT MAX(PI.FEHA_ELIMINACION)
FROM B_PREMATRICULA_INVALIDOS PI
WHERE PI.CODIGO_ESTUDIANTE=P_CODIGO
);*/
V_ULTIMO_USUARIO := null;

SELECT NVL(MAX(HH.ANIO||HH.CICLO),0)
INTO   v_anio_ciclo
FROM   a_Horario_Horizontal HH;


select be.ciclo_de_ingreso,be.tipo_de_ingreso
into   v_ciclo_de_ingreso,v_tipo_de_ingreso
from   b_estudiantes be
where  be.codigo=p_codigo;
--htp.p(v_ciclo_de_ingreso);
--htp.p(v_tipo_de_ingreso);

select max(ca.ciclo)
into   v_ciclo_nuevos
from   a_ciclos_academicos ca;
--htp.p(v_ciclo_nuevos);

--if v_ciclo_de_ingreso||v_tipo_de_ingreso in(v_ciclo_nuevos||'NV',v_ciclo_nuevos||'GM',v_ciclo_nuevos||'HM',v_ciclo_nuevos||'IH',v_ciclo_nuevos||'PI',v_ciclo_nuevos||'SA') THEN
--aviso_general_fondo_azul('Importante: Usted podrÃ¡ consultar los salones asignados a cada asignatura, a partir del 25 de Julio de 2011.','white');
--end if;

select count(1)
into v_existe
/* se cambia cuando hay cierre de prematricual*/
--from b_prematricula p
from b_prematricula p
where p.codigo_estudiante= p_codigo;
if v_existe = 0 then
HTP.P('<html>
    <body  bgcolor="white" text="black" link="blue" vlink="purple" alink="red">');
 B_ACEPTAR('NO TIENE ASIGNATURAS PREMATRICULADAS','white');
 htp.p('
</tr><tr>
</tr>
<p align="center"><input type="submit" name="b_boton1" value="TERMINAR" onclick="history.go(-1)"></td>
</tr>
</form>
');
else
IF SUBSTR(p_codigo,1,2)='10' then
select be.nombre,be.indicador_pago,be.jornada_facultad,
DECODE(be.plan_estudio,'1','PLAN ANTIGUO','2','PLAN MODERNIZACION','3','PLAN CREDITOS','4','PLAN CREDITOS-AJUSTES20071','5','PLAN CREDITOS-REDIMENSIONAMIENTO'),be.promedio_ponderado
into   v_nombre_estudiante,v_indicador_pago,v_jornada,plan,v_promedio_ponderado
from   b_estudiantes be
where  be.codigo=p_codigo;
v_indicador_pago:='X';
else
select be.nombre,be.indicador_pago,be.jornada_facultad,
DECODE(be.plan_estudio,'1','PLAN ANTIGUO','2','PLAN MODERNIZACION','3','PLAN CREDITOS','4','PLAN CREDITOS-REDIMENSIONAMIENTO'),be.promedio_ponderado
into   v_nombre_estudiante,v_indicador_pago,v_jornada,plan,v_promedio_ponderado
from   b_estudiantes be
where  be.codigo=p_codigo;
v_indicador_pago:='X';
end if;
HTP.P('<!-- JDRJ cons BAK -->
<TABLE align=center border="1" style="font-family:Verdana,cursive; font-size:9px;">
<tr bgcolor="#FBF6DA">
<td colspan="21">
<P align=center style="font-family:Verdana,cursive; font-size:9px;"><FONT COLOR=BLUE>CODIGO: </FONT>'||P_CODIGO||' <FONT COLOR=BLUE>NOMBRE: </FONT>'||V_NOMBRE_ESTUDIANTE||'<FONT COLOR=BLUE><br>'||PLAN||' </FONT>
</td>
</tr>
');
HTP.P('
<TR>
<TH bordercolor="blue"   rowspan="2" bgcolor="#FFFFCC">CODIGO DEL PLAN</TH>
<TH bordercolor="blue"   rowspan="2" bgcolor="#FFFFCC">MATERIA DEL PLAN</TH>
<TH bordercolor="blue"   rowspan="2">HORAS PLAN</TH>
<TH bordercolor="blue"   rowspan="2">CR&Eacute;DITOS PLAN</TH>
<TH bordercolor="blue"   rowspan="2">SEM. PLAN</TH>
<TH bordercolor="blue"   rowspan="2" bgcolor="#33FFFF">UNIDAD ACAD&Eacute;MICA</TH>
<TH bordercolor="blue"   rowspan="2" bgcolor="#FFCC99">CODIGO DE LA MATERIA CURSAR</TH>
<TH bordercolor="blue"   rowspan="2" bgcolor="#FFCC99">MATERIA A CURSAR</TH>
<TH bordercolor="blue"   rowspan="2" bgcolor="#66FF99">GRUPO</TH>
');
--IF V_EXISTE_INDICADOR>0 THEN
HTP.P('
<TH  rowspan="2" bordercolor="blue">Novedad</TH>
');
--END IF;
HTP.P('
<TH bordercolor="blue" >LUNES</TH>
<TH bordercolor="blue" >MARTES</TH>
<TH bordercolor="blue" >MIERC.</TH>
<TH bordercolor="blue" >JUEVES</TH>
<TH bordercolor="blue" >VIERNES</TH>
<TH bordercolor="blue" >SABADO</TH>
<TH rowspan="2" bordercolor="blue" >FECHA PREMATRICULA</TH>
');
IF V_ULTIMO_USUARIO IS NOT NULL THEN
HTP.P('
<TH rowspan="2" bordercolor="blue" >USUARIO QUE REALIZO LA PREMATRICULA ACTUAL</TH>
');
END IF;

HTP.P('
<Th bordercolor="blue" H rowspan="2">SYLLABUS</TH>
');

IF v_anio_ciclo=v_anio_ciclo_ha THEN
HTP.P('
<Th bordercolor="blue" H rowspan="2">Email docente</TH>
');
END IF;

HTP.P('
<TH bordercolor="blue"  rowspan="2">SEDE</TH>
</TR>
<TR>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
<TH bordercolor="blue" ><font color="#0066FF"></font>
</TH>
</TR>

');

SELECT MAX(bp.anio||bp.ciclo)
INTO   v_perpre
FROM   b_prematricula bp;




if v_PERPRE=v_anio_ciclo then

FOR v_Horario IN c_Horario1 LOOP

SELECT COUNT(1)
INTO HAY_SALON
FROM SALONES S
where v_horario.facultad_cursar= s.codigo_facultad
AND v_horario.materia_cursar=s.codigo_materia
AND TO_NUMBER(v_horario.grupo)=TO_NUMBER(s.grupo_materia)
and s.anio=substr(v_anio_ciclo,1,4)
and s.ciclo=substr(v_anio_ciclo,5,2);


HTP.P('
<TR>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#FFFFCC">'||v_Horario.materia_plan||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#FFFFCC">'||v_Horario.nombre_materia||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1">'||v_Horario.INTENSIDAD_HORARIA||'</TD>
<TD bordercolor="white"  ALIGN="center" rowspan="1">'||v_Horario.creditos||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1">'||v_Horario.semestre||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#33FFFF">'||v_Horario.nombre||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#FFCC99">'||v_Horario.materia_cursar||'</TD>
');

--MODIFICADO EL 12-OCT-2006
/*29-11-2007 Se agrego la siguiente condiciÃ³n para cuando esta integrando con posgrados*/
IF v_horario.facultad_cursar <= '71' or SUBSTR(v_horario.facultad_cursar,1,1)='0' THEN
   SELECT COUNT(*)
   INTO   V_EXISTE1
   FROM   A_MATERIAS M
   where  m.codigo_facultad=v_horario.facultad_cursar
   and    m.jornada_facultad=v_horario.jornada_facultad
   and    m.codigo=v_horario.materia_cursar;
   IF V_EXISTE1>0 THEN
      select m.nombre
      into   nom_mat
      from   a_materias m
      where  m.codigo_facultad=v_horario.facultad_cursar
      and    m.jornada_facultad=v_horario.jornada_facultad
      and    m.codigo=v_horario.materia_cursar;
      ELSE
      select HH.NOMBRE_MATERIA
      into   nom_mat
      from   A_HORARIO_HORIZONTAL HH
      where  HH.CODIGO_FACULTAD=V_HORARIO.facultad_cursar
      AND    HH.CODIGO_MATERIA=V_HORARIO.materia_cursar
      and    TO_NUMBER(HH.GRUPO_MATERIA)=TO_NUMBER(V_HORARIO.GRUPO);

   END IF;
ELSE
    begin
        select m.nombre
        into   nom_mat
        from   postgrado.a_materias m
        where  m.codigo_facultad=v_horario.facultad_cursar
        and    m.codigo=v_horario.materia_cursar;
    exception
    when others then
        htp.p('<td colspan="12">' || sqlerrm || '</td></tr></table>');
        raise;
    end;
END IF;


HTP.P('
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#FFCC99">'||NOM_MAT||'</TD>
<TD bordercolor="white"  ALIGN="LEFT" rowspan="1" bgcolor="#66FF99">'||v_Horario.grupo||'</TD>
');

if v_horario.indicador_reglamento is not null then
    HTP.P('<td style="background: red; color: white; font-weight: bold; text-align: center;">N</td>');
elsif v_Horario.indicador_pago in ('K','C') then
	HTP.P('<td style="background: red; color: white; font-weight: bold; text-align: center;">asignatura retirada</td>');
else
	HTP.P('<td>&nbsp;</td>');
end if;


select count(*)
into   v_existebl
from    a_bloques bl
where   bl.codigo_facultad=v_horario.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario.materia_cursar
AND     BL.GRUPO=v_horario.grupo;


if v_existebl>0 then


select bl.codigo_facultad,bl.codigo_materia,bl.grupo,
MAX(decode(bl.bloque||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) lunes,
MAX(decode(bl.bloque||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) martes,
MAX(decode(bl.bloque||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) miercoles,
MAX(decode(bl.bloque||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) jueves,
MAX(decode(bl.bloque||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) viernes,
MAX(decode(bl.bloque||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) sabado
INTO scodfac,scodmat,sgrupo,slunes,smartes,smiercoles,sjueves,sviernes,ssabado
from  a_bloques bl
where   bl.codigo_facultad=v_horario.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario.materia_cursar
AND     BL.GRUPO=v_horario.grupo
group by bl.codigo_facultad,bl.codigo_materia,bl.grupo;



select bl.codigo_facultad,bl.codigo_materia,bl.grupo,
MAX(decode(bl.bloque||bl.dia,'11',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'21',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) lunes,
MAX(decode(bl.bloque||bl.dia,'32',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'42',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) martes,
MAX(decode(bl.bloque||bl.dia,'53',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'63',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) miercoles,
MAX(decode(bl.bloque||bl.dia,'74',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'84',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) jueves,
MAX(decode(bl.bloque||bl.dia,'95',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'105',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) viernes,
MAX(decode(bl.bloque||bl.dia,'116',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'126',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) sabado
INTO hcodfac,hcodmat,hgrupo,hlunes,hmartes,hmiercoles,hjueves,hviernes,hsabado
from  a_bloques bl
where   bl.codigo_facultad=v_horario.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario.materia_cursar
AND     BL.GRUPO=v_horario.grupo
group by bl.codigo_facultad,bl.codigo_materia,bl.grupo;
else
Hlunes:='.';
Hmartes:='.';
Hmiercoles:='.';
Hjueves:='.';
Hviernes:='.';
Hsabado:='.';

slunes:='.';
smartes:='.';
smiercoles:='.';
sjueves:='.';
sviernes:='.';
ssabado:='.';

IF V_MOSTRAR_SALONES=0 THEN
slunes:='.';
smartes:='.';
smiercoles:='.';
sjueves:='.';
sviernes:='.';
ssabado:='.';
END IF;
end if;
IF V_MOSTRAR_SALONES=0 THEN
--DESBLOQUEAR PARA NO MOSTRAR SALONES
slunes:='.';
smartes:='.';
smiercoles:='.';
sjueves:='.';
sviernes:='.';
ssabado:='.';
END IF;

HTP.P('
<TD bordercolor="white"      align=left><font color="#0066FF">'||HLUNES||'<BR>'||SLUNES||'</font></TD>
<TD bordercolor="white"      align=left><font color="#0066FF">'||HMARTES||'<BR>   '||SMARTES||'</font></TD>
<TD bordercolor="white"      align=left><font color="#0066FF">'||HMIERCOLES||'<BR>   '||SMIERCOLES||'</font></TD>
<TD bordercolor="white"      align=left><font color="#0066FF">'||HJUEVES||'<BR>   '||SJUEVES||'</font></TD>
<TD bordercolor="white"      align=left><font color="#0066FF">'||HVIERNES||'<BR>  '||SVIERNES||'</font></TD>
<TD bordercolor="white"      align=left><font color="#0066FF">'||HSABADO||'<BR>    '||SSABADO||'</font></TD>
');


HTP.P('
<TD bordercolor="white"  ALIGN="LEFT">'||v_Horario.FECHA||'</TD>
');
IF V_ULTIMO_USUARIO IS NOT NULL THEN
HTP.P('
<TD bordercolor="white" >'||V_ULTIMO_USUARIO||'</TD>
');
END IF;
/*
select count(*)
into   hay_pdf_nvo
from   documents.documents_new d
where  d.CODIGO_FACULTAD =v_horario.facultad_cursar
AND d.CODIGO_MATERIA = V_horario.materia_cursar
AND d.GRUPO =v_horario.grupo_materia;
--hay_pdf_nvo:=0;

if hay_pdf_nvo>0 then

    begin
        SELECT d.documento_id
        INTO v_doc_id
        FROM documents.documents_new d
        where  d.codigo_facultad=v_horario.facultad_cursar
        and    d.codigo_materia=V_horario.materia_cursar
        and    d.grupo=v_horario.grupo_materia;
    exception
    when others then
        v_doc_id := null;
        htp.p('<!-- doc id not found -->');
    end;
    begin
        SELECT  NVL(dc.nombre_original, dc.nombre)
        INTO v_nomarc
        from cti_documentos.cti_dc_documentos dc
        where dc.id = v_doc_id;
    exception
    when others then
        v_nomarc := null;
        htp.p('<!-- nom arc not found -->');
    end;
    if v_nomarc is null then
        htp.p('
        <td>&nbsp;</td>
        ');
    else
        htp.p('
        <TD bordercolor="white"  width="200" ALIGN="LEFT" rowspan="1"><a href="javascript:enviarSyll('||''''||v_horario.facultad_cursar||V_horario.materia_cursar||v_horario.grupo_materia||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_nomarc||'</a></TD>
        ');
    end if;
else
      htp.p('
      <TD bordercolor="white"  width="200" ALIGN="LEFT">.</TD>
      ');
end if;

/*htp.p(v_anio_ciclo);*/
--2018-08-21 Cambia al sistema syllabus
htp.p('
  <TD bordercolor="white"  width="200" ALIGN="LEFT" rowspan="1"><a href="javascript:enviarSyll('||''''||v_horario.facultad_cursar||V_horario.materia_cursar||v_Horario.grupo||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >Ver Syllabus</a></TD>
');


IF v_anio_ciclo=v_anio_ciclo_ha THEN




                    select count(*)
                    into   v_tiene_email
                    from   correos_institucionales ci
                    where  LTRIM(RTRIM(ci.codigo))=LTRIM(RTRIM(V_NUMDOC));
                    if v_tiene_email>0 then
                       select ci.correo
                       into   v_email
                       from   correos_institucionales ci
                       where  LTRIM(RTRIM(ci.codigo))=LTRIM(RTRIM(V_NUMDOC));
                       if v_email='null' then
                       v_email:='.';
                       end if;
                       else
                       v_email:='.';
                    end if;
                    if v_email!='.' then
                    htp.p('
                    <td bordercolor="white"   ALIGN="LEFT">
                        <p align="left"><a href="mailto:'||V_EMAIL||'" >'||v_email||'</a></p>
                    </td>
                    ');
                    else
                    htp.p('
                    <td bordercolor="white"   ALIGN="LEFT">
                        <p align="left">.</p>
                    </td>
                    ');
                    end if;


END IF;








htp.p('
<TD bordercolor="white"  ALIGN="LEFT">'||v_Horario.SEDE||'</TD>
</TR>
');
END LOOP;

else
--ciclo actUAL
--HTP.P('XXXXXXXXXXXXXXXXXXXXX-V_HORARIO2');

FOR v_Horario2 IN c_Horario2 LOOP
SELECT MAX(ANIO||CICLO)
INTO   V_ANIO_CICLO
FROM   AH_HORIZONTAL_ACTUAL;

SELECT COUNT(1)
INTO HAY_SALON
FROM SALONES S
where v_horario2.facultad_cursar= s.codigo_facultad
AND v_horario2.materia_cursar=s.codigo_materia
AND TO_NUMBER(v_horario2.grupo)=TO_NUMBER(s.grupo_materia)
AND S.ANIO=SUBSTR(V_ANIO_CICLO,1,4)
AND S.CICLO=SUBSTR(V_ANIO_CICLO,5,2) ;

IF v_horario2.facultad_cursar <= '71' or SUBSTR(v_horario2.facultad_cursar,1,1)='0' THEN
   SELECT COUNT(*)
   INTO   V_EXISTE2
   FROM   A_MATERIAS M
   where  m.codigo_facultad=v_horario2.facultad_cursar
   and    m.jornada_facultad=v_horario2.jornada_facultad
   and    m.codigo=v_horario2.materia_cursar;
   IF V_EXISTE2>0 THEN
      select m.nombre
      into   nom_mat
      from   a_materias m
      where  m.codigo_facultad=v_horario2.facultad_cursar
      and    m.jornada_facultad=v_horario2.jornada_facultad
      and    m.codigo=v_horario2.materia_cursar;
   END IF;
ELSE
   select m.nombre
   into   nom_mat
   from   postgrado.a_materias m
   where  m.codigo_facultad=v_horario2.facultad_cursar
   and    m.codigo=v_horario2.materia_cursar;
END IF;


HTP.P('
<TR>
<TD ALIGN="LEFT" ROwspan="1" bgcolor="#FFFFCC">'||v_Horario2.materia_plan||'</TD>
<TD ALIGN="LEFT" ROwspan="1" bgcolor="#FFFFCC">'||v_Horario2.nombre_materia||'</TD>
<TD ALIGN="LEFT" ROwspan="1">'||v_Horario2.INTENSIDAD_HORARIA||'</TD>
<TD ALIGN="center" ROwspan="1">'||v_Horario2.creditos||'</TD>
<TD ALIGN="LEFT" ROwspan="1">'||v_Horario2.semestre||'</TD>
<TD ALIGN="LEFT" ROwspan="1" bgcolor="#33FFFF">'||v_Horario2.nombre||'</TD>
<TD ALIGN="LEFT" ROwspan="1" bgcolor="#FFCC99">'||v_Horario2.materia_cursar||'</TD>
');


HTP.P('
<TD ALIGN="LEFT" ROwspan="1">'||NOM_MAT||'</TD>
<TD ALIGN="LEFT" ROwspan="1">'||v_Horario2.grupo||'</TD>
');

if v_horario2.indicador_reglamento is not null then
    HTP.P('<td style="background: red; color: white; font-weight: bold; text-align: center;">N</td>');
elsif v_Horario2.indicador_pago in ('K','C') then
	HTP.P('<td style="background: red; color: white; font-weight: bold; text-align: center;">asignatura retirada</td>');
else
	HTP.P('<td>&nbsp;</td>');
end if;

--AJUSTADO EL 02MAY2012
select count(*)
into   v_existebl
from    CACTUALPRE.a_bloques bl
where   bl.codigo_facultad=v_horario2.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario2.materia_cursar
AND     BL.GRUPO=v_horario2.grupo;
if v_existebl>0 then
select bl.codigo_facultad,bl.codigo_materia,bl.grupo,
MAX(decode(bl.bloque||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) lunes,
MAX(decode(bl.bloque||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) martes,
MAX(decode(bl.bloque||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) miercoles,
MAX(decode(bl.bloque||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) jueves,
MAX(decode(bl.bloque||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) viernes,
MAX(decode(bl.bloque||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))||MAX(decode(bl.bloque||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) sabado
INTO scodfac,scodmat,sgrupo,slunes,smartes,smiercoles,sjueves,sviernes,ssabado
from  CACTUALPRE.a_bloques bl
where   bl.codigo_facultad=v_horario2.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario2.materia_cursar
AND     BL.GRUPO=v_horario2.grupo
group by bl.codigo_facultad,bl.codigo_materia,bl.grupo;



select bl.codigo_facultad,bl.codigo_materia,bl.grupo,
MAX(decode(bl.bloque||bl.dia,'11',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'21',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) lunes,
MAX(decode(bl.bloque||bl.dia,'32',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'42',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) martes,
MAX(decode(bl.bloque||bl.dia,'53',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'63',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) miercoles,
MAX(decode(bl.bloque||bl.dia,'74',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'84',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) jueves,
MAX(decode(bl.bloque||bl.dia,'95',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'105',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) viernes,
MAX(decode(bl.bloque||bl.dia,'116',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL)))||MAX(decode(bl.bloque||bl.dia,'126',BL.HORA||DECODE(BL.ASIGSAL,'N','P',NULL))) sabado
INTO hcodfac,hcodmat,hgrupo,hlunes,hmartes,hmiercoles,hjueves,hviernes,hsabado
from  CACTUALPRE.a_Bloques bl
where   bl.codigo_facultad=v_horario2.facultad_cursar
AND     BL.CODIGO_MATERIA=V_horario2.materia_cursar
AND     BL.GRUPO=v_horario2.grupo
group by bl.codigo_facultad,bl.codigo_materia,bl.grupo;

else
Hlunes:='.';
Hmartes:='.';
Hmiercoles:='.';
Hjueves:='.';
Hviernes:='.';
Hsabado:='.';

slunes:='.';
smartes:='.';
smiercoles:='.';
sjueves:='.';
sviernes:='.';
ssabado:='.';

IF V_MOSTRAR_SALONES=0 THEN
slunes:='.';
smartes:='.';
smiercoles:='.';
sjueves:='.';
sviernes:='.';
ssabado:='.';
END IF;
end if;


HTP.P('

<TD     align=left><font color="#0066FF">'||HLUNES||'<BR>'||SLUNES||'</font></TD>
<TD     align=left><font color="#0066FF">'||HMARTES||'<BR>   '||SMARTES||'</font></TD>
<TD     align=left><font color="#0066FF">'||HMIERCOLES||'<BR>   '||SMIERCOLES||'</font></TD>
<TD     align=left><font color="#0066FF">'||HJUEVES||'<BR>   '||SJUEVES||'</font></TD>
<TD     align=left><font color="#0066FF">'||HVIERNES||'<BR>  '||SVIERNES||'</font></TD>
<TD     align=left><font color="#0066FF">'||HSABADO||'<BR>    '||SSABADO||'</font></TD>

');


HTP.P('
<TD ALIGN="LEFT">'||v_Horario2.FECHA||'</TD>
');
IF V_ULTIMO_USUARIO IS NOT NULL THEN
HTP.P('
<TD>'||V_ULTIMO_USUARIO||'</TD>
');
END IF;
select count(1)
into   hay_pdf
from   a_syllabus s
where  v_horario2.materia_cursar=s.codigo_materia;

/*
select count(*)
into   hay_pdf_nvo
from   documents.documents_new d
where  d.CODIGO_FACULTAD = v_horario2.facultad_cursar
AND d.CODIGO_MATERIA = V_horario2.materia_cursar
AND d.GRUPO = v_horario2.grupo;
--hay_pdf_nvo:=0;

if hay_pdf_nvo>0 then

     SELECT d.documento_id
  INTO v_doc_id
  FROM documents.documents_new d
   where  d.codigo_facultad=v_horario2.facultad_cursar
   and    d.codigo_materia=V_horario2.materia_cursar
   and    d.grupo=v_horario2.grupo;

   SELECT  NVL(dc.nombre_original, dc.nombre)
   INTO v_nomarc
   from cti_documentos.cti_dc_documentos dc
   where dc.id = v_doc_id;


   htp.p('
   <TD width="200" ALIGN="LEFT" ROwspan="1"><a href="javascript:enviarSyll('||''''||v_horario2.facultad_cursar||V_horario2.materia_cursar||v_horario2.grupo||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_nomarc||'</a></TD>
   ');
   else
      htp.p('
      <TD width="200" ALIGN="LEFT">.</TD>
      ');
end if;
*/


   htp.p('
   <TD width="200" ALIGN="LEFT" ROwspan="1"><a href="javascript:enviarSyll('||''''||v_horario2.facultad_cursar||V_horario2.materia_cursar||v_horario2.grupo||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >Ver Syllabus</a></TD>
   ');

htp.p('
<TD ALIGN="LEFT">'||v_Horario2.SEDE||'</TD>
</TR>
');
END LOOP;


end if;



HTP.P('</TABLE>');

SELECT SUM(m.creditos)
INTO   v_creditos
FROM   vw_prematricula bp,a_materias m,b_estudiantes be
WHERE  bp.codigo_estudiante=be.codigo
AND    bp.codigo_estudiante=p_codigo
AND    bp.facultad=m.codigo_facultad
AND    m.jornada_facultad = v_jornada
AND    bp.indicador_reglamento is null
AND    bp.materia_plan=m.codigo;

SELECT be.total_creditos
 INTO v_total_creditos
 FROM b_estudiantes be
 WHERE be.codigo = p_codigo;

SELECT MAX(c.ciclo)  INTO v_ciclo
  FROM a_ciclos_academicos c
  WHERE  c.tipo = 'P';
SELECT c.batch,c.mensaje_consulta INTO v_batch,v_mensaje_consulta FROM a_ciclos_academicos c
  WHERE c.ciclo = v_ciclo AND c.tipo = 'P';
--Solo en caso de que ya se halla corrido el proceso batch, se hacen las siguientes verificaciones
IF v_batch = 'S' THEN
--A continuacion seleccionamos la intensidad horaria 27-06-03
SELECT be.total_creditos
INTO v_total_creditos
FROM b_estudiantes be
WHERE be.codigo = p_codigo;
---------------------------------------------------------------------
select count(otros)
INTO   v_c8
from   b_prematricula bp
where  bp.codigo_estudiante=p_codigo
and    substr(bp.otros,1,2)='C8';
---------------------------------------------------------------------

if v_indicador_pago in('P','V','A') and v_c8=0 then
   AVISO_GENERAL_FONDO_AZUL('ESTUDIANTE MATRICULADO','WHITE');
end if;

if v_indicador_pago in('P','V','A') and v_c8>1 then
   ERRORES_GENERAL('ESTUDIANTE CANCELO SEMESTRE DESPUES DE EMPEZAR REGISTRO DE NOTAS','WHITE');
end if;

if v_indicador_pago IN('K','C') then
   AVISO_GENERAL_FONDO_ROJO('PERÃ?ODO ACADÃ‰MICO CANCELADO','WHITE');
end if;
if (v_indicador_pago='X' OR v_indicador_pago is null) then
   if  v_total_creditos = 0 THEN
       AVISO_GENERAL_FONDO_ROJO('SU PREMATRICULA FUE ANULADA TOTALMENTE','WHITE');
     elsif  v_total_creditos <> v_creditos then
       AVISO_GENERAL_FONDO_ROJO('SU PREMATRICULA FUE ANULADA PARCIALMENTE','WHITE');
     else
      HTP.P();
     end if;
end if;
END IF;
IF v_batch = 'S' THEN
HTP.P('TOTAL CREDITOS: '||v_total_creditos);
ELSE
HTP.P('TOTAL CREDITOS: '||v_creditos);
END IF;
--HTP.P('TOTAL CREDITOS: '||v_total_creditos);
---------

n_es_postgradual := pkg_estudiantes.esPostgradual(p_codigo);
if n_es_postgradual > 0 then
    htp.p('<p>Apreciado Estudiante: tenga en cuenta que para aprobar y homologar en su programa de Pregrado los espacios académicos que cursará en Postgrado, debe obtener una calificación mínima de tres punto cinco (3.5), según lo establecido en el Artículo 7° - Cogrado del Acuerdo No. 004 de 2018 expedido por el Consejo Académico el 17 de octubre de 2018. Sino aprueba con esta calificación, la nota y el espacio académico NO será cargado en el sistema, razón por la cual quedará pendiente por cursar en su malla curricular.</p>');
end if;

SELECT COUNT(*)
INTO V_EXISTE_INDICADOR
FROM b_PREMATRICULA BP
WHERE BP.CODIGO_ESTUDIANTE=p_codigo
AND BP.INDICADOR_REGLAMENTO||BP.OTROS IS NOT NULL;
IF V_EXISTE_INDICADOR>0 THEN
    HTP.P('
    <TABLE align=center border=1 style="font-family:Verdana,cursive; font-size:9px;">
    <tr>
    <td colspan="2" bgcolor="blue">
    <p align="center"><font color="white"><b>INDICADORES DE CANCELACION</b></font>
    </td>
    </tr>
    <tr>
    <td >
    <b>N: GRUPO CERRADO</b>
    </td>
    <td >
    <b>W: LA MATERIA YA FUE APROBADA</b>
    </td>
    </tr>
    <tr>
    <td ><b>CT: CANCELACION TOTAL</b></font></td>
    <td ><b>C8: CANCELO SEMESTRE DESPUES DE EMPEZAR REGISTRO DE NOTAS</b></font></td>
    </tr>
    </table>
    ');
END IF;
--21FEB2014
 prematricula_libres(p_codigo);

SELECT COUNT(1)
INTO   v_c8
FROM   b_prematricula_invalidos i
WHERE  i.codigo_estudiante = p_codigo;
IF v_c8 > 0 THEN
    B_ACEPTAR('RELACION DE PREMATRICULAS ANTERIORES','white');
    htp.p('
    <TABLE align=center border=1 style="font-family:Verdana,cursive; font-size:9px;">
    <tr>
    <td><font COLOR=BLUE>MAT. PLAN</FONT></td>
    <td><font COLOR=BLUE>NOMBRE MATERIA PLAN</FONT></td>
    <td><font COLOR=BLUE>FACULTAD INTEGRADA</FONT></td>
    <td><font COLOR=BLUE>MATERIA INTEGRADA</FONT></td>
    <td><font COLOR=BLUE>GRUPO</FONT></td>
    <td><font COLOR=BLUE>FECHA PREMATRICULA</FONT></td>
    <td><font COLOR=BLUE>FECHA MODIFICACION</FONT></td>
    <td><font COLOR=BLUE>USUARIO QUE MODIFICO LA PREMATRICULA</FONT></td>
    </tr>
    ');
    FOR v_DATOS IN c_PREMELIMINADAS LOOP
        htp.p('
        <tr>
        <td>'||V_DATOS.MATERIA_PLAN||'</td>
        <td>'||V_DATOS.NOMAT||'</td>
        <td>'||V_DATOS.NOMBRE||'</td>
        <td>'||V_DATOS.MATERIA_CURSAR||'</td>
        <td>'||V_DATOS.GRUPO||'</td>
        <td>'||V_DATOS.FECHA_PRE||'</td>
        <td>'||V_DATOS.feCha_elimINACION||'</td>
        <td>'||V_DATOS.NOMBRE_USUARIO||'</td>
        </tr>
        ');
    END LOOP;
    HTP.P('
    </TABLE>
    ');
END IF;
-------

END IF;

htp.p('
<form name="syllform" action="/pls/pdfs/abrir_archivo" method="post" target="_blank">
<input type=hidden name="p_filename" value='||v_nomarc||'>
</form>
');
HTP.P('
<script>
function enviarSyll(docVal) {
    document.syllform.p_filename.value=docVal;
    document.syllform.submit();
}
</script>
');

EXCEPTION
WHEN OTHERS THEN
   htp.p('<!-- ERROR: ' || pkg_utils.acentos(sqlerrm) || ' -->');
end b_consulta_creditos_bak;