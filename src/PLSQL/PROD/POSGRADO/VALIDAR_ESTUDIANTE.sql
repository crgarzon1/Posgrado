set define off;
create or replace procedure validar_estudiante
(p_usuario varchar default null,
 p_clave   varchar default null,
 p_codest  varchar default null,
 p_opcion  varchar default null,
 p_boton   varchar default null
)
is
v_plan_estudio b_estudiantes.plan_estudio%type default null;
v_existe_usuario    number      default 0;
v_existe_estudiante number      default 0;
v_codigo b_estudiantes.codigo%type default null;
v_codfac varchar2(2) default substr(p_codest,1,2);

v_esextranjero        number default 0;
v_aviso1_extranjeros varchar2(1000);
v_aviso2_extranjeros varchar2(1000);
v_aviso3_extranjeros varchar2(1000);
v_aviso4_extranjeros varchar2(1000);
v_aviso1_evaluaciones varchar2(1000);
V_Aviso2_Evaluaciones Varchar2(1000);
V_FUE_REINTEGRO     number default 0;

v_debedocext1       number default 0;
v_debedocext2       number default 0;
v_debedocext3       number default 0;
VPDOCUEX     VARCHAR2(1000) DEFAULT NULL;

V_facultad varchar2(2) default null;
v_hizo_evaluacion              varchar2(250);--Esta variable me indica si el estudinte ya hizo o no evaluacion de profesores
v_debe_evaluar number default 0;
v_indicador_pago b_estudiantes.indicador_pago%type default null;
v_mensaje varchar2(300) default null;
v_tipoest            varchar2(7) default null;
v_anio b_estudiantes.anio%type default null;
v_ciclo b_estudiantes.ciclo%type default null;
v_indpago           b_estudiantes.matriculados_ciclo_anterior%type default null;
v_planestudio b_estudiantes.plan_estudio%type default null;
v_debe_documento number default 0;
VPDOCUMENTOS VARCHAR2(500) DEFAULT NULL;
v_link1 number default 0;
v_link2 number default 0;
v_link3 number default 0;
v_link4 number default 0;
v_link5 number default 0;
v_link6 number default 0;
v_encuesta_ant    number default 0;
v_fecha_iniciori          DATE DEFAULT NULL;
v_fecha_finalizacionri    DATE DEFAULT NULL;
v_ciclo_ingre             b_estudiantes.ciclo_de_ingreso%type default null;
v_tipo_ingreso            b_estudiantes.tipo_de_ingreso%type default null;
v_cicloNEW varchar2(5)       default null;

v_indicador_pago         b_estudiantes.indicador_pago%type default null;
v_ciclo_de_ingreso       b_estudiantes.ciclo_de_ingreso%type default null;
v_tipo_de_ingreso        b_estudiantes.tipo_de_ingreso%type default null;
VPACTDAT     VARCHAR2(1000) DEFAULT NULL;
v_ultimo_ciclo_cursado         varchar2(6)  default null;
v_inicio                       number default 0;
v_final                        number default null;--controlar ciclos de reintegros
v_no_matriculado               number default 0;
v_cancelo_despues              number default 0;
v_egresado                     number default 0;
v_solicito_reintegro           number default 0;
v_ciclo_nuevos varchar2(5) default  null;
v_jornada_actual               b_estudiantes.jornada_facultad%type default null;
v_jornada_solicitada           varchar2(10) default NULL;
v_jornada_aprobada             a_solicitud_reintegro.jornada_aprobada%type default null;
v_jornada_aprobada_char        varchar2(30) default null;
v_fecha_concepto_facultad      date default null;
v_fecha_concepto_vrac          date default null;
v_concepto_vrac                a_solicitud_reintegro.concepto_vrac%type default null;
V_TIPO_REINTEGRO A_SOLICITUD_REINTEGRO.TIPO_REINTEGRO%TYPE DEFAULT NULL;
v_plan_reintegro               a_solicitud_reintegro.plan_estudio%type default null;
v_aviso_reintegros1            a_fechas_de_corte.aviso_reintegros1%type default null;
v_aviso_reintegros2            a_fechas_de_corte.aviso_reintegros2%type default null;
v_aviso_reintegros3            a_fechas_de_corte.aviso_reintegros2%type default null;
v_aviso_reintegros4            a_fechas_de_corte.aviso_reintegros4%type default null;
v_aviso_reintegros5            a_fechas_de_corte.aviso_reintegros5%type default null;
v_aviso_reintegros6            a_fechas_de_corte.aviso_reintegros6%type default null;
v_sinplan  number default 0;
v_fecha_publicacion_reintegros a_fechas_de_corte.fecha_finalizacion%type default null;
v_existe_plan                  number default 0;
v_plan_caracter                A_PLANES_DE_ESTUDIO.DESCRIPCION%TYPE DEFAULT NULL;
v_encuesta_ri           number default 0;
v_contacto              admisiones.directorio_programas.contacto%type default null;
v_telefono              admisiones.directorio_programas.telefono%type default null;
V_NUMDOC  DATOS_PERSONALES.NUMERO_DOCUMENTO%TYPE DEFAULT NULL;
p_codigo b_estudiantes.codigo%type default null;
v_tiene_datosper                   number default 0;
v_encuesta                         number default 0;
v_existe_prematricula           number default 0;
v_encod                  varchar2(256) default null;
v_granfac                varchar2(2) default null;
begin
/*HTP.P(p_opcion);
HTP.P(p_opcion);
HTP.P(p_opcion);
HTP.P(p_opcion);
HTP.P(p_opcion);
HTP.P(p_opcion);*/



