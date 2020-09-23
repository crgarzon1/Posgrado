
DROP TABLE AUX_B_ESTUDIANTES;
/
CREATE TABLE AUX_B_ESTUDIANTES (
    CODIGO VARCHAR(8),
    TIPO_ESTUDIANTE VARCHAR(2),
    CODIGO_TRANSACCION NUMBER,
    INDICADOR_PAGO_ORIGINAL VARCHAR(1),
    INDICADOR_PAGO_MODIFICADO VARCHAR(1)
);
/
INSERT INTO AUX_B_ESTUDIANTES(CODIGO,
                              TIPO_ESTUDIANTE,
                              INDICADOR_PAGO_ORIGINAL)
    SELECT CODIGO, 
           TIPO_DE_INGRESO, 
           INDICADOR_PAGO
    FROM   POSTGRADO.B_ESTUDIANTES 
    WHERE  INDICADOR_PAGO NOT IN ('X', 'K');

UPDATE     AUX_B_ESTUDIANTES
SET        CODIGO_TRANSACCION = (SELECT     COD_TRANSAC
                                 FROM       (SELECT     G.CODIGO_EST, 
                                                        E.INDICADOR_PAGO_ORIGINAL,
                                                        G.CODIGO_GUIA, 
                                                        G.COD_TRANSAC,
                                                        G.FECHA_GEN,
                                                        ROW_NUMBER() OVER (PARTITION BY G.CODIGO_EST ORDER BY G.FECHA_GEN DESC) AS ROW_NUM
                                             FROM       G_GUIAS_DE_PAGO G
                                             INNER JOIN AUX_B_ESTUDIANTES E ON G.CODIGO_EST = E.CODIGO
                                             WHERE          INDICADOR_PAGO = 'P'
                                                        AND ANIO = '2020'
                                                        AND CICLO = '01'
                                                        AND TOTAL_CRED_ADICIONALES = '0')
                                WHERE           CODIGO_EST = CODIGO
                                            AND ROW_NUM = 1);
UPDATE     AUX_B_ESTUDIANTES
SET        INDICADOR_PAGO_MODIFICADO = (SELECT X.INDICADOR_PAGO
                                        FROM (SELECT PR.INDICADOR_PAGO, 
                                                     TRIM(TO_CHAR(TX.COD_TRANSACCION, '00')) CODTX 
                                              FROM   CTI_GRUPO_EST_TX TX, 
                                                     CTI_PERIODO PR 
                                              WHERE  PR.ID_PERIODO = 0
                                              UNION
                                              SELECT     P.INDICADOR_PAGO, 
                                                         TRIM(TO_CHAR(D.CODIGO_DE_TRANSACCION, '00')) 
                                              FROM       CTI_DESCUENTO D 
                                              INNER JOIN CTI_PERIODO P ON D.ID_PERIODO = P.ID_PERIODO
                                              UNION
                                              SELECT PR.INDICADOR_PAGO, TRIM(TO_CHAR(PR.COD_TRANSACCION, '00')) CODTX 
                                              FROM   CTI_PERIODO PR 
                                              WHERE  PR.ID_PERIODO > 0) X
                                        WHERE X.CODTX = TRIM(TO_CHAR(CODIGO_TRANSACCION, '00')));

SELECT * 
FROM   AUX_B_ESTUDIANTES 
WHERE  INDICADOR_PAGO_ORIGINAL != INDICADOR_PAGO_MODIFICADO;

UPDATE B_ESTUDIANTES B
SET INDICADOR_PAGO = (SELECT INDICADOR_PAGO_MODIFICADO
                      FROM   AUX_B_ESTUDIANTES a
                      WHERE  INDICADOR_PAGO_ORIGINAL != INDICADOR_PAGO_MODIFICADO
                             and A.CODIGO = B.CODIGO)       
WHERE CODIGO IN (SELECT CODIGO
FROM   AUX_B_ESTUDIANTES 
WHERE  INDICADOR_PAGO_ORIGINAL != INDICADOR_PAGO_MODIFICADO);

SELECT CODIGO, INDICADOR_PAGO
FROM   B_ESTUDIANTES B
WHERE CODIGO IN (SELECT CODIGO
                 FROM   AUX_B_ESTUDIANTES 
                 WHERE  INDICADOR_PAGO_ORIGINAL != INDICADOR_PAGO_MODIFICADO)
ORDER BY CODIGO;
