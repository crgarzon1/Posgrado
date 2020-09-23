create or replace FUNCTION ESTADO_MATERIAS (
    P_CODIGO_ESTUDIANTE VARCHAR2
) RETURN MATERIAS_ESTUDIANTE IS

    V_RETURNABLE          MATERIAS_ESTUDIANTE;
    V_TIPO_PROGRAMA       NUMBER;
    V_TIPO_PREGRADO       NUMBER DEFAULT 1;
    V_TIPO_POSTGRADO      NUMBER DEFAULT 2;
    V_TIPO_YOPAL          NUMBER DEFAULT 4;
    V_ANIO                VARCHAR2 (4) DEFAULT NULL;
    V_CICLO               VARCHAR2 (2) DEFAULT NULL;
    V_ESQUEMA_PRINCIPAL   VARCHAR2 (256) DEFAULT NULL;
    V_ESQUEMA             VARCHAR2 (256) DEFAULT NULL;
    V_QUERY               VARCHAR2 (4000);
    V_JOIN_OPERATOR VARCHAR2(20) DEFAULT 'LEFT JOIN';
BEGIN
    IF SUBSTR (P_CODIGO_ESTUDIANTE, '0', '2') = '46' THEN
        V_TIPO_PROGRAMA       := V_TIPO_YOPAL;
        V_ESQUEMA_PRINCIPAL   := 'YOPAL';
    ELSIF SUBSTR (P_CODIGO_ESTUDIANTE, '0', '2') < '71' THEN
        V_TIPO_PROGRAMA       := V_TIPO_PREGRADO;
        V_ESQUEMA_PRINCIPAL   := 'ADMISIONES';
    ELSIF SUBSTR (P_CODIGO_ESTUDIANTE, '0', '2') >= '71' THEN
        V_TIPO_PROGRAMA       := V_TIPO_POSTGRADO;
        V_ESQUEMA_PRINCIPAL   := 'POSTGRADO';
    END IF;

    PKG_UTILS.GETANIOCICLOESQUEMA (V_TIPO_PROGRAMA, V_ANIO, V_CICLO, V_ESQUEMA);

    IF(GRADUADO(P_CODIGO_ESTUDIANTE) = '1') THEN
        V_JOIN_OPERATOR := 'INNER JOIN';
    END IF;

    V_QUERY := 
        q'!
                    SELECT MATERIA_ESTUDIANTE (TO_NUMBER (MATERIA.SEMESTRE), MATERIA.CODIGO, TRIM (MATERIA.NOMBRE), MATERIA.CREDITOS, NOTA.VALOR,
                                               CASE
                                        WHEN 
                                            ('!' || V_ESQUEMA_PRINCIPAL || q'!' = 'POSTGRADO' AND NOTA.VALOR IS NOT NULL AND NOTA.VALOR >= 3.5)
                                            OR 
                                            ('!' || V_ESQUEMA_PRINCIPAL || q'!' != 'POSTGRADO' AND NOTA.VALOR IS NOT NULL
                                                AND ((NOTA.INDICADOR != 'V' AND NOTA.VALOR >= 3)
                                                OR (NOTA.INDICADOR = 'V' AND NOTA.VALOR >= 3.5))) 
                                             THEN
                                            1
                                        ELSE
                                            0
                                    END,
                                               CASE
                                                   WHEN PREMATRICULA.MATERIA_PLAN IS NOT NULL THEN
                                                       1
                                                   ELSE
                                                       0
                                               END
                    ) 
                    FROM !' || V_ESQUEMA_PRINCIPAL || q'!.B_ESTUDIANTES    ESTUDIANTE
                    INNER JOIN !' || V_ESQUEMA_PRINCIPAL || q'!.A_MATERIAS       MATERIA ON ESTUDIANTE.CODIGO_FACULTAD = MATERIA.CODIGO_FACULTAD
                                                     AND ESTUDIANTE.JORNADA_FACULTAD = MATERIA.JORNADA_FACULTAD
                                                     AND ESTUDIANTE.PLAN_ESTUDIO = MATERIA.PLAN_ESTUDIO
                    !' || V_JOIN_OPERATOR || ' ' || V_ESQUEMA_PRINCIPAL || q'!.A_NOTAS          NOTA ON NOTA.CODIGO_ESTUDIANTE = ESTUDIANTE.CODIGO
                                              AND NOTA.CODIGO_MATERIA = MATERIA.CODIGO
                                              AND NOTA.CODIGO_FACULTAD = ESTUDIANTE.CODIGO_FACULTAD
                                              AND NOTA.JORNADA_FACULTAD = ESTUDIANTE.JORNADA_FACULTAD
                                              AND NOTA.IND_HNVOPLAN = ESTUDIANTE.PLAN_ESTUDIO
                    LEFT JOIN !' || V_ESQUEMA || q'!.B_PREMATRICULA   PREMATRICULA ON PREMATRICULA.CODIGO_ESTUDIANTE = ESTUDIANTE.CODIGO
                                                             AND PREMATRICULA.MATERIA_PLAN = MATERIA.CODIGO
                                                             AND PREMATRICULA.FACULTAD = ESTUDIANTE.CODIGO_FACULTAD
                                                             AND PREMATRICULA.JORNADA_FACULTAD = ESTUDIANTE.JORNADA_FACULTAD
                    WHERE ESTUDIANTE.CODIGO = :codigoEstudiante
                          AND MATERIA.SEMESTRE != '00'
                    ORDER BY TO_NUMBER (MATERIA.SEMESTRE),
                             MATERIA.CODIGO
        !';

    EXECUTE IMMEDIATE V_QUERY BULK COLLECT
    INTO V_RETURNABLE
        USING P_CODIGO_ESTUDIANTE;
    RETURN V_RETURNABLE;
END;