select fc.Ciclo_Nuevos_Ri,fc.fecha_inicio,fc.fecha_finalizacion,fc.aviso_reintegros1,fc.aviso_reintegros2,fc.aviso_reintegros3,fc.aviso_reintegros4,fc.aviso_reintegros5,fc.aviso_reintegros6
into   v_final,v_fecha_iniciori,v_fecha_finalizacionri,v_aviso_reintegros1,v_aviso_reintegros2,v_aviso_reintegros3,v_aviso_reintegros4,v_aviso_reintegros5,v_aviso_reintegros6
from   a_fechas_de_corte fc
where  rtrim(SUBSTR(fc.proceso,1,20))='REINTEGROS POSTGRADO';

select fc.fecha_inicio
into   v_fecha_publicacion_reintegros
from   a_fechas_de_corte fc
where  substr(fc.proceso,1,32)='PUBLICACION REINTEGROS APROBADOS';


--LOS TRES CASOS
v_aviso1_extranjeros:='A la fecha su Visa, Cedula de Extranjeria y Autorizacion para adelantar estudios en la universidad se encuentran vencidos. Recuerde que la renovacion de estos documentos debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalizacion de los estudios y la obtencion del titulo respectivo. De lo contrario no podra inscribir las asignaturas correspondientes al I periodo de 2009.\nPara renovar la autorizacion debe acercarse a la Oficina de Admisiones y Registro la cual le expedira una constancia de estudio y una fotocopia de la Personeria Juridica de la Universidad, dicho tramite debe realizarlo en el Ministerio de Relaciones Exteriores en la Cra. 13 No. 93-68 Of.203 Coordinacion de Visas e Inmigracion.\nUna vez realizados los tramites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
--ESTE AVISO ES SOLO PARA AUTORIZACION
v_aviso2_extranjeros:='A la fecha su Autorizacion para adelantar estudios en la universidad se encuentra vencida. Recuerde que la renovacion de esta autorizacion debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalizacion de los estudios y la obtencion del titulo respectivo. De lo contrario no podra inscribir las asignaturas correspondientes al I periodo de 2009.\nPara renovar la autorizacion debe acercarse a la Oficina de Admisiones y Registro la cual le expedira una constancia de estudio y una fotocopia de la Personeria Juridica de la Universidad, dicho tramite debe realizarlo en el Ministerio de Relaciones Exteriores en la Cra. 13 No. 93-68 Of.203 Coordinacion de Visas e Inmigracion.\nUna vez realizados los tramites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
--ESTE AVISO ES SOLO PARA VISA
v_aviso3_extranjeros:='A la fecha su Visa se encuentra vencida. Recuerde que la renovacion de este documento debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalizacion de los estudios y la obtencion del titulo respectivo. De lo contrario no podra inscribir las asignaturas correspondientes al I periodo de 2009.\nDebe acercarse a la Oficina de Admisiones y Registro donde se le entregara carta informativa.\nUna vez realizados los tramites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';
--ESTE AVISO ES SOLO PARA CEDULA
v_aviso4_extranjeros:='A la fecha su Cedula de Extranjeria se encuentra vencida. Recuerde que la renovacion de este documento debe tramitarse antes de su vencimiento y las veces que sea necesario hasta la finalizacion de los estudios y la obtencion del titulo respectivo. De lo contrario no podra inscribir las asignaturas correspondientes al I periodo de 2009.\nDebe acercarse a la Oficina de Admisiones y Registro donde se le entregara carta informativa.\nUna vez realizados los tramites debe entregar fotocopia a la Oficina de Admisiones y Registro, Sede Chapinero Cra. 5 No. 59A - 44, Edificio Administrativo, en el horario de 8:00 a.m. a 12 m. y de 2:00 p.m. a 6:00 p.m.';


--v_aviso1_evaluaciones:='Usted primero debe realizar la evaluación a sus profesores para consultar sus notas, ingrese por  el portal de estudiantes donde dice: Evaluación a Profesores. Su participación es importante para la Institución.';
v_aviso2_evaluaciones:='Si le aparece una página con el siguiente mensaje:''''Existe un problema con el certificado de seguridad de este sitio web''''. por favor seleccione la opción:''''Vaya a este sitio web (no recomendado)''''.Para que le cargue el listado de profesores  a evaluar';
v_aviso1_evaluaciones:='Usted primero debe realizar la evaluación a sus profesores para consultar sus notas, ingrese por la página principal de La Universidad donde dice: Evaluación a Profesores. Su participación es importante para la Institución.';



SELECT  COUNT(1)
INTO    v_existe_usuario
FROM    admisiones.a_usuarios u
WHERE   u.usuario=p_usuario and u.clave=p_clave;
if v_existe_usuario>0 then



   SELECT u.codigo
   INTO   v_codigo
   FROM   admisiones.v_usuarios u
   WHERE  UPPER(u.usuario) = UPPER(p_usuario) 
   AND    UPPER(u.clave) = UPPER(p_clave);
   
   p_codigo:=v_codigo;
   
   
