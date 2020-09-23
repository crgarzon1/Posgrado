create or replace PACKAGE BODY PKG_ESTUDIANTE AS 

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
        V_INDICADOR_PAGO     B_ESTUDIANTES.INDICADOR_PAGO%TYPE DEFAULT 'X';
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
                                                 SUBSTR (P_CODIGO_ESTUDIANTE, 1, 2) || '2' || SUBSTR (P_CODIGO_ESTUDIANTE, 3, 6), 
                                                 --CTI_CODMIL(),
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
                       
            SELECT COUNT(*) 
            INTO   V_CONTEO
            FROM   ADMISIONES.A_NUEVOS_MATRICULADOS M
            WHERE  M.CODIGO=P_CODIGO_ESTUDIANTE;
            
            IF V_CONTEO=0 THEN
                INSERT INTO ADMISIONES.A_NUEVOS_MATRICULADOS(CODIGO)
                VALUES (P_CODIGO_ESTUDIANTE); 
            END IF;   
            
            crear_usuario(p_codigo_estudiante);
            add_est_bolsa_electiva(p_codigo_estudiante);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR (-20000, 'Error al crear estudiante '|| sqlerrm);
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

    procedure crear_usuario(
        p_codigo admisiones.a_usuarios.codigo%type
    ) as
        n_n number;
        r_clave admisiones.a_claves_libres%rowtype;
    begin
        select count(*)
        into n_n
        from admisiones.a_usuarios u
        where u.codigo = p_codigo;
        if n_n > 0 then
            return;
        end if;
        select x.*
        into r_clave
        from (
            select l.*
            from admisiones.a_claves_libres l
            where l.indica is null
            order by dbms_random.value) x
        where rownum <= 1;
        delete from admisiones.a_claves_libres l
        where l.usuario = r_clave.usuario and l.clave = r_clave.clave;
        insert into admisiones.a_usuarios (usuario, clave, codigo, fecha, nombre_usuario, numero_documento)
        select r_clave.usuario, r_clave.clave, a.cod_def, to_char(sysdate, 'YY-MM-DD'), a.nombre, a.numdoc
        from a_aspirantes a
        where a.cod_def = p_codigo;
    end crear_usuario;

    procedure add_est_bolsa_electiva(
        p_codigo admisiones.a_usuarios.codigo%type
    ) as
    begin
        insert into postgrado.cti_bolsa_estudiante
        select seq_bolsa_estudiante.nextval, e.codigo, bc.id_bolsa
        from postgrado.b_estudiantes e
        inner join
        postgrado.cti_bolsas_creditos bc
        on e.codigo_facultad = bc.codigo_facultad and e.jornada_facultad = bc.jornada_facultad and e.plan_estudio = bc.plan_estudio
        where e.codigo = p_codigo;
    end add_est_bolsa_electiva;
    
     /***********Borrar la asignacion de creditos lectivos*************/
    procedure del_est_bolsa_electiva(
        p_codigo admisiones.a_usuarios.codigo%type
    ) as
    begin
       DELETE FROM postgrado.cti_bolsa_estudiante be 
       WHERE  be.codigo=p_codigo;
    end del_est_bolsa_electiva;
    /*******************************************************************/
    
    FUNCTION es_transferencia_reintegro (
        p_codigo_estudiante    b_estudiantes.codigo%TYPE
    ) RETURN NUMBER IS
        cantidad NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO cantidad
        FROM b_estudiantes b
        WHERE b.tipo_de_ingreso in ('RI', 'RA', 'TI', 'TE') 
        AND b.ciclo_de_ingreso = CONCAT(b.anio, TO_NUMBER(b.ciclo))
        AND b.codigo = p_codigo_estudiante;
        
        IF (cantidad > 0) THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END es_transferencia_reintegro;

END PKG_ESTUDIANTE;