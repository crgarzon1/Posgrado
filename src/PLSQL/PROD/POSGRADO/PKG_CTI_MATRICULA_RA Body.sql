CREATE OR REPLACE PACKAGE BODY PKG_CTI_MATRICULA_RA AS

    FUNCTION GETOFERTA (
        P_CODIGO_ESTUDIANTE   B_ESTUDIANTES.CODIGO%TYPE,
        V_ANIO                VARCHAR2,
        V_CICLO               VARCHAR2,
        V_ESQUEMA             VARCHAR2
    ) RETURN SYS_REFCURSOR IS
        OFERTA_REFCUR   SYS_REFCURSOR;
        V_QUERY         VARCHAR2 (4096);
    BEGIN
        IF ADMISIONES.PKG_PREMATRICULA.PUEDEVERTURORIAPOSTMALLA (P_CODIGO_ESTUDIANTE) = 1 THEN
            V_QUERY := 'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
            'from ' ||
            V_ESQUEMA ||
            '.b_estudiantes e ' ||
            'inner join ' ||
            'a_materias m ' ||
            'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
            'inner join ' ||
            V_ESQUEMA ||
            '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
            'where e.codigo = :cod ' ||
            'and pkg_utils.evaluar_pago (e.indicador_pago) in (1, 2)' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and m.area in (''T'') ' ||
            
            'union ' ||
            
            'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
            'from ' ||
            V_ESQUEMA ||
            '.b_estudiantes e ' ||
            'inner join ' ||
            'a_materias m ' ||
            'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
            'inner join ' ||
            'cti_materias_integradas mi ' ||
            'on mi.codigo_facultad = m.codigo_facultad and mi.jornada_facultad = m.jornada_facultad and mi.codigo_materia = m.codigo ' ||
            'inner join ' ||
            V_ESQUEMA ||
            '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = mi.CODIGO_FACULTAD_EQ and h.jornada_facultad = mi.JORNADA_FACULTAD_EQ and h.codigo_materia = mi.CODIGO_MATERIA_EQ ' ||
            'where e.codigo = :cod ' ||
            'and pkg_utils.evaluar_pago (e.indicador_pago) in (1, 2)' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and m.area in (''T'') ' ||
            'order by 4, 5';

            OPEN OFERTA_REFCUR FOR V_QUERY
                USING P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO, P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO;

        ELSE
            V_QUERY := 'select m.codigo_facultad, m.jornada_facultad, m.plan_estudio, m.semestre, m.codigo, h.consecutivo ' ||
            'from ' ||
            V_ESQUEMA ||
            '.b_estudiantes e ' ||
            'inner join ' ||
            'a_materias m ' ||
            'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
            'inner join ' ||
            V_ESQUEMA ||
            '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = m.codigo_facultad and h.jornada_facultad = m.jornada_facultad and h.plan_estudio = m.plan_estudio and h.codigo_materia = m.codigo ' ||
            'where e.codigo = :cod ' ||
            'and pkg_utils.evaluar_pago (e.indicador_pago) in (1, 2)' ||
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
            'from ' ||
            V_ESQUEMA ||
            '.b_estudiantes e ' ||
            'inner join ' ||
            'a_materias m ' ||
            'on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
            'inner join ' ||
            'cti_materias_integradas mi ' ||
            'on mi.codigo_facultad = m.codigo_facultad and mi.jornada_facultad = m.jornada_facultad and mi.codigo_materia = m.codigo ' ||
            'inner join ' ||
            V_ESQUEMA ||
            '.a_horario_horizontal h ' ||
            'on h.codigo_facultad = mi.CODIGO_FACULTAD_EQ and h.jornada_facultad = mi.JORNADA_FACULTAD_EQ and h.codigo_materia = mi.CODIGO_MATERIA_EQ ' ||
            'where e.codigo = :cod ' ||
            'and pkg_utils.evaluar_pago (e.indicador_pago) in (1, 2)' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo ' ||
            'and m.codigo not in ( ' ||
            'select rr.codigo_materia ' ||
            'from a_requisitos rr ' ||
            'where rr.codigo_facultad = e.codigo_facultad ' ||
            'and rr.plan_estudio = e.plan_estudio ' ||
            ') ' ||
            'and m.semestre > 0 ' ||
            'order by 4, 5';

            OPEN OFERTA_REFCUR FOR V_QUERY
                USING P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO, P_CODIGO_ESTUDIANTE, V_ANIO, V_CICLO;

        END IF;

        RETURN OFERTA_REFCUR;
    END GETOFERTA;

END PKG_CTI_MATRICULA_RA;