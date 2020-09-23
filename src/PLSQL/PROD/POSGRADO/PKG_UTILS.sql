create or replace package body pkg_utils as

    function getTopes(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type
    )return json_list as
        j_tope json;
        v_list json_list := json_list();
    begin
        for tope in (
            select cp.semestre, cp.periodo, cp.creditos
            from cti_creditos_periodo cp
            where cp.codigo_facultad = p_codigo_facultad
            and cp.jornada_facultad = p_jornada_facultad
            and cp.plan_estudio = p_plan_estudio
            order by 1, 2, 3
            ) loop
            j_tope := json();
            json.put(j_tope,'semestre',tope.semestre);
            json.put(j_tope,'periodo',tope.periodo);
            json.put(j_tope,'creditos',tope.creditos);
            json_list.append(v_list,j_tope.to_json_value);
        end loop;
        return v_list;
    exception
    when others then
        return null;
    end getTopes;

    function getBolsas(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type
    )return json_list as
        j_bolsa json;
        v_list json_list := json_list();
    begin
        for bolsa in (
            select b.id_bolsa, b.nombre, b.tope
            from cti_bolsas_creditos b
            where b.codigo_facultad = p_codigo_facultad
            and b.jornada_facultad = p_jornada_facultad
            and b.plan_estudio = p_plan_estudio
            and b.activo > 0
            order by 2
            ) loop
            j_bolsa := json();
            json.put(j_bolsa,'id',bolsa.id_bolsa);
            json.put(j_bolsa,'bolsa',bolsa.nombre);
            json.put(j_bolsa,'tope',bolsa.tope);
            json_list.append(v_list,j_bolsa.to_json_value);
        end loop;
        return v_list;
    exception
    when others then
        return null;
    end getBolsas;

    function getPlan(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_plan_estudio a_planes_de_estudio.plan_estudio%type,
        p_bolsas number default 0,
        p_topes number default 0
    )return json as
        v_plan a_planes_de_estudio%rowtype;
        j_plan json := json();
        j_bolsas json_list;
        j_topes json_list;
    begin
        select p.*
        into v_plan
        from a_planes_de_estudio p
        where p.codigo_facultad = p_codigo_facultad
        and p.jornada_facultad = p_jornada_facultad
        and p.plan_estudio = p_plan_estudio;
        json.put(j_plan,'id',v_plan.plan_estudio);
        json.put(j_plan,'plan',v_plan.descripcion);
        if p_bolsas > 0 then
            j_bolsas := getBolsas(p_codigo_facultad, p_jornada_facultad, p_plan_estudio);
            if j_bolsas is not null then
                json.put(j_plan,'bolsas',j_bolsas.to_json_value);
            end if;
        end if;
        if p_topes > 0 then
            j_topes := getTopes(p_codigo_facultad, p_jornada_facultad, p_plan_estudio);
            if j_topes is not null then
                json.put(j_plan,'topes',j_topes.to_json_value);
            end if;
        end if;
        return j_plan;
    exception
    when others then
        return null;
    end getPlan;

    function getPlanes(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_bolsas number default 0,
        p_topes number default 0
    )return json_list as
        j_plan json;
        v_list json_list := json_list();
    begin
        for planes in (
            select p.plan_estudio
            from a_planes_de_estudio p
            where p.codigo_facultad = p_codigo_facultad
            and p.jornada_facultad = p_jornada_facultad
            order by 1
            ) loop
            j_plan := getPlan(p_codigo_facultad, p_jornada_facultad, planes.plan_estudio, p_bolsas, p_topes);
            if j_plan is not null then
                json_list.append(v_list,j_plan.to_json_value);
            end if;
        end loop;
        return v_list;
    exception
    when others then
        return null;
    end getPlanes;

    function getFacultad(
        p_codigo_facultad admisiones.a_facultades.codigo%type,
        p_jornada_facultad admisiones.a_facultades.jornada%type,
        p_planes number default 0,
        p_bolsas number default 0,
        p_topes number default 0
    )return json as
        v_fac admisiones.a_facultades%rowtype;
        j_fac json := json();
        j_planes json_list;
    begin
        select f.*
        into v_fac
        from admisiones.a_facultades f
        where f.codigo = p_codigo_facultad
        and f.jornada = p_jornada_facultad;
        json.put(j_fac,'codigo',v_fac.codigo);
        json.put(j_fac,'jornada',v_fac.jornada);
        json.put(j_fac,'nombre',trim(v_fac.nombre));
        json.put(j_fac,'abreviatura',v_fac.abreviatura);
        json.put(j_fac,'activa',v_fac.activa);
        json.put(j_fac,'indicador',v_fac.indicador);
        if p_planes > 0 then
            j_planes := getPlanes(p_codigo_facultad, p_jornada_facultad, p_bolsas, p_topes);
            if j_planes is not null then
                json.put(j_fac,'planes',j_planes.to_json_value);
            end if;
        end if;
        return j_fac;
    exception
    when others then
        return null;
    end getFacultad;

    function getMateria(
        p_codigo_facultad a_materias.codigo_facultad%type,
        p_jornada_facultad a_materias.jornada_facultad%type,
        p_plan_estudio a_materias.plan_estudio%type,
        p_codigo a_materias.codigo%type,
        p_facultad number default 0,
        p_plan number default 0
    )return json as
        v_mat a_materias%rowtype;
        j_mat json := json();
        j_fac json;
        j_plan json;
    begin
        select m.*
        into v_mat
        from a_materias m
        where m.codigo = p_codigo
        and m.codigo_facultad = p_codigo_facultad
        and m.jornada_facultad = p_jornada_facultad
        and m.plan_estudio = p_plan_estudio;
        json.put(j_mat,'codigo',v_mat.codigo);
        json.put(j_mat,'semestre',v_mat.semestre);
        json.put(j_mat,'nombre',trim(v_mat.nombre));
        json.put(j_mat,'creditos',v_mat.creditos);
        json.put(j_mat,'plan',v_mat.plan_estudio);
        if p_facultad > 0 then
            j_fac := getFacultad(p_codigo_facultad, p_jornada_facultad);
            if j_fac is not null then
                json.put(j_mat,'facultad',j_fac.to_json_value);
            end if;
        end if;
        if p_plan > 0 then
            j_plan := getPlan(p_codigo_facultad, p_jornada_facultad, p_plan_estudio);
            if j_plan is not null then
                json.put(j_mat,'plan',j_plan.to_json_value);
            end if;
        end if;
        return j_mat;
    exception
    when others then
        return null;
    end getMateria;

    function getMaterias(
        p_codigo_facultad a_materias.codigo_facultad%type,
        p_jornada_facultad a_materias.jornada_facultad%type,
        p_plan_estudio a_materias.plan_estudio%type,
        p_semestre number default 1
    )return json_list as
        j_mat json;
        v_list json_list := json_list();
    begin
        for materias in (
            select m.semestre, m.codigo
            from a_materias m
            where m.codigo_facultad = p_codigo_facultad
            and m.jornada_facultad = p_jornada_facultad
            and m.plan_estudio = p_plan_estudio
            and m.semestre >= p_semestre
            order by 1, 2
            ) loop
            j_mat := getMateria(p_codigo_facultad, p_jornada_facultad, p_plan_estudio, materias.codigo);
            if j_mat is not null then
                json_list.append(v_list,j_mat.to_json_value);
            end if;
        end loop;
        return v_list;
    end getMaterias;

    function getGrupo(
        p_consecutivo a_horario_horizontal.consecutivo%type,
        p_abierto number default 1
    )return json as
        v_gr a_horario_horizontal%rowtype;
        j_gr json := json();
        j_fac json;
        j_mat json;
        v_fecha_inicial date;
        v_fecha_final   date;
    begin
        select h.*
        into v_gr
        from a_horario_horizontal h
        where h.consecutivo = p_consecutivo
        union
        select h.*
        from cactualpos.a_horario_horizontal h
        where h.consecutivo = p_consecutivo;
        if p_abierto > 0 and v_gr.abierto not in ('S') then
            return null;
        end if;
        json.put(j_gr,'id',v_gr.consecutivo);
        json.put(j_gr,'grupo',to_number(v_gr.grupo_materia));
        json.put(j_gr,'abierto',v_gr.abierto);

        select min(fecha_inicial),
               max(fecha_final)
        into   v_fecha_inicial,
               v_fecha_final
        from   (select fecha_inicial, fecha_final from admisiones.a_bloques_pos where  consecutivo = p_consecutivo
                union
                select fecha_inicial, fecha_final from cactualpre.a_bloques_pos where  consecutivo = p_consecutivo);

        if(v_fecha_inicial is not null and v_fecha_final is not null) then
            json.put(j_gr,'fechaInicial', TO_CHAR (v_fecha_inicial, 'RRRR/MM/DD HH24:MI:SS'));
            json.put(j_gr,'fechaFinal', TO_CHAR (v_fecha_final, 'RRRR/MM/DD HH24:MI:SS'));
        end if;

        j_fac := getFacultad(v_gr.codigo_facultad, v_gr.jornada_facultad);
        if j_fac is not null then
            json.put(j_gr,'facultad',j_fac.to_json_value);
            j_mat := getMateria(v_gr.codigo_facultad, v_gr.jornada_facultad, v_gr.plan_estudio, v_gr.codigo_materia);
            if j_mat is not null then
                json.put(j_gr,'materia',j_mat.to_json_value);
            end if;
        end if;
        return j_gr;
    exception
    when others then
        return null;
    end getGrupo;

    /*
        EVALUA SI EL PAGO DEL ESTUDIANTE ES VIGENTE PARA EL PERIODO ACTUAL.
        @param P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE. CODIGO DEL ESTUDIANTE
        @return O = EL ESTUDIANTE NO HA REGISTRADO PAGOS EN EL SEMESTRE ACTUAL.
                1 = EL ESTUDIANTE TIENE PAGO PARA EL TRIMESTRE VIGENTE.
                2 = EL ESTUDIANTE HA REGISTRADO PAGOS PARA EL SEMESTRE ACTUAL, PERO NO PARA EL TRIMESTRE ACTUAL.
        */    
    FUNCTION EVALUAR_PAGO_ESTUDIANTE (
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN NUMBER IS
        -- INDICADOR DE PAGO DE ESTUDIANTE.
        V_INDICADOR_PAGO         B_ESTUDIANTES.INDICADOR_PAGO%TYPE;
        -- AÑO Y CICLO ACTUALES.
        V_ANIO                   DESARROLLOSPRE.SS_PERIODO.ANIO%TYPE;
        V_CICLO                  DESARROLLOSPRE.SS_PERIODO.CICLO%TYPE;
        -- ESQUEMA ACTUAL.
        V_ESQUEMA                DESARROLLOSPRE.SS_SCHEMA.SCHEMA%TYPE;        
        -- SQL DINAMICO PARA CAMBIAR DE ESQUEMA.
        V_SQL                    VARCHAR(2000);  
    BEGIN    
        -- OBTENIENDO CICLO ACTUAL.
		ADMISIONES.PKG_UTILS.GETANIOCICLOESQUEMA(2, V_ANIO, V_CICLO, V_ESQUEMA);

        -- SQL PARA OBTENER INDICADOR DE PAGO DEL ESTUDIANTE.
        V_SQL := '
            SELECT  INDICADOR_PAGO
            FROM    ' || V_ESQUEMA || '.B_ESTUDIANTES
            WHERE   CODIGO = :codigo 
        ';

        -- OBTENEMOS EL INDICADOR DE PAGO DEL SQL DINAMICO.
        EXECUTE IMMEDIATE V_SQL 
        INTO              V_INDICADOR_PAGO 
        USING             P_CODIGO_ESTUDIANTE;

        RETURN EVALUAR_PAGO(V_INDICADOR_PAGO);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END EVALUAR_PAGO_ESTUDIANTE;

    /*
        EVALUA EL INDICADOR DE PAGO.
        @param P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE. CODIGO DEL ESTUDIANTE
        @return O = EL ESTUDIANTE NO HA REGISTRADO PAGOS EN EL SEMESTRE ACTUAL.
                1 = EL ESTUDIANTE TIENE PAGO PARA EL TRIMESTRE VIGENTE.
                2 = EL ESTUDIANTE HA REGISTRADO PAGOS PARA EL SEMESTRE ACTUAL, PERO NO PARA EL TRIMESTRE ACTUAL.
        */   
    FUNCTION EVALUAR_PAGO (
        P_INDICADOR B_ESTUDIANTES.INDICADOR_PAGO%TYPE
    ) RETURN NUMBER IS
        -- FECHAS PRIMER SEMESTRE.
        V_FECHA_INICIAL_1        ADMISIONES.A_FECHAS_DE_CORTE.FECHA_INICIO%TYPE;
        V_FECHA_FINAL_1          ADMISIONES.A_FECHAS_DE_CORTE.FECHA_FINALIZACION%TYPE;
        -- FECHAS SEGUNDO SEMESTRE.
        V_FECHA_INICIAL_2        ADMISIONES.A_FECHAS_DE_CORTE.FECHA_INICIO%TYPE;
        V_FECHA_FINAL_2          ADMISIONES.A_FECHAS_DE_CORTE.FECHA_FINALIZACION%TYPE;    
    BEGIN        
        -- OBTENIENDO FECHAS DE PRIMER TRIMESTRE.
        SELECT FECHA_INICIO, 
               FECHA_FINALIZACION
        INTO   V_FECHA_INICIAL_1, 
               V_FECHA_FINAL_1
        FROM   ADMISIONES.A_FECHAS_DE_CORTE
        WHERE  PROCESO = 'INICIO-FIN TRIMESTRE 1 POSGRADO';

        -- OBTENIENDO FECHAS DE SEGUNDO TRIMESTRE.
        SELECT FECHA_INICIO, 
               FECHA_FINALIZACION
        INTO   V_FECHA_INICIAL_2, 
               V_FECHA_FINAL_2
        FROM   ADMISIONES.A_FECHAS_DE_CORTE
        WHERE  PROCESO = 'INICIO-FIN TRIMESTRE 2 POSGRADO';

        -- SI EL ESTUDIANTE TIENE PAGO EL TRIMESTRE ACTUAL (PRIMER SEMESTRE = V, SEGUNDO TRIMESTRE = W), O TIENE PAGO COMPLETO (SEMESTRE COMPLETO = P).
        IF (   (SYSDATE BETWEEN V_FECHA_INICIAL_1 AND V_FECHA_FINAL_1 AND P_INDICADOR = GET_INDICADOR_PAGO(1))
            OR (SYSDATE BETWEEN V_FECHA_INICIAL_2 AND V_FECHA_FINAL_2 AND P_INDICADOR = GET_INDICADOR_PAGO(2))
            OR (P_INDICADOR = GET_INDICADOR_PAGO(0))) THEN
           RETURN 1;
        -- SI EL ESTUDIANTE HA REGISTRADO ALGUN PAGO EN EL SEMESTRE.
        ELSIF (P_INDICADOR IN (GET_INDICADOR_PAGO(1), GET_INDICADOR_PAGO(2))) THEN
            RETURN 2;
        -- SI EL ESTUDIANTE NO REGISTRA NINGUN TIPO DE PAGO PARA EL SEMESTRE ACTUAL.
        ELSE
            RETURN 0;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END EVALUAR_PAGO;

    /*
        OBTIENE VALOR DEL INDICADOR DE PAGO.
        @param P_ID_PERIODO CTI_PERIODO.ID_PERIODO%TYPE. INDICADOR DE PAGO.
        @return VALOR DEL INDICADOR DE PAGO.
        */
    FUNCTION GET_INDICADOR_PAGO(
        P_ID_PERIODO CTI_PERIODO.ID_PERIODO%TYPE
    ) RETURN CTI_PERIODO.INDICADOR_PAGO%TYPE IS
        V_INDICADOR CTI_PERIODO.INDICADOR_PAGO%TYPE;
    BEGIN
        SELECT INDICADOR_PAGO
        INTO   V_INDICADOR
        FROM   CTI_PERIODO
        WHERE  ID_PERIODO = P_ID_PERIODO;

        RETURN V_INDICADOR;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '';
    END GET_INDICADOR_PAGO;   

    function getEstudiante(
        p_codigo b_estudiantes.codigo%type
    ) return json as
        v_est b_estudiantes%rowtype;
        j_est json := json();
        j_per json;
        j_fac json;
        j_plan json;
    begin
        select e.*
        into v_est
        from b_estudiantes e
        where e.codigo = p_codigo;
        json.put(j_est,'codigo',v_est.codigo);
        json.put(j_est,'nombre',v_est.nombre);
        j_per := getTipoMatricula(v_est.codigo);
        if j_per is not null then
            json.put(j_est,'matricula',j_per.to_json_value);
        end if;
        j_fac := getFacultad(v_est.codigo_facultad, v_est.jornada_facultad);
        if j_fac is not null then
            json.put(j_est,'facultad',j_fac.to_json_value);
        end if;
        j_plan := getPlan(v_est.codigo_facultad, v_est.jornada_facultad, v_est.plan_estudio);
        if j_plan is not null then
            json.put(j_est,'plan',j_plan.to_json_value);
        end if;
        return j_est;
    exception
    when others then
        return null;
    end getEstudiante;

    function getTipoMatricula(
        p_codigo b_estudiantes.codigo%type
    ) return json as
        v_anio varchar2(4);
        v_ciclo varchar2(2);
        v_esquema varchar2(32);
        v_per cti_periodo%rowtype;
        j_per json := json();
    begin
        admisiones.pkg_utils.getAnioCicloEsquema('2',v_anio,v_ciclo,v_esquema);
        execute immediate
            'select p.* ' ||
            'from ' || v_esquema || '.b_estudiantes e ' ||
            'inner join ' ||
            'cti_periodo p ' ||
            'on e.indicador_pago = p.indicador_pago ' ||
            'where e.codigo = :codigo ' ||
            'and e.anio = :anio ' ||
            'and e.ciclo = :ciclo'
        into v_per
        using p_codigo, v_anio, v_ciclo;
        json.put(j_per,'id',v_per.id_periodo);
        json.put(j_per,'periodo',v_per.periodo);
        json.put(j_per,'indicador_pago',v_per.indicador_pago);
        return j_per;
    exception
    when others then
        return null;
    end getTipoMatricula;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE LOS PERFILES DE UNA PERSONA A PARTIR DE UN TOKEN ESTRUCTURADO DE LA FORMA (OBTIENE UN TOKEN POR CADA PERFIL).
--      USUARIO || ';' || CLAVE || ';' || CODIGO || ';' || NOMBRE_USUARIO || ';' || NUMERO_DOCUMENTO
-- ****************************************************************************************************************************

    PROCEDURE GETPERFILES (
        TOKEN VARCHAR2
    ) AS
        V_DOCUMENTO        VARCHAR2 (64);
        V_CODIGO_PERFIL    VARCHAR2 (16);
        V_LABEL            VARCHAR2 (512);
        V_LABEL2           VARCHAR2 (512);
        V_CODIGO_FACULTAD  VARCHAR2 (512);
        V_TOKEN            VARCHAR2 (512);
        V_TOKEN_SIA        VARCHAR2 (512);
        V_RESPUESTA        JSON := JSON ();
        V_LIST             JSON_LIST := JSON_LIST ();
        V_PERFIL           JSON;
        CURSOR C_LISTADO_PERFILES (
            P_DOCUMENTO VARCHAR2
        ) IS
            SELECT -- SI EL PERFIL ES ESTUDIANTE O UNIDAD ACADEMICA DE POSTGRADO.
                   CASE
                       WHEN (ID_PERFIL IN ('7', '3', '4') AND TIPO_PERFIL IN ('002', '003', '004'))
                            THEN ADMISIONES.PKG_UTILS.F_CREARTOKEN (USUARIO || ';' || CLAVE || ';' || CODIGO || ';' || NOMBRE_USUARIO || ';' || NUMERO_DOCUMENTO, '3764613438353137') 
                       ELSE '' 
                   END AS TOKEN,
                   -- SI NO ES PARTE DEL GRUPO ANTERIOR SE ENVIA TOKEN DEL PORTAL SIA PARA REDIRIGIRLO.
                   CASE
                       WHEN NOT (ID_PERFIL IN ('7', '3', '4') AND TIPO_PERFIL IN ('002', '003', '004'))
                            THEN ADMISIONES.PKG_UTILS.F_CREARTOKEN (USUARIO || ';' || CLAVE, '3764613438353137') 
                       ELSE '' 
                   END AS TOKEN_SIA,
                   ID_PERFIL,
                   ETIQUETA || nvl(' ' || etiqueta2, ''),
                   etiqueta2,
                   --codigo,
                   NVL(CODIGO_FACULTAD, '') CODIGO_FACULTAD
            FROM   (SELECT    P.ID_PERFIL,
                              U.USUARIO,
                              U.CLAVE,
                              u.codigo,
                              P.ETIQUETA, 
                              CASE
                                   WHEN P.ID_PERFIL = 7 THEN U.CODIGO
                                   WHEN P.ID_PERFIL BETWEEN 1 AND 4 THEN PR.NOMBRE 
                                   ELSE NULL
                               END AS etiqueta2,
                               CASE
                                   WHEN P.ID_PERFIL BETWEEN 1 AND 4 THEN PR.CODIGO
                                   ELSE NULL
                               END AS CODIGO_FACULTAD,
                               NOMBRE_USUARIO,
                               NUMERO_DOCUMENTO,
                               -- OBTENER TIPO DEL PROGRAMA PARA ESTUDIANTES Y UNIDAD ACADEMICA (PREGRADO, ESPECIALIZACION, MAESTRIA O DOCORADO)
                               CASE
                                    WHEN (P.ID_PERFIL = 7) THEN (SELECT     P.CODIGO_TIPO
                                                                 FROM       ADMISIONES.B_ESTUDIANTES E
                                                                 INNER JOIN ADMISIONES.A_PROGRAMAS P ON     E.CODIGO_FACULTAD  = P.CODIGO
                                                                                                        AND E.JORNADA_FACULTAD = P.JORNADA
                                                                 WHERE      E.CODIGO = U.CODIGO
                                                                 UNION
                                                                 SELECT     P.CODIGO_TIPO
                                                                 FROM       POSTGRADO.B_ESTUDIANTES E
                                                                 INNER JOIN ADMISIONES.A_PROGRAMAS P ON     E.CODIGO_FACULTAD  = P.CODIGO
                                                                                                        AND E.JORNADA_FACULTAD = P.JORNADA
                                                                 WHERE      E.CODIGO = U.CODIGO)
                                    WHEN (P.ID_PERFIL BETWEEN 1 AND 4) THEN PR.CODIGO_TIPO
                                    ELSE NULL
                               END TIPO_PERFIL
                    FROM       ADMISIONES.A_USUARIOS U
                    INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                            OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
                    LEFT JOIN (SELECT      FU.NOMBRE, 
                                           FU.CODIGO_FACULTAD CODIGO,
                                           MAX(P1.CODIGO_TIPO) CODIGO_TIPO
                               FROM        ADMISIONES.A_PROGRAMAS P1
                               INNER JOIN  ADMISIONES.A_FACULTADES_UNICA FU ON P1.CODIGO = FU.CODIGO_FACULTAD
                               GROUP BY    FU.NOMBRE,
                                           FU.CODIGO_FACULTAD
                               UNION
                               SELECT      FU.NOMBRE, 
                                           FU.CODIGO_FACULTAD,
                                           MAX(P1.CODIGO_TIPO)
                               FROM        ADMISIONES.A_PROGRAMAS P1
                               INNER JOIN  ADMISIONES.A_FACULTADES_UNICA FU ON P1.CODIGO = FU.CODIGO_FACULTAD
                               GROUP BY    FU.NOMBRE,
                                           FU.CODIGO_FACULTAD) PR ON     PR.CODIGO = SUBSTR (U.CODIGO, 2, 2)
                                                                     AND P.ID_PERFIL BETWEEN 1 AND 4
                    WHERE          NOT REGEXP_LIKE (U.USUARIO, '^(ZR).{2}$') 
                               AND U.NUMERO_DOCUMENTO = P_DOCUMENTO 
                               AND NOT REGEXP_LIKE (U.CODIGO, '^(&)+$')
                    ORDER BY   2, 3) A
            ORDER BY 4;
    BEGIN
        OWA_UTIL.MIME_HEADER ('application/json', FALSE, 'utf-8');
        OWA_UTIL.HTTP_HEADER_CLOSE;
        V_DOCUMENTO := ADMISIONES.PKG_UTILS.F_LEERTOKEN (TOKEN, 1 / 24, '3764613438353137');
                       --TOKEN
                       --'79651298';
        OPEN C_LISTADO_PERFILES (upper(V_DOCUMENTO));
        LOOP
            FETCH C_LISTADO_PERFILES INTO V_TOKEN,
                                          V_TOKEN_SIA,  
                                          V_CODIGO_PERFIL,
                                          V_LABEL, 
                                          V_LABEL2,
                                          V_CODIGO_FACULTAD;
            EXIT WHEN C_LISTADO_PERFILES%NOTFOUND;
            V_PERFIL := JSON ();
            JSON.PUT (V_PERFIL, 'token', V_TOKEN);
            JSON.PUT (V_PERFIL, 'tokenSia', V_TOKEN_SIA);
            JSON.PUT (V_PERFIL, 'codigoPerfil', V_CODIGO_PERFIL);
            JSON.PUT (V_PERFIL, 'etiqueta', V_LABEL);
            JSON.PUT (V_PERFIL, 'etiqueta2', V_LABEL2);
            JSON.PUT (V_PERFIL, 'codigoFacultad', V_CODIGO_FACULTAD);
            JSON_LIST.APPEND (V_LIST, V_PERFIL.TO_JSON_VALUE);
        END LOOP;
        CLOSE C_LISTADO_PERFILES;
        JSON_LIST.HTP (V_LIST, FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                CLOSE C_LISTADO_PERFILES;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            JSON.PUT (V_RESPUESTA, 'status', 'fail');
            JSON.PUT (V_RESPUESTA, 'mensaje', SQLERRM);
            JSON.HTP (V_RESPUESTA, FALSE);
    END GETPERFILES;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE EL MENU PARA LA NUEVA INTERFAZ DE POSGRADOS DE ACUERDO AL TOKEN DE PERFIL GENERADO EN GETPERFILES().
-- ****************************************************************************************************************************

    PROCEDURE GETMENU (
        TOKEN VARCHAR2
    ) IS
        V_RESPUESTA     JSON_LIST := JSON_LIST ();
        V_ERROR         JSON      := JSON ();
        V_DECODED_TOKEN VARCHAR2(200);
        V_ID_PERFIL     VARCHAR2(32);
        V_USUARIO       VARCHAR2(32);
        V_CODIGO        VARCHAR2(8);
        V_CLAVE         VARCHAR2(32);
    BEGIN
        -- DECIFRADO Y OBTENCION DE DATOS A PARTIR DEL TOKEN.
        V_DECODED_TOKEN := ADMISIONES.PKG_UTILS.F_LEERTOKEN (TOKEN, 1 / 24, '3764613438353137');
        V_USUARIO := REGEXP_SUBSTR (V_DECODED_TOKEN, '[^;]+', 1,1);
        V_CLAVE := REGEXP_SUBSTR (V_DECODED_TOKEN, '[^;]+',1,2);        
        -- OBTENCION DE PERFIL.
        SELECT     P.ID_PERFIL,
                   U.CODIGO
        INTO       V_ID_PERFIL,
                   V_CODIGO 
        FROM       ADMISIONES.A_USUARIOS U
        INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
        WHERE          U.USUARIO = V_USUARIO
                   AND U.CLAVE   = V_CLAVE;
        -- OBTENCION DE ITEMS POR PERFIL
        FOR MENUITEM IN (SELECT ID_PROCESO
                         FROM   ADMISIONES.CTI_MENU
                         WHERE  ID_PERFIL = V_ID_PERFIL) LOOP
            JSON_LIST.APPEND (V_RESPUESTA, GETMENUITEM(MENUITEM.ID_PROCESO, V_CODIGO).TO_JSON_VALUE);
        END LOOP;
        JSON_LIST.HTP (V_RESPUESTA, FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_ERROR, 'status', 'fail');
            JSON.PUT (V_ERROR, 'mensaje', SQLERRM);
            JSON.HTP (V_ERROR, FALSE);
    END;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE UN ELEMENTO DEL MENU CON SUS RESPECTIVOS NODOS HIJO.
-- ****************************************************************************************************************************

    FUNCTION GETMENUITEM (
        P_ID_PROCESO NUMBER,
        P_CODIGO VARCHAR2
    ) RETURN JSON IS
        V_RESPUESTA         JSON      := JSON ();
        V_ERROR             JSON      := JSON ();
        V_PARAMETRO         JSON;
        V_PARAMETROS        JSON_LIST := JSON_LIST ();
        V_NODOS_HIJOS       JSON_LIST := JSON_LIST ();
        V_LABEL             VARCHAR2(256);
        V_EJECUCION         VARCHAR2(256);
        V_PRE_EJECUCION     VARCHAR2(256);
        V_ID_TIPO_EJECUCION VARCHAR2(512);
        V_TIPO_EJECUCION    VARCHAR2(64);
        V_HABILITADO        NUMBER DEFAULT '0';
        V_HABILITADO_EJECUC NUMBER;
    BEGIN
        -- NODO ACTUAL.
        SELECT     P.PROCESO,
                   P.EJECUCION,
                   TE.ID_TIPO_EJECUCION,
                   TE.TIPO_EJECUCION,
                   HABILITADO,
                   PRE_EJECUCION
        INTO       V_LABEL,
                   V_EJECUCION,
                   V_ID_TIPO_EJECUCION,
                   V_TIPO_EJECUCION,
                   V_HABILITADO,
                   V_PRE_EJECUCION
        FROM       ADMISIONES.CTI_PROCESOS P 
        INNER JOIN ADMISIONES.CTI_TIPO_EJECUCION TE ON TE.ID_TIPO_EJECUCION = P.ID_TIPO_EJECUCION
        WHERE      P.ID_PROCESO = P_ID_PROCESO;     
        JSON.PUT (V_RESPUESTA, 'label', V_LABEL);      
        JSON.PUT (V_RESPUESTA, 'urlRef', V_EJECUCION);     
        JSON.PUT (V_RESPUESTA, 'typeId', V_ID_TIPO_EJECUCION); 
        JSON.PUT (V_RESPUESTA, 'type', V_TIPO_EJECUCION); 
        
        IF(V_PRE_EJECUCION IS NOT NULL) THEN
            EXECUTE IMMEDIATE 'select ' || V_PRE_EJECUCION || '(:p_codigo) from dual'
            INTO V_HABILITADO_EJECUC
            USING P_CODIGO;
        END IF;
        
        IF (V_HABILITADO = 1 AND (V_PRE_EJECUCION IS NULL OR (V_PRE_EJECUCION IS NOT NULL AND V_HABILITADO_EJECUC = '1'))) THEN
            JSON.PUT (V_RESPUESTA, 'enabled', TRUE);
        ELSE
            JSON.PUT (V_RESPUESTA, 'enabled', FALSE);
        END IF;           
        
        -- PARAMETROS.
        FOR PARAMETRO IN (SELECT ID_PARAMETRO,                              
                                 LABEL,
                                 IDENTIFIER  
                          FROM   ADMISIONES.CTI_PARAMETRO_PROCESO
                          WHERE  ID_PROCESO = P_ID_PROCESO) LOOP
            V_PARAMETRO := JSON();
            JSON.PUT (V_PARAMETRO, 'idParametro', PARAMETRO.ID_PARAMETRO); 
            JSON.PUT (V_PARAMETRO, 'label', PARAMETRO.LABEL); 
            JSON.PUT (V_PARAMETRO, 'identifier', PARAMETRO.IDENTIFIER); 
            JSON_LIST.APPEND (V_PARAMETROS, V_PARAMETRO.TO_JSON_VALUE);
        END LOOP;
        JSON.PUT (V_RESPUESTA, 'params', V_PARAMETROS);
        -- NODOS HIJOS.
        FOR MENUITEM IN (SELECT ID_PROCESO
                         FROM   ADMISIONES.CTI_PROCESOS
                         WHERE  ID_PROCESO_PADRE = P_ID_PROCESO) LOOP
            JSON_LIST.APPEND (V_NODOS_HIJOS, GETMENUITEM(MENUITEM.ID_PROCESO, P_CODIGO).TO_JSON_VALUE);
        END LOOP;
        JSON.PUT (V_RESPUESTA, 'items', V_NODOS_HIJOS);
        RETURN V_RESPUESTA;
    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_ERROR, 'status', 'fail');
            JSON.PUT (V_ERROR, 'mensaje', SQLERRM);
            JSON.HTP (V_ERROR, FALSE);
    END;    

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE EL CODIGO DEL ESTUDIANTE A PARTIR DEL TOKEN.
-- ****************************************************************************************************************************

    PROCEDURE GET_CODIGO_ESTUDIANTE (
        TOKEN VARCHAR2
    ) IS                        
        V_MENSAJE           JSON := JSON ();
        V_ERROR             JSON := JSON ();  
        V_DECODED_TOKEN VARCHAR2(200);                                                          
        V_USUARIO           VARCHAR2 (200);
        V_CLAVE             VARCHAR2 (200);
        V_CODIGO_ESTUDIANTE VARCHAR2 (8);
    BEGIN
        PKG_HTML.CORSHEADERS();
        V_MENSAJE := JSON();
        -- DECIFRADO Y OBTENCION DE DATOS A PARTIR DEL TOKEN.
        V_DECODED_TOKEN := ADMISIONES.PKG_UTILS.F_LEERTOKEN (TOKEN, 1 / 24, '3764613438353137');
        V_USUARIO := REGEXP_SUBSTR (V_DECODED_TOKEN, '[^;]+', 1,1);
        V_CLAVE := REGEXP_SUBSTR (V_DECODED_TOKEN, '[^;]+',1,2);   
        SELECT     U.CODIGO
        INTO       V_CODIGO_ESTUDIANTE
        FROM       ADMISIONES.A_USUARIOS U
        INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
        WHERE          U.USUARIO = V_USUARIO
                   AND U.CLAVE = V_CLAVE
                   AND P.ID_PERFIL = 7 ;
        JSON.PUT (V_MENSAJE, 'status', 'ok');
        JSON.PUT (V_MENSAJE, 'mensaje', V_CODIGO_ESTUDIANTE);
        JSON.HTP (V_MENSAJE);
    EXCEPTION
        WHEN OTHERS THEN
            V_ERROR := JSON();
            JSON.PUT (V_ERROR, 'status', 'fail');
            JSON.PUT (V_ERROR, 'mensaje', SQLERRM);
            JSON.HTP (V_ERROR);
    END GET_CODIGO_ESTUDIANTE;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
--
-- **************************************************************************************************************************** 

    PROCEDURE GET_PORTAL_INFO IS
        V_BODY        JSON := JSON ();
        V_PROPERTIES  JSON_LIST := JSON_LIST();
        V_PROPERTY    JSON;
        V_ERROR       JSON := JSON ();  
        -- PARAMETROS DE LA COOKIE.                                                                                       
        V_USUARIO     VARCHAR2 (200);
        V_CLAVE       VARCHAR2 (200);
        V_DOCUMENTO   VARCHAR2 (200);
        V_CODIGO      VARCHAR2 (200);
        V_NOMBRE      VARCHAR2 (200);
        V_PERFIL_ID   NUMBER;
        V_AUXILIAR    VARCHAR2(200);
        v_cookie owa_cookie.cookie;
    BEGIN
        PKG_HTML.CORSHEADERS();
        /*begin
            v_cookie := owa_cookie.get('wUFAnew4');
            htp.prn(v_cookie.vals(1) || 'asd');
        exception when others then
            htp.prn('error en la cookie');
        end;*/
        -- VARIABLES ALMACENADAS EN LA COOKIE.
        ADMISIONES.PKG_UTILS.P_LEER_COOKIE(V_USUARIO, V_CLAVE, V_DOCUMENTO, V_CODIGO, V_NOMBRE);
        JSON.PUT(V_BODY, 'nombre', V_NOMBRE);

        SELECT     ID_PERFIL
        INTO       V_PERFIL_ID
        FROM       ADMISIONES.A_USUARIOS U
        INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
        WHERE          U.USUARIO = V_USUARIO
                   AND U.CLAVE = V_CLAVE;

        -- UNIDAD ACADEMICA.
        IF (V_PERFIL_ID BETWEEN 1 AND 4) THEN
            -- PROPIEDAD 1.
            V_PROPERTY := JSON();            
            SELECT     ETIQUETA
            INTO       V_AUXILIAR
            FROM       ADMISIONES.A_USUARIOS U
            INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                    OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
            WHERE          U.USUARIO = V_USUARIO
                       AND U.CLAVE = V_CLAVE;                       
            JSON.PUT(V_PROPERTY, 'key', 'Cargo');
            JSON.PUT(V_PROPERTY, 'value', V_AUXILIAR);
            JSON_LIST.APPEND(V_PROPERTIES, V_PROPERTY.TO_JSON_VALUE);
            -- PROPIEDAD 2.
            V_PROPERTY := JSON();            
            SELECT     PR.NOMBRE
            INTO       V_AUXILIAR
            FROM       ADMISIONES.A_USUARIOS U
            INNER JOIN ADMISIONES.CTI_PERFILES P ON    P.COD_PERFIL = U.CODIGO 
                                                    OR REGEXP_LIKE (U.CODIGO, P.REGEXP)
            INNER JOIN ADMISIONES.A_PROGRAMAS PR ON  --  PR.FACULTAD = SUBSTR (U.CODIGO, 2, 2) OR 
                                                    PR.CODIGO   = SUBSTR (U.CODIGO, 2, 2)
            WHERE          U.USUARIO = V_USUARIO
                       AND U.CLAVE   = V_CLAVE;                       
            JSON.PUT(V_PROPERTY, 'key', 'Programa');
            JSON.PUT(V_PROPERTY, 'value', V_AUXILIAR);
            JSON_LIST.APPEND(V_PROPERTIES, V_PROPERTY.TO_JSON_VALUE);           

        END IF;

        JSON.PUT(V_BODY, 'propiedades', V_PROPERTIES);
        JSON.HTP(V_BODY);
    EXCEPTION
        WHEN OTHERS THEN
            JSON.PUT (V_ERROR, 'status', 'fail');
            JSON.PUT (V_ERROR, 'mensaje', SQLERRM);
            JSON.HTP (V_ERROR);
    END GET_PORTAL_INFO;

    function toChar(
        p_date date
    ) return varchar2
    is
    begin
        return to_char(p_date, 'RRRR/MM/DD HH24:MI:SS');
    end;

end pkg_utils;