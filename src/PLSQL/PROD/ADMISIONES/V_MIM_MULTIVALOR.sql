CREATE OR REPLACE FORCE VIEW "ADMISIONES"."V_MIM_MULTIVALOR" (
    "ID",
    "EST_DOCUMENTO",
    "EST_INFO",
    "EST_RELACION"
) AS
    SELECT ROWNUM ID,
           TD.TIPO || V.NUMERO_DOCUMENTO EST_DOCUMENTO,
           'registro' EST_INFO,
           DECODE (VDP.INDICADOR_PAGO, 'P', 'S', 'V', 'S', 'W', 'S',
                   'K', 'N', 'C', 'N', 'N') ||
           '|' ||
           (DECODE (VDP.NUMERO_ACTA, '0', 'ESTUDIANTE', 'EGRESADO')) ||
           '|' ||
           VDP.CODFAC ||
           '|' ||
           VDP.NOMFAC ||
           '|' ||
           VDP.ABREVIATURA_FAC_NVO ||
           '|' ||
           VDP.CODPGM ||
           '|' ||
           VDP.PROGRAMA ||
           '|' ||
           VDP.ABREVIATURA_PGM_NVO ||
           '|' ||
           VDP.CODIGO_ESTUDIANTE EST_RELACION
    FROM V_MIM_ESTUDIANTES   V,
         V_MIM_DATOSPER      VDP,
         A_TIPO_DOCUMENTO    TD
    WHERE V.CODTIPO_DOCUMENTO = TD.CODIGO
          AND V.NUMERO_DOCUMENTO = VDP.NUMERO_DOCUMENTO;