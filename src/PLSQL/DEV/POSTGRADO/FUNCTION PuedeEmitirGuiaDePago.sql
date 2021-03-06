CREATE OR REPLACE FUNCTION PuedeEmitirGuiaDePago(P_CODIGO_ESTUDIANTE VARCHAR2) RETURN NUMBER IS
    V_TIPO_ESTUDIANTE VARCHAR2(2);
    V_MATERIAS_FALTANTES NUMBER;
    V_MATRICULADO_CICLO_ANTERIOR NUMBER;
BEGIN
    IF(P_CODIGO_ESTUDIANTE IS NULL) THEN RETURN 0; END IF;
    
    SELECT    TIPO_DE_INGRESO,
              NVL(MATERIAS_PENDIENTES, '0'),     
              CASE WHEN (P.ID_PERIODO IS NOT NULL) THEN 1 ELSE 0 END
    INTO      V_TIPO_ESTUDIANTE,
              V_MATERIAS_FALTANTES,
              V_MATRICULADO_CICLO_ANTERIOR
    FROM      B_ESTUDIANTES E
    LEFT JOIN CTI_PERIODO P ON E.MATRICULADOS_CICLO_ANTERIOR = P.INDICADOR_PAGO
    WHERE     CODIGO = P_CODIGO_ESTUDIANTE;
    
    IF(ADMISIONES.VERIFICAR_DEUDA_FINANCIERA(P_CODIGO_ESTUDIANTE) != 'OK') THEN RETURN 0;
    ELSIF (ADMISIONES.VERIFICAR_DEUDA_BIBLIOTECA(P_CODIGO_ESTUDIANTE) != 'OK') THEN RETURN 0; 
    ELSIF (V_MATRICULADO_CICLO_ANTERIOR = 0) THEN RETURN 0; 
    ELSIF (V_TIPO_ESTUDIANTE IN ('RA', 'RE', 'RI', 'TE', 'TI')) THEN RETURN 0; 
    ELSIF (V_MATERIAS_FALTANTES <= 0) THEN RETURN 0; 
    END IF;
    RETURN 1;
END;
/
