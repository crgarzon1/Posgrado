CREATE OR REPLACE PACKAGE PKG_NOTAS IS

    FUNCTION PRC_GET_DOCENTES_CURSOR(P_VC_CODIGO_FACULTAD VARCHAR2) RETURN SYS_REFCURSOR;
    
    FUNCTION PRC_GET_HORARIOS_CURSOR(    
        P_VC_CODIGO_FACULTAD IN VARCHAR2,       
        P_VC_APELLIDOS       IN VARCHAR,
        P_VC_NOMBRES         IN VARCHAR2
    ) RETURN SYS_REFCURSOR;
    
END PKG_NOTAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_NOTAS IS
            
    FUNCTION PRC_GET_DOCENTES_CURSOR(P_VC_CODIGO_FACULTAD IN VARCHAR2) 
    RETURN SYS_REFCURSOR
    IS     
        V_QUERY  VARCHAR2(4000);
        V_CIERRE NUMBER DEFAULT 0;
        V_CON    VARCHAR2(1000) DEFAULT '';    
        V_CURSOR SYS_REFCURSOR;
    BEGIN
        SELECT     COUNT(*)
        INTO       V_CIERRE
        FROM       DESARROLLOSPRE.SS_SCHEMA SH
        INNER JOIN DESARROLLOSPRE.SS_PERIODO PR ON PR.ID_SCHEMA = SH.ID_SCHEMA
        WHERE          PR.ID_CICLO        = '2'
                   AND PR.ID_ESTADO_PERIODO = '1';
                   
        IF V_CIERRE=1 THEN
           V_CON:='cactualpos.';
        END IF;
        
        V_QUERY := q'!SELECT   DISTINCT(HA.APEDOC||HA.NOMBRE) NOMPRO,
                               HA.APEDOC,
                               HA.NOMBRE
                      FROM     !' || V_CON || q'!A_HORARIO_HORIZONTAL  HA
                      WHERE        HA.CODIGO_FACULTAD = :codFacultad
                               AND HA.MATRICULADOS>0
                               AND HA.NUMERO_DOCUMENTO NOT IN('0','99')
                      ORDER BY HA.APEDOC||HA.NOMBRE!';
        OPEN V_CURSOR FOR V_QUERY USING P_VC_CODIGO_FACULTAD;
        RETURN V_CURSOR;
    END PRC_GET_DOCENTES_CURSOR; 
    
    FUNCTION PRC_GET_HORARIOS_CURSOR(
        P_VC_CODIGO_FACULTAD IN VARCHAR2,
        P_VC_APELLIDOS       IN VARCHAR,
        P_VC_NOMBRES         IN VARCHAR2) 
    RETURN SYS_REFCURSOR
    IS
        V_QUERY  VARCHAR2(4000);
        V_CIERRE NUMBER DEFAULT 0;
        V_CON    VARCHAR2(1000) DEFAULT '';  
        V_CURSOR SYS_REFCURSOR;
    BEGIN
        SELECT     COUNT(*)
        INTO       V_CIERRE
        FROM       DESARROLLOSPRE.SS_SCHEMA SH
        INNER JOIN DESARROLLOSPRE.SS_PERIODO PR ON PR.ID_SCHEMA = SH.ID_SCHEMA
        WHERE          PR.ID_CICLO        = '2'
                   AND PR.ID_ESTADO_PERIODO = '1';
                   
        IF V_CIERRE=1 THEN
           V_CON:='cactualpos.';
        END IF;
        
        V_QUERY :=  q'!SELECT   *
                      FROM     !' || V_CON || q'!A_HORARIO_HORIZONTAL  HA
                      WHERE        HA.CODIGO_FACULTAD = :codFacultad
                               AND HA.APEDOC = :apellidos
                               AND HA.NOMBRE = :nombres
                               AND HA.MATRICULADOS > 0
                               AND HA.NUMERO_DOCUMENTO NOT IN('0','99')
                      ORDER BY HA.APEDOC||HA.NOMBRE!'; 
        OPEN V_CURSOR FOR V_QUERY USING P_VC_CODIGO_FACULTAD, P_VC_APELLIDOS, P_VC_NOMBRES;
        RETURN V_CURSOR;
    END PRC_GET_HORARIOS_CURSOR;
END PKG_NOTAS;
/