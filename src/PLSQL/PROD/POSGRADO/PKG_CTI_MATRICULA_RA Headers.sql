CREATE OR REPLACE PACKAGE PKG_CTI_MATRICULA_RA AS
    FUNCTION GETOFERTA (
        P_CODIGO_ESTUDIANTE   B_ESTUDIANTES.CODIGO%TYPE,
        V_ANIO                VARCHAR2,
        V_CICLO               VARCHAR2,
        V_ESQUEMA             VARCHAR2
    ) RETURN SYS_REFCURSOR;

END PKG_CTI_MATRICULA_RA;