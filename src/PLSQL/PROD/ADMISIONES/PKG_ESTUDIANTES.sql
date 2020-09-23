create or replace package body pkg_estudiantes
as
    function getCodigoLibre(
            p_programa a_facultades.codigo%type,
            p_anio  varchar2,
            p_ciclo varchar2)
        return varchar2
    as
        v_codigo b_estudiantes.codigo%type;
        v_i number := 0;
    begin
        for cod in (
            select to_number(substr(st.codigo_transfer,6,3)) x
            from a_solicitud_transferencias st
            where st.cod_facultad_solicitada = p_programa
            and st.codigo_transfer is not null
            and st.anio = p_anio
            and st.ciclo = p_ciclo
            union
            select to_number(substr(t.cod_def,6,3)) x
            from a_aspirantes t
            where
            t.codigo_facultad = p_programa
            and t.anio = p_anio
            and t.ciclo = p_ciclo
            and t.cod_def is not null
            union
            select to_number(substr(t.cod_def,6,3)) x
            from a_historico_aspiroracle t
            where
            t.codigo_facultad = p_programa
            and t.anio = p_anio
            and t.ciclo = p_ciclo
            and t.cod_def is not null
            union
            select to_number(substr(e.codigo,6,3)) x
            from b_estudiantes e
            where
            e.codigo_facultad  = p_programa
            and e.ciclo_de_ingreso = p_anio || to_number(p_ciclo)
            and e.tipo_de_ingreso not in ('RI')
            /*and e.anio = p_anio
            and e.ciclo = p_ciclo*/
            order by 1
        ) loop
            if cod.x != v_i then
                v_codigo := p_programa || substr(p_anio, 3, 2) || to_number(p_ciclo) || trim(to_char(v_i, '000'));
                exit;
            else
                v_i := v_i + 1;
            end if;
        end loop;
        if v_codigo is null then
            v_codigo := p_programa || substr(p_anio, 3, 2) || to_number(p_ciclo) || trim(to_char(v_i, '000'));
        end if;
        if v_i > 999 then
            raise_application_error(-20001, 'Codigo fuera de rango: ' || v_i);
        end if;
        if not regexp_like(v_codigo, '^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$') then
            raise_application_error(-20002, 'Codigo mal formado: ' || v_codigo);
        end if;
        return(v_codigo);
    exception
    when others then
        raise;
    end getCodigoLibre;
    function getObjEstudiante(
            p_codigo b_estudiantes.codigo%type)
        return json
    as
        v_est b_estudiantes%rowtype;
        v_est_p postgrado.b_estudiantes%rowtype;
        --v_est_y yopal.b_estudiantes%rowtype;
        v_est_old a_graduados%rowtype;
        j_est json := json();
        j_fac json;
    begin
        if length(p_codigo) < 8 then
            select *
            into v_est_old
            from a_graduados gr
            where trim(gr.codigo_estudiante) = p_codigo;
            json.put(j_est,'codigo',trim(v_est_old.codigo_estudiante));
            json.put(j_est,'nombre',v_est_old.nombre);
            json.put(j_est,'codigo_facultad',v_est_old.codigo_facultad);
            json.put(j_est,'jornada_facultad','D');
        elsif substr(p_codigo, 0, 2) < '71' and substr(p_codigo, 0, 2) not in ('46') then
            select *
            into v_est
            from b_estudiantes e
            where e.codigo = p_codigo;
            json.put(j_est,'codigo',v_est.codigo);
            json.put(j_est,'nombre',v_est.nombre);
            json.put(j_est,'ciclo_de_ingreso',v_est.ciclo_de_ingreso);
            json.put(j_est,'tipo_de_ingreso',v_est.tipo_de_ingreso);
            json.put(j_est,'graduado',v_est.graduado);
            json.put(j_est,'codigo_facultad',v_est.codigo_facultad);
            json.put(j_est,'jornada_facultad',v_est.jornada_facultad);
            json.put(j_est,'indicador_pago',v_est.indicador_pago);
            json.put(j_est,'promedio_acumulado',v_est.promedio_acumulado);
            json.put(j_est,'matriculados_ciclo_anterior',v_est.matriculados_ciclo_anterior);
            json.put(j_est,'plan_estudio',v_est.plan_estudio);
            json.put(j_est,'materias_pendientes',v_est.materias_pendientes);
            json.put(j_est,'promedio_ponderado',v_est.promedio_ponderado);
            json.put(j_est,'anio',v_est.anio);
            json.put(j_est,'ciclo',v_est.ciclo);
            json.put(j_est,'porcred_aprobado',v_est.porcred_aprobado);
            j_fac := getObjFacultad(v_est.codigo_facultad,v_est.jornada_facultad);
            if j_fac is not null then
                json.put(j_est,'programa',j_fac);
            end if;
        elsif substr(p_codigo, 0, 2) >= '71' then
            select *
            into v_est_p
            from postgrado.b_estudiantes e
            where e.codigo = p_codigo;
            json.put(j_est,'codigo',v_est_p.codigo);
            json.put(j_est,'nombre',v_est_p.nombre);
            json.put(j_est,'ciclo_de_ingreso',v_est_p.ciclo_de_ingreso);
            json.put(j_est,'tipo_de_ingreso',v_est_p.tipo_de_ingreso);
            json.put(j_est,'graduado',v_est_p.graduado);
            json.put(j_est,'codigo_facultad',v_est_p.codigo_facultad);
            json.put(j_est,'jornada_facultad',v_est_p.jornada_facultad);
            json.put(j_est,'indicador_pago',v_est_p.indicador_pago);
            json.put(j_est,'promedio_acumulado',v_est_p.promedio_acumulado);
            json.put(j_est,'matriculados_ciclo_anterior',v_est_p.matriculados_ciclo_anterior);
            json.put(j_est,'plan_estudio',v_est_p.plan_estudio);
            json.put(j_est,'materias_pendientes',v_est_p.materias_pendientes);
            json.put(j_est,'promedio_ponderado',v_est_p.promedio_ponderado);
            json.put(j_est,'anio',v_est_p.anio);
            json.put(j_est,'ciclo',v_est_p.ciclo);
            j_fac := getObjFacultad(v_est_p.codigo_facultad,v_est_p.jornada_facultad);
            if j_fac is not null then
                json.put(j_est,'programa',j_fac);
            end if;
        elsif substr(p_codigo, 0, 2) = '46' then
            raise_application_error(-20009,'Yopal no implementado: ' || p_codigo);
        else
            raise_application_error(-20009,'Tipo errado de estudiante: ' || p_codigo);
        end if;
        return j_est;
    exception
    when others then
        return null;
    end getObjEstudiante;
    function getObjFacultad(
            p_codigo a_facultades.codigo%type,
            p_jornada a_facultades.jornada%type)
        return json
    as
        v_fac a_facultades%rowtype;
        j_fac json := json();
    begin
        select *
        into v_fac
        from a_facultades f
        where f.codigo = p_codigo
        and f.jornada = p_jornada;
        json.put(j_fac,'codigo',v_fac.codigo);
        json.put(j_fac,'jornada',v_fac.jornada);
        json.put(j_fac,'nombre',trim(v_fac.nombre));
        json.put(j_fac,'sede',v_fac.sede);
        json.put(j_fac,'abreviatura',v_fac.abreviatura);
        json.put(j_fac,'abrir_inscripcion',v_fac.abrir_inscripcion);
        json.put(j_fac,'activa',v_fac.activa);
        json.put(j_fac,'indicador',v_fac.indicador);
        return j_fac;
    exception
    when others then
        return null;
    end getObjFacultad;
    procedure getPersona(
        p_tipo_documento varchar2,
        p_numero_documento varchar2
    ) is
        v_codigo datos_personales.codigo_estudiante%type;
        cursor c_codigos is
        select dp.codigo_estudiante as codigo from datos_personales dp where dp.codtipo_documento = p_tipo_documento and dp.numero_documento = p_numero_documento
        union
        select dp.codigo_estudiante as codigo from postgrado.datos_personales dp where dp.codtipo_documento = p_tipo_documento and dp.numero_documento = p_numero_documento;
    begin
        owa_util.mime_header('application/json', false, 'utf-8');
        owa_util.http_header_close;
        for p in (
            select
                td.tipo as tipodoc, dp.numero_documento, dp.primer_nombre, dp.segundo_nombre, dp.primer_apellido, dp.segundo_apellido
            from
                datos_personales dp
                    inner join
                a_tipo_documento td
                    on dp.codtipo_documento = td.codigo
            where
                td.codigo = p_tipo_documento
                and dp.numero_documento = p_numero_documento
            union
            select
                td.tipo as tipodoc, dp.numero_documento, dp.primer_nombre, dp.segundo_nombre, dp.primer_apellido, dp.segundo_apellido
            from
                postgrado.datos_personales dp
                    inner join
                a_tipo_documento td
                    on dp.codtipo_documento = td.codigo
            where
                td.codigo = p_tipo_documento
                and dp.numero_documento = p_numero_documento
            order by 1,2
        ) loop
            htp.prn('{');
            htp.prn('"tipoDoc":"' || p.tipodoc || '",');
            htp.prn('"numDoc":"' || p.numero_documento || '",');
            htp.prn('"primerNombre":"' || pkg_utils.acentos(p.primer_nombre) || '",');
            htp.prn('"segundoNombre":"' || pkg_utils.acentos(p.segundo_nombre) || '",');
            htp.prn('"primerApellido":"' || pkg_utils.acentos(p.primer_apellido) || '",');
            htp.prn('"segundoApellido":"' || pkg_utils.acentos(p.segundo_apellido) || '",');
            htp.prn('"codigos":[');
            begin
                open c_codigos;
                loop fetch c_codigos into v_codigo;
                    if c_codigos%found and c_codigos%rowcount > 1 then
                        htp.prn(',');
                    end if;
                    exit when c_codigos%notfound;
                    htp.prn('"' || v_codigo || '"');
                end loop;
                close c_codigos;
            exception
            when others then
                close c_codigos;
            end;
            htp.prn(']');
            htp.prn('}');
            exit;
        end loop;
    exception
    when others then
        htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
    end getPersona;
    procedure getEstudiante(
        p_codigo b_estudiantes.codigo%type,
        p_dp number default 0
    ) as
        v_est b_estudiantes%rowtype;
        v_dp datos_personales%rowtype;
        v_codigo_contrario b_estudiantes.codigo%type;
        j_est json := json();
        j_dp json;
        v_respuesta json := json();
    begin
        owa_util.mime_header('application/json', false, 'utf-8');
        owa_util.http_header_close;
        j_est := getObjEstudiante(p_codigo);
        if j_est is null then
            raise_application_error(-20001,'Estudiante no encontrado');
        end if;
        v_codigo_contrario := b_prematricula_spring.f_get_codigo_contrario(p_codigo,null,null);
        if v_codigo_contrario is not null then
            json.put(j_est,'contrario',getObjEstudiante(v_codigo_contrario));
        end if;
        if p_dp = 1 then
            j_dp := json();
            select *
            into v_dp
            from datos_personales p
            where p.codigo_estudiante = p_codigo;
            json.put(j_dp,'fecha_actualizacion',to_char(v_dp.fecha_actualizacion, 'RRRR/MM/DD HH24:MI:SS'));
            json.put(j_dp,'codtipo_documento',v_dp.codtipo_documento);
            json.put(j_dp,'nombre_documento',v_dp.nombre_documento);
            json.put(j_dp,'numero_documento',v_dp.numero_documento);
            json.put(j_dp,'coddepto_documento',v_dp.coddepto_documento);
            json.put(j_dp,'departamento_documento',v_dp.departamento_documento);
            json.put(j_dp,'codmuni_documento',v_dp.codmuni_documento);
            json.put(j_dp,'ciudad_documento',v_dp.ciudad_documento);
            json.put(j_dp,'coddepto_nacimiento',v_dp.coddepto_nacimiento);
            json.put(j_dp,'departamento_nacimiento',v_dp.departamento_nacimiento);
            json.put(j_dp,'codmuni_nacimiento',v_dp.codmuni_nacimiento);
            json.put(j_dp,'ciudad_nacimiento',v_dp.ciudad_nacimiento);
            json.put(j_dp,'fecha_nacimiento',to_char(v_dp.fecha_nacimiento,'RRRR/MM/DD'));
            json.put(j_dp,'codestado_civil',v_dp.codestado_civil);
            json.put(j_dp,'estado_civil',v_dp.estado_civil);
            json.put(j_dp,'coddepto_residencia',v_dp.coddepto_residencia);
            json.put(j_dp,'departamento_residencia',v_dp.departamento_residencia);
            json.put(j_dp,'codmuni_residencia',v_dp.codmuni_residencia);
            json.put(j_dp,'ciudad_residencia',v_dp.ciudad_residencia);
            json.put(j_dp,'direccion',v_dp.direccion);
            json.put(j_dp,'barrio',v_dp.barrio);
            json.put(j_dp,'telefono_casa',v_dp.telefono_casa);
            json.put(j_dp,'telefono_oficina',v_dp.telefono_oficina);
            json.put(j_dp,'telefono_otro',v_dp.telefono_otro);
            json.put(j_dp,'email',v_dp.email);
            json.put(j_dp,'otro_email',v_dp.otro_email);
            json.put(j_dp,'codestrato_servicios',v_dp.codestrato_servicios);
            json.put(j_dp,'estrato_servicios',v_dp.estrato_servicios);
            json.put(j_dp,'fecha_actualizacion_oar',to_char(v_dp.fecha_actualizacion_oar, 'RRRR/MM/DD HH24:MI:SS'));
            json.put(j_dp,'codigo_facultad',v_dp.codigo_facultad);
            json.put(j_dp,'jornada_facultad',v_dp.jornada_facultad);
            json.put(j_dp,'sexo',v_dp.sexo);
            json.put(j_dp,'cod_eps',v_dp.cod_eps);
            json.put(j_dp,'nombre_eps',v_dp.nombre_eps);
            json.put(j_dp,'coddepto_eps',v_dp.coddepto_eps);
            json.put(j_dp,'departamento_eps',v_dp.departamento_eps);
            json.put(j_dp,'codmuni_eps',v_dp.codmuni_eps);
            json.put(j_dp,'ciudad_eps',v_dp.ciudad_eps);
            json.put(j_dp,'primer_apellido',v_dp.primer_apellido);
            json.put(j_dp,'segundo_apellido',v_dp.segundo_apellido);
            json.put(j_dp,'primer_nombre',v_dp.primer_nombre);
            json.put(j_dp,'segundo_nombre',v_dp.segundo_nombre);
            json.put(j_est,'dp',j_dp);
        end if;
        json.htp(j_est,false);
    exception
    when no_data_found then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje','Estudiante no encontrado');
        json.htp(v_respuesta,false);
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getEstudiante;
    procedure salvarDP(
        p in nclob)
    is
        data_c json;
        p_codigo b_estudiantes.codigo%type;
        p_facultad a_facultades.codigo%type;
        p_jornada a_facultades.jornada%type;
        p_plan b_estudiantes.plan_estudio%type;
        v_cumple number;
        v_est_origen b_estudiantes%rowtype;
        v_codigo_nuevo b_estudiantes.codigo%type;
        v_codigo_dp b_estudiantes.codigo%type;
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_respuesta json := json();
        ------------------------------------------------------------------------
        v_graduado b_estudiantes.graduado%type default 'N';
        v_documento b_estudiantes.documento%type default '0';
        v_indicador_pago b_estudiantes.indicador_pago%type default 'X';
        v_semestre b_estudiantes.semestre%type default null;
        v_semestre_inferior b_estudiantes.semestre_inferior%type default null;
        v_articulo11 b_estudiantes.articulo11%type default '.';
        v_promedio_ponderado b_estudiantes.promedio_ponderado%type default 0;
        v_codmil b_estudiantes.codmil%type default null;
        v_tipoest b_estudiantes.tipo_de_ingreso%type default 'DT';
        ------------------------------------------------------------------------
        v_dp datos_personales%rowtype;
        v_dp_id number;
        ------------------------------------------------------------------------
        p_usuario varchar2(16);
        p_clave varchar2(16);
        p_documento varchar2(32);
        v_cod varchar2(32);
        p_nombre varchar2(512);
    begin
        owa_util.mime_header('application/json', false, 'utf-8');
        owa_util.http_header_close;
        pkg_utils.p_leer_cookie(p_usuario, p_clave, p_documento, v_cod, p_nombre);
        if v_cod not in ('005','007','802') then
            raise_application_error(-20000, 'Usuario no autorizado: ' || p_nombre);
        end if;
        data_c := json(p);
        p_codigo := data_c.get('codigo').get_string;
        p_facultad := data_c.get('facultad').get_string;
        p_jornada := data_c.get('jornada').get_string;
        p_plan := data_c.get('plan').get_string;
        if substr(p_codigo,0,2) = p_facultad then
            raise_application_error(-20001,'Mismo programa...');
        end if;
        cumpleDP(p_codigo);
        pkg_utils.getAnioCiclo(p_codigo, v_anio, v_ciclo);
        select *
        into v_est_origen
        from b_estudiantes e
        where e.codigo = p_codigo;
        v_codigo_nuevo := getCodigoLibre(p_facultad, v_anio, v_ciclo);
        v_codmil := substr(v_codigo_nuevo,1,2)||'2'||substr(v_codigo_nuevo,3,6);
        insert
        into b_estudiantes
            (
                codigo,
                nombre,
                apellidos,
                nombres,
                ingles,
                sexo,
                ciclo_de_ingreso,
                sistemas,
                tipo_de_ingreso,
                graduado,
                codigo_facultad,
                jornada_facultad,
                indicador_pago,
                semestre,
                articulo11,
                promedio_ponderado,
                plan_estudio,
                codmil,
                semestre_inferior,
                anio,
                ciclo,
                documento
            )
            values
            (
                v_codigo_nuevo,
                v_est_origen.nombre,
                v_est_origen.apellidos,
                v_est_origen.nombres,
                v_est_origen.ingles,
                v_est_origen.sexo,
                v_anio || to_number(v_ciclo),
                v_est_origen.sistemas,
                v_tipoest,
                v_graduado,
                p_facultad,
                p_jornada,
                v_indicador_pago,
                v_semestre,
                v_articulo11,
                v_promedio_ponderado,
                p_plan,
                v_codmil,
                v_semestre_inferior,
                v_anio,
                v_ciclo,
                v_anio || v_ciclo || v_tipoest
            );
        begin
            select *
            into v_dp
            from datos_personales p
            where p.codigo_estudiante = p_codigo;
            v_dp.codigo_estudiante := v_codigo_nuevo;
            v_dp.codigo_facultad := p_facultad;
            v_dp.jornada_facultad := p_jornada;
        exception
        when no_data_found then
            raise_application_error(-20001,'Sin datos personales registrados.');
        end;
        insert into datos_personales values v_dp;
        v_dp_id := seq_estudiante_dp.nextval;
        insert into cti_doble_programa values (v_dp_id, p_codigo, null);
        insert into cti_doble_programa values (seq_estudiante_dp.nextval, v_codigo_nuevo, v_dp_id);
        commit;
        begin
            execute immediate
                'begin estudio_academico_p' || p_plan || 'p' || p_plan || '(:fac,:jor,:cod); end;'
            using
                p_facultad, p_jornada, v_codigo_nuevo;
            subir_notas.conteo_materias_pendientes(v_codigo_nuevo);
        exception
        when others then
            raise_application_error(-20001,'Se creo el codigo, pero el estudio academico fallo: ' || v_codigo_nuevo || ' ' || sqlerrm);
        end;
        json.put(v_respuesta,'status','ok');
        json.put(v_respuesta,'mensaje',v_codigo_nuevo);
        json.htp(v_respuesta,false);
    exception
    when others then
        rollback;
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end salvarDP;
    procedure getPlanes(
            p_facultad a_facultades.codigo%type,
            p_jornada a_facultades.jornada%type)
    as
        v_respuesta json := json();
        v_list json_list := json_list();
        v_pl json;
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        for pl in (
            select p.plan_estudio, p.descripcion || ' (' || p.descripcion_ri || ')' as pestudio
            from a_planes_de_estudio p where
            p.codigo_facultad=p_facultad
            and p.jornada_facultad=p_jornada
            order by 1, 2
        ) loop
            v_pl := json();
            json.put(v_pl,'id',pl.plan_estudio);
            json.put(v_pl,'nombre',pl.pestudio);
            json_list.append(v_list,v_pl.to_json_value);
        end loop;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getPlanes;
    procedure cumpleDP(
            p_codigo b_estudiantes.codigo%type)
    as
        v_cod_dp b_estudiantes.codigo%type;
        v_ca b_estudiantes.matriculados_ciclo_anterior%type;
        v_cre number;
        v_prom number;
        v_pru number;
    begin
        v_cod_dp := b_prematricula_spring.f_get_codigo_contrario(p_codigo, null, null);
        if v_cod_dp is not null then
            raise_application_error(-20000,'Ya es doble programa: ' || v_cod_dp);
        end if;
        select e.porcred_aprobado, e.promedio_ponderado, e.matriculados_ciclo_anterior
        into v_cre, v_prom, v_ca
        from b_estudiantes e
        where e.codigo = p_codigo;
        if v_cre < 20 then
            raise_application_error(-20001,'No cumple con creditos aprobados: ' || v_cre);
        elsif v_cre >= 100 then
            raise_application_error(-20002,'Plan de estudios finalizado');
        elsif v_prom < 3.5 then
            raise_application_error(-20003,'No cumple con promedio: ' || v_prom);
        elsif v_ca not in ('P','V') then
            raise_application_error(-20004,'No se matriculó el ciclo anterior: ' || v_ca);
        end if;
        select count(*)
        into v_pru
        from a_periodo_prueba p
        where p.codigo_estudiante = p_codigo;
        if v_pru > 0 then 
            raise_application_error(-20005,'Está o estuvo en prueba académica');
        end if;
    end cumpleDP;
    procedure dp_html
    as
        p_usuario varchar2(16);
        p_clave varchar2(16);
        p_documento varchar2(32);
        p_codigo varchar2(32);
        p_nombre varchar2(512);
    begin
        pkg_utils.p_leer_cookie(p_usuario, p_clave, p_documento, p_codigo, p_nombre);
        if p_codigo not in ('005','007','802') then
            raise_application_error(-20000, 'Usuario no autorizado: ' || p_nombre);
        end if;
        htp.prn('<!doctype html>');
        htp.prn('<html lang="es">');
        htp.prn('  <head>');
        htp.prn('    <meta charset="utf-8">');
        htp.prn('    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">');
        htp.prn('    <title>Crear estudiante DP</title>');
        htp.prn('    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">');
        htp.prn('  </head>');
        htp.prn('  <body>');
        htp.prn('    <form class="container">');
        htp.prn('      <fieldset>');
        htp.prn('        <legend>Buscar estudiante</legend>');
        htp.prn('        <div class="form-group row">');
        htp.prn('          <label class="col-sm-2 col-form-label" for="incodest">C&oacute;digo:</label>');
        htp.prn('          <div class="col-sm-9">');
        htp.prn('            <input class="form-control" type="text" id="incodest" placeholder="digite el c&oacute;digo del estudiante que desea ver" data-bind="value: codigo">');
        htp.prn('          </div>');
        htp.prn('          <div class="col-sm-1">');
        htp.prn('            <button class="btn btn-primary" type="button" data-bind="click: buscar"><i class="fas fa-search"></i></button>');
        htp.prn('          </div>');
        htp.prn('        </div>');
        htp.prn('      </fieldset>');
        htp.prn('      <!-- ko if: estudiante -->');
        htp.prn('      <hr>');
        htp.prn('      <fieldset data-bind="with: estudiante">');
        htp.prn('        <legend data-bind="text: programa.nombre"></legend>');
        htp.prn('        <h5><span data-bind="text: codigo"></span><!-- ko if:!_.isUndefined($data.contrario) -->&nbsp;(<span data-bind="text: contrario.codigo"></span>)<!-- /ko --> <span data-bind="text: nombre"></span></h5>');
        htp.prn('        <hr>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Tipo de documento</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.nombre_documento"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Documento</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.numero_documento"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Depto. expedici&oacute;n</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.departamento_documento"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Mcipio. expedici&oacute;n</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.ciudad_documento"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Sexo</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.sexo"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Fecha de nacimiento</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.fecha_nacimiento"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Depto. nacimiento</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.departamento_nacimiento"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Mcipio. nacimiento</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.ciudad_nacimiento"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Depto. residencia</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.departamento_residencia"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Mcipio. residencia</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.ciudad_residencia"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Barrio</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.barrio"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Direcci&oacute;n</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.direccion"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Tel&eacute;fono casa</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.telefono_casa"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Otro tel&eacute;fono</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.telefono_otro"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Tel&eacute;fono oficina</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.telefono_oficina"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Estado civil</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.estado_civil"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Email institucional</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.email"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Otro email</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.otro_email"></p></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="row">');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">Estrato</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.estrato_servicios"></p></div>');
        htp.prn('          <div class="col-sm-2"><p class="font-weight-bold">EPS</p></div>');
        htp.prn('          <div class="col-sm-4"><p data-bind="text: dp.nombre_eps"></p></div>');
        htp.prn('        </div>');
        htp.prn('      </fieldset>');
        htp.prn('      <hr>');
        htp.prn('      <fieldset>');
        htp.prn('        <legend>Programa destino</legend>');
        htp.prn('        <div class="form-group row">');
        htp.prn('          <label class="col-sm-2 col-form-label" for="inprograma">Programa:</label>');
        htp.prn('          <div class="col-sm-10">');
        htp.prn('            <select id="inprograma" class="form-control" data-bind="options:facultades, optionsText:''nombre'', value:facultad, optionsCaption:''Elija un programa''"></select>');
        htp.prn('          </div>');
        htp.prn('        </div>');
        htp.prn('        <div class="form-group row">');
        htp.prn('          <label class="col-sm-2 col-form-label" for="inplan">Plan:</label>');
        htp.prn('          <div class="col-sm-10">');
        htp.prn('            <select id="inplan" class="form-control" data-bind="options:planes, optionsText:''nombre'', value:plan, optionsCaption:''Elija un plan de estudios''"></select>');
        htp.prn('          </div>');
        htp.prn('        </div>');
        htp.prn('        <div class="text-center">');
        htp.prn('          <button type="button" class="btn btn-danger" data-bind="enable: plan, click: salvar"><i class="far fa-save"></i> crear c&oacute;digo doble programa</button>');
        htp.prn('        </div>');
        htp.prn('      </fieldset>');
        htp.prn('      <!-- /ko -->');
        htp.prn('    </form>');
        htp.prn('    <div id="loading" class="modal animated flipInX" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">');
        htp.prn('  		<div class="modal-dialog">');
        htp.prn('  			<div class="modal-content">');
        htp.prn('  				<div class="modal-body">');
        htp.prn('  					<h4>cargando...</h4>');
        htp.prn('  					<div class="progress">');
        htp.prn('  						<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>');
        htp.prn('  					</div>');
        htp.prn('  				</div>');
        htp.prn('  			</div>');
        htp.prn('  		</div>');
        htp.prn('  	</div>');
        htp.prn('  	<div id="aviso" class="modal animated flipInX" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">');
        htp.prn('  		<div class="modal-dialog">');
        htp.prn('  			<div class="modal-content">');
        htp.prn('  				<div class="modal-header">');
        htp.prn('  					<h3 class="modal-title" data-bind="text: aviso().header"></h3>');
        htp.prn('  				</div>');
        htp.prn('  				<div class="modal-body">');
        htp.prn('  					<table class="table"><thead>');
        htp.prn('  					    <tr>');
        htp.prn('  						    <td class="text-center" style="border-top: none; font-size: 4em;">');
        htp.prn('                               <i class="fas fa-times-circle text-danger" data-bind="visible: aviso().level == 1"></i>');
        htp.prn('  							    <i class="fas fa-exclamation-circle text-warning" data-bind="visible: aviso().level == 2"></i>');
        htp.prn('  							    <i class="fas fa-check-circle text-success" data-bind="visible: aviso().level == 3"></i>');
        htp.prn('  						    </td>');
        htp.prn('  						    <td style="border-top: none;">');
        htp.prn('  							    <div data-bind="text: aviso().body"></div>');
        htp.prn('  						    </td>');
        htp.prn('  					    </tr>');
        htp.prn('  					</thead></table>');
        htp.prn('  				</div>');
        htp.prn('  				<!-- ko if: aviso().closeable -->');
        htp.prn('  				<div class="modal-footer">');
        htp.prn('  					<button type="button" class="btn btn-primary" data-dismiss="modal">');
        htp.prn('  						<span class="glyphicon glyphicon-remove-sign" aria-hidden="true"></span>');
        htp.prn('  						cerrar');
        htp.prn('  					</button>');
        htp.prn('  				</div>');
        htp.prn('  				<!-- /ko -->');
        htp.prn('  			</div>');
        htp.prn('  		</div>');
        htp.prn('  	</div>');
        htp.prn('    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>');
        htp.prn('    <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-min.js"></script>');
        htp.prn('    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>');
        htp.prn('    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>');
        htp.prn('    <script src="https://use.fontawesome.com/releases/v5.0.6/js/all.js"></script>');
        htp.prn('    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>');
        htp.prn('    <script type="text/javascript">');
        htp.prn('      var DoblePrgVM = function () {');
        htp.prn('        var self = this;');
        htp.prn('        self.codigo = ko.observable();');
        htp.prn('        self.facultades = ko.observableArray();');
        htp.prn('        self.facultad = ko.observable();');
        htp.prn('        self.facultad.subscribe(function (newFacultad) {');
        htp.prn('          if (!newFacultad) {');
        htp.prn('            self.planes([]);');
        htp.prn('            return;');
        htp.prn('          }');
        htp.prn('          $(''#loading'').modal();');
        htp.prn('          $.getJSON(''pkg_estudiantes.getPlanes?p_facultad='' + newFacultad.codigo + ''&p_jornada='' + newFacultad.jornada, function (data) {');
        htp.prn('            self.planes(data);');
        htp.prn('            $(''#loading'').modal(''hide'');');
        htp.prn('          });');
        htp.prn('        });');
        htp.prn('        self.planes = ko.observableArray();');
        htp.prn('        self.plan = ko.observable();');
        htp.prn('        self.estudiante = ko.observable();');
        htp.prn('        self.init = function () {');
        htp.prn('          $.getJSON(''pkg_utils.getFacultades?p_activas=2&p_tipo=1'', function (data) {');
        htp.prn('            data = _.sortBy(data, function (f) {return f.nombre;});');
        htp.prn('            _.each(data, function (facu) {');
        htp.prn('              _.each(facu.jornadas, function (jr) {');
        htp.prn('                self.facultades.push({codigo:facu.codigo,jornada:jr.jornada,nombre:facu.nombre+'' (''+(jr.jornada == ''D'' ? ''diurno'' : ''nocturno'')+'')'',contacto:facu.contacto,fa:facu.fa});');
        htp.prn('              });');
        htp.prn('            });');
        htp.prn('            $(''#loading'').modal(''hide'');');
        htp.prn('          });');
        htp.prn('        };');
        htp.prn('        self.buscar = function () {');
        htp.prn('          if (!self.codigo() || !self.codigo().match(/^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$/g)) {');
        htp.prn('            self.aviso({level:2, header:''Mensaje importante'', body:''Código mal digitado!'', closeable: true});');
        htp.prn('            return;');
        htp.prn('          }');
        htp.prn('          $(''#loading'').modal();');
        htp.prn('          self.estudiante(undefined);');
        htp.prn('          $.getJSON(''pkg_estudiantes.getEstudiante?p_codigo='' + self.codigo() + ''&p_dp=1'', function (data) {');
        htp.prn('            if (data.mensaje) {');
        htp.prn('              $(''#loading'').modal(''hide'');');
        htp.prn('              self.aviso({level:1, header:''Mensaje importante'', body: data.mensaje, closeable: true});');
        htp.prn('              return;');
        htp.prn('            }');
        htp.prn('            self.estudiante(data);');
        htp.prn('            self.codigo(undefined);');
        htp.prn('            $(''#loading'').modal(''hide'');');
        htp.prn('          });');
        htp.prn('        };');
        htp.prn('        self.salvar = function () {');
        htp.prn('          $(''#loading'').modal(''hide'');');
        htp.prn('          var est = {');
        htp.prn('            codigo: self.estudiante().codigo,');
        htp.prn('            facultad: self.facultad().codigo,');
        htp.prn('            jornada: self.facultad().jornada,');
        htp.prn('            plan: self.plan().id');
        htp.prn('          };');
        htp.prn('          $.ajax({');
        htp.prn('    				type: ''post'',');
        htp.prn('    				url: ''pkg_estudiantes.salvarDP'',');
        htp.prn('    				data: ''p='' + ko.toJSON(est),');
        htp.prn('    				success: function(data) {');
        htp.prn('    					$(''#loading'').modal(''hide'');');
        htp.prn('    					if (data.status==''ok'') {');
        htp.prn('    					    self.aviso({level:3, header:''Exito'', body: ''Estudiante creado: '' +data.mensaje, closeable: true});');
        htp.prn('    					    self.estudiante(undefined);');
        htp.prn('    					} else {');
        htp.prn('                           self.aviso({level:1, header:''Mensaje importante'', body: data.mensaje, closeable: true});');
        htp.prn('    					}');
        htp.prn('    				},');
        htp.prn('    				error: function (jqXHR, textStatus, errorThrown) {');
        htp.prn('                       $(''#loading'').modal(''hide'');');
        htp.prn('                       self.aviso({level:1, header:''Mensaje importante'', body: errorThrown, closeable: true});');
        htp.prn('    				}');
        htp.prn('    			});');
        htp.prn('        };');
        htp.prn('        self.aviso = ko.observable({level:1, header:'''', body:'''', closeable: true});');
        htp.prn('      	self.aviso.subscribe(function () {');
        htp.prn('      		$(''#aviso'').modal();');
        htp.prn('      	});');
        htp.prn('      };');
        htp.prn('      $(''#loading'').modal();');
        htp.prn('      $(document).ready(function () {');
        htp.prn('        var dpVM = new DoblePrgVM();');
        htp.prn('        ko.applyBindings(dpVM);');
        htp.prn('        dpVM.init();');
        htp.prn('      });');
        htp.prn('    </script>');
        htp.prn('  </body>');
        htp.prn('</html>');
    exception
    when others then
        cti_pantalla_error('No puede acceder', sqlerrm);
    end dp_html;
    procedure actualizarDPMulticodigo
    as
        v_dp1 datos_personales%rowtype;
    begin
        for est in (select * from desarrollospre.cti_act_datos_tmp) loop
            select *
            into v_dp1
            from datos_personales dp
            where dp.codigo_estudiante = est.codigo_estudiante;
            for est2 in (
                select dp.codigo_estudiante, dp.codigo_facultad, dp.jornada_facultad
                from datos_personales dp
                where dp.numero_documento = est.numero_documento and dp.codigo_estudiante not in (est.codigo_estudiante)
            ) loop
                v_dp1.codigo_estudiante := est2.codigo_estudiante;
                v_dp1.codigo_facultad := est2.codigo_facultad;
                v_dp1.jornada_facultad := est2.jornada_facultad;
                v_dp1.fecha_actualizacion := sysdate;
                v_dp1.fecha_actualizacion_oar := sysdate;
                update datos_personales dpu set row = v_dp1 where dpu.codigo_estudiante = est2.codigo_estudiante;
            end loop;
        end loop;
        delete from desarrollospre.cti_act_datos_tmp where codigo_estudiante is not null;
        commit;
    exception
    when others then
        rollback;
    end actualizarDPMulticodigo;
    procedure getEstudiantesXDocumento(
        p_documento varchar2)
    as
        v_est json;
        v_respuesta json;
        v_list json_list := json_list();
    begin
        owa_util.mime_header('application/json', false, 'utf-8');
        owa_util.http_header_close;
        for est in (
            select dp.codigo_estudiante
            from datos_personales dp
            where dp.numero_documento = p_documento
            union
            select dp.codigo_estudiante
            from postgrado.datos_personales dp
            where dp.numero_documento = p_documento
            union
            select trim(gr.codigo_estudiante)
            from a_graduados gr
            where length(trim(gr.codigo_estudiante)) < 8
            and (trim(gr.numero_documento) = p_documento or trim(gr.codigo_estudiante) = p_documento)
        ) loop
            v_est := getObjEstudiante(est.codigo_estudiante);
            if v_est is not null then
                json_list.append(v_list,v_est.to_json_value);
            end if;
        end loop;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getEstudiantesXDocumento;
    procedure por_documento_html(
        p_documento varchar2
    ) as
        p_usuario a_usuarios.usuario%type;
        p_clave a_usuarios.clave%type;
        p_cc a_usuarios.numero_documento%type;
        p_codigo a_usuarios.codigo%type;
        p_nombre a_usuarios.nombre_usuario%type;
    begin
        pkg_utils.p_leer_cookie(p_usuario, p_clave, p_cc, p_codigo, p_nombre);
        if p_codigo not in ('813','814','815','816','817','99','994','007') then
            raise_application_error(-20000, 'Usuario no autorizado: ' || p_nombre);
        end if;
        htp.prn('<!doctype html>');
        htp.prn('<html lang="es">');
        htp.prn('<head>');
        htp.prn('<meta charset="utf-8">');
        htp.prn('<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">');
        htp.prn('<title>Consulta DP</title>');
        htp.prn('<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">');
        htp.prn('<style>');
        htp.prn('body {');
        htp.prn('overflow: hidden;');
        htp.prn('}');
        htp.prn('section {');
        htp.prn('position: relative;');
        htp.prn('}');
        htp.prn('iframe {');
        htp.prn('width: 100%;');
        htp.prn('height: calc(100vh - 45px);');
        htp.prn('margin: 0;');
        htp.prn('padding: 0;');
        htp.prn('border: 0;');
        htp.prn('}');
        htp.prn('.vcenter {');
        htp.prn('position: absolute;');
        htp.prn('top: 50%;');
        htp.prn('-webkit-transform: translateY(-50%);');
        htp.prn('-ms-transform: translateY(-50%);');
        htp.prn('transform: translateY(-50%);');
        htp.prn('}');
        htp.prn('p.vcenter {');
        htp.prn('width: 100%;');
        htp.prn('}');
        htp.prn('.custom-overlay {');
        htp.prn('background: none repeat scroll 0 0 #002547;');
        htp.prn('height: 100%;');
        htp.prn('left: 0;');
        htp.prn('opacity: 0.6;');
        htp.prn('position: absolute;');
        htp.prn('top: 0;');
        htp.prn('width: 100%;');
        htp.prn('z-index: 99;');
        htp.prn('color: #e3af00;');
        htp.prn('font-size: 5em;');
        htp.prn('}');
        htp.prn('</style>');
        htp.prn('</head>');
        htp.prn('<body class="container-fluid">');
        htp.prn('<!-- ko if: estudiante -->');
        htp.prn('<ul class="nav nav-tabs" data-bind="foreach: estudiantes">');
        htp.prn('<li class="nav-item">');
        htp.prn('<a class="nav-link" href="#" data-bind="text: $data.codigo, css: {''active'': $data.codigo == $root.estudiante().codigo}, click: $root.verEstudiante"></a>');
        htp.prn('</li>');
        htp.prn('</ul>');
        htp.prn('<!-- /ko -->');
        htp.prn('<section>');
        htp.prn('<div class="custom-overlay text-center"><p class="vcenter text-center"><i class="fas fa-clock"></i></p></div>');
        htp.prn('<div id="frm-est"></div>');
        htp.prn('</section>');
        htp.prn('<div id="loading" class="modal animated flipInX" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">');
        htp.prn('<div class="modal-dialog">');
        htp.prn('<div class="modal-content">');
        htp.prn('<div class="modal-body">');
        htp.prn('<h4>cargando...</h4>');
        htp.prn('<div class="progress">');
        htp.prn('<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('<div id="aviso" class="modal animated flipInX" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">');
        htp.prn('<div class="modal-dialog">');
        htp.prn('<div class="modal-content">');
        htp.prn('<div class="modal-header">');
        htp.prn('<h3 class="modal-title" data-bind="text: aviso().header"></h3>');
        htp.prn('</div>');
        htp.prn('<div class="modal-body">');
        htp.prn('<table class="table">');
        htp.prn('<tbody>');
        htp.prn('<tr>');
        htp.prn('<td>');
        htp.prn('<i class="fas fa-times-circle text-danger" data-bind="visible: aviso().level == 1"></i>');
        htp.prn('<i class="fas fa-exclamation-circle text-warning" data-bind="visible: aviso().level == 2"></i>');
        htp.prn('<i class="fas fa-check-circle text-success" data-bind="visible: aviso().level == 3"></i>');
        htp.prn('</td>');
        htp.prn('<td data-bind="text: aviso().body"></td>');
        htp.prn('</tr>');
        htp.prn('</tbody>');
        htp.prn('</table>');
        htp.prn('</div>');
        htp.prn('<!-- ko if: aviso().closeable -->');
        htp.prn('<div class="modal-footer">');
        htp.prn('<button type="button" class="btn btn-primary" data-dismiss="modal">');
        htp.prn('<span class="glyphicon glyphicon-remove-sign" aria-hidden="true"></span>');
        htp.prn('cerrar');
        htp.prn('</button>');
        htp.prn('</div>');
        htp.prn('<!-- /ko -->');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('</div>');
        htp.prn('<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>');
        htp.prn('<script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-min.js"></script>');
        htp.prn('<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>');
        htp.prn('<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>');
        htp.prn('<script src="https://use.fontawesome.com/releases/v5.0.6/js/all.js"></script>');
        htp.prn('<script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>');
        htp.prn('<script type="text/javascript">');
        htp.prn('var DoblePrgVM = function () {');
        htp.prn('var self = this;');
        htp.prn('self.estudiantes = ko.observableArray();');
        htp.prn('self.estudiante = ko.observable();');
        htp.prn('self.init = function () {');
        htp.prn('$.getJSON(''pkg_estudiantes.getEstudiantesXDocumento?p_documento=' || p_documento || ''', function (data) {');
        htp.prn('if (data.status) {');
        htp.prn('self.aviso({level:1, header:''Aviso importante'', body:data.mensaje, closeable: false});');
        htp.prn('return;');
        htp.prn('}else if (_.isEmpty(data)) {');
        htp.prn('self.aviso({level:2, header:''Sin resultados'', body:''No existen registros asociados a ese documento.'', closeable: false});');
        htp.prn('$(''.custom-overlay'').hide();');
        htp.prn('return;');
        htp.prn('}');
        htp.prn('self.estudiantes(data);');
        htp.prn('self.verEstudiante(data[0]);');
        htp.prn('$(''#loading'').modal(''hide'');');
        htp.prn('});');
        htp.prn('};');
        htp.prn('self.verEstudiante = function (est) {');
        htp.prn('if (self.estudiante() && est.codigo == self.estudiante().codigo) {');
        htp.prn('return;');
        htp.prn('} else if (est.codigo.length < 8) {');
        htp.prn('self.aviso({level:1, header:''Sin resultados'', body:''No existe historia académica: '' + est.codigo, closeable: false});');
        htp.prn('$(''.custom-overlay'').hide();');
        htp.prn('return;');
        htp.prn('}');
        htp.prn('$(''.custom-overlay'').show(''fast'');');
        htp.prn('self.estudiante(est);');
        htp.prn('$(''#frm-est'').html(''<iframe id="frm-sia" src="ls_estudiante_dir?p_codestudiante='' + est.codigo + ''&p_boton=99"></iframe>'');');
        htp.prn('$(''#frm-sia'').on(''load'', function() {');
        htp.prn('$(''.custom-overlay'').hide(''slow'');');
        htp.prn('});');
        htp.prn('};');
        htp.prn('self.aviso = ko.observable({level:1, header:'''', body:'''', closeable: true});');
        htp.prn('self.aviso.subscribe(function () {');
        htp.prn('$(''#loading'').modal(''hide'');');
        htp.prn('$(''#aviso'').modal();');
        htp.prn('});');
        htp.prn('};');
        htp.prn('$(document).ready(function () {');
        htp.prn('var dpVM = new DoblePrgVM();');
        htp.prn('dpVM.init();');
        htp.prn('ko.applyBindings(dpVM);');
        htp.prn('});');
        htp.prn('</script>');
        htp.prn('</body>');
        htp.prn('</html>');
    exception
    when others then
        cti_pantalla_error('No puede acceder', sqlerrm);
    end por_documento_html;
    
    PROCEDURE PR_GET_DATOS_ARL_ESTUDIANTE(p_codigo varchar2) AS
     periodo json;
     periodos json_list:=json_list();
     respuesta json:=json();
     datos_encontrados boolean := False;
   BEGIN
     owa_util.mime_header('application/json',false,'utf-8');
     owa_util.http_header_close;
     json.put(respuesta,'status','success');
     FOR est IN (
            SELECT E.CODIGO,CONCAT(E.APELLIDOS,' '||E.NOMBRES) AS NOMBRES, 
                   DECODE(E.INDICADOR_PAGO,'P','MATRICULADO','V','MATRICULADO','C','CANCELACIÓN DE MATRÍCULA','K','CANCELACIÓN DE MATRÍCULA','X','RETIRADO') as ESTADO, 
                   DP.NUMERO_DOCUMENTO, TRIM(AF.NOMBRE) AS FACULTAD
            FROM   B_ESTUDIANTES E
            JOIN   DATOS_PERSONALES DP
            ON     DP.CODIGO_ESTUDIANTE = E.CODIGO
            JOIN   A_FACULTADES AF
            ON     AF.CODIGO = E.CODIGO_FACULTAD
            WHERE  E.CODIGO = p_codigo
        UNION
            SELECT E.CODIGO,CONCAT(E.APELLIDOS,' '||E.NOMBRES) AS NOMBRES,
                   DECODE(E.INDICADOR_PAGO,'P','MATRICULADO','V','MATRICULADO','C','CANCELACIÓN DE MATRÍCULA','K','CANCELACIÓN DE MATRÍCULA','X','RETIRADO') as ESTADO, 
                   DP.NUMERO_DOCUMENTO, TRIM(AF.NOMBRE) AS FACULTAD
            FROM   POSTGRADO.B_ESTUDIANTES E
            JOIN   DATOS_PERSONALES DP
            ON     DP.CODIGO_ESTUDIANTE = E.CODIGO
            JOIN   A_FACULTADES AF
            ON     AF.CODIGO = E.CODIGO_FACULTAD
            WHERE  E.CODIGO = p_codigo
        UNION
            SELECT E.CODIGO,CONCAT(E.APELLIDOS,' '||E.NOMBRES) AS NOMBRES, 
                   DECODE(E.INDICADOR_PAGO,'P','MATRICULADO','V','MATRICULADO','C','CANCELACIÓN DE MATRÍCULA','K','CANCELACIÓN DE MATRÍCULA','X','RETIRADO') as ESTADO, 
                   DP.NUMERO_DOCUMENTO, TRIM(AF.NOMBRE) AS FACULTAD
            FROM   YOPAL.B_ESTUDIANTES E
            JOIN   DATOS_PERSONALES DP
            ON     DP.CODIGO_ESTUDIANTE = E.CODIGO
            JOIN   A_FACULTADES AF
            ON     AF.CODIGO = E.CODIGO_FACULTAD
            WHERE  E.CODIGO = p_codigo
    ) LOOP
        json.put(respuesta,'codigo',est.codigo);
        json.put(respuesta,'nombres',est.nombres);
        json.put(respuesta,'estado',est.estado);
        json.put(respuesta,'numero_documento',est.numero_documento);
        json.put(respuesta,'facultad',est.facultad);
        datos_encontrados := True;
    END LOOP;

     FOR periodo_row IN (
       SELECT  AC.ANIO,AC.CICLO,
                DECODE(AC.CICLO,
                '00','HOMOLOGACION POR TRANSFERENCIA',
                '01','PRIMER PERÍODO',
                '02','CURSO INTERSEMESTRAL',
                '03','SEGUNDO PERÍODO',
                '04','CURSO DE VACACIONES FIN DE AÑO',
                '*','HOMOLOGACIÓN POR CAMBIO DE PLAN DE ESTUDIOS',
                '**','HOMOLOGACIÓN POR CAMBIO DE PLAN DE ESTUDIOS',
                '.','HOMOLOGACIÓN') PERIODO,
                NVL(DECODE(
                CASE
                  WHEN AC.CICLO = '02' THEN 'P'
                  WHEN CONCAT(AC.ANIO,AC.CICLO) = (SELECT CONCAT(MAX(BE.ANIO),DECODE(MAX(BE.CICLO),'01','01','02','03')) FROM B_ESTUDIANTES BE) 
                    THEN (
                    SELECT BE.INDICADOR_PAGO
                    FROM   B_ESTUDIANTES BE
                    WHERE  BE.CODIGO = p_codigo
                    AND    BE.ANIO   = AC.ANIO
                    AND    BE.CICLO  = DECODE(AC.CICLO,'01','01','03','02','02','01'))      
                ELSE
                  (SELECT HE.INDICADOR_PAGO
                   FROM   HISTORICO_ESTUDIANTES HE
                   WHERE  HE.CODIGO = p_codigo
                   AND    HE.ANIO   = AC.ANIO
                   AND    HE.CICLO  = DECODE(AC.CICLO,'01','01','03','02','02','01')
                  )
                END
                ,'P','MATRICULADO','V','MATRICULADO','C','CANCELACIÓN DE MATRÍCULA','K','CANCELACIÓN DE MATRÍCULA','X','RETIRADO'),'SIN REGISTRO') AS ESTADO
       FROM    (SELECT         DISTINCT AN.ANO AS ANIO,AN.CICLO AS CICLO
                FROM            A_NOTAS AN
                WHERE           AN.CODIGO_ESTUDIANTE = p_codigo
                AND             AN.CICLO IN ('01','03')
                UNION
                SELECT          HE.ANIO,DECODE(HE.CICLO,'01','01','02','03') AS CICLO
                FROM            HISTORICO_ESTUDIANTES HE
                WHERE           HE.CODIGO = p_codigo
                UNION
                SELECT          BE.ANIO,DECODE(BE.CICLO,'01','01','02','03') AS CICLO
                FROM            B_ESTUDIANTES BE
                WHERE           BE.CODIGO = p_codigo
                ) AC
       ORDER BY AC.ANIO ASC, AC.CICLO ASC
      ) LOOP
         periodo :=json();
         json.put(periodo,'anio',periodo_row.anio);
         json.put(periodo,'ciclo',periodo_row.ciclo);
         json.put(periodo,'periodo',periodo_row.periodo);
         json.put(periodo,'estado',periodo_row.estado);
         json_list.append(periodos,periodo.to_json_value);
      END LOOP;
      json.put(respuesta,'periodos',periodos);
      
      IF datos_encontrados = False THEN
        respuesta:= json();
        json.put(respuesta,'status','fail');
        json.put(respuesta,'message','No se encontró información del estudiante '||p_codigo);
      END IF;
      
      json.htp(respuesta,false);
      EXCEPTION
      WHEN OTHERS THEN
        respuesta:= json();
        json.put(respuesta,'status','fail');
        json.put(respuesta,'message','Error: '||pkg_utils.acentos(sqlerrm));        
        json.htp(respuesta);
   END PR_GET_DATOS_ARL_ESTUDIANTE;
   
   PROCEDURE PR_ARL_PERFIL_ESTUDIANTES AS
      /*Autenticación por cookie*/
      v_usuario a_usuarios.usuario%type;
      v_clave a_usuarios.clave%type;
      v_documento a_usuarios.numero_documento%type;
      v_codigo a_usuarios.codigo%type;
      v_nombre_usuario a_usuarios.nombre_usuario%type;
   BEGIN
      pkg_utils.p_leer_cookie(v_usuario, v_clave, v_documento,v_codigo, v_nombre_usuario);
      IF v_codigo NOT IN ('300') THEN
          raise_application_error(-20999, 'Usuario no autorizado: ' || v_nombre_usuario);
      END IF;
      htp.p('<!doctype html>');
      htp.p('<html lang="">');
      htp.p('  <head>');
      htp.p('    <meta charset="utf-8">');
      htp.p('    <meta name="description" content="">');
      htp.p('    <meta name="viewport" content="width=device-width, initial-scale=1">');
      htp.p('    <title>Perfil consulta estudiantes</title>');
      htp.p('    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs4-4.1.1/jq-3.3.1/dt-1.10.18/cr-1.5.0/r-2.2.2/datatables.min.css"/>');
      htp.p('    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.0/jquery-confirm.min.css">');
      htp.p('    <style>');
      htp.p('      @keyframes spinner-line-fade-more{0%,100%{opacity:0}1%{opacity:1}}@keyframes spinner-line-fade-quick{0%,100%,39%{opacity:.25}40%{opacity:1}}@keyframes spinner-line-fade-default{0%,100%{opacity:.22}1%{opacity:1}}.browserupgrade{margin:.2em 0;background:#ccc;color:#000;padding:.2em 0}body{background:#fafafa;font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;color:#333}#input-fields{width:50%;margin:20px auto 0}#input-fields button{margin:0 auto;display:block}#basic-data .table{margin:0 auto;width:50%;font-size:.8rem;line-height:1}#basic-data .table tbody tr{line-height:1}#periodos-cursados_wrapper{width:60%;margin:0 auto}h4{text-align:center}#basic-data>table.table.table-bordered>thead>tr{background-color:#e2e2e2;color:#000}.btn-primary,.page-item.active .page-link{background-color:#042b50}.banner-lasalle{border-bottom:3px solid #fa9e24;width:60%;margin:0 auto 10px;background:#042b50;color:#fff;height:39px;padding-top:3px;font-family:"Open Sans",sans-serif!important}.btn-primary{border-color:#fa9e24}.h4,h4{font-size:1.4rem}');
      htp.p('    </style>');
      htp.p('  </head>');
      htp.p('  <body>');
      htp.p('    <!--[if IE]>');
      htp.p('      <p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>');
      htp.p('    <![endif]-->');
      htp.p('    <div id="modal-cargando">');
      htp.p('    </div>');
      htp.p('    <h4 class="banner-lasalle">Consulta de estudiantes</h4>');
      htp.p('    <div id="input-fields" >');
      htp.p('        <div class="form-group row">');
      htp.p('          <label for="codigo" class="col-sm-3 col-form-label"><b>Código:</b></label>');
      htp.p('          <div class="col-sm-5">');
      htp.p('            <input type="text" class="form-control" id="codigo" placeholder="Código estudiante" data-bind="value:codigo" >');
      htp.p('          </div>');
      htp.p('          <div class="col-sm-4">');
      htp.p('              <button type="submit" class="btn btn-primary " data-bind="click:consultarEstudiante">Consultar</button>');
      htp.p('          </div>');
      htp.p('        </div>');
      htp.p('      </div>');
      htp.p('    <br/>');
      htp.p('    <h4 class="banner-lasalle" data-bind="visible:periodos().length>0">Datos generales</h4>');
      htp.p('    <div id="basic-data" data-bind="visible:periodos().length>0">');
      htp.p('        <table class="table table-bordered">');
      htp.p('            <tbody>');
      htp.p('                <tr>');
      htp.p('                    <th scope="row">Apellidos y nombres:</th>');
      htp.p('                    <td data-bind="text:nombres"></td>');
      htp.p('                  </tr>');
      htp.p('              <tr>');
      htp.p('                <th scope="row">Programa:</th>');
      htp.p('                <td data-bind="text:programa"></td>');
      htp.p('              </tr>');
      htp.p('            </tbody>');
      htp.p('          </table>');
      htp.p('      <table class="table table-bordered">');
      htp.p('        <thead>');
      htp.p('          <th class="text-center" scope="row">Código</th>');
      htp.p('          <th class="text-center" scope="row">Número de documento</th>');
      htp.p('          <th class="text-center" scope="row">Estado</th>');
      htp.p('        </thead>');
      htp.p('          <tbody>');
      htp.p('            <tr>');
      htp.p('              <td class="text-center" data-bind="text:codigo_consultado"></td>');
      htp.p('              <td class="text-center" data-bind="text:numero_documento"></td>');
      htp.p('              <td class="text-center" data-bind="text:estado"></td>');
      htp.p('            </tr>');
      htp.p('          </tbody>');
      htp.p('        </table>');
      htp.p('    </div>');
      htp.p('    <br/>');
      htp.p('    <h4 class="banner-lasalle" data-bind="visible:periodos().length>0">Periodos registrados</h4>');
      htp.p('    <div id="table-container">');
      htp.p('    </div>');
      htp.p('    <script type="text/javascript" src="https://cdn.datatables.net/v/bs4-4.1.1/jq-3.3.1/dt-1.10.18/cr-1.5.0/r-2.2.2/datatables.min.js"></script>');
      htp.p('    <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-min.js"></script>');
      htp.p('    <script src="https://cdnjs.cloudflare.com/ajax/libs/spin.js/2.3.2/spin.min.js"></script>');
      htp.p('    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.0/jquery-confirm.min.js"></script>');
      htp.p('    <script>');
      htp.p('    var url_consulta_estudiante="/pls/regadm/pkg_estudiantes.PR_GET_DATOS_ARL_ESTUDIANTE";function consultarEstudiante(o){return $.get(url_consulta_estudiante,{p_codigo:o})}function periodo(o){this.anio=ko.observable(o.anio),this.periodo=ko.observable(o.periodo),this.estado=ko.observable(o.estado)}function AppViewModel(){var o=this;o.codigo=ko.observable(),o.codigo_consultado=ko.observable(),o.nombres=ko.observable(),o.estado=ko.observable(),o.programa=ko.observable(),o.numero_documento=ko.observable(),o.periodos=ko.observableArray([]),o.consultarEstudiante=function(){$("#modal-cargando").spin("modal"),consultarEstudiante(o.codigo).done(function(e){if(console.log(e),"fail"==e.status)$.alert({title:"Atención!",content:e.message,type:"red",backgroundDismiss:!0}),$("#modal-cargando").spin("modal"),o.periodos([]),$("#periodos-cursados_wrapper").hide();else{o.codigo_consultado(e.codigo),o.nombres(e.nombres),o.estado(e.estado),o.programa(e.facultad),o.numero_documento(e.numero_documento),o.periodos([]);for(var a=0;a<e.periodos.length;a++)o.periodos.push(new periodo(e.periodos[a]));$("#periodos-cursados_wrapper").remove();var s="<table id=\"periodos-cursados\" class=\"display table-striped\" style=\"width:100%\" data-bind=\"visible:periodos().length>0\"> <thead><tr><th>Año</th><th>Periodo</th><th>Estado</th></tr></thead><tbody data-bind=\"foreach:periodos\">";for(a=0;a<e.periodos.length;a++)s+="<tr><td>"+e.periodos[a].anio+"</td><td>"+e.periodos[a].periodo+"</td><td>"+e.periodos[a].estado+"</td></tr>";s+="</tbody></table>",$(s).appendTo("#table-container"),$("#periodos-cursados").DataTable({language:{lengthMenu:"Mostrar _MENU_ registros por página",zeroRecords:"Lo sentimos no se han encontrado coincidencias",info:"Mostrando página _PAGE_ de _PAGES_",infoEmpty:"No se encontraron registros",infoFiltered:"(De un total de _MAX_ registros)",paginate:{first:"Primera",last:"Última",next:"Siguiente",previous:"Anterior"},search:"Búsqueda"}}),$("#periodos-cursados_wrapper").show(),$("#modal-cargando").spin("modal")}})}}ko.applyBindings(new AppViewModel);var default_opts={lines:13,length:38,width:17,radius:45,scale:.25,corners:1,color:"#163856",fadeColor:"transparent",speed:1,rotate:0,animation:"spinner-line-fade-quick",direction:1,zIndex:2e9,className:"spinner",top:"50%",left:"50%",shadow:"0 0 1px transparent",position:"absolute"},modal_opts={lines:13,length:38,width:17,radius:45,scale:.25,corners:1,color:"#163856",fadeColor:"transparent",speed:1,rotate:0,animation:"spinner-line-fade-quick",direction:1,zIndex:2e9,className:"spinner",top:"50%",left:"50%",shadow:"0 0 1px transparent",position:"absolute"};$.fn.spin=function(o){return null==o&&(o=default_opts),"modal"==o&&(o=modal_opts),this.each(function(){var e=$(this),a=e.data();if(a.spinner)return a.spinner.stop(),delete a.spinner,o==modal_opts&&$("#spin_modal_overlay").remove(),this;var s=this;o==modal_opts&&($("body").append("<div id=\"spin_modal_overlay\" style=\"background-color: rgba(0, 0, 0, 0.2); width:100%; height:100%; position:fixed; top:0px; left:0px; z-index:"+(o.zIndex-1)+"\"/>"),s=$("#spin_modal_overlay")[0]),a.spinner=new Spinner($.extend({color:e.css("color")},o)).spin(s)}),this};');
      htp.p('    </script>');
      htp.p('  </body>');
      htp.p('</html>');
      EXCEPTION
      WHEN OTHERS THEN
        htp.p('Error:'||sqlerrm);
   END PR_ARL_PERFIL_ESTUDIANTES;

    procedure getUltimoPeriodoCursado (
        p_codigo in b_estudiantes.codigo%type,
        o_anio out b_estudiantes.anio%type,
        o_ciclo out b_estudiantes.ciclo%type
    ) is
        v_aniociclo varchar2(8);
    begin
        select max(x.n)
        into v_aniociclo
        from (
            select max(n.ano || n.ciclo) n
            from a_notas n
            where n.codigo_estudiante = p_codigo
            and n.ciclo in ('01', '03')
            union
            select max(n.ano || n.ciclo)
            from postgrado.a_notas n
            where n.codigo_estudiante = p_codigo
            and n.ciclo in ('01', '03')
            union
            select max(n.ano || n.ciclo)
            from yopal.a_notas n
            where n.codigo_estudiante = p_codigo
            and regexp_like(n.ciclo, '^[0-9]{2}$')
            and n.ciclo != '00'
        ) x
        where rownum <= 1;
        o_anio := substr(v_aniociclo, 0, 4);
        o_ciclo := substr(v_aniociclo, 5, 2);
    exception
    when others then
        o_anio := null;
        o_ciclo := null;
        dbms_output.put_line(sqlerrm);
    end getUltimoPeriodoCursado;

    function getCodigoContrario(
        p_codigo b_estudiantes.codigo%type
    ) return b_estudiantes.codigo%type is
        v_codigo_dp b_estudiantes.codigo%type;
    begin
        --FIXME: Que pasa cuando está registrado más de una vez?
        select dos.codigo_estudiante
        into v_codigo_dp
        from cti_doble_programa uno
        inner join
        cti_doble_programa dos
        on uno.id_dp = dos.id_dp_rel
        where uno.id_dp_rel is null
        and uno.codigo_estudiante = p_codigo
        and rownum <= 1
        and not exists (select 1 from b_estudiantes e where e.codigo = dos.codigo_estudiante and e.materias_pendientes <= 0)
        union
        select dos.codigo_estudiante
        from cti_doble_programa uno
        inner join
        cti_doble_programa dos
        on uno.id_dp_rel = dos.id_dp
        where uno.id_dp_rel is not null
        and uno.codigo_estudiante = p_codigo
        and rownum <= 1
        and not exists (select 1 from b_estudiantes e where e.codigo = dos.codigo_estudiante and e.materias_pendientes <= 0);
        return v_codigo_dp;
    exception
    when no_data_found then
        return null;
    end getCodigoContrario;

    function aplicaArt47 (
        p_codigo varchar2,
        p_val_dp number default 1
    ) return number is
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_anioa varchar2(4);
        v_cicloa varchar2(2);
        v_cicloa_notas varchar2(2);
        v_esquema varchar2(32);
        v_beneficiario number;
        v_sem_inf number;
        v_cred_max number;
        v_cred_ins number;
        v_promedio number;
        v_perdidas number;
        v_cod_contrario b_estudiantes.codigo%type;
        v_ind_dp number;
    begin
        pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
        if to_number(v_ciclo) = 2 then
            v_anioa := v_anio;
            v_cicloa := '01';
            v_cicloa_notas := '01';
        else
            v_anioa := trim(to_char(to_number(v_anio) - 1, '0000'));
            v_cicloa := '02';
            v_cicloa_notas := '03';
        end if;
        pkg_utils.getResumenCreditos(p_codigo, v_anioa, v_cicloa, v_sem_inf, v_cred_max, v_cred_ins);
        --htp.p('<!-- ' || v_sem_inf || ',' || v_cred_max || ',' || v_cred_ins || ' -->');
        -- Condiciones que aplican sin importar el estaus del estudiante:
        -- No estudio      | No inscribio cr. extra            | Perdio al menos una materia                                      | Promedio menor a 4
        if v_sem_inf = 0 /*or v_cred_ins - v_cred_max <= 0*/ or pkg_utils.porcentajeAprobacion(p_codigo, v_anioa, v_cicloa_notas) < 1 or pkg_utils.promedioPeriodo(p_codigo, v_anioa, v_cicloa_notas) < 4 then
            return(0);
        elsif v_sem_inf < 0 then
            return(-1);
        end if;
        --Ya fue beneficiario?
        select count(*)
        into v_beneficiario
        from
        liquidacion_guias.vw_articulo47@uvirtual.lasalle.edu.co
        where
        codigo = p_codigo
        and anio = v_anioa
        and periodo = v_cicloa;
        --Si fue beneficiario y retiro 2 o mas asignaturas
        if v_beneficiario > 0 and pkg_utils.noMateriasRetiradas(p_codigo, v_anioa, v_cicloa) >= 2 then
            return(2);
        end if;
        if p_val_dp > 0 then
            v_cod_contrario := b_prematricula_spring.f_get_codigo_contrario(p_codigo, v_anio, v_ciclo);
            if v_cod_contrario is not null then
                v_beneficiario := 0;
                --Si el codigo contrario es nuevo
                select count(*)
                into v_beneficiario
                from b_estudiantes e
                where e.codigo = v_cod_contrario and e.ciclo_de_ingreso = e.anio || to_number(e.ciclo);
                --De ser así no se valida si aplica o no, por que no tiene historia.
                if v_beneficiario <= 0 then
                    --Si el dp no es nuevo se hace la validación normal.
                    v_ind_dp := pkg_utils.aplicaArt47(v_cod_contrario, 0);
                    if v_ind_dp != 1 then
                        return(v_ind_dp);
                    end if;
                end if;
            end if;
        end if;
        return(1);
    exception
    when no_data_found then
        return(0);
    when others then
        return(-1);
    end aplicaArt47;

    function aplicaArt44 (
        p_codigo varchar2,
        p_val_dp number default 1,
        p_debug number default 0
    ) return number is
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_anioa varchar2(4);
        v_cicloa varchar2(2);
        v_esquema varchar2(32);
        v_paprob number;
        v_prom number;
        v_prueba number;
        v_cod_contrario b_estudiantes.codigo%type;
        v_err_cod number := -20000;
    begin
        if p_val_dp > 0 then
            v_cod_contrario := getCodigoContrario(p_codigo);
            if v_cod_contrario is not null then
                if pkg_utils.esNuevo(p_codigo) = 1 then
                    if p_debug > 0 then
                        dbms_output.put_line(' * DP nuevo: ' || p_codigo || ',' || v_cod_contrario);
                    end if;
                    return aplicaArt44(v_cod_contrario, 0, p_debug);
                elsif pkg_utils.esNuevo(v_cod_contrario) = 1 then
                    if p_debug > 0 then
                        dbms_output.put_line(' * DP nuevo: ' || v_cod_contrario || ',' || p_codigo);
                    end if;
                    return aplicaArt44(p_codigo, 0, p_debug);
                elsif aplicaArt44(v_cod_contrario, 0, p_debug) < 1 then
                    raise_application_error(v_err_cod, 'No cumple el codigo de DP: ' || v_cod_contrario);
                end if;
                if p_debug > 0 then
                    dbms_output.put_line(' * cumple DP: ' || v_cod_contrario);
                end if;
            end if;
        end if;
        getUltimoPeriodoCursado(p_codigo, v_anio, v_ciclo);
        if v_anio is null then
            raise_application_error(v_err_cod, 'No tiene ultimo ciclo: ' || p_codigo);
        elsif p_debug > 0 then
            dbms_output.put_line(' -> Ultimo ciclo cursado: ' || p_codigo || ' ' || v_anio || v_ciclo || ' (' || v_anio || (case when v_ciclo = '03' then '02' else v_ciclo end) || ')');
        end if;
        v_prom := pkg_utils.promedioPonderadoTotal(p_codigo);
        if v_prom < 4.1 then
            raise_application_error(v_err_cod, 'No cumple con el promedio: ' || p_codigo || ':' || v_prom);
        elsif p_debug > 0 then
            dbms_output.put_line(' * cumple promedio: ' || p_codigo || ' ' || v_prom);
        end if;
        v_paprob := pkg_utils.porcentajeAprobacion(p_codigo, v_anio, v_ciclo);
        if v_paprob < 1 then
            raise_application_error(v_err_cod, 'Ha perdido materias en el ultimo periodo cursado: ' || p_codigo || ' ' || v_anio || v_ciclo || ':' || (100 * round(v_paprob, 3)) || '%');
        elsif p_debug > 0 then
            dbms_output.put_line(' * cumple sin materias perdidas: ' || p_codigo || ' ' || (100 * round(v_paprob, 3)) || '%');
        end if;
        select count(*)
        into v_prueba
        from a_periodo_prueba pp
        where pp.codigo_estudiante = p_codigo;
        if v_prueba > 0 then
            raise_application_error(v_err_cod, 'Ha estado en prueba academica: ' || p_codigo);
        elsif p_debug > 0 then
            dbms_output.put_line(' * cumple sin prueba academica: ' || p_codigo || ' ' || v_prueba);
        end if;
        for ben in (
            select distinct l.anio, l.periodo
            from liquidacion_guias.vw_articulo47@uvirtual.lasalle.edu.co l
            where l.codigo = p_codigo
            and l.anio = (case when v_ciclo = '03' then to_number(v_anio-1) else to_number(v_anio) end) --mariano rua mejia 30/01/2020  caso codigo : 37182027
            and l.periodo = (case when v_ciclo = '03' then '02' else v_ciclo end)
            order by 1, 2
        ) loop
            if pkg_utils.noMateriasRetiradas(p_codigo, ben.anio, ben.periodo) > 1 then
                raise_application_error(v_err_cod, 'Fue beneficiario y retiro dos o más materias: ' || p_codigo || ' ' || ben.anio || ben.periodo);
            elsif p_debug > 0 then
                dbms_output.put_line(' * cumple beneficiario en ' || ben.anio || ben.periodo || ': ' || p_codigo);
            end if;
        end loop;
        return(1);
    exception
    when others then
        if p_debug > 0 then
            dbms_output.put_line(sqlerrm);
        end if;
        return(0);
    end aplicaArt44;
    
    function esMenorDeEdad(
        p_codigo b_estudiantes.codigo%type
    ) return number as
        v_edad number;
    begin
        select
            months_between(sysdate, x.fecha_nacimiento)/12
        into v_edad
        from
            (select dp.fecha_nacimiento
            from datos_personales dp
            where dp.codigo_estudiante = p_codigo
            union
            select distinct to_date(trim(to_char(a.dia_nac,'00')) || '/' || a.mes_nac || '/' || trim(to_char(a.ano_nac,'0000')), 'DD/MON/RRRR', 'nls_date_language = American') fecha_nacimiento
            from a_aspirantes a
            where a.cod_def = p_codigo and a.dia_nac is not null) x
        where rownum <= 1;
        if v_edad < 18 then
            return(1);
        else
            return(0);
        end if;
    exception
    when no_data_found then
        return(-1);
    end esMenorDeEdad;
    
    procedure getFacultadesExcel
    is
        facs json_list:=json_list();
        fac json;
        respuesta json;
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        for f in (select f.codigo, f.jornada, trim(f.nombre) nombre from a_facultades f where f.indicador in ('S') order by 1) loop
            fac := json();
            json.put(fac,'id',f.codigo || f.jornada);
            json.put(fac,'codigo',f.codigo);
            json.put(fac,'jornada',f.jornada);
            json.put(fac,'nombre',f.nombre);
            json_list.append(facs,fac.to_json_value);
        end loop;
        json_list.htp(facs,false);
    exception
    when others then
        respuesta := json();
        json.put(respuesta,'status','fail');
        json.put(respuesta,'message',sqlerrm);
        json.htp(respuesta,false);
    end getFacultadesExcel;
    
    function fncUltimoPeriodoCursado(
        p_codigo b_estudiantes.codigo%type
    ) return varchar2 as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
    begin
        getUltimoPeriodoCursado(p_codigo, v_anio, v_ciclo);
        return v_anio || '-' || v_ciclo;
    exception
    when others then
        return 'NA';
    end fncUltimoPeriodoCursado;

    function getCohorte(
        p_codigo b_estudiantes.codigo%type
    ) return varchar2 as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
    begin
        select
            to_number(case substr(e.codmil,3,1) when '1' then '1,9' when '2' then '2' else '0' end)*1000 + to_number(substr(e.codigo,3,2)) || '' anio,
            substr(e.codigo,5,1) ciclo
        into
            v_anio, v_ciclo
        from
            b_estudiantes e
        where
            e.codigo = p_codigo;
        return v_anio || v_ciclo;
    exception
    when others then
        return '00000';
    end getCohorte;

    function esPostgradual(
        p_codigo b_estudiantes.codigo%type
    ) return number as
        v_n number;
    begin
        select sum(n)
        into v_n
        from (
            select count(*) n
            from
                b_estudiantes e
                    inner join
                b_prematricula p
                    on e.codigo = p.codigo_estudiante
            where
                e.codigo = p_codigo
                and e.indicador_pago in ('P','V')
                and p.indicador_pago in ('P','V')
                and p.facultad_cursar >= '71'
            union all
            select count(*) n
            from
                cactualpre.b_estudiantes e
                    inner join
                cactualpre.b_prematricula p
                    on e.codigo = p.codigo_estudiante
            where
                e.codigo = p_codigo
                and e.indicador_pago in ('P','V')
                and p.indicador_pago in ('P','V')
                and p.facultad_cursar >= '71'
        ) x;
        return v_n;
    end esPostgradual;

    function porcentajeCreditosAprobados(
        p_codigo b_estudiantes.codigo%type,
        p_anio b_estudiantes.anio%type,
        p_ciclo b_estudiantes.ciclo%type
    )return number is
        sumcred        number default 0;
        v_plan         number;
        v_total_cred   number;
        v_semestres    number;
    begin
        select
            sum(x),
            sum(y),
            sum(z)
        into
            v_plan,
            v_total_cred,
            v_semestres
        from
            (
                select
                    max(e.plan_estudio)x,
                    sum(m.creditos)y,
                    max(m.semestre)z
                from
                    historico_estudiantes   e
                    inner join a_materias      m on e.codigo_facultad = m.codigo_facultad
                                               and e.jornada_facultad = m.jornada_facultad
                                               and e.plan_estudio = m.plan_estudio
                where
                    m.semestre > 0
                    and e.codigo = p_codigo
                    and e.anio = p_anio
                    and e.ciclo = p_ciclo
                union
                select
                    max(e.plan_estudio),
                    sum(m.creditos),
                    max(m.semestre)
                from
                    postgrado.historico_estudiantes   e
                    inner join postgrado.a_materias      m on e.codigo_facultad = m.codigo_facultad
                                                         and e.jornada_facultad = m.jornada_facultad
                                                         and e.plan_estudio = m.plan_estudio
                where
                    m.semestre > 0
                    and e.codigo = p_codigo
                    and e.anio = p_anio
                    and e.ciclo = p_ciclo
                union
                select
                    max(e.plan_estudio),
                    sum(m.creditos),
                    max(m.semestre)
                from
                    yopal.historico_estudiantes   e
                    inner join yopal.a_materias      m on e.codigo_facultad = m.codigo_facultad
                                                     and e.jornada_facultad = m.jornada_facultad /*and e.plan_estudio = m.plan_estudio*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
                where
                    m.semestre > 0
                    and e.codigo = p_codigo
                    and m.plan_estudio = e.plan_estudio
                    and e.anio = p_anio
                    and e.ciclo = p_ciclo
            )zz;

        if v_total_cred = 0 then
            return(-1);
        end if;
        select
            sum(cr)
        into sumcred
        from
            (
                select
                    nvl(sum(m.creditos),0)cr
                from
                    b_estudiantes   e
                    inner join a_notas         n on e.codigo = n.codigo_estudiante
                                            and e.plan_estudio = n.ind_hnvoplan
                    inner join a_materias      m on m.codigo = n.codigo_materia
                                               and m.plan_estudio = n.ind_hnvoplan
                                               and m.codigo_facultad = n.codigo_facultad
                                               and m.jornada_facultad = n.jornada_facultad
                where
                    n.codigo_estudiante = p_codigo
                    and((n.indicador != 'V'
                         and n.valor >= 3)
                        or(n.indicador = 'V'
                           and n.valor >= 3.5))
                    and n.ano || n.ciclo <= p_anio || case when p_ciclo = '02' then '03' else p_ciclo end
                union
                select
                    nvl(sum(m.creditos),0)cr
                from
                    postgrado.b_estudiantes   e
                    inner join postgrado.a_notas         n on e.codigo = n.codigo_estudiante
                                                      and e.plan_estudio = n.ind_hnvoplan
                    inner join postgrado.a_materias      m on m.codigo = n.codigo_materia
                                                         and m.plan_estudio = n.ind_hnvoplan
                                                         and m.codigo_facultad = n.codigo_facultad
                                                         and m.jornada_facultad = n.jornada_facultad
                where
                    n.codigo_estudiante = p_codigo
                    and n.valor >= 3.5
                    and n.ano || n.ciclo <= p_anio || case when p_ciclo = '02' then '03' else p_ciclo end
                union
                select
                    nvl(sum(m.creditos),0)cr
                from
                    yopal.b_estudiantes   e
                    inner join yopal.a_notas         n on e.codigo = n.codigo_estudiante /*and e.plan_estudio = n.ind_hnvoplan*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
                    inner join yopal.a_materias      m on m.codigo = n.codigo_materia /*and m.plan_estudio = n.ind_hnvoplan*/
                                                     and m.codigo_facultad = n.codigo_facultad
                                                     and m.jornada_facultad = n.jornada_facultad
                where
                    n.codigo_estudiante = p_codigo
                    and((n.indicador != 'V'
                         and n.valor >= 3)
                        or(n.indicador = 'V'
                           and n.valor >= 3.5))
                    and n.ano || n.ciclo <= p_anio || p_ciclo
            )zz;
        return(nvl(sumcred,0)/ v_total_cred);
    exception
        when others then
            return(sqlcode);
    end porcentajeCreditosAprobados;
    function getEstudianteAuth(
        p_codigo b_estudiantes.codigo%type
    ) return json is
        type t_est is record (
            codigo				varchar2(8),
            tipo_documento		varchar2(2),
            numero_documento	varchar2(12),
            tingreso			varchar2(2),
            cingreso			varchar2(5),
            codprograma			varchar2(2),
            nombreprograma		varchar2(100),
            codfacultad			varchar2(3),
            nombrefacultad		varchar2(50),
            jornada				varchar2(1),
            foto				varchar2(4000),
            pilo				number default 0,
            prueba				number default 0,
            anio				varchar2(4),
            ciclo				varchar2(2),
            ultimo				varchar2(9),
            indicador_pago		varchar2(1),
            usuario				varchar2(50)
        );
        est t_est;
        v_tipo number;
        v_codfac a_facultades.codigo%type;
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        v_esquema2 varchar2(32);
        j_est json;
        v_q varchar2(2048);
        v_tipo_de_estudiante varchar2(1);
    begin
        v_codfac := substr(p_codigo,0,2);
        if v_codfac = '46' then
            v_tipo := 4;
        else
            select to_number(max(p.codigo_tipo))
            into v_tipo
            from a_programas p
            where p.codigo = v_codfac;
            if v_tipo = 1 then
                v_tipo := 1;
            elsif v_tipo in (2,3,4) then
                v_tipo := 2;
            else
                raise_application_error(-20001, 'Tipo no valido');
            end if;
        end if;
        pkg_utils.getAnioCicloEsquema(to_char(v_tipo),v_anio,v_ciclo,v_esquema);
        if v_esquema = 'admisiones' then
            v_esquema := '';
            v_esquema2 := '';
        else
            if v_esquema = 'cactualpre' then
                v_esquema2 := 'admisiones.';
            elsif v_esquema = 'cactualpos' then
                v_esquema2 := 'postgrado.';
            elsif v_esquema = 'cactualyop' then
                v_esquema2 := 'yopal.';
            else
                v_esquema2 := v_esquema || '.';
            end if;
            v_esquema := v_esquema || '.';
        end if;
        begin
            v_q := 'select ' ||
                'e.codigo, ' ||
                'td.tipo, ' ||
                'dp.numero_documento, ' ||
                'e.tipo_de_ingreso, ' ||
                'e.ciclo_de_ingreso, ' ||
                'pr.codigo, ' ||
                'pr.nombre, ' ||
                'f.codigo_unidad, ' ||
                'f.nombre, ' ||
                'e.jornada_facultad, ' ||
                'pkg_utils.getfoto(e.codigo), to_number(' ||
                'pkg_utils.espilo(e.codigo)), to_number(' ||
                'pkg_utils.estasuspendido(e.codigo)), ' ||
                'e.anio, ' ||
                'e.ciclo, ' ||
                'pkg_estudiantes.fncUltimoPeriodoCursado(e.codigo), ' ||
                'e.indicador_pago, ' ||
                'da.usuario ' ||
                'from ' ||
                v_esquema || 'b_estudiantes e ' ||
                'inner join ' || v_esquema2 || 'datos_personales dp on e.codigo = dp.codigo_estudiante ' ||
                'inner join a_tipo_documento td on dp.codtipo_documento = td.codigo ' ||
                'inner join a_programas pr on pr.codigo = e.codigo_facultad and pr.jornada = e.jornada_facultad ' ||
                'inner join a_maestro_facultades f on f.codigo_unidad = pr.facultad ' ||
                'inner join cti_da_usuario da on da.codigo_estudiante = e.codigo ' ||
                'where ' ||
                'e.codigo = :codigo';
            execute immediate
                v_q
            into est
            using p_codigo;
        exception
        when no_data_found then
            raise_application_error(-20002, 'Estudiante no encontrado');
        end;
        j_est := json();
        json.put(j_est, 'codigo',est.codigo);
        json.put(j_est, 'tipo_documento',est.tipo_documento);
        json.put(j_est, 'numero_documento',est.numero_documento);
        json.put(j_est, 'tingreso',est.tingreso);
        json.put(j_est, 'cingreso',est.cingreso);
        json.put(j_est, 'codprograma',est.codprograma);
        json.put(j_est, 'nombreprograma',est.nombreprograma);
        json.put(j_est, 'codfacultad',est.codfacultad);
        json.put(j_est, 'nombrefacultad',est.nombrefacultad);
        json.put(j_est, 'jornada',est.jornada);
        json.put(j_est, 'foto',replace(est.foto, 'http://', 'https://'));
        json.put(j_est, 'pilo',est.pilo);
        json.put(j_est, 'prueba',est.prueba);
        json.put(j_est, 'anio',est.anio);
        json.put(j_est, 'ciclo',est.ciclo);
        json.put(j_est, 'indicador_pago',est.indicador_pago);
        json.put(j_est, 'ultimo',est.ultimo);
        json.put(j_est, 'usuario',est.usuario);
        
        BEGIN
            V_Q := q'!SELECT    CASE 
                                     WHEN G.CODIGO_ESTUDIANTE IS NOT NULL THEN 'G'
                                     WHEN E.INDICADOR_PAGO IN ('P', 'V', 'W') THEN 'A'
                                     ELSE 'N'
                                END TIPO
                      FROM      (SELECT CODIGO,
                                        INDICADOR_PAGO
                                 FROM   !' || V_ESQUEMA || q'!B_ESTUDIANTES) E
                      LEFT JOIN A_GRADUADOS G ON     E.CODIGO = G.CODIGO_ESTUDIANTE 
                                                 AND G.NUMERO_ACTA NOT IN ('0', '8888') 
                                                 AND G.FECHA_GRADO != to_date('01-01-1960','DD-MM-YYYY')  
                      WHERE     E.CODIGO = :codigo!';
            
            EXECUTE IMMEDIATE V_Q
            INTO  V_TIPO_DE_ESTUDIANTE
            USING P_CODIGO;
        EXCEPTION
        WHEN OTHERS THEN
            V_TIPO_DE_ESTUDIANTE := 'N';
        END;
        
        json.put(j_est, 'estado', V_TIPO_DE_ESTUDIANTE); 
        return j_est;
    exception
    when others then
        return null;
    end getEstudianteAuth;
    procedure getEstudiantesAuthByCedula(
        p_documento datos_personales.numero_documento%type
    ) is
        v_respuesta json := json();
        v_est json;
        v_list json_list := json_list();
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        for cod in (
            select dp.codigo_estudiante cod from datos_personales dp where dp.numero_documento = p_documento
            union
            select dp.codigo_estudiante cod from postgrado.datos_personales dp where dp.numero_documento = p_documento
            union
            select dp.codigo_estudiante cod from yopal.datos_personales dp where dp.numero_documento = p_documento
        ) loop
            v_est := getEstudianteAuth(cod.cod);
            if v_est is not null then
                json_list.append(v_list,v_est.to_json_value);
            end if;
        end loop;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getEstudiantesAuthByCedula;
end pkg_estudiantes;