create or replace PROCEDURE "PINTA_HORARIOK_POSTGRADO"
   (v_codigo  in varchar DEFAULT 'NO VALIDO')
   IS
     ignore boolean;
     condicion             varchar2(2000);
     i                     number;
     v_facultad            varchar(8):=substr(v_codigo,1,2);
     v_semestre             varchar(2);
     v_jornada             varchar(1);
     v_diurna             varchar(1) default 'D';
     v_nocturna           varchar(1) default 'N';
     v_nombre_facultad    varchar(50) default null;
     V_CUPO_DISP        NUMBER DEFAULT 0;
     V_EXISTE_DIURNO   NUMBER DEFAULT 0;
     V_EXISTE_NOCTURNO   NUMBER DEFAULT 0;
     HAY_SALON          NUMBER DEFAULT 0;
     hay_pdf            NUMBER DEFAULT 0;

    p_codigo   varchar2(2) default v_codigo;
    v_existe   number default 0;
    v_consecutivo       a_horario_horizontal.consecutivo%type default null;
CURSOR jornadas is
SELECT f.nombre,f.jornada
FROM   a_horario_horizontal hh,a_facultades f
WHERE  hh.codigo_facultad=f.codigo
AND    hh.codigo_facultad=v_codigo
GROUP  BY f.nombre,f.jornada;

CURSOR semestres is
SELECT DISTINCT(m.semestre)
FROM   a_horario_horizontal hh,a_materias m
WHERE  hh.codigo_facultad=m.codigo_facultad
AND    hh.jornada_facultad=m.jornada_facultad
AND    hh.codigo_materia=m.codigo
AND    hh.codigo_facultad=v_codigo
AND    hh.jornada_facultad=v_jornada
ORDER  BY m.semestre;

CURSOR  horario IS
SELECT  hh.codigo_materia,m.nombre,m.semestre,m.intensidad_horaria,hh.grupo_materia,hh.cupo,(select count(bp.codigo_estudiante)
from   postgrado.b_prematricula bp
where  bp.facultad_cursar=HH.CODIGO_FACULTAD
and    bp.materia_cursar =HH.CODIGO_MATERIA
and     BP.INDICADOR_PAGO in ('P', 'V', 'W')
and    TO_NUMBER(bp.grupo)=TO_NUMBER(HH.GRUPO_MATERIA))   + (select count(bp.codigo_estudiante)
from   admisiones.b_prematricula bp
where  bp.facultad_cursar=HH.CODIGO_FACULTAD
and    bp.materia_cursar =HH.CODIGO_MATERIA
and     BP.INDICADOR_PAGO in ('P', 'V', 'W')
and    TO_NUMBER(bp.grupo)=TO_NUMBER(HH.GRUPO_MATERIA)) MATRICULADOS,(select count(bp.codigo_estudiante)
from   postgrado.b_prematricula bp
where  bp.facultad_cursar=HH.CODIGO_FACULTAD
and    bp.materia_cursar =HH.CODIGO_MATERIA
and     BP.INDICADOR_PAGO in ('P', 'V', 'W')
and    TO_NUMBER(bp.grupo)=TO_NUMBER(HH.GRUPO_MATERIA))   + (select count(bp.codigo_estudiante)
from   admisiones.b_prematricula bp
where  bp.facultad_cursar=HH.CODIGO_FACULTAD
and    bp.materia_cursar =HH.CODIGO_MATERIA
and     BP.INDICADOR_PAGO in ('P', 'V', 'W')
and    TO_NUMBER(bp.grupo)=TO_NUMBER(HH.GRUPO_MATERIA)) CUPO_UTILIZADO,hh.cupo-hh.cupo_utilizado cupo_disponible,hh.lunes,hh.martes,hh.miercoles,hh.jueves,hh.viernes,hh.sabado,hh.semanas,hh.nombre_profesor,hh.profesor_practica,hh.abierto,
        hh.fecha_inicio_notas,hh.fecha_fin_notas ,hh.fecha_inicio_clases,hh.fecha_fin_clases,hh.consecutivo
FROM    a_horario_horizontal hh, a_materias m
WHERE   hh.jornada_facultad=m.jornada_facultad
AND     hh.codigo_facultad=m.codigo_facultad
AND     hh.codigo_facultad=v_facultad
AND     hh.codigo_materia=m.codigo
AND     m.jornada_facultad=v_jornada
AND     m.semestre=v_semestre
ORDER   BY m.semestre,hh.grupo_materia,hh.codigo_materia;


CURSOR  PROFESORESXBLOQUE IS
select  UNIQUE BL.NOMBRE_PROFESOR
from    ADMISIONES.a_bloques_POS bl,ADMISIONES.ls_plantilla pl
where   bl.numero_documento=pl.cedula
AND     BL.CONSECUTIVO=V_CONSECUTIVO
AND     BL.NUMERO_DOCUMENTO>0/*
AND     PL.APROBADO_PLANTILLA='1'*/;

