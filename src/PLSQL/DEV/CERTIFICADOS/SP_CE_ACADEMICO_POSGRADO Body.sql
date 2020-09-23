create or replace PACKAGE BODY SP_CE_ACADEMICO_POSGRADO IS
  PROCEDURE PR_TERMINACION_PLAN_JSON(p_codigo_estudiante varchar2) IS
    CURSOR c_terminacionplan IS
      SELECT e.nombre AS nombres_estudiante,
             e.codigo AS codigo_estudiante,
             UPPER(SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE(t.valor)) AS tipo_documento,
             d.numero_documento,
             UPPER(d.departamento_documento) AS departamento_documento,
             UPPER(d.ciudad_documento) AS ciudad_documento,
             UPPER(e.sexo) as genero,
             UPPER(f.nombre) AS programa,
             (CASE
               WHEN e.jornada_facultad = 'D' THEN
                'DIURNA'
               WHEN e.jornada_facultad = 'N' THEN
                'NOCTURNA'
               ELSE
                e.jornada_facultad
             END) AS jornada,
             m.semestre AS periodos_programa,
             SP_CE_ACADEMICO_UTIL.FN_PERIODO_PROGRAMA_LETRAS(m.semestre) AS periodos_programa_letras,
             'SEMESTRES' periodicidad,
             (CASE WHEN pys.ano_terminacion IS NOT NULL THEN pys.ano_terminacion
                   WHEN n.periodo IS NOT NULL THEN TO_NUMBER(SUBSTR(n.periodo, 1, 4))
                   ELSE NULL
             END) AS anio_terminacion,
             (CASE WHEN TRIM(pys.ciclo_de_terminacion) IS NOT NULL THEN TRIM(pys.ciclo_de_terminacion)
                   WHEN n.periodo IS NOT NULL THEN SUBSTR(n.periodo, 5)
                   ELSE NULL
              END) AS ciclo_terminacion,
             (CASE WHEN TRIM(pys.ano_terminacion) IS NOT NULL THEN
                        SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_T_LETRAS(pys.ano_terminacion, TRIM(pys.ciclo_de_terminacion))
                   WHEN n.periodo IS NOT NULL THEN
                        SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_T_LETRAS(SUBSTR(n.periodo, 1, 4), SUBSTR(n.periodo, 5))
                   ELSE NULL
              END) AS periodo_terminacion,
             SP_CE_ACADEMICO_UTIL.FN_SANCIONES(e.codigo, 2) AS sanciones,
             p.codigo_tipo AS codigo_tipo_programa,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_DEL_A(UPPER(e.sexo)) AS del_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_INTERESADO_A(UPPER(e.sexo)) AS interesado_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_IDENTIFICADO_A(UPPER(e.sexo)) AS identificado_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_MATRICULADO_A(UPPER(e.sexo)) AS matriculado_a,
             e.plan_estudio,
             SP_CE_ACADEMICO_UTIL.FN_TIPO_PLAN_ESTUDIO(e.plan_estudio) AS tipo_plan_estudio
        FROM postgrado.b_estudiantes e
        JOIN admisiones.a_facultades_unica f
          ON (e.codigo_facultad = f.codigo_facultad)
        JOIN admisiones.a_facultades f2
          ON (e.codigo_facultad = f2.codigo AND
              e.jornada_facultad = f2.jornada)
        JOIN postgrado.datos_personales d
          ON (e.codigo = d.codigo_estudiante)
        JOIN admisiones.a_tipo_documento t
          ON (DECODE(d.codtipo_documento,'07','01', d.codtipo_documento) = t.codigo)
        JOIN admisiones.a_programas p
          ON (f2.codigo = p.codigo AND f2.jornada = p.jornada)
        LEFT JOIN (SELECT codigo_estudiante, MAX(ano || ciclo) AS periodo
                    FROM postgrado.a_notas
                   WHERE ciclo IN ('01','02','03','04')
                   GROUP BY codigo_estudiante) n
          ON (n.codigo_estudiante = e.codigo)
        LEFT JOIN (SELECT eg.codigo_estudiante,
                          eg.ano_terminacion,
                          eg.ciclo_de_terminacion
                    FROM postgrado.relacion_pys_egresado eg
                   WHERE TRIM(eg.ciclo_de_terminacion) IN ('01','02','03','04', 'PRIMER', 'SEGUNDO')
                   ) pys
          ON (pys.codigo_estudiante = e.codigo)
        JOIN (SELECT m.codigo_facultad,
                     m.jornada_facultad,
                     m.plan_estudio,
                     MAX(m.semestre) AS semestre
                FROM postgrado.a_materias m
               GROUP BY m.codigo_facultad,
                        m.jornada_facultad,
                        m.plan_estudio) m
          ON (m.codigo_facultad = e.codigo_facultad AND
             m.jornada_facultad = e.jornada_facultad AND
             m.plan_estudio = e.plan_estudio)
        LEFT JOIN (SELECT g.codigo_estudiante, g.fecha_grado, g.numero_acta
                    FROM admisiones.a_graduados g
                   WHERE g.fecha_grado > to_date('01/01/1960', 'DD/MM/YYYY')
                  )grf
          ON e.codigo = grf.codigo_estudiante
       WHERE (e.materias_pendientes = 0 OR grf.codigo_estudiante IS NOT NULL)
         AND e.codigo = p_codigo_estudiante;
    v_reg c_terminacionplan%rowtype;
    v_promedio NUMBER;  
    v_promedio_letras VARCHAR2(100);
  BEGIN
    OPEN c_terminacionplan;
    LOOP
      FETCH c_terminacionplan INTO v_reg;
      IF c_terminacionplan%NOTFOUND THEN
          htp.prn('{}');
          EXIT;
      END IF;

      IF v_reg.anio_terminacion IS NULL OR v_reg.ciclo_terminacion IS NULL THEN
          raise_application_error(-20004, 'Estudiante sin periodos cursados');
          EXIT;
      END IF;

      v_promedio := ADMISIONES.PKG_UTILS.promedioponderadototal(p_codigo_estudiante);
      v_promedio_letras := SP_CE_ACADEMICO_UTIL.FN_HISTORIA_ACAD_NUMERO(TO_CHAR(v_promedio));

      htp.prn('{"nombresEstudiante":"' || v_reg.nombres_estudiante ||
              '","codigoEstudiante":"' || v_reg.codigo_estudiante ||
              '","tipoDocumento":"' || v_reg.tipo_documento ||
              '","numeroDocumento":"' || v_reg.numero_documento ||
              '","departamentoDocumento":"' || v_reg.departamento_documento ||
              '","ciudadDocumento":"' || v_reg.ciudad_documento ||
              '","genero":"' || v_reg.genero ||
              '","programa":"' || v_reg.programa ||
              '","jornada":"' || v_reg.jornada ||
              '","periodosPrograma":"' || v_reg.periodos_programa ||
              '","periodosProgramaLetras":"' || v_reg.periodos_programa_letras ||
              '","periodicidad":"' || v_reg.periodicidad ||
              '","periodoTerminacion":"' || v_reg.periodo_terminacion ||
              '","sanciones":"' || v_reg.sanciones ||
              '","delA":"' || v_reg.del_a ||
              '","interesadoA":"' || v_reg.interesado_a ||
              '","identificadoA":"' || v_reg.identificado_a ||
              '","matriculadoA":"' || v_reg.matriculado_a ||
              '","planEstudio":"' || v_reg.plan_estudio ||
              '","tipoPlanEstudio":"' || v_reg.tipo_plan_estudio ||
              '","promedio":"' || v_promedio ||
              '","promedio_letras":{' || v_promedio_letras ||'}'||
              '}');
      EXIT;
    END LOOP;
    CLOSE c_terminacionplan;
  END PR_TERMINACION_PLAN_JSON;

  PROCEDURE PR_TERMINACION_PLAN_FGRAD_JSON(p_codigo_estudiante varchar2) IS
    CURSOR c_terminacionplan IS
      SELECT e.nombre AS nombres_estudiante,
             e.codigo AS codigo_estudiante,
             UPPER(SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE(t.valor)) AS tipo_documento,
             d.numero_documento,
             UPPER(d.departamento_documento) AS departamento_documento,
             UPPER(d.ciudad_documento) AS ciudad_documento,
             UPPER(e.sexo) as genero,
             UPPER(f.nombre) AS programa,
             (CASE
               WHEN e.jornada_facultad = 'D' THEN
                'DIURNA'
               WHEN e.jornada_facultad = 'N' THEN
                'NOCTURNA'
               ELSE
                e.jornada_facultad
             END) AS jornada,
             m.semestre AS periodos_programa,
             SP_CE_ACADEMICO_UTIL.FN_PERIODO_PROGRAMA_LETRAS(m.semestre) AS periodos_programa_letras,
             'SEMESTRES' periodicidad,
             (CASE WHEN pys.ano_terminacion IS NOT NULL THEN pys.ano_terminacion
                   WHEN n.periodo IS NOT NULL THEN TO_NUMBER(SUBSTR(n.periodo, 1, 4))
                   ELSE NULL
             END) AS anio_terminacion,
             (CASE WHEN TRIM(pys.ciclo_de_terminacion) IS NOT NULL THEN TRIM(pys.ciclo_de_terminacion)
                   WHEN n.periodo IS NOT NULL THEN SUBSTR(n.periodo, 5)
                   ELSE NULL
              END) AS ciclo_terminacion,
             (CASE WHEN pys.ano_terminacion IS NOT NULL THEN
                        SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_T_LETRAS(pys.ano_terminacion, TRIM(pys.ciclo_de_terminacion))
                   WHEN n.periodo IS NOT NULL THEN
                        SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_T_LETRAS(SUBSTR(n.periodo, 1, 4), SUBSTR(n.periodo, 5))
                   ELSE NULL
              END) AS periodo_terminacion,
             SP_CE_ACADEMICO_UTIL.FN_SANCIONES(e.codigo, 2) AS sanciones,
             (UPPER(CASE
                      WHEN a.fecha_grado IS NOT NULL THEN
                       (TRIM(TO_CHAR(a.fecha_grado,
                                     'DAY',
                                     'NLS_DATE_LANGUAGE=spanish')) || ' ' ||
                       TRIM(TO_CHAR(a.fecha_grado,
                                     'DD',
                                     'NLS_DATE_LANGUAGE=spanish')) || ' de ' ||
                       TRIM(INITCAP(to_char(a.fecha_grado,
                                             'MONTH',
                                             'NLS_DATE_LANGUAGE=spanish'))) ||
                       ' de ' ||
                       (TO_CHAR(a.fecha_grado, 'YYYY', 'NLS_DATE_LANGUAGE=spanish')))
                      ELSE
                       NULL
                    END)) AS fecha_grado,
             SP_CE_ACADEMICO_UTIL.FN_REEMPLAZAR_EXPRESION_TITULO(f2.titulo_a_otorgar, UPPER(e.sexo)) AS titulo_otorgar,
             p.codigo_tipo AS codigo_tipo_programa,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_DEL_A(UPPER(e.sexo)) AS del_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_INTERESADO_A(UPPER(e.sexo)) AS interesado_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_IDENTIFICADO_A(UPPER(e.sexo)) AS identificado_a,
             SP_CE_ACADEMICO_UTIL.FN_EXPRESION_MATRICULADO_A(UPPER(e.sexo)) AS matriculado_a,
             e.plan_estudio,
             SP_CE_ACADEMICO_UTIL.FN_TIPO_PLAN_ESTUDIO(e.plan_estudio) AS tipo_plan_estudio
        FROM postgrado.b_estudiantes e
        JOIN admisiones.a_facultades_unica f
          ON (e.codigo_facultad = f.codigo_facultad)
        JOIN admisiones.a_facultades f2
          ON (e.codigo_facultad = f2.codigo AND
             e.jornada_facultad = f2.jornada)
        JOIN postgrado.datos_personales d
          ON (e.codigo = d.codigo_estudiante)
        JOIN admisiones.a_tipo_documento t
          ON (DECODE(d.codtipo_documento,'07','01', d.codtipo_documento) = t.codigo)
        JOIN admisiones.a_programas p
          ON (f2.codigo = p.codigo AND f2.jornada = p.jornada)
        LEFT JOIN (SELECT codigo_estudiante, MAX(ano || ciclo) AS periodo
                    FROM postgrado.a_notas
                   WHERE ciclo IN ('01','02','03','04')
                   GROUP BY codigo_estudiante) n
          ON (n.codigo_estudiante = e.codigo)
        LEFT JOIN (SELECT eg.codigo_estudiante,
                          eg.ano_terminacion,
                          eg.ciclo_de_terminacion
                    FROM postgrado.relacion_pys_egresado eg
                   WHERE TRIM(eg.ciclo_de_terminacion) IN ('01','02','03','04', 'PRIMER', 'SEGUNDO')
                   ) pys
          ON (pys.codigo_estudiante = e.codigo)
        JOIN (SELECT m.codigo_facultad,
                     m.jornada_facultad,
                     m.plan_estudio,
                     MAX(m.semestre) AS semestre
                FROM postgrado.a_materias m
               GROUP BY m.codigo_facultad,
                        m.jornada_facultad,
                        m.plan_estudio) m
          ON (m.codigo_facultad = e.codigo_facultad AND
             m.jornada_facultad = e.jornada_facultad AND
             m.plan_estudio = e.plan_estudio)
        JOIN admisiones.a_graduados a
          ON (e.codigo = a.codigo_estudiante)
       WHERE e.materias_pendientes = 0
         AND a.fecha_grado >= TRUNC(SYSDATE)
         AND a.fecha_grado > to_date('01/01/1960', 'DD/MM/YYYY')
         AND (UPPER(a.tipo_grado) <> 'POS' OR a.tipo_grado IS NULL)
         AND e.codigo = p_codigo_estudiante;

    v_reg c_terminacionplan%rowtype;

  BEGIN
    OPEN c_terminacionplan;
    LOOP
      FETCH c_terminacionplan INTO v_reg;

      IF c_terminacionplan%NOTFOUND THEN
        htp.prn('{}');
        EXIT;
      END IF;

      IF v_reg.titulo_otorgar IS NULL THEN
        raise_application_error(-20003, 'Programa sin título a otorgar.');
        EXIT;
      END IF;

      IF v_reg.anio_terminacion IS NULL OR v_reg.ciclo_terminacion IS NULL THEN
          raise_application_error(-20004, 'Estudiante sin periodos cursados');
          EXIT;
      END IF;

      htp.prn('{"nombresEstudiante":"' || v_reg.nombres_estudiante ||
              '","codigoEstudiante":"' || v_reg.codigo_estudiante ||
              '","tipoDocumento":"' || v_reg.tipo_documento ||
              '","numeroDocumento":"' || v_reg.numero_documento ||
              '","departamentoDocumento":"' || v_reg.departamento_documento ||
              '","ciudadDocumento":"' || v_reg.ciudad_documento ||
              '","genero":"' || v_reg.genero ||
              '","programa":"' || v_reg.programa ||
              '","jornada":"' || v_reg.jornada ||
              '","periodosPrograma":"' || v_reg.periodos_programa ||
              '","periodosProgramaLetras":"' || v_reg.periodos_programa_letras ||
              '","periodicidad":"' || v_reg.periodicidad ||
              '","periodoTerminacion":"' || v_reg.periodo_terminacion ||
              '","sanciones":"' || v_reg.sanciones ||
              '","fechaGrado":"' || v_reg.fecha_grado ||
              '","tituloOtorgar":"' || v_reg.titulo_otorgar ||
              '","delA":"' || v_reg.del_a ||
              '","interesadoA":"' || v_reg.interesado_a ||
              '","identificadoA":"' || v_reg.identificado_a ||
              '","matriculadoA":"' || v_reg.matriculado_a ||
              '","planEstudio":"' || v_reg.plan_estudio ||
              '","tipoPlanEstudio":"' || v_reg.tipo_plan_estudio ||
              '"}');
      EXIT;
    END LOOP;
    CLOSE c_terminacionplan;
  END PR_TERMINACION_PLAN_FGRAD_JSON;

    /**
     * @see SP_CE_ACADEMICO_POSGRADO.PR_CERTIFICADO_ESTUDIO_JSON(p_codigo_estudiante varchar2);
     */
  PROCEDURE PR_CERTIFICADO_ESTUDIO_JSON(p_codigo_estudiante VARCHAR2) IS

      CURSOR c_info_certificados IS
      SELECT est_matri.*,
       max_sem_plan.semestre AS periodos_programa,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_PROGRAMA_LETRAS(max_sem_plan.semestre) AS periodos_programa_letras,
       SP_CE_ACADEMICO_UTIL.FN_ESTADO_MATRICULA(est_matri.grupo_matricula) AS estado,
       SP_CE_ACADEMICO_UTIL.FN_PREPOSICION_MATRICULA(est_matri.grupo_matricula) AS preposicion,
       SP_CE_ACADEMICO_UTIL.FN_TITULO_ASIGNATURAS(est_matri.grupo_matricula, est_matri.codigo_tipo_programa) AS titulo_asignaturas,
       SP_CE_ACADEMICO_UTIL.FN_TIPO_PLAN_ESTUDIO(est_matri.plan_estudio) AS tipo_plan_estudio,
       cre_plan.creditos AS creditos_programa,
       est_matri.anio_ingreso || est_matri.ciclo_ingreso AS periodo_ingreso,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
       (
        est_matri.anio_ingreso,
        est_matri.ciclo_ingreso) AS periodo_ingreso_letras
      FROM
      (
       SELECT e.nombre AS nombres_estudiante,
              e.codigo AS codigo_estudiante,
              UPPER(SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE(t.valor)) AS tipo_documento,
              d.numero_documento,
              t.tipo AS tipo_doc_letras,
              UPPER(d.departamento_documento) AS departamento_documento,
              UPPER(d.ciudad_documento) AS ciudad_documento,
              UPPER(e.sexo) as genero,
              UPPER(f.nombre) AS programa,
              e.jornada_facultad AS codigo_jornada,
              (CASE
                 WHEN e.jornada_facultad = 'D' THEN
                   'DIURNA'
                 WHEN e.jornada_facultad = 'N' THEN
                   'NOCTURNA'
               ELSE
                 e.jornada_facultad
              END) AS jornada,
              e.codigo_facultad AS codigo_programa,
              (CASE WHEN mn_sinpr.plan_estudio IS NOT NULL THEN mn_sinpr.plan_estudio
                    WHEN m_premat.plan_estudio IS NOT NULL THEN m_premat.plan_estudio
                    WHEN retirado.plan_estudio IS NOT NULL THEN retirado.plan_estudio
                    ELSE NULL
               END) AS plan_estudio,
              (CASE WHEN  mn_sinpr.anio IS NOT NULL THEN mn_sinpr.anio
                     WHEN m_premat.anio IS NOT NULL THEN m_premat.anio
                     WHEN retirado.anio IS NOT NULL THEN retirado.anio
                     ELSE NULL
               END) AS anio_matricula,
              (CASE WHEN  mn_sinpr.ciclo IS NOT NULL THEN mn_sinpr.ciclo
                     WHEN m_premat.ciclo IS NOT NULL THEN m_premat.ciclo
                     WHEN retirado.ciclo IS NOT NULL THEN  SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL(retirado.ciclo)
                     ELSE NULL
                END) AS ciclo_matricula,
              SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
              (
                CASE WHEN mn_sinpr.anio IS NOT NULL THEN mn_sinpr.anio
                     WHEN m_premat.anio IS NOT NULL THEN m_premat.anio
                     WHEN retirado.anio IS NOT NULL THEN retirado.anio
                     ELSE NULL
                END,
                CASE WHEN mn_sinpr.ciclo IS NOT NULL THEN mn_sinpr.ciclo
                     WHEN m_premat.ciclo IS NOT NULL THEN m_premat.ciclo
                     WHEN retirado.ciclo IS NOT NULL THEN  SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL(retirado.ciclo)
                     ELSE NULL
                END
              )AS periodo_matricula_letras,
              (CASE WHEN mn_sinpr.ciclo IS NOT NULL THEN 'MATRICULADO_NUEVO_SIN_PREMATRICULA'
                     WHEN m_premat.ciclo IS NOT NULL THEN 'MATRICULADO_CON_PREMATRICULA'
                     WHEN retirado.ciclo IS NOT NULL THEN  'RETIRADO'
                     ELSE NULL
                END) AS grupo_matricula,
              'SEMESTRES' periodicidad,
              p.codigo_tipo AS codigo_tipo_programa,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_DEL_A(UPPER(e.sexo)) AS del_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_INTERESADO_A(UPPER(e.sexo)) AS interesado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_IDENTIFICADO_A(UPPER(e.sexo)) AS identificado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_MATRICULADO_A(UPPER(e.sexo)) AS matriculado_a,
              (CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,1,4)
                 ELSE SUBSTR(e.ciclo_de_ingreso,1,4)
              END) AS anio_ingreso,
              SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL
              (
               CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,5)
                 ELSE LPAD(SUBSTR(e.ciclo_de_ingreso,5),2,'0')
               END
              )AS ciclo_ingreso,
              SP_CE_ACADEMICO_UTIL.FN_TITULO_REINTEGRO(e.tipo_de_ingreso, m_premat.codigo, 2) AS reintegro_actualizacion,
              SP_CE_ACADEMICO_UTIL.FN_SANCIONES(e.codigo, 2) AS sanciones
       FROM postgrado.b_estudiantes e
       JOIN admisiones.a_facultades_unica f
         ON (e.codigo_facultad = f.codigo_facultad)
       JOIN admisiones.a_facultades f2
         ON (e.codigo_facultad = f2.codigo AND e.jornada_facultad = f2.jornada)
       JOIN postgrado.datos_personales d
         ON (e.codigo = d.codigo_estudiante)
       JOIN admisiones.a_tipo_documento t
         ON (DECODE(d.codtipo_documento,'07','01', d.codtipo_documento) = t.codigo)
       JOIN admisiones.a_programas p
         ON (f2.codigo = p.codigo AND f2.jornada = p.jornada)
       LEFT JOIN (SELECT n.codigo_estudiante,
                         MIN(n.ano || n.ciclo) AS periodo_minimo_notas
                   FROM postgrado.a_notas n
                  WHERE n.ciclo IN ('01', '03')
               GROUP BY n.codigo_estudiante)mp_est
        ON e.codigo = mp_est.codigo_estudiante
       LEFT JOIN (SELECT est.codigo,
                        SUBSTR(est.ciclo_de_ingreso, 1, 4) AS anio,
                        LPAD(SUBSTR(est.ciclo_de_ingreso, 5, 1), 2, '0') AS ciclo,
                        est.plan_estudio
                   FROM postgrado.b_estudiantes est
                   LEFT JOIN (SELECT MAX(est2.anio || TO_NUMBER(est2.ciclo)) AS periodo
                               FROM postgrado.b_estudiantes est2) max_per_guias
                     ON est.ciclo_de_ingreso = max_per_guias.periodo
                  WHERE est.indicador_pago IN ('P', 'V')
                    AND est.tipo_de_ingreso = 'NV'
                    AND (est.ciclo_de_ingreso = est.anio || TO_NUMBER(est.ciclo) OR
                         est.ciclo_de_ingreso = max_per_guias.periodo)
                    AND NOT EXISTS (SELECT 1
                           FROM postgrado.b_prematricula p
                          WHERE p.codigo_estudiante = est.codigo
                            AND p.indicador_pago IN ('P', 'V'))
                    AND NOT EXISTS
                  (SELECT 1
                           FROM cactualpos.b_prematricula p2
                          WHERE p2.codigo_estudiante = est.codigo
                            AND p2.indicador_pago IN ('P', 'V'))) mn_sinpr --matriculado nuevo sin prematricula
        ON e.codigo = mn_sinpr.codigo
      LEFT JOIN (SELECT est.codigo, est.anio, est.ciclo, est.plan_estudio
                   FROM postgrado.b_estudiantes est
                  WHERE est.indicador_pago IN ('P', 'V')
                    AND EXISTS (SELECT 1
                           FROM postgrado.b_prematricula p
                          WHERE p.codigo_estudiante = est.codigo
                            AND p.indicador_pago IN ('P', 'V'))
                     OR EXISTS
                               (SELECT 1
                           FROM cactualpos.b_prematricula p2
                          WHERE p2.codigo_estudiante = est.codigo
                            AND p2.anio = est.anio
                            AND p2.ciclo = est.ciclo
                            AND p2.indicador_pago IN ('P', 'V'))) m_premat --matriculado con prematricula
        ON e.codigo = m_premat.codigo
      LEFT JOIN (SELECT DISTINCT est.codigo,
                                 SUBSTR(u_notas.periodo, 1, 4) AS anio,
                                 SUBSTR(u_notas.periodo, 5, 2) AS ciclo,
                                 (CASE
                                   WHEN mp_pe.ind_hnvoplan IN ('N') THEN
                                    '1'
                                   ELSE
                                    mp_pe.ind_hnvoplan
                                 END) AS plan_estudio
                   FROM postgrado.b_estudiantes est
                   JOIN (SELECT n.codigo_estudiante,
                               MAX(n.ano || n.ciclo) AS periodo
                          FROM postgrado.a_notas n
                         WHERE n.ciclo IN ('01', '03')
                         GROUP BY n.codigo_estudiante) u_notas
                     ON est.codigo = u_notas.codigo_estudiante
                   JOIN (SELECT max_plan_notas.codigo_estudiante,
                                max_plan_notas.periodo,
                                (CASE WHEN max_plan_notas.ind_hnvoplan_tf >= 48000  THEN CHR((max_plan_notas.ind_hnvoplan_tf / 1000))
                                      WHEN max_plan_notas.ind_hnvoplan_tf < 48000 THEN CHR(max_plan_notas.ind_hnvoplan_tf)
                                      ELSE NULL
                                 END) AS ind_hnvoplan
                          FROM
                          (
                          SELECT n2.codigo_estudiante,
                                 n2.ano || n2.ciclo AS periodo,
                                 MAX(CASE WHEN REGEXP_SUBSTR(n2.ind_hnvoplan, '\D') IS NOT NULL THEN ASCII(n2.ind_hnvoplan)
                                          WHEN REGEXP_SUBSTR(n2.ind_hnvoplan, '\D') IS NULL THEN (ASCII(n2.ind_hnvoplan) * 1000)
                                          ELSE NULL
                                     END) AS ind_hnvoplan_tf
                           FROM postgrado.a_notas n2
                          WHERE n2.ciclo IN ('01','03')
                          GROUP BY n2.codigo_estudiante, n2.ano || n2.ciclo
                          )max_plan_notas)mp_pe
                     ON (u_notas.codigo_estudiante = mp_pe.codigo_estudiante AND
                         u_notas.periodo = mp_pe.periodo)
                  WHERE est.indicador_pago NOT IN ('P', 'V')) retirado --retirado
        ON e.codigo = retirado.codigo
        WHERE e.codigo = p_codigo_estudiante
        )est_matri
      LEFT JOIN (SELECT m.codigo_facultad,
                        m.jornada_facultad,
                        m.plan_estudio,
                        MAX(m.semestre) AS semestre
                    FROM postgrado.a_materias m
                   GROUP BY m.codigo_facultad,
                            m.jornada_facultad,
                            m.plan_estudio) max_sem_plan
      ON (max_sem_plan.codigo_facultad = est_matri.codigo_programa AND
          max_sem_plan.jornada_facultad = est_matri.codigo_jornada AND
          max_sem_plan.plan_estudio = est_matri.plan_estudio)
      LEFT JOIN (SELECT  m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio,
                         SUM(m.creditos) AS creditos
                    FROM postgrado.a_materias m
                   WHERE m.semestre <> '00'
                GROUP BY m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio)cre_plan
      ON (cre_plan.codigo_facultad = est_matri.codigo_programa AND
          cre_plan.jornada_facultad = est_matri.codigo_jornada AND
          cre_plan.plan_estudio = est_matri.plan_estudio);

    v_reg c_info_certificados%rowtype;

    BEGIN
      OPEN c_info_certificados;

      LOOP
        FETCH c_info_certificados INTO v_reg;
        IF c_info_certificados%NOTFOUND THEN
          htp.prn('{}');
          EXIT;
        END IF;

        IF v_reg.anio_matricula IS NULL OR v_reg.ciclo_matricula IS NULL THEN
          raise_application_error(-20004, 'Estudiante sin periodos cursados');
          EXIT;
        END IF;

        IF v_reg.periodos_programa IS NULL THEN
           raise_application_error(-20005, 'No se encontró duración del programa');
        END IF;

        htp.prn('{');
        htp.prn('"nombreEstudiante" : "' || v_reg.nombres_estudiante || '", ');
        htp.prn('"codigoEstudiante" : "' || v_reg.codigo_estudiante || '", ');
        htp.prn('"tipoDocumento" : "'    || v_reg.tipo_documento || '", ');
        htp.prn('"tipoDocumentoLetras" : "' || v_reg.tipo_doc_letras || '", ');
        htp.prn('"numeroDocumento" : "'  || v_reg.numero_documento || '", ');
        htp.prn('"departamentoDocumento" : "'  || v_reg.departamento_documento || '", ');
        htp.prn('"ciudadDocumento" : "'  || v_reg.ciudad_documento || '", ');
        htp.prn('"genero" : "'  || v_reg.genero || '", ');
        htp.prn('"programa" : "'  || v_reg.programa || '", ');
        htp.prn('"tipoPrograma" : "'  || 'POSGRADO' || '", ');
        htp.prn('"jornada" : "'  || v_reg.jornada || '", ');
        htp.prn('"periodosPrograma" : "'  || v_reg.periodos_programa || '", ');
        htp.prn('"periodosProgramaLetras" : "'  || v_reg.periodos_programa_letras || '", ');
        htp.prn('"periodicidad" : "'  || v_reg.periodicidad || '", ');
        htp.prn('"estado" : "'  || v_reg.estado || '", ');
        htp.prn('"preposicion" : "'  || v_reg.preposicion || '", ');
        htp.prn('"periodoMatricula" : "'  || v_reg.anio_matricula || v_reg.ciclo_matricula || '", ');
        htp.prn('"periodoMatriculaLetras" : "'  || v_reg.periodo_matricula_letras || '", ');
        htp.prn('"tituloAsignaturas" : "'  || v_reg.titulo_asignaturas || '", ');
        htp.prn('"anioMatricula" : "'   || v_reg.anio_matricula || '", ');
        htp.prn('"cicloMatricula" : "'  || v_reg.ciclo_matricula || '", ');
        htp.prn('"planEstudio" : "'    || v_reg.plan_estudio || '", ');
        htp.prn('"codigoPrograma" : "' || v_reg.codigo_programa || '", ');
        htp.prn('"codigoJornada" : "'  || v_reg.codigo_jornada || '", ');
        htp.prn('"grupoMatricula" : "' || v_reg.grupo_matricula || '", ');
        htp.prn('"delA" : "' || v_reg.del_a || '", ');
        htp.prn('"interesadoA" : "' || v_reg.interesado_a || '", ');
        htp.prn('"identificadoA" : "' || v_reg.identificado_a || '", ');
        htp.prn('"matriculadoA" : "' || v_reg.matriculado_a || '", ');
        htp.prn('"tipoPlanEstudio" : "' || v_reg.tipo_plan_estudio  || '", ');
        htp.prn('"creditosPrograma" : "' || v_reg.creditos_programa  || '", ');
        htp.prn('"periodoIngreso" : "' || v_reg.periodo_ingreso || '", ');
        htp.prn('"periodoIngresoLetras" : "' || v_reg.periodo_ingreso_letras  || '", ');
        htp.prn('"reintegroActualizacion" : "' || v_reg.reintegro_actualizacion  || '", ');
        htp.prn('"sanciones" : "' || v_reg.sanciones || '"');
        htp.prn('}');
        EXIT;
      END LOOP;
      CLOSE c_info_certificados;

    END PR_CERTIFICADO_ESTUDIO_JSON;

  PROCEDURE PR_CERTIFICADO_ESTUDIO_AC_JSON(p_codigo_estudiante VARCHAR2) IS
    CURSOR c_info_certificados IS
      SELECT est_matri.*,
       max_sem_plan.semestre AS periodos_programa,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_PROGRAMA_LETRAS(max_sem_plan.semestre) AS periodos_programa_letras,
       SP_CE_ACADEMICO_UTIL.FN_ESTADO_MATRICULA(est_matri.grupo_matricula) AS estado,
       SP_CE_ACADEMICO_UTIL.FN_PREPOSICION_MATRICULA(est_matri.grupo_matricula) AS preposicion,
       SP_CE_ACADEMICO_UTIL.FN_TITULO_ASIGNATURAS(est_matri.grupo_matricula, est_matri.codigo_tipo_programa) AS titulo_asignaturas,
       SP_CE_ACADEMICO_UTIL.FN_TIPO_PLAN_ESTUDIO(est_matri.plan_estudio) AS tipo_plan_estudio,
       cre_plan.creditos AS creditos_programa,
       est_matri.anio_ingreso || est_matri.ciclo_ingreso AS periodo_ingreso,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
       (
        est_matri.anio_ingreso,
        est_matri.ciclo_ingreso) AS periodo_ingreso_letras
      FROM
      (
       SELECT e.nombre AS nombres_estudiante,
              e.codigo AS codigo_estudiante,
              UPPER(SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE(t.valor)) AS tipo_documento,
              d.numero_documento,
              UPPER(d.departamento_documento) AS departamento_documento,
              UPPER(d.ciudad_documento) AS ciudad_documento,
              UPPER(e.sexo) as genero,
              UPPER(f.nombre) AS programa,
              e.jornada_facultad AS codigo_jornada,
              (CASE
                 WHEN e.jornada_facultad = 'D' THEN
                   'DIURNA'
                 WHEN e.jornada_facultad = 'N' THEN
                   'NOCTURNA'
               ELSE
                 e.jornada_facultad
              END) AS jornada,
              e.codigo_facultad AS codigo_programa,
              e.plan_estudio,
              (CASE WHEN  mn_sinpr.anio IS NOT NULL THEN mn_sinpr.anio
                     WHEN m_premat.anio IS NOT NULL THEN m_premat.anio
                     ELSE NULL
               END) AS anio_matricula,
              (CASE WHEN  mn_sinpr.ciclo IS NOT NULL THEN mn_sinpr.ciclo
                     WHEN m_premat.ciclo IS NOT NULL THEN m_premat.ciclo
                     ELSE NULL
                END) AS ciclo_matricula,
              SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
              (
                CASE WHEN mn_sinpr.anio IS NOT NULL THEN mn_sinpr.anio
                     WHEN m_premat.anio IS NOT NULL THEN m_premat.anio
                     ELSE NULL
                END,
                CASE WHEN mn_sinpr.ciclo IS NOT NULL THEN mn_sinpr.ciclo
                     WHEN m_premat.ciclo IS NOT NULL THEN m_premat.ciclo
                     ELSE NULL
                END
              )AS periodo_matricula_letras,
              (CASE WHEN mn_sinpr.ciclo IS NOT NULL THEN 'MATRICULADO_NUEVO_SIN_PREMATRICULA'
                     WHEN m_premat.ciclo IS NOT NULL THEN 'MATRICULADO_CON_PREMATRICULA'
                     ELSE NULL
                END) AS grupo_matricula,
              'SEMESTRES' periodicidad,
              p.codigo_tipo AS codigo_tipo_programa,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_DEL_A(UPPER(e.sexo)) AS del_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_INTERESADO_A(UPPER(e.sexo)) AS interesado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_IDENTIFICADO_A(UPPER(e.sexo)) AS identificado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_MATRICULADO_A(UPPER(e.sexo)) AS matriculado_a,
              (CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,1,4)
                 ELSE SUBSTR(e.ciclo_de_ingreso,1,4)
              END) AS anio_ingreso,
              SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL
              (
               CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,5)
                 ELSE LPAD(SUBSTR(e.ciclo_de_ingreso,5),2,'0')
               END
              )AS ciclo_ingreso
       FROM postgrado.b_estudiantes e
       JOIN admisiones.a_facultades_unica f
         ON (e.codigo_facultad = f.codigo_facultad)
       JOIN admisiones.a_facultades f2
         ON (e.codigo_facultad = f2.codigo AND e.jornada_facultad = f2.jornada)
       JOIN postgrado.datos_personales d
         ON (e.codigo = d.codigo_estudiante)
       JOIN admisiones.a_tipo_documento t
         ON (DECODE(d.codtipo_documento,'07','01', d.codtipo_documento) = t.codigo)
       JOIN admisiones.a_programas p
         ON (f2.codigo = p.codigo AND f2.jornada = p.jornada)
       LEFT JOIN (SELECT n.codigo_estudiante,
                         MIN(n.ano || n.ciclo) AS periodo_minimo_notas
                   FROM postgrado.a_notas n
                  WHERE n.ciclo IN ('01', '03')
               GROUP BY n.codigo_estudiante)mp_est
        ON e.codigo = mp_est.codigo_estudiante
       LEFT JOIN (SELECT est.codigo,
                        SUBSTR(est.ciclo_de_ingreso, 1, 4) AS anio,
                        LPAD(SUBSTR(est.ciclo_de_ingreso, 5, 1), 2, '0') AS ciclo,
                        est.plan_estudio
                   FROM postgrado.b_estudiantes est
                   LEFT JOIN (SELECT MAX(est2.anio || TO_NUMBER(est2.ciclo)) AS periodo
                               FROM postgrado.b_estudiantes est2) max_per_guias
                     ON est.ciclo_de_ingreso = max_per_guias.periodo
                  WHERE est.indicador_pago IN ('P', 'V')
                    AND est.tipo_de_ingreso = 'NV'
                    AND (est.ciclo_de_ingreso = est.anio || TO_NUMBER(est.ciclo) OR
                         est.ciclo_de_ingreso = max_per_guias.periodo)
                    AND NOT EXISTS (SELECT 1
                           FROM postgrado.b_prematricula p
                          WHERE p.codigo_estudiante = est.codigo
                            AND p.indicador_pago IN ('P', 'V'))
                    AND NOT EXISTS
                  (SELECT 1
                           FROM cactualpos.b_prematricula p2
                          WHERE p2.codigo_estudiante = est.codigo
                            AND p2.indicador_pago IN ('P', 'V'))) mn_sinpr --matriculado nuevo sin prematricula
        ON e.codigo = mn_sinpr.codigo
      LEFT JOIN (SELECT est.codigo, est.anio, est.ciclo, est.plan_estudio
                   FROM postgrado.b_estudiantes est
                  WHERE est.indicador_pago IN ('P', 'V')
                    AND EXISTS (SELECT 1
                           FROM postgrado.b_prematricula p
                          WHERE p.codigo_estudiante = est.codigo
                            AND p.indicador_pago IN ('P', 'V'))
                     OR EXISTS
                               (SELECT 1
                           FROM cactualpos.b_prematricula p2
                          WHERE p2.codigo_estudiante = est.codigo
                            AND p2.anio = est.anio
                            AND p2.ciclo = est.ciclo
                            AND p2.indicador_pago IN ('P', 'V'))) m_premat --matriculado con prematricula
        ON e.codigo = m_premat.codigo
     WHERE e.codigo = p_codigo_estudiante
       AND e.indicador_pago IN ('P', 'V')
        )est_matri
      LEFT JOIN (SELECT m.codigo_facultad,
                        m.jornada_facultad,
                        m.plan_estudio,
                        MAX(m.semestre) AS semestre
                    FROM postgrado.a_materias m
                   GROUP BY m.codigo_facultad,
                            m.jornada_facultad,
                            m.plan_estudio) max_sem_plan
      ON (max_sem_plan.codigo_facultad = est_matri.codigo_programa AND
         max_sem_plan.jornada_facultad = est_matri.codigo_jornada AND
         max_sem_plan.plan_estudio = est_matri.plan_estudio)
      LEFT JOIN (SELECT  m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio,
                         SUM(m.creditos) AS creditos
                    FROM postgrado.a_materias m
                   WHERE m.semestre <> '00'
                GROUP BY m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio)cre_plan
      ON (cre_plan.codigo_facultad = est_matri.codigo_programa AND
          cre_plan.jornada_facultad = est_matri.codigo_jornada AND
          cre_plan.plan_estudio = est_matri.plan_estudio);

    v_reg c_info_certificados%rowtype;
  BEGIN
    OPEN c_info_certificados;

      LOOP
        FETCH c_info_certificados INTO v_reg;
        IF c_info_certificados%NOTFOUND THEN
          htp.prn('{}');
          EXIT;
        END IF;

        IF v_reg.periodos_programa IS NULL THEN
           raise_application_error(-20005, 'No se encontró duración del programa');
        END IF;

        htp.prn('{');
        htp.prn('"nombreEstudiante" : "' || v_reg.nombres_estudiante || '", ');
        htp.prn('"codigoEstudiante" : "' || v_reg.codigo_estudiante || '", ');
        htp.prn('"tipoDocumento" : "'    || v_reg.tipo_documento || '", ');
        htp.prn('"numeroDocumento" : "'  || v_reg.numero_documento || '", ');
        htp.prn('"departamentoDocumento" : "'  || v_reg.departamento_documento || '", ');
        htp.prn('"ciudadDocumento" : "'  || v_reg.ciudad_documento || '", ');
        htp.prn('"genero" : "'  || v_reg.genero || '", ');
        htp.prn('"programa" : "'  || v_reg.programa || '", ');
        htp.prn('"jornada" : "'  || v_reg.jornada || '", ');
        htp.prn('"periodosPrograma" : "'  || v_reg.periodos_programa || '", ');
        htp.prn('"periodosProgramaLetras" : "'  || v_reg.periodos_programa_letras || '", ');
        htp.prn('"periodicidad" : "'  || v_reg.periodicidad || '", ');
        htp.prn('"estado" : "'  || v_reg.estado || '", ');
        htp.prn('"preposicion" : "'  || v_reg.preposicion || '", ');
        htp.prn('"periodoMatricula" : "'  || v_reg.anio_matricula || v_reg.ciclo_matricula || '", ');
        htp.prn('"periodoMatriculaLetras" : "'  || v_reg.periodo_matricula_letras || '", ');
        htp.prn('"tituloAsignaturas" : "'  || v_reg.titulo_asignaturas || '", ');
        htp.prn('"anioMatricula" : "'   || v_reg.anio_matricula || '", ');
        htp.prn('"cicloMatricula" : "'  || v_reg.ciclo_matricula || '", ');
        htp.prn('"planEstudio" : "'    || v_reg.plan_estudio || '", ');
        htp.prn('"codigoPrograma" : "' || v_reg.codigo_programa || '", ');
        htp.prn('"codigoJornada" : "'  || v_reg.codigo_jornada || '", ');
        htp.prn('"grupoMatricula" : "' || v_reg.grupo_matricula || '", ');
        htp.prn('"delA" : "' || v_reg.del_a || '", ');
        htp.prn('"interesadoA" : "' || v_reg.interesado_a || '", ');
        htp.prn('"identificadoA" : "' || v_reg.identificado_a || '", ');
        htp.prn('"matriculadoA" : "' || v_reg.matriculado_a || '", ');
        htp.prn('"tipoPlanEstudio" : "' || v_reg.tipo_plan_estudio  || '", ');
        htp.prn('"creditosPrograma" : "' || v_reg.creditos_programa  || '", ');
        htp.prn('"periodoIngreso" : "' || v_reg.periodo_ingreso || '", ');
        htp.prn('"periodoIngresoLetras" : "' || v_reg.periodo_ingreso_letras  || '"');
        htp.prn('}');

        EXIT;
      END LOOP;
      CLOSE c_info_certificados;
  END PR_CERTIFICADO_ESTUDIO_AC_JSON;

  /**
   * @see SP_CE_ACADEMICO_POSGRADO.PR_CERTIFICADO_ESTUDIO_IN_JSON(p_codigo_estudiante varchar2);
   */
  PROCEDURE PR_CERTIFICADO_ESTUDIO_IN_JSON(p_codigo_estudiante VARCHAR2) IS

      CURSOR c_info_certificados IS
      SELECT est_matri.*,
       max_sem_plan.semestre AS periodos_programa,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_PROGRAMA_LETRAS(max_sem_plan.semestre) AS periodos_programa_letras,
       SP_CE_ACADEMICO_UTIL.FN_ESTADO_MATRICULA(est_matri.grupo_matricula) AS estado,
       SP_CE_ACADEMICO_UTIL.FN_PREPOSICION_MATRICULA(est_matri.grupo_matricula) AS preposicion,
       SP_CE_ACADEMICO_UTIL.FN_TITULO_ASIGNATURAS(est_matri.grupo_matricula, est_matri.codigo_tipo_programa) AS titulo_asignaturas,
       SP_CE_ACADEMICO_UTIL.FN_TIPO_PLAN_ESTUDIO(est_matri.plan_estudio) AS tipo_plan_estudio,
       cre_plan.creditos AS creditos_programa,
       est_matri.anio_ingreso || est_matri.ciclo_ingreso AS periodo_ingreso,
       SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
       (
        est_matri.anio_ingreso,
        est_matri.ciclo_ingreso) AS periodo_ingreso_letras
      FROM
      (
       SELECT e.nombre AS nombres_estudiante,
              e.codigo AS codigo_estudiante,
              UPPER(SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE(t.valor)) AS tipo_documento,
              d.numero_documento,
              UPPER(d.departamento_documento) AS departamento_documento,
              UPPER(d.ciudad_documento) AS ciudad_documento,
              UPPER(e.sexo) as genero,
              UPPER(f.nombre) AS programa,
              e.jornada_facultad AS codigo_jornada,
              (CASE
                 WHEN e.jornada_facultad = 'D' THEN
                   'DIURNA'
                 WHEN e.jornada_facultad = 'N' THEN
                   'NOCTURNA'
               ELSE
                 e.jornada_facultad
              END) AS jornada,
              e.codigo_facultad AS codigo_programa,
              retirado.plan_estudio,
              retirado.anio AS anio_matricula,
              SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL(retirado.ciclo) AS ciclo_matricula,
              SP_CE_ACADEMICO_UTIL.FN_PERIODO_SEMESTRAL_LETRAS
              (
                retirado.anio,
                SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL(retirado.ciclo)
              )AS periodo_matricula_letras,
              'RETIRADO' AS grupo_matricula,
              'SEMESTRES' periodicidad,
              p.codigo_tipo AS codigo_tipo_programa,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_DEL_A(UPPER(e.sexo)) AS del_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_INTERESADO_A(UPPER(e.sexo)) AS interesado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_IDENTIFICADO_A(UPPER(e.sexo)) AS identificado_a,
              SP_CE_ACADEMICO_UTIL.FN_EXPRESION_MATRICULADO_A(UPPER(e.sexo)) AS matriculado_a,
              (CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,1,4)
                 ELSE SUBSTR(e.ciclo_de_ingreso,1,4)
              END) AS anio_ingreso,
              SP_CE_ACADEMICO_UTIL.FN_TRANSFORMAR_CICLO_SEMESTRAL
              (
               CASE
                 WHEN mp_est.periodo_minimo_notas IS NOT NULL THEN SUBSTR(mp_est.periodo_minimo_notas,5)
                 ELSE LPAD(SUBSTR(e.ciclo_de_ingreso,5),2,'0')
               END
              )AS ciclo_ingreso
       FROM postgrado.b_estudiantes e
       JOIN admisiones.a_facultades_unica f
         ON (e.codigo_facultad = f.codigo_facultad)
       JOIN admisiones.a_facultades f2
         ON (e.codigo_facultad = f2.codigo AND e.jornada_facultad = f2.jornada)
       JOIN postgrado.datos_personales d
         ON (e.codigo = d.codigo_estudiante)
       JOIN admisiones.a_tipo_documento t
         ON (DECODE(d.codtipo_documento,'07','01', d.codtipo_documento) = t.codigo)
       JOIN admisiones.a_programas p
         ON (f2.codigo = p.codigo AND f2.jornada = p.jornada)
       LEFT JOIN (SELECT n.codigo_estudiante,
                         MIN(n.ano || n.ciclo) AS periodo_minimo_notas
                   FROM postgrado.a_notas n
                  WHERE n.ciclo IN ('01', '03')
               GROUP BY n.codigo_estudiante)mp_est
        ON e.codigo = mp_est.codigo_estudiante
       JOIN (SELECT DISTINCT est.codigo,
                             SUBSTR(u_notas.periodo, 1, 4) AS anio,
                             SUBSTR(u_notas.periodo, 5, 2) AS ciclo,
                             (CASE
                                WHEN mp_pe.ind_hnvoplan IN ('N') THEN
                                 '1'
                                ELSE
                                 mp_pe.ind_hnvoplan
                              END) AS plan_estudio
                   FROM postgrado.b_estudiantes est
                   JOIN (SELECT n.codigo_estudiante,
                                MAX(n.ano || n.ciclo) AS periodo
                          FROM postgrado.a_notas n
                         WHERE n.ciclo IN ('01', '03')
                         GROUP BY n.codigo_estudiante) u_notas
                     ON est.codigo = u_notas.codigo_estudiante
                   JOIN (SELECT max_plan_notas.codigo_estudiante,
                                max_plan_notas.periodo,
                                (CASE WHEN max_plan_notas.ind_hnvoplan_tf >= 48000  THEN CHR((max_plan_notas.ind_hnvoplan_tf / 1000))
                                      WHEN max_plan_notas.ind_hnvoplan_tf < 48000 THEN CHR(max_plan_notas.ind_hnvoplan_tf)
                                      ELSE NULL
                                 END) AS ind_hnvoplan
                          FROM
                          (
                          SELECT n2.codigo_estudiante,
                                 n2.ano || n2.ciclo AS periodo,
                                 MAX(CASE WHEN REGEXP_SUBSTR(n2.ind_hnvoplan, '\D') IS NOT NULL THEN ASCII(n2.ind_hnvoplan)
                                          WHEN REGEXP_SUBSTR(n2.ind_hnvoplan, '\D') IS NULL THEN (ASCII(n2.ind_hnvoplan) * 1000)
                                          ELSE NULL
                                     END) AS ind_hnvoplan_tf
                           FROM postgrado.a_notas n2
                          WHERE n2.ciclo IN ('01','03')
                          GROUP BY n2.codigo_estudiante, n2.ano || n2.ciclo
                          )max_plan_notas)mp_pe
                     ON (u_notas.codigo_estudiante = mp_pe.codigo_estudiante AND
                         u_notas.periodo = mp_pe.periodo)
                  WHERE est.indicador_pago NOT IN ('P', 'V')) retirado --retirado
        ON e.codigo = retirado.codigo
        WHERE e.codigo = p_codigo_estudiante
        )est_matri
      LEFT JOIN (SELECT m.codigo_facultad,
                        m.jornada_facultad,
                        m.plan_estudio,
                        MAX(m.semestre) AS semestre
                    FROM postgrado.a_materias m
                   GROUP BY m.codigo_facultad,
                            m.jornada_facultad,
                            m.plan_estudio) max_sem_plan
      ON (max_sem_plan.codigo_facultad = est_matri.codigo_programa AND
          max_sem_plan.jornada_facultad = est_matri.codigo_jornada AND
          max_sem_plan.plan_estudio = est_matri.plan_estudio)
      LEFT JOIN (SELECT  m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio,
                         SUM(m.creditos) AS creditos
                    FROM postgrado.a_materias m
                   WHERE m.semestre <> '00'
                GROUP BY m.codigo_facultad,
                         m.jornada_facultad,
                         m.plan_estudio)cre_plan
      ON (cre_plan.codigo_facultad = est_matri.codigo_programa AND
          cre_plan.jornada_facultad = est_matri.codigo_jornada AND
          cre_plan.plan_estudio = est_matri.plan_estudio);

    v_reg c_info_certificados%rowtype;

    BEGIN
      OPEN c_info_certificados;

      LOOP
        FETCH c_info_certificados INTO v_reg;
        IF c_info_certificados%NOTFOUND THEN
          htp.prn('{}');
          EXIT;
        END IF;

        IF v_reg.anio_matricula IS NULL OR v_reg.ciclo_matricula IS NULL THEN
          raise_application_error(-20004, 'Estudiante sin periodos cursados');
          EXIT;
        END IF;

        IF v_reg.periodos_programa IS NULL THEN
           raise_application_error(-20005, 'No se encontró duración del programa');
        END IF;

        htp.prn('{');
        htp.prn('"nombreEstudiante" : "' || v_reg.nombres_estudiante || '", ');
        htp.prn('"codigoEstudiante" : "' || v_reg.codigo_estudiante || '", ');
        htp.prn('"tipoDocumento" : "'    || v_reg.tipo_documento || '", ');
        htp.prn('"numeroDocumento" : "'  || v_reg.numero_documento || '", ');
        htp.prn('"departamentoDocumento" : "'  || v_reg.departamento_documento || '", ');
        htp.prn('"ciudadDocumento" : "'  || v_reg.ciudad_documento || '", ');
        htp.prn('"genero" : "'  || v_reg.genero || '", ');
        htp.prn('"programa" : "'  || v_reg.programa || '", ');
        htp.prn('"jornada" : "'  || v_reg.jornada || '", ');
        htp.prn('"periodosPrograma" : "'  || v_reg.periodos_programa || '", ');
        htp.prn('"periodosProgramaLetras" : "'  || v_reg.periodos_programa_letras || '", ');
        htp.prn('"periodicidad" : "'  || v_reg.periodicidad || '", ');
        htp.prn('"estado" : "'  || v_reg.estado || '", ');
        htp.prn('"preposicion" : "'  || v_reg.preposicion || '", ');
        htp.prn('"periodoMatricula" : "'  || v_reg.anio_matricula || v_reg.ciclo_matricula || '", ');
        htp.prn('"periodoMatriculaLetras" : "'  || v_reg.periodo_matricula_letras || '", ');
        htp.prn('"tituloAsignaturas" : "'  || v_reg.titulo_asignaturas || '", ');
        htp.prn('"anioMatricula" : "'   || v_reg.anio_matricula || '", ');
        htp.prn('"cicloMatricula" : "'  || v_reg.ciclo_matricula || '", ');
        htp.prn('"planEstudio" : "'    || v_reg.plan_estudio || '", ');
        htp.prn('"codigoPrograma" : "' || v_reg.codigo_programa || '", ');
        htp.prn('"codigoJornada" : "'  || v_reg.codigo_jornada || '", ');
        htp.prn('"grupoMatricula" : "' || v_reg.grupo_matricula || '", ');
        htp.prn('"delA" : "' || v_reg.del_a || '", ');
        htp.prn('"interesadoA" : "' || v_reg.interesado_a || '", ');
        htp.prn('"identificadoA" : "' || v_reg.identificado_a || '", ');
        htp.prn('"matriculadoA" : "' || v_reg.matriculado_a || '", ');
        htp.prn('"tipoPlanEstudio" : "' || v_reg.tipo_plan_estudio  || '", ');
        htp.prn('"creditosPrograma" : "' || v_reg.creditos_programa  || '", ');
        htp.prn('"periodoIngreso" : "' || v_reg.periodo_ingreso || '", ');
        htp.prn('"periodoIngresoLetras" : "' || v_reg.periodo_ingreso_letras  || '"');
        htp.prn('}');
        EXIT;
      END LOOP;
      CLOSE c_info_certificados;

    END PR_CERTIFICADO_ESTUDIO_IN_JSON;

  PROCEDURE PR_HORARIO_ESTUDIO_JSON(p_codigo_estudiante VARCHAR2) IS
  CURSOR c_info_horarios IS
    SELECT pr.materia_plan,
           m.nombre AS nombre_materia,
           m.semestre,
           NVL(TRIM(hh.lunes), TRIM(hh2.lunes)) AS lunes,
           NVL(TRIM(hh.martes), TRIM(hh2.martes)) AS martes,
           NVL(TRIM(hh.miercoles), TRIM(hh2.miercoles)) AS miercoles,
           NVL(TRIM(hh.jueves), TRIM(hh2.jueves)) AS jueves,
           NVL(TRIM(hh.viernes), TRIM(hh2.viernes)) AS viernes,
           NVL(TRIM(hh.sabado), TRIM(hh2.sabado)) AS sabado,
           m.creditos creditos,
           m.intensidad_horaria intensidad_horaria
    FROM
       (SELECT   e.plan_estudio,
                 e.jornada_facultad AS jornada_facultad_plan,
                 NVL(bp.facultad, bp2.facultad) AS codigo_facultad_plan,
                 NVL(bp.materia_plan, bp2.materia_plan) AS materia_plan,
                 NVL(bp.jornada_facultad, bp2.jornada_facultad) AS jornada_facultad_cursar,
                 NVL(bp.facultad_cursar, bp2.facultad_cursar) AS codigo_facultad_cursar,
                 NVL(bp.materia_cursar, bp2.materia_cursar) AS materia_cursar,
                 NVL(bp.grupo, bp2.grupo) AS grupo,
                 e.anio,
                 e.ciclo
             FROM postgrado.b_estudiantes e
        LEFT JOIN postgrado.b_prematricula bp
               ON e.codigo = bp.codigo_estudiante
        LEFT JOIN cactualpos.b_prematricula bp2
               ON e.codigo = bp2.codigo_estudiante
            WHERE NVL(bp.indicador_pago, bp2.indicador_pago) IN ('P', 'V')
              AND e.indicador_pago IN ('P', 'V')
              AND e.codigo = p_codigo_estudiante)pr
        LEFT JOIN postgrado.a_horario_horizontal hh
               ON (pr.codigo_facultad_cursar = hh.codigo_facultad AND
                   pr.materia_cursar = hh.codigo_materia AND
                   to_number(pr.grupo) = to_number(hh.grupo_materia))
        LEFT JOIN cactualpos.a_horario_horizontal hh2 --tabla a donde queda lo de a_horario_horizontal despues del cierre para el proceso de horarios
               ON (pr.codigo_facultad_cursar = hh2.codigo_facultad AND
                   pr.materia_cursar = hh2.codigo_materia AND
                   to_number(pr.grupo) = to_number(hh2.grupo_materia) AND
                   pr.anio = hh2.anio AND
                   pr.ciclo = hh2.ciclo)
             JOIN  postgrado.a_materias m
               ON (pr.codigo_facultad_plan = m.codigo_facultad AND
                   pr.materia_plan = m.codigo AND
                   pr.jornada_facultad_plan = m.jornada_facultad AND
                   pr.plan_estudio = m.plan_estudio);

   v_reg c_info_horarios%ROWTYPE;
   v_json_horario VARCHAR2(5000);

   BEGIN
     v_json_horario := NULL;

     OPEN c_info_horarios;
     LOOP
     FETCH c_info_horarios INTO v_reg;
        EXIT WHEN c_info_horarios%NOTFOUND;
        v_json_horario := v_json_horario ||
                          '{' ||
                          '"materia_plan" : "' || v_reg.materia_plan || '", ' ||
                          '"nombre_materia" : "' || v_reg.nombre_materia || '", ' ||
                          '"semestre" : "' || v_reg.semestre || '", ' ||
                          '"lunes" : "' || v_reg.lunes || '", ' ||
                          '"martes" : "' || v_reg.martes || '", ' ||
                          '"miercoles" : "' || v_reg.miercoles || '", ' ||
                          '"jueves" : "' || v_reg.jueves || '",' ||
                          '"viernes" : "' || v_reg.viernes || '", ' ||
                          '"sabado" : "' || v_reg.sabado || '", ' ||
                          '"creditos" : "' || v_reg.creditos || '", ' ||
                          '"intensidad" : "' || v_reg.intensidad_horaria || '"' ||
                          '},';
     END LOOP;
     CLOSE c_info_horarios;

     IF v_json_horario IS NOT NULL THEN
        v_json_horario := SUBSTR(v_json_horario, 1, (LENGTH(v_json_horario) - 1));
        v_json_horario := '[' || v_json_horario || ']';
     ELSE
        v_json_horario := '{}';
     END IF ;

     htp.prn(v_json_horario);

   END PR_HORARIO_ESTUDIO_JSON;


   /**
   * @see SP_CE_ACADEMICO_POSTGRADO.PR_MATERIAS_PRIMER_SEM_JSON(p_codigo_programa VARCHAR2, p_jornada VARCHAR2);
   */
   PROCEDURE PR_MATERIAS_PRIMER_SEM_JSON(p_codigo_programa VARCHAR2,
                                          p_jornada         VARCHAR2) IS
    CURSOR c_asignaturas IS
      SELECT m.codigo,
             UPPER(TRIM(m.nombre)) AS nombre,
             m.semestre,
             m.creditos,
             m.intensidad_horaria,
             m.hor_trabajo_independiente AS horas_trabajo_independiente,
             COUNT(*) OVER() AS total_filas,
             SUM(m.hor_trabajo_independiente) OVER() AS total_hti,
             SUM(m.creditos) OVER() AS total_creditos,
             SUM(m.intensidad_horaria) OVER() AS total_ih
        FROM postgrado.a_materias m
       WHERE m.codigo_facultad = p_codigo_programa
         AND m.jornada_facultad = p_jornada
         AND m.semestre = '01'
         AND m.plan_estudio IN (SELECT MAX(m2.plan_estudio)
                                  FROM postgrado.a_materias m2
                                 WHERE m2.codigo_facultad = m.codigo_facultad
                                   AND m2.jornada_facultad = m.jornada_facultad);

      v_asignatura c_asignaturas%ROWTYPE;
  BEGIN
    v_asignatura := NULL;

    OPEN c_asignaturas;

    htp.prn('{');
    htp.prn('"listado" :');
    htp.prn('[');
    LOOP
      FETCH c_asignaturas INTO v_asignatura;
      EXIT WHEN c_asignaturas%NOTFOUND;
      PR_ESCRIBIR_ASIGNATURA_JSON(v_asignatura);
      IF c_asignaturas%ROWCOUNT <> v_asignatura.total_filas THEN
        htp.prn(',');
      END IF;
    END LOOP;
    htp.prn(']');
    htp.prn('}');
    CLOSE c_asignaturas;

  END PR_MATERIAS_PRIMER_SEM_JSON;


  /**
   * @see SP_CE_ACADEMICO_POSTGRADO.PR_MATERIAS_MATRICULO_ACT_JSON(p_codigo_estudiante VARCHAR2);
   */
  PROCEDURE PR_MATERIAS_MATRICULO_ACT_JSON(p_codigo_estudiante VARCHAR2) IS
    CURSOR c_asignaturas IS
      SELECT pre.materia_plan AS codigo,
             UPPER(TRIM(m.nombre)) AS nombre,
             m.semestre,
             m.creditos,
             m.intensidad_horaria,
             m.hor_trabajo_independiente AS horas_trabajo_independiente,
             COUNT(*) OVER() AS total_filas,
             SUM(m.hor_trabajo_independiente) OVER() AS total_hti,
             SUM(m.creditos) OVER() AS total_creditos,
             SUM(m.intensidad_horaria) OVER() AS total_ih
        FROM postgrado.a_materias m
        JOIN (SELECT be.codigo AS codigo_estudiante,
                     be.plan_estudio,
                     be.jornada_facultad,
                     premat.facultad,
                     premat.materia_plan,
                     premat.indicador_pago AS indicador_pago_prematricula
                FROM postgrado.b_estudiantes be
                JOIN (SELECT p.codigo_estudiante,
                             p.facultad,
                             p.materia_plan,
                             p.indicador_pago,
                             p.anio,
                             p.ciclo
                        FROM postgrado.b_prematricula p
                       WHERE p.indicador_pago IN ('P', 'V')
                       UNION
                      SELECT p2.codigo_estudiante,
                             p2.facultad,
                             p2.materia_plan,
                             p2.indicador_pago,
                             p2.anio,
                             p2.ciclo
                        FROM cactualpos.b_prematricula p2
                       WHERE p2.indicador_pago IN ('P', 'V')
                       )premat
                 ON  (be.codigo = premat.codigo_estudiante AND
                      be.anio = premat.anio AND
                      be.ciclo = premat.ciclo
                     )
                 WHERE be.indicador_pago IN ('P', 'V')
                   AND be.codigo = p_codigo_estudiante
             )pre
         ON (
             m.codigo= pre.materia_plan AND
             m.codigo_facultad = pre.facultad AND
             m.plan_estudio = pre.plan_estudio AND
             m.jornada_facultad = pre.jornada_facultad
             );

     v_asignatura c_asignaturas%ROWTYPE;
  BEGIN
    v_asignatura := NULL;

    OPEN c_asignaturas;
    htp.prn('{');
    htp.prn('"listado" :');
    htp.prn('[');
    LOOP
      FETCH c_asignaturas INTO v_asignatura;
      EXIT WHEN c_asignaturas%NOTFOUND;
      PR_ESCRIBIR_ASIGNATURA_JSON(v_asignatura);
      IF c_asignaturas%ROWCOUNT <> v_asignatura.total_filas THEN
        htp.prn(',');
      END IF;
    END LOOP;
    htp.prn(']');
    htp.prn('}');
    CLOSE c_asignaturas;
  END PR_MATERIAS_MATRICULO_ACT_JSON;


  /**
   * @see SP_CE_ACADEMICO_POSTGRADO.PR_MATERIAS_MATRICULO_RET_JSON(p_codigo_estudiante VARCHAR2);
   */
  PROCEDURE PR_MATERIAS_MATRICULO_RET_JSON(p_codigo_estudiante VARCHAR2) IS
    CURSOR c_asignaturas IS
      SELECT m.codigo,
             UPPER(TRIM(m.nombre)) AS nombre,
             m.semestre,
             m.creditos,
             m.intensidad_horaria,
             m.hor_trabajo_independiente AS horas_trabajo_independiente,
             COUNT(*) OVER() AS total_filas,
       SUM(m.hor_trabajo_independiente) OVER() AS total_hti,
             SUM(m.creditos) OVER() AS total_creditos,
             SUM(m.intensidad_horaria) OVER() AS total_ih
        FROM postgrado.a_materias m
        JOIN (SELECT n.codigo_estudiante,
                     n.codigo_materia,
                     n.codigo_facultad,
                     n.jornada_facultad,
                     (CASE WHEN n.ind_hnvoplan IN ('N') THEN '1' ELSE n.ind_hnvoplan END) AS plan_estudio,
                     n.ano || n.ciclo as periodo
                FROM postgrado.a_notas n
               WHERE n.codigo_estudiante = p_codigo_estudiante
                 AND n.ano || n.ciclo = (SELECT MAX(n2.ano || n2.ciclo)
                                          FROM postgrado.a_notas n2
                                         WHERE n2.codigo_estudiante = n.codigo_estudiante
                                           AND n2.ciclo IN ('01','02','03'))

             )u_notas
          ON (
              m.plan_estudio = u_notas.plan_estudio AND
              m.jornada_facultad = u_notas.jornada_facultad AND
              m.codigo_facultad = u_notas.codigo_facultad AND
              m.codigo = u_notas.codigo_materia
             );

       v_asignatura c_asignaturas%ROWTYPE;

  BEGIN
    v_asignatura := NULL;

    OPEN c_asignaturas;
    htp.prn('{');
    htp.prn('"listado" :');
    htp.prn('[');
    LOOP
      FETCH c_asignaturas INTO v_asignatura;
      EXIT WHEN c_asignaturas%NOTFOUND;
      PR_ESCRIBIR_ASIGNATURA_JSON(v_asignatura);
      IF c_asignaturas%ROWCOUNT <> v_asignatura.total_filas THEN
        htp.prn(',');
      END IF;
    END LOOP;
    htp.prn(']');
    htp.prn('}');
    CLOSE c_asignaturas;
  END PR_MATERIAS_MATRICULO_RET_JSON;


   /**
   * @see SP_CE_ACADEMICO_POSTGRADO.PR_ESCRIBIR_ASIGNATURA_JSON(p_asignatura VARCHAR2);
   */