SELECT count(*)
INTO   V_TIENE_DATOSPER
FROM   DATOS_PERSONALES DP
WHERE  DP.CODIGO_ESTUDIANTE=p_CODIGO;
IF   V_TIENE_DATOSPER>0 THEN
SELECT DP.NUMERO_DOCUMENTO
INTO   V_NUMDOC
FROM   DATOS_PERSONALES DP
WHERE  DP.CODIGO_ESTUDIANTE=p_CODIGO;
END IF;

   If p_codest!=v_codigo then
      htp.p('
      <script>
      alert("Usuario y/o clave no registrado.");
      top.history.back();
      </script>
      ');
      ELSE
         SELECT COUNT(1)
         INTO   v_existe_estudiante
         FROM   b_estudiantes be
         WHERE  be.codigo=p_codest;
         if v_existe_estudiante>0 then
               SELECT be.plan_estudio
               INTO   v_plan_estudio
               FROM   b_estudiantes be
               WHERE  be.codigo=p_codest;       

---------------------------------------
             if p_opcion='CERTIFICADOS' then
    --AVISO_GENERAL_FONDO_GRIS('IR A APLICACION DE MARIANO DE SOLICITUDES DE CERTIFICADOS.........','navy');
    htp.p('
    <body onLoad="enviar()" background="white" bgcolor="white" text="black" link="blue" vlink="purple" alink="red">
    <form name="ensayo" action="http://oar.lasalle.edu.co:8085/certificaciones/indexEstudiante.jsp" method="post">
    <input type=hidden name=cod  value='||p_codest||'>
    </form>
    <SCRIPT>
    function enviar()
    {
    document.ensayo.submit();
    }
    </SCRIPT>
    ');
             ELSif p_opcion='consulta_general' then
                --HTP.P('...');
                consulnotas(p_codest);
             elsif p_opcion='estudio_academico' then
                   estudio_posgrados_V2(p_codest,p_usuario);
             elsif p_opcion='actualizar_datos' then
                   cti_act_datos_personales();

elsIF upper(p_opcion) ='FORMATO_QSR' then
      barra_iso(p_codest);


             elsif p_opcion='consultar_horario' then
                --HTP.P('UNO');
                PINTA_HORARIOK_POSTGRADO_EST(V_codFAC);
                v_facultad:='02';
                --HTP.P('DOS');
                PINTA_HORARIOK_HUMPOST_EST(v_facultad);
-----------------------------------------------------------------------------------------------------------------------------                
            elsif p_opcion='guia_ttd' then
                cti_guia_matricula();
            Elsif P_Opcion='imprimir_guias' Then
                /*SELECT COUNT(*)
                INTO   V_FUE_REINTEGRO
                From   G_Guias_De_Pago Gp
                WHERE  GP.ANIO||GP.CICLO IN('201201','201202','201301','201302','201401','201402','201501','201502','201601')
                AND    GP.COD_TRANSAC IN('03','13')
                AND    GP.CODIGO_EST=p_codigo;*/
                
                Select (
                SELECT COUNT(*)
                FROM   G_GUIAS_DE_PAGO GP
                WHERE  /*GP.ANIO||GP.CICLO IN('201201','201202','201301','201302','201401','201402','201501','201502','201601','201602','201701','201702')
                And*/  Gp.Cod_Transac In('03','13')
                And    Gp.Codigo_Est=P_Codigo
                )
                +
                (
                Select Count(*)
                From   B_Estudiantes B 
                Where  B.Anio||To_Number(B.Ciclo) = B.Ciclo_De_Ingreso 
                and    B.Tipo_De_Ingreso in ('RI','RA')
                And    B.Codigo=P_Codigo
                ) Into V_Fue_Reintegro
                from dual;
                
                V_Fue_Reintegro:=0;
                If V_Fue_Reintegro>0 Then
                  aviso_general_fondo_rojo('Apreciado Estudiante: Por favor ingresar nuevamente por esta opción el día 7 Julio de 2016.','white');
                ELSE
                select be.matriculados_ciclo_anterior,be.ciclo_de_ingreso||be.tipo_de_ingreso,be.anio,substr(be.ciclo,2,1)
                into   v_indpago,v_tipoest,v_anio,v_ciclo
                from   b_estudiantes be
                where  be.codigo=p_codest;
                select count(*)
                into   v_encuesta_ant
                from   a_satisfaccion_antiguos sa
                where  sa.cod_def=p_codest;
                
                SELECT COUNT(*)
                INTO   v_debe_documento
                FROM   doc_estudiante de
                WHERE  de.codigo_estudiante=p_codest
                AND    de.estado = 'NO'
                AND    DE.CODIGO_DOCUMENTO IN ('1','2');
                
                --MODIFICADO EL 02FEB2012 PARA GENERAR UNA GUIA EXTRAORDINARIA
                --IF P_CODEST='81082210' THEN
                --v_indpago:='P';
                --END IF;
                
                v_encuesta_ant:=1;
                if (v_indpago in ('P','V') OR v_tipoest in(v_anio||v_ciclo||'RI') OR  v_tipoest in(v_anio||v_ciclo||'RA') OR  v_tipoest in(v_anio||v_ciclo||'TE') OR  v_tipoest in(v_anio||v_ciclo||'NR')) then 
                   if v_encuesta_ant>0 then--inicio encuesta
                      if v_debe_documento>0 then--inicio documentos
                         VPDOCUMENTOS:=REVISAR_DOCUMENTOS(p_codest,v_mensaje);
                         PINTA_RESULTADO(VPDOCUMENTOS,'RED');
                         Else
                         cti_frame_guias_antiguos(p_codest);
                            --v_mensaje:='Apreciado Estudiante: Usted podrá descargar su guia de matrícula a partir del próximo lunes 18 de enero de 2016 a las 2:00 pm.';
                            --alerta(v_mensaje);
                      end if;--fin documentos
                      else
                      encuesta_satisfaccion_antiguos(p_codest);
                   end if;--fin encuesta
                   else
                   v_mensaje:='No estuvo matriculado en el ciclo anterior.';
                   alerta(v_mensaje);
                End If;
                end if;
                --------------------------------------------------------------------
                
                --if v_indpago in ('P','V') AND SUBSTR(p_codest,1,2) IN('DE') THEN
                --   frame_guias_antiguos(p_codest);
                --END IF;
                
                
                
                elsif p_opcion='evaldoc' then
                VENTANA_EVALUACION_ESTUDIANTES(P_CODEST);



/*                elsif p_opcion='imprimir_guias' then
                select be.matriculados_ciclo_anterior,be.ciclo_de_ingreso||be.tipo_de_ingreso,be.anio,substr(be.ciclo,2,1)
                into   v_indpago,v_tipoest,v_anio,v_ciclo
                from   b_estudiantes be
                where  be.codigo=p_codest;          
                if (v_indpago in ('P','V') OR v_tipoest in(v_anio||v_ciclo||'RI')OR  v_tipoest in(v_anio||v_ciclo||'RA')) then 
                   --frame_guias_antiguos(p_codest);
                    SELECT COUNT(*)
                    INTO   v_debe_documento
                    FROM   doc_estudiante de
                    WHERE  de.codigo_estudiante=p_codest
                    AND    de.estado = 'NO'
                    AND    DE.CODIGO_DOCUMENTO IN ('1','2');
                    if v_debe_documento>0 then
                       VPDOCUMENTOS:=REVISAR_DOCUMENTOS(p_codest,v_mensaje);
                       PINTA_RESULTADO(VPDOCUMENTOS,'RED');
                       else
                          ACTUALIZAR_DOCUMENTO_GUIASV2(p_codest);
                    end if;
                   ELSE
                   v_mensaje:='No estuvo matriculado en el ciclo anterior.';
                   alerta(v_mensaje);
                end if;*/
-----------------------------------------------------------------------------------------------------------------------------                
                elsif p_opcion='solicitud_reintegro' then
   VPACTDAT:=REVISAR_ACTDAT(v_codigo,V_MENSAJE);
   VPACTDAT:='OK';
   IF VPACTDAT='OK' THEN
       select NVL(max(n.ano||decode(n.ciclo,'01','01','03','02')),0)
       into   v_ultimo_ciclo_cursado
       from   a_notas n
       where  n.codigo_estudiante=p_codest
       and    n.ciclo in('01','03');
       v_inicio:=to_number(substr(v_ultimo_ciclo_cursado,1,4))*2+to_number(substr(v_ultimo_ciclo_cursado,5,2));
       v_final:=to_number(substr(v_final,1,4))*2+to_number(substr(v_final,5,2));
       v_no_matriculado    :=existe_nomatriculado(p_codest);
       v_cancelo_despues   :=existe_cancelo_despues(p_codest);
       v_egresado          :=ADMISIONES.existe_egresado(p_codest);
       v_solicito_reintegro:=existe_reintegro(p_codest);
       --htp.p(v_ultimo_ciclo_cursado||'<br>');
       --htp.p(v_ciclo_de_ingreso||'<br>');
       --htp.p(v_tipo_de_ingreso||'<br>');
       --htp.p(v_final||'<br>');
       --htp.p(v_inicio);
       select fc.Ciclo_Nuevos_Ri
       into   v_ciclo_nuevos
       from   a_fechas_de_corte fc
       where  rtrim(SUBSTR(fc.proceso,1,20))='REINTEGROS POSTGRADO';

       IF  v_solicito_reintegro>0 THEN
           select sr.jornada_actual,sr.jornada_solicitada,DECODE(sr.jornada_aprobada,'D','DIURNA','N','NOCTURNA') jornada_aprobada,sr.fecha_concepto_facultad,sr.fecha_concepto_vrac,sr.concepto_vrac,SR.TIPO_REINTEGRO,SR.PLAN_ESTUDIO,SR.JORNADA_APROBADA
           into   v_jornada_actual,v_jornada_solicitada,v_jornada_aprobada_char,v_fecha_concepto_facultad,v_fecha_concepto_vrac,v_concepto_vrac,V_TIPO_REINTEGRO,V_PLAN_REINTEGRO,V_JORNADA_APROBADA
           from   a_solicitud_reintegro sr
           where  sr.codigo_estudiante=p_codest;
       END IF;
       IF to_char(sysdate,'YYYYMMDD') BETWEEN TO_CHAR(v_fecha_iniciori,'YYYYMMDD') AND TO_CHAR(v_fecha_finalizacionri,'YYYYMMDD')THEN      
          if (v_no_matriculado>0 or  v_cancelo_despues>0) then
          
              SELECT COUNT(*)
              INTO   v_egresado
              FROM   RELACION_PYS_EGRESADO PE
              WHERE  PE.CODIGO_ESTUDIANTE=p_codest;
              
          
             if v_egresado=0 then
                if v_ultimo_ciclo_cursado=0 then
                   aviso_general_fondo_rojo('USTED CANCELO SEMESTRE EN TAL CASO EL ASPIRANTE TENDRA QUE VOLVER A COMENZAR LA CARRERA Y REALIZAR EL PROCESO DE ADMISION COMO ESTUDIANTE NUEVO.','white');
                   else   
                      if (v_final-v_inicio)<=4 THEN
                         if v_solicito_reintegro>0 then
                            --YA HIZO LA SOLICITUD DE REINTEGRO
                            aviso_general_fondo_azul(v_aviso_reintegros1,'WHITE');
                            atras;
                            else
                               --HACE SU SOLICITUD DE REINTEGRO POR PRIMERA VEZ
                               FORM_DATOS_PERSONALES2(p_usuario,p_clave,p_codest,'1');
                               atras;
                         end if;
                         else
                            aviso_general_fondo_rojo('SU SOLICITUD DE REINTEGRO NO PUEDE SER REGISTRADA, TENIENDO EN CUENTA QUE USTED DEJÓ DE RENOVAR SU MATRÍCULA POR MÁS DE (CUATRO) 04 PERÍODOS ACADÉMICOS SEMESTRALES EN LA UNIVERSIDAD, Y <br>DE ACUERDO CON LO ESTABLECIDO EN EL ARTÍCULO 18, PARÁGRAFO 1 DEL REGLAMENTO ESTUDIANTÍL DE POSTGRADO.<br> COMUNÍQUESE CON SU UNIDAD ACADÉMICA PARA MAYOR INFORMACIÓN.','WHITE');
                            informes_facultad_art11(v_codfac,'N');
                      end if;
                end if;   
             else
               --ES EGRESADO NO GRADUADO ART11
               if v_solicito_reintegro>0 then
                  aviso_general_fondo_azul(v_aviso_reintegros3,'WHITE');
                  atras;
                  else
                  if (v_final-v_inicio)<=8 THEN
                      FORM_DATOS_PERSONALES2(p_usuario,p_clave,p_codest,'2');
                      atras;
                      else
                      aviso_general_fondo_rojo('SU SOLICITUD DE REINTEGRO NO PUEDE SER REGISTRADA, TENIENDO EN CUENTA QUE USTED DEJÓ DE RENOVAR SU MATRÍCULA POR MÁS DE (OCHO) 08 PERÍODOS ACADÉMICOS SEMESTRALES EN LA UNIVERSIDAD, Y <br>DE ACUERDO CON LO ESTABLECIDO EN EL ARTÍCULO 19, DEL REGLAMENTO ESTUDIANTÍL DE POSTGRADO.<br> COMUNÍQUESE CON SU UNIDAD ACADÉMICA PARA MAYOR INFORMACIÓN.','WHITE'); 
                      informes_facultad_art11(v_codfac,'N');
                  end if;    
               end if;
         end if;
      end if;
      else
      select count(*)
      into   v_sinplan
      from   a_solicitud_reintegro sr
      where  substr(codigo_estudiante,1,2)=substr(p_codest,1,2)
      and    sr.plan_estudio is null;
      --plan
      if v_sinplan=0 then
          --SE VENCIERON LAS FECHAS DE INSCRIPCION ENTONCES MIRA SI LA FECHA DE PUBLICACION DE RESULTADOS ESTA VIGENTE
          --fechas
           if to_char(sysdate,'RRRRMMDD')>=TO_CHAR(v_fecha_publicacion_reintegros,'RRRRMMDD') then
              IF V_PLAN_REINTEGRO IS NOT NULL THEN
                  v_existe_plan:=existe_plan(substr(p_codest,1,2),SUBSTR(v_jornada_aprobada_CHAR,1,1),v_plan_reintegro);
                  if v_existe_plan>0 then
                      select pe.descripcion
                      into   v_plan_caracter 
                      from   a_planes_de_estudio pe
                      where  pe.codigo_facultad=substr(p_codest,1,2)
                      and    pe.jornada_facultad=SUBSTR(v_jornada_aprobada_CHAR,1,1)
                      and    pe.plan_estudio=v_plan_reintegro;
                  else
                  v_plan_caracter:='NO DISPONIBLE';
                  end if;
              END IF;
              --RIART11
              IF V_TIPO_REINTEGRO IS NOT NULL THEN
                 IF v_plan_reintegro is not null THEN
                  alerta(v_aviso_reintegros2);
                  atras;
                 END IF; 
              END IF;   
              IF V_TIPO_REINTEGRO IS NULL THEN
                select dp.contacto,dp.telefono
                into   v_contacto,v_telefono
                from   admisiones.directorio_programas dp
                where  dp.codigo_facultad=v_codfac;
                AVISO_GENERAL_FONDO_GRIS('Su reintegro fue aprobado. Pongase en contacto con: '||v_contacto||' al: <br>'||v_telefono||' para la inscripción de materias. Usted podrá imprimir su guía de matrícula a partir del 16 de diciembre de 2011 a partir de las 4:00 p.m.','navy');
                 if v_plan_reintegro is not null then
                     if v_encuesta_ri=0 then
                        -----------------------------------------------------------------
                        v_encuesta_ri:=1;
                        --21-NOV-2009
                        --encuesta_satisfaccion_RI(p_codest);
                        -----------------------------------------------------------------                        
                        else
                          alerta(SUBSTR(v_aviso_reintegros5,1,54)||v_jornada_aprobada_char||SUBSTR(v_aviso_reintegros5,55,22)||v_plan_caracter||SUBSTR(v_aviso_reintegros5,78,300));
                     end if;   
                 end if;  
              END IF;
           --NO ESTA DENTRO DE LAS FECHAS DE PUBLICACION DE RESULTADOS
           else
              aviso_general_fondo_azul('AUN NO SE HAN PUBLICADO RESULTADOS DE SU SOLICITUD!!!','WHITE');
              atras;
           end if; 
      --sin plan       
      else
                      select dp.contacto,dp.telefono
                into   v_contacto,v_telefono
                from   admisiones.directorio_programas dp
                where  dp.codigo_facultad=v_codfac;
        aviso_general_fondo_azul('Pongase en contacto con: '||v_contacto||' al: <br>'||v_telefono||' para solicitar más información.','WHITE');
     END IF;
   END IF;
   ELSE
   AVISO_GENERAL_FONDO_ROJO(VPACTDAT,'WHITE');
   ATRAS_CENTRADO;
   END IF;
-----------------------
 ELSIF p_opcion='cambiocon' then
    v_encod:=xamplecripto(p_codigo,'3764613438353137');
htp.p('
<!DOCTYPE html>
<html>
    <head>
        <title>Registro Preguntas de Seguridad</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="http://estudiantes.lasalle.edu.co/modules/mod_modalpopup/css/lasalle/jquery-ui-1.10.0.custom.min.css" type="text/css" />
        <link rel="stylesheet" href="http://estudiantes.lasalle.edu.co/modules/mod_modalpopup/css/mod_modalpopup.css" type="text/css" />
        <script src="http://estudiantes.lasalle.edu.co/modules/mod_modalpopup/js/jquery-1.9.0.js" type="text/javascript"></script>
        <script src="http://estudiantes.lasalle.edu.co/modules/mod_modalpopup/js/jquery-ui-1.10.0.custom.min.js" type="text/javascript"></script>
        <script type="text/javascript">
            jQuery.noConflict();

            function getValue(valor, ancho) {
                if (valor.indexOf("%") > 0) {
                    valor = valor.substring(0, valor.indexOf("%"));
                    valor = Math.ceil((ancho ? jQuery(window).width() : jQuery(window).height()) * valor / 100);
                    if (valor < 510 && ancho) {
                        return 510;
                    } else if (valor < 430 && !ancho) {
                        return 430;
                    }
                }
                return valor;
            }

            jQuery(document).ready(function () {
                var n = jQuery("#mod_modalpopup_dialog").length;
                if (n <= 0) {
                    jQuery("body").append(''<div id="mod_modalpopup_dialog"></div>'');
                    jQuery("#mod_modalpopup_dialog").html("");
                    jQuery("#mod_modalpopup_dialog").hide();
                }
                var url = "http://tigris.lasalle.edu.co:8080/changepassword/?enc='||v_encod||'";
                var alto = getValue("80%", false);
                var ancho = getValue("80%", true);
                var titulo = "Correo Universitario - Preguntas de Seguridad";
                var onclose = "http://tigris.lasalle.edu.co:8080/changepassword/close.xhtml";;
                jQuery("#mod_modalpopup_dialog").html("<div style=\"width: 100%; height: 100%; overflow: hidden; color: #FFF; text-align: center;\"><iframe src=\"" + url + "\" frameborder=\"0\" style=\"height: 100%; width: 100%; border: none;\"><p>Your browser does not support iframes.</p><iframe></div>");
                jQuery("#mod_modalpopup_dialog").dialog({
                    height: Math.floor(alto * 1.2),
                    width: Math.floor(ancho * 1.1),
                    modal: false,
                    resizable: false,
                    title: titulo,
                    beforeClose: function(event, ui) {
                        if (onclose) {
                            jQuery("#mod_modalpopup_dialog").html("");
                            jQuery("#mod_modalpopup_dialog").html("<iframe src=\"" + onclose + "\" height=\"" + alto + "px\" width=\"" + ancho + "px\" frameborder=\"0\" style=\"border: none;\"><p>Your browser does not support iframes.</p><iframe>");
                            history.back(1);
                        }
                        
                    }
                });
            });
        </script>
    </head>
    <body>
    </body>
</html>
');




                  elsif p_opcion='elecciones' then
                   /*IF substr(p_codest,1,2) in('85') then
                      admisiones.estad85;
                   END IF;
                   IF substr(p_codest,1,2) IN('76','77','78') THEN
                      admisiones.ESTAD767778;
                   END IF;*/
                   
      if substr(p_codigo,1,2) in('80','81','83') then
        v_granfac:='AC';
     end if;
     if substr(p_codigo,1,2) in('90','87','76','77','86','89','EP','DA','78') then
        v_granfac:='CA';
     end if;
     if substr(p_codigo,1,2) in('92','84','75','95','85','MY','DE') then
        v_granfac:='CE';
     end if;
     if substr(p_codigo,1,2) in('97') then
        v_granfac:='CH';
     end if;
     if substr(p_codigo,1,2) in('79') then
        v_granfac:='CS';
     end if;
     if substr(p_codigo,1,2) in('98','93','88','74','96','72','82') then
        v_granfac:='ES';
     end if;
     if substr(p_codigo,1,2) in('MI','94','91') then
        v_granfac:='IN';
     end if;
     if substr(p_codigo,1,2) in('73') then
        v_granfac:='FH';
     end if;
     ESTADPRE_FACULTADES(v_granfac);              
     
                   
                   
                   
             elsif p_opcion='notas_parciales' then
                  SELECT COUNT(*) 
                  INTO   v_existe_prematricula
                  FROM   b_prematricula_notas_depurada bpd
                  WHERE  bpd.codigo_estudiante=p_codigo;

                    select count(*)
                    into   v_encuesta
                    from   A_SATISFACCION_ESTUDIANTES sa
                    where  sa.codigo=p_codigo;
                    v_encuesta:=1;
                   v_esextranjero:=existe_extranjero(p_codest);
                    if v_esextranjero>0 then
                       VPDOCUEX:=REVISAR_DOCEXTRANJERO(p_codest);
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
                    --SE BLOQUE POR MANTENIMIENTO DE SERVIDOR EN CTI
                    SELECT siis.validar_consulta_estudiante@uvirtual.lasalle.edu.co(p_codest) 
                    into   v_hizo_evaluacion
                    FROM   dual;    
                 IF v_hizo_evaluacion not in ('S') THEN
                       alerta(v_hizo_evaluacion);
                       --alerta(v_hizo_evaluacion);
                       ELSE  
                    if v_existe_prematricula>0 then
                     if  v_encuesta=0 then
                     v_mensaje:='Para que pueda consultar sus notas parciales, debe diligenciar la encuesta de satisfacción';
                     VENTANA_EVALOAR_ESTUDIANTES(p_codigo);
                     end if;      
                     null;
                     end if;
                          SELECT tipo_de_ingreso
                          into   v_tipo_de_ingreso
                          FROM   B_estudiantes
                          WHERE  codigo=p_codest;    
                          --HTP.P(V_TIPO_DE_INGRESO);
                          if V_TIPO_DE_INGRESO NOT IN ('RA','AR','NR') THEN
                         
                            insert into ADMISIONES.a_entradas_consulnotas
                            values(p_codest,sysdate);
                            commit;
                             ls_ensayo(p_codest); 
                             htp.p('
                             <HR color="red">
                             ');
                          END IF;
                          if V_TIPO_DE_INGRESO IN ('RA','AR','NR') THEN
                            insert into ADMISIONES.a_entradas_consulnotas
                            values(p_codest,sysdate);
                            commit;
                             LS_ensayo_art11(p_codest); 
         
                             htp.p('
                             <HR color="red">
                             ');
                          END IF;
                   end if;          
---------------------------------------------------
ELSIF upper(p_opcion) ='BIB_LINK1' then
/*htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://proquest.umi.com/login/refurl" method="post">
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
}
</SCRIPT>
</form>
');*/

htp.p('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post">
<input type="hidden" value="PROQUESTALL2" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
//javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 
SELECT COUNT(*)
INTO   v_LINK1
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link1=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4)
    VALUES (p_codigo,1,0,0,sysdate,NULL,NULL,0,NULL);
    COMMIT;
    ELSE
      SELECT db.link1+1
      INTO   v_link1
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      
      UPDATE a_descargas_biblioteca db
      SET    db.link1=v_link1,db.fecha1=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
END IF;     
ELSIF upper(p_opcion) ='BIB_LINK2' then
/*htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://site.ebrary.com/lib/bibliounisallesp" method="post">
<SCRIPT>
function enviar() 

{
document.ensayo.submit();  
}
</SCRIPT>
</form>
'); */  


htp.p('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post">
<input type="hidden" value="ELIBRO" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
//javascript:history.go(-1);
}
</SCRIPT>
</form>
');        

SELECT COUNT(*)
INTO   v_link2
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link2=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4)
    VALUES (p_codigo,0,1,0,null,sysdate,NULL,0,NULL);
    COMMIT;
    ELSE
      SELECT db.link2+1
      INTO   v_link2
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      
      UPDATE a_descargas_biblioteca db
      SET    db.link2=v_link2,db.fecha2=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
END IF;     



ELSIF upper(p_opcion) ='BIB_LINK3' then
/*htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://search.ebscohost.com/login.aspx?authtype=url" method="post">
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
}
</SCRIPT>
</form>
'); */  
htp.p('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post">
<input type="hidden" value="EBSCOHOST" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
//javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 
       
SELECT COUNT(*)
INTO   v_link3
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link3=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4)
    VALUES (p_codigo,0,0,1,null,null,sysdate,0,NULL);
    COMMIT;
    ELSE
      SELECT db.link3+1
      INTO   v_link3
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      
      UPDATE a_descargas_biblioteca db
      SET    db.link3=v_link3,db.fecha3=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
END IF;     

ELSIF upper(p_opcion) ='BIB_LINK4' then
/*htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://site.ebrary.com/lib/bibliounisalle" method="post">
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
}
</SCRIPT>
</form>
'); */   
htp.p('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post">
<input type="hidden" value="EBRARY" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
//javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 
      
SELECT COUNT(*)
INTO   v_link4
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link4=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4)
    VALUES (p_codigo,0,0,0,null,null,null,1,sysdate);
    COMMIT;
    ELSE
      SELECT db.link4+1
      INTO   v_link4
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      
      UPDATE a_descargas_biblioteca db
      SET    db.link4=v_link4,db.fecha4=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
END IF;     

ELSIF upper(p_opcion) ='BIB_LINK5' then
htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
 <form name="ensayo" action="http://tigris.lasalle.edu.co/dwis3/cgi/tegra.pl" method="post">  
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
}
</SCRIPT>
</form>
');          


 

SELECT COUNT(*)
INTO   v_link5
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link5=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4,LINK5,FECHA5,LINK6,FECHA6)
    VALUES (P_codigo,0,0,0,null,Null,null,0,NULL,1,sysdate,0,NULL);
    COMMIT;
    ELSE
      SELECT NVL(db.link5,0)+1
      INTO   v_link5
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      UPDATE a_descargas_biblioteca db
      SET    db.link5=v_link5,db.fecha5=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
    
END IF; 
ELSIF upper(p_opcion) ='BIB_LINK6' then
htp.p('xxx');
htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://biblioteca.lasalle.edu.co/media/public/restauracion_dspace2.html" method="get">
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
}
</SCRIPT>
</form>
');   

ELSIF upper(p_opcion) ='BIB_LINK7' then
htp.p('7-compendex');




htp.p('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="COMPENDEX" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
');   

ELSIF upper(p_opcion) ='BIB_LINK8' then
htp.p('8-embase');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="EMBASE" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
');   
ELSIF upper(p_opcion) ='BIB_LINK9' then
htp.p('9-multilegis');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="LEGISMOVIL" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 

ELSIF upper(p_opcion) ='BIB_LINK10' then
htp.p('10-reaxys');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="REAXYS" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 

ELSIF upper(p_opcion) ='BIB_LINK11' then
htp.p('11-sciencieDirect');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="SCIENCEDIRECT" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 
ELSIF upper(p_opcion) ='BIB_LINK12' then
htp.p('12-scopus');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="SCOPUS" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 

ELSIF upper(p_opcion) ='BIB_LINK13' then
htp.p('13-WISERTRADE');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="WISERTRADE" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 

ELSIF upper(p_opcion) ='BIB_LINK16' then
htp.p('16-THOMSONGALE');
HTP.P('
<body onLoad="enviar()">
<form name="ensayo" action="https://jupiter.lasalle.edu.co/wrapperlibrary/AuthenticateUser" method="post" target="_blank">
<input type="hidden" value="THOMSONGALE" name="lbrname"  />
<input type="hidden" value="E" name="tipoUsuario" />
<input type="hidden" value='||V_NUMDOC||' name="documento" />
<input type="hidden" value='||P_CODIGO||' name="codigo" />
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
'); 

      
ELSIF upper(p_opcion) ='BIB_LINK14' then
htp.p('14-tegra-misalle');
htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://repository.lasalle.edu.co/tegra/" method="get" target="_blank">
<SCRIPT>
function enviar() 
{
document.ensayo.submit();  
javascript:history.go(-1);
}
</SCRIPT>
</form>
');   

ELSIF upper(p_opcion) ='BIB_LINK15' then
htp.p('15-sibbila');
htp.p('
<body background="/images/rg_10_002.jpg" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<h1>"Por favor espere unos momentos........"</h1>
<body onLoad="enviar()" bgcolor="aqua" text="black" link="blue" vlink="purple" alink="red">
<form name="ensayo" action="http://biblioch1.lasalle.edu.co/janium-bin/janium_login_opac.pl" method="get" target="_blank">
<SCRIPT>
function enviar() 
{
document.ensayo.submit(); 
javascript:history.go(-1); 
}
</SCRIPT>
</form>
');   




/*SELECT COUNT(*)
INTO   v_link6
FROM   a_descargas_biblioteca db
WHERE  db.codigo=P_codigo;
IF v_link6=0 THEN
    INSERT INTO A_DESCARGAS_BIBLIOTECA (CODIGO,  LINK1,LINK2,LINK3,FECHA1,FECHA2,FECHA3,LINK4,FECHA4, LINK5,FECHA5,LINK6,FECHA6)
    VALUES (p_codigo,0,0,0,null,Null,null,0,sysdate,0,NULL,1,sysdate);
    COMMIT;
    ELSE
      SELECT NVL(db.link6,0)+1
      INTO   v_link6
      FROM   a_descargas_biblioteca db
      WHERE  db.codigo=P_CODigo;
      
      UPDATE a_descargas_biblioteca db
      SET    db.link6=v_link6,db.fecha6=sysdate
      WHERE  db.codigo=P_CODigo;
      COMMIT;
END IF; */

----------------------------------------------------

----------------------------------------------------
    ELSIF upper(p_opcion) ='VOTACIONES' THEN
    --htp.p('!!!!!!!!!!!');
    TARJETON(p_codest);
    --admisiones.estadpre(substr(p_codest,1,2));
    --aviso_general_fondo_azul('Este pendiente de los resultados de las elecciones por este mismo medio.','white');
    
           ELSIF p_opcion ='consulta_prematricula'  then
               SELECT be.plan_estudio
               INTO   v_planestudio
               FROM   b_estudiantes be
               WHERE  be.codigo=p_codest;       
               IF v_planestudio < '3' THEN
                 --b_consulta_prematricula_bak(p_codest);
                  B_CONSULTA_CREDITOS_bak(p_codest);
               ELSE
                 B_CONSULTA_CREDITOS_bak(p_codest);
               END IF;      
             else
                 htp.p('opcion no registrada');     
            end if;      
-----------------------------------------


            else
              htp.p('
              <script>
              alert("Codigo estudiantil no registrado.");
              top.history.back();
              </script>
              ');
         end if;
   END IF;          
   else
        htp.p('
        <script>
        alert("Codigo estudiantil no registrado.");
        top.history.back();
        </script>
        ');
END IF; 

end validar_estudiante;