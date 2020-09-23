CREATE OR REPLACE FUNCTION DEBE_DOCUMENTOS_PREMATRICULA (
    P_CODIGO IN VARCHAR2
) RETURN VARCHAR2 IS
    V_DEBE_DOCUMENTOS   NUMBER DEFAULT 0;
    V_EXCLUIDO          NUMBER DEFAULT 0;
BEGIN
    SELECT COUNT (1)
    INTO V_DEBE_DOCUMENTOS
    FROM DOC_ESTUDIANTE DE
    WHERE DE.CODIGO_ESTUDIANTE = P_CODIGO
          AND CODIGO_DOCUMENTO <> '3'
          AND DE.ESTADO = 'NO';

    IF V_DEBE_DOCUMENTOS > 0 THEN
        SELECT COUNT(*)
        INTO V_EXCLUIDO
        FROM DOC_ESTUDIANTE DOC
        WHERE DOC.CODIGO_ESTUDIANTE = P_CODIGO
              AND ((CODIGO_DOCUMENTO = 5
                    AND ESTADO  = 'NO')
                   OR (CODIGO_DOCUMENTO = 7
                       AND ESTADO  = 'NO')
                   OR (CODIGO_DOCUMENTO = 8
                       AND ESTADO  = 'NO'));

        IF (V_EXCLUIDO > 0) THEN
            RETURN (0);/*no debe documentos*/
        ELSE
            RETURN (1);/*debe documentos*/
        END IF;

    ELSE
        RETURN (0);/*no debe documentos*/
    END IF;

END;
/