v_matriculados number default 0;
maxper  varchar2(6) default null;
v_semestres number default 0;
V_ANIO     varchar2(4) default null;
V_CICLO    varchar2(2) default null;
CICLO_REAL varchar2(2) default null;
PERMAX     varchar2(5) default null;
cadena   varchar2(100) default null;
v_nomarc admisiones.a_pdfs.nombre_archivo%type default null;
v_grupo  varchar2(2) default null;
hay_pdf_nvo       number      default 0;
v_nomarc_real  varchar2(256)                             default null;
v_parametro        varchar2(100)                             default null;
v_doc_id           documents.documents_new.documento_id%type;
v_parametros varchar2(100) default null;

begin
--htp.p('PINTA_HORARIOK_POSTGRADO');
--htp.p(V_CODIGO);


C_ACTUALIZAR_MATRICULADOS;
SELECT COUNT(1)
INTO   v_existe
FROM   a_horario_horizontal hh
WHERE  hh.codigo_facultad=v_codigo;
if v_existe>0 then

SELECT SUM(hh.matriculados),MAX(hh.anio||decode(hh.ciclo,'01','1','02','2')) permax
INTO   v_matriculados,permax
FROM   a_horario_horizontal hh;

--v_matriculados:=0;

V_ANIO:=SUBSTR(PERMAX,1,4);
V_CICLO:='0'||SUBSTR(PERMAX,5,1);
SELECT DECODE(V_CICLO,'01','I','02','II')
INTO   ciclo_real
FROM   DUAL;

