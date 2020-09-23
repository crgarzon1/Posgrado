CREATE OR REPLACE VIEW DIFERENCIAS_PREM_NOTAS_DEP AS
    SELECT A.CODIGO_ESTUDIANTE,
           A.FACULTAD,
           A.MATERIA_PLAN,
           A.FACULTAD_CURSAR,
           A.MATERIA_CURSAR,
           TRIM (TO_CHAR (A.GRUPO, '00')) GRUPO,
           A.JORNADA_FACULTAD,
           SYSDATE FECHA,
           E.INDICADOR_PAGO,
           E.CODMIL,
           E.NOMBRE,
           E.ANIO,
           E.CICLO,
           D.CONSECUTIVO
    FROM (SELECT CODIGO_ESTUDIANTE,
                 FACULTAD,
                 MATERIA_PLAN,
                 FACULTAD_CURSAR,
                 JORNADA_FACULTAD,
                 GRUPO,
                 MATERIA_CURSAR,
                 ANIO,
                 CICLO,
                 INDICADOR_PAGO
          FROM CACTUALPOS.B_PREMATRICULA
          UNION
          SELECT CODIGO_ESTUDIANTE,
                 FACULTAD,
                 MATERIA_PLAN,
                 FACULTAD_CURSAR,
                 JORNADA_FACULTAD,
                 GRUPO,
                 MATERIA_CURSAR,
                 ANIO,
                 CICLO,
                 INDICADOR_PAGO
          FROM CACTUALPRE.B_PREMATRICULA
          UNION
          SELECT CODIGO_ESTUDIANTE,
                 FACULTAD,
                 MATERIA_PLAN,
                 FACULTAD_CURSAR,
                 JORNADA_FACULTAD,
                 GRUPO,
                 MATERIA_CURSAR,
                 ANIO,
                 CICLO,
                 INDICADOR_PAGO
          FROM POSTGRADO.B_PREMATRICULA
          UNION
          SELECT CODIGO_ESTUDIANTE,
                 FACULTAD,
                 MATERIA_PLAN,
                 FACULTAD_CURSAR,
                 JORNADA_FACULTAD,
                 GRUPO,
                 MATERIA_CURSAR,
                 ANIO,
                 CICLO,
                 INDICADOR_PAGO
          FROM ADMISIONES.B_PREMATRICULA
    ) A
    INNER JOIN POSTGRADO.A_MATERIAS                      B ON A.MATERIA_CURSAR = B.CODIGO
                                         AND A.FACULTAD_CURSAR = B.CODIGO_FACULTAD
    LEFT JOIN POSTGRADO.B_PREMATRICULA_NOTAS_DEPURADA   C ON C.FACULTAD_CURSAR = A.FACULTAD_CURSAR
                                                           AND TO_NUMBER (C.GRUPO) = TO_NUMBER (A.GRUPO)
                                                           AND C.MATERIA_CURSAR = A.MATERIA_CURSAR
                                                           AND C.ANIO = A.ANIO
                                                           AND C.CICLO = A.CICLO
                                                           AND C.CODIGO_ESTUDIANTE = A.CODIGO_ESTUDIANTE
    INNER JOIN (SELECT *
                FROM POSTGRADO.A_HORARIO_HORIZONTAL
                UNION
                SELECT *
                FROM CACTUALPOS.A_HORARIO_HORIZONTAL
    ) D ON D.CODIGO_FACULTAD = A.FACULTAD_CURSAR
           AND A.MATERIA_CURSAR = D.CODIGO_MATERIA
           AND TO_NUMBER (D.GRUPO_MATERIA) = TO_NUMBER (A.GRUPO)
           AND D.JORNADA_FACULTAD = A.JORNADA_FACULTAD
    INNER JOIN (SELECT E.CODIGO,
                       E.INDICADOR_PAGO,
                       E.CODMIL,
                       E.NOMBRE,
                       E.ANIO,
                       E.CICLO
                FROM POSTGRADO.B_ESTUDIANTES E
                UNION
                SELECT E.CODIGO,
                       E.INDICADOR_PAGO,
                       E.CODMIL,
                       E.NOMBRE,
                       E.ANIO,
                       E.CICLO
                FROM ADMISIONES.B_ESTUDIANTES E
    ) E ON E.CODIGO = A.CODIGO_ESTUDIANTE
    INNER JOIN POSTGRADO.AH_HORIZONTAL_ACTUAL            F ON A.FACULTAD_CURSAR = F.CODIGO_FACULTAD
                                                   AND A.MATERIA_CURSAR = F.CODIGO_MATERIA
                                                   AND TRIM (TO_CHAR (A.GRUPO, '00')) = F.GRUPO_MATERIA
    WHERE A.INDICADOR_PAGO IN (
        'P',
        'V',
        'W'
    )
          AND C.CODIGO_ESTUDIANTE IS NULL
    ORDER BY 4,
             3,
             1;