CREATE OR REPLACE VIEW CTI_ESTADO_INTERESADO AS
    SELECT A.NUMDOC   INTERESADO,
           C.NUMDOC   CRM,
           D.NUMDOC   ASPIRANTE,
           CASE
               WHEN D.CODIGO IS NOT NULL THEN
                   D.PRIMER_NOMBRE
               ELSE
                   A.PRIMER_NOMBRE
           END PRIMER_NOMBRE,
           CASE
               WHEN D.CODIGO IS NOT NULL THEN
                   D.SEGUNDO_NOMBRE
               ELSE
                   A.SEGUNDO_NOMBRE
           END SEGUNDO_NOMBRE,
           CASE
               WHEN D.CODIGO IS NOT NULL THEN
                   D.PRIMER_APELLIDO
               ELSE
                   A.PRIMER_APELLIDO
           END PRIMER_APELLIDO,
           CASE
               WHEN D.CODIGO IS NOT NULL THEN
                   D.SEGUNDO_APELLIDO
               ELSE
                   A.SEGUNDO_APELLIDO
           END SEGUNDO_APELLIDO,
           A.TIPDOC,
           A.ORIGEN,
           B.CODIGO,
           B.JORNADA,
           B.NOMBRE,
           TO_CHAR (FECHA, 'YYYY-MM-DD HH24:MI') FECHA_CREACION_INTERESADO,
           A.ANIO,
           A.CICLO
    FROM DESARROLLOSPRE.CTI_INTERESADO       A
    INNER JOIN ADMISIONES.A_FACULTADES             B ON A.CODIGO_FACULTAD = B.CODIGO
                                            AND A.JORNADA_FACULTAD = B.JORNADA
    LEFT JOIN DESARROLLOSPRE.CTI_INTERESADO_CRM   C ON C.TIPDOC = A.TIPDOC
                                                     AND C.NUMDOC = A.NUMDOC
                                                     AND C.CODIGO_FACULTAD = A.CODIGO_FACULTAD
                                                     AND C.JORNADA_FACULTAD = A.JORNADA_FACULTAD
                                                     AND C.ANIO = A.ANIO
                                                     AND C.CICLO = A.CICLO
    LEFT JOIN (SELECT CODIGO,
                      TIPDOC,
                      NUMDOC,
                      CODIGO_FACULTAD,
                      JORNADA_FACULTAD,
                      ANIO,
                      CICLO,
                      IND1,
                      'PREGRADO' ESQUEMA,
                      PRIMER_NOMBRE,
                      SEGUNDO_NOMBRE,
                      PRIMER_APELLIDO,
                      SEGUNDO_APELLIDO,
                      EMAIL,
                      CELULAR
               FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
               UNION
               SELECT CODIGO,
                      CASE TIPDOC
                          WHEN 'CC'   THEN
                              'C'
                          WHEN 'TI'   THEN
                              'T'
                          WHEN 'PA'   THEN
                              'P'
                      END TIPDOC,
                      NUMDOC,
                      CODIGO_FACULTAD,
                      JORNADA_FACULTAD,
                      ANIO,
                      CICLO,
                      IND1,
                      'POSTGRADO' ESQUEMA,
                      PRIMER_NOMBRE,
                      SEGUNDO_NOMBRE,
                      PRIMER_APELLIDO,
                      SEGUNDO_APELLIDO,
                      EMAIL,
                      CELULAR
               FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
    ) D ON D.TIPDOC = A.TIPDOC
           AND D.NUMDOC = A.NUMDOC
           AND D.CODIGO_FACULTAD = A.CODIGO_FACULTAD
           AND D.JORNADA_FACULTAD = A.JORNADA_FACULTAD
           AND D.ANIO = A.ANIO
           AND D.CICLO = A.CICLO;