PROCEDURE PR_ESCRIBIR_ASIGNATURA_JSON(p_asignatura ASIGNATURA) IS
BEGIN

  htp.prn('{');
    htp.prn('"codigo" : "'                || p_asignatura.codigo                || '", ');
    htp.prn('"nombre" : "'                || p_asignatura.nombre               || '", ');
    htp.prn('"semestre" : "'               || p_asignatura.semestre             || '", ');
    htp.prn('"creditos" : "'               || p_asignatura.creditos              || '", ');
    htp.prn('"intensidad_horaria" : "'       || p_asignatura.intensidad_horaria        || '", ');
    htp.prn('"horas_trabajo_independiente" : "'  || p_asignatura.horas_trabajo_independiente   || '", ');
    htp.prn('"total_hti" : "'             || p_asignatura.total_hti              || '", ');
    htp.prn('"total_creditos" : "'         || p_asignatura.total_creditos           || '", ');
    htp.prn('"total_ih" : "'             || p_asignatura.total_ih             || '"  ');
    htp.prn('}');

END PR_ESCRIBIR_ASIGNATURA_JSON;
    
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER INFORMACION DE ESTUDIANTE DE ACUERDO A SU CODIGO.
-- ****************************************************************************************************************************

    PROCEDURE PR_HISTORIA_ACAD_JSON (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS        
        V_HISTORIA_ACADEMICA JSON;
        V_NUMEROERROR        NUMBER;
        V_TEXTOERROR         VARCHAR2 (200);
        V_INFORMACION        VARCHAR2 (300);
        SIN_DATOS_ACADEMICOS EXCEPTION;
        PRAGMA EXCEPTION_INIT (SIN_DATOS_ACADEMICOS, -20003);
        -- INFORMACION DEL ESTUDIANTE.
        CURSOR C_INFO IS
            SELECT     BE.NOMBRE AS NOMBRE_ESTUDIANTE, 
                       BE.PLAN_ESTUDIO, 
                       BE.JORNADA_FACULTAD, 
                       BE.TIPO_DE_INGRESO, 
                       F.NOMBRE AS NOMBRE_FACULTAD, 
                       D.NUMERO_DOCUMENTO, 
                       UPPER (T.TIPO) || '. ' || D.NUMERO_DOCUMENTO DOCUMENTO, 
                       UPPER (SP_CE_ACADEMICO_UTIL.FN_TIPO_DOCUMENTO_TILDE (T.VALOR)) AS TIPO_DOCUMENTO, 
                       UPPER (T.TIPO) AS TIPO_DOCUMENTO_ABV
            FROM       POSTGRADO.B_ESTUDIANTES BE
            INNER JOIN POSTGRADO.DATOS_PERSONALES D ON BE.CODIGO = D.CODIGO_ESTUDIANTE
            INNER JOIN ADMISIONES.A_TIPO_DOCUMENTO T ON D.CODTIPO_DOCUMENTO = T.CODIGO
            INNER JOIN ADMISIONES.A_FACULTADES F ON     BE.CODIGO_FACULTAD = F.CODIGO 
                                                    AND BE.JORNADA_FACULTAD = F.JORNADA
            WHERE BE.CODIGO = P_CODIGO_ESTUDIANTE;
        V_DATA     C_INFO%ROWTYPE;
        N_PROMEDIO NUMBER;
    BEGIN
        V_HISTORIA_ACADEMICA := JSON();
        
        -- PROMEDIO CARRERA.
        SELECT ADMISIONES.PKG_UTILS.PROMEDIOPONDERADOTOTAL (P_CODIGO_ESTUDIANTE)
        INTO   N_PROMEDIO
        FROM   DUAL;
        
        -- OBTENER INFORMACION ACADEMICA.
        OPEN C_INFO;        
        FETCH C_INFO INTO V_DATA;        
        IF C_INFO%NOTFOUND THEN
            RAISE_APPLICATION_ERROR (-20003, 'Estudiante sin información académica.');
        END IF;
        
        -- IMPRESION JSON.
        JSON.PUT(V_HISTORIA_ACADEMICA, 'codigo', P_CODIGO_ESTUDIANTE);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'nombre', V_DATA.NOMBRE_ESTUDIANTE);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'facultad', V_DATA.NOMBRE_FACULTAD);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'documento', V_DATA.DOCUMENTO);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'planfin', V_DATA.PLAN_ESTUDIO);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'promedio', N_PROMEDIO);
        JSON.PUT(V_HISTORIA_ACADEMICA, 'ciclos', PR_HISTORIA_ACAD_PERIODOS(P_CODIGO_ESTUDIANTE));
        JSON.PUT(V_HISTORIA_ACADEMICA, 'bolsasDeCreditos', GET_NOTAS_BOLSA_CREDITOS(P_CODIGO_ESTUDIANTE));
        
        JSON.HTP(V_HISTORIA_ACADEMICA);
        CLOSE C_INFO;
    EXCEPTION
        WHEN OTHERS THEN
            V_NUMEROERROR   := SQLCODE;
            V_TEXTOERROR    := SUBSTR (SQLERRM, 1, 200);
            V_INFORMACION   := '[FAIL] Buscando información académica del estudiante: (' || P_CODIGO_ESTUDIANTE || ') >> ' || TO_CHAR (SYSDATE, 'DD-MON-YY HH24:MI:SS');
            SP_EXCEPCION.PR_REGISTRAR_LOG (V_NUMEROERROR, V_TEXTOERROR, V_INFORMACION);
            SP_EXCEPCION.PR_ESCRIBIR_ERROR_JSON (V_NUMEROERROR, V_TEXTOERROR);
    END PR_HISTORIA_ACAD_JSON;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER BOLSA DE CREDITOS QUE TENGAN MATERIAS CURSADAS. (NO SE USA PORQUE SE DECIDIO MOSTRAR LAS ELECTIVAS EN LA CONSULTA DE
-- NOTAS EN PR_HISTORIA_ACAD_MATERIAS CON EL SUFIJO (Electiva))
-- ****************************************************************************************************************************

    FUNCTION GET_NOTAS_BOLSA_CREDITOS(
        P_CODIGO_ESTUDIANTE VARCHAR2    
    ) RETURN JSON_LIST IS
        V_BOLSAS   JSON_LIST := JSON_LIST();
        V_BOLSA    JSON;
        V_MATERIAS JSON_LIST;
        V_MATERIA  JSON;
    BEGIN
        -- BOLSAS DE CREDITOS RELACIONADAS AL ESTUDIANTE.
        FOR C_BOLSA_CRED IN (SELECT     BC.ID_BOLSA,
                                        BC.NOMBRE,
                                        BC.TOPE
                             FROM       POSTGRADO.CTI_BOLSAS_CREDITOS BC
                             INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.ID_BOLSA = BC.ID_BOLSA
                             WHERE      BE.CODIGO = P_CODIGO_ESTUDIANTE) LOOP
            V_BOLSA := JSON();        
            V_MATERIAS := JSON_LIST();
            -- MATERIAS CON SUS RESPECTIVAS NOTAS PARA LA BOLSA DE CREDITOS ACTUAL.                             
            FOR C_NOTAS_POR_BOLSA IN  (SELECT     M.CODIGO,
                                                  M.NOMBRE,
                                                  M.CREDITOS,
                                                  M.INTENSIDAD_HORARIA,
                                                  N.VALOR,
                                                  F.NOMBRE FACULTAD
                                       FROM       POSTGRADO.B_ESTUDIANTES E 
                                       INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                                       INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                                       -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                                       INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                                         AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                                         AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                                         AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                                         AND N.CODIGO_ESTUDIANTE = E.CODIGO
                                       -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                                       INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                                            AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                                            AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                                            AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                                       INNER JOIN ADMISIONES.A_FACULTADES F ON     F.CODIGO  = M.CODIGO_FACULTAD
                                                                               AND F.JORNADA = M.JORNADA_FACULTAD
                                       WHERE          E.CODIGO    = P_CODIGO_ESTUDIANTE
                                                  AND BE.ID_BOLSA = C_BOLSA_CRED.ID_BOLSA) LOOP
                V_MATERIA := JSON();
                JSON.PUT(V_MATERIA, 'codigo', C_NOTAS_POR_BOLSA.CODIGO);
                JSON.PUT(V_MATERIA, 'facultad', C_NOTAS_POR_BOLSA.FACULTAD);
                JSON.PUT(V_MATERIA, 'nombre', C_NOTAS_POR_BOLSA.NOMBRE);
                JSON.PUT(V_MATERIA, 'creditos', C_NOTAS_POR_BOLSA.CREDITOS);
                JSON.PUT(V_MATERIA, 'intensidad_horaria', C_NOTAS_POR_BOLSA.INTENSIDAD_HORARIA);
                JSON.PUT(V_MATERIA, 'nota', C_NOTAS_POR_BOLSA.VALOR);
                JSON.PUT(V_MATERIA, 'notadigito', SP_CE_ACADEMICO_UTIL.GET_ALPHABETIC_VALUE(SP_CE_ACADEMICO_UTIL.IS_NUMBER(SUBSTR(TRIM(TO_CHAR(C_NOTAS_POR_BOLSA.VALOR, '0.0')), 0, 1))));
                JSON.PUT(V_MATERIA, 'notadecimal', SP_CE_ACADEMICO_UTIL.GET_ALPHABETIC_VALUE(SP_CE_ACADEMICO_UTIL.IS_NUMBER(SUBSTR(TRIM(TO_CHAR(C_NOTAS_POR_BOLSA.VALOR, '0.0')), 3, 3))));
                JSON_LIST.APPEND (V_MATERIAS, V_MATERIA.TO_JSON_VALUE);
            END LOOP;
            JSON.PUT(V_BOLSA, 'codigo', C_BOLSA_CRED.ID_BOLSA);
            JSON.PUT(V_BOLSA, 'nombre', C_BOLSA_CRED.NOMBRE);
            JSON.PUT(V_BOLSA, 'tope', C_BOLSA_CRED.TOPE);
            JSON.PUT(V_BOLSA, 'materias', V_MATERIAS);
            JSON_LIST.APPEND (V_BOLSAS, V_BOLSA.TO_JSON_VALUE);
        END LOOP;
        RETURN V_BOLSAS;
    END GET_NOTAS_BOLSA_CREDITOS;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER INFORMACION DE LOS PERIODOS ACADEMICOS CURSADOS POR UN ESTUDIANTE.
