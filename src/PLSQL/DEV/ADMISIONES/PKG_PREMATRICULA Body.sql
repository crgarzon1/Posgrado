create or replace package body pkg_prematricula
as


-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE LOS GRUPOS DE ACUERDO AL CONSECUTIVO. DEVUELVE UN OBJECTO JSON.
-- ****************************************************************************************************************************
	PROCEDURE GRUPO_JSON_OBJECT(
		P_JSON_OBJECT OUT JSON,
		P_CONSECUTIVO IN INTEGER,
		P_ELIMINABLE  IN INTEGER,
		P_YOPAL       IN INTEGER DEFAULT 0)
	AS
		V_CONSECUTIVO	 		NUMBER;
		V_COD_FACU   	 		VARCHAR2(4);
		V_FACU       	 		VARCHAR2(128);
		V_SEDE       			VARCHAR2(64);
		V_COD_MATE   	 		VARCHAR2(8);
		V_MATE       	 		VARCHAR2(128);
		V_GRUPO      	 		NUMBER;
		V_CUPO       			NUMBER;
		V_DISPONIBLE 			NUMBER;
		V_I           			NUMBER DEFAULT 1;
		V_J            			NUMBER DEFAULT 1;
        V_ISCANCELADO   		VARCHAR2(2) DEFAULT NULL;
		P_JSON_AUXILIAR1 		JSON;
		P_JSON_AUXILIAR2 		JSON;
        P_JSON_AUXILIAR1_LIST   JSON_LIST;
        P_JSON_AUXILIAR2_LIST   JSON_LIST;
	BEGIN
		BEGIN
			P_JSON_OBJECT := JSON();
			IF P_CONSECUTIVO <= 0 THEN
				RETURN;
			END IF;
			IF P_YOPAL <= 0 THEN
				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				INTO 		V_CONSECUTIVO,
							V_COD_FACU,
							V_FACU,
							V_SEDE,
							V_COD_MATE,
							V_MATE,
							V_GRUPO,
							V_CUPO,
							V_DISPONIBLE,
							V_ISCANCELADO
				FROM 		A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				FROM 		CACTUALPRE.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO    = P_CONSECUTIVO

				UNION

				SELECT		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				FROM 		POSTGRADO.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				FROM 		CACTUALPOS.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
										   AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE		AH.CONSECUTIVO = P_CONSECUTIVO;
			ELSE
				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				INTO 		V_CONSECUTIVO,
							V_COD_FACU,
							V_FACU,
							V_SEDE,
							V_COD_MATE,
							V_MATE,
							V_GRUPO,
							V_CUPO,
							V_DISPONIBLE,
							V_ISCANCELADO
				FROM 		YOPAL.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	YOPAL.A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
											     AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO

				UNION

				SELECT 		AH.CONSECUTIVO,
							AH.CODIGO_FACULTAD,
							F.NOMBRE,
							F.SEDE,
							AH.CODIGO_MATERIA,
							AH.NOMBRE_MATERIA,
							TO_NUMBER(AH.GRUPO_MATERIA),
							AH.CUPO,
							AH.CUPO - AH.CUPO_UTILIZADO,
							AH.ABIERTO
				FROM		CACTUALYOP.A_HORARIO_HORIZONTAL AH
				INNER JOIN 	YOPAL.A_FACULTADES F ON  AH.CODIGO_FACULTAD  = F.CODIGO
												 AND AH.JORNADA_FACULTAD = F.JORNADA
				WHERE 		AH.CONSECUTIVO = P_CONSECUTIVO;
			END IF;
		EXCEPTION
		WHEN OTHERS THEN
            P_JSON_OBJECT := NULL;
			RETURN;
		END;
		JSON.PUT(P_JSON_OBJECT, 'consecutivo', V_CONSECUTIVO);
		P_JSON_AUXILIAR1 := JSON();
		JSON.PUT(P_JSON_AUXILIAR1, 'codFacultad', V_COD_FACU);
		JSON.PUT(P_JSON_AUXILIAR1, 'nombreFacultad', TRIM(V_FACU));
		P_JSON_AUXILIAR2 := JSON();
		JSON.PUT(P_JSON_AUXILIAR2, 'sede', V_SEDE);
		JSON.PUT(P_JSON_AUXILIAR1, 'sede', P_JSON_AUXILIAR2);
		JSON.PUT(P_JSON_OBJECT, 'facultadCursar', P_JSON_AUXILIAR1);
		P_JSON_AUXILIAR1 := JSON();
		JSON.PUT(P_JSON_AUXILIAR1, 'codMateria', V_COD_MATE);
		--JSON.PUT(P_JSON_AUXILIAR1, 'nombreMateria',  PKG_PREMATRICULA.F_ACENTOS(V_MATE));
		JSON.PUT(P_JSON_AUXILIAR1, 'nombreMateria',  V_MATE);
		JSON.PUT(P_JSON_OBJECT, 'materiaCursar', P_JSON_AUXILIAR1);
		JSON.PUT(P_JSON_OBJECT, 'grupo', V_GRUPO);
		JSON.PUT(P_JSON_OBJECT, 'cupo', V_CUPO);
		JSON.PUT(P_JSON_OBJECT, 'cupoDisponible', V_DISPONIBLE);
		JSON.PUT(P_JSON_OBJECT, 'eliminable', P_ELIMINABLE);

        P_JSON_AUXILIAR1_LIST := JSON_LIST();
        IF (V_ISCANCELADO NOT IN ('S')) THEN
			JSON.PUT(P_JSON_OBJECT, 'cancelado', '1');
        END IF;

		FOR DIA IN
			(
				SELECT 		X.DIA,
							X.DTXT,
							COUNT(*) OVER () TOT_ROWS
				FROM 		(
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				ADMISIONES.A_HORARIO_VERTICAL
								WHERE 				CONSECUTIVO = P_CONSECUTIVO
								UNION
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				CACTUALPRE.A_HORARIO_VERTICAL
								WHERE               CONSECUTIVO = P_CONSECUTIVO
                                UNION                                
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				POSTGRADO.A_HORARIO_VERTICAL
								WHERE 				CONSECUTIVO = P_CONSECUTIVO
								UNION
								SELECT DISTINCT 	DIA,
													DECODE(DIA,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') DTXT
								FROM 				CACTUALPOS.A_HORARIO_VERTICAL
								WHERE               CONSECUTIVO = P_CONSECUTIVO
							) X
				ORDER BY X.DIA
			) LOOP
			P_JSON_AUXILIAR1 := JSON();
			P_JSON_AUXILIAR2_LIST := JSON_LIST();
			JSON.PUT(P_JSON_AUXILIAR1, 'idDia', (DIA.DIA - 1));
			JSON.PUT(P_JSON_AUXILIAR1, 'dia', DIA.DTXT);
			V_I := 1;
			FOR HR IN
				(
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM		A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO, 
								SALON
					UNION
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM 		CACTUALPRE.A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO, 
								SALON
                    UNION
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								'' SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM		POSTGRADO.A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO
					UNION
					SELECT 		TO_CHAR(MIN(TO_NUMBER(HORA)), '00') HMIN,
								TO_CHAR(MAX(TO_NUMBER(HORA)) + 1, '00') HMAX,
								DECODE(TIPO, 't', 0, 'p', 1, 0) TIPO,
								'' SALON,
								COUNT(*) OVER () TOT_ROWS
					FROM 		CACTUALPOS.A_HORARIO_VERTICAL
					WHERE 			CONSECUTIVO = P_CONSECUTIVO
								AND DIA         = DIA.DIA
					GROUP BY 	BLOQUE, 
								TIPO
				) LOOP
				P_JSON_AUXILIAR2 := JSON();
				JSON.PUT(P_JSON_AUXILIAR2, 'inicio', TRIM(HR.HMIN) || ':00');
				JSON.PUT(P_JSON_AUXILIAR2, 'fin', TRIM(HR.HMAX) || ':00');
				JSON.PUT(P_JSON_AUXILIAR2, 'practica', HR.TIPO);
				JSON.PUT(P_JSON_AUXILIAR2, 'salon', HR.SALON);				
				JSON_LIST.APPEND(P_JSON_AUXILIAR2_LIST, P_JSON_AUXILIAR2.TO_JSON_VALUE);
				V_I := V_I + 1;
			END LOOP;
			JSON.PUT(P_JSON_AUXILIAR1, 'hora', P_JSON_AUXILIAR2_LIST);
			V_J := V_J + 1;

            JSON_LIST.APPEND(P_JSON_AUXILIAR1_LIST, P_JSON_AUXILIAR1.TO_JSON_VALUE);
		END LOOP;
		JSON.PUT(P_JSON_OBJECT, 'horario', P_JSON_AUXILIAR1_LIST);
	EXCEPTION
	WHEN OTHERS THEN
		JSON.PUT(P_JSON_OBJECT, 'exception',  SQLCODE || ' - grupo - ' || SQLERRM || ': ' || P_CONSECUTIVO);
	END GRUPO_JSON_OBJECT;

	procedure grupo_json(
			p_consecutivo in integer,
			p_eliminable  in integer,
			p_yopal       in integer default 0)
	as
		v_consecutivo number;
		v_cod_facu    varchar2(4);
		v_facu        varchar2(128);
		v_sede        varchar2(64);
		v_cod_mate    varchar2(8);
		v_mate        varchar2(128);
		v_grupo       number;
		v_cupo        number;
		v_disponible  number;
		v_i           number default 1;
		v_j           number default 1;
        v_iscancelado varchar2(2) default null;
	begin
		begin
			if p_consecutivo <= 0 then
				return;
			end if;
			if p_yopal <= 0 then
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				into v_consecutivo,
					v_cod_facu,
					v_facu,
					v_sede,
					v_cod_mate,
					v_mate,
					v_grupo,
					v_cupo,
					v_disponible,
                    v_iscancelado
				from a_horario_horizontal ah
				inner join a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo
				union
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				from cactualpre.a_horario_horizontal ah
				inner join a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo
				union
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				from postgrado.a_horario_horizontal ah
				inner join a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo
				union
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				from cactualpos.a_horario_horizontal ah
				inner join a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo;
			else
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				into v_consecutivo,
					v_cod_facu,
					v_facu,
					v_sede,
					v_cod_mate,
					v_mate,
					v_grupo,
					v_cupo,
					v_disponible,
                    v_iscancelado
				from yopal.a_horario_horizontal ah
				inner join yopal.a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo
				union
				select ah.consecutivo,
					ah.codigo_facultad,
					f.nombre,
					f.sede,
					ah.codigo_materia,
					ah.nombre_materia,
					to_number(ah.grupo_materia),
					ah.cupo,
					ah.cupo - ah.cupo_utilizado,
                    ah.abierto
				from cactualyop.a_horario_horizontal ah
				inner join yopal.a_facultades f
				on (ah.codigo_facultad  = f.codigo
				and ah.jornada_facultad = f.jornada)
				where ah.consecutivo    = p_consecutivo;
			end if;
		exception
		when no_data_found then
			return;
		end;
		htp.prn('{' || '"consecutivo":' || v_consecutivo || ',' || '"facultadCursar":{"codFacultad":"' || v_cod_facu || '","nombreFacultad":"' || trim(v_facu) || '","sede":{"sede":"' || v_sede || '"}},' || '"materiaCursar":{"codMateria":"' || v_cod_mate || '","nombreMateria":"' || pkg_prematricula.f_acentos(v_mate) || '"},' || '"grupo":' || v_grupo || ',' || '"cupo":' || v_cupo || ',' || '"cupoDisponible":' || v_disponible || ',' || '"eliminable":' || p_eliminable || ',');
        if v_iscancelado not in ('S') then
            htp.prn('"cancelado":1,');
        end if;
        htp.prn('"horario":[');
		for dia in
		(select x.dia,
			x.dtxt,
			count(*) over () tot_rows
		from
			(select distinct dia,
				decode(dia,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') dtxt
			from a_horario_vertical
			where consecutivo = p_consecutivo
            --CIERRE DE HORARIOS
            union
            select distinct dia,
				decode(dia,'1','Lunes','2','Martes','3','Miercoles','4','Jueves','5','Viernes','6','Sabado','X') dtxt
			from cactualpre.a_horario_vertical
			where consecutivo = p_consecutivo
            --FIN CIERRE DE HORARIOS
			) x
		order by x.dia
		)
		loop
			htp.prn('{' || '"idDia":' || (dia.dia - 1) || ',' || '"dia":"' || dia.dtxt || '",' || '"hora":[');
			v_i := 1;
			for hr in
			(select to_char(min(to_number(hora)), '00') hmin,
				to_char(max(to_number(hora)) + 1, '00') hmax,
				decode(tipo, 't', 0, 'p', 1, 0) tipo,
				salon,
				count(*) over () tot_rows
			from a_horario_vertical
			where consecutivo = p_consecutivo
			and dia           = dia.dia
			group by bloque,
				tipo,
				salon
            --CIERRE DE HORARIOS
            union
            select to_char(min(to_number(hora)), '00') hmin,
				to_char(max(to_number(hora)) + 1, '00') hmax,
				decode(tipo, 't', 0, 'p', 1, 0) tipo,
				salon,
				count(*) over () tot_rows
			from cactualpre.a_horario_vertical
			where consecutivo = p_consecutivo
			and dia           = dia.dia
			group by bloque,
				tipo,
				salon
            --FIN CIERRE DE HORARIOS
			)
			loop
				htp.prn('{' || '"inicio":"' || trim(hr.hmin) || ':00",' || '"fin":"' || trim(hr.hmax) || ':00",' || '"practica":' || hr.tipo || ',' || '"salon":"' || hr.salon || '"');
				if v_i = hr.tot_rows then
					htp.prn('}');
				else
					htp.prn('},');
				end if;
				v_i := v_i + 1;
			end loop;
			htp.prn(']');
			if v_j = dia.tot_rows then
				htp.prn('}');
			else
				htp.prn('},');
			end if;
			v_j := v_j + 1;
		end loop;
		htp.prn(']}');
	exception
	when others then
		htp.prn('{"exception":"' || sqlcode || ' - grupo - ' || sqlerrm || ': ' || p_consecutivo || '"}');
	end grupo_json;
	procedure oferta_academica(
			p_codigo  varchar2,
			p_anio    varchar2,
			p_ciclo   varchar2,
			p_tipo    number,
			p_soferta number default 0)
	as
	type t_oferta
is
	ref
	cursor;
	type consecs
is
	table of integer;
	consecutivos consecs := consecs();
	consec_norep consecs := consecs();
	v_n number default 1;
	csv clob default '';
	v_oferta t_oferta;
	v_opcion_no_valida number default 0;
	v_cod_mate         varchar2(8);
	v_semestre         number;
	v_creditos         number;
	v_ihoraria         number;
	v_materia          varchar2(256);
	v_consecutivo      number;
	v_post             number;
	v_cod_mate_act     varchar2(8) default 'X';
	v_cod_facu         varchar2(8);
	v_facu             varchar2(256);
	v_jornada_facu     varchar2(4);
	v_sede             varchar2(68);
	v_al_menos_uno     number default 0;
begin
	/*
	1: primiparos - solo 1ro misma sede
	2: primiparos UA - solo 1ro
	3: oferta x sede
	4: toda la oferta sin postgraduales
	5: toda la oferta con postgraduales
	6: todos los ofertados (para RA)
	*/
	select f.codigo,
		f.nombre,
		f.jornada,
		f.sede
	into v_cod_facu,
		v_facu,
		v_jornada_facu,
		v_sede
	from b_estudiantes e
	inner join a_facultades f
	on (e.codigo_facultad  = f.codigo
	and e.jornada_facultad = f.jornada)
	where e.codigo         =p_codigo;
case p_tipo
when 1 then
	open v_oferta for select m.codigo,
        to_number(m.semestre) sem,
        m.creditos,
        m.intensidad_horaria,
        m.nombre,
        ah.consecutivo,
        0 postgradual
    from a_materias_pendientes mp
    inner join a_horario_horizontal ah
    on  mp.codigo_materia   = ah.codigo_materia
    and mp.codigo_facultad  = ah.codigo_facultad
    and mp.jornada_facultad = ah.jornada_facultad
    inner join a_materias m
    on  mp.codigo_materia                                                                                                                                               = m.codigo
    and mp.codigo_facultad                                                                                                                                              = m.codigo_facultad
    and mp.jornada_facultad                                                                                                                                             = m.jornada_facultad
    and mp.plan_estudio                                                                                                                                                 = m.plan_estudio
    where ah.abierto                                                                                                                                                    = 'S'
    and mp.aprobada                                                                                                                                                    is null
    and mp.codigo_estudiante                                                                                                                                            = p_codigo
    and ah.anio                                                                                                                                                         = p_anio
    and ah.ciclo                                                                                                                                                        = p_ciclo
    and decode(ah.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede
    and m.semestre                                                                                                                                                      = '01'
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where h.abierto      ='S' and p.aprobada is null and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and decode(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede and m.semestre ='01'
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo_materia in
		(select cj.materia
		from a_cambio_jornada cj
		where cj.codigo             =p.codigo_estudiante
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and p.aprobada is null and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and decode(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede and m.semestre ='01'
    --FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
	order by sem,
		codigo,
		consecutivo;
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
when 2 then
	open v_oferta for select m.codigo,
        to_number(m.semestre) sem,
        m.creditos,
        m.intensidad_horaria,
        m.nombre,
        ah.consecutivo,
        0 postgradual
    from a_materias_pendientes mp
    inner join a_horario_horizontal ah
    on  mp.codigo_materia   = ah.codigo_materia
    and mp.codigo_facultad  = ah.codigo_facultad
    and mp.jornada_facultad = ah.jornada_facultad
    inner join a_materias m
    on  mp.codigo_materia                                                                                                                                               = m.codigo
    and mp.codigo_facultad                                                                                                                                              = m.codigo_facultad
    and mp.jornada_facultad                                                                                                                                             = m.jornada_facultad
    and mp.plan_estudio                                                                                                                                                 = m.plan_estudio
    where ah.abierto                                                                                                                                                    = 'S'
    and mp.aprobada                                                                                                                                                    is null
    and mp.codigo_estudiante                                                                                                                                            = p_codigo
    and ah.anio                                                                                                                                                         = p_anio
    and ah.ciclo                                                                                                                                                        = p_ciclo
    and decode(ah.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede
    and m.semestre                                                                                                                                                      = '01'
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where h.abierto      ='S' and p.aprobada is null and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and m.semestre ='01'
    --FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo_materia in
		(select cj.materia
		from a_cambio_jornada cj
		where cj.codigo             =p.codigo_estudiante
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and p.aprobada is null and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and m.semestre ='01'
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    order by sem,
		codigo,
		consecutivo;
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
when 3 then
	open v_oferta for select m.codigo,
        to_number(m.semestre) sem,
        m.creditos,
        m.intensidad_horaria,
        m.nombre,
        ah.consecutivo,
        0 postgradual
    from a_materias_pendientes mp
    inner join a_horario_horizontal ah
    on  mp.codigo_materia   = ah.codigo_materia
    and mp.codigo_facultad  = ah.codigo_facultad
    and mp.jornada_facultad = ah.jornada_facultad
    inner join a_materias m
    on  mp.codigo_materia                                                                                                                                               = m.codigo
    and mp.codigo_facultad                                                                                                                                              = m.codigo_facultad
    and mp.jornada_facultad                                                                                                                                             = m.jornada_facultad
    and mp.plan_estudio                                                                                                                                                 = m.plan_estudio
    where ah.abierto                                                                                                                                                    = 'S'
    --Incluye materias con requisitos autorizados
    and (mp.aprobada is null or mp.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and mp.codigo_estudiante                                                                                                                                            = p_codigo
    and ah.anio                                                                                                                                                         = p_anio
    and ah.ciclo                                                                                                                                                        = p_ciclo
    and decode(ah.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where h.abierto      ='S' and
    --Incluye materias con requisitos autorizados
    (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and decode(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede
    --FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo_materia in
		(select cj.materia
		from a_cambio_jornada cj
		where cj.codigo             =p.codigo_estudiante
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and
        --Incluye materias con requisitos autorizados
        (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
        and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo and decode(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') = v_sede
    --FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
	order by sem,
		codigo,
		consecutivo;
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
when 4 then
	open v_oferta for select m.codigo,
        to_number(m.semestre) sem,
        m.creditos,
        m.intensidad_horaria,
        m.nombre,
        ah.consecutivo,
        0 postgradual
    from a_materias_pendientes mp
    inner join a_horario_horizontal ah
    on  mp.codigo_materia   = ah.codigo_materia
    and mp.codigo_facultad  = ah.codigo_facultad
    and mp.jornada_facultad = ah.jornada_facultad
    inner join a_materias m
    on  mp.codigo_materia    = m.codigo
    and mp.codigo_facultad   = m.codigo_facultad
    and mp.jornada_facultad  = m.jornada_facultad
    and mp.plan_estudio      = m.plan_estudio
    where ah.abierto         = 'S'
    and
    --Incluye materias con requisitos autorizados
    (mp.aprobada is null or mp.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and mp.codigo_estudiante = p_codigo
    and ah.anio              = p_anio
    and ah.ciclo             = p_ciclo
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where h.abierto      ='S' and
    --Incluye materias con requisitos autorizados
    (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo_materia in
		(select cj.materia
		from a_cambio_jornada cj
		where cj.codigo             =p.codigo_estudiante
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and
        --Incluye materias con requisitos autorizados
        (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
        and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    order by sem,
		codigo,
		consecutivo;
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
	--########################################################################################################################
when 5 then
	open v_oferta for select m.codigo,
        to_number(m.semestre) sem,
        m.creditos,
        m.intensidad_horaria,
        m.nombre,
        ah.consecutivo,
        0 postgradual
    from a_materias_pendientes mp
    inner join a_horario_horizontal ah
    on  mp.codigo_materia   = ah.codigo_materia
    and mp.codigo_facultad  = ah.codigo_facultad
    and mp.jornada_facultad = ah.jornada_facultad
    inner join a_materias m
    on  mp.codigo_materia    = m.codigo
    and mp.codigo_facultad   = m.codigo_facultad
    and mp.jornada_facultad  = m.jornada_facultad
    and mp.plan_estudio      = m.plan_estudio
    where ah.abierto         = 'S'
    and
    --Incluye materias con requisitos autorizados
    (mp.aprobada is null or mp.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and mp.codigo_estudiante = p_codigo
    and ah.anio              = p_anio
    and ah.ciclo             = p_ciclo
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
		--inner join b_estudiantes e on p.codigo_estudiante = e.codigo and m.plan_estudio=e.plan_estudio
	where h.abierto ='S' and
    --Incluye materias con requisitos autorizados
    (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo_materia    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo_materia in
		(select cj.materia
		from a_cambio_jornada cj
		where cj.codigo             =p.codigo_estudiante
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and
        --Incluye materias con requisitos autorizados
        (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
        and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
    --FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
	union
	select m1.codigo,
		to_number(m1.semestre) sem,
		m1.creditos,
		m1.intensidad_horaria,
		m1.nombre,
		h.consecutivo,
		1 postgradual
	from a_materias_pendientes p
	inner join a_materias_integradas i
	on (p.codigo_materia = i.codigo_materia and p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad)
	inner join a_materias m1
	on (p.codigo_materia=m1.codigo
        and p.codigo_facultad = m1.codigo_facultad
        and p.jornada_facultad = m1.jornada_facultad
        and p.plan_estudio =m1.plan_estudio)
	inner join postgrado.a_materias m2
	on (i.materia_equivalente =m2.codigo and i.facultad_equivalente=m2.codigo_facultad and i.jornada_equivalente =m2.jornada_facultad)
	inner join postgrado.a_horario_horizontal h
	on (m2.codigo   = h.codigo_materia and m2.codigo_facultad =h.codigo_facultad and m2.jornada_facultad =h.jornada_facultad)
	where h.abierto ='S' and
    --Incluye materias con requisitos autorizados
    (p.aprobada is null or p.codigo_materia in (select ra.materia_plan from a_requisitos_autorizados ra where ra.codigo_estudiante = p_codigo and ra.anio = p_anio and ra.ciclo = p_ciclo))
    and p.codigo_estudiante =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	order by sem,
		codigo,
		consecutivo;
when 6 then
	open v_oferta for select mp.codigo,
        to_number(mp.semestre) sem,
        mp.creditos,
        mp.intensidad_horaria,
        mp.nombre,
        ah.consecutivo,
        0 postgradual
    from b_estudiantes e
    inner join a_materias mp
    on  e.codigo_facultad  = mp.codigo_facultad
    and e.jornada_facultad = mp.jornada_facultad
    inner join a_horario_horizontal ah
    on  mp.codigo    = ah.codigo_materia
    where ah.abierto = 'S'
    and ah.anio      = p_anio
    and ah.ciclo     = p_ciclo
    and e.codigo     = p_codigo
	/*AND mp.plan_estudio IN
	(SELECT MAX(m1.plan_estudio)
	FROM a_materias m1
	WHERE m1.codigo_facultad=e.codigo_facultad  AND m1.jornada_facultad = e.jornada_facultad
	)*/
	union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from b_estudiantes e
	inner join a_materias p
	on e.codigo_facultad = p.codigo_facultad and e.jornada_facultad = p.jornada_facultad
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo = i.codigo_materia and i.jornada_equivalente = p.jornada_facultad)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where h.abierto ='S' and e.codigo =p_codigo
		/*AND p.plan_estudio    IN
		(SELECT MAX(m1.plan_estudio)
		FROM a_materias m1
		WHERE m1.codigo_facultad=e.codigo_facultad    AND m1.jornada_facultad = e.jornada_facultad
		)*/
	and h.anio =p_anio and h.ciclo =p_ciclo
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select m.codigo,
		to_number(m.semestre) sem,
		m.creditos,
		m.intensidad_horaria,
		m.nombre,
		h.consecutivo,
		0 postgradual
	from b_estudiantes e
	inner join a_materias p
	on e.codigo_facultad = p.codigo_facultad and e.jornada_facultad = p.jornada_facultad
	inner join a_materias_integradas i
	on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo = i.codigo_materia)
	inner join a_horario_horizontal h
	on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
	inner join a_materias m
	on (p.codigo    = m.codigo and i.codigo_facultad = m.codigo_facultad and i.jornada_facultad = m.jornada_facultad)
	where p.codigo in
		(select cj.materia from a_cambio_jornada cj where cj.codigo =e.codigo
		) and i.jornada_equivalente = decode(p.jornada_facultad,'D','N','N','D') and h.abierto ='S' and e.codigo =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	--FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD (antes FL411)
    and i.codigo_materia || i.materia_equivalente not in (
        select distinct ami.codigo_materia || ami.materia_equivalente from
        a_materias am inner join a_materias_integradas ami on am.codigo = ami.codigo_materia and am.codigo_facultad = ami.codigo_facultad and am.jornada_facultad = ami.jornada_facultad
        where
        am.codigo = m.codigo
        and am.codigo in ('FL130','FLR04','FLR21','FLA04','F1130')
        and
        ((not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente not in ('FL420'))
        or (exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=p_codigo and bph.materia_cursar in ('FL411','FL420') and nvl(bph.total_fallas,0) <= 8 and bph.definitiva_depurada >= 3)
        and ami.materia_equivalente in ('FL420'))
        )
    )
    --FIN FORZAR LA MATERIA FL420: JESÚS DE NAZARET: MAESTRO DE HUMANIDAD
    union
	select p.codigo,
		to_number(p.semestre) sem,
		p.creditos,
		p.intensidad_horaria,
		p.nombre,
		h.consecutivo,
		1 postgradual
	from b_estudiantes e
	inner join a_materias p
	on (e.codigo_facultad = p.codigo_facultad and e.jornada_facultad = p.jornada_facultad)
	inner join a_materias_integradas i
	on (i.codigo_materia = p.codigo and i.codigo_facultad = p.codigo_facultad and i.jornada_facultad = p.jornada_facultad)
	inner join postgrado.a_materias m
	on (i.materia_equivalente = m.codigo and i.facultad_equivalente = m.codigo_facultad and i.jornada_equivalente = m.jornada_facultad)
	inner join postgrado.a_horario_horizontal h
	on (m.codigo    = h.codigo_materia and m.codigo_facultad = h.codigo_facultad and m.jornada_facultad = h.jornada_facultad)
	where h.abierto ='S' and e.codigo =p_codigo and h.anio =p_anio and h.ciclo =p_ciclo
	order by sem,
		codigo,
		consecutivo;
else
	v_opcion_no_valida := 1;
end case;
if v_opcion_no_valida > 0 then
	htp.prn('{"exception":"Opcion no permitida"}');
else
	--htp.prn('[{');
	htp.prn('{' || '"codFacultad":"' || v_cod_facu || '",' || '"nombreFacultad":"' || trim(v_facu) || '",' || '"jornadaFacultad":"' || v_jornada_facu || '"');
	loop
		fetch v_oferta
		into v_cod_mate,
			v_semestre,
			v_creditos,
			v_ihoraria,
			v_materia,
			v_consecutivo,
			v_post;
		exit
	when v_oferta%notfound;
		if v_al_menos_uno = 0 then
			htp.prn(',"materias":[');
		end if;
		v_al_menos_uno       := 1;
		if v_cod_mate        <> v_cod_mate_act then
			if v_oferta%rowcount = 1 then
				htp.prn('{');
			else
				htp.prn(']},{');
			end if;
			htp.prn('"codMateria":"' || v_cod_mate || '",' || '"semestre":' || v_semestre || ',' || '"creditos":' || v_creditos || ',' || '"intencidadHoraria":' || v_ihoraria || ',' || '"nombreMateria":"' || pkg_prematricula.f_acentos(v_materia) || '",' || '"grupos":[');
			v_cod_mate_act := v_cod_mate;
		else
			htp.prn(',');
		end if;
		pkg_prematricula.grupo_json(v_consecutivo, 1);
		if p_soferta = 1 then
			consecutivos.extend;
			consecutivos(v_n) := v_consecutivo;
			v_n               := v_n + 1;
		end if;
	end loop;
if v_al_menos_uno > 0 then
	htp.prn(']}]');
end if;
htp.prn('}');
end if;
close v_oferta;
exception
when others then
	htp.prn('{"exception":"' || pkg_utils.acentos(sqlerrm) || '"}');
end oferta_academica;


-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTIENE MATERIAS, HORARIO, NOTAS Y FALLAS DE PREMATRICULA.
-- ****************************************************************************************************************************
    PROCEDURE PREMATRICULA (
        P_CODIGO   		VARCHAR2,
        P_ANIO     		VARCHAR2,
		P_CICLO    		VARCHAR2,
        P_TIPO     		NUMBER DEFAULT 0,
		P_MOSTRAR_NOTAS NUMBER DEFAULT 0
    ) AS

        TYPE T_OFERTA IS REF CURSOR;
        TYPE CUR_TYP IS REF CURSOR;
		-- JSON VARIABLES.
        V_CODIGO_CONTRARIO       VARCHAR2(50);
        V_JSON_BODY              JSON;
        V_JSON_MATERIAS          JSON_LIST;
        V_JSON_MATERIA           JSON;
		V_JSON_NOTAS_FALLAS		 JSON;
        V_JSON_GRUPOS          	 JSON_LIST;
		V_JSON_GRUPO			 JSON;
        V_OFERTA                 T_OFERTA;
		V_OPCION_NO_VALIDA       NUMBER DEFAULT 0;
        V_COD_MATE               VARCHAR2(8);
        V_SEMESTRE               NUMBER;
        V_CREDITOS         		 NUMBER;
		V_IHORARIA               NUMBER;
		V_MATERIA          		 VARCHAR2(256);
		V_CONSECUTIVO            NUMBER;
        V_POST                   NUMBER;
		V_PROPIA                 NUMBER;
		V_COD_MATE_ACT           VARCHAR2(8) DEFAULT 'X';
        V_COD_FACU               VARCHAR2(8);
		V_FACU                   VARCHAR2(256);
        V_JORNADA_FACU           VARCHAR2(4);
		V_SEDE                   VARCHAR2(68);
        V_AL_MENOS_UNO           NUMBER DEFAULT 0;
        V_ISPOSTGRADO            NUMBER DEFAULT 0;
		V_ISCANCELADO            VARCHAR2(2) DEFAULT NULL;
        V_INDPAGO                VARCHAR2(2) DEFAULT NULL;
		V_COD_EST          		 VARCHAR2(8);
        V_ANIO                   VARCHAR2 (4);
        V_CICLO                  VARCHAR2(2);
        V_ESQUEMA                VARCHAR2(32);
		V_SELECT_FILLED 		 VARCHAR2 (4000);
        V_SELECT                 VARCHAR2(4000);
        V_NOTA_UNICA             NUMBER DEFAULT 0;
		V_PREMATRICULA_DEP       NUMBER DEFAULT 0;
        V_DEFINITIVA			 NUMBER(3, 1);
        V_NOTA_PRIMER_CORTE      NUMBER(3, 1);
        V_NOTA_SEGUNDO_CORTE     NUMBER(3, 1);
        V_NOTA_TERCER_CORTE      NUMBER(3, 1);
        V_FALLAS_PRIMER_CORTE    NUMBER(3, 1);
        V_FALLAS_SEGUNDO_CORTE   NUMBER(3, 1);
		V_FALLAS_TERCER_CORTE    NUMBER(3,1);
		V_FALLAS_TOTALES	     NUMBER(3,1);
        V_COLUMNA_VALIDA         NUMBER;
		V_ENC_PLAN_ESTRA		 NUMBER;
        C                        CUR_TYP;
    BEGIN
        V_JSON_BODY := JSON();
        V_JSON_MATERIAS := JSON_LIST();
		
		-- SE VERIFICA SI EL CODIGO DEL ESTUDIANTE ACTUAL CORRESPONDE A UN PROGRAMA DE PREGRADO, POSGRADO O YOPAL (PREGRADO POR DEFECTO).
        IF SUBSTR(P_CODIGO, 0, 2) >= '71' THEN
			-- POSTGRADO.
            V_ISPOSTGRADO := 1;
        ELSIF SUBSTR(P_CODIGO, 0, 2) IN (
            '46'
        ) THEN
			-- YOPAL.
            V_ISPOSTGRADO := 2;
		END IF;
		
        SELECT NVL(B_PREMATRICULA_SPRING.F_GET_CODIGO_CONTRARIO(P_CODIGO, P_ANIO, P_CICLO), 'abcdefgh')
        INTO V_CODIGO_CONTRARIO
        FROM DUAL;
        
		--SI ES PREGRADO.
		---------------------------------------------------------------------------------------------------------------------------------
        IF (V_ISPOSTGRADO = 0) THEN
            SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
            INTO        V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
            FROM 		B_ESTUDIANTES E
			INNER JOIN  A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
                                       AND E.JORNADA_FACULTAD = F.JORNADA 
            WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR 
				-- ADMISIONES: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN (P.FACULTAD_CURSAR >= '71') THEN
									1 
								ELSE 
									0
							END POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM		B_ESTUDIANTES E
				INNER JOIN 	B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                             AND E.ANIO   = P.ANIO
                                             AND E.CICLO  = P.CICLO 
				INNER JOIN 	A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
										 AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
										 AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
				WHERE 			E.CODIGO = P_CODIGO
                            AND E.ANIO   = P_ANIO
                            AND E.CICLO  = P_CICLO
							
				UNION
             
				-- ADMISIONES: INFORMACION ESTUDIANTE CODIGO ALTERNO (DOBLOE PROGRAMA).
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
                            M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN P.FACULTAD_CURSAR >= '71' THEN
									1
								ELSE
									 0
							END POSTGRADUAL,
							0 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM		B_ESTUDIANTES E
				INNER JOIN 	B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE
                                             AND E.ANIO  = P.ANIO
                                             AND E.CICLO = P.CICLO 
				INNER JOIN 	A_MATERIAS M ON M.CODIGO            = P.MATERIA_PLAN
                                         AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                         AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
				WHERE   		E.CODIGO = V_CODIGO_CONTRARIO
							AND E.ANIO   = P_ANIO
							AND E.CICLO  = P_CICLO
							
				UNION
				
				-- CACTUAL: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN P.FACULTAD_CURSAR >= '71' THEN
									1
								ELSE
									0
							END POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM		ADMISIONES.B_ESTUDIANTES E
				INNER JOIN  CACTUALPRE.B_PREMATRICULA   P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                                          AND E.ANIO   = P.ANIO
                                                          AND E.CICLO  = P.CICLO 
				INNER JOIN 	A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
                                         AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                         AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD 
                WHERE 			E.CODIGO = P_CODIGO
							AND E.ANIO   = P_ANIO
							AND E.CICLO  = P_CICLO
							
				UNION
				
				-- CACTUAL: INFORMACION ESTUDIANTE CODIGO ALTERNO (DOBLE PROGRAMA).
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							P.ID_CURSO,
							CASE
								WHEN P.FACULTAD_CURSAR >= '71' THEN
									1
								ELSE
									0
							END POSTGRADUAL,
							0 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM 		ADMISIONES.B_ESTUDIANTES E
				INNER JOIN  CACTUALPRE.B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                                        AND E.ANIO   = P.ANIO
														AND E.CICLO  = P.CICLO
				INNER JOIN A_MATERIAS M ON M.CODIGO = P.MATERIA_PLAN
										AND M.CODIGO_FACULTAD = E.CODIGO_FACULTAD
										AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
				WHERE 			E.CODIGO = V_CODIGO_CONTRARIO
							AND E.ANIO 	 = P_ANIO
                            AND E.CICLO  = P_CICLO
                ORDER BY 1;

		--SI ES POSTGRADO
		---------------------------------------------------------------------------------------------------------------------------------
        ELSIF (V_ISPOSTGRADO = 1) THEN
			SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
			INTO 		V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
			FROM 		POSTGRADO.B_ESTUDIANTES E
			INNER JOIN  A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
									   AND E.JORNADA_FACULTAD = F.JORNADA
			WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR			
				-- POSTGRADO: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							NVL((
								SELECT		TO_NUMBER(HH.CONSECUTIVO)
								FROM		POSTGRADO.A_HORARIO_HORIZONTAL HH
								WHERE       	HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
							), 0) ID_CURSO,
							0 POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
						   P.INDICADOR_PAGO,
						   E.CODIGO
				FROM       POSTGRADO.B_ESTUDIANTES E
				INNER JOIN POSTGRADO.B_PREMATRICULA P ON E.CODIGO = P.CODIGO_ESTUDIANTE
                                                       AND E.ANIO  = P.ANIO
                                                       AND E.CICLO = P.CICLO 
                INNER JOIN POSTGRADO.A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
                                                  AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                                  AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
                                                  AND (	  M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
													  OR (	 E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME')
											             AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO))) 
				WHERE 			E.CODIGO = P_CODIGO
                            AND E.ANIO   = P_ANIO
                            AND E.CICLO  = P_CICLO
                UNION
                
                -- TIENE EN CUENTA LAS MATERIAS DE LA BOLSA DE CREDITOS ELECTIVOS.
                SELECT     M.CODIGO,
						   TO_NUMBER(M.SEMESTRE) SEM,
						   M.CREDITOS,
						   M.INTENSIDAD_HORARIA,
						   M.NOMBRE,
						   NVL((
								SELECT		TO_NUMBER(HH.CONSECUTIVO)
								FROM		POSTGRADO.A_HORARIO_HORIZONTAL HH
								WHERE       	HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
                           ), 0) ID_CURSO,
						   0 POSTGRADUAL,
						   1 PROPIA,
						   P.INDICADOR_REGLAMENTO,
						   P.INDICADOR_PAGO,
						   E.CODIGO
                FROM       POSTGRADO.B_ESTUDIANTES E 
                INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
				INNER JOIN POSTGRADO.B_PREMATRICULA P ON     E.CODIGO = P.CODIGO_ESTUDIANTE
                                                         AND E.ANIO  = P.ANIO
                                                         AND E.CICLO = P.CICLO 
                INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON     BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                                                              AND BEM.CODIGO_MATERIA   = P.MATERIA_CURSAR
                                                              AND BEM.CODIGO_FACULTAD  = P.FACULTAD_CURSAR
                                                              AND BEM.JORNADA_FACULTAD = P.JORNADA_FACULTAD
                -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = BEM.CODIGO_MATERIA
                                                     AND M.PLAN_ESTUDIO     = BEM.PLAN_ESTUDIO
                                                     AND M.CODIGO_FACULTAD  = BEM.CODIGO_FACULTAD
                                                     AND M.JORNADA_FACULTAD = BEM.JORNADA_FACULTAD
                WHERE      E.CODIGO = P_CODIGO
                
				UNION
				
				-- CACTUALPOS: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							NVL((
								 SELECT 	TO_NUMBER(HH.CONSECUTIVO)
								 FROM 		CACTUALPOS.A_HORARIO_HORIZONTAL HH
								 WHERE 			HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
							), 0) ID_CURSO,
							0 POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM 		POSTGRADO.B_ESTUDIANTES E
				INNER JOIN 	CACTUALPOS.B_PREMATRICULA P ON 	E.CODIGO = P.CODIGO_ESTUDIANTE
					                                    AND E.ANIO   = P.ANIO
														AND E.CICLO  = P.CICLO 
				INNER JOIN 	POSTGRADO.A_MATERIAS M ON M.CODIGO = P.MATERIA_PLAN
                                                   AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
												   AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
												   AND (  M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
                                                       OR (   E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME')
													      AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)))
				WHERE 		    E.CODIGO = P_CODIGO
							AND E.ANIO = P_ANIO
							AND E.CICLO = P_CICLO
				ORDER BY 	1;

		--SI ES YOPAL
		---------------------------------------------------------------------------------------------------------------------------------
		ELSIF V_ISPOSTGRADO = 2 THEN
            SELECT 		F.CODIGO,
						F.NOMBRE,
						F.JORNADA,
						F.SEDE
            INTO 		V_COD_FACU,
						V_FACU,
						V_JORNADA_FACU,
						V_SEDE
            FROM 		YOPAL.B_ESTUDIANTES   E
			INNER JOIN 	A_FACULTADES F ON  E.CODIGO_FACULTAD  = F.CODIGO
                                       AND E.JORNADA_FACULTAD = F.JORNADA
            WHERE 		E.CODIGO = P_CODIGO;

            OPEN V_OFERTA FOR 
				-- YOPAL: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 		M.CODIGO,
							TO_NUMBER(M.SEMESTRE) SEM,
							M.CREDITOS,
							M.INTENSIDAD_HORARIA,
							M.NOMBRE,
							NVL((
								SELECT 		TO_NUMBER(HH.CONSECUTIVO)
								FROM 		YOPAL.A_HORARIO_HORIZONTAL HH
								WHERE 		    HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
											AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
											AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
											AND HH.ANIO                     = P.ANIO
											AND HH.CICLO                    = P.CICLO
							), 0) ID_CURSO,
							0 POSTGRADUAL,
							1 PROPIA,
							P.INDICADOR_REGLAMENTO,
							P.INDICADOR_PAGO,
							E.CODIGO
				FROM 		YOPAL.B_ESTUDIANTES E
				INNER JOIN YOPAL.B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
                                                  AND E.ANIO   = P.ANIO
                                                  AND E.CICLO  = P.CICLO
				INNER JOIN YOPAL.A_MATERIAS M ON  M.CODIGO = P.MATERIA_PLAN
                                              AND M.CODIGO_FACULTAD = E.CODIGO_FACULTAD
											  AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
											  AND (   M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
											      OR (   E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME') 
												     AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)))
				 WHERE 		    E.CODIGO = P_CODIGO
							AND E.ANIO = P_ANIO
							AND E.CICLO = P_CICLO
							
                             UNION
							 
				-- CACTUALYOP: INFORMACION ESTUDIANTE ACTUAL.
				SELECT 			M.CODIGO,
                                TO_NUMBER(M.SEMESTRE) SEM,
								M.CREDITOS,
								M.INTENSIDAD_HORARIA,
								M.NOMBRE,
								NVL((
									SELECT 		TO_NUMBER(HH.CONSECUTIVO)
									FROM 		CACTUALYOP.A_HORARIO_HORIZONTAL HH
									WHERE 		    HH.CODIGO_FACULTAD          = P.FACULTAD_CURSAR
												AND HH.CODIGO_MATERIA           = P.MATERIA_CURSAR
												AND TO_NUMBER(HH.GRUPO_MATERIA) = TO_NUMBER(P.GRUPO)
												AND HH.ANIO                     = P.ANIO
												AND HH.CICLO                    = P.CICLO
                                ), 0) ID_CURSO,
                                0 POSTGRADUAL,
                                1 PROPIA,
                                P.INDICADOR_REGLAMENTO,
                                P.INDICADOR_PAGO,
                                E.CODIGO
				FROM 			YOPAL.B_ESTUDIANTES E
				INNER JOIN 		CACTUALYOP.B_PREMATRICULA P ON  E.CODIGO = P.CODIGO_ESTUDIANTE
															AND E.ANIO   = P.ANIO
															AND E.CICLO  = P.CICLO
				INNER JOIN 		YOPAL.A_MATERIAS M ON  M.CODIGO           = P.MATERIA_PLAN
                                                   AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                                   AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
                                                   AND (  M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
												       OR (   E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME')
													      AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO)))
				WHERE               E.CODIGO = P_CODIGO
								AND E.ANIO = P_ANIO
								AND E.CICLO = P_CICLO
				ORDER BY 		1;
        END IF;

        JSON.PUT(V_JSON_BODY, 'codFacultad', V_COD_FACU);
        JSON.PUT(V_JSON_BODY, 'nombreFacultad', TRIM(V_FACU));
        JSON.PUT(V_JSON_BODY, 'jornadaFacultad', V_JORNADA_FACU);
        LOOP
            FETCH V_OFERTA INTO
                V_COD_MATE,
                V_SEMESTRE,
                V_CREDITOS,
                V_IHORARIA,
                V_MATERIA,
                V_CONSECUTIVO,
                V_POST,
                V_PROPIA,
                V_ISCANCELADO,
                V_INDPAGO,
                V_COD_EST;

            EXIT WHEN V_OFERTA%NOTFOUND;
            IF ( V_COD_MATE <> V_COD_MATE_ACT ) THEN
                V_JSON_MATERIA := JSON();
				V_JSON_GRUPOS := JSON_LIST();
                JSON.PUT(V_JSON_MATERIA, 'codMateria', V_COD_MATE);
                JSON.PUT(V_JSON_MATERIA, 'semestre', V_SEMESTRE);
                JSON.PUT(V_JSON_MATERIA, 'creditos', V_CREDITOS);
                JSON.PUT(V_JSON_MATERIA, 'intencidadHoraria', V_IHORARIA);
                JSON.PUT(V_JSON_MATERIA, 'post', V_POST);
                JSON.PUT(V_JSON_MATERIA, 'propia', V_PROPIA);
                --JSON.PUT(V_JSON_MATERIA, 'nombreMateria', PKG_PREMATRICULA.F_ACENTOS(V_MATERIA));
                JSON.PUT(V_JSON_MATERIA, 'nombreMateria', V_MATERIA);
                IF ( V_ISCANCELADO IS NOT NULL ) THEN
                    JSON.PUT(V_JSON_MATERIA, 'cancelado', '1');
                END IF;

                JSON.PUT(V_JSON_MATERIA, 'indicador', V_INDPAGO);
				
				SELECT COUNT(*)
				INTO V_ENC_PLAN_ESTRA
				FROM SIE.SIE_VW_ENCU_AUTO_PRE_SALL_ESTU@UVIRTUAL.LASALLE.EDU.CO
				WHERE CODIGO = P_CODIGO AND CONTESTO = 'NO';
  
				IF(P_MOSTRAR_NOTAS <> 0 AND V_ENC_PLAN_ESTRA = 0) THEN
					BEGIN
						V_SELECT_FILLED := '';
						-- SE OBTIENE EL AÑO, CICLO Y ESQUECA ACTUAL DE ACUERDO AL TIPO DE PROGRAMA.
						--SI ES PREGRADO
						IF (V_ISPOSTGRADO = 0) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(1, V_ANIO, V_CICLO, V_ESQUEMA);
						--SI ES POSTGRADO
						ELSIF (V_ISPOSTGRADO = 1) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(2, V_ANIO, V_CICLO, V_ESQUEMA);
						--SI ES YOPAL
						ELSIF (V_ISPOSTGRADO = 2) THEN
							PKG_UTILS.GETANIOCICLOESQUEMA(3, V_ANIO, V_CICLO, V_ESQUEMA);
						END IF;
					
						-- SE VERIFICA SI EXISTE LA TABLA 'B_PREMATRICULA_NOTAS_DEPURADA' EN EL ESQUEMA ACTUAL.
						SELECT 	COUNT(*)
						INTO 	V_PREMATRICULA_DEP
						FROM 	ALL_TABLES
						WHERE 		LOWER(OWNER) = LOWER(V_ESQUEMA)
								AND TABLE_NAME LIKE 'B_PREMATRICULA_NOTAS_DEPURADA';
					 
						-- SI EXISTE LA TABLA, SE EMPIEZA A CREAR EL QUERY DINAMICO.
	
						IF ( V_PREMATRICULA_DEP > 0 ) THEN
							V_SELECT_FILLED := V_SELECT_FILLED || '						
									SELECT 					
							';
							-- SE VERIFICA QUE EXISTA CADA UNA DE LAS COLUMAS PARA EL QUERY.
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'DEFINITIVA_DEPURADA';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(DEFINITIVA_DEPURADA, NVL(DEFINITIVA, 0)) DEFINITIVA, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(DEFINITIVA, 0) DEFINITIVA, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'PRIMER_PARCIAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(PRIMER_PARCIAL, 0) PRIMER_PARCIAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 PRIMER_PARCIAL, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'SEGUNDO_PARCIAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || '  NVL(SEGUNDO_PARCIAL, 0) SEGUNDO_PARCIAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 SEGUNDO_PARCIAL, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'EXAMEN_FINAL';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(EXAMEN_FINAL, 0) EXAMEN_FINAL, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 EXAMEN_FINAL, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_PRIMER_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(FALLAS_PRIMER_CORTE, 0) FALLAS_PRIMER_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_PRIMER_CORTE, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_SEGUNDO_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || 'NVL(FALLAS_SEGUNDO_CORTE, 0) FALLAS_SEGUNDO_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_SEGUNDO_CORTE, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'FALLAS_TERCER_CORTE';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(FALLAS_TERCER_CORTE, 0) FALLAS_TERCER_CORTE, ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 FALLAS_TERCER_CORTE, ';
							END IF;
							
							SELECT COUNT(*) INTO V_COLUMNA_VALIDA FROM ALL_TAB_COLUMNS WHERE LOWER(OWNER) = LOWER(V_ESQUEMA) AND TABLE_NAME = 'B_PREMATRICULA_NOTAS_DEPURADA' AND COLUMN_NAME = 'TOTAL_FALLAS';
							IF (V_COLUMNA_VALIDA > 0) THEN V_SELECT_FILLED := V_SELECT_FILLED || ' NVL(TOTAL_FALLAS, 0) TOTAL_FALLAS ';
							ELSE V_SELECT_FILLED := V_SELECT_FILLED || ' 0 TOTAL_FALLAS ';
							END IF;
							
							V_SELECT_FILLED := V_SELECT_FILLED || '	
									FROM 	' || V_ESQUEMA || '.B_PREMATRICULA_NOTAS_DEPURADA
									WHERE 	CODIGO_ESTUDIANTE = ''' || V_COD_EST ||''' AND
											MATERIA_PLAN = ''' || V_COD_MATE || ''' AND
											ANIO = ''' || V_ANIO || ''' AND
											CICLO = ''' || V_CICLO || '''		
							';
								
							V_SELECT := '
								SELECT  MAX(DEFINITIVA),
										MAX(PRIMER_PARCIAL),
										MAX(SEGUNDO_PARCIAL),
										MAX(EXAMEN_FINAL),
										MAX(FALLAS_PRIMER_CORTE),
										MAX(FALLAS_SEGUNDO_CORTE),
										MAX(FALLAS_TERCER_CORTE),
										MAX(TOTAL_FALLAS)
								FROM	(
											{0}
										) A
							';
							
							V_SELECT := REPLACE(V_SELECT, '{0}', V_SELECT_FILLED);
								
							SELECT 	COUNT(INDICADOR_CIERRE)
							INTO	V_NOTA_UNICA
							FROM	(
										SELECT 	INDICADOR_CIERRE
										FROM 	ADMISIONES.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
										UNION ALL
										SELECT 	INDICADOR_CIERRE
										FROM 	POSTGRADO.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
										UNION ALL
										SELECT 	INDICADOR_CIERRE
										FROM 	YOPAL.AH_HORIZONTAL_ACTUAL
										WHERE 		CODIGO_FACULTAD  = V_COD_FACU
												AND JORNADA_FACULTAD = V_JORNADA_FACU
												AND CODIGO_MATERIA 	 = V_COD_MATE
									) A
							WHERE	TRIM(INDICADOR_CIERRE) = 'NU';
												
							OPEN C FOR V_SELECT;	
							LOOP
								FETCH C INTO 	V_DEFINITIVA,
												V_NOTA_PRIMER_CORTE,
												V_NOTA_SEGUNDO_CORTE,
												V_NOTA_TERCER_CORTE,
												V_FALLAS_PRIMER_CORTE,
												V_FALLAS_SEGUNDO_CORTE,
												V_FALLAS_TERCER_CORTE,
												V_FALLAS_TOTALES;
								EXIT WHEN C%NOTFOUND;
								--SI ES NOTA UNICA.
								IF (V_NOTA_UNICA > 0 OR V_ISPOSTGRADO = 1) THEN
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'definitiva', V_DEFINITIVA);
									JSON.PUT(V_JSON_MATERIA, 'notas', V_JSON_NOTAS_FALLAS);
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'fallasTotales', V_FALLAS_TOTALES);
									IF (V_FALLAS_TOTALES > (V_IHORARIA * 16 * 0.25)) THEN
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '1');
									ELSE
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '0');
									END IF;
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
								--SI TIENE NOTAS PARCIALES.
								ELSE
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'definitiva', V_DEFINITIVA);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'primerCorte', V_NOTA_PRIMER_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'segundoCorte', V_NOTA_SEGUNDO_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'tercerCorte', V_NOTA_TERCER_CORTE);
									JSON.PUT(V_JSON_MATERIA, 'notas', V_JSON_NOTAS_FALLAS);
									V_JSON_NOTAS_FALLAS := JSON();
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'fallasTotales', V_FALLAS_TOTALES);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'primerCorte', V_FALLAS_PRIMER_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'segundoCorte', V_FALLAS_SEGUNDO_CORTE);
									JSON.PUT(V_JSON_NOTAS_FALLAS, 'tercerCorte', V_FALLAS_TERCER_CORTE);
									IF (V_FALLAS_TOTALES > (V_IHORARIA * 16 * 0.25)) THEN
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '1');
									ELSE
										JSON.PUT(V_JSON_NOTAS_FALLAS, 'perdidaPorFallas', '0');
									END IF;
									JSON.PUT(V_JSON_MATERIA, 'fallas', V_JSON_NOTAS_FALLAS);
								END IF;
							END LOOP;
							CLOSE C;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							JSON.PUT(V_JSON_BODY, 'exception',  SQLCODE || ' --- ' || SUBSTR(SQLERRM, 1, 200));
							V_SELECT := '';
					END;
				END IF;
                V_COD_MATE_ACT := V_COD_MATE;
            END IF;
            
            IF (V_ISPOSTGRADO <> 2) THEN
                IF 	  (V_PROPIA = 1 AND V_POST = 0)                  THEN PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 1);
                ELSIF (V_PROPIA = 1 AND P_TIPO = 777 AND V_POST = 1) THEN PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, -1);
                ELSE                                                      PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 0);
				END IF;
            ELSE
                IF (V_PROPIA = 1 AND V_POST = 0) 			         THEN PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 1, 1);
                ELSIF (V_PROPIA = 1 AND P_TIPO = 777 AND V_POST = 1) THEN PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, -1, 1);
                ELSE 													  PKG_PREMATRICULA.GRUPO_JSON_OBJECT(V_JSON_GRUPO, V_CONSECUTIVO, 0, 1);
                END IF;
            END IF;

            JSON_LIST.APPEND(V_JSON_GRUPOS, V_JSON_GRUPO.TO_JSON_VALUE);
			JSON.PUT(V_JSON_MATERIA, 'grupos', V_JSON_GRUPOS);
            JSON_LIST.APPEND(V_JSON_MATERIAS, V_JSON_MATERIA.TO_JSON_VALUE);
        END LOOP;
        CLOSE V_OFERTA;
        JSON.PUT(V_JSON_BODY, 'materias', V_JSON_MATERIAS);
        JSON.HTP(V_JSON_BODY);
    EXCEPTION
        WHEN OTHERS THEN
			JSON.PUT(V_JSON_BODY, 'exception',  SQLCODE || ' --- ' || SUBSTR(SQLERRM, 1, 200));
			JSON.HTP(V_JSON_BODY);
    END PREMATRICULA;

procedure usuario(
		p_codigo   varchar2,
		p_facultad varchar2 default '-NA-',
		p_anio     varchar2,
		p_ciclo    varchar2 )
as
	v_es_ser_pilo_paga number;
	v_vacio            number default 0;
    v_sem_inf number;
    v_crd_max number;
    v_crd_ins number;
    v_periodos_ra number;
    v_auth_cred_add number;
    V_SUSPENDIDO NUMBER;
    V_AUTORIZADO NUMBER;
begin
	if p_facultad = '-NA-' then
		for usuario in
		(select      *
		from table(b_prematricula_spring.f_get_usuario_con_turno(p_codigo, p_anio, p_ciclo))
		)
		loop
            --BUG: Se colo este estudiante suspendido 70041053.
            select count(*)
            into v_suspendido
            from a_periodo_prueba pp
            where pp.codigo_estudiante = p_codigo and pp.indicador >= 3;
            SELECT COUNT(*)
            INTO   V_AUTORIZADO--mariano rua mejia 01/02/2019 casos autorizaciones de programas a estudiantes con retiro definitivo
            FROM   AUTORIZACIONES_SUSPENSION T
            WHERE  T.CODIGO_ESTUDIANTE = p_codigo;
            if v_suspendido > 0 AND V_AUTORIZADO=0 then
                raise_application_error(-20000,'Estudiante suspendido.');
            end if;
			v_vacio := 1;
			htp.prn('{');
			htp.prn('"codigo":"' || usuario.codigo || '",');
			htp.prn('"perfil":"' || usuario.perfil || '",');
			htp.prn('"nombes":"' || pkg_prematricula.f_acentos(usuario.nombres) || '",');
			htp.prn('"apellidos":"' || pkg_prematricula.f_acentos(usuario.apellidos) || '",');
			htp.prn('"correo":"' || usuario.correo || '",');
			htp.prn('"semestreInferior":' || usuario.semestre_inferior || ',');
			htp.prn('"creditosMax":' || usuario.creditos_max || ',');
			htp.prn('"creditosExtra":' || usuario.creditos_extra || ',');
			htp.prn('"turno":' || usuario.turno || ',');
			htp.prn('"planEstudio":' || usuario.plan_estudios || ',');
			if usuario.codigo_contrario is not null then
				htp.prn('"codigoContrario":"' || usuario.codigo_contrario || '",');
			end if;
			if usuario.referente is not null then
				htp.prn('"referente":"' || usuario.referente || '",');
			end if;
            if usuario.perfil in ('RA') then
                htp.prn('"ausencia":' || pkg_utils.ciclosDespuesDeFinMateriasRA(usuario.codigo) || ',');
                select count(*)
                into v_periodos_ra
                from historico_estudiantes he where
                he.codigo = usuario.codigo
                and he.indicador_pago in ('P','V')
                and he.tipo_de_ingreso in ('RA')
                and he.anio || to_number(he.ciclo) = he.ciclo_de_ingreso;
                htp.prn('"periodosRA":' || v_periodos_ra || ',');
            end if;
            htp.prn('"pilo":' || pkg_utils.esPilo(usuario.codigo) || ',');
			htp.prn('"facultad":{');
			htp.prn('"codFacultad":"' || usuario.codigo_facultad || '",');
			htp.prn('"nombreFacultad":"' || pkg_utils.acentos(trim(usuario.nombre_facultad)) || '",');
			htp.prn('"jornadaFacultad":"' || usuario.jornada_facultad || '",');
			htp.prn('"sede":{');
			htp.prn('"sede":"' || usuario.sede || '"');
			htp.prn('}}}');
		end loop;
		if v_vacio = 0 then
			htp.prn('{"exception":"Estudiante no autorizado o inexistente."}');
		end if;
	else
		for usuario in
		(select * from (
            select null codigo,
                pu.documento,
                'UA' perfil,
                pu.nombres nombres,
                pu.apellidos apellidos,
                pu.correo_institucional correo,
                0 semestre_inferior,
                0 creditos_max,
                pu.codigo_unidad_academica codigo_facultad,
                f.nombre nombre_facultad,
                'U' jornada_facultad,
                '' sede,
                '' ciclo_de_ingreso,
                '' referente,
                0 creditos_extra,
                1 turno
            from siis.vw_perfil_prematricula@uvirtual.lasalle.edu.co pu,
                admisiones.a_facultades_unica f
            where (
                case when pu.codigo_unidad_academica = 'FL' then '01' else pu.codigo_unidad_academica end) = f.codigo_facultad
            and pu.documento                      = p_codigo
            and pu.codigo_unidad_academica        = p_facultad
            and rownum                           <= 1
            --Para secretarios academicos
            union
            select null codigo,
                pu.documento,
                'UA' perfil,
                pu.nombres nombres,
                pu.apellidos apellidos,
                pu.correo_institucional correo,
                0 semestre_inferior,
                0 creditos_max,
                pu.codigo_unidad_academica codigo_facultad,
                pr.nombre nombre_facultad,
                'U' jornada_facultad,
                '' sede,
                '' ciclo_de_ingreso,
                '' referente,
                0 creditos_extra,
                1 turno
            from siis.vw_perfil_prematricula@uvirtual.lasalle.edu.co pu,
                admisiones.a_programas pr
            where pu.codigo_unidad_academica = pr.facultad
            and pu.documento                      = p_codigo
            and pu.codigo_unidad_academica        = p_facultad
            and substr(pr.codigo, 0, 1) = '0'
            and pr.facultad not in ('FL')
            and rownum <= 1
            union
            select null codigo,
                pu.documento,
                'UA' perfil,
                pu.nombres nombres,
                pu.apellidos apellidos,
                pu.correo_institucional correo,
                0 semestre_inferior,
                0 creditos_max,
                pu.codigo_unidad_academica codigo_facultad,
                (select prg2.nombre from a_programas prg2 where prg2.facultad = p_facultad and substr(prg2.codigo, 0, 1) = '0' and rownum <= 1) nombre_facultad,
                'U' jornada_facultad,
                '' sede,
                '' ciclo_de_ingreso,
                '' referente,
                0 creditos_extra,
                1 turno
            from siis.vw_perfil_prematricula@uvirtual.lasalle.edu.co pu,
                admisiones.a_facultades_unica pr
            where pu.codigo_unidad_academica = pr.codigo_facultad
            and pu.documento                      = p_codigo
            and pu.codigo_unidad_academica        in (select distinct prg.codigo from a_programas prg where prg.facultad = p_facultad)
            and pr.codigo_facultad not in ('FL')
            and rownum <= 1
            --fin secretarios
            union
            select null codigo,
                u.numero_documento,
                'UA' perfil,
                u.nombre_usuario nombres,
                '' apellidos,
                'registro@lasalle.edu.co' correo,
                0 semestre_inferior,
                0 creditos_max,
                '802' codigo_facultad,
                'Admisiones y Registro' nombre_facultad,
                'U' jornada_facultad,
                '' sede,
                '' ciclo_de_ingreso,
                '' referente,
                0 creditos_extra,
                1 turno
            from a_usuarios u
            where u.codigo in ('802')
        ) x where x.codigo_facultad = p_facultad and rownum <= 1)
		loop
			v_vacio := 1;
			htp.prn('{');
			htp.prn('"documento":"' || usuario.documento || '",');
			htp.prn('"perfil":"' || usuario.perfil || '",');
			htp.prn('"nombes":"' || pkg_prematricula.f_acentos(usuario.nombres) || '",');
			htp.prn('"apellidos":"' || pkg_prematricula.f_acentos(usuario.apellidos) || '",');
			htp.prn('"correo":"' || usuario.correo || '",');
			htp.prn('"semestreInferior":' || usuario.semestre_inferior || ',');
			htp.prn('"creditosMax":' || usuario.creditos_max || ',');
			htp.prn('"creditosExtra":' || usuario.creditos_extra || ',');
			htp.prn('"turno":' || usuario.turno || ',');
			htp.prn('"facultad":{');
			htp.prn('"codFacultad":"' || usuario.codigo_facultad || '",');
			htp.prn('"nombreFacultad":"' || pkg_utils.acentos(trim(usuario.nombre_facultad)) || '",');
			htp.prn('"jornadaFacultad":"' || usuario.jornada_facultad || '",');
			htp.prn('"sede":{');
			htp.prn('"sede":"' || usuario.sede || '"');
			htp.prn('}}}');
		end loop;
		if v_vacio = 0 then
			htp.prn('{"exception":"Usuario no autorizado o inexistente."}');
		end if;
	end if;
exception
when others then
	htp.prn('{"exception":"' || pkg_utils.acentos(sqlerrm) || '"}');
end usuario;
procedure creditosmax(
		p_codigo varchar2 )
as
	v_cod_facu varchar2(4);
	v_jor_facu varchar2(2);
	v_plan_est number;
	v_i        number default 1;
begin
	select e.codigo_facultad,
		e.jornada_facultad,
		e.plan_estudio
	into v_cod_facu,
		v_jor_facu,
		v_plan_est
	from b_estudiantes e
	where e.codigo=p_codigo;
	htp.prn('[');
	for crm in
	(select to_number(semestre) semestre,
		creditos,
		count(*) over () tot_rows
	from creditosxsemestre
	where codigo_facultad=v_cod_facu
	and jornada_facultad =v_jor_facu
	and plan_estudio     =v_plan_est
	order by semestre
	)
	loop
		htp.prn('{');
		htp.prn('"semestre":' || crm.semestre || ',');
		htp.prn('"creditos":' || crm.creditos);
		if v_i = crm.tot_rows then
			htp.prn('}');
		else
			htp.prn('},');
		end if;
		v_i := v_i + 1;
	end loop;
	htp.prn(']');
exception
when others then
	htp.prn('{"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end creditosmax;
procedure cupos(
		p_codigo in varchar2,
		p_tipo   in number default 3 )
as
	csv clob;
	n    number default 1;
	cupo number;
	v_consecs dbms_utility.uncl_array;
	ln_len binary_integer;
begin
	select oferta
	into csv
	from oferta_calculada
	where codigo=p_codigo
	and tipo    = p_tipo;
	htp.prn('[');
	csv := '"' || regexp_replace(csv, '[,]+', '","') || '"';
	dbms_utility.comma_to_table(csv, ln_len, v_consecs);
	for i in 1 .. ln_len
	loop
		begin
			select cupo - cupo_utilizado
			into cupo
			from a_horario_horizontal
			where consecutivo = to_number(regexp_replace(v_consecs(i),'["]+',''));
		exception
		when no_data_found then
			select 20
			into cupo
			from postgrado.a_horario_horizontal
			where consecutivo = to_number(regexp_replace(v_consecs(i),'["]+',''));
		end;
		if cupo > 0 then
			htp.prn('{"consecutivo":' || regexp_replace(v_consecs(i),'["]+','') || ',"cupo":' || cupo || '},');
		end if;
	end loop;
	htp.prn('{"consecutivo":1,"cupo":0}');
	htp.prn(']');
exception
when others then
	htp.prn('{"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end cupos;
procedure turno_hoy(
		p_anio varchar2 default '2014' )
as
	n       number default 1;
	v_fecha varchar2(20);
begin
    v_fecha := to_char(sysdate, 'RRRR-MM-DD');
    --v_fecha := '2018-12-03';
	htp.prn('[');
	for turno in
	(select x.codigo_estudiante,
		x.sede,
		x.tipo_oferta,
		count(*) over () tot_rows
	from
		( select distinct te.codigo_estudiante,
			f.sede,
			te.tipo_oferta
		from cti_turnos_prematricula te
		inner join b_estudiantes e
		on te.codigo_estudiante = e.codigo
		inner join a_facultades f
		on e.codigo_facultad = f.codigo
		where (to_date(v_fecha
			|| ' 18:10', 'RRRR-MM-DD HH24:MI') between te.inicio and te.fin
		or to_date(v_fecha
			|| ' 17:00', 'RRRR-MM-DD HH24:MI') between te.inicio and te.fin)
        --and e.codigo = '41161305'
        --and e.codigo_facultad in ('14')
			--te.fecha       = '20150625'--TO_CHAR(sysdate, 'RRRRMMDD')
			--where e.codigo_facultad in ('42', '45')
		order by te.codigo_estudiante desc
			/*SELECT DISTINCT e.codigo,
			f.sede
			FROM a_solicitud_reintegro te
			INNER JOIN b_estudiantes e
			ON te.codigo_estudiante = e.codigo
			INNER JOIN a_facultades f
			ON e.codigo_facultad = f.codigo
			--WHERE te.fecha       = '20141213'--TO_CHAR(sysdate, 'RRRRMMDD')
			--where e.codigo_facultad in ('42', '45')
			WHERE te.anio='2015'
			ORDER BY e.codigo DESC*/
		) x
	)
	loop
		htp.prn('{"codigo":"' || turno.codigo_estudiante || '","sede":"' || turno.sede || '","toferta":' || turno.tipo_oferta || '}');
		if n <> turno.tot_rows then
			htp.prn(',');
		end if;
		n := n + 1;
	end loop;
	htp.prn(']');
exception
when others then
	htp.prn('{"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end turno_hoy;
function f_acentos(
		texto varchar2 )
	return varchar2
is
	txt varchar2(4000);
begin
	txt := regexp_replace(texto, 'ñ', '\u00f1');
	txt := regexp_replace(txt, 'á', '\u00e1');
	txt := regexp_replace(txt, 'é', '\u00e9');
	txt := regexp_replace(txt, 'í', '\u00ed');
	txt := regexp_replace(txt, 'ó', '\u00f3');
	txt := regexp_replace(txt, 'ú', '\u00fa');
	txt := regexp_replace(txt, 'ü', '\u00fc');
	txt := regexp_replace(txt, 'Ñ', '\u00d1');
	txt := regexp_replace(txt, '�?', '\u00c1');
	txt := regexp_replace(txt, 'É', '\u00c9');
	txt := regexp_replace(txt, '�?', '\u00cd');
	txt := regexp_replace(txt, 'Ó', '\u00d3');
	txt := regexp_replace(txt, 'Ú', '\u00da');
	txt := regexp_replace(txt, 'Ü', '\u00dc');
	txt := regexp_replace(txt, '"', '\u0022');
	return(txt);
exception
when others then
	return(texto);
end f_acentos;
procedure cupo(
		p_conseutivo in number)
as
	cupo number;
begin
	select cupo - cupo_utilizado
	into cupo
	from a_horario_horizontal
	where consecutivo = p_conseutivo;
	htp.prn('{"consecutivo":' || p_conseutivo || ',"cupo":' || cupo || '}');
exception
when others then
	htp.prn('{"consecutivo":-1,"cupo":0,"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end cupo;
procedure cupos_parciales(
		p_consecutivos in varchar2)
as
	consecutivo number;
	cupo        number;
	n           number default 1;
	v_arg       varchar2(64);
begin
	htp.prn('[');
	v_arg       := regexp_substr(p_consecutivos,'[^,]+',1,n);
	while v_arg is not null
	loop
		begin
			select ah.consecutivo,
				ah.cupo - ah.cupo_utilizado
			into consecutivo,
				cupo
			from a_horario_horizontal ah
			where ah.consecutivo = to_number(v_arg);
			htp.prn('{"consecutivo":' || consecutivo || ',"cupo":' || cupo || '},');
		exception
		when no_data_found then
			select count(*)
			into consecutivo
			from postgrado.a_horario_horizontal ah
			where ah.consecutivo = to_number(v_arg);
			if consecutivo       > 0 then
				select ah.consecutivo,
					30
				into consecutivo,
					cupo
				from postgrado.a_horario_horizontal ah
				where ah.consecutivo = to_number(v_arg);
				htp.prn('{"consecutivo":' || consecutivo || ',"cupo":' || cupo || '},');
			end if;
		when others then
			htp.prn('');
		end;
		n     := n + 1;
		v_arg := regexp_substr(p_consecutivos,'[^,]+',1,n);
	end loop;
	htp.prn('{"consecutivo":0,"cupo":0}]');
exception
when others then
	htp.prn('{"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end cupos_parciales;
procedure turno(
		p_codigo in varchar2,
		p_perfil in varchar2,
		p_anio   in varchar2,
		p_ciclo  in varchar2)
as
begin
	htp.prn('{"turno":' || b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) || '}');
exception
when others then
	htp.prn('{"exception":"' || sqlcode || ' --- ' || substr(sqlerrm,1,200) || '"}');
end turno;
procedure lista_prematriculados(
		p_anio  varchar2,
		p_ciclo varchar2 )
as
begin
	htp.prn('[');
	for est in
	(select distinct codigo_estudiante codigo
	from b_prematricula
	where anio = p_anio
	and ciclo  = p_ciclo
	)
	loop
		htp.prn('{"codigo":"' || est.codigo || '"},');
	end loop;
	htp.prn('{"codigo":"end"}]');
end lista_prematriculados;
procedure liquidar(
    p_token varchar2
)
as
    v_codigo b_estudiantes.codigo%type;
    v_id_params number default 0;
    v_params a_parametros%rowtype;
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_sem_inf number;
    v_cred_max number;
    v_cred_ins number;
    v_cred_art47 number default 0;
    v_indc_art47 varchar2(1) default 'S';
begin
    owa_util.mime_header('application/json', false, 'utf-8');
    owa_util.http_header_close;
    v_codigo := pkg_utils.f_leertoken(p_token, 1/1440, '3764613438353137');
    v_id_params := pg_liquidacion_guias_v2(v_codigo);
    if v_id_params is null or v_id_params <= 0 then
        raise_application_error(-20599, 'No se logro liquidar la guia desde el SIA.');
    end if;
    select p.*
    into v_params
    from a_parametros p
    where p.id = v_id_params;
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    pkg_utils.getResumenCreditos(v_codigo, v_anio, v_ciclo, v_sem_inf, v_cred_max, v_cred_ins);
    if v_cred_ins > v_cred_max then
        if pkg_utils.aplicaArt47(v_codigo) = 1 then
            begin
                v_cred_art47 := (case when v_cred_ins - v_cred_max > 6 then 6 else v_cred_ins - v_cred_max end);
                v_indc_art47 := 'N';
                insert into cti_art47_params (id_parametro, creds_descontar, cobrar_creds_ads)
                values (v_id_params, v_cred_art47, v_indc_art47);
                commit;
            exception
            when others then
                rollback;
                raise;
            end;
        else
            update a_prematricula_autorizados set
            tope_creditos = v_cred_ins - v_cred_max,
            ind_sistemas_inicial = 'S'
            where codigo_estudiante = v_codigo
            and tope_creditos > 0
            and ind_sistemas_inicial is null;
            commit;
        end if;
    else
        update a_prematricula_autorizados set
        tope_creditos = 0,
        ind_sistemas_inicial = 'S'
        where codigo_estudiante = v_codigo
        and tope_creditos > 0
        and ind_sistemas_inicial is null
        and pkg_utils.aplicaArt47(v_codigo) <> 1;
        commit;
    end if;
    v_cred_max := v_params.totcred_sem;
    salle_guias.fixPostGridTutorialParams(v_codigo, v_params.id, v_cred_max);
    htp.prn('{');
    htp.prn('"anio":"' || v_params.anio || '",');
    htp.prn('"anioIngreso":"' || v_params.anio_ingreso || '",');
    htp.prn('"anioreintegro":"' || v_params.ciclo_de_ingreso || '",');
    htp.prn('"aplicaIndicador":"' || v_params.aplicar_concepto || '",');
    htp.prn('"cobrarRecargo":"' || v_params.recargo || '",');
    htp.prn('"cod2DoPrograma":"' || v_params.codseg_pgm || '",');
    htp.prn('"codigo":"' || v_params.codest || '",');
    htp.prn('"correoElectronico":"' || v_params.email || '",');
    htp.prn('"creditosInscritos":' || v_params.tot_creditos || ',');
    htp.prn('"creditosSemestre":' || v_cred_max || ',');
    htp.prn('"credsInscritos2DoProg":' || v_params.credinsseg_pgm || ',');
    htp.prn('"credsSemestre2DoProg":' || v_params.credsemseg_pgm || ',');
    htp.prn('"departamento":' || to_number(v_params.coddepto) || ',');
    htp.prn('"direccion":"' || pkg_utils.acentos(v_params.direccion) || '",');
    htp.prn('"fechaAjuste":"' || to_char(v_params.fecha_ajuste, 'RRRR/MM/DD') || '",');
    htp.prn('"fechaNacimiento":"' || v_params.fecnac || '",');
    htp.prn('"genero":"' || v_params.genero || '",');
    htp.prn('"guiaAcademica":"' || v_params.numguia || '",');
    htp.prn('"identificacion":"' || v_params.numero_documento || '",');
    htp.prn('"jornada":"' || v_params.jornada || '",');
    htp.prn('"nombre2DoPrograma":"' || pkg_utils.acentos(v_params.nomseg_pgm) || '",');
    htp.prn('"nombrePrograma":"' || pkg_utils.acentos(v_params.nomfac) || '",');
    htp.prn('"pais":' || to_number(v_params.codpais) || ',');
    htp.prn('"periodo":"' || v_params.ciclo || '",');
    htp.prn('"poblacion":' || to_number(v_params.codmuni) || ',');
    htp.prn('"porcentajeRecargo":' || v_params.porcrecargo || ',');
    htp.prn('"primerApellido":"' || pkg_utils.acentos(v_params.primer_apelllido) || '",');
    htp.prn('"primerNombre":"' || pkg_utils.acentos(v_params.primer_nombre) || '",');
    htp.prn('"primerSemestre":"' || v_params.primer_semestre || '",');
    htp.prn('"programa":"' || v_params.codfac || '",');
    htp.prn('"segundoApellido":"' || pkg_utils.acentos(v_params.segundo_apellido) || '",');
    htp.prn('"segundoNombre":"' || pkg_utils.acentos(v_params.segundo_nombre) || '",');
    htp.prn('"semestre":"' || v_params.seminf || '",');
    htp.prn('"telefono":"' || v_params.telefono || '",');
    htp.prn('"tipoIdentificacion":"' || v_params.tipo_documento || '",');
    htp.prn('"tipoMatricula":"' || v_params.codtran || '",');
    htp.prn('"tipoPrograma":"' || v_params.tipo_programa || '",');
    htp.prn('"totalCreditos":' || nvl(v_params.totcredfac,0) || ',');
    htp.prn('"totalSemestres":' || to_number(v_params.numsem) || ',');
    htp.prn('"cobrarcreditosadicionales":"' || v_indc_art47 || '",');
    htp.prn('"creditosadescontar":' || v_cred_art47);
    htp.prn('}');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end liquidar;
function puedeVerTuroriaPostMalla (
    p_codigo varchar2
) return number is
    v_ind number default 0;
    v_pre number default 0;
begin
    select e.materias_pendientes
    into v_ind
    from postgrado.b_estudiantes e
    where e.codigo = p_codigo
    and e.materias_pendientes is not null;
    if v_ind > 0 then
        select count(*)
        into v_pre
        from (
            select distinct ph.materia_plan, ph.codigo_estudiante
            from postgrado.b_prematricula_historico ph
            where ph.materia_plan in ('DES81','DES52','DES61','DES62','DES71')
            and ph.codigo_estudiante = p_codigo
            and not exists (select 1 from postgrado.a_notas n where n.codigo_estudiante = ph.codigo_estudiante and n.codigo_materia = ph.materia_plan and n.valor >= 3.5)) x;
        if v_ind - v_pre <= 0 then
            return(1);
        end if;
    else
        return(1);
    end if;
    return(0);
exception
when others then
    return(sqlcode);
end puedeVerTuroriaPostMalla;

procedure prematricular(
        p_args in varchar2)
as
    v_csv varchar2(4096) ;
    n number default 1;
    type t_strings is table of varchar2(128) ;
    v_parametros t_strings := t_strings() ;
    v_arg varchar2(128) ;
    v_respuesta number default - 777;
    anio varchar2(4) ;
    ciclo varchar2(2) ;
begin
    select pr.anio,
        pr.ciclo
    into anio,
        ciclo
    from desarrollospre.ss_schema sh
    inner join desarrollospre.ss_periodo pr
    on  pr.id_schema         = sh.id_schema
    where pr.id_ciclo        = 1
    and pr.id_estado_periodo = 1;
    owa_util.mime_header('application/json', false, 'ISO-8859-1') ;
    owa_util.http_header_close;
    dbms_obfuscation_toolkit.desdecrypt( input_string => utl_raw.cast_to_varchar2(hextoraw(p_args)) , key_string => utl_raw.cast_to_varchar2(hextoraw('3764613438353137')) , decrypted_string => v_csv) ;
    v_csv       := trim(v_csv) ;
    v_arg       := regexp_substr(v_csv,'[^,]+',1,n) ;
    while v_arg is not null
    loop
        v_parametros.extend;
        v_parametros(n) := v_arg;
        n := n + 1;
        v_arg := regexp_substr(v_csv,'[^,]+',1,n) ;
    end loop;
    case v_parametros(4)
    when 'ADD' then
        b_prematricula_spring.p_prematricular_json( v_parametros(5) , v_parametros(6) , v_parametros(8) , to_number(v_parametros(7)) , anio, ciclo, v_respuesta) ;
    when 'DEL' then
        b_prematricula_spring.p_desprematricular_json( v_parametros(5) , v_parametros(6) , to_number(v_parametros(7)) , anio, ciclo, v_respuesta) ;
    end case;
    if v_respuesta > 0 then
        insert
        into prematricula_logs values
            (
                seq_logs_prematricula.nextval,
                sysdate,
                v_parametros(2) ,
                v_parametros(1) ,
                v_parametros(5) ,
                v_parametros(4) ,
                v_parametros(3) ,
                anio,
                ciclo,
                v_parametros(6)
            ) ;
        commit;
    end if;
    htp.prn('{"respuesta":'||v_respuesta||'}') ;
exception
when others then
    htp.prn('{"respuesta":-888,"error":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
end prematricular;
procedure prematricular_tx(
        p_codigo      in varchar2,
        p_perfil      in varchar2,
        p_materia     in varchar2,
        p_consecutivo in numeric,
        p_anio        in varchar2,
        p_ciclo       in varchar2)
as
    v_grupo a_horario_horizontal%rowtype;
    v_grupo_post postgrado.a_horario_horizontal%rowtype;
    v_creditos        number := - 1;
    v_facultad        varchar2(4) ;
    v_jornada         varchar2(4) ;
    v_plan_estudio    varchar2(2) ;
    v_tipo_estudiante varchar2(8) ;
    v_nombre_est      varchar2(50) ;
    v_semestre        number;
    v_cred_mat        number;
    v_cred_ext        number;
    v_cred_max        number;
    v_vista           number;
    v_postgradual     number;
    v_cruces          number;
    v_mplan           number;
    v_numeroerror     number;
    v_textoerror      varchar2(200) ;
    --BUG: JDRJ 20150616 11:10
    v_mcursar number;
begin
    if b_prematricula_spring.f_prematricula_activa(p_anio, p_ciclo) < 1 then
        raise_application_error(-20000, 'Prematricula cerrada');
    end if;
    if b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 then
        raise_application_error(-20001, 'Fuera de turno');
    end if;
    select est.codigo_facultad,
        est.jornada_facultad,
        est.plan_estudio,
        (
        case when length(est.nombre) > 50 then substr(est.nombre, 0, 50) else est.nombre end) ,
        est.ciclo_de_ingreso
        || est.tipo_de_ingreso
    into v_facultad,
        v_jornada,
        v_plan_estudio,
        v_nombre_est,
        v_tipo_estudiante
    from admisiones.b_estudiantes est
    where est.codigo      = p_codigo;
    if v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'NR' and v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'RA' and v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'ME' then
        begin
            select to_number(m1.semestre)
            into v_semestre
            from b_estudiantes e
            inner join a_materias m1
            on(m1.codigo_facultad   = e.codigo_facultad
            and m1.jornada_facultad = e.jornada_facultad
            and m1.plan_estudio     = e.plan_estudio)
            where m1.codigo         = p_materia
            and e.codigo            = p_codigo;
            --Ojo con los postgraduales
            select x.cr +
                (select m1.creditos
                from a_materias m1
                where m1.codigo         = p_materia
                and m1.codigo_facultad  = e.codigo_facultad
                and m1.jornada_facultad = e.jornada_facultad
                and m1.plan_estudio     = e.plan_estudio
                ) ,
                cr.creditos + nvl(
                (select pa.tope_creditos
                from a_prematricula_autorizados pa
                where pa.codigo_estudiante = e.codigo
                ) , 0) as cr_max
            into v_creditos,
                v_cred_max
            from b_estudiantes e
            inner join creditosxsemestre cr
            on(cr.codigo_facultad   = e.codigo_facultad
            and cr.jornada_facultad = e.jornada_facultad
            and cr.plan_estudio     = e.plan_estudio)
            inner join
                (select sum(m.creditos) as cr,
                    min(to_number(m.semestre)) as sm
                from b_estudiantes e
                inner join b_prematricula p
                on  e.codigo = p.codigo_estudiante
                inner join a_materias m
                on(p.materia_plan      = m.codigo
                and p.facultad         = m.codigo_facultad
                and m.jornada_facultad = e.jornada_facultad
                and e.plan_estudio     = m.plan_estudio)
                where e.codigo         = p_codigo
                ) x on(
                case when v_semestre < x.sm then v_semestre else x.sm end) = to_number(cr.semestre)
            where e.codigo           = p_codigo;
            if v_creditos            > v_cred_max then
                raise_application_error(-20002, 'Creditos maximos superados');
            end if;
        exception
        when no_data_found then
            dbms_output.put_line('sin prematricula');
        end;
        --BUG: caso 41111110: materia inscrita desde diferentes lugares, no los atrapa la sesion.
        select count( *)
        into v_mcursar
        from b_prematricula p1
        where p1.materia_cursar in
            (select h1.codigo_materia
            from a_horario_horizontal h1
            where h1.consecutivo = p_consecutivo
            union
            select h2.codigo_materia
            from postgrado.a_horario_horizontal h2
            where h2.consecutivo = p_consecutivo
            )
        and p1.anio                  = p_anio
        and p1.ciclo                 = p_ciclo
        and p1.codigo_estudiante     = p_codigo
        and p1.indicador_reglamento is null;
        if v_mcursar                >= 1 then
            raise_application_error(-20003, 'Materia ya prematriculada');
        end if;
        --FIN BUG
        select count( *)
        into v_vista
        from b_prematricula_historico h
        where h.codigo_estudiante = p_codigo
        and h.materia_cursar     in
            (select ah.codigo_materia
            from a_horario_horizontal ah
            where ah.consecutivo = p_consecutivo
            )
        and h.indicador_pago      in('P', 'V')
        and h.definitiva_depurada >= 3;
        if v_vista                >= 1 then
            raise_application_error(-20004, 'Tema ya visto');
        end if;
    end if;
    begin
        select *
        into v_grupo
        from admisiones.a_horario_horizontal hh
        where hh.consecutivo = p_consecutivo
        and hh.abierto       = 'S'
        and hh.anio          = p_anio
        and hh.ciclo         = p_ciclo;
    exception
    when no_data_found then
        v_postgradual := 1;
    end;
    if v_postgradual > 0 then
        select *
        into v_grupo_post
        from postgrado.a_horario_horizontal hh
        where hh.consecutivo = p_consecutivo
        and hh.abierto       = 'S'
        and hh.anio          = p_anio
        and hh.ciclo         = p_ciclo;
    end if;
    if v_grupo.consecutivo is not null then
        select count( *)
        into v_cruces
        from
            (select count(consecutivo) as y
            from
                (select hv.consecutivo,
                    hv.dia
                    || hv.hora as x
                from a_horario_vertical hv
                inner join b_prematricula p
                on  hv.consecutivo          = p.id_curso
                where p.codigo_estudiante   = p_codigo
                and hv.anio                 = p_anio
                and hv.ciclo                = p_ciclo
                and p.indicador_reglamento is null
                --No tener en cuenta los cancelados?
                and p.indicador_pago not in ('C','K')
                and p.indicador_reglamento is null
                union
                select hv.consecutivo,
                    hv.dia
                    || hv.hora as x
                from a_horario_vertical hv
                where hv.consecutivo = v_grupo.consecutivo
                and hv.anio          = p_anio
                and hv.ciclo         = p_ciclo
                ) y
            group by x
            having count(consecutivo) > 1
            ) z;
        if v_cruces      > 0 then
            raise_application_error(-20005, 'Tiene cruces de horario.');
        end if;
        select count( *)
        into v_mplan
        from b_prematricula
        where materia_plan    = p_materia
        and codigo_estudiante = p_codigo
        and anio              = p_anio
        and ciclo             = p_ciclo;
        --and indicador_reglamento is null;
        if v_mplan       > 0 then
            raise_application_error(-20006, 'Materia plan ya prematriculada.');
            return;
        end if;
        insert
        into b_prematricula
            (
                codigo_estudiante,
                facultad,
                materia_plan,
                facultad_cursar,
                materia_cursar,
                grupo,
                jornada_facultad,
                fecha,
                flag_procesado,
                anio,
                ciclo,
                codmil,
                nombre,
                id_curso
            )
        select p_codigo,
            v_facultad,
            p_materia,
            v_grupo.codigo_facultad,
            v_grupo.codigo_materia,
            to_number(v_grupo.grupo_materia) ,
            v_grupo.jornada_facultad,
            sysdate,
            null,
            p_anio,
            p_ciclo,
            be.codmil,
            v_nombre_est,
            p_consecutivo
        from admisiones.b_estudiantes be
        where be.codigo = p_codigo
        and exists
            (select 1
            from admisiones.a_horario_horizontal hh
            where hh.cupo_utilizado + 1 <= hh.cupo
            and hh.consecutivo           = p_consecutivo
            and hh.anio                  = p_anio
            and hh.ciclo                 = p_ciclo
            ) ;
    elsif v_grupo_post.consecutivo is not null then
        insert
        into b_prematricula
            (
                codigo_estudiante,
                facultad,
                materia_plan,
                facultad_cursar,
                materia_cursar,
                grupo,
                jornada_facultad,
                fecha,
                flag_procesado,
                anio,
                ciclo,
                codmil,
                nombre,
                id_curso
            )
        select p_codigo,
            v_facultad,
            p_materia,
            v_grupo_post.codigo_facultad,
            v_grupo_post.codigo_materia,
            to_number(v_grupo_post.grupo_materia) ,
            v_grupo_post.jornada_facultad,
            sysdate,
            null,
            p_anio,
            p_ciclo,
            be.codmil,
            v_nombre_est,
            p_consecutivo
        from admisiones.b_estudiantes be
        where be.codigo = p_codigo
        and exists
            (select 1
            from postgrado.a_horario_horizontal hh
            where hh.consecutivo = p_consecutivo
            and hh.anio          = p_anio
            and hh.ciclo         = p_ciclo
            ) ;
    else
        raise_application_error(-20007, 'El grupo no existe.');
    end if;
    if sql%rowcount != 1 then
        raise_application_error(-20008, 'Sin cupo: ' || p_materia);
    end if;
exception
when no_data_found then
    raise_application_error(-20011, sqlerrm);
when others then
    raise_application_error(-20099, sqlerrm);
end prematricular_tx;
procedure desprematricular_tx(
        p_codigo      in varchar2,
        p_perfil      in varchar2,
        p_consecutivo in numeric,
        p_anio        in varchar2,
        p_ciclo       in varchar2)
as
begin
    if b_prematricula_spring.f_prematricula_activa(p_anio, p_ciclo) < 1 then
        raise_application_error(-20100, 'Prematricula cerrada');
    end if;
    if b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 then
        raise_application_error(-20101, 'Fuera de turno');
    end if;
    delete
    from b_prematricula
    where codigo_estudiante = p_codigo
    and id_curso            = p_consecutivo
    and anio                = p_anio
    and ciclo               = p_ciclo
    and indicador_pago not in('K','C') ;
    if sql%rowcount        <> 1 then
        raise_application_error(-20102, 'Datos discordantes.');
    end if;
exception
when no_data_found then
    raise_application_error(-20111, sqlerrm);
when others then
    raise_application_error(-20199, sqlerrm);
end desprematricular_tx;
procedure prematriculaBloque(
    p_usr varchar2,
    p_add varchar2 default null,
    p_del varchar2 default null)
as
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_usr varchar2(256);
    v_add varchar2(2096);
    v_del varchar2(2096);
    /*USUARIO*/
    v_codigo b_estudiantes.codigo%type;
    v_facu b_estudiantes.codigo_facultad%type;
    v_jor b_estudiantes.jornada_facultad%type;
    v_perfil varchar2(8);
    v_ip varchar2(16);
    v_plan number;
    v_crs_ini number default 0;
    v_crs number default 0;
    v_crmax number default 99;
    --UA
    v_cc a_usuarios.numero_documento%type;
    v_perfil2 varchar2(8);
    --fin UA
    /*fin USUARIO*/
    /*MATERIA*/
    v_consecutivo a_horario_horizontal.consecutivo%type;
    v_nom_mat prematricula_logs.descripcion%type;
    v_materia a_materias.codigo%type;
    v_crd_mat a_materias.creditos%type;
    /*fin MATERIA*/
    v_arg varchar2(256);
    n number default 1;
    v_periodos number;
begin
    owa_util.mime_header('application/json', false, 'utf8') ;
    owa_util.http_header_close;
    v_usr := pkg_utils.f_leertoken(p_usr, 1/1440, '3764613438353137');
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    v_codigo := regexp_substr(v_usr,'[^,]+',1,1);
    v_facu := substr(v_codigo, 0, 2);
    v_perfil := regexp_substr(v_usr,'[^,]+',1,2);
    v_ip := regexp_substr(v_usr,'[^,]+',1,3);
    v_cc := regexp_substr(v_usr,'[^,]+',1,4);
    v_perfil2 := regexp_substr(v_usr,'[^,]+',1,5);
    begin
        select e.jornada_facultad, to_number(e.plan_estudio), case v_perfil when 'RA' then 99 when 'NV' then (select to_number(cr.creditos) from creditosxsemestre cr where cr.codigo_facultad = e.codigo_facultad and cr.jornada_facultad = e.jornada_facultad and cr.plan_estudio = e.plan_estudio and to_number(cr.semestre) = 1) else 99 end as cmax
        into v_jor, v_plan, v_crmax
        from b_estudiantes e
        where e.codigo = v_codigo and e.anio = v_anio and e.ciclo = v_ciclo;
        if v_perfil = 'RA' then
            v_periodos := pkg_utils.ciclosDespuesDeFinMateriasRA(v_codigo);
            if v_periodos between 5 and 8 then
                v_crmax := 1;
            elsif v_periodos between 9 and 10 then
                v_crmax := 14;
            end if;
        end if;
        v_crs_ini := pkg_utils.creditosPrematriculados(v_codigo);
    exception
    when no_data_found then
        raise_application_error(-20000, 'Estudiante no registrado.');
    end;
    if p_del is not null then
        v_del := pkg_utils.f_leertoken(p_del, 1/1440, '3764613438353137');
        v_arg := regexp_substr(v_del,'[^;]+',1,n);
        while v_arg is not null loop
            v_consecutivo := to_number(regexp_substr(v_arg,'[^,]+',1,1));
            v_materia := regexp_substr(v_arg,'[^,]+',1,2);
            begin
                if v_perfil = 'RA' then
                    select m.creditos, m.codigo || ' ' || m.nombre || ' (' || (select ah.codigo_materia || ' gr.' || ah.grupo_materia from a_horario_horizontal ah where ah.consecutivo = v_consecutivo) || ')'
                    into v_crd_mat, v_nom_mat
                    from a_materias m
                    where m.codigo = v_materia and m.codigo_facultad = v_facu and m.jornada_facultad = v_jor and rownum <= 1;
                else
                    select m.creditos, m.codigo || ' ' || m.nombre || ' (' || (select ah.codigo_materia || ' gr.' || ah.grupo_materia from a_horario_horizontal ah where ah.consecutivo = v_consecutivo) || ')'
                    into v_crd_mat, v_nom_mat
                    from a_materias m
                    where m.codigo = v_materia and m.codigo_facultad = v_facu and m.jornada_facultad = v_jor and m.plan_estudio = v_plan and rownum <= 1;
                end if;
            exception
            when others then
                raise_application_error(-20002, 'Materia no encontrada: ' || v_materia || '-' || v_facu || '-' || v_jor || '-' || v_plan);
            end;
            if v_cc is not null then
                pkg_prematricula.desprematricular_tx(v_codigo, v_perfil2, v_consecutivo, v_anio, v_ciclo);
                insert into prematricula_logs values (seq_logs_prematricula.nextval, sysdate, v_ip, v_cc, v_codigo, 'DEL', v_nom_mat, v_anio, v_ciclo, v_perfil2);
            else
                pkg_prematricula.desprematricular_tx(v_codigo, v_perfil, v_consecutivo, v_anio, v_ciclo);
                insert into prematricula_logs values (seq_logs_prematricula.nextval, sysdate, v_ip, v_codigo, v_codigo, 'DEL', v_nom_mat, v_anio, v_ciclo, v_perfil);
            end if;
            v_crs_ini := v_crs_ini - v_crd_mat;
            n := n + 1;
            v_arg := regexp_substr(v_del,'[^;]+',1,n);
        end loop;
        n := 1;
    end if;
    if p_add is not null then
        v_add := pkg_utils.f_leertoken(p_add, 1/1440, '3764613438353137');
        v_arg := regexp_substr(v_add,'[^;]+',1,n);
        while v_arg is not null loop
            v_consecutivo := to_number(regexp_substr(v_arg,'[^,]+',1,1));
            v_materia := regexp_substr(v_arg,'[^,]+',1,2);
            begin
                if v_perfil = 'RA' then
                    select m.creditos, m.codigo || ' ' || m.nombre || ' (' || (select ah.codigo_materia || ' gr.' || ah.grupo_materia from a_horario_horizontal ah where ah.consecutivo = v_consecutivo) || ')'
                    into v_crd_mat, v_nom_mat
                    from a_materias m
                    where m.codigo = v_materia and m.codigo_facultad = v_facu and m.jornada_facultad = v_jor and rownum <= 1;
                else
                    select m.creditos, m.codigo || ' ' || m.nombre || ' (' || (select ah.codigo_materia || ' gr.' || ah.grupo_materia from a_horario_horizontal ah where ah.consecutivo = v_consecutivo) || ')'
                    into v_crd_mat, v_nom_mat
                    from a_materias m
                    where m.codigo = v_materia and m.codigo_facultad = v_facu and m.jornada_facultad = v_jor and m.plan_estudio = v_plan and rownum <= 1;
                end if;
            exception
            when others then
                raise_application_error(-20003, 'Materia no encontrada: ' || v_perfil || '->' || v_materia || '-' || v_facu || '-' || v_jor || '-' || v_plan);
            end;
            if v_cc is not null then
                pkg_prematricula.prematricular_tx(v_codigo, v_perfil2, v_materia, v_consecutivo, v_anio, v_ciclo);
                insert into prematricula_logs values (seq_logs_prematricula.nextval, sysdate, v_ip, v_cc, v_codigo, 'ADD', v_nom_mat, v_anio, v_ciclo, v_perfil2);
            else
                pkg_prematricula.prematricular_tx(v_codigo, v_perfil, v_materia, v_consecutivo, v_anio, v_ciclo);
                insert into prematricula_logs values (seq_logs_prematricula.nextval, sysdate, v_ip, v_codigo, v_codigo, 'ADD', v_nom_mat, v_anio, v_ciclo, v_perfil);
            end if;
            v_crs_ini := v_crs_ini + v_crd_mat;
            n := n + 1;
            v_arg := regexp_substr(v_add,'[^;]+',1,n);
        end loop;
    end if;
    if v_crs_ini < v_crmax then
        raise_application_error(-20001, 'Creditos minimos no prematriculados. Faltan: ' || (v_crmax - v_crs_ini));
    end if;
    commit;
    htp.prn('{"status":"ok","mensaje":"Prematricula almacenada."}');
    actualizar_estudiante(v_codigo);
exception
when others then
    rollback;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end prematriculaBloque;
procedure getLiquidables
as
    type t_liquidables is ref cursor;
    v_liquidables t_liquidables;
    v_codigo b_estudiantes.codigo%type;
    v_correo correos_institucionales.correo%type;
    v_liquidacion number;
    v_marca_np number;
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
begin
    owa_util.mime_header('application/json', false, 'utf8') ;
    owa_util.http_header_close;
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    open v_liquidables for
        select
            l.codigo,
            (select ci.correo from correos_institucionales ci where ci.codigo = l.codigo) as email,
            l.liqprem,
            0 as marca_np
        from
            v_liquidacion_estudiantes l
        where
            l.liqguia < l.liqprem
            and l.liqprem > 0
            and l.guia is not null
            and l.tipo_de_ingreso not in ('RA','NR','ME')
            and (l.indicador_pago in ('P','V') or b_prematricula_spring.f_get_codigo_contrario(l.codigo, l.anio, l.ciclo) is not null)
        union
        select
            distinct e.codigo,
            (select ci.correo from correos_institucionales ci where ci.codigo = e.codigo) as email,
            0 as liqprem,
            0 as marca_np
        from
            g_guias_de_pago p
                inner join
            b_estudiantes e
                on  p.codigo_est = e.codigo
        where
            p.anio = e.anio
            and p.ciclo = e.ciclo
            and p.indicador_pago in('X')
            and e.indicador_pago in('P','V')
            and p.activa = '1'
            and not exists (select 1 from cti_marca_no_pago np where np.codigo_estudiante = e.codigo)
        union
        select
            np.codigo_estudiante,
            (select ci.correo from correos_institucionales ci where ci.codigo = np.codigo_estudiante) as email,
            0 as liqprem,
            1 as marca_np
        from
            b_estudiantes e
                inner join
            cti_marca_no_pago np
                on e.codigo = np.codigo_estudiante
        where
            np.anio = v_anio
            and np.ciclo = v_ciclo
            and e.indicador_pago in ('P','V');
    htp.prn('[');
    loop fetch v_liquidables into v_codigo, v_correo, v_liquidacion, v_marca_np;
		if v_liquidables%found and v_liquidables%rowcount > 1 then
            htp.prn(',');
        end if;
        exit when v_liquidables%notfound;
        htp.prn('{"codigo":"' || v_codigo || '","correo":"' || v_correo || '","art47":' || pkg_utils.aplicaArt47(v_codigo) || ',"liquidacion":' || v_liquidacion || ',"np":' || v_marca_np || '}');
    end loop;
    htp.prn(']');
    close v_liquidables;
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
    close v_liquidables;
end getLiquidables;
procedure modificarMarcaNoPago (
    p_token varchar2
) as
    v_token varchar2(32);
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(16);
    v_codigo varchar2(8);
    v_accion varchar2(3);
begin
    owa_util.mime_header('application/json', false, 'utf8') ;
    owa_util.http_header_close;
    v_token := pkg_utils.f_leertoken(p_token, 1/*1/1440*/, '3764613438353137');
    v_codigo := regexp_substr(v_token,'[^;]+',1,1);
    v_accion := regexp_substr(v_token,'[^;]+',1,2);
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    case v_accion
        when 'ADD' then
            insert into cti_marca_no_pago (codigo_estudiante, anio, ciclo, fecha)
            select v_codigo, v_anio, v_ciclo, sysdate from dual
            where not exists (select 1 from cti_marca_no_pago np where np.codigo_estudiante = v_codigo and np.anio = v_anio and np.ciclo = v_ciclo);
        when 'DEL' then
            delete from cti_marca_no_pago np where np.codigo_estudiante = v_codigo and np.anio = v_anio and np.ciclo = v_ciclo;
        else
            raise_application_error(-20001, 'Opcion no valida.');
    end case;
    commit;
    htp.prn('{"status":"ok","mensaje":"Etiqueta modificada."}');
exception
when others then
    rollback;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end modificarMarcaNoPago;
function tieneMarcaNoPago(
    p_codigo b_estudiantes.codigo%type,
    p_anio b_estudiantes.anio%type default null,
    p_ciclo b_estudiantes.ciclo%type default null
) return number
as
    v_anio b_estudiantes.anio%type;
    v_ciclo b_estudiantes.ciclo%type;
    v_np number;
begin
    if p_anio is null or p_ciclo is null then
        pkg_utils.getAnioCiclo(p_codigo, v_anio, v_ciclo);
    end if;
    select count(*)
    into v_np
    from cti_marca_no_pago mnp
    where mnp.codigo_estudiante = p_codigo
    and mnp.anio = v_anio
    and mnp.ciclo = v_ciclo;
    return(v_np);
exception
when others then
    return(sqlcode);
end tieneMarcaNoPago;
procedure listado_np_json(
    p_anio in b_estudiantes.anio%type default null,
    p_ciclo in b_estudiantes.ciclo%type default null
) is
    type t_marcados is ref cursor;
    v_marcados t_marcados;
    v_codigo b_estudiantes.codigo%type;
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
begin
    owa_util.mime_header('application/json', false, 'utf8') ;
    owa_util.http_header_close;
    if p_anio is null or p_ciclo is null then
        pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    else
        v_anio := p_anio;
        v_ciclo := p_ciclo;
    end if;
    open v_marcados for
        select np.codigo_estudiante from cti_marca_no_pago np where np.anio = v_anio and np.ciclo = v_ciclo order by np.codigo_estudiante;
    htp.prn('[');
    loop fetch v_marcados into v_codigo;
		if v_marcados%found and v_marcados%rowcount > 1 then
            htp.prn(',');
        end if;
        exit when v_marcados%notfound;
        pkg_utils.getEstudiante(v_codigo, 0);
    end loop;
    close v_marcados;
    htp.prn(']');
exception
when others then
    close v_marcados;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end listado_np_json;
procedure getCodigosCAdicionales is
    p_codigo b_estudiantes.codigo%type;
    p_anio b_estudiantes.anio%type := '2017';
    p_ciclo b_estudiantes.ciclo%type := '02';
    v_mail varchar2(128);
    v_esquema varchar2(32);
    v_sem_inf number;
    v_crd_max number;
    v_crd_ins number;
    cursor cods is select distinct e.codigo, nvl((select ci.correo from correos_institucionales ci where ci.codigo = e.codigo),'') as mail from b_estudiantes e inner join b_prematricula p on e.codigo = p.codigo_estudiante where e.indicador_pago in ('P','V') order by 1;
begin
    owa_util.mime_header('application/json', false, 'utf8') ;
    owa_util.http_header_close;
    pkg_utils.getAnioCicloEsquema(1, p_anio, p_ciclo, v_esquema);
    open cods;
    htp.prn('[');
    loop fetch cods into p_codigo, v_mail;
        exit when cods%notfound;
        pkg_utils.getResumenCreditos(p_codigo, p_anio, p_ciclo, v_sem_inf, v_crd_max, v_crd_ins, 0);
        if v_crd_max < v_crd_ins then
            htp.prn('{"codigo":"' || p_codigo || '","correo":"' || v_mail || '","art47":' || pkg_utils.aplicaArt47(p_codigo) || ',"liquidacion":0,"np":0},');
        end if;
    end loop;
    close cods;
    htp.prn('{"codigo":"0"}]');
exception
when others then
    close cods;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getCodigosCAdicionales;
end pkg_prematricula;