htp.p('
<html>
<head>
<link href="/images/interna.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/jquery/js/jquery-1.11.1.min.js"></script>
</head>

<body bgcolor="white">
<center>
<table border="0" width="1500px">
<tr>
<td>
<p align="center">
HORARIOS DE CLASE '||CICLO_REAL||' PERIODO DE '||V_ANIO||'</b></font></BR>
<FONT color="red"><B>'||SYSDATE||'</B></FONT><BR>
');

htp.p('
</p>
</td>
</tr>
');
for v_datos1 in jornadas loop
v_jornada:=v_datos1.jornada;
htp.p('
<center>
<table border="1">
<tr>
<td colspan="22" bgcolor="#CFE5F2">
<p align="center"><b>'||v_datos1.nombre||'</b></p>
</td>
</tr>
');
for v_datos3 in semestres loop
    v_semestre:=v_datos3.semestre;
    htp.p('
    <tr>
    <td colspan="22 bgcolor="#E1E1E1"><p align="left">SEMESTRE: '||v_datos3.semestre||'</p>
    </td>
    </tr>
    ');
    htp.p('
    <tr>
        <td bgcolor="#EFEFF7">
            <p align="center">CODIGO</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">NOMBRE</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">GRUPO</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">H/S</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">CUPO INI.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">CUPO UTIL</p>
        </td>
        ');
        HTP.P('
        <td  bgcolor="#EFEFF7">
            <p align="center">MATRI.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">LUN.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">MAR.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">MIE.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">JUE.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">VIE.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">SAB.</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">NRO. SEMANAS</p>
        </td>
        ');



        HTP.P('
        <td  bgcolor="#EFEFF7">
            <p align="center">SYLLABUS</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">PROFESOR</p>
        </td>
        <td  bgcolor="#EFEFF7">
            <p align="center">PROFESOR TITULAR</p>
        </td>
    </tr>
    ');
      for v_datos2 in horario loop
      v_parametros := 'p_facultad='||v_codigo||'&p_materia='||v_datos2.codigo_materia||'&p_grupo='||v_datos2.grupo_materia||'';
      v_consecutivo:=v_datos2.consecutivo;
            htp.p('
            <tr>
            <td>
            ');
            --v_matriculados:=0;
            if v_matriculados>0 then
            cadena  := 'p_facultad='||v_codigo||'&p_materia='||v_datos2.codigo_materia||'&p_grupo='||v_datos2.grupo_materia||'';
            htp.p('
            <a href="javascript:ver_prematxgrupo('||''''||v_parametros||''''||')">'||v_datos2.codigo_materia||'</a></td>
            ');
            else
            htp.p('
            '||v_datos2.codigo_materia||'
            ');
            end if;
            htp.p('
            </td>
            <td>
                <p>'||v_datos2.nombre||'</p>
            </td>
            <td>
                <p>'||v_datos2.grupo_materia||'</p>
            </td>
            <td>
                <p>'||v_datos2.intensidad_horaria||'</p>
            </td>
            <td>
                <p>'||v_datos2.cupo||'</p>
            </td>
            <td>
                <p>'||v_datos2.cupo_utilizado||'</p>
            </td>
            ');
            --<td>
            --    <p>'||v_datos2.cupo_disponible||'</p>
            --</td>
            HTP.P('
            <td>
                <p>'||v_datos2.matriculados||'</p>
            </td>
            <td>
                <p>'||v_datos2.lunes||'</p>
            </td>
            <td>
                <p>'||v_datos2.martes||'</p>
            </td>
            <td>
                <p>'||v_datos2.miercoles||'</p>
            </td>
            <td>
                <p>'||v_datos2.jueves||'</p>
            </td>
            <td>
                <p>'||v_datos2.viernes||'</p>
            </td>
            <td>
                <p>'||v_datos2.sabado||'</p>
            </td>
            <td>
                <p>'||v_datos2.semanas||'</p>
            </td>
            ');



select count(*)
into   hay_pdf_nvo
from   documents.documents_new d
   where  d.codigo_facultad=v_facultad
   and    d.codigo_materia=v_datos2.codigo_materia
   and    d.grupo=v_datos2.grupo_materia
   and d.anio = v_anio
   and d.ciclo = v_ciclo;

if hay_pdf_nvo>0 then


   v_parametro:=v_facultad||v_datos2.codigo_materia||v_datos2.grupo_materia;
   htp.p('<td>');
   begin
       SELECT d.documento_id
       INTO   v_doc_id
       FROM   documents.documents_new d
       where  d.codigo_facultad=v_facultad
       and    d.codigo_materia=v_datos2.codigo_materia
       and    d.grupo=v_datos2.grupo_materia
       and    d.anio=v_anio
       and    d.ciclo=v_ciclo;
    exception
    when others then
        htp.p('<p style="color: red; font-weight: bold; font-size: 2em;">err (doc_new): ' || v_facultad || v_datos2.codigo_materia || v_datos2.grupo_materia || '</p>');
    end;
    begin
       SELECT  NVL(dc.nombre_original, dc.nombre)
       INTO    v_nomarc
       from    cti_documentos.cti_dc_documentos dc
       where   dc.id = v_doc_id;
    exception
    when others then
        v_nomarc:=null;
        htp.p('<p style="color: red; font-weight: bold; font-size: 2em;">err (cti_dc_doc): ' || v_doc_id || '</p>');
    end;
    if v_nomarc is not null then
        htp.p('<a href="javascript:enviar2('||''''||v_parametro||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_nomarc||'</a>');
    end if;
    htp.p('</td>');
    
    /*SELECT d.documento_id
    INTO v_doc_id
    FROM documents.documents_new d
    where  d.codigo_facultad=v_facultad
    and    d.codigo_materia=v_datos2.codigo_materia
    and    d.grupo=v_datos2.grupo_materia;

   SELECT  NVL(dc.nombre_original, dc.nombre)
   INTO v_nomarc
   from cti_documentos.cti_dc_documentos dc
   where dc.id = v_doc_id;

htp.p('
   <TD width="200" ALIGN="LEFT"><a href="javascript:enviar2('||''''||v_parametro||''''||')" onmouseover = "status= ''...''; return true" onmouseout="status = ''...'' "   onclick="status = ''...'' " >'||v_nomarc||'</a></TD>
    ');*/


   else
      htp.p('
      <TD width="200" ALIGN="LEFT">.</TD>
      ');
end if;


HTP.P('
<TD>
<TABLE  width="250">
<TR>
<td>
');
FOR V_DATOS IN PROFESORESXBLOQUE LOOP
htp.p('
'||v_datos.nombre_profesor||'<br>
');
END LOOP;
HTP.P('
</td>
</TR>
</TABLE>
</TD>
');

            HTP.P('
            <td>
                <p>'||v_datos2.nombre_profesor||'</p>
            </td>
            ');



      end loop;

end loop;
htp.p('
</table>
</center>
');
end loop;
htp.p('
</tr>
</table>
</center>
');

HTP.P('
<script>

function enviar2(parametro)
{

$.ajax({
   url: "/pls/pdfs/document_api.tokenDocumentoId",
   type: "POST",
   data: {
    parametro: parametro
   },
   success: function(data) {
     if (data.status == "ok") {
        document.formulario2.action = "https://jupiter.lasalle.edu.co:8181/GestionDocumentos/oar/documentos/descargarDocumento/" + data.token;
        document.formulario2.submit();
     }
   }
});


}
</script>
');
htp.p('
<form name="formulario2" method="get" target="_parent">
</form>
');


else
AVISO_GENERAL_FONDO_ROJO('AUN NO SE HAN INGRESADO HORARIOS','white');
end if;


END PINTA_HORARIOK_POSTGRADO;