-- ****************************************************************************************************************************

    FUNCTION PR_HISTORIA_ACAD_PERIODOS (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) RETURN JSON_LIST IS
        V_PERIODOS_ACADEMICOS JSON_LIST := JSON_LIST();
        V_PERIODOS_ACADEMICO  JSON;
        
        N_CICLO_REAL          A_NOTAS.CICLO_REAL%TYPE;
        N_PROMEDIO            NUMBER DEFAULT 0;
        B_PERIODO_REINTEGRO   NUMBER DEFAULT 0;
        V_CICLO_TERMINACION   RELACION_PYS_EGRESADO.CICLO_DE_TERMINACION%TYPE;
        V_ANIO_TERMINACION    RELACION_PYS_EGRESADO.ANO_TERMINACION%TYPE;
        CURSOR C_PERIODOS_ACADEMICOS IS
            SELECT DISTINCT N.CODIGO_ESTUDIANTE CODIGO,
                            N.ANO, 
                            N.CICLO_REAL, 
                            N.CICLO
            FROM            POSTGRADO.A_MATERIAS M, 
                            POSTGRADO.A_NOTAS N
            WHERE           N.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE
            ORDER BY        N.ANO, N.CICLO;
    BEGIN
        -- CONSULTAMOS EL AÑO Y CICLO DE TERMINACION PARA DETERMINAR SI EL CICLO ES DE ACTUALIZACION.
        BEGIN
            SELECT PYS.ANO_TERMINACION, 
                   DECODE (TRIM (PYS.CICLO_DE_TERMINACION), 'PRIMER', '01', 'SEGUNDO', '03', 'CURSO VACACIONAL PRIMER', '02')
            INTO   V_ANIO_TERMINACION, 
                   V_CICLO_TERMINACION
            FROM   POSTGRADO.RELACION_PYS_EGRESADO PYS
            WHERE  PYS.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CICLO_TERMINACION   := '';
                V_ANIO_TERMINACION    := '';
        END;  
           
        FOR V_DATOS_CICLO IN C_PERIODOS_ACADEMICOS LOOP
            V_PERIODOS_ACADEMICO := JSON();
            
            -- BUSQUEDA DEL NOMBRE REAL DEL CICLO QUE DEBE APARECER EN EL CERTIFICADO (PRIMER SEMESTRE, SEGUNDO SEMESTRE, ETC.).
            N_CICLO_REAL := SP_CE_ACADEMICO_UTIL.FN_CICLO_ACADEMICO_LPERIODO (V_DATOS_CICLO.CICLO, V_DATOS_CICLO.CICLO_REAL);
            
            -- OBTENCION DEL PROMEDIO DEL PERIODO.
            SELECT ADMISIONES.PKG_UTILS.PROMEDIOPERIODOCERTIFICADO (P_CODIGO_ESTUDIANTE, V_DATOS_CICLO.ANO, V_DATOS_CICLO.CICLO)
            INTO   N_PROMEDIO
            FROM   DUAL;
            
            -- IMPRESION JSON.
            JSON.PUT(V_PERIODOS_ACADEMICO, 'anno', V_DATOS_CICLO.ANO);
            JSON.PUT(V_PERIODOS_ACADEMICO, 'cicloreal', N_CICLO_REAL);
            JSON.PUT(V_PERIODOS_ACADEMICO, 'promedio', N_PROMEDIO);
            JSON.PUT(V_PERIODOS_ACADEMICO, 'periodo_actualizacion', B_PERIODO_REINTEGRO);
            JSON.PUT(V_PERIODOS_ACADEMICO, 'materias', PR_HISTORIA_ACAD_MATERIAS(P_CODIGO_ESTUDIANTE, V_DATOS_CICLO.ANO, V_DATOS_CICLO.CICLO));  
            JSON_LIST.APPEND (V_PERIODOS_ACADEMICOS, V_PERIODOS_ACADEMICO.TO_JSON_VALUE);
            
            -- DETERMINAMOS SI EL CICLO CURSADO ES EN REINTEGRO DE ACTUALIZACION.
            IF B_PERIODO_REINTEGRO = 0 THEN
                B_PERIODO_REINTEGRO := SP_CE_ACADEMICO_UTIL.FN_CICLO_EN_REINTEGRO (V_CICLO_TERMINACION, 
                                                                                   V_ANIO_TERMINACION, 
                                                                                   V_DATOS_CICLO.CICLO,
                                                                                   V_DATOS_CICLO.ANO);
            END IF;
        END LOOP;
        RETURN V_PERIODOS_ACADEMICOS;
    END PR_HISTORIA_ACAD_PERIODOS;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER INFORMACION DE ASIGNATURAS CURSADAS EN UN DETERMINADO PERIODO.
