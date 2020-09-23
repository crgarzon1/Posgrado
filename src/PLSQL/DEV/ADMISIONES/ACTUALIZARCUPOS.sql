CREATE OR REPLACE TRIGGER ACTUALIZARCUPOS AFTER
    INSERT ON B_PREMATRICULA
    REFERENCING
            NEW AS NEW
            OLD AS OLD
    FOR EACH ROW
DECLARE
    V_ESQUEMA_GRUPO NUMBER;    
    V_PREGRADO NUMBER DEFAULT '1';
    V_POSTGRADO NUMBER DEFAULT '2';
    V_CONSECUTIVO NUMBER;
    V_NUMEROERROR NUMBER;
    V_TEXTOERROR VARCHAR2 (200);
BEGIN
    SELECT UNIQUE ESQUEMA,
                  CONSECUTIVO
    INTO          V_ESQUEMA_GRUPO,
                  V_CONSECUTIVO
    FROM          (SELECT V_PREGRADO ESQUEMA,
                          CONSECUTIVO
                   FROM   ADMISIONES.A_HORARIO_HORIZONTAL
                   WHERE      CODIGO_FACULTAD = :NEW.FACULTAD_CURSAR 
                          AND CODIGO_MATERIA = :NEW.MATERIA_CURSAR 
                          AND TO_NUMBER (GRUPO_MATERIA) = :NEW.GRUPO
                   UNION
                   SELECT V_POSTGRADO,
                          CONSECUTIVO
                   FROM   POSTGRADO.A_HORARIO_HORIZONTAL
                   WHERE      CODIGO_FACULTAD = :NEW.FACULTAD_CURSAR 
                          AND CODIGO_MATERIA = :NEW.MATERIA_CURSAR 
                          AND TO_NUMBER (GRUPO_MATERIA) = :NEW.GRUPO) B;    
    CASE V_ESQUEMA_GRUPO
        WHEN V_PREGRADO THEN 
            UPDATE ADMISIONES.A_HORARIO_HORIZONTAL
            SET    CUPO_UTILIZADO = CUPO_UTILIZADO + 1
            WHERE  CONSECUTIVO = V_CONSECUTIVO;
        WHEN V_POSTGRADO THEN 
            POSTGRADO.PKG_MATRICULA.MODIFICARCUPO(V_CONSECUTIVO, 1);            
    END CASE;
EXCEPTION
    WHEN OTHERS THEN
        V_NUMEROERROR   := SQLCODE;
        V_TEXTOERROR    := SUBSTR (SQLERRM, 1, 200);
        INSERT INTO B_LOG (CODIGO, 
                           MENSAJE, 
                           INFORMACION)
        VALUES (V_NUMEROERROR, 
                V_TEXTOERROR, 
                   'Error en ActualizarCupos con la materia ' 
                || :NEW.MATERIA_CURSAR 
                || 'facultad ' 
                || :NEW.FACULTAD_CURSAR 
                || ' grupo ' 
                || :NEW.GRUPO 
                || ' ' 
                || TO_CHAR (SYSDATE, 'DD-MON-YY HH24:MI:SS'));
END ACTUALIZARCUPOS;