create or replace package body pkg_matricula as

    /*
FFFFFFFFFFFFFFFFFFFFFFIIIIIIIIIIXXXXXXX       XXXXXXXMMMMMMMM               MMMMMMMMEEEEEEEEEEEEEEEEEEEEEE
F::::::::::::::::::::FI::::::::IX:::::X       X:::::XM:::::::M             M:::::::ME::::::::::::::::::::E
F::::::::::::::::::::FI::::::::IX:::::X       X:::::XM::::::::M           M::::::::ME::::::::::::::::::::E
FF::::::FFFFFFFFF::::FII::::::IIX::::::X     X::::::XM:::::::::M         M:::::::::MEE::::::EEEEEEEEE::::E
  F:::::F       FFFFFF  I::::I  XXX:::::X   X:::::XXXM::::::::::M       M::::::::::M  E:::::E       EEEEEE
  F:::::F               I::::I     X:::::X X:::::X   M:::::::::::M     M:::::::::::M  E:::::E             
  F::::::FFFFFFFFFF     I::::I      X:::::X:::::X    M:::::::M::::M   M::::M:::::::M  E::::::EEEEEEEEEE   
  F:::::::::::::::F     I::::I       X:::::::::X     M::::::M M::::M M::::M M::::::M  E:::::::::::::::E   
  F:::::::::::::::F     I::::I       X:::::::::X     M::::::M  M::::M::::M  M::::::M  E:::::::::::::::E   
  F::::::FFFFFFFFFF     I::::I      X:::::X:::::X    M::::::M   M:::::::M   M::::::M  E::::::EEEEEEEEEE   
  F:::::F               I::::I     X:::::X X:::::X   M::::::M    M:::::M    M::::::M  E:::::E             
  F:::::F               I::::I  XXX:::::X   X:::::XXXM::::::M     MMMMM     M::::::M  E:::::E       EEEEEE
FF:::::::FF           II::::::IIX::::::X     X::::::XM::::::M               M::::::MEE::::::EEEEEEEE:::::E
F::::::::FF           I::::::::IX:::::X       X:::::XM::::::M               M::::::ME::::::::::::::::::::E
F::::::::FF           I::::::::IX:::::X       X:::::XM::::::M               M::::::ME::::::::::::::::::::E
FFFFFFFFFFF           IIIIIIIIIIXXXXXXX       XXXXXXXMMMMMMMM               MMMMMMMMEEEEEEEEEEEEEEEEEEEEEE
    */
    --Se deben incluir dentro de la lógica de matrícula los estudiantes postgraduales de pregrado y los cogrados.

    procedure getOferta(
        p_codigo b_estudiantes.codigo%type
    )as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        j_of json;
        j_mt json;
        j_gr json;
        v_list json_list := json_list();
        v_respuesta json := json();
        v_query varchar2(4096);
        oferta_refcur sys_refcursor;
        v_fac a_materias.codigo_facultad%type;
        v_jor a_materias.jornada_facultad%type;
        v_pln a_materias.plan_estudio%type;
        v_sem a_materias.semestre%type;
        v_cod a_materias.codigo%type;
        v_cod_ant a_materias.codigo%type := 'xxxxx';
        v_con a_horario_horizontal.consecutivo%type;
        v_grs json_list;
    begin
        pkg_html.corsHeaders();
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        if admisiones.pkg_prematricula.puedeVerTuroriaPostmalla(p_codigo) = 1 then
            v_query :=
                'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
                'from ' || v_esquema || '.b_estudiantes e ' ||
                'inner join ' ||
                'a_materias m ' ||
                'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
                'inner join ' ||
                v_esquema || '.a_horario_horizontal h ' ||
                'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
                'where e.codigo = :cod ' ||
                'and pkg_utils.evaluar_pago (e.indicador_pago) = 1' ||
                'and e.anio = :anio ' ||
                'and e.ciclo = :ciclo ' ||
                'and m.area in (''T'') ' ||
                'order by 4, 5';
            open oferta_refcur for v_query using p_codigo, v_anio, v_ciclo;
        else
            v_query :=
                'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
                'from ' || v_esquema || '.b_estudiantes e ' ||
                'inner join ' ||
                'a_materias m ' ||
                'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
                'inner join ' ||
                v_esquema || '.a_horario_horizontal h ' ||
                'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
                'where e.codigo = :cod ' ||
                'and pkg_utils.evaluar_pago (e.indicador_pago) = 1' ||
                'and e.anio = :anio ' ||
                'and e.ciclo = :ciclo ' ||
                'and m.codigo not in ( ' ||
                'select n.codigo_materia ' ||
                'from a_notas n ' ||
                'where n.codigo_estudiante = e.codigo and n.valor >= 3.5 ' ||
                'union ' ||
                'select rr.codigo_materia ' ||
                'from a_requisitos rr ' ||
                'where rr.codigo_facultad = e.codigo_facultad ' ||
                'and rr.plan_estudio = e.plan_estudio ' ||
                'and rr.requisito not in (select n.codigo_materia from postgrado.a_notas n where n.codigo_estudiante = e.codigo and n.valor >= 3.5) ' ||
                ') ' ||
                'and m.semestre > 0 ' ||
                'union ' ||
                'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
                'from ' || v_esquema || '.b_estudiantes e ' ||
                'inner join ' ||
                'a_materias m ' ||
                'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
                'inner join ' ||
                'a_materias_integradas mi ' ||
                'on mi.codigo_facultad = m.codigo_facultad and mi.jornada_facultad = m.jornada_facultad and mi.codigo_materia = m.codigo ' ||
                'inner join ' ||
                v_esquema || '.a_horario_horizontal h ' ||
                'on h.codigo_facultad = mi.facultad_equivalente and h.jornada_facultad = mi.jornada_equivalente and h.codigo_materia = mi.materia_equivalente ' ||
                'where e.codigo = :cod ' ||
                'and pkg_utils.evaluar_pago (e.indicador_pago) = 1' ||
                'and e.anio = :anio ' ||
                'and e.ciclo = :ciclo ' ||
                'and m.codigo not in ( ' ||
                'select n.codigo_materia ' ||
                'from a_notas n ' ||
                'where n.codigo_estudiante = e.codigo and n.valor >= 3.5 ' ||
                'union ' ||
                'select rr.codigo_materia ' ||
                'from a_requisitos rr ' ||
                'where rr.codigo_facultad = e.codigo_facultad ' ||
                'and rr.plan_estudio = e.plan_estudio ' ||
                'and rr.requisito not in (select n.codigo_materia from postgrado.a_notas n where n.codigo_estudiante = e.codigo and n.valor >= 3.5) ' ||
                ') ' ||
                'and m.semestre > 0 ' ||
                'order by 4, 5';
            open oferta_refcur for v_query using p_codigo, v_anio, v_ciclo, p_codigo, v_anio, v_ciclo;
        end if;
        loop
            fetch oferta_refcur into v_fac,v_jor,v_pln,v_sem,v_cod,v_con;
            exit when oferta_refcur%notfound;
            if v_cod_ant != v_cod then
                if j_of is not null then
                    json.put(j_of,'grupos',v_grs.to_json_value);
                    json_list.append(v_list,j_of.to_json_value);
                end if;
                v_cod_ant := v_cod;
                j_of := json();
                v_grs := json_list();
                j_mt := pkg_utils.getMateria(v_fac, v_jor, v_pln, v_cod, 1);
                if j_mt is not null then
                    json.put(j_of,'materia',j_mt.to_json_value);
                end if;    
            end if;
            j_gr := pkg_utils.getGrupo(v_con);
            if j_gr is not null then
                json_list.append(v_grs,j_gr.to_json_value);
            end if;
        end loop;
        close oferta_refcur;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getOferta;
    
    procedure getMatricula(
        p_codigo b_estudiantes.codigo%type
    )as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        j_of json;
        j_mt json;
        j_gr json;
        v_list json_list := json_list();
        v_respuesta json := json();
        v_query varchar2(4096);
        oferta_refcur sys_refcursor;
        v_fac a_materias.codigo_facultad%type;
        v_jor a_materias.jornada_facultad%type;
        v_pln a_materias.plan_estudio%type;
        v_bol number;
        v_cod a_materias.codigo%type;
        v_cod_ant a_materias.codigo%type := 'xxxxx';
        v_con a_horario_horizontal.consecutivo%type;
        v_grs json_list;
    begin
        pkg_html.corsHeaders();
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        --FIXME: seguro no funciona con RAs!!!
        v_query :=
            'select p.facultad, p.jornada_facultad, e.plan_estudio, p.materia_plan, p.consecutivo, 0 bolsa ' ||
            'from ' || v_esquema || '.b_estudiantes e ' ||
            'inner join ' ||
            v_esquema || '.b_prematricula p ' ||
            'on e.codigo = p.codigo_estudiante ' ||
            'where e.codigo = :codigo ' ||
            'and pkg_utils.evaluar_pago (e.indicador_pago) = 1' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and pkg_utils.evaluar_pago(e.indicador_pago) = 1 ' ||
            'and pkg_bolsas.esGrupoBolsa(e.codigo, p.consecutivo) = 0 ' ||
            'union ' ||
            'select h.codigo_facultad, h.jornada_facultad, h.plan_estudio, h.codigo_materia, h.consecutivo, 1 bolsa ' ||
            'from ' || v_esquema || '.b_prematricula bp ' ||
            'inner join ' || v_esquema || '.a_horario_horizontal h ' ||
            'on bp.consecutivo = h.consecutivo ' ||
            'where bp.codigo_estudiante = :codigo ' ||
            'and bp.anio = :anio ' ||
            'and bp.ciclo = :ciclo ' ||
            'and pkg_utils.evaluar_pago(bp.indicador_pago) = 1 ' ||
            'and pkg_bolsas.esGrupoBolsa(bp.codigo_estudiante, h.consecutivo) = 1 ' ||
            'order by 4, 5';
        open oferta_refcur for v_query using p_codigo, v_anio, v_ciclo, p_codigo, v_anio, v_ciclo;
        loop
            fetch oferta_refcur into v_fac,v_jor,v_pln,v_cod,v_con,v_bol;
            exit when oferta_refcur%notfound;
            if v_cod_ant != v_cod then
                if j_of is not null then
                    json.put(j_of,'grupos',v_grs.to_json_value);
                    json_list.append(v_list,j_of.to_json_value);
                end if;
                v_cod_ant := v_cod;
                j_of := json();
                v_grs := json_list();
                j_mt := pkg_utils.getMateria(v_fac, v_jor, v_pln, v_cod, 1);
                if j_mt is not null then
                    json.put(j_of,'materia',j_mt.to_json_value);
                    json.put(j_of,'bolsa',v_bol);
                end if;    
            end if;
            j_gr := pkg_utils.getGrupo(v_con);
            if j_gr is not null then
                json_list.append(v_grs,j_gr.to_json_value);
            end if;
        end loop;
        json.put(j_of,'grupos',v_grs.to_json_value);
        json_list.append(v_list,j_of.to_json_value);
        close oferta_refcur;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getMatricula;
    
    procedure getResumenCreditos(
        p_codigo b_estudiantes.codigo%type,
        o_cred_max out cti_bolsa_general.tope%type,
        o_sem_inferior out number,
        o_cred_inscritos out number,
        o_cred_bolsa out number
    )as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        v_disponibles cti_bolsa_general.disponibles%type;
    begin
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        execute immediate
            'select nvl(sum(m.creditos), 0), nvl(min(m.semestre), 0) ' ||
            'from ' || v_esquema || '.b_estudiantes e ' ||
            'inner join ' || v_esquema || '.b_prematricula p ' ||
            'on e.codigo = p.codigo_estudiante ' ||
            'inner join ' ||
            'a_materias m ' ||
            'on p.facultad = m.codigo_facultad and p.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio and p.materia_plan = m.codigo ' ||
            'where e.codigo = :codigo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and pkg_bolsas.esGrupoBolsa(e.codigo, p.consecutivo) = 0'
        into o_cred_inscritos, o_sem_inferior
        using p_codigo, v_anio, v_ciclo;
        execute immediate
            'select nvl(sum(m.creditos), 0) ' ||
            'from ' || v_esquema || '.b_estudiantes e ' ||
            'inner join ' || v_esquema || '.b_prematricula p ' ||
            'on e.codigo = p.codigo_estudiante ' ||
            'inner join ' || v_esquema || '.a_horario_horizontal h ' ||
            'on h.consecutivo = p.consecutivo ' ||
            'inner join a_materias m ' ||
            'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
            'where e.codigo = :codigo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and pkg_bolsas.esGrupoBolsa(e.codigo, p.consecutivo) = 1'
        into o_cred_bolsa
        using p_codigo, v_anio, v_ciclo;
        begin
            select bg.tope, bg.disponibles
            into o_cred_max, v_disponibles
            from cti_bolsa_general bg
            where bg.codigo = p_codigo
            and bg.anio = v_anio
            and bg.ciclo = v_ciclo;
        exception
        when no_data_found then
            o_cred_max := 0;
            v_disponibles := 0;
        end;
        if o_cred_max - (o_cred_inscritos + o_cred_bolsa) != v_disponibles then
            raise_application_error(-20000, p_codigo || ': Los valores de creditos inscritos y de bolsas, no corresponden a la bolsa general de creditos, rectifique el registro.');
        end if;
    exception
    when others then
        o_cred_max := 0;
        o_sem_inferior := 0;
        o_cred_inscritos := 0;
        o_cred_bolsa := 0;
    end getResumenCreditos;
    
    procedure getEstudiante(
        p_codigo b_estudiantes.codigo%type
    ) as
        j_est json;
        v_fecha_pivote date;
        v_fecha_inicio date;
        v_fecha_fin date;
        o_cred_max cti_bolsa_general.tope%type;
        o_sem_inferior number;
        o_cred_inscritos number;
        o_cred_bolsa number;
        v_respuesta json := json();
    begin
        pkg_html.corsHeaders();
        j_est := pkg_utils.getEstudiante(p_codigo);
        getResumenCreditos(
            p_codigo,
            o_cred_max,
            o_sem_inferior,
            o_cred_inscritos,
            o_cred_bolsa
        );
        select fecha_inicio
        into v_fecha_pivote
        from admisiones.a_fechas_de_corte
        where proceso = 'INICIO-FIN-CLASES TRIMESTRE 2 POSGRADO';
        select fecha_inicio, fecha_finalizacion
        into v_fecha_inicio, v_fecha_fin
        from admisiones.a_fechas_de_corte
        where proceso = 'INICIO-FIN SEMESTRE-POSTGRADO';
        json.put(j_est,'creditos_maximos',o_cred_max);
        json.put(j_est,'semestre_inferior',o_cred_max);
        json.put(j_est,'creditos_inscritos',o_cred_inscritos);
        json.put(j_est,'creditos_bolsa',o_cred_bolsa);
        json.put(j_est,'fecha_pivote',admisiones.pkg_utils.toChar(v_fecha_pivote));
        json.put(j_est,'fecha_inicio',admisiones.pkg_utils.toChar(v_fecha_inicio));
        json.put(j_est,'fecha_fin',admisiones.pkg_utils.toChar(v_fecha_fin));
        json.htp(j_est,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getEstudiante;
    
    procedure inscribir(
        p_arg nclob,
        p_usuario_aud nclob
    ) as
        v_json varchar2(2048);
        p_codigo b_estudiantes.codigo%type;
        p_mplan a_materias.codigo%type;
        p_consecutivo a_horario_horizontal.consecutivo%type;
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        v_respuesta json := json();
        n_vencido number;
        n_isra number;
        n_cred number;
        n_bolsa number;
        j_arg json;
        j_usr json;
    begin
        pkg_html.corsHeaders();
        v_json := p_arg;
        j_arg := json(v_json);
        p_codigo := j_arg.get('c').get_string;
        p_mplan := j_arg.get('m').get_string;
        p_consecutivo := j_arg.get('n').get_number;
        begin
            n_bolsa := j_arg.get('b').get_number;
        exception
        when others then
            n_bolsa := -1;
        end;
        j_usr := json(p_usuario_aud);
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        select sum(x.n)
        into n_vencido
        from (
            select count(*) n
            from admisiones.a_bloques_pos bl
            where bl.consecutivo = p_consecutivo
            and bl.fecha_final > sysdate
            union
            select count(*) n
            from cactualpre.a_bloques_pos bl
            where bl.consecutivo = p_consecutivo
            and bl.fecha_final > sysdate
        ) x;
        if n_vencido <= 0 then
            raise_application_error(-20008, 'Grupo ya finalizado.');
        end if;
        --Se determina si el estudiante es RA, ME o NR que tienen inscripción a materia plan igual a la cursar.
        execute immediate
            'select count(*) ' ||
            'from ' || v_esquema || '.b_estudiantes e ' ||
            'where e.codigo = :codigo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and e.ciclo_de_ingreso = e.anio || to_number(e.ciclo) ' ||
            'and e.tipo_de_ingreso in ( ' ||
            'select ' ||
            't.tipo ' ||
            'from ' ||
            'admisiones.a_tipo_estudiante t, ' ||
            'admisiones.cti_grupo_tipo_est gr ' ||
            'where ' ||
            't.codigo = gr.codigo_tipo ' ||
            'and gr.id_grupo in (12) ' ||
            ')'
        into n_isra
        using p_codigo, v_anio, v_ciclo;
        --Si no es RA y no es inscripcion por bolsa.
        if n_isra = 0 and n_bolsa <= 0 then
            begin
                select m.creditos
                into n_cred
                from b_estudiantes e
                inner join
                a_materias m
                on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
                where e.codigo = p_codigo
                and m.codigo = p_mplan;
            exception
            when others then
                raise_application_error(-20008, 'No se ha localizado la materia: ' || p_mplan);
            end;
            --Inscripción de la materia en la prematricula, no funciona si no pertenece al plan.
            execute immediate
                'insert into ' || v_esquema || '.b_prematricula ' ||
                'select e.codigo, e.codigo_facultad, m.codigo, h.codigo_facultad, h.codigo_materia, h.grupo_materia, e.jornada_facultad, null, sysdate, null, null, e.indicador_pago, null, e.anio, e.ciclo, e.codmil, null, e.nombre, null, h.consecutivo ' ||
                'from ' || v_esquema || '.b_estudiantes e ' ||
                'inner join ' ||
                'a_materias m ' ||
                'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio, ' ||
                v_esquema || '.a_horario_horizontal h ' ||
                'where ' ||
                'e.codigo = :codigo ' ||
                'and m.codigo = :mplan ' ||
                'and h.consecutivo = :consecutivo ' ||
                'and e.anio = :anio ' ||
                'and e.ciclo = :ciclo ' ||
                'and pkg_utils.evaluar_pago(e.indicador_pago)=1'
            using p_codigo, p_mplan, p_consecutivo, v_anio, v_ciclo;
            if sql%rowcount != 1 then
                raise_application_error(-20001, 'No se logro registrar la asignatura');
            end if;
            --Si el grupo está cerrado, se hace la inserción a la tabla de notas parciales
            insert into b_prematricula_notas_depurada(
                codigo_estudiante,
                facultad,
                materia_plan,
                facultad_cursar,
                materia_cursar,
                grupo,
                jornada_facultad,
                fecha,
                indicador_pago,
                codmil,
                nombre,
                anio,
                ciclo,
                consecutivo
            )
            select
                e.codigo,
                e.codigo_facultad,
                m.codigo,
                h.codigo_facultad,
                h.codigo_materia,
                h.grupo_materia,
                e.jornada_facultad,
                sysdate,
                e.indicador_pago,
                e.codmil,
                e.nombre,
                e.anio,
                e.ciclo,
                h.consecutivo
            from b_estudiantes e
            inner join
            a_materias m
            on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio,
            ah_horizontal_actual h
            where
            e.codigo = p_codigo
            and m.codigo = p_mplan
            and h.consecutivo = p_consecutivo
            and e.anio = v_anio
            and e.ciclo = v_ciclo
            and pkg_utils.evaluar_pago(e.indicador_pago)=1;
        --Entre si es RA o inscripcion por bolsa
        else
            begin
                execute immediate
                    'select m.creditos ' ||
                    'from ' || v_esquema || '.a_horario_horizontal h ' ||
                    'inner join ' ||
                    'a_materias m ' ||
                    'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
                    'where h.consecutivo = :consecutivo'
                into n_cred
                using p_consecutivo;
            exception
            when others then
                raise_application_error(-20008, 'No se ha localizado la materia: ' || p_mplan || ' -> ' || sqlerrm);
            end;
            --Inscripción de la materia en la prematricula, la materia cursar es la misma que la plan.
            execute immediate
                'insert into ' || v_esquema || '.b_prematricula ' ||
                'select e.codigo, e.codigo_facultad, m.codigo, h.codigo_facultad, h.codigo_materia, h.grupo_materia, e.jornada_facultad, null, sysdate, null, null, e.indicador_pago, null, e.anio, e.ciclo, e.codmil, null, e.nombre, null, h.consecutivo ' ||
                'from ' || v_esquema || '.b_estudiantes e, ' ||
                'a_materias m ' ||
                'inner join ' ||
                v_esquema || '.a_horario_horizontal h ' ||
                'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.codigo_materia = m.codigo ' ||
                'where ' ||
                'e.codigo = :codigo ' ||
                'and h.consecutivo = :consecutivo ' ||
                'and e.anio = :anio ' ||
                'and e.ciclo = :ciclo ' ||
                'and pkg_utils.evaluar_pago(e.indicador_pago)=1'
            using p_codigo, p_consecutivo, v_anio, v_ciclo;
            if sql%rowcount != 1 then
                raise_application_error(-20011, 'No se logro registrar la asignatura');
            end if;
            --Si el grupo está cerrado, se hace la inserción a la tabla de notas parciales
            insert into b_prematricula_notas_depurada(
                codigo_estudiante,
                facultad,
                materia_plan,
                facultad_cursar,
                materia_cursar,
                grupo,
                jornada_facultad,
                fecha,
                indicador_pago,
                codmil,
                nombre,
                anio,
                ciclo,
                consecutivo
            )
            select
                e.codigo,
                e.codigo_facultad,
                m.codigo,
                h.codigo_facultad,
                h.codigo_materia,
                h.grupo_materia,
                e.jornada_facultad,
                sysdate, 
                e.indicador_pago,
                e.codmil,
                e.nombre,
                e.anio,
                e.ciclo,
                h.consecutivo
            from b_estudiantes e,
            a_materias m
            inner join
            ah_horizontal_actual h
            on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.codigo_materia = m.codigo
            where
            e.codigo = p_codigo
            and h.consecutivo = p_consecutivo
            and e.anio = v_anio
            and e.ciclo = v_ciclo
            and pkg_utils.evaluar_pago(e.indicador_pago)=1;
            if n_bolsa > 0 then
                execute immediate
                    'insert into cti_bolsa_est_mat ' ||
                    'select be.id_bolsa_est, m.codigo, m.plan_estudio, m.codigo_facultad, m.jornada_facultad, h.anio, h.ciclo, 3 ' ||
                    'from ' || v_esquema || '.b_estudiantes e ' ||
                    'inner join ' ||
                    'cti_bolsa_estudiante be ' ||
                    'on e.codigo = be.codigo, ' ||
                    'a_materias m ' ||
                    'inner join ' ||
                    v_esquema || '.a_horario_horizontal h ' ||
                    'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.codigo_materia = m.codigo ' ||
                    'where ' ||
                    'e.codigo = :codigo ' ||
                    'and h.consecutivo = :consecutivo ' ||
                    'and e.anio = :anio ' ||
                    'and e.ciclo = :ciclo ' ||
                    'and be.id_bolsa = :bolsa ' ||
                    'and pkg_utils.evaluar_pago(e.indicador_pago)=1'
                using p_codigo, p_consecutivo, v_anio, v_ciclo, n_bolsa;
                if sql%rowcount != 1 then
                    raise_application_error(-20002, 'No se logro agregar el espacio académico a la bolsa de créditos del estudiante.');
                end if;
            end if;
        end if;
        update cti_bolsa_general bg
        set bg.disponibles = bg.disponibles - n_cred
        where bg.codigo = p_codigo
        and bg.anio = v_anio
        and bg.ciclo = v_ciclo
        and bg.disponibles - n_cred >= 0;
        if sql%rowcount != 1 then
            raise_application_error(-20002, 'No tiene créditos disponibles para hacer esta transacción.');
        end if;
        execute immediate
            'insert into admisiones.prematricula_logs ' ||
            'select admisiones.seq_logs_prematricula.nextval, sysdate, :ip, :usr, e.codigo, :accion, m.codigo || '' '' || m.nombre || ''('' || h.codigo_materia || '' gr.'' || h.grupo_materia || '')'', h.anio, h.ciclo, :perfil ' ||
            'from ' || v_esquema || '.b_estudiantes e, ' ||
            'a_materias m  ' ||
            'inner join ' ||
            v_esquema || '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.codigo_materia = m.codigo ' ||
            'where ' ||
            'e.codigo = :codigo ' ||
            'and h.consecutivo = :consecutivo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo'
        using j_usr.get('i').get_string, j_usr.get('id').get_string, 'ADD', j_usr.get('pe').get_string, p_codigo, p_consecutivo, v_anio, v_ciclo;
        commit;
        json.put(v_respuesta,'status','ok');
        json.put(v_respuesta,'mensaje','ok');
        json.htp(v_respuesta,false);
    exception
    when others then
        rollback;
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end inscribir;
    
    procedure modificarCupo(
        p_consecutivo a_horario_horizontal.consecutivo%type,
        p_inc number
    ) as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
    begin
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        if p_inc = 1 then
            execute immediate
                'update ' || v_esquema || '.a_horario_horizontal h set ' ||
                'h.cupo_utilizado = h.cupo_utilizado + 1 ' ||
                'where h.consecutivo = :consecutivo and h.cupo - (h.cupo_utilizado + 1) >= 0'
            using p_consecutivo;
        elsif p_inc = -1 then
            execute immediate
                'update ' || v_esquema || '.a_horario_horizontal h set ' ||
                'h.cupo_utilizado = h.cupo_utilizado - 1 ' ||
                'where h.consecutivo = :consecutivo'
            using p_consecutivo;
        else
            raise_application_error(-20000, 'No se puede procesar la solicitud.');
        end if;
        if sql%rowcount != 1 then 
            raise_application_error(-20001, '[' || p_consecutivo || '] ' || (case p_inc when 1 then 'Sin cupo' else 'No se recuperó el cupo' end));
        end if;
    end modificarCupo;
    
    procedure desinscribir(
        p_arg nclob,
        p_usuario_aud nclob
    ) as
        v_json varchar2(2048);
        p_codigo b_estudiantes.codigo%type;
        p_consecutivo a_horario_horizontal.consecutivo%type;
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        v_respuesta json := json();
        j_arg json;
        j_usr json;
        n_cred number;
        n_has_notas number;
        n_bolsa number;
        n_vencido number;
        r_bem cti_bolsa_est_mat%rowtype;
    begin
        pkg_html.corsHeaders();
        v_json := p_arg;
        j_arg := json(v_json);
        p_codigo := j_arg.get('c').get_string;
        p_consecutivo := j_arg.get('n').get_number;
        begin
            n_bolsa := j_arg.get('b').get_number;
        exception
        when others then
            n_bolsa := -1;
        end;
        j_usr := json(p_usuario_aud);
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        select sum(x.n)
        into n_vencido
        from (
            select count(*) n
            from admisiones.a_bloques_pos bl
            where bl.consecutivo = p_consecutivo
            and bl.fecha_final > sysdate
            union
            select count(*) n
            from cactualpre.a_bloques_pos bl
            where bl.consecutivo = p_consecutivo
            and bl.fecha_final > sysdate
        ) x;
        if n_vencido <= 0 then
            raise_application_error(-20008, 'Grupo ya finalizado.');
        end if;
        select count(*)
        into n_has_notas
        from b_prematricula_notas_depurada nd
        where nd.codigo_estudiante = p_codigo
        and nd.consecutivo = p_consecutivo
        and nd.definitiva is not null;
        if n_has_notas > 0 then
            raise_application_error(-20001, 'No se puede eliminar el grupo porque tiene notas registradas.');
        end if;
        if n_bolsa <= 0 then
            begin
                execute immediate
                    'select m.creditos ' ||
                    'from ' || v_esquema || '.b_prematricula p ' ||
                    'inner join ' ||
                    'a_materias m ' ||
                    'on p.facultad = m.codigo_facultad and p.jornada_facultad = m.jornada_facultad and p.materia_plan = m.codigo ' ||
                    'where p.consecutivo = :consecutivo ' ||
                    'and p.codigo_estudiante = :codigo'
                into n_cred
                using p_consecutivo, p_codigo;
            exception
            when others then
                raise_application_error(-20002, 'No se ha localizado la materia: ' || sqlerrm);
            end;
        else
            begin
                execute immediate
                    'select m.creditos ' ||
                    'from ' || v_esquema || '.a_horario_horizontal h ' ||
                    'inner join ' ||
                    'a_materias m ' ||
                    'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
                    'where h.consecutivo = :consecutivo'
                into n_cred
                using p_consecutivo;
            exception
            when others then
                raise_application_error(-20008, 'No se ha localizado la materia: ' || sqlerrm);
            end;
        end if;
        execute immediate
            'delete from ' || v_esquema || '.b_prematricula p ' ||
            'where p.codigo_estudiante = :codigo ' ||
            'and p.consecutivo = :consecutivo'
        using p_codigo, p_consecutivo;
        delete from b_prematricula_notas_depurada nd
        where nd.codigo_estudiante = p_codigo
        and nd.consecutivo = p_consecutivo
        and nd.definitiva is null;
        if n_bolsa > 0 then
            begin
                select bem.*
                into r_bem
                from b_estudiantes e
                inner join cti_bolsa_estudiante be
                on e.codigo = be.codigo
                inner join cti_bolsa_est_mat bem
                on be.id_bolsa_est = bem.id_bolsa_estudiante
                inner join a_horario_horizontal h
                on bem.codigo_facultad = h.codigo_facultad and bem.jornada_facultad = h.jornada_facultad and bem.plan_estudio = h.plan_estudio and bem.codigo_materia = h.codigo_materia
                where e.codigo = p_codigo
                and h.consecutivo = p_consecutivo
                union
                select bem.*
                from cactualpos.b_estudiantes e
                inner join cti_bolsa_estudiante be
                on e.codigo = be.codigo
                inner join cti_bolsa_est_mat bem
                on be.id_bolsa_est = bem.id_bolsa_estudiante
                inner join cactualpos.a_horario_horizontal h
                on bem.codigo_facultad = h.codigo_facultad and bem.jornada_facultad = h.jornada_facultad and bem.plan_estudio = h.plan_estudio and bem.codigo_materia = h.codigo_materia
                where e.codigo = p_codigo
                and h.consecutivo = p_consecutivo;
            exception
            when others then
                raise_application_error(-20002, 'Grupo mal formado, cierres mal elaborados: ' || p_consecutivo || ' -> ' || sqlerrm);
            end;
            delete from cti_bolsa_est_mat bem
            where bem.id_bolsa_estudiante = r_bem.id_bolsa_estudiante
            and bem.codigo_facultad = r_bem.codigo_facultad
            and bem.jornada_facultad = r_bem.jornada_facultad
            and bem.plan_estudio = r_bem.plan_estudio
            and bem.codigo_materia = r_bem.codigo_materia
            and bem.id_estado = 3;
        end if;
        --Luego de eliminar el espacio académico, libera créditos.
        update cti_bolsa_general bg
        set bg.disponibles = bg.disponibles + n_cred
        where bg.codigo = p_codigo
        and bg.anio = v_anio
        and bg.ciclo = v_ciclo;
        execute immediate
            'insert into admisiones.prematricula_logs ' ||
            'select admisiones.seq_logs_prematricula.nextval, sysdate, :ip, :usr, e.codigo, :accion, m.codigo || '' '' || m.nombre || ''('' || h.codigo_materia || '' gr.'' || h.grupo_materia || '')'', h.anio, h.ciclo, :perfil ' ||
            'from ' || v_esquema || '.b_estudiantes e, ' ||
            'a_materias m  ' ||
            'inner join ' ||
            v_esquema || '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.codigo_materia = m.codigo ' ||
            'where ' ||
            'e.codigo = :codigo ' ||
            'and h.consecutivo = :consecutivo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo'
        using j_usr.get('i').get_string, j_usr.get('id').get_string, 'DEL', j_usr.get('pe').get_string, p_codigo, p_consecutivo, v_anio, v_ciclo;
        commit;
        json.put(v_respuesta,'status','ok');
        json.put(v_respuesta,'mensaje','ok');
        json.htp(v_respuesta,false);
    exception
    when others then
        rollback;
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end desinscribir;
    
end pkg_matricula;