-- ****************************************************************************************************************************

    FUNCTION PR_HISTORIA_ACAD_MATERIAS (
        P_CODIGO_ESTUDIANTE VARCHAR2, 
        P_ANO               VARCHAR2, 
        P_CICLO             VARCHAR2
    ) RETURN JSON_LIST IS
        V_MATERIAS    JSON_LIST := JSON_LIST();
        V_MATERIA_JS  JSON;
        N_VALOR_NOTA  NUMBER DEFAULT -1;
        N_ES_GRADUADO NUMBER DEFAULT 0;
        CURSOR C_MATERIA IS
        SELECT COUNT(*) OVER () AS TOTAL_FILAS, 
               G.*
        FROM   (SELECT DISTINCT N.CODIGO_MATERIA,
                                CASE 
                                     WHEN BC.CODIGO_MATERIA IS NOT NULL THEN TRIM(BC.NOMBRE_FACULTAD) || ' - ' || TRIM(M.NOMBRE) || ' (Electiva)'
                                     ELSE M.NOMBRE
                                END NOMBRE,
                                M.INTENSIDAD_HORARIA, 
                                M.CREDITOS, 
                                N.VALOR NOTA
                FROM            POSTGRADO.A_MATERIAS M
                INNER JOIN      POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA   = M.CODIGO
                                                       AND N.CODIGO_FACULTAD  = M.CODIGO_FACULTAD 
                                                       AND N.JORNADA_FACULTAD = M.JORNADA_FACULTAD
                -- QUERY PARA IDENTIFICAR MATERIAS CURSADAS POR CREDITOS ELECTIVOS.
                LEFT JOIN       (SELECT     BEM.CODIGO_MATERIA,
                                            BEM.PLAN_ESTUDIO,
                                            BEM.CODIGO_FACULTAD,
                                            BEM.JORNADA_FACULTAD,
                                            F.NOMBRE NOMBRE_FACULTAD
                                 FROM       POSTGRADO.CTI_BOLSA_ESTUDIANTE BE
                                 INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                                 LEFT JOIN  ADMISIONES.A_FACULTADES F ON     F.CODIGO  = BEM.CODIGO_FACULTAD
                                                                         AND F.JORNADA = BEM.JORNADA_FACULTAD
                                 WHERE      BE.CODIGO = P_CODIGO_ESTUDIANTE) BC ON     BC.CODIGO_MATERIA   = N.CODIGO_MATERIA
                                                                                   AND BC.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                                                   AND BC.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                                                   AND BC.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                WHERE               N.ANO                = P_ANO 
                                AND N.CICLO              = P_CICLO
                                AND N.CODIGO_ESTUDIANTE  = P_CODIGO_ESTUDIANTE
                                AND N.VALOR              >= N_VALOR_NOTA
                ORDER BY        N.CODIGO_MATERIA) G;
        V_MATERIA C_MATERIA%ROWTYPE;
    BEGIN
        -- CONSULTAMOS SI EL ESTUDIANTE ES GRADUADO.
        SELECT     COUNT (*)
        INTO       N_ES_GRADUADO
        FROM       POSTGRADO.B_ESTUDIANTES E
        INNER JOIN ADMISIONES.A_GRADUADOS A ON (E.CODIGO = A.CODIGO_ESTUDIANTE)
        WHERE          A.FECHA_GRADO <= TRUNC (SYSDATE) 
                   AND A.FECHA_GRADO > TO_DATE ('01/01/1960', 'DD/MM/YYYY') 
                   AND E.CODIGO = P_CODIGO_ESTUDIANTE;

        -- EN EL CERTIFICADO DE CALIFICACIONES PARA ESTUDIANTES GRADUADOS SOLO APARECEN LAS MATERIAS CON NOTA MAYOR IGUAL A 3.
        IF N_ES_GRADUADO <> 0 THEN
            N_VALOR_NOTA := 3;
        END IF;
        
        OPEN C_MATERIA;
        LOOP
            FETCH C_MATERIA INTO V_MATERIA;
            EXIT WHEN C_MATERIA%NOTFOUND;
            
            -- IMPRESION JSON.
            V_MATERIA_JS := JSON();
            JSON.PUT(V_MATERIA_JS, 'codigo', V_MATERIA.CODIGO_MATERIA);
            JSON.PUT(V_MATERIA_JS, 'nombre', V_MATERIA.NOMBRE);
            JSON.PUT(V_MATERIA_JS, 'creditos', V_MATERIA.CREDITOS);
            JSON.PUT(V_MATERIA_JS, 'intensidad_horaria', V_MATERIA.INTENSIDAD_HORARIA);
            JSON.PUT(V_MATERIA_JS, 'nota', TRIM(TO_CHAR(V_MATERIA.NOTA, '0.0')));
            JSON.PUT(V_MATERIA_JS, 'notadigito', SP_CE_ACADEMICO_UTIL.GET_ALPHABETIC_VALUE(SP_CE_ACADEMICO_UTIL.IS_NUMBER(SUBSTR(TRIM(TO_CHAR(V_MATERIA.NOTA, '0.0')), 0, 1))));
            JSON.PUT(V_MATERIA_JS, 'notadecimal', SP_CE_ACADEMICO_UTIL.GET_ALPHABETIC_VALUE(SP_CE_ACADEMICO_UTIL.IS_NUMBER(SUBSTR(TRIM(TO_CHAR(V_MATERIA.NOTA, '0.0')), 3, 3))));
            JSON_LIST.APPEND (V_MATERIAS, V_MATERIA_JS.TO_JSON_VALUE);
        END LOOP;
        CLOSE C_MATERIA;
        RETURN V_MATERIAS;
    END PR_HISTORIA_ACAD_MATERIAS;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER INFORMACION DE ASIGNATURAS CURSADAS EN UN DETERMINADO PERIODO.
