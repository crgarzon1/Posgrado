/* ************************************ELIMINACION DE OBJETOS******************************************/
/* ****************************************************************************************************/

DROP TRIGGER UPDATE_CRM_ASPIRANTE;

DROP TRIGGER UPDATE_CRM_ESTUDIANTE;

/* ************************************CREACION DEL TRIGGER********************************************/
/* ****************************************************************************************************/
CREATE OR REPLACE TRIGGER UPDATE_CRM_ASPIRANTE FOR
    UPDATE OR INSERT ON A_ASPIRANTES
COMPOUND TRIGGER
    TYPE CTI_INTERESADO_TMP IS RECORD (
        TIPDOC             VARCHAR2 (8),
        NUMDOC             VARCHAR2 (32),
        CODIGO_FACULTAD    VARCHAR2 (2),
        JORNADA_FACULTAD   VARCHAR2 (1),
        ANIO               VARCHAR2 (4),
        CICLO              VARCHAR2 (2)
    );
    TYPE CTI_INTERESADOS_TMP IS
        TABLE OF CTI_INTERESADO_TMP INDEX BY PLS_INTEGER;
    G_ROW_LEVEL_INFO CTI_INTERESADOS_TMP;
    AFTER EACH ROW IS BEGIN
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT + 1).TIPDOC        := :NEW.TIPDOC;
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT).NUMDOC            := :NEW.NUMDOC;
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT).CODIGO_FACULTAD   := :NEW.CODIGO_FACULTAD;
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT).JORNADA_FACULTAD  := :NEW.JORNADA_FACULTAD;
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT).ANIO              := :NEW.ANIO;
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT).CICLO             := :NEW.CICLO;
    END AFTER EACH ROW;
    AFTER STATEMENT IS BEGIN
        FOR INDX IN 1..G_ROW_LEVEL_INFO.COUNT LOOP
            DESARROLLOSPRE.PKG_INTERESADOS_CRM.REFRESH_INTERESADO (CASE G_ROW_LEVEL_INFO (INDX).TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END, G_ROW_LEVEL_INFO (INDX).NUMDOC, G_ROW_LEVEL_INFO (INDX).CODIGO_FACULTAD, G_ROW_LEVEL_INFO (INDX).JORNADA_FACULTAD, G_ROW_LEVEL_INFO (INDX).ANIO,
                                               G_ROW_LEVEL_INFO (INDX).CICLO);
        END LOOP;
    END AFTER STATEMENT;
END;
/

/* ************************************CREACION DEL TRIGGER********************************************/
/* ****************************************************************************************************/

CREATE OR REPLACE TRIGGER UPDATE_CRM_ESTUDIANTE FOR
    UPDATE OR INSERT ON B_ESTUDIANTES
COMPOUND TRIGGER
    TYPE CTI_INTERESADO_TMP IS RECORD (
        CODIGO_EST VARCHAR2 (8)
    );
    TYPE CTI_INTERESADOS_TMP IS
        TABLE OF CTI_INTERESADO_TMP INDEX BY PLS_INTEGER;
    G_ROW_LEVEL_INFO CTI_INTERESADOS_TMP;
    AFTER EACH ROW IS BEGIN
        G_ROW_LEVEL_INFO (G_ROW_LEVEL_INFO.COUNT + 1).CODIGO_EST := :NEW.CODIGO;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
        V_TIPDOC             VARCHAR2 (8);
        V_NUMDOC             VARCHAR2 (32);
        V_CODIGO_FACULTAD    VARCHAR2 (2);
        V_JORNADA_FACULTAD   VARCHAR2 (1);
        V_ANIO               VARCHAR2 (4);
        V_CICLO              VARCHAR2 (2);
    BEGIN
        FOR INDX IN 1..G_ROW_LEVEL_INFO.COUNT LOOP
            BEGIN
                SELECT TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO
                INTO
                    V_TIPDOC,
                    V_NUMDOC,
                    V_CODIGO_FACULTAD,
                    V_JORNADA_FACULTAD,
                    V_ANIO,
                    V_CICLO
                FROM (SELECT COD_DEF,
                             TIPDOC,
                             NUMDOC,
                             CODIGO_FACULTAD,
                             JORNADA_FACULTAD,
                             ANIO,
                             CICLO
                      FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                      UNION
                      SELECT COD_DEF,
                             CASE TIPDOC WHEN 'CC' THEN 'C' WHEN 'TI' THEN 'T' WHEN 'PA' THEN 'P' END TIPDOC,
                             NUMDOC,
                             CODIGO_FACULTAD,
                             JORNADA_FACULTAD,
                             ANIO,
                             CICLO
                      FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
                ) ASPIRANTE
                WHERE ASPIRANTE.COD_DEF = G_ROW_LEVEL_INFO (INDX).CODIGO_EST;

                DESARROLLOSPRE.PKG_INTERESADOS_CRM.REFRESH_INTERESADO (V_TIPDOC, V_NUMDOC, V_CODIGO_FACULTAD, V_JORNADA_FACULTAD, V_ANIO,
                                                   V_CICLO);

            EXCEPTION
                WHEN OTHERS THEN
                    ADMISIONES.PKG_EXCEPTION.LOG_EXCEPTION ();
            END;
        END LOOP;
    END AFTER STATEMENT;
END;
/
