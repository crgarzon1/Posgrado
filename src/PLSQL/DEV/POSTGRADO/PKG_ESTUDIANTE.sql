CREATE OR REPLACE PACKAGE PKG_ESTUDIANTE AS 

    PROCEDURE CREAR_ESTUDIANTE_POSTGRADO (
        P_CODIGO_ESTUDIANTE VARCHAR2 DEFAULT NULL
    );
    
    FUNCTION GET_ULTIMO_PLAN_ESTUDIOS (
        V_CODIGO_FACULTAD    B_ESTUDIANTES.CODIGO_FACULTAD%TYPE,
        V_JORNADA_FACULTAD   B_ESTUDIANTES.JORNADA_FACULTAD%TYPE
    ) RETURN VARCHAR2;
    
END PKG_ESTUDIANTE;
/

CREATE OR REPLACE PACKAGE BODY PKG_ESTUDIANTE AS 

    PROCEDURE CREAR_ESTUDIANTE_POSTGRADO (
        P_CODIGO_ESTUDIANTE VARCHAR2 DEFAULT NULL
    ) IS
        V_CODIGO             B_ESTUDIANTES.CODIGO%TYPE DEFAULT NULL;
        V_NOMBRE             B_ESTUDIANTES.NOMBRE%TYPE DEFAULT NULL;
        V_SEXO               B_ESTUDIANTES.SEXO%TYPE DEFAULT NULL;
        V_CICLO_DE_INGRESO   B_ESTUDIANTES.CICLO_DE_INGRESO%TYPE DEFAULT NULL;
        V_TIPO_DE_INGRESO    B_ESTUDIANTES.TIPO_DE_INGRESO%TYPE DEFAULT NULL;
        V_CODIGO_FACULTAD    B_ESTUDIANTES.CODIGO_FACULTAD%TYPE DEFAULT NULL;
        V_JORNADA_FACULTAD   B_ESTUDIANTES.JORNADA_FACULTAD%TYPE DEFAULT NULL;
        V_PLAN_ESTUDIO       B_ESTUDIANTES.PLAN_ESTUDIO%TYPE DEFAULT NULL;
        V_INDICADOR_PAGO     B_ESTUDIANTES.INDICADOR_PAGO%TYPE DEFAULT 'X ';
        V_PROMEDIO_PONDERADO B_ESTUDIANTES.PROMEDIO_PONDERADO%TYPE DEFAULT 3;
        V_INGLES             B_ESTUDIANTES.INGLES%TYPE DEFAULT 'S';
        V_SISTEMAS           B_ESTUDIANTES.SISTEMAS%TYPE DEFAULT 'S';
        V_ANIO               B_ESTUDIANTES.ANIO%TYPE DEFAULT NULL;
        V_CICLO              B_ESTUDIANTES.CICLO%TYPE DEFAULT NULL;
        V_ESQUEMA            DESARROLLOSPRE.SS_SCHEMA.SCHEMA%TYPE;    
        V_EXISTE             NUMBER DEFAULT 0;
        V_ASIGNADA           NUMBER DEFAULT 0;
        V_ANIOCICLO          VARCHAR2 (6) DEFAULT NULL;
        V_NUMEROERROR        NUMBER;
        V_TEXTOERROR         VARCHAR2 (200);
        V_APELLIDOS          A_ASPIRANTES.APELLIDOS%TYPE DEFAULT NULL;
        V_NOMBRES            A_ASPIRANTES.NOMBRES%TYPE DEFAULT NULL;
        V_CONTEO             NUMBER DEFAULT 0;
        V_ANIO_ASP           VARCHAR2 (100) DEFAULT NULL;
        V_CICLO_ASP          VARCHAR2 (100) DEFAULT NULL;
    BEGIN
        V_EXISTE      := EXISTE_ESTUDIANTE (P_CODIGO_ESTUDIANTE);
        
        -- AÑO Y CICLO ACTUAL PARA POSTGRADO(2).
        ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA(2, V_ANIO, V_CICLO, V_ESQUEMA);
    
        SELECT T.ANIO, 
               T.CICLO
        INTO   V_ANIO_ASP, 
               V_CICLO_ASP
        FROM   A_FECHAS_DE_CORTE T
        WHERE  T.PROCESO = 'ADMISION ESTUDIANTES NUEVOS-POSTGRADO';
    
        -- SI EL ESTUDIANTE NO EXISTE.
        IF (EXISTE_ESTUDIANTE (P_CODIGO_ESTUDIANTE) = 0) THEN   
            -- OBTIENE EL REGISTRO DEL ASPIRANTE DE A_ASPIRANTES O A_HISTORICO_ASPIRORACLE.
            SELECT COD_DEF CODIGO, 
                   TRIM(NOMBRE) NOMBRE, 
                   SEXO SEXO, 
                   ANIO || TO_NUMBER(CICLO) CICLO_DE_INGRESO, 
                   -- PARA DOCTORADOS EL TIPO DE INGRESO ES 'NV'.
                   -- SI EL TIPO DE INGRESO ORIGINAL ES 'NUEVO' SE REEMPLAZA POR 'NV'.
                   CASE 
                        WHEN (   (V_CODIGO_FACULTAD IN ('DA', 'DE')) 
                              OR TIPOEST = 'NUEVO') THEN 'NV'
                        ELSE TIPOEST
                   END TIPO_DE_INGRESO, 
                   CODIGO_FACULTAD CODIGO_FACULTAD, 
                   JORNADA_FACULTAD JORNADA_FACULTAD, 
                   TRIM(APELLIDOS) APELLIDOS, 
                   TRIM(NOMBRES) NOMBRES
            INTO   V_CODIGO, 
                   V_NOMBRE, 
                   V_SEXO, 
                   V_CICLO_DE_INGRESO, 
                   V_TIPO_DE_INGRESO, 
                   V_CODIGO_FACULTAD, 
                   V_JORNADA_FACULTAD, 
                   V_APELLIDOS,
                   V_NOMBRES
            FROM   (SELECT AP.COD_DEF, 
                           AP.NOMBRE, 
                           AP.SEXO, 
                           AP.ANIO,
                           AP.CICLO, 
                           AP.TIPOEST, 
                           AP.CODIGO_FACULTAD, 
                           AP.JORNADA_FACULTAD, 
                           AP.APELLIDOS, 
                           AP.NOMBRES
                    FROM   POSTGRADO.A_ASPIRANTES AP
                    WHERE      AP.COD_DEF = P_CODIGO_ESTUDIANTE 
                           AND AP.ANIO    = V_ANIO_ASP 
                           AND AP.CICLO   = V_CICLO_ASP
                    UNION
                    SELECT AP.COD_DEF, 
                           AP.NOMBRE, 
                           AP.SEXO, 
                           AP.ANIO,
                           AP.CICLO, 
                           AP.TIPOEST, 
                           AP.CODIGO_FACULTAD, 
                           AP.JORNADA_FACULTAD, 
                           AP.APELLIDOS, 
                           AP.NOMBRES
                    FROM   POSTGRADO.A_HISTORICO_ASPIRORACLE AP
                    WHERE      AP.COD_DEF = P_CODIGO_ESTUDIANTE 
                           AND AP.ANIO    = V_ANIO 
                           AND AP.CICLO   = V_CICLO) X;
            
            -- TOMA EL ÚLTIMO PLAN DE ESTUDIOS.
            SELECT GET_ULTIMO_PLAN_ESTUDIOS(V_CODIGO_FACULTAD, V_JORNADA_FACULTAD)
            INTO   V_PLAN_ESTUDIO
            FROM   DUAL;
                   
            -- PASO DEL ESTUDIANTE DE LA TABLA A_ASPIRANTES 0 A_HISTORICO A B_ESTUDIANTES.
            INSERT INTO POSTGRADO.B_ESTUDIANTES (CODIGO, NOMBRE, SEXO, CICLO_DE_INGRESO, TIPO_DE_INGRESO, CODIGO_FACULTAD, JORNADA_FACULTAD, INGLES, SISTEMAS, PLAN_ESTUDIO, 
                                                 INDICADOR_PAGO, PROMEDIO_PONDERADO, CODMIL, SEMESTRE_INFERIOR, DOCUMENTO, ANIO, CICLO, APELLIDOS, NOMBRES, FECHA_MODIFICACION) 
                                         VALUES (V_CODIGO, 
                                                 V_NOMBRE, 
                                                 V_SEXO, 
                                                 V_CICLO_DE_INGRESO, 
                                                 V_TIPO_DE_INGRESO,
                                                 V_CODIGO_FACULTAD,
                                                 V_JORNADA_FACULTAD,
                                                 V_INGLES,
                                                 V_SISTEMAS, 
                                                 V_PLAN_ESTUDIO, 
                                                 V_INDICADOR_PAGO, 
                                                 V_PROMEDIO_PONDERADO, 
                                                 --SUBSTR (P_CODIGO_ESTUDIANTE, 1, 2) || '2' || SUBSTR (P_CODIGO_ESTUDIANTE, 3, 6), 
                                                 CTI_CODMIL(),
                                                 '01', 
                                                 V_ANIO || TO_NUMBER (V_CICLO) || V_TIPO_DE_INGRESO,
                                                 V_ANIO,
                                                 V_CICLO, 
                                                 TRIM (V_APELLIDOS), 
                                                 TRIM (V_NOMBRES), 
                                                 SYSDATE);
            
            -- INSERCION DE DATOS PERSONALES DEL ESTUDIANTE.
            INSERT INTO POSTGRADO.DATOS_PERSONALES
                SELECT AP.COD_DEF, 
                       NULL, 
                       TD.CODIGO TIPODOC, 
                       TD.VALOR NOMBRE_DOCUMENTO, 
                       AP.NUMDOC NUMERO_DOCUMENTO, 
                       -- DEPARTAMENTO DEL DOCUMENTO.
                       AP.CODDEPTO_DOCUMENTO, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_DOCUMENTO, AP.CODDEPTO_DOCUMENTO) DEPARTAMENTO_DOCUMENTO, 
                       -- MUNICIPIO DEL DOCUMENTO.
                       AP.CODMUNI_DOCUMENTO, 
                       GET_NOMBRE_MUNICIPIO(AP.CODDEPTO_DOCUMENTO, AP.CODMUNI_DOCUMENTO) MUNICIPIO_DOCUMENTO, 
                       -- DEPARTAMENTO DE NACIMIENTO.
                       AP.CODDEPTO_NACIMIENTO, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_NACIMIENTO, AP.CODDEPTO_NACIMIENTO) DEPARTAMENTO_NACIMIENTO, 
                       -- MUNICIPIO DE NACIMIENTO.
                       AP.CODMUNI_NACIMIENTO, 
                       GET_NOMBRE_MUNICIPIO(AP.CODDEPTO_DOCUMENTO, AP.CODMUNI_NACIMIENTO) MUNICIPIO_NACIMIENTO, 
                       AP.FECHA_NACIMIENTO, 
                       '01', 
                       'Soltero(a)', 
                       -- DEPARTAMENTO DE RESIDENCIA.
                       AP.CODDEPTO_RESIDENCIA, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_RESIDENCIA, AP.CODMUNI_RESIDENCIA) DEPARTAMENTO_RESIDENCIA, 
                       -- MUNICIO DE RESIDENCIA.
                       AP.CODMUNI_RESIDENCIA,
                       GET_NOMBRE_MUNICIPIO(AP.CODDEPTO_RESIDENCIA, AP.CODMUNI_RESIDENCIA) DEPARTAMENTO_RESIDENCIA, 
                       AP.DIRECCION, 
                       AP.BARRIO, 
                       AP.TELEFONO_CASA, 
                       AP.TELEFONO_OTRO, 
                       AP.TELEFONO_OTRO,
                       AP.EMAIL, 
                       AP.EMAIL, 
                       '99', 
                       'No sabe/No responde', 
                       TRIM (AP.PRIMER_APELLIDO) || ' ' || TRIM (AP.SEGUNDO_APELLIDO) || ' ' || TRIM (AP.PRIMER_NOMBRE) || ' ' || TRIM (AP.SEGUNDO_NOMBRE) NOMBRE, 
                       AP.CODIGO_FACULTAD,
                       AP.JORNADA_FACULTAD, 
                       AP.SEXO, 
                       'EPS888', 
                       'No sabe/No responde', 
                       '11',
                       'Bogota D.C', 
                       '001', 
                       'Bogota', 
                       SYSDATE, 
                       TRIM (AP.PRIMER_APELLIDO),
                       TRIM (AP.SEGUNDO_APELLIDO),
                       TRIM (AP.PRIMER_NOMBRE),
                       TRIM (AP.SEGUNDO_NOMBRE)
                FROM   POSTGRADO.A_ASPIRANTES AP,
                       POSTGRADO.A_TIPO_DOCUMENTO TD
                WHERE      DECODE (AP.TIPDOC, 'CC', '01', 'CE', '02', 'PS', '05', '01') = TD.CODIGO 
                       AND AP.COD_DEF = P_CODIGO_ESTUDIANTE
                UNION
                SELECT AP.COD_DEF, 
                       NULL, 
                       TD.CODIGO TIPODOC,
                       TD.VALOR NOMBRE_DOCUMENTO, 
                       AP.NUMDOC NUMERO_DOCUMENTO, 
                       -- DEPARTAMENTO DEL DOCUMENTO.
                       AP.CODDEPTO_DOCUMENTO, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_DOCUMENTO, AP.CODDEPTO_DOCUMENTO) DEPARTAMENTO_DOCUMENTO, 
                       -- MUNICIPIO DEL DOCUMENTO.
                        AP.CODMUNI_DOCUMENTO, 
                       GET_NOMBRE_MUNICIPIO(AP.CODDEPTO_DOCUMENTO, AP.CODMUNI_DOCUMENTO) MUNICIPIO_DOCUMENTO, 
                       -- DEPARTAMENTO DE NACIMIENTO.
                        AP.CODDEPTO_NACIMIENTO, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_NACIMIENTO, AP.CODDEPTO_NACIMIENTO) DEPARTAMENTO_NACIMIENTO, 
                       -- MUNICIPIO DE NACIMIENTO.
                       AP.CODMUNI_NACIMIENTO, 
                       GET_NOMBRE_MUNICIPIO(AP.CODDEPTO_DOCUMENTO, AP.CODMUNI_NACIMIENTO) MUNICIPIO_NACIMIENTO, 
                       AP.FECHA_NACIMIENTO, 
                       '01', 
                       'Soltero(a)', 
                       -- DEPARTAMENTO DE RESIDENCIA.
                       AP.CODDEPTO_RESIDENCIA, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_RESIDENCIA, AP.CODMUNI_RESIDENCIA) DEPARTAMENTO_RESIDENCIA, 
                       -- MUNICIO DE RESIDENCIA.
                       AP.CODMUNI_RESIDENCIA, 
                       GET_NOMBRE_DEPARTAMENTO(AP.CODDEPTO_RESIDENCIA, AP.CODMUNI_RESIDENCIA) DEPARTAMENTO_RESIDENCIA, 
                       AP.DIRECCION, 
                       AP.BARRIO, 
                       AP.TELEFONO_CASA, 
                       AP.TELEFONO_OTRO, 
                       AP.TELEFONO_OTRO, 
                       AP.EMAIL, 
                       AP.EMAIL, 
                       '99', 
                       'No sabe/No responde', 
                       TRIM (AP.PRIMER_APELLIDO) || ' ' || TRIM (AP.SEGUNDO_APELLIDO) || ' ' || TRIM (AP.PRIMER_NOMBRE) || ' ' || TRIM (AP.SEGUNDO_NOMBRE) NOMBRE, 
                       AP.CODIGO_FACULTAD, 
                       AP.JORNADA_FACULTAD, 
                       AP.SEXO, 
                       'EPS888', 
                       'No sabe/No responde', 
                       '11', 
                       'Bogota D.C', 
                       '001', 
                       'Bogota', 
                       SYSDATE, 
                       TRIM (AP.PRIMER_APELLIDO), 
                       TRIM (AP.SEGUNDO_APELLIDO), 
                       TRIM (AP.PRIMER_NOMBRE), 
                       TRIM (AP.SEGUNDO_NOMBRE)
                FROM   POSTGRADO.A_HISTORICO_ASPIRORACLE AP, 
                       POSTGRADO.A_TIPO_DOCUMENTO TD
                WHERE      DECODE (AP.TIPDOC, 'CC', '01', 'CE', '02', 'PS', '05', '01') = TD.CODIGO 
                       AND AP.COD_DEF = P_CODIGO_ESTUDIANTE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000, 'Error al crear estudiante');
    END CREAR_ESTUDIANTE_POSTGRADO;    
    
    FUNCTION GET_ULTIMO_PLAN_ESTUDIOS (
        V_CODIGO_FACULTAD    B_ESTUDIANTES.CODIGO_FACULTAD%TYPE,
        V_JORNADA_FACULTAD   B_ESTUDIANTES.JORNADA_FACULTAD%TYPE
    ) RETURN VARCHAR2 IS
        V_RETURNABLE VARCHAR2(3);
    BEGIN
        SELECT MAX(PE.PLAN_ESTUDIO)
        INTO   V_RETURNABLE 
        FROM   A_PLANES_DE_ESTUDIO PE 
        WHERE      PE.CODIGO_FACULTAD = V_CODIGO_FACULTAD 
               AND PE.JORNADA_FACULTAD = V_JORNADA_FACULTAD;
        RETURN V_RETURNABLE;
    END GET_ULTIMO_PLAN_ESTUDIOS;
END PKG_ESTUDIANTE;
/

SELECT * FROM A_PLANES_DE_ESTUDIO;

CREATE OR REPLACE FUNCTION GET_NOMBRE_DEPARTAMENTO(
    P_CODIGO_DEPARTAMENTO	VARCHAR2,
    P_CODIGO_MUNICIPIO	VARCHAR2
) RETURN VARCHAR2 IS
    V_RETURNABLE VARCHAR2(27);
BEGIN
    SELECT DISTINCT DP.NOM_MUNICIPIO
    INTO   V_RETURNABLE
    FROM   ADMISIONES.A_DIVIPOLA DP
    WHERE      DP.CODIGO_DEPARTAMENTO = P_CODIGO_DEPARTAMENTO
           AND DP.CODIGO_MUNICIPIO    = P_CODIGO_MUNICIPIO;
    RETURN V_RETURNABLE;
END;
/

CREATE OR REPLACE FUNCTION GET_NOMBRE_MUNICIPIO(
    P_CODIGO_DEPARTAMENTO	VARCHAR2,
    P_CODIGO_MUNICIPIO	VARCHAR2
) RETURN VARCHAR2 IS
    V_RETURNABLE VARCHAR2(19);
BEGIN
    SELECT DISTINCT DP.NOM_DEPARTAMENTO
    INTO   V_RETURNABLE
    FROM   ADMISIONES.A_DIVIPOLA DP
    WHERE      DP.CODIGO_DEPARTAMENTO = P_CODIGO_DEPARTAMENTO
           AND DP.CODIGO_MUNICIPIO    = P_CODIGO_MUNICIPIO;
    RETURN V_RETURNABLE;
END;
/