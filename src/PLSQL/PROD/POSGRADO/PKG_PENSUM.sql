create or replace package body pkg_pensum as

    procedure getFacultades(
        p_codigo b_estudiantes.codigo%type default null
    )as
        j_fac json;
        v_list json_list := json_list();
        v_respuesta json := json();
    begin
        pkg_html.corsHeaders();
        for fac in (
            select     p.codigo, p.jornada, p.nombre
            from       admisiones.a_programas p
            inner join admisiones.a_facultades f on p.codigo = f.codigo and p.jornada = f.jornada
            where      (   P.FACULTAD IN ('FL', 'CB') 
                        OR (    p.codigo_tipo in ('002','003','004') 
                            and f.indicador in ('S')) )
                       and f.codigo not in (case when p_codigo is null then '00' else substr(p_codigo,1,2) end)
            order by   p.nombre
        ) loop
            j_fac := pkg_utils.getFacultad(fac.codigo, fac.jornada, 1, 1, 1);
            if j_fac is not null and json_list(j_fac.get('planes')).count > 0 then
                json_list.append(v_list,j_fac.to_json_value);
            end if;
        end loop;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getFacultades;

    procedure getMaterias(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type
    )as
        j_materias json_list;
        v_respuesta json := json();
    begin
        pkg_html.corsHeaders();
        j_materias := pkg_utils.getMaterias(p_codigo_facultad, p_jornada_facultad, p_plan_estudio, 0);
        json_list.htp(j_materias,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getMaterias;

    procedure getMateriasIntegradas(
        p_codigo_facultad    admisiones.a_facultades.codigo%type,
        p_jornada_facultad   admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type,
        p_codigo_materia     a_materias.codigo%type
    )as
        j_mat json;
        v_list json_list := json_list();
        v_respuesta json := json();
    begin
        pkg_html.corsHeaders();
        for mat in (
            select mi.codigo_facultad, mi.jornada_facultad, mi.plan_estudio, mi.codigo from
            a_materias m
            inner join
            cti_materias_integradas i
            on m.codigo_facultad = i.codigo_facultad and m.jornada_facultad = i.jornada_facultad and m.plan_estudio = i.plan_estudio and m.codigo = i.codigo_materia
            inner join
            a_materias mi
            on mi.codigo_facultad = i.codigo_facultad_eq and mi.jornada_facultad = i.jornada_facultad_eq and mi.plan_estudio = i.plan_estudio_eq and mi.codigo = i.codigo_materia_eq
            where
            m.codigo_facultad = p_codigo_facultad
            and m.jornada_facultad = p_jornada_facultad
            and m.plan_estudio = p_plan_estudio
            and m.codigo = p_codigo_materia
            order by 1, 2, 3, 4
        ) loop
            j_mat := pkg_utils.getMateria(mat.codigo_facultad, mat.jornada_facultad, mat.plan_estudio, mat.codigo, 1, 1);
            if j_mat is not null then
                json_list.append(v_list,j_mat.to_json_value);
            end if;
        end loop;
        json_list.htp(v_list,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end getMateriasIntegradas;

    procedure getResumenPensum(
        p_codigo_programa in a_planes_de_estudio.codigo_facultad%type,
        p_jornada_programa in a_planes_de_estudio.jornada_facultad%type,
        p_plan in a_planes_de_estudio.plan_estudio%type,
        o_semestres out number,
        o_creditos out number
    ) is
        n_tope cti_bolsas_creditos.tope%type;
    begin
        select sum(m.creditos), max(m.semestre)
        into o_creditos, o_semestres
        from a_materias m
        where m.codigo_facultad = p_codigo_programa
        and m.jornada_facultad = p_jornada_programa
        and m.plan_estudio = p_plan;
        select nvl(sum(b.tope), 0)
        into n_tope
        from cti_bolsas_creditos b
        where b.codigo_facultad = p_codigo_programa
        and b.jornada_facultad = p_jornada_programa
        and b.plan_estudio = p_plan;
        o_creditos := o_creditos + n_tope;
    exception
    when no_data_found then
        o_semestres := -1;
        o_creditos := -1;
    end getResumenPensum;

end pkg_pensum;
