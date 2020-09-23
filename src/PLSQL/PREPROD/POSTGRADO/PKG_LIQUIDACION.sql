create or replace package body pkg_liquidacion as

    --FIXME: Agregar restricciones de liquidación de guías.
    /*
    @param r_param admisiones.a_parametros%rowtype
    @return json
    */
    function parametroToJSON(
        r_param admisiones.a_parametros%rowtype
    ) return json as
        j_param json := json();
    begin
        json.put(j_param, 'anio', r_param.anio);
        json.put(j_param, 'anioIngreso', r_param.anio_ingreso);
        json.put(j_param, 'anioreintegro', r_param.ciclo_de_ingreso);
        json.put(j_param, 'aplicaIndicador', r_param.aplicar_concepto);
        json.put(j_param, 'cobrarRecargo', r_param.recargo);
        json.put(j_param, 'cod2DoPrograma', r_param.codseg_pgm);
        json.put(j_param, 'codigo', r_param.codest);
        json.put(j_param, 'correoElectronico', r_param.email);
        json.put(j_param, 'creditosInscritos', r_param.tot_creditos);
        json.put(j_param, 'creditosSemestre', r_param.totcred_sem);
        json.put(j_param, 'credsInscritos2DoProg', r_param.credinsseg_pgm);
        json.put(j_param, 'credsSemestre2DoProg', r_param.credsemseg_pgm);
        json.put(j_param, 'departamento', to_number(r_param.coddepto));
        json.put(j_param, 'direccion', r_param.direccion);
        json.put(j_param, 'fechaAjuste', to_char(r_param.fecha_ajuste, 'RRRR/MM/DD'));
        json.put(j_param, 'fechaNacimiento', r_param.fecnac);
        json.put(j_param, 'genero', r_param.genero);
        json.put(j_param, 'guiaAcademica', r_param.numguia);
        json.put(j_param, 'identificacion', r_param.numero_documento);
        json.put(j_param, 'jornada', r_param.jornada);
        json.put(j_param, 'nombre2DoPrograma', r_param.nomseg_pgm);
        json.put(j_param, 'nombrePrograma', r_param.nomfac);
        json.put(j_param, 'pais', to_number(r_param.codpais));
        json.put(j_param, 'periodo', r_param.ciclo);
        json.put(j_param, 'poblacion', to_number(r_param.codmuni));
        json.put(j_param, 'porcentajeRecargo', r_param.porcrecargo);
        json.put(j_param, 'primerApellido', r_param.primer_apelllido);
        json.put(j_param, 'primerNombre', r_param.primer_nombre);
        json.put(j_param, 'primerSemestre', r_param.primer_semestre);
        json.put(j_param, 'programa', r_param.codfac);
        json.put(j_param, 'segundoApellido', r_param.segundo_apellido);
        json.put(j_param, 'segundoNombre', r_param.segundo_nombre);
        json.put(j_param, 'semestre', r_param.seminf);
        json.put(j_param, 'telefono', r_param.telefono);
        json.put(j_param, 'tipoIdentificacion', r_param.tipo_documento);
        json.put(j_param, 'tipoMatricula', r_param.codtran);
        json.put(j_param, 'tipoPrograma', r_param.tipo_programa);
        json.put(j_param, 'totalCreditos', nvl(r_param.totcredfac,0));
        json.put(j_param, 'totalSemestres', to_number(r_param.numsem));
        json.put(j_param, 'cobrarcreditosadicionales', 0);
        json.put(j_param, 'creditosadescontar', 0);
        return j_param;
    end parametroToJSON;

    procedure validarLiquidacion(
        p_codigo b_estudiantes.codigo%type,
        p_id_periodo cti_periodo.id_periodo%type
    ) as
        n_id_periodo cti_periodo.id_periodo%type;
        v_indicador_pago b_estudiantes.indicador_pago%type;
        n_periodo_act cti_periodo.id_periodo%type;
    begin
        n_periodo_act := trimestreActual();
        select p.id_periodo, e.indicador_pago
        into n_id_periodo, v_indicador_pago
        from b_estudiantes e
        left join cti_periodo p
        on e.indicador_pago = p.indicador_pago
        where e.codigo = p_codigo;
        if n_periodo_act = 1 and v_indicador_pago = 'X' and p_id_periodo = 2 then
            raise_application_error(-20101, 'Debe liquidar el primer trimestre antes que el segundo.');
        elsif n_periodo_act = 2 and v_indicador_pago = 'X' and p_id_periodo = 1 then
            raise_application_error(-20101, 'Debe liquidar el segundo trimestre.');
        elsif n_id_periodo = 0 and p_id_periodo != 0 then
            raise_application_error(-20102, 'El estudiante tiene el semestre completo ya pago, no requiere liquidar.');
        elsif n_id_periodo in (1, 2) and p_id_periodo = 0 then
            raise_application_error(-20103, 'El estudiante tiene un trimertre ya pago. No puede liquidar el semestre completo.');
        elsif n_id_periodo = 2 and p_id_periodo = 1 then
            raise_application_error(-20104, 'El estudiante tiene el segundo trimertre pago. No puede liquidar el primer trimestre.');
        end if;
    exception
    when no_data_found then
        null;
    end validarLiquidacion;

    procedure liquidar(
        p_codigo b_estudiantes.codigo%type,
        p_periodo cti_periodo.id_periodo%type,
        p_creditos_add admisiones.g_guias_de_pago.total_cred_adicionales%type default 0,
        p_semestre cti_creditos_periodo.semestre%type default 1
    ) as
        n_aspirante number;
        r_parametro admisiones.a_parametros%rowtype;
        v_respuesta json := json();
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        select count(*)
        into n_aspirante
        from a_aspirantes a
        left join b_estudiantes e
        on a.cod_def = e.codigo
        where e.codigo is null
        and a.cod_def = p_codigo;
        if n_aspirante > 0 then
            liquidar_aspirante(p_codigo, p_periodo, p_creditos_add, p_semestre, r_parametro);
        else
            validarLiquidacion(p_codigo, p_periodo);
            liquidar_estudiante(p_codigo, p_periodo, p_creditos_add, p_semestre, r_parametro);
        end if;
        json.htp(parametroToJSON(r_parametro),false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end liquidar;

    procedure liquidar_aspirante(
        p_codigo in a_aspirantes.cod_def%type,
        p_periodo in cti_periodo.id_periodo%type,
        p_creditos_add in admisiones.g_guias_de_pago.total_cred_adicionales%type,
        p_semestre in cti_creditos_periodo.semestre%type,
        o_parametro out admisiones.a_parametros%rowtype
    ) as
        cod_tx admisiones.g_guias_de_pago.cod_transac%type;
        n_creditos cti_creditos_periodo.creditos%type;
        n_guia admisiones.g_guias_de_pago.codigo_guia%type;
        n_id_parametro admisiones.a_parametros.id%type;
        v_prg admisiones.a_programas.codigo%type;
        v_jrn admisiones.a_programas.jornada%type;
        v_plan a_planes_de_estudio.plan_estudio%type;
        n_creditos_prg number;
        n_semestres_prg number;
        n_egresado number;
        v_descuento admisiones.g_guias_de_pago.cod_transac%type;
    begin
        if p_creditos_add > 0 then
            raise_application_error(-20100,'Solo puede solicitar creditos adicionales cuando ha matriculado el semestre completo.');
        end if;
        --Se consulta el codigo de transaccion que corresponde segun seleccion.
        if p_periodo = 0 then
            begin
                --El estudiante es nuevo si o si
                select trim(to_char(tx.cod_transaccion, '00'))
                into cod_tx
                from cti_grupo_est_tx tx
                where tx.id_grupo_estudiante = 4; -- 4: Neolasallistas
                v_descuento := trim(to_char(GET_DESCUENTO(p_codigo, p_periodo), '00'));
                if v_descuento is not null then
                    cod_tx := v_descuento;
                end if;
            exception
            when no_data_found then
                raise_application_error(-20100,'Tipo de estudiante no registrado');
            end;
        else
            begin
                select trim(to_char(tx.cod_transaccion, '00'))
                into cod_tx
                from cti_periodo tx
                where tx.id_periodo = p_periodo;
            exception
            when no_data_found then
                raise_application_error(-20100,'Periodo no registrado');
            end;
        end if;

        select a.codigo_facultad, a.jornada_facultad, to_char(max(to_number(pe.plan_estudio)))
        into v_prg, v_jrn, v_plan
        from a_planes_de_estudio pe
        inner join
        a_aspirantes a
        on pe.codigo_facultad = a.codigo_facultad and pe.jornada_facultad = a.jornada_facultad
        where a.cod_def = p_codigo
        group by a.codigo_facultad, a.jornada_facultad;
        pkg_pensum.getResumenPensum(v_prg, v_jrn, v_plan, n_semestres_prg, n_creditos_prg);

        --Se consulta el numero de creditos segun el periodo seleccionado
        begin
            select cr.creditos
            into n_creditos
            from a_aspirantes a
            inner join cti_creditos_periodo cr
            on a.codigo_facultad = cr.codigo_facultad and a.jornada_facultad = cr.jornada_facultad
            where
            a.cod_def = p_codigo
            and cr.plan_estudio = v_plan
            and cr.periodo = p_periodo
            and cr.semestre = p_semestre;
        exception
        when no_data_found then
            raise_application_error(-20100,'No se han parametrizado los creditos por periodo: ' || substr(p_codigo, 0, 2));
        end;
        --Si ya tiene una guia activa con el mismo codigo de tx para el periodo actual, lo retorna
         BEGIN
            SELECT PR.*
            into o_parametro
            from admisiones.a_parametros pr
            inner join admisiones.g_guias_de_pago pg
            on pr.numguia = pg.codigo_guia
            inner join a_aspirantes a
            on pg.codigo_est = a.cod_def and a.anio = pg.anio and a.ciclo = pg.ciclo
            where pg.codigo_est = p_codigo
            and pg.activa = 1
            and pg.cod_transac = cod_tx
            and pg.total_creditos_ins = n_creditos;
            return;
        exception
        when no_data_found then
            null;
        when too_many_rows then
            raise_application_error(-20100,'Tiene mas de una guia activa.');
        end;
        /*--mariano rua mejia 13/01/2020 02:54 pm
        IF P_PERIODO IN (1,2) THEN
           IF PKG_DESCUENTOS.ES_EGRESADO_NUEVO(P_CODIGO) = 1 THEN  --EGRESEADO NUEVO TRIMESTRAL
            COD_TX := '81';
           END IF;
        END IF;*/
        begin
            --Desactiva todas las guias no pagas activas del periodo
            update admisiones.g_guias_de_pago p
            set p.activa = 0
            where p.codigo_est = p_codigo
            and p.indicador_pago not in (select pp.indicador_pago from cti_periodo pp)
            and p.activa = 1
            and exists (select 1 from a_aspirantes a where a.cod_def = p.codigo_est and a.anio = p.anio and a.ciclo = p.ciclo);
            --Se inserta guia nueva.
            n_guia := admisiones.seq_num_guia_pago.nextval;
            insert into admisiones.g_guias_de_pago
            select
                a.cod_def codigo_est,
                sysdate fecha_gen,
                0 val_sem,
                0 total_intensidad_hor,
                a.ciclo,
                0 recargos,
                0 auxilio_beca,
                0 icetex,
                0 formulario_inscripcion,
                0 creditos_adicionales,
                1 activa,
                null deuda_documentos,
                p.codigo facultad,
                '00000' materia_plan,
                p.codigo materia_facultad_cursar,
                '00000' materia_cursar,
                '00' materia_grupo,
                n_guia codigo_guia, --> secuencia
                '01' tipo_guia,
                a.anio,
                '00' digito_chequeo,
                0 val_pagado,
                'S' chack_impresion,
                sysdate fecha_ord,
                null fecha_extra1,
                null fecha_extra2,
                a.jornada_facultad jornada_fac_est,
                cod_tx cod_transac, --> param
                n_creditos total_creditos_ins, --> param
                0 total_cred_adicionales,
                0 val_pagado_ext1,
                0 val_pagado_ext2,
                a.nombre nomest,
                0 val_seguro,
                'ESTUDIANTE' tipoest,
                substr(p.nombre,0,50) nomfac,
                v_plan plan,
                0 porcentaje_auxilio,
                '.' banco,
                '.' mensaje_info1,
                '.' mensaje_info2,
                '.' mensaje_info3,
                null mensaje_nuevos,
                null mensaje_servicio_medico,
                'X' indicador_pago,
                0 val_otros_descuentos,
                0 pago_parcial,
                0 val_inscripcion,
                null fecha_pago,
                td.codigo codtipo_documento,
                td.tipo tipo_documento,
                td.valor nombre_documento,
                a.numdoc numero_documento
            from admisiones.a_programas p
            inner join a_aspirantes a
            on p.codigo = a.codigo_facultad and p.jornada = a.jornada_facultad
            inner join admisiones.a_tipo_documento td
            on a.tipdoc = td.tipo
            where a.cod_def = p_codigo;
            --Se agrega parametro de liquidacion nuevo
            n_id_parametro := admisiones.seq_a_parametros.nextval;
            select
                a.anio,
                a.ciclo,
                p.codigo codfac,
                substr(p.nombre,0,50) nomfac,
                (case p.codigo_tipo when '001' then 'P' else 'S' end) tipo_programa,
                a.tipdoc tipo_documento,
                a.numdoc numero_documento,
                a.cod_def codest,
                a.primer_apellido,
                a.segundo_apellido,
                a.primer_nombre,
                a.segundo_nombre,
                to_char(a.fecha_nacimiento, 'RRRR/MM/DD') fecnac,
                '57' codpais,
                a.coddepto_nacimiento coddepto,
                a.codmuni_nacimiento codmuni,
                a.direccion,
                a.telefono_casa telefono,
                a.sexo genero,
                a.email email,
                a.anio anio_ingreso,
                '0' seminf,
                cod_tx codtran,
                n_creditos totcred_sem,
                n_creditos tot_creditos,
                n_semestres_prg numsem,
                n_creditos_prg totcredfac,
                'S' primer_semestre,
                'N' recargo,
                0 porcrecargo,
                n_guia numguia, --> secuencia
                'N' aplicar_concepto,
                p.jornada,
                null codseg_pgm,
                null nomseg_pgm,
                null credinsseg_pgm,
                null credsemseg_pgm,
                a.anio || to_number(a.ciclo) ciclo_de_ingreso,
                sysdate fecha,
                a.fecha_pago fecha_ajuste,
                a.cod_def cod_def,
                n_id_parametro id --> secuencia
            into o_parametro
            from
                admisiones.a_programas p
                    inner join
                cti_creditos_periodo cp
                    on p.codigo = cp.codigo_facultad and p.jornada = cp.jornada_facultad
                    inner join
                a_aspirantes a
                    on p.codigo = a.codigo_facultad and p.jornada = a.jornada_facultad
                    inner join
                admisiones.a_tipo_documento td
                    on a.tipdoc = td.tipo
            where
                a.cod_def = p_codigo
                and cp.plan_estudio = v_plan
                and cp.periodo = p_periodo
                and cp.semestre = p_semestre;
            INSERT INTO ADMISIONES.A_PARAMETROS VALUES O_PARAMETRO;      
            commit;
        exception
        when no_data_found then
            rollback;
            raise_application_error(-20100,'No se han encontrado datos para la liquidacion de: ' || p_codigo);
        when others then
            rollback;
            raise_application_error(-20100,'No se logro realizar la liquidacion de ' || p_codigo || ': ' || sqlerrm);
        end;
    end liquidar_aspirante;

    PROCEDURE LIQUIDAR_ESTUDIANTE(
        P_CODIGO IN B_ESTUDIANTES.CODIGO%TYPE,
        P_PERIODO IN CTI_PERIODO.ID_PERIODO%TYPE,
        P_CREDITOS_ADD IN ADMISIONES.G_GUIAS_DE_PAGO.TOTAL_CRED_ADICIONALES%TYPE,
        P_SEMESTRE IN CTI_CREDITOS_PERIODO.SEMESTRE%TYPE,
        O_PARAMETRO OUT ADMISIONES.A_PARAMETROS%ROWTYPE
    ) AS
        COD_TX           ADMISIONES.G_GUIAS_DE_PAGO.COD_TRANSAC%TYPE;
        N_CREDITOS       CTI_CREDITOS_PERIODO.CREDITOS%TYPE;
        N_GUIA           ADMISIONES.G_GUIAS_DE_PAGO.CODIGO_GUIA%TYPE;
        N_ID_PARAMETRO   ADMISIONES.A_PARAMETROS.ID%TYPE;
        V_PRG            ADMISIONES.A_PROGRAMAS.CODIGO%TYPE;
        V_JRN            ADMISIONES.A_PROGRAMAS.JORNADA%TYPE;
        V_PLAN           A_PLANES_DE_ESTUDIO.PLAN_ESTUDIO%TYPE;
        N_CREDITOS_PRG   NUMBER;
        N_SEMESTRES_PRG  NUMBER;
        V_INDICADOR_PAGO B_ESTUDIANTES.INDICADOR_PAGO%TYPE;
        V_DESCUENTO      ADMISIONES.G_GUIAS_DE_PAGO.COD_TRANSAC%TYPE;
    BEGIN
        --mariano rua mejia 09/01/2020 --matriculados
        IF PUEDEEMITIRGUIADEPAGO(P_CODIGO) = -6 THEN
            RAISE_APPLICATION_ERROR(-20109,'Estudiante con pago registrado en el sistema académico.');
        ELSIF PUEDEEMITIRGUIADEPAGO(P_CODIGO) = -4 THEN
            RAISE_APPLICATION_ERROR(-20109,'Estudiante no tiene materias pendientes.');
        ELSIF PUEDEEMITIRGUIADEPAGO(P_CODIGO) <= 0 THEN
            RAISE_APPLICATION_ERROR(-20109,'No puede liquidar la guia.');
        END IF;
                
        -- OBTENIENDO EL CODIGO DE TRANSACCION DEPENDIENDO SI ES SEMESTRAL (P_PERIODO = 0) O TRIMESTRAL (P_PERIODO = 1, 2).
        IF P_PERIODO = 0 THEN
            BEGIN
                -- SI EL ESTUDIANTE ES REINTEGRO O INGRESO EN EL SEMESTRE ACTUAL SE LE ASIGNA 
                -- EL CODIGO DE TRANSACCION CORRESPONDIENTE.
                SELECT     TRIM(TO_CHAR(TX.COD_TRANSACCION, '00'))
                INTO       COD_TX
                FROM       CTI_GRUPO_EST_TX TX
                INNER JOIN ADMISIONES.CTI_GRUPO_ESTUDIANTE G ON TX.ID_GRUPO_ESTUDIANTE = G.ID_GRUPO
                INNER JOIN ADMISIONES.CTI_GRUPO_TIPO_EST GT ON G.ID_GRUPO = GT.ID_GRUPO
                INNER JOIN ADMISIONES.A_TIPO_ESTUDIANTE TE ON GT.CODIGO_TIPO = TE.CODIGO
                INNER JOIN B_ESTUDIANTES E ON E.TIPO_DE_INGRESO = TE.TIPO
                WHERE          E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)
                           AND E.CODIGO = P_CODIGO;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- SE ASUME QUE EL ESTUDIANTE ES ANTIGUO.
                BEGIN
                    SELECT TRIM(TO_CHAR(TX.COD_TRANSACCION, '00'))
                    INTO   COD_TX
                    FROM   CTI_GRUPO_EST_TX TX
                    WHERE  TX.ID_GRUPO_ESTUDIANTE = 7;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20101,'Tipo de estudiante no registrado');
                END;
            END;
        ELSE
            BEGIN
                -- OBTENIENDO CODIGO DE TRANSACCION POR DEFECTO PARA EL TRIMESTRE ACTUAL.
                SELECT TRIM(TO_CHAR(TX.COD_TRANSACCION, '00'))
                INTO   COD_TX
                FROM   CTI_PERIODO TX
                WHERE  TX.ID_PERIODO = P_PERIODO;                  
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20101,'Periodo no registrado');
            END;
        END IF;
         
        -- ASIGNANDO DESCUENTO SI APLICA.
        COD_TX := NVL(GET_DESCUENTO(P_CODIGO, P_PERIODO), COD_TX);
        
        BEGIN
            -- SE CONSULTA EL NUMERO DE CREDITOS SEGUN EL PERIODO SELECCIONADO.
            SELECT     CR.CREDITOS, 
                       E.CODIGO_FACULTAD,
                       E.JORNADA_FACULTAD,
                       E.PLAN_ESTUDIO,
                       E.INDICADOR_PAGO
            INTO       N_CREDITOS, 
                       V_PRG,
                       V_JRN, 
                       V_PLAN, 
                       V_INDICADOR_PAGO
            FROM       B_ESTUDIANTES E
            INNER JOIN CTI_CREDITOS_PERIODO CR ON     E.CODIGO_FACULTAD = CR.CODIGO_FACULTAD 
                                                  AND E.JORNADA_FACULTAD = CR.JORNADA_FACULTAD 
                                                  AND E.PLAN_ESTUDIO = CR.PLAN_ESTUDIO
            WHERE          E.CODIGO = P_CODIGO
                       AND CR.PERIODO = P_PERIODO
                       AND CR.SEMESTRE = P_SEMESTRE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101,'No se han parametrizado los creditos por periodo: ' || SUBSTR(P_CODIGO, 0, 2));
        END;
        
        IF (P_CREDITOS_ADD > 0 AND V_INDICADOR_PAGO != 'P') THEN
            RAISE_APPLICATION_ERROR(-20101,'Solo puede solicitar creditos adicionales cuando ha matriculado el semestre completo.');
        END IF;
        
        -- OBTIENE LA CANTIDAD DE SEMESTRES Y CREDITOS DEL PLAN.
        PKG_PENSUM.GETRESUMENPENSUM(V_PRG, V_JRN, V_PLAN, N_SEMESTRES_PRG, N_CREDITOS_PRG);
        
        -- SI YA TIENE UNA GUIA ACTIVA CON EL MISMO CODIGO DE TRANSACCION PARA EL PERIODO ACTUAL, LO RETORNA.
        BEGIN
            SELECT     PR.*
            INTO       O_PARAMETRO
            FROM       ADMISIONES.A_PARAMETROS PR
            INNER JOIN ADMISIONES.G_GUIAS_DE_PAGO PG ON PR.NUMGUIA = PG.CODIGO_GUIA
            INNER JOIN B_ESTUDIANTES E ON     PG.CODIGO_EST = E.CODIGO 
                                          AND E.ANIO = PG.ANIO AND E.CICLO = PG.CICLO
            WHERE     PG.CODIGO_EST = P_CODIGO
                  AND PG.ACTIVA = 1
                  AND PG.COD_TRANSAC = COD_TX
                  AND PG.TOTAL_CREDITOS_INS = N_CREDITOS
                  AND PG.TOTAL_CRED_ADICIONALES = P_CREDITOS_ADD;
            RETURN;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        END;
                
        BEGIN
            -- DESACTIVANDO TODAS LAS GUIAS NO PAGAS ACTIVAS DEL PERIODO.
            UPDATE ADMISIONES.G_GUIAS_DE_PAGO P
            SET    P.ACTIVA = 0
            WHERE      P.CODIGO_EST = P_CODIGO
                   AND P.INDICADOR_PAGO NOT IN (SELECT PP.INDICADOR_PAGO FROM CTI_PERIODO PP)
                   AND P.ACTIVA = 1
                   AND EXISTS (SELECT 1 
                               FROM   B_ESTUDIANTES E 
                               WHERE      E.CODIGO = P.CODIGO_EST
                                      AND E.ANIO = P.ANIO 
                                      AND E.CICLO = P.CICLO);
                   
            -- INSERTANDO NUEVA GUIA DE PAGO.
            N_GUIA := ADMISIONES.SEQ_NUM_GUIA_PAGO.NEXTVAL;

            INSERT INTO ADMISIONES.G_GUIAS_DE_PAGO
            SELECT     E.CODIGO CODIGO_EST,
                       SYSDATE FECHA_GEN,
                       0 VAL_SEM,
                       0 TOTAL_INTENSIDAD_HOR,
                       E.CICLO,
                       0 RECARGOS,
                       0 AUXILIO_BECA,
                       0 ICETEX,
                       0 FORMULARIO_INSCRIPCION,
                       0 CREDITOS_ADICIONALES,
                       1 ACTIVA,
                       NULL DEUDA_DOCUMENTOS,
                       P.CODIGO FACULTAD,
                       '00000' MATERIA_PLAN,
                       P.CODIGO MATERIA_FACULTAD_CURSAR,
                       '00000' MATERIA_CURSAR,
                       '00' MATERIA_GRUPO,
                       N_GUIA CODIGO_GUIA, --> secuencia
                       '01' TIPO_GUIA,
                       E.ANIO,
                       '00' DIGITO_CHEQUEO,
                       0 VAL_PAGADO,
                       'S' CHACK_IMPRESION,
                       SYSDATE FECHA_ORD,
                       NULL FECHA_EXTRA1,
                       NULL FECHA_EXTRA2,
                       E.JORNADA_FACULTAD JORNADA_FAC_EST,
                       COD_TX COD_TRANSAC, --> param
                       N_CREDITOS TOTAL_CREDITOS_INS, --> param
                       P_CREDITOS_ADD TOTAL_CRED_ADICIONALES,
                       0 VAL_PAGADO_EXT1,
                       0 VAL_PAGADO_EXT2,
                       E.NOMBRE NOMEST,
                       0 VAL_SEGURO,
                       'ESTUDIANTE' TIPOEST,
                       SUBSTR(P.NOMBRE,0,50) NOMFAC,
                       E.PLAN_ESTUDIO PLAN,
                       0 PORCENTAJE_AUXILIO,
                       '.' BANCO,
                       '.' MENSAJE_INFO1,
                       '.' MENSAJE_INFO2,
                       '.' MENSAJE_INFO3,
                       NULL MENSAJE_NUEVOS,
                       NULL MENSAJE_SERVICIO_MEDICO,
                       'X' INDICADOR_PAGO,
                       0 VAL_OTROS_DESCUENTOS,
                       0 PAGO_PARCIAL,
                       0 VAL_INSCRIPCION,
                       NULL FECHA_PAGO,
                       TD.CODIGO CODTIPO_DOCUMENTO,
                       TD.TIPO TIPO_DOCUMENTO,
                       TD.VALOR NOMBRE_DOCUMENTO,
                       DP.NUMERO_DOCUMENTO
            FROM       ADMISIONES.A_PROGRAMAS P
            INNER JOIN B_ESTUDIANTES E ON P.CODIGO = E.CODIGO_FACULTAD AND E.JORNADA_FACULTAD = P.JORNADA
            INNER JOIN DATOS_PERSONALES DP ON E.CODIGO = DP.CODIGO_ESTUDIANTE
            INNER JOIN ADMISIONES.A_TIPO_DOCUMENTO TD ON DP.CODTIPO_DOCUMENTO = TD.CODIGO
            WHERE      E.CODIGO = P_CODIGO;
            
            -- CREANDO PARAMETRO DE LIQUIDACION.
            N_ID_PARAMETRO := ADMISIONES.SEQ_A_PARAMETROS.NEXTVAL;
            SELECT     E.ANIO, 
                       E.CICLO,
                       P.CODIGO CODFAC,
                       SUBSTR(P.NOMBRE,0,50) NOMFAC,
                       (CASE P.CODIGO_TIPO WHEN '001' THEN 'P' ELSE 'S' END) TIPO_PROGRAMA,
                       (CASE TD.TIPO WHEN 'PA' THEN 'PS' ELSE TD.TIPO END) TIPO_DOCUMENTO,
                       DP.NUMERO_DOCUMENTO,
                       E.CODIGO CODEST,
                       DP.PRIMER_APELLIDO,
                       DP.SEGUNDO_APELLIDO,
                       DP.PRIMER_NOMBRE,
                       DP.SEGUNDO_NOMBRE,
                       TO_CHAR(DP.FECHA_NACIMIENTO, 'RRRR/MM/DD') FECNAC,
                       '57' CODPAIS,
                       DP.CODDEPTO_NACIMIENTO CODDEPTO,
                       DP.CODMUNI_NACIMIENTO CODMUNI,
                       DP.DIRECCION,
                       DP.TELEFONO_CASA TELEFONO,
                       DP.SEXO GENERO,
                       DP.OTRO_EMAIL EMAIL,
                       SUBSTR(E.CICLO_DE_INGRESO, 0, 4) ANIO_INGRESO,
                       '0' SEMINF,
                       COD_TX CODTRAN,
                       N_CREDITOS TOTCRED_SEM,
                       (N_CREDITOS + P_CREDITOS_ADD) TOT_CREDITOS,
                       N_SEMESTRES_PRG NUMSEM,
                       N_CREDITOS_PRG TOTCREDFAC,
                       (CASE COD_TX WHEN '01' THEN 'S' WHEN '81' THEN 'S' ELSE 'N' END) PRIMER_SEMESTRE,
                       'N' RECARGO,
                       0 PORCRECARGO,
                       N_GUIA NUMGUIA, --> secuencia
                       'N' APLICAR_CONCEPTO,
                       P.JORNADA,
                       NULL CODSEG_PGM,
                       NULL NOMSEG_PGM,
                       NULL CREDINSSEG_PGM,
                       NULL CREDSEMSEG_PGM,
                       E.CICLO_DE_INGRESO,
                       SYSDATE FECHA,
                       NULL FECHA_AJUSTE,
                       NULL COD_DEF,
                       N_ID_PARAMETRO ID --> secuencia
            INTO       O_PARAMETRO
            FROM       ADMISIONES.A_PROGRAMAS P
            INNER JOIN CTI_CREDITOS_PERIODO CP ON     P.CODIGO = CP.CODIGO_FACULTAD 
                                                  AND P.JORNADA = CP.JORNADA_FACULTAD
            INNER JOIN B_ESTUDIANTES E ON     P.CODIGO = E.CODIGO_FACULTAD 
                                          AND P.JORNADA = E.JORNADA_FACULTAD 
                                          AND E.PLAN_ESTUDIO = CP.PLAN_ESTUDIO
            INNER JOIN DATOS_PERSONALES DP ON E.CODIGO = DP.CODIGO_ESTUDIANTE
            INNER JOIN ADMISIONES.A_TIPO_DOCUMENTO TD ON DP.CODTIPO_DOCUMENTO = TD.CODIGO
            WHERE          E.CODIGO = P_CODIGO  
                       AND CP.PERIODO = P_PERIODO
                       AND CP.SEMESTRE = P_SEMESTRE;
               
            -- INSERTANDO PARAMETRO CREADO.        
            INSERT INTO ADMISIONES.A_PARAMETROS VALUES O_PARAMETRO;
            COMMIT;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20101,'No se han encontrado datos para la liquidacion de: ' || P_CODIGO);
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20101,'No se logro realizar la liquidacion de ' || P_CODIGO || ': ' || SQLERRM);
        END;
    END LIQUIDAR_ESTUDIANTE;

    procedure marcar(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type,
        p_codigo_est admisiones.g_guias_de_pago.codigo_est%type,
        p_cod_transac admisiones.g_guias_de_pago.cod_transac%type,
        p_creds admisiones.g_guias_de_pago.total_creditos_ins%type,
        p_creds_add admisiones.g_guias_de_pago.total_cred_adicionales%type,
        p_ind_1 admisiones.g_guias_de_pago.indicador_pago%type,
        p_ind_2 admisiones.g_guias_de_pago.indicador_pago%type,
        p_anio admisiones.g_guias_de_pago.anio%type,
        p_ciclo admisiones.g_guias_de_pago.ciclo%type
    ) is
        n_cr number;
        n_n number;
        v_ind_pago b_estudiantes.indicador_pago%type;
    begin
        begin
            --A partir del codigo de transaccion se determina el indicador de pago
            select x.indicador_pago
            into v_ind_pago
            from (
                select pr.indicador_pago, trim(to_char(tx.cod_transaccion, '00')) codtx from cti_grupo_est_tx tx, cti_periodo pr where pr.id_periodo = 0
                union
                select p.indicador_pago, trim(to_char(d.codigo_transaccion, '00')) from cti_descuento_cod_tran d inner join cti_periodo p on d.id_periodo = p.id_periodo
                union
                select pr.indicador_pago, trim(to_char(pr.cod_transaccion, '00')) codtx from cti_periodo pr where pr.id_periodo > 0
            ) x
            where x.codtx = p_cod_transac;
        exception
        when no_data_found then
            raise_application_error(-20200, 'Transacción no permitida: ' || p_cod_transac);
        end;
        --PAGO
        if p_ind_1 = 'X' and p_ind_2 = 'P' then
            select count(*)
            into n_n
            from a_aspirantes a
            left join b_estudiantes e
            on a.cod_def = e.codigo
            where e.codigo is null
            and a.cod_def = p_codigo_est;
            if n_n > 0 then
                --Crea al estudiante de postgrado sin inscripción de materias.
                --Solo se adiciona en b_estudiantes y en datos_personales.
                pkg_estudiante.crear_estudiante_postgrado(p_codigo_est);
            end if;
            update b_estudiantes e set e.indicador_pago = v_ind_pago where e.codigo = p_codigo_est and e.indicador_pago in ('X', 'V');
            /*if sql%rowcount != 1 then
                raise_application_error(-20200, 'No se actualizó el indicador de pago del estudiante: ' || p_codigo_est);
            end if;*/
            select count(*)
            into n_n
            from cti_bolsa_general bg
            where bg.codigo = p_codigo_est
            and bg.anio = p_anio
            and bg.ciclo = p_ciclo;
            if n_n > 0 then
                if p_creds_add > 0 then
                    update cti_bolsa_general bg
                    set bg.tope = bg.tope + p_creds_add, bg.disponibles = bg.disponibles + p_creds_add
                    where bg.codigo = p_codigo_est
                    and bg.anio = p_anio
                    and bg.ciclo = p_ciclo;
                else
                    update cti_bolsa_general bg
                    set bg.tope = bg.tope + p_creds, bg.disponibles = bg.disponibles + p_creds
                    where bg.codigo = p_codigo_est
                    and bg.anio = p_anio
                    and bg.ciclo = p_ciclo;
                end if;
            else
                insert into cti_bolsa_general(codigo,anio,ciclo,tope,disponibles)
                values (p_codigo_est, p_anio, p_ciclo, p_creds, p_creds);
            end if;
        --DESPAGO
        elsif p_ind_1 = 'P' and p_ind_2 = 'X' then
            update b_estudiantes e
            set e.indicador_pago = 'X'
            where e.codigo = p_codigo_est
            and e.indicador_pago = v_ind_pago;
            if p_creds_add > 0 then
                update cti_bolsa_general bg
                set bg.tope = bg.tope - p_creds_add, bg.disponibles = bg.disponibles - p_creds_add
                where bg.codigo = p_codigo_est
                and bg.anio = p_anio
                and bg.ciclo = p_ciclo;
            else
                update cti_bolsa_general bg
                set bg.tope = bg.tope - p_creds, bg.disponibles = bg.disponibles - p_creds
                where bg.codigo = p_codigo_est
                and bg.anio = p_anio
                and bg.ciclo = p_ciclo;
            end if;
            select bg.disponibles
            into n_n
            from cti_bolsa_general bg
            where bg.codigo = p_codigo_est
            and bg.anio = p_anio
            and bg.ciclo = p_ciclo;
            if n_n < 0 then
                raise_application_error(-20200, 'Retire asignaturas para poder realizar el despago.');
            end if;
        end if;
    end marcar;

    procedure desactivarGuia(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type
    ) is
        v_respuesta json := json();
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        marcarGuiaDesactivada(p_codigo_guia);
        json.put(v_respuesta,'status','ok');
        json.put(v_respuesta,'mensaje','ok');
        json.htp(v_respuesta,false);
    exception
    when others then
        rollback;
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end desactivarGuia;

    procedure marcarGuiaDesactivada(
        p_codigo_guia admisiones.g_guias_de_pago.codigo_guia%type
    ) is
    begin
        update admisiones.g_guias_de_pago gp set gp.activa = 0
        where gp.codigo_guia = p_codigo_guia
        and gp.activa = 1
        and gp.indicador_pago = 'X';
        commit;
    exception
    when others then
        rollback;
        raise_application_error(-20200, 'No se pudo desactivar la guia de pago.');
    end marcarGuiaDesactivada;

    function trimestreActual(
        p_admision number default 0
    ) return number as
        n_id_periodo_1 cti_periodo.id_periodo%type;
        n_id_periodo_2 cti_periodo.id_periodo%type;
    begin
        if p_admision = 0 then
            select
                nvl((select 1 from admisiones.a_fechas_de_corte fc
                where fc.proceso = 'INICIO-FIN TRIMESTRE 1 POSGRADO'
                and fc.anio = pp.anio
                and fc.ciclo = pp.ciclo
                and sysdate between fc.fecha_inicio and fc.fecha_finalizacion), 0),
                nvl((select 1 from admisiones.a_fechas_de_corte fc
                where fc.proceso = 'INICIO-FIN TRIMESTRE 2 POSGRADO'
                and fc.anio = pp.anio
                and fc.ciclo = pp.ciclo
                and sysdate between fc.fecha_inicio and fc.fecha_finalizacion), 0)
            into n_id_periodo_1, n_id_periodo_2
            from desarrollospre.ss_periodo pp
            where pp.id_ciclo = 2
            and pp.id_estado_periodo = 1;
        else
            select
                nvl((select 1 from admisiones.a_fechas_de_corte fc
                where fc.proceso = 'INICIO-FIN ADM. TRIM. 1 POSGRADO'
                and sysdate between fc.fecha_inicio and fc.fecha_finalizacion), 0) uno,
                nvl((select 1 from admisiones.a_fechas_de_corte fc
                where fc.proceso = 'INICIO-FIN ADM. TRIM. 2 POSGRADO'
                and sysdate between fc.fecha_inicio and fc.fecha_finalizacion), 0) dos
            into n_id_periodo_1, n_id_periodo_2
            from dual;
        end if;

        if n_id_periodo_1 = 1 and n_id_periodo_2 = 0 then
            return 1;
        elsif n_id_periodo_1 = 0 and n_id_periodo_2 = 1 then
            return 2;
        else
            raise_application_error(-20150, 'Trimestres mal configurados, revisar fechas');
        end if;
    end trimestreActual;

    procedure listadoPeriodos(
        p_codigo b_estudiantes.codigo%type
    ) is
        type t_periodos is ref cursor;
        c_periodos t_periodos;
        n_aspirante number;
        n_guias number;
        n_id_periodo cti_periodo.id_periodo%type;
        v_indicador_pago b_estudiantes.indicador_pago%type;
        v_mcicloant b_estudiantes.matriculados_ciclo_anterior%type;
        n_periodo_act cti_periodo.id_periodo%type;
        n_id cti_periodo.id_periodo%type;
        v_periodo cti_periodo.periodo%type;
        j_per json;
        v_list json_list := json_list();
        V_RESPUESTA JSON := JSON();
        v_c number default 0;
    begin
        owa_util.mime_header('application/json',false,'utf-8');
        owa_util.http_header_close;
        if not regexp_like(p_codigo, '^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$') then
            raise_application_error(-20300, 'Código no valido.');
        end if;
        begin
            select p.id_periodo, e.indicador_pago, case when e.ciclo_de_ingreso = e.anio || to_number(e.ciclo) then e.indicador_pago else e.matriculados_ciclo_anterior end
            into n_id_periodo, v_indicador_pago, v_mcicloant
            from b_estudiantes e
            left join cti_periodo p
            on e.indicador_pago = p.indicador_pago
            where e.codigo = p_codigo;
            n_periodo_act := trimestreActual();
        exception
        when no_data_found then
            select count(*)
            into n_aspirante
            from a_aspirantes a
            where a.cod_def = p_codigo;
            if n_aspirante <= 0 then
                raise_application_error(-20300, 'Código inexistente.');
            end if;
            --Si entra por este lado es porque es un aspirante
            v_indicador_pago := 'X';
            n_periodo_act := trimestreActual(1);
        end;
        if n_periodo_act = 1 and v_indicador_pago = 'X' then
            open c_periodos for
                select pp.id_periodo, pp.periodo
                from cti_periodo pp
                where pp.id_periodo in (0, 1);
        elsif (n_periodo_act = 2 and v_indicador_pago = 'X') or (n_id_periodo = 1 and n_periodo_act = 2) or (n_id_periodo = 1 and n_periodo_act = 1) then
            open c_periodos for
                select pp.id_periodo, pp.periodo
                from cti_periodo pp
                where pp.id_periodo in (2);
                --where pp.id_periodo in (-1); -- todavia no se pueden generar guias de segundo trimestre.
        else
            open c_periodos for
                select pp.id_periodo, pp.periodo
                from cti_periodo pp
                where pp.id_periodo in (n_id_periodo);
        end if;
        loop fetch c_periodos into n_id, v_periodo;
            exit when c_periodos%notfound;
            j_per := json();
            json.put(j_per,'id',n_id);
            json.put(j_per,'periodo',v_periodo);
            json_list.append(v_list,j_per.to_json_value);
        end loop;
        close c_periodos;
        --Determina el numero de guías activas sin pago del ciclo actual
        select count(*)
        into n_guias
        from admisiones.g_guias_de_pago p
        inner join (
            select ee.codigo, ee.anio, ee.ciclo
            from b_estudiantes ee
            where ee.codigo = p_codigo
            union
            select aa.cod_def codigo, aa.anio, aa.ciclo
            from a_aspirantes aa
            where aa.cod_def = p_codigo
        ) x
        on x.codigo = p.codigo_est and x.anio = p.anio and x.ciclo = p.ciclo
        where p.codigo_est = p_codigo
        and p.activa = 1
        and p.indicador_pago = 'X'
        and p.cod_transac in (
            select trim(to_char(tx.cod_transaccion, '00')) codtx from cti_grupo_est_tx tx, cti_periodo pr where pr.id_periodo = 0
            union
            select trim(to_char(pr.cod_transaccion, '00')) codtx from cti_periodo pr where pr.id_periodo > 0
        );
        j_per := json();
        json.put(j_per,'guia',n_guias);
        json.put(j_per,'periodos',v_list.to_json_value);
        json.htp(j_per,false);
    exception
    when others then
        json.put(v_respuesta,'status','fail');
        json.put(v_respuesta,'mensaje',sqlerrm);
        json.htp(v_respuesta,false);
    end listadoPeriodos;

    FUNCTION PuedeEmitirGuiaDePago(
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) RETURN NUMBER IS
        V_TIPO_ESTUDIANTE VARCHAR2(2);
        V_MATERIAS_FALTANTES NUMBER;
        V_MATRICULADO_CICLO_ANTERIOR NUMBER;
        V_MATRICULADO NUMBER DEFAULT 0;
        v_acomp_tut number default 0;
    BEGIN
        IF(P_CODIGO_ESTUDIANTE IS NULL) THEN RETURN 0; END IF;

        SELECT    TIPO_DE_INGRESO,
                  NVL(MATERIAS_PENDIENTES, '1'),     
                  CASE 
                    WHEN (P.ID_PERIODO IS NOT NULL AND E.INDICADOR_PAGO NOT IN ('P', 'W')) THEN 1
                    WHEN (E.INDICADOR_PAGO = 'V') THEN 1
                    ELSE 0 
                  END
        INTO      V_TIPO_ESTUDIANTE,
                  V_MATERIAS_FALTANTES,
                  V_MATRICULADO_CICLO_ANTERIOR
        FROM      B_ESTUDIANTES E
        LEFT JOIN CTI_PERIODO P ON NVL(E.MATRICULADOS_CICLO_ANTERIOR, 'X') = P.INDICADOR_PAGO
        WHERE     CODIGO = P_CODIGO_ESTUDIANTE;

        --mariano rua mejia 09/01/2020 --matriculados
        SELECT    
                  CASE 
                   WHEN P.INDICADOR_PAGO = 'P' AND  P.ID_PERIODO = 0 THEN 0
                   WHEN P.INDICADOR_PAGO = 'V' AND  P.ID_PERIODO = 1 THEN 0
                   WHEN P.INDICADOR_PAGO = 'W' AND  P.ID_PERIODO = 2 THEN 1
                   ELSE 0
                  END
        INTO      V_MATRICULADO
        FROM      B_ESTUDIANTES E
        LEFT JOIN CTI_PERIODO P ON NVL(E.INDICADOR_PAGO, 'X') = P.INDICADOR_PAGO
        WHERE     CODIGO = P_CODIGO_ESTUDIANTE;

        --mariano rua mejia 10/01/2020 --acompañamiento tutorial
        /*SELECT COUNT(*)
        into  v_acomp_tut
        FROM AUTORIZACION_GUIA_ACOMP AC
        WHERE AC.CODIGO_estudiante = P_CODIGO_ESTUDIANTE
        and ac.anio||ac.ciclo = (select unique b.anio||b.ciclo from b_estudiantes b);*/

        IF V_ACOMP_TUT>0 THEN
           RETURN 1;
        end if;

        IF(ADMISIONES.VERIFICAR_DEUDA_FINANCIERA(P_CODIGO_ESTUDIANTE) != 'OK') THEN RETURN -1;
        ELSIF (ADMISIONES.VERIFICAR_DEUDA_BIBLIOTECA(P_CODIGO_ESTUDIANTE) != 'OK') THEN RETURN -2; 
        ELSIF (V_MATRICULADO =1) THEN RETURN -6;  
        --ELSIF (V_MATRICULADO_CICLO_ANTERIOR = 0) THEN RETURN -3; 
        --ELSIF(pkg_estudiante.es_transferencia_reintegro(p_codigo_estudiante) = 1) then return -5;
        --ELSIF (V_MATERIAS_FALTANTES <= 0) THEN RETURN -4;
        END IF;
        RETURN 1;
    END;

    /*
        OBTIENE LA GUIA DE PAGO MARCADA COMO ACTIVA.
        @param P_CODIGO_ESTUDIANTE VARCHAR2
        */
    PROCEDURE GETGUIADEPAGOACTIVA(
        P_CODIGO_ESTUDIANTE VARCHAR2
    ) IS
        V_BODY JSON;
        V_CODIGO_GUIA NUMBER;
    BEGIN
        V_BODY := JSON();
        SELECT MAX(CODIGO_GUIA)
        INTO   V_CODIGO_GUIA
        FROM   ADMISIONES.G_GUIAS_DE_PAGO 
        WHERE      CODIGO_EST  = P_CODIGO_ESTUDIANTE
               AND ACTIVA = '1'
               AND INDICADOR_PAGO != 'P'
               AND COD_TRANSAC IN (SELECT TRIM(TO_CHAR(TX.COD_TRANSACCION, '00'))
                                   FROM CTI_GRUPO_EST_TX TX
                                   UNION
                                   SELECT TRIM(TO_CHAR(TX.COD_TRANSACCION, '00'))
                                   FROM CTI_PERIODO TX
                                   WHERE TX.ID_PERIODO NOT IN (0));
        if V_CODIGO_GUIA is null then
            JSON.PUT(V_BODY, 'status', 'fail');
            JSON.PUT(V_BODY, 'mensaje', 'Sin resultados');
        else
            JSON.PUT(V_BODY, 'status', 'ok');
            JSON.PUT(V_BODY, 'mensaje', to_char(V_CODIGO_GUIA));
        end if;
        JSON.HTP(V_BODY);
    EXCEPTION
    WHEN OTHERS THEN
        JSON.PUT(V_BODY,'status','fail');
        JSON.PUT(V_BODY,'mensaje',SQLERRM);
        JSON.HTP(V_BODY,FALSE);
    END;

    /*
        OBTIENE EL CODIGO DE TRANSACCION SI EL ESTUDIANTE APLICA PARA ALGUN DESCUENTO.
        @param P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE
        @param P_PERIODO CTI_PERIODO.ID_PERIODO%TYPE
        @return 
        */
    FUNCTION GET_DESCUENTO(
        P_CODIGO_ESTUDIANTE B_ESTUDIANTES.CODIGO%TYPE,
        P_PERIODO CTI_PERIODO.ID_PERIODO%TYPE
    ) RETURN NUMBER IS
        V_CODIGO_TRANSACCION NUMBER;
        V_QUERY_TEMPLATE VARCHAR2(1000) DEFAULT 'SELECT [FUNCTION] (:codigoEstudiante, :id_periodo) FROM DUAL';
        V_QUERY VARCHAR2(1000);
    BEGIN
        FOR DESCUENTO IN (SELECT   OPERACION
                          FROM     POSTGRADO.CTI_DESCUENTO
                          ORDER BY PRIORIDAD) LOOP 
            V_QUERY := REPLACE(V_QUERY_TEMPLATE, '[FUNCTION]', DESCUENTO.OPERACION);
            -- SE EJECUTA LA FUNCION DINAMICAMENTE. TODAS LAS FUNCIONES DEBEN TENER LOS MISMOS PARAMETROS.
            EXECUTE IMMEDIATE V_QUERY INTO V_CODIGO_TRANSACCION USING P_CODIGO_ESTUDIANTE, P_PERIODO;
            IF(V_CODIGO_TRANSACCION != '0') THEN 
                RETURN TRIM(TO_CHAR(V_CODIGO_TRANSACCION, '00')); 
            END IF;
        END LOOP;
        RETURN NULL;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
    END;

end pkg_liquidacion;