-- ****************************************************************************************************************************

    PROCEDURE PR_PLAN_DE_ESTUDIO (
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS

        V_NUMEROERROR  NUMBER;
        V_TEXTOERROR   VARCHAR2 (200);
        V_INFORMACION  VARCHAR2 (300);
        MATERIA        JSON;
        MATERIAS_LIST  JSON_LIST;
        INFO_PLAN      JSON_LIST := JSON_LIST ();
        SEMESTRE       JSON;
        V_PLAN_ESTUDIO JSON;
        VC_PLAN        VARCHAR2 (2);
        V_SEMESTRE     VARCHAR2 (10);

        CERTIFICADOS_EXCEPTION EXCEPTION;
        PRAGMA EXCEPTION_INIT (CERTIFICADOS_EXCEPTION, -20001);

        -- OBTENCION DE LOS SEMESTRES DEL PLAN.
        CURSOR C_SEMESTRES IS
            SELECT DISTINCT AM.SEMESTRE
            FROM            POSTGRADO.B_ESTUDIANTES B
            INNER JOIN      POSTGRADO.DATOS_PERSONALES D ON B.CODIGO = D.CODIGO_ESTUDIANTE
            INNER JOIN      ADMISIONES.A_TIPO_DOCUMENTO T ON DECODE (D.CODTIPO_DOCUMENTO, '07', '01', D.CODTIPO_DOCUMENTO) = T.CODIGO
            INNER JOIN      ADMISIONES.A_FACULTADES_UNICA FU ON FU.CODIGO_FACULTAD = B.CODIGO_FACULTAD
            INNER JOIN      ADMISIONES.A_FACULTADES F ON     B.CODIGO_FACULTAD  = F.CODIGO 
                                                         AND B.JORNADA_FACULTAD = F.JORNADA
            INNER JOIN      POSTGRADO.A_MATERIAS AM ON     AM.CODIGO_FACULTAD  = F.CODIGO 
                                                       AND AM.JORNADA_FACULTAD = F.JORNADA 
                                                       AND AM.PLAN_ESTUDIO     = B.PLAN_ESTUDIO
            WHERE               B.CODIGO = P_CODIGO_ESTUDIANTE 
                            AND AM.SEMESTRE NOT IN ('00')
            ORDER BY        AM.SEMESTRE;

        -- ASIGNATURAS POR SEMESTRE. SE UTILIZA EL CURSOR ANTERIOR PARA FILTRAR EL ACTUAL USANDO LA VARIABLE V_SEMESTRE.
        CURSOR C_PLAN_ESTUDIO IS
            SELECT     AM.CODIGO, 
                       AM.NOMBRE, 
                       AM.CREDITOS, 
                       AM.INTENSIDAD_HORARIA, 
                       AM.SEMESTRE
            FROM       POSTGRADO.B_ESTUDIANTES B 
            INNER JOIN POSTGRADO.DATOS_PERSONALES D ON B.CODIGO = D.CODIGO_ESTUDIANTE
            INNER JOIN ADMISIONES.A_TIPO_DOCUMENTO T ON DECODE (D.CODTIPO_DOCUMENTO, '07', '01', D.CODTIPO_DOCUMENTO) = T.CODIGO
            INNER JOIN ADMISIONES.A_FACULTADES_UNICA FU ON FU.CODIGO_FACULTAD = B.CODIGO_FACULTAD
            INNER JOIN ADMISIONES.A_FACULTADES F ON     B.CODIGO_FACULTAD  = F.CODIGO 
                                                    AND B.JORNADA_FACULTAD = F.JORNADA
            INNER JOIN POSTGRADO.A_MATERIAS AM ON     AM.CODIGO_FACULTAD  = F.CODIGO 
                                                  AND AM.JORNADA_FACULTAD = F.JORNADA 
                                                  AND AM.PLAN_ESTUDIO     = B.PLAN_ESTUDIO
            WHERE          B.CODIGO    = P_CODIGO_ESTUDIANTE 
                       AND AM.SEMESTRE = V_SEMESTRE
                       AND AM.SEMESTRE NOT IN ('00')  
            ORDER BY   AM.SEMESTRE, AM.CODIGO;
            
        V_PLAN C_PLAN_ESTUDIO%ROWTYPE;
        V_SEMESTRE_ROW C_SEMESTRES%ROWTYPE;
    BEGIN
        V_PLAN_ESTUDIO := JSON ();
        
        -- OBTENCION DEL ID DEL PLAN DE ESTUDIO.
        SELECT VW.PLAN_ESTUDIO
        INTO   VC_PLAN
        FROM   VW_CE_ESTUDIANTES_POSGRADO VW
        WHERE  VW.CODIGO_ESTUDIANTE = P_CODIGO_ESTUDIANTE;

        OPEN C_SEMESTRES;
        LOOP
            FETCH C_SEMESTRES INTO V_SEMESTRE_ROW;
            EXIT WHEN C_SEMESTRES%NOTFOUND;

            
            -- OBTENCION DEL NUMERO DEL SEMESTRE.
            V_SEMESTRE      := V_SEMESTRE_ROW.SEMESTRE;
            
            SEMESTRE        := JSON ();
            MATERIAS_LIST   := JSON_LIST ();
            JSON.PUT (SEMESTRE, 'semestre', V_SEMESTRE_ROW.SEMESTRE);
            JSON.PUT (SEMESTRE, 'semestreValorOrdinal', SP_CE_ACADEMICO_UTIL.FN_NUMEROS_ORDINALES (V_SEMESTRE_ROW.SEMESTRE) || ' ' || 'SEMESTRE');
            
            -- ITERACION SOBRE LAS MATERIAS PARA EL SEMESTRE (V_SEMESTRE) ACTUAL.
            OPEN C_PLAN_ESTUDIO;
            LOOP
                FETCH C_PLAN_ESTUDIO INTO V_PLAN;
                EXIT WHEN C_PLAN_ESTUDIO%NOTFOUND;

                MATERIA := JSON ();
                JSON.PUT (MATERIA, 'codigo', V_PLAN.CODIGO);
                JSON.PUT (MATERIA, 'nombre', V_PLAN.NOMBRE);
                JSON.PUT (MATERIA, 'creditos', V_PLAN.CREDITOS);
                JSON.PUT (MATERIA, 'intensidad_horaria', V_PLAN.INTENSIDAD_HORARIA);
                JSON.PUT (MATERIA, 'semestre', V_PLAN.SEMESTRE);
                JSON_LIST.APPEND (MATERIAS_LIST, MATERIA.TO_JSON_VALUE);
            END LOOP;
            CLOSE C_PLAN_ESTUDIO;

            JSON.PUT (SEMESTRE, 'materias', MATERIAS_LIST);
            JSON_LIST.APPEND (INFO_PLAN, SEMESTRE.TO_JSON_VALUE);
        END LOOP;
        CLOSE C_SEMESTRES;
        JSON.PUT (V_PLAN_ESTUDIO, 'plan', INFO_PLAN);
        JSON.PUT (V_PLAN_ESTUDIO, 'plan_estudio', VC_PLAN);
        JSON.PUT (V_PLAN_ESTUDIO, 'programa', 'POSGRADO');
        JSON.HTP (V_PLAN_ESTUDIO);

    END PR_PLAN_DE_ESTUDIO;

   /**
   * @see SP_CE_ACADEMICO.PR_PUESTO_OCUPADO(p_codigo_estudiante VARCHAR2);
   */
   PROCEDURE PR_PUESTO_OCUPADO(p_codigo_estudiante VARCHAR2) IS
       v_esquema                VARCHAR2(10);
       v_NumeroError            NUMBER;
       v_TextoError             VARCHAR2(200);
       v_Informacion            VARCHAR2(300);
       v_materias_pendientes    json_list;
       v_materia                json;
       v_respuesta              json;
       v_promedio               NUMBER;  
       v_cantidad_egresados     NUMBER;
       v_promedio_letras        VARCHAR2(100);
       v_puesto_ocupado         NUMBER DEFAULT 0;
       
       CURSOR promedios_cohorte IS
       SELECT 
       UNIQUE (ADMISIONES.PKG_UTILS.promedioponderadototal(BE.CODIGO)) NOTA
       FROM   POSTGRADO.B_ESTUDIANTES BE
       WHERE  BE.CODIGO_FACULTAD||be.jornada_facultad =(SELECT T.CODIGO_FACULTAD||T.JORNADA_FACULTAD FROM POSTGRADO.B_ESTUDIANTES T WHERE T.CODIGO=p_codigo_estudiante)
       AND    (BE.MATERIAS_PENDIENTES=0
       OR     (SELECT COUNT(*)
              FROM ADMISIONES.A_GRADUADOS G
              WHERE G.CODIGO_ESTUDIANTE  =BE.CODIGO
              AND G.NUMERO_ACTA         <>0
              AND TO_CHAR(G.FECHA_GRADO)<>'01011960')<>0)
       AND    (SELECT MAX(n.ano
              ||DECODE(n.ciclo,'01','01','02','01','03','02','04','02'))
              FROM POSTGRADO.A_NOTAS N
              WHERE N.CODIGO_ESTUDIANTE= p_codigo_estudiante)=
              (SELECT MAX(n.ano
                      ||DECODE(n.ciclo,'01','01','02','01','03','02','04','02'))
                      FROM POSTGRADO.A_NOTAS N
                      WHERE N.CODIGO_ESTUDIANTE=BE.CODIGO
              ) 
       ORDER BY NOTA DESC;

       ESTUDIANTE_INEXISTENTE   EXCEPTION;
       SIN_DATOS_PERSONALES     EXCEPTION;
       
       PRAGMA EXCEPTION_INIT(ESTUDIANTE_INEXISTENTE, -20001);
       PRAGMA EXCEPTION_INIT(SIN_DATOS_PERSONALES  , -20002);
   BEGIN

      v_materias_pendientes := json_list();
      v_respuesta := json();
      
      SELECT (ADMISIONES.PKG_UTILS.promedioponderadototal(BE.CODIGO)) AS PROMEDIO
      INTO   v_promedio
      FROM   POSTGRADO.B_ESTUDIANTES BE
      WHERE  BE.CODIGO = p_codigo_estudiante;
      
      SELECT COUNT(*) AS numero_egresados
      INTO   v_cantidad_egresados
      FROM   POSTGRADO.B_ESTUDIANTES BE
      WHERE  BE.CODIGO_FACULTAD || be.jornada_facultad =(SELECT T.CODIGO_FACULTAD||T.JORNADA_FACULTAD FROM POSTGRADO.B_ESTUDIANTES T WHERE T.CODIGO=p_codigo_estudiante)
      AND    (BE.MATERIAS_PENDIENTES=0
      OR     (SELECT COUNT(*)
             FROM ADMISIONES.A_GRADUADOS G
             WHERE G.CODIGO_ESTUDIANTE  =BE.CODIGO
             AND G.NUMERO_ACTA         <>0
             AND TO_CHAR(G.FECHA_GRADO)<>'01011960')<>0)
      AND    (SELECT MAX(n.ano
             ||DECODE(n.ciclo,'01','01','02','01','03','02','04','02'))
             FROM POSTGRADO.A_NOTAS N
             WHERE N.CODIGO_ESTUDIANTE = p_codigo_estudiante) =
             (SELECT MAX(n.ano
             ||DECODE(n.ciclo,'01','01','02','01','03','02','04','02'))
             FROM POSTGRADO.A_NOTAS N
             WHERE N.CODIGO_ESTUDIANTE=BE.CODIGO
      );
      
      FOR p_c IN promedios_cohorte LOOP
            IF p_c.NOTA IS NOT NULL THEN
                v_puesto_ocupado := v_puesto_ocupado +1;
             END IF;
             IF p_c.NOTA = v_promedio THEN
                EXIT;
             END IF;
      END LOOP;
      
      json.put(v_respuesta, 'promedio', v_promedio);
      json.put(v_respuesta, 'cantidad_egresados', v_cantidad_egresados);
      json.put(v_respuesta, 'puesto_ocupado', v_puesto_ocupado);
      json.put(v_respuesta, 'puesto_en_letras', SP_CE_ACADEMICO_UTIL.FN_NUMEROS_ORDINALES(v_puesto_ocupado));
      
      json.htp(v_respuesta);
      
      EXCEPTION
      WHEN OTHERS THEN
      
      v_NumeroError := SQLCODE;
      v_TextoError  := SUBSTR(SQLERRM, 1, 200);
      v_Informacion := '[FAIL] recuperando puesto ocupado de: (' || p_codigo_estudiante || ') >> ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS');
      
      SP_EXCEPCION.PR_REGISTRAR_LOG(v_NumeroError, v_TextoError, v_Informacion);
      SP_EXCEPCION.PR_ESCRIBIR_ERROR_JSON(v_NumeroError, v_TextoError);
   
   END PR_PUESTO_OCUPADO;

END SP_CE_ACADEMICO_POSGRADO;