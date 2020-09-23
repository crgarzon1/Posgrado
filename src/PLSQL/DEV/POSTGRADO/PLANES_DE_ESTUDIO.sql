create or replace Procedure PLANES_DE_ESTUDIOS(
    p_codigo_facultad   a_facultades.codigo%type,
    p_semestre number default -1,
    p_excel number default 0
)
IS
v_facultad_origen        a_materias.codigo_facultad%type    default null;
v_jornada_origen         a_materias.jornada_facultad%type   default null;
v_materia_origen         a_materias.codigo%type             default null;
v_requisito              a_requisitos.requisito%type        default null;
v_plan_origen            a_materias.plan_estudio%type       default null;
v_semestre_origen        a_materias.semestre%type           default null;
v_intensidad_origen      a_materias.intensidad_horaria%type default null;
v_creditos_origen        a_materias.creditos%type           default null;
v_nombre_materia_origen  a_materias.nombre%type             default null;
v_nombre_materia_requisito  a_materias.nombre%type             default null;
v_nombre_facultad        a_facultades.nombre%type           default null;
v_existe_origen          number default 0;
v_existe_destino         number default 0;
v_plan_char              varchar2(50) default null;
v_horti                  a_materias.hor_trabajo_independiente%type default null;
V_FACULTAD  A_FACULTADES.CODIGO%TYPE DEFAULT NULL;
V_PLAN     a_MATERIAS.Plan_Estudio%TYPE DEFAULT NULL;
V_JORNADA   A_MATERIAS.JORNADA_FACULTAD%TYPE DEFAULT NULL;
V_JORTEX    VARCHAR2(20);

CURSOR C_JORNADAS IS 
SELECT DISTINCT(M.JORNADA_FACULTAD) JORNADA
FROM   A_MATERIAS M
WHERE M.CODIGO_FACULTAD=P_CODIGO_FACULTAD;

CURSOR C_PLANES IS 
/*SELECT DISTINCT(M.PLAN_ESTUDIO) PLAN
FROM   A_MATERIAS M
WHERE  M.CODIGO_FACULTAD=P_CODIGO_FACULTAD
--AND    M.PLAN_ESTUDIO IN ('1','2','3','4','5','6','7','8')
--01APR2017
AND    M.PLAN_ESTUDIO IN(
SELECT PE.PLAN_ESTUDIO FROM A_PLANES_DE_ESTUDIO PE
WHERE  PE.CODIGO_FACULTAD=P_CODIGO_FACULTAD
)
ORDER  BY M.PLAN_ESTUDIO DESC;*/
SELECT * FROM (
SELECT DISTINCT(TO_NUMBER(M.PLAN_ESTUDIO)) PLAN
FROM   A_MATERIAS M
WHERE  M.CODIGO_FACULTAD=P_CODIGO_FACULTAD
--AND    M.PLAN_ESTUDIO IN ('1','2','3','4','5','6','7','8')
--01APR2017
AND    M.PLAN_ESTUDIO IN(
SELECT PE.PLAN_ESTUDIO FROM A_PLANES_DE_ESTUDIO PE
WHERE  PE.CODIGO_FACULTAD=P_CODIGO_FACULTAD
)
ORDER  BY TO_NUMBER(M.PLAN_ESTUDIO) ASC) X
ORDER BY X.PLAN DESC;



CURSOR C_PLANES_NODEF IS 
SELECT DISTINCT(M.PLAN_ESTUDIO) PLAN
FROM A_MATERIAS M
WHERE M.CODIGO_FACULTAD=P_CODIGO_FACULTAD
--AND M.PLAN_ESTUDIO NOT IN ('1','2','3','4','5','6','7','8');
--01APR2017
AND M.PLAN_ESTUDIO NOT IN (
SELECT PE.PLAN_ESTUDIO FROM A_PLANES_DE_ESTUDIO PE
WHERE  PE.CODIGO_FACULTAD=P_CODIGO_FACULTAD
);

cursor materias is
select * from a_materias m
where  m.codigo_facultad=p_codigo_facultad
and    m.jornada_facultad=V_JORNADA
and    m.plan_estudio=V_plan
order  by m.semestre,m.codigo;

cursor requisitos is
select * from a_requisitos r
where  r.codigo_facultad=p_codigo_facultad
and    r.jornada_facultad=V_jornada
and    r.codigo_materia=v_materia_origen
and    r.plan_estudio=V_plan
order by r.codigo_materia;

BEGIN
/*HTP.P('PLANES_DE_ESTUDIOS');
HTP.P(p_codigo_facultad);
HTP.P(V_jornada);
HTP.P(V_plan);*/




select nombre
into   v_nombre_facultad
from   ADMISIONES.A_Facultades_Unica FU
where  FU.CODIGO_FACULTAD=p_codigo_facultad;

htp.p('
<link href="/images/interna.css" rel="stylesheet" type="text/css">
  <center><font color="BLUE"><b>PROGRAMA: </B></FONT><font color="RED" ><b>'||V_NOMBRE_FACULTAD||'</B></FONT>
');

FOR V_DATOSJOR IN C_JORNADAS LOOP
    V_JORNADA:=V_DATOSJOR.JORNADA;
    SELECT DECODE(V_JORNADA,'D','DIURNA','N','NOCTURNA')
    INTO v_JORTEX
    FROM DUAL;
    HTP.P('
  <center><font color="BLUE"><b>JORNADA: </B></FONT><font color="RED"><b>'||V_JORTEX||'</B></FONT>
    ');

    
    
      FOR V_DATOSPLAN IN C_PLANES LOOP
          v_PLAN:=V_DATOSPLAN.PLAN;
          SELECT PE.DESCRIPCION
          INTO   v_plan_char
          FROM   A_PLANES_DE_ESTUDIO PE
          WHERE  PE.CODIGO_FACULTAD=p_codigo_facultad
          AND    PE.PLAN_ESTUDIO=V_plan;
          
          
          
          /*if V_plan='1' then
             v_plan_char:='ANTIGUO';
          end if;
          if V_plan='2' then
             v_plan_char:='MODERNIZACION';
          end if;
          if V_plan='3' then
             v_plan_char:='CREDITOS';
          end if;
          if V_plan='4' then
             v_plan_char:='CREDITOS-REDIMENSION';
          end if;
          if V_plan in('5','6','7') AND p_codigo_facultad NOT  IN('73') then
             v_plan_char:='REDIMENSION';
          end if;
          if V_plan in('5') AND p_codigo_facultad IN('73') then
             v_plan_char:='REDIMENSION-2014';
          end if;
          if V_plan='8' then
             v_plan_char:='REDIMENSION ACTUALIZADA';
          end if;*/
HTP.P('    
    <table  WIDTH="650">
  <center>
  <td colspan="7">
  <p align="center">
  <font color="BLUE" ><b>PLAN: </B></FONT><font color="RED"><b>'||V_PLAN_CHAR||'('||v_PLAN||')</B></FONT><BR>
  </p>
  </td>
  
  
                  <tr WIDTH="650">
                      <td width="10"   bgcolor="#EFEFF7">
                       <p align="left"><span style="font-size:8pt;"><B>SEMESTRE</B></span></p>
                      </td>
                      <td width="10"   bgcolor="#EFEFF7">
                          <p align="left"><span style="font-size:8pt;"><B>CODIGO</B></span></p>
                      </td>
                      <td width="250"   bgcolor="#EFEFF7">
                          <p align="left"><span style="font-size:8pt;"><B>NOMBRE ASIGNATURA</B></span></p>
                      </td>
                      ');
                       IF V_PLAN>=3 THEN
                         HTP.P('
                         <td width="10"   bgcolor="#EFEFF7">
                          <p align="center"><span style="font-size:8pt;"><B>CREDITOS</B></span></p>
                      </td>
                      ');
                      END IF;
                      HTP.P('
                      <td width="10"   bgcolor="#EFEFF7">
                          <p align="left"><span style="font-size:8pt;"><B>H.PRES.</B></span></p>
                      </td>
                      ');
                    
                    IF V_PLAN>=3 THEN
                    
                      HTP.P('
                     <td width="10"   bgcolor="#EFEFF7">
                          <p align="left"><span style="font-size:8pt;"><B>H.TRAB.IND.</B></span></p>
                      </td>
                      ');
                    END IF;  
             HTP.P('
             <td width="250"   bgcolor="#EFEFF7">
             <p align="center"><span style="font-size:8pt;"><b>PRERREQUISITOS</b></span></p>
             </td>
             </tr>
             ');
              for v_datos in materias loop
               v_materia_origen :=v_datos.codigo;
                  htp.p('
                   <tr>
                      <td width="10">
                       <p align="left"><span style="font-size:8pt;">'||v_datos.semestre||'</span></p>
                      </td>
                      <td width="10">
                          <p align="left"><span style="font-size:8pt;">'||v_datos.codigo||'</span></p>
                      </td>
                      <td width="250">
                          <p align="left"><span style="font-size:8pt;">'||v_datos.nombre||'</span></p>
                      </td>
                      ');
                      IF V_PLAN>=3 THEN
                            IF v_datos.CREDITOS IS NOT NULL THEN
                            HTP.P('
                           <td width="10">
                          <p align="center"><span style="font-size:8pt;">'||v_datos.creditos||'</span></p>
                            </td>
                            ');
                            ELSE 
                            HTP.P('
                           <td width="10"><B>.<B></td>
                            ');
                            END IF;
                    END IF;
               
                    HTP.P('       
                     <td width="10">
                          <p align="left"><span style="font-size:8pt;">'||V_datos.intensidad_horaria||'</span></p>
                      </td>
                      ');
                      IF V_PLAN>=3 THEN
                            IF v_datos.hor_trabajo_independiente IS NOT NULL THEN
                            HTP.P('
                           <td width="10">
                               <p align="left"><span style="font-size:8pt;">'||v_datos.hor_trabajo_independiente||'</span></p>
                            </td>
                            ');
                            ELSE 
                            HTP.P('
                           <td width="10"><B>.</B></td>
                            ');
                            END IF;
                    END IF;
                      select count(*)
                      into   v_existe_origen
                      from   a_requisitos r
                      where  r.codigo_facultad=p_codigo_facultad
                      and    r.jornada_facultad=v_jornada
                      and    r.codigo_materia=v_datos.codigo
                      and    r.plan_estudio=v_plan;
                      if v_existe_origen=0 then
                         v_requisito:='.';
                         htp.p('
                         <td width="250">
                         <p align="left"><span style="font-size:8pt;">'||v_requisito||'</span></p>
                         </td>
                         ');
                         else
                            htp.p('
                            <td width="250">
                            ');
                           for v_requisitos in requisitos loop
                                       select m.nombre
                                       into   v_nombre_materia_requisito
                                       from   a_materias m
                                       where  m.codigo_facultad=v_requisitos.codigo_facultad
                                       and    m.jornada_facultad=v_requisitos.jornada_facultad
                                       and    m.codigo=v_requisitos.requisito;
                                       v_requisito:=v_requisitos.requisito;
                                       htp.p('
                                       <p style="line-height:100%; margin-top:0; margin-bottom:0;"><span style="font-size:8pt;"><B>'||v_requisito||'-'||v_nombre_materia_requisito||'</B><br></span></p>
                                       ');
                                    end loop;
                            
                            htp.p('
                            </td>
                            ');
                          end if;
                      htp.p('
                  </tr>
                  ');       
              end loop;
              
            END LOOP;
            
            HTP.P('
              </TABLE>
              ');


      FOR V_DATOSPLAN_NODEF IN C_PLANES_NODEF LOOP
      v_PLAN:=V_DATOSPLAN_NODEF.PLAN;
      v_plan_char:='NO DEFINIDO/ANTERIORES';
                    
          HTP.P('    
              <table  WIDTH="650">
            <center>
              <td colspan="7">
  <p align="center">
  <font color="BLUE" ><b>PLAN: </B></FONT><font color="RED"><b>'||V_PLAN_CHAR||'</B></FONT><BR>
  </p>
  </td>

                            <tr WIDTH="650"   bgcolor="#EFEFF7">
                                <td width="10"   bgcolor="#EFEFF7">
                                 <p align="left"><span style="font-size:8pt;"><B>SEMESTRE</B></span></p>
                                </td>
                                <td width="10"   bgcolor="#EFEFF7">
                                    <p align="left"><span style="font-size:8pt;"><B>CODIGO</B></span></p>
                                </td>
                                <td width="250"   bgcolor="#EFEFF7">
                                    <p align="left"><span style="font-size:8pt;"><B>NOMBRE ASIGNATURA</B></span></p>
                                </td>
                                ');
                                 IF V_PLAN>=3 THEN
                                   HTP.P('
                                   <td width="10"   bgcolor="#EFEFF7">
                                    <p align="center"><span style="font-size:8pt;"><B>CREDITOS</B></span></p>
                                </td>
                                ');
                                END IF;
                                HTP.P('
                                <td width="10"   bgcolor="#EFEFF7">
                                    <p align="left"><span style="font-size:8pt;"><B>H.PRES.</B></span></p>
                                </td>
                                ');
                              
                              IF V_PLAN>=3 THEN
                              
                                HTP.P('
                               <td width="10"   bgcolor="#EFEFF7">
                                    <p align="left"><span style="font-size:8pt;"><B>H.TRAB.IND.</B></span></p>
                                </td>
                                ');
                              END IF;  
/*                       HTP.P('
                       <td width="250"   bgcolor="#EFEFF7">
                       <p align="center"><span style="font-size:8pt;"><b>PRERREQUISITOS</b></span></p>
                       </td>
                       </tr>
                       ');
*/                      for v_datos in materias loop
                       v_materia_origen :=v_datos.codigo;
                          htp.p('
                           <tr>
                              <td width="10">
                               <p align="left"><span style="font-size:8pt;">'||v_datos.semestre||'</span></p>
                              </td>
                              <td width="10">
                                  <p align="left"><span style="font-size:8pt;">'||v_datos.codigo||'</span></p>
                              </td>
                              <td width="250">
                                  <p align="left"><span style="font-size:8pt;">'||v_datos.nombre||'</span></p>
                              </td>
                              ');
                              IF V_PLAN>=3 THEN
                                    IF v_datos.CREDITOS IS NOT NULL THEN
                                    HTP.P('
                                   <td width="10">
                                  <p align="center"><span style="font-size:8pt;">'||v_datos.creditos||'</span></p>
                                    </td>
                                    ');
                                    ELSE 
                                    HTP.P('
                                   <td width="10"><B>.<B></td>
                                    ');
                                    END IF;
                            END IF;
                       
                            HTP.P('       
                             <td width="10">
                                  <p align="left"><span style="font-size:8pt;">'||V_datos.intensidad_horaria||'</span></p>
                              </td>
                              ');
                              IF V_PLAN>=3 THEN
                                    IF v_datos.hor_trabajo_independiente IS NOT NULL THEN
                                    HTP.P('
                                   <td width="10">
                                       <p align="left"><span style="font-size:8pt;">'||v_datos.hor_trabajo_independiente||'</span></p>
                                    </td>
                                    ');
                                    ELSE 
                                    HTP.P('
                                   <td width="10"><B>.</B></td>
                                    ');
                                    END IF;
                            END IF;
                              select count(*)
                              into   v_existe_origen
                              from   a_requisitos r
                              where  r.codigo_facultad=p_codigo_facultad
                              and    r.jornada_facultad=v_jornada
                              and    r.codigo_materia=v_datos.codigo
                              and    r.plan_estudio=v_plan;
/*                              if v_existe_origen=0 then
                                 v_requisito:='.';
                                 htp.p('
                                 <td width="250">
                                 <p align="left"><span style="font-size:8pt;">'||v_requisito||'</span></p>
                                 </td>
                                 ');
                                 else
                                    htp.p('
                                    <td width="250">
                                    ');
                                   for v_requisitos in requisitos loop
                                               select m.nombre
                                               into   v_nombre_materia_requisito
                                               from   a_materias m
                                               where  m.codigo_facultad=v_requisitos.codigo_facultad
                                               and    m.jornada_facultad=v_requisitos.jornada_facultad
                                               and    m.codigo=v_requisitos.requisito;
                                               v_requisito:=v_requisitos.requisito;
                                               htp.p('
                                               <p style="line-height:100%; margin-top:0; margin-bottom:0;"><span style="font-size:8pt;"><B>'||v_requisito||'-'||v_nombre_materia_requisito||'</B><br></span></p>
                                               ');
                                  end loop;
                                    
                                    htp.p('
                                    </td>
                                    ');
                                  end if;
*/                              htp.p('
                          </tr>
                          ');       
                      end loop;
              
            END LOOP;
            
            HTP.P('
              </TABLE>
     <hr>    
              ');
      

  
                         
END LOOP;

-----------------------
htp.p('
</table>
</center>
</body>
</html>
');
htp.p('   
</CENTER> 
<!--p align="center"><input type="submit"  value="<-REGRESAR" onclick=history.go(-1)></td-->
<center>
');


END PLANES_DE_ESTUDIOS;