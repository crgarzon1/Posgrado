create or replace package body pkg_admisiones as

/*
FIXME: Seguridad por oscuridad no es seguridad.
        Se debe validar el origen de la petición, se puede mediante cookie.
*/

function getPeriodo(p_programa varchar2) return varchar2 as
    v_periodo varchar2(8);
begin
    select anio || ciclo
    into v_periodo
    from admisiones.a_fechas_de_corte
    where proceso = case when p_programa < '71' then 'ADMISION ESTUDIANTES NUEVOS-PREGRADO' else 'ADMISION ESTUDIANTES NUEVOS-POSTGRADO' end;
    return v_periodo;
exception
when others then
    return null;
end getPeriodo;

function getTexto(p_clave varchar2) return varchar2 as
    v_msg mensajes_inscripcion.mensaje%type;
begin
    select t.mensaje
    into v_msg
    from mensajes_inscripcion t
    where t.id = p_clave;
    return v_msg;
exception
when others then
    return null;
end getTexto;

function estaInscrito(p_documento varchar2, p_programa varchar2, p_jornada varchar2) return number as
    v_esta_inscrito number;
    v_periodo varchar2(8);
    v_anio varchar2(4);
    v_ciclo varchar2(2);
begin
    if p_programa < '71' then
        select count(*)
        into v_esta_inscrito
        from
            (select asp1.numdoc
            from admisiones.a_aspirantes asp1
            where asp1.numdoc         = p_documento
            and asp1.codigo_facultad  = p_programa
            and asp1.jornada_facultad = p_jornada
            union
            select asp2.numdoc
            from admisiones.a_aspirantes asp2
            where asp2.numdoc         = p_documento
            and asp2.codigo_facultad  = p_programa
            and asp2.jornada_facultad = p_jornada
            and(asp2.numsnp          is not null
             or(select count(*)
                from admisiones.a_aspirantes_interesados ai
                where ai.codigo_facultad = p_programa
                and ai.jornada_facultad  = p_jornada
                and ai.numero_documento  = p_documento
                and ai.anio
                    ||ai.ciclo = getPeriodo(p_programa)) > 0)
            );
        if v_esta_inscrito <= 0 then
            select count(*)
            into v_esta_inscrito
            from admisiones.a_aspirantes asp1
            where asp1.numdoc = p_documento;
            if v_esta_inscrito > 0 then
                return 2;--en otro programa
            end if;
        else
            return 1;--en el mismo programa
        end if;
    else
        v_periodo := getPeriodo(p_programa);
        v_anio := substr(v_periodo,0,4);
        v_ciclo := substr(v_periodo,5,2);
        select count(*)
        into v_esta_inscrito
        from desarrollospre.cti_interesado i
        where i.numdoc = p_documento
        and i.codigo_facultad = p_programa and i.jornada_facultad = p_jornada
        and i.anio || i.ciclo = v_anio || v_ciclo
        and rownum <= 1;
        if v_esta_inscrito > 0 then
            return 1;
        end if;
    end if;
    return 0;--no esta inscrito
end estaInscrito;

function fueEstudiante(p_documento varchar2, p_snp varchar2 default '-') return number as
    v_retorno varchar2(8);
    v_matriculado number;
begin
    v_retorno := fn_tiene_historia_academica(p_documento, p_snp);
    if v_retorno = 'SI' then
        return 1;
    else
        select count(*)
        into v_matriculado
        from admisiones.datos_personales d
        inner join admisiones.b_estudiantes b
        on  d.codigo_estudiante = b.codigo
        where b.indicador_pago in('P','V')
        and d.numero_documento  = p_documento
        and b.tipo_de_ingreso  in('NV','TE','TI','RA','RI','NR','ME');
        if v_matriculado > 0 then
            return 1;
        end if;
    end if;
    return 0;
end fueEstudiante;

function esAutorizadoPrograma(p_documento varchar2, p_programa varchar2, p_jornada varchar2, p_anio varchar2, p_ciclo varchar2) return number as
    v_retorno number;
begin
    select count(*)
    into v_retorno
    from admisiones.autorizacion_admisiones aa
    inner join admisiones.programas_aut_admisiones aut
    on  aa.id = aut.id
    and aa.anio || aa.ciclo = p_anio || p_ciclo
    and aut.programa = p_programa || p_jornada
    and aa.documento = p_documento;
    return v_retorno;
end esAutorizadoPrograma;

function esAutorizadoExtranjero(p_documento varchar2, p_anio varchar2, p_ciclo varchar2) return number as
    v_retorno number;
begin
  SELECT count(*)
  into  v_retorno 
  FROM AUTORIZACION_ADMISIONES t
  WHERE t.DOCUMENTO   = p_documento
  AND t.TIPO          = 'EXT'
  AND T.ANIO          = p_anio
  AND T.CICLO         = p_ciclo
  AND t.TIPO_DOCUMENTO='P';
  return v_retorno;
end esAutorizadoExtranjero;

function esSPPxDocumento(p_documento varchar2, p_facultad varchar2) return number as
    v_retorno number;
    v_periodo varchar2(8);
begin
    v_periodo := getPeriodo(p_facultad);
    select count(*)
    into v_retorno
    from beneficiarios_becas bb
    where bb.documento = p_documento
    and bb.anio = substr(v_periodo,0,4)
    and bb.ciclo = substr(v_periodo,5,2);
    return v_retorno;
end esSPPxDocumento;

function esSPP(p_documento varchar2) return number as
    v_retorno number;
begin
    select count(*)
    into v_retorno
    From Admisiones.V_Beneficiarios
    where numsnp in (select numsnp from admisiones.a_aspirantes where (numdoc = p_documento or numdoc_icfes = p_documento));
    return v_retorno;
End Esspp;

function tieneInscripcionSNP(p_numsnp varchar2, p_programa varchar2, p_jornada varchar2) return number as
    v_retorno number;
begin
    Select Count(*)
    into v_retorno
    From A_Aspirantes
    Where Codigo_Facultad= p_programa
    And Jornada_Facultad = p_jornada
    AND NUMSNP           = P_Numsnp;
    return v_retorno;
end tieneInscripcionSNP;

procedure validarParte1(p_numdoc varchar2, p_tipdoc varchar2, p_programa varchar2, p_jornada varchar2) as
    V_Periodo Varchar2(8) Default Getperiodo(P_Programa);
    V_Nom_Programa Varchar2(100);
    V_Nom_jornada Varchar2(10);
Begin
    if esAutorizadoPrograma(p_numdoc, p_programa, p_jornada, substr(v_periodo,0,4), substr(v_periodo,5,2)) <= 0 then
        If Estainscrito(P_Numdoc, P_Programa, P_Jornada) = 2 Then
            RAISE_APPLICATION_ERROR(-20001, GETTEXTO('17'));
        elsif (fueEstudiante(p_numdoc) > 0 or Estamatriculado(P_Numdoc) > 0) AND p_programa<'71' and FNC_TIENE_SUSP_DEF_PROG(P_PROGRAMA, P_NUMDOC)=0 then
            raise_application_error(-20001, getTexto('1'));
        elsif tieneInscripcionSPP(p_numdoc) > 0 then
            RAISE_APPLICATION_ERROR(-20001, GETTEXTO('4'));
        Elsif Estaentransferencias(P_Numdoc, substr(v_periodo,0,4), substr(v_periodo,5,2)) > 0 AND esAutorizadoTransferencias(P_Numdoc, substr(v_periodo,0,4), substr(v_periodo,5,2)) = 0 Then
            Select Unique F.Nombre, Decode(T.Jor_Fac_Solicitada,'D','DIURNA','N','NOCTURNA')
            Into   V_Nom_Programa, V_Nom_Jornada
            FROM   A_Solicitud_Transferencias T, A_Facultades_Unica f
            Where  T.Cod_Facultad_Solicitada = F.Codigo_Facultad
            And    T.Numero_Documento        =  P_Numdoc
            AND    T.TIPO_TRANSFERENCIA      = 'TE'
            and    t.anio||t.ciclo           = substr(v_periodo,0,4)||substr(v_periodo,5,2)
            and    rownum                    = 1;
            Raise_Application_Error(-20001, REPLACE(REPLACE(GETTEXTO('19'),'?1',V_NOM_PROGRAMA),'?2',V_NOM_JORNADA));
        ELSIF FNC_TIENE_SUSP_DEF_PROG(P_PROGRAMA, P_NUMDOC) >0 THEN  
            Raise_Application_Error(-20001, GETTEXTO('21'));
        end if;
   end if;
exception
when others then
    raise;
end validarParte1;

procedure validarParte2(p_numdoc varchar2, p_tipdoc varchar2, p_programa varchar2, p_jornada varchar2, p_numsnp Varchar2)
as
    v_periodo varchar2(8) default getPeriodo(p_programa);
Begin
        If (Fueestudiante(P_Numdoc) > 0 Or Estamatriculado(P_Numdoc) > 0) And P_Programa<'71' and FNC_TIENE_SUSP_DEF_PROG(P_PROGRAMA, P_NUMDOC)=0 Then
            Raise_Application_Error(-20001, Gettexto('1'));
        /*Elsif Tieneinscripcionsnp(P_Numsnp, P_Programa, P_Jornada) > 0 Then
            Raise_Application_Error(-20001, Gettexto('9'));--mariano rua mejia 16/04/2020*/
        ELSIF CERRADOEXTEMPORANEO(P_PROGRAMA, P_JORNADA) > 0 THEN
            raise_application_error(-20001, getTexto('10'));
        ELSIF FNC_TIENE_SUSP_DEF_PROG(P_PROGRAMA, P_NUMDOC) >0 THEN  
            Raise_Application_Error(-20001, GETTEXTO('21'));
        End If;
exception
When Others Then
    Raise;
End Validarparte2;

procedure saveAspiratOnePre(
        p_tipdoc varchar2,
        p_numdoc varchar2,
        p_codigo_facultad varchar2,
        p_jornada_facultad varchar2,
        p_primer_nombre varchar2,
        p_segundo_nombre varchar2,
        p_primer_apellido varchar2,
        p_segundo_apellido varchar2,
        p_celular varchar2,
        p_email varchar2,
        p_origen varchar2,
        p_anio varchar2,
        p_ciclo varchar2)
as
begin
    if estaCerrado(p_codigo_facultad, p_jornada_facultad)>0 or p_origen = 'freCuTu5' then
        return;
    end if;
    insert into a_aspirantes(
        codigo,
        nombre,
        codigo_facultad,
        jornada_facultad,
        fac_origen,
        jor_origen,
        codigo_transaccion,
        apellidos,
        nombres,
        tipdoc,
        numdoc,
        tipoest,
        anio,
        ciclo,
        fecha_inscripcion,
        valor_matricula,
        motivacion,
        email,
        celular,
        entrevista,
        lectura,
        tipo_inscripcion,
        primer_nombre,
        segundo_nombre,
        primer_apellido,
        segundo_apellido
    )
    (select seq_inscripcion.nextval, 
        regexp_replace(p_primer_apellido || ' ' || p_segundo_apellido || ' ' || p_primer_nombre || ' ' || p_segundo_nombre, '[ ]+', ' '),
        p_codigo_facultad, 
        p_jornada_facultad,
        p_codigo_facultad, 
        p_jornada_facultad,
        '01',
        regexp_replace(p_primer_apellido || ' ' || p_segundo_apellido, '[ ]+', ' '),
        regexp_replace(p_primer_nombre || ' ' || p_segundo_nombre, '[ ]+', ' '),
        p_tipdoc,
        p_numdoc,
        'NUEVO',
        p_anio,
        p_ciclo,
        sysdate,
        0,
        'E',
        p_email,
        p_celular,
        '-',              
        'INTERNET'||' '||to_char(sysdate,'YYYYMMDD HH:MM:SS'),  
        null,
        p_primer_nombre,
        p_segundo_nombre,
        p_primer_apellido,
        p_segundo_apellido
    from dual
    where
        p_codigo_facultad < '71'
        and not exists (select 1 from a_aspirantes a where a.numdoc = p_numdoc and a.tipdoc = p_tipdoc and a.codigo_facultad = p_codigo_facultad and a.jornada_facultad = p_jornada_facultad)
    );
end saveAspiratOnePre;

procedure savePartOne(
        p_tipdoc varchar2,
        p_numdoc varchar2,
        p_codigo_facultad varchar2,
        p_jornada_facultad varchar2,
        p_primer_nombre varchar2,
        p_segundo_nombre varchar2,
        p_primer_apellido varchar2,
        p_segundo_apellido varchar2,
        p_celular varchar2,
        p_email varchar2,
        p_origen varchar2,
        p_anio varchar2,
        p_ciclo varchar2)
as
    v_programa varchar2(256);
    v_campania number;
    v_autorizado number;
    v_prg_anterior varchar2(8);
    v_cod_prg_anterior varchar2(8);
    v_anio varchar2(4) := p_anio;
    v_ciclo varchar2(2) := p_ciclo;
begin
    begin
        select 1
        into v_campania
        from desarrollospre.cti_campania c
        where c.codigo = p_origen;
    exception
    when no_data_found then
        raise_application_error(-20004, 'Origen no registrado.');
    end;
    validarParte1(p_numdoc, p_tipdoc, p_codigo_facultad, p_jornada_facultad);
    begin
        select f.nombre || ' (' || f.jornada || ')' as programa, f.codigo || f.jornada as codfac
        into v_programa, v_prg_anterior
        from a_facultades f inner join desarrollospre.cti_interesado i
        on f.codigo = i.codigo_facultad and f.jornada = i.jornada_facultad
        where i.tipdoc = p_tipdoc and i.numdoc = p_numdoc
        --and i.codigo_facultad = p_codigo_facultad and i.jornada_facultad = p_jornada_facultad
        and i.anio || i.ciclo != v_anio || v_ciclo
        and rownum <= 1;
        update desarrollospre.cti_interesado i
        set 
            i.anio = v_anio,
            i.ciclo = v_ciclo,
            i.primer_nombre = p_primer_nombre,
            i.segundo_nombre = p_segundo_nombre,
            i.primer_apellido = p_primer_apellido,
            i.segundo_apellido = p_segundo_apellido,
            i.celular = p_celular,
            i.email = p_email,
            i.origen = p_origen,
            i.codigo_facultad = p_codigo_facultad,
            i.jornada_facultad = p_jornada_facultad,
            i.fecha = sysdate
        where i.tipdoc = p_tipdoc and i.numdoc = p_numdoc
        and i.codigo_facultad = p_codigo_facultad
        and i.jornada_facultad = p_jornada_facultad
        and i.anio || i.ciclo != v_anio || v_ciclo;
        if sql%rowcount = 1 and p_codigo_facultad < '71' then
            saveAspiratOnePre(
                p_tipdoc,
                p_numdoc,
                p_codigo_facultad,
                p_jornada_facultad,
                p_primer_nombre,
                p_segundo_nombre,
                p_primer_apellido,
                p_segundo_apellido,
                p_celular,
                p_email,
                p_origen,
                v_anio,
                v_ciclo
            );
            return;
        elsif sql%rowcount > 1 then
            raise_application_error(-20111,'Mas de un registro');
        end if;
    exception
    when no_data_found then
        null;--continua ejecucion
    end;
    begin
        select f.nombre || ' ' || f.jornada as programa, f.codigo || f.jornada as codfac, f.codigo codprg
        into v_programa, v_prg_anterior, v_cod_prg_anterior
        from a_facultades f inner join desarrollospre.cti_interesado i
        on f.codigo = i.codigo_facultad and f.jornada = i.jornada_facultad
        where i.tipdoc = p_tipdoc and i.numdoc = p_numdoc
        and i.anio || i.ciclo = v_anio || v_ciclo
        and rownum <= 1;
        if v_prg_anterior != p_codigo_facultad || p_jornada_facultad then
            if p_codigo_facultad < '71' and v_cod_prg_anterior >= '71' then
                update desarrollospre.cti_interesado i
                set 
                    i.anio = v_anio,
                    i.ciclo = v_ciclo,
                    i.primer_nombre = p_primer_nombre,
                    i.segundo_nombre = p_segundo_nombre,
                    i.primer_apellido = p_primer_apellido,
                    i.segundo_apellido = p_segundo_apellido,
                    i.celular = p_celular,
                    i.email = p_email,
                    i.origen = p_origen,
                    i.codigo_facultad = p_codigo_facultad,
                    i.jornada_facultad = p_jornada_facultad,
                    i.fecha = sysdate
                where i.tipdoc = p_tipdoc and i.numdoc = p_numdoc
                and i.anio || i.ciclo = v_anio || v_ciclo;
                saveAspiratOnePre(
                    p_tipdoc,
                    p_numdoc,
                    p_codigo_facultad,
                    p_jornada_facultad,
                    p_primer_nombre,
                    p_segundo_nombre,
                    p_primer_apellido,
                    p_segundo_apellido,
                    p_celular,
                    p_email,
                    p_origen,
                    v_anio,
                    v_ciclo
                );
                return;
            elsif p_codigo_facultad >= '71' then
                update desarrollospre.cti_interesado i
                set 
                    i.anio = v_anio,
                    i.ciclo = v_ciclo,
                    i.primer_nombre = p_primer_nombre,
                    i.segundo_nombre = p_segundo_nombre,
                    i.primer_apellido = p_primer_apellido,
                    i.segundo_apellido = p_segundo_apellido,
                    i.celular = p_celular,
                    i.email = p_email,
                    i.origen = p_origen,
                    i.codigo_facultad = p_codigo_facultad,
                    i.jornada_facultad = p_jornada_facultad,
                    i.fecha = sysdate
                where i.tipdoc = p_tipdoc and i.numdoc = p_numdoc
                and i.anio || i.ciclo = v_anio || v_ciclo;
                return;
            else
                raise_application_error('-20001', getTexto('17') || '. Programa inscrito: ' || v_programa);
            end if;
        else
            return;
        end if;
    exception
    when no_data_found then
        null;
    when others then
        raise;
    end;
    insert into desarrollospre.cti_interesado (
        tipdoc,
        numdoc,
        codigo_facultad,
        jornada_facultad,
        primer_nombre,
        segundo_nombre,
        primer_apellido,
        segundo_apellido,
        celular,
        email,
        origen,
        anio,
        ciclo,
        fecha
    ) select p_tipdoc,
        trim(p_numdoc),
        p_codigo_facultad,
        p_jornada_facultad,
        trim(p_primer_nombre),
        trim(p_segundo_nombre),
        trim(p_primer_apellido),
        trim(p_segundo_apellido),
        trim(p_celular),
        trim(p_email),
        p_origen,
        v_anio,
        v_ciclo,
        sysdate
    from dual;
    if sql%rowcount != 1 then
        raise_application_error(-20002,'No se logro almacenar');
    end if;
    if p_codigo_facultad < '71' then
        saveAspiratOnePre(
            p_tipdoc,
            p_numdoc,
            p_codigo_facultad,
            p_jornada_facultad,
            p_primer_nombre,
            p_segundo_nombre,
            p_primer_apellido,
            p_segundo_apellido,
            p_celular,
            p_email,
            p_origen,
            v_anio,
            v_ciclo
        );
    end if;
exception
when others then
    raise;
end savePartOne;

procedure getInteresado(p_parametro in nclob) as
    data_c json default json(p_parametro);
    p_numdoc varchar2(16) default data_c.get('documento').get_string;
    p_codigo_facultad varchar2(8) default data_c.get('programa').get_string;
    p_jornada_facultad varchar2(4) default data_c.get('jornada').get_string;
begin
    owa_util.mime_header('application/json', false, 'utf8');
    owa_util.http_header_close;
    for interesado in (select * from desarrollospre.cti_interesado i where i.numdoc = p_numdoc and i.codigo_facultad = p_codigo_facultad and i.jornada_facultad = p_jornada_facultad) loop
        htp.prn('{');
        htp.prn('"primerNombre":"' || interesado.primer_nombre || '",');
        htp.prn('"segundoNombre":"' || interesado.segundo_nombre || '",');
        htp.prn('"primerApellido":"' || interesado.primer_apellido || '",');
        htp.prn('"segundoApellido":"' || interesado.segundo_apellido || '",');
        htp.prn('"tipoDocumento":"' || interesado.tipdoc || '",');
        htp.prn('"documento":"' || interesado.numdoc || '",');
        htp.prn('"email":"' || interesado.email || '",');
        htp.prn('"movil":"' || interesado.celular || '",');
        if interesado.codigo_facultad < '71' then
            htp.prn('"tipoPrograma":"1",');
        else
            htp.prn('"tipoPrograma":"2",');
        end if;
        htp.prn('"jornada":"' || interesado.jornada_facultad || '",');
        htp.prn('"programa":"' || interesado.codigo_facultad || '"');
        htp.prn('}');
        return;
    end loop;
    htp.prn('{"status":"fail","mensaje":"Sin registros"}');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getInteresado;

procedure getAspirante(p_parametro in nclob) as
    data_c json default json(p_parametro);
    p_numdoc varchar2(16) default data_c.get('documento').get_string;
    p_codigo_facultad varchar2(8) default data_c.get('programa').get_string;
    P_Jornada_Facultad Varchar2(4) Default Data_C.Get('jornada').Get_String;
    V_Vc_Periodo Varchar2(100) Default Getperiodo(P_Codigo_Facultad);
    v_vc_spp number;
begin
    owa_util.mime_header('application/json', false, 'utf8');
    owa_util.http_header_close;
    for asp in (
        select
            a.codigo,
            a.primer_nombre,
            a.segundo_nombre,
            a.primer_apellido,
            a.segundo_apellido,
            a.sexo,
            a.dia_nac,
            a.mes_nac,
            a.ano_nac,
            case when a.dia_nac is null then null else trim(to_char(a.dia_nac, '00')) || '/' || (select trim(to_char(mm.id_mes, '00')) from desarrollospre.cti_mes mm where mm.abr_ing = a.mes_nac) || '/' || a.ano_nac end as fechaNacimiento,
            a.codigo_pais_nacimiento,
            a.nombre_pais_nacimiento,
            a.coddepto_nacimiento,
            a.departamento_nacimiento,
            a.codmuni_nacimiento,
            a.municipio_nacimiento,
            a.tipdoc,
            a.numdoc,
            a.coddepto_documento,
            a.departamento_documento,
            a.codmuni_documento,
            a.municipio_documento,
            a.numsnp,
            a.dia,
            a.mes,
            a.ano,
            case when a.numsnp is null then null else trim(to_char(a.dia, '00')) || '/' || a.mes || '/' || a.ano end as fechaIcfes,
            a.tipdoc_icfes,
            a.numdoc_icfes,
            a.codigo_pais_residencia,
            a.nombre_pais_residencia,
            a.coddepto_residencia,
            a.departamento_residencia,
            a.codmuni_residencia,
            a.municipio_residencia,
            a.direccion_residencia,
            a.telefono_residencia,
            a.email,
            a.celular,
            case a.entrevista when '-' then null else a.entrevista end as entrevista,
            a.codigo_facultad,
            a.jornada_facultad,
            a.cod_def,
            (select ci.correo from correos_institucionales ci where a.cod_def is not null and ci.codigo = a.cod_def) as correoIns
        from a_aspirantes a
        where a.numdoc = p_numdoc
        and a.codigo_facultad = p_codigo_facultad
        and a.jornada_facultad = p_jornada_facultad
    ) Loop
        v_vc_spp := esSPPxDocumento(asp.numdoc, asp.codigo_facultad);
        htp.prn('{');
        htp.prn('"primerNombre":"' || asp.primer_nombre || '",');
        htp.prn('"segundoNombre":"' || asp.segundo_nombre || '",');
        htp.prn('"primerApellido":"' || asp.primer_apellido || '",');
        htp.prn('"segundoApellido":"' || asp.segundo_apellido || '",');
        htp.prn('"tipoDocumento":"' || asp.tipdoc || '",');
        htp.prn('"documento":"' || asp.numdoc || '",');
        htp.prn('"email":"' || asp.email || '",');
        htp.prn('"movil":"' || asp.celular || '",');
        if asp.codigo_facultad < '71' then
            htp.prn('"tipoPrograma":"1",');
        else
            htp.prn('"tipoPrograma":"2",');
        end if;
        if asp.cod_def is not null then
            htp.prn('"codDef":"' || asp.cod_def || '",');
        end if;
        htp.prn('"jornada":"' || asp.jornada_facultad || '",');
        htp.prn('"programa":"' || asp.codigo_facultad || '",');
        htp.prn('"codigo":"' || asp.codigo || '",');
        htp.prn('"sexo":"' || asp.sexo || '",');
        htp.prn('"diaNac":"' || asp.dia_nac || '",');
        htp.prn('"mesNac":"' || asp.mes_nac || '",');
        htp.prn('"anoNac":"' || asp.ano_nac || '",');
        htp.prn('"fechaNacimiento":"' || asp.fechaNacimiento || '",');
        htp.prn('"codigoPaisNacimiento":"' || asp.codigo_pais_nacimiento || '",');
        htp.prn('"nombrePaisNacimiento":"' || asp.nombre_pais_nacimiento || '",');
        htp.prn('"coddeptoNacimiento":"' || asp.coddepto_nacimiento || '",');
        htp.prn('"departamentoNacimiento":"' || asp.departamento_nacimiento || '",');
        htp.prn('"codmuniNacimiento":"' || asp.codmuni_nacimiento || '",');
        htp.prn('"municipioNacimiento":"' || asp.municipio_nacimiento || '",');
        htp.prn('"coddeptoDocumento":"' || asp.coddepto_documento || '",');
        htp.prn('"departamentoDocumento":"' || asp.departamento_documento || '",');
        htp.prn('"codmuniDocumento":"' || asp.codmuni_documento || '",');
        htp.prn('"municipioDocumento":"' || asp.municipio_documento || '",');
        htp.prn('"numsnp":"' || asp.numsnp || '",');
        htp.prn('"dia":"' || asp.dia || '",');
        htp.prn('"mes":"' || asp.mes || '",');
        htp.prn('"ano":"' || asp.ano || '",');
        htp.prn('"fechaIcfes":"' || asp.fechaIcfes || '",');
        htp.prn('"tipdocIcfes":"' || asp.tipdoc_icfes || '",');
        htp.prn('"numdocIcfes":"' || asp.numdoc_icfes || '",');
        htp.prn('"codigoPaisResidencia":"' || asp.codigo_pais_residencia || '",');
        htp.prn('"nombrePaisResidencia":"' || asp.nombre_pais_residencia || '",');
        htp.prn('"coddeptoResidencia":"' || asp.coddepto_residencia || '",');
        htp.prn('"departamentoResidencia":"' || asp.departamento_residencia || '",');
        htp.prn('"codmuniResidencia":"' || asp.codmuni_residencia || '",');
        htp.prn('"municipioResidencia":"' || asp.municipio_residencia || '",');
        htp.prn('"direccionResidencia":"' || asp.direccion_residencia || '",');
        Htp.Prn('"telefonoResidencia":"' || Asp.Telefono_Residencia || '",');
        Htp.Prn('"entrevista":"' || Asp.Entrevista || '",');
        if asp.entrevista is not null and asp.entrevista not in ('-') then
            for ent in (
                select
                    to_char(e.fecha, 'RRRR/MM/DD HH24:MI') as fecha,
                    d.direccion,
                    d.contacto,
                    d.telefono
                from
                a_programacion_entrevistas e
                    inner join
                directorio_programas d
                    on e.codigo_facultad = d.codigo_facultad
                where e.codigo_facultad = asp.codigo_facultad
                and e.dia = substr(asp.entrevista, 0, 1)
                and e.fecha = to_date(substr(asp.entrevista, 3), 'RRRRMMDD-HH24:MI')
                and rownum <= 1
            ) loop
                htp.prn('"entrevistaObj":{');
                htp.prn('"fecha":"' || ent.fecha || '",');
                htp.prn('"direccion":"' || pkg_utils.acentos(ent.direccion) || '",');
                htp.prn('"contacto":"' || pkg_utils.acentos(ent.contacto) || '",');
                htp.prn('"telefono":"' || pkg_utils.acentos(ent.telefono) || '"');
                htp.prn('},');
            end loop;
        end if;
        htp.prn('"correoInstitucional":"' || asp.correoIns || '",');
        htp.prn('"spp":' || v_vc_spp);
        htp.prn('}');
        return;
    end loop;
    htp.prn('{"status":"fail","mensaje":"Sin registros"}');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getAspirante;

procedure salvarParte1(p_parametro in nclob) as
    data_c json default json(p_parametro);
    p_tipdoc varchar2(2) default data_c.get('tipoDocumento').get_string;
    p_numdoc varchar2(16) default data_c.get('documento').get_string;
    p_codigo_facultad varchar2(8) default data_c.get('programa').get_string;
    p_jornada_facultad varchar2(4) default data_c.get('jornada').get_string;
    p_primer_nombre varchar2(256) default data_c.get('primerNombre').get_string;
    p_segundo_nombre varchar2(256);
    p_primer_apellido varchar2(256) default data_c.get('primerApellido').get_string;
    p_segundo_apellido varchar2(256);
    p_celular varchar2(32) default data_c.get('movil').get_string;
    p_email varchar2(512) default data_c.get('email').get_string;
    p_origen varchar2(16) default data_c.get('origen').get_string;
    v_periodo varchar2(8);
    p_anio varchar2(4);
    p_ciclo varchar2(2);
    v_msg mensajes_inscripcion.mensaje%type;
    v_spp number;
    v_cerrado number;
begin
    begin
        p_segundo_nombre := data_c.get('segundoNombre').get_string;
    exception
    when others then
        null;
    end;
    begin
        p_segundo_apellido := data_c.get('segundoApellido').get_string;
    exception
    when others then
        null;
    end;
    owa_util.mime_header('application/json', false, 'utf8');
    owa_util.http_header_close;
    v_periodo := getPeriodo(p_codigo_facultad);
    p_anio := substr(v_periodo,0,4);
    p_ciclo := substr(v_periodo,5,2);
    if estaInscrito(p_numdoc, p_codigo_facultad, p_jornada_facultad) = 1 then
        if p_tipdoc in ('P','E','V') then
            htp.prn('{"status":"go","mensaje":"' || pkg_utils.acentos(getTexto('8')) || '"}');
        else
            htp.prn('{"status":"go","mensaje":"' || pkg_utils.acentos(getTexto('7')) || '"}');
        end if;
    else
        v_cerrado := estaCerrado(p_codigo_facultad, p_jornada_facultad);
        savePartOne(
            p_tipdoc,
            p_numdoc,
            p_codigo_facultad,
            p_jornada_facultad,
            p_primer_nombre,
            p_segundo_nombre,
            p_primer_apellido,
            p_segundo_apellido,
            p_celular,
            p_email,
            p_origen,
            p_anio,
            p_ciclo
        );
        v_spp := esSPPxDocumento(p_numdoc, p_codigo_facultad);
        if v_spp > 0 then
            htp.prn('{"status":"spp","mensaje":"' || pkg_utils.acentos(getTexto('6')) || '"}');
        elsif v_cerrado = 1 or (v_cerrado = 2 and esAutorizadoPrograma(p_numdoc, p_codigo_facultad, p_jornada_facultad, p_anio, p_ciclo) <= 0) then
            htp.prn('{"status":"warn","mensaje":"' || pkg_utils.acentos(getTexto('10')) || '"}');
        else
            htp.prn('{"status":"ok","mensaje":"' || pkg_utils.acentos(getTexto('6')) || '"}');
        end if;
    end if;
    commit;
exception
when others then
    rollback;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end salvarParte1;

function fnc_getnombrecolegio(
        p_vc_codigo in varchar2)
    return varchar2
is
    v_nom_colegio varchar2(100) default null;
begin
    select nombre
        || ' - '
        || jornada
    into v_nom_colegio
    from admisiones.a_colegios
    where codcole = p_vc_codigo
    order by nombre;
    return v_nom_colegio;
exception
when others then
    return null;
end fnc_getnombrecolegio;

function fnc_getcodigoinscripcion(
        p_vc_programa  in varchar2,
        p_vc_jornada   in varchar2,
        p_vc_documento in varchar2)
    return varchar2
is
    v_codigo_ins varchar2(100) default null;
begin
    select codigo
    into v_codigo_ins
    from admisiones.a_aspirantes
    where codigo_facultad = p_vc_programa
    and jornada_facultad  = p_vc_jornada
    and numdoc            = p_vc_documento;
    return v_codigo_ins;
exception
when others then
    return null;
end fnc_getcodigoinscripcion;

function fnc_getnombrepais(
        p_vc_codigo in varchar2)
    return varchar2
is
    v_nom_pais varchar2(100) default null;
begin
    select nombre_pais
    into v_nom_pais
    from doctorados.doc_paises
    where id_pais = p_vc_codigo;
    return v_nom_pais;
exception
when others then
    return null;
end fnc_getnombrepais;

procedure salvarDatosComplemen(
        p_parametro in nclob)
is
    data_c json default json(p_parametro);
    v_vc_programa                varchar2(100);
    v_vc_primer_apellido         varchar2(100);
    v_vc_segundo_apellido        varchar2(100);
    v_vc_primer_nombre           varchar2(100);
    v_vc_segundo_nombre          varchar2(100);
    v_vc_genero                  varchar2(100);
    v_vc_pais_nacimiento         varchar2(100);
    v_vc_ciudad_nacimiento       varchar2(100);
    v_vc_departamento_nacimiento varchar2(100);
    v_vc_ciud_dep                varchar2(100);
    v_vc_fecha_nacimiento        varchar2(100);
    v_dia_n                      varchar2(100);
    v_mes_n                      varchar2(100);
    v_mes1_n                     varchar2(100);
    v_ano1_n                     varchar2(100);
    v_ano2_n                     varchar2(100);
    v_vc_numero_documento        varchar2(100);
    v_vc_tipo_documento          varchar2(100);
    v_vc_exp_doc                 varchar2(100);
    v_vc_ciudad_expedicion       varchar2(100);
    v_vc_departamento_expedicion varchar2(100);
    v_vc_bachillerato            varchar2(100);
    v_vc_bac                     varchar2(100);
    v_vc_bac_ciud                varchar2(100);
    v_vc_icfes                   varchar2(100);
    v_vc_snp                     varchar2(100);
    v_vc_fecha_icfes             varchar2(100);
    vc_vc_fec_icfes1             varchar2(100);
    vc_vc_fec_icfes2             varchar2(100);
    vc_vc_fec_icfes3             varchar2(100);
    v_vc_direccion               varchar2(100);
    v_vc_pais_contacto           varchar2(100);
    v_vc_ciudad_contacto         varchar2(100);
    v_vc_departamento_contacto   varchar2(100);
    v_vc_p_contacto              varchar2(100);
    v_vc_telefono                varchar2(100);
    v_vc_email_personal          varchar2(320);
    v_vc_celular                 varchar2(100);
    v_nom_pais_nac               varchar2(100);
    v_nom_pais_con               varchar2(100);
    v_vc_codigo                  number;
    v_vc_jornada                 varchar2(100);
    v_vc_tipo_documento_icfes    varchar2(100);
    v_vc_numero_documento_icfes  varchar2(100);
    v_vc_fecha_entrevista        varchar2(100);
    v_retorno                    varchar2(100);
    v_pago_factura    number default 0;
    v_is_no_admitido  number default 0;
    v_coddef          varchar2(100) default '';
    v_aniociclo       varchar2(100) default '';
    v_anio            varchar2(100) default '';
    v_ciclo           varchar2(100) default '';
    v_ciclo_actual    varchar2(100) default '';
    v_codfac          varchar2(100) default '';
    v_jornada         varchar2(100) default '';
    v_admision_aa     number default 0;
    v_debe_documentos number default 0;
    V_Autorizado      Number Default 0;
    V_Esta_Ins        Number Default 0;
    V_Esta_Ins2       Number Default 0;
    V_MAYOR_EDAD      NUMBER DEFAULT 0;
    V_CORREO_ASPIRANTE VARCHAR2(100) DEFAULT NULL;
    v_nombres_aspirante VARCHAR2(100) DEFAULT NULL;
    V_PROGRAMA_ASPIRANTE VARCHAR2(100) DEFAULT NULL;  
    V_JORNADA_ASPIRANTE VARCHAR2(100) DEFAULT NULL;
    V_CORREO_ORIGEN   VARCHAR2(100) DEFAULT 'inscripciones@lasalle.edu.co';
    V_ASUNTO          VARCHAR2(100) DEFAULT 'ADMISION UNIVERSIDAD DE LA SALLE';
    V_Texto           Varchar2(100) Default Null;
Begin
   
    
    begin
        v_vc_codigo := data_c.get('codigo').get_number;
    exception
    when others then
        raise_application_error(-20101, 'Hace falta información: ' || sqlerrm);
    end;

    Insert Into Tmp_Admisiones Values(v_vc_codigo, Sysdate);
   
    v_vc_programa                := getString('programa', data_c);
    v_vc_primer_apellido         := getString('primerApellido', data_c);
    v_vc_segundo_apellido        := getString('segundoApellido', data_c, 0);
    v_vc_primer_nombre           := getString('primerNombre', data_c);
    v_vc_segundo_nombre          := getString('segundoNombre', data_c, 0);
    v_vc_genero                  := getString('sexo', data_c);
    v_vc_pais_nacimiento         := getString('codigoPaisNacimiento', data_c);
    v_vc_ciudad_nacimiento       := getString('codmuniNacimiento', data_c);
    v_vc_departamento_nacimiento := getString('coddeptoNacimiento', data_c);
    v_vc_fecha_nacimiento        := getString('fechaNacimiento', data_c);
    v_vc_numero_documento        := getString('documento', data_c);
    v_vc_tipo_documento          := getString('tipoDocumento', data_c);
    v_vc_ciudad_expedicion       := getString('codmuniDocumento', data_c);
    v_vc_departamento_expedicion := getString('coddeptoDocumento', data_c);
    v_vc_bachillerato            := getString('bachillerato', data_c);
    v_vc_icfes                   := getString('icfes', data_c);
    v_vc_snp                     := getString('numsnp', data_c);
    v_vc_fecha_icfes             := getString('fechaIcfes', data_c);
    v_vc_direccion               := getString('direccionResidencia', data_c);
    v_vc_pais_contacto           := getString('codigoPaisResidencia', data_c);
    v_vc_ciudad_contacto         := getString('codmuniResidencia', data_c);
    v_vc_departamento_contacto   := getString('coddeptoResidencia', data_c);
    v_vc_telefono                := getString('telefonoResidencia', data_c, 0);
    v_vc_email_personal          := getString('email', data_c);
    v_vc_celular                 := getString('movil', data_c);
    v_vc_tipo_documento_icfes    := getString('tipdocIcfes', data_c);
    v_vc_numero_documento_icfes  := getString('numdocIcfes', data_c);
    v_vc_fecha_entrevista        := getString('entrevista', data_c);
    
    owa_util.mime_header('application/json', false, 'utf8');
    Owa_Util.Http_Header_Close;
    Utl_Http.Set_Transfer_Timeout (180); -- mariano rua mejia 01/10/2020
 
    V_Vc_Jornada:=Substr(V_Vc_Programa,-1);
    V_Vc_Programa:=Substr(V_Vc_Programa,0,2);
    Validarparte2(V_Vc_Numero_Documento, V_Vc_Tipo_Documento, V_Vc_Programa, V_Vc_Jornada, V_Vc_Snp);
    if v_vc_pais_nacimiento = '1' then
        v_vc_ciud_dep      := v_vc_ciudad_nacimiento || v_vc_departamento_nacimiento;
    Else
        v_vc_ciud_dep := '99999';
    End If;
    v_mes1_n                 := substr(v_vc_fecha_nacimiento,4,2) ;
    if to_number(v_mes1_n)    = 1 then
        v_mes_n              := 'JAN';
    elsif to_number(v_mes1_n) = 2 then
        v_mes_n              := 'FEB';
    elsif to_number(v_mes1_n) = 3 then
        v_mes_n              := 'MAR';
    elsif to_number(v_mes1_n) = 4 then
        v_mes_n              := 'APR';
    elsif to_number(v_mes1_n) = 5 then
        v_mes_n              := 'MAY';
    elsif to_number(v_mes1_n) = 6 then
        v_mes_n              := 'JUN';
    elsif to_number(v_mes1_n) = 7 then
        v_mes_n              := 'JUL';
    elsif to_number(v_mes1_n) = 8 then
        v_mes_n              := 'AUG';
    elsif to_number(v_mes1_n) = 9 then
        v_mes_n              := 'SEP';
    elsif to_number(v_mes1_n) = 10 then
        v_mes_n              := 'OCT';
    elsif to_number(v_mes1_n) = 11 then
        v_mes_n              := 'NOV';
    elsif to_number(v_mes1_n) = 12 then
        v_mes_n              := 'DEC';
    end if;
    V_Dia_N               := To_Char(To_Number(Substr(V_Vc_Fecha_Nacimiento,0,2))) ;
    V_Ano1_N              := Substr(V_Vc_Fecha_Nacimiento,9,1) ;
    V_Ano2_N              := Substr(V_Vc_Fecha_Nacimiento,10,1) ;
    if v_vc_tipo_documento = 'P' or v_vc_tipo_documento = 'V' then
        v_vc_exp_doc      := '99999';
    else
        v_vc_exp_doc := v_vc_ciudad_expedicion || v_vc_departamento_expedicion;
    End If;
    if v_vc_bachillerato = 'S' then
        v_vc_bac        := 'ICFES - COMPLETA U ORDINARIA';
        v_vc_bac_ciud   := '999999';
    else
        v_vc_bac      := fnc_getnombrecolegio('000000') ;
        v_vc_bac_ciud := '000000';
    end if;
    if v_vc_icfes         = 'S' then
        vc_vc_fec_icfes1 := to_char(to_number(substr(v_vc_fecha_icfes,0,2))) ;
        vc_vc_fec_icfes2 := substr(v_vc_fecha_icfes,4,2) ;
        vc_vc_fec_icfes3 := substr(v_vc_fecha_icfes,7,5) ;
    else
        v_vc_snp         := 'AC201210000000';
        vc_vc_fec_icfes1 := to_char(to_number('01')) ;
        vc_vc_fec_icfes2 := '01';
        vc_vc_fec_icfes3 := '2012';
    end if;
    if v_vc_pais_contacto = '1' then
        v_vc_p_contacto  := v_vc_ciudad_contacto||v_vc_departamento_contacto;
    else
        v_vc_p_contacto := '99999';
    end if;
    v_nom_pais_nac  := fnc_getnombrepais(v_vc_pais_nacimiento) ;
    V_Nom_Pais_Con  := Fnc_Getnombrepais(V_Vc_Pais_Contacto) ;
    if v_vc_codigo is null or v_vc_codigo = -1 then
        v_vc_codigo := fnc_getcodigoinscripcion(v_vc_programa, v_vc_jornada, v_vc_numero_documento) ;
    end if;
    Registrar_Aspirante(V_Vc_Programa||V_Vc_Jornada, 'XXX', V_Vc_Primer_Apellido||' '||V_Vc_Segundo_Apellido, V_Vc_Primer_Nombre||' '||V_Vc_Segundo_Nombre, V_Vc_Genero, V_Vc_Ciud_Dep, V_Dia_N, V_Mes_N, V_Ano1_N, V_Ano2_N, V_Vc_Numero_Documento, V_Vc_Tipo_Documento, V_Vc_Exp_Doc, V_Vc_Bac, V_Vc_Bac_Ciud, '31', 'DEC', '1', '1', V_Vc_Snp, Vc_Vc_Fec_Icfes1, Vc_Vc_Fec_Icfes2, Vc_Vc_Fec_Icfes3, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', V_Vc_Direccion, '', V_Vc_P_Contacto, V_Vc_Telefono, V_Vc_Email_Personal, V_Vc_Celular, 'E', 'O', 'E',Null, 'GRABAR INSCRIPCION', V_Vc_Primer_Nombre, V_Vc_Segundo_Nombre, V_Vc_Primer_Apellido, V_Vc_Segundo_Apellido, V_Vc_Pais_Nacimiento, V_Nom_Pais_Nac, V_Vc_Pais_Contacto, V_Nom_Pais_Con, Null, V_Vc_Codigo, V_Vc_Tipo_Documento_Icfes, V_Vc_Numero_Documento_Icfes, V_Retorno) ;
    --mariano rua mejia 16/04/2020 cambio para grabar automaticamente puntaje entrevista y generar guia de inscripción 
    select count(*)
    into   v_is_no_admitido
    from   a_aspirantes t
    where  t.codigo = V_Vc_Codigo
    and    t.ind1 = '1'
    and    t.cod_def is null;
    if v_is_no_admitido>0 AND v_vc_tipo_documento <> 'P' then
          SELECT MAX(ap.anio||ap.ciclo)
          INTO   v_aniociclo
          FROM   a_aspirantes ap;
          v_anio :=substr(v_aniociclo,1,4);
          v_ciclo:=substr(v_aniociclo,5,2);
          
          SELECT distinct(SUBSTR(pl.anio,3,2)||SUBSTR(pl.ciclo,2,1)) ciclo_actual
          INTO  v_ciclo_actual
          FROM  g_parametros_liquidacion pl
          WHERE pl.anio=v_anio
          AND   pl.ciclo=v_ciclo
          AND   pl.codtran='30';  
            
          select t.CODIGO_FACULTAD, t.JORNADA_FACULTAD 
          into   v_codfac, v_jornada
          from   a_aspirantes t
          where  t.codigo = V_Vc_Codigo;
                   
            V_Coddef:=pkg_estudiantes.getCodigoLibre(
            V_Codfac,
            V_Anio,
            V_Ciclo);
            
          UPDATE a_aspirantes ap
          Set    Ap.Cod_Def = V_Coddef,
                 ap.ind1='2' --mariano rua mejia 01/10/2020
          WHERE  ap.codigo=V_Vc_Codigo;  
          
          UPDATE a_aspirantes_RESPALDO ap
          Set    Ap.Cod_Def=V_Coddef,
                 ap.ind1 = '2'   --mariano rua mejia 01/10/2020
          WHERE  ap.codigo=V_Vc_Codigo;
          
          SELECT 
          CASE WHEN 
          trunc(months_between(sysdate, to_date(
          CASE WHEN ASP.DIA_NAC<10 THEN '0'||ASP.DIA_NAC ELSE ASP.DIA_NAC END||'/'||
          CASE 
          WHEN ASP.MES_NAC = 'JAN' THEN '01'
          WHEN ASP.MES_NAC = 'FEB' THEN '02'
          WHEN ASP.MES_NAC = 'MAR' THEN '03'
          WHEN ASP.MES_NAC = 'APR' THEN '04'
          WHEN ASP.MES_NAC = 'MAY' THEN '05'
          WHEN ASP.MES_NAC = 'JUN' THEN '06'
          WHEN ASP.MES_NAC = 'JUL' THEN '07'
          WHEN ASP.MES_NAC = 'AUG' THEN '08'
          WHEN ASP.MES_NAC = 'SEP' THEN '09'
          WHEN ASP.MES_NAC = 'OCT' THEN '10'
          WHEN ASP.MES_NAC = 'NOV' THEN '11'
          WHEN ASP.MES_NAC = 'DEC' THEN '12'
          END
          ||'/'||ASP.ANO_NAC,'dd/mm/yyyy'))/12) >= 18 THEN 1 ELSE 0 END 
          INTO V_MAYOR_EDAD
          FROM A_ASPIRANTES ASP 
          WHERE ASP.CODIGO=V_Vc_Codigo;
          SELECT ASP.EMAIL, ASP.PRIMER_NOMBRE, nombre_facultad_unica(ASP.CODIGO_FACULTAD), DECODE(ASP.JORNADA_FACULTAD,'D','DIURNA','N','NOCTURNA')
          INTO  V_CORREO_ASPIRANTE, v_nombres_aspirante, V_PROGRAMA_ASPIRANTE, V_JORNADA_ASPIRANTE
          FROM A_ASPIRANTES ASP
          WHERE ASP.CODIGO = V_Vc_Codigo;
          IF  V_MAYOR_EDAD = 0 THEN
              V_TEXTO:='22';
          ELSE
              V_TEXTO:='23';  
          END IF;
    end if;
    ---
    If V_Retorno = 'OK' Then
       /* If V_Vc_Fecha_Entrevista<>'-' and V_Vc_Fecha_Entrevista is not null Then
         begin
            UPDATE A_Programacion_Entrevistas Pe
            Set Pe.Ocupado                  = Nvl(Pe.Ocupado,0)+1
            Where Pe.Codigo_Facultad        = V_Vc_Programa
            And Pe.Dia                      = Substr(V_Vc_Fecha_Entrevista,0,1)
            And Pe.Hora                     = Substr(V_Vc_Fecha_Entrevista,12,13)
            And To_Char(Pe.Fecha,'YYYYMMDD')= Substr(V_Vc_Fecha_Entrevista,3,8);
            If Sql%Rowcount=0 Then
               raise_application_error(-20001, Gettexto('14'));
            END IF;
            Update A_Aspirantes Asp
            Set Asp.Entrevista=V_Vc_Fecha_Entrevista
            Where Asp.Codigo  =V_Vc_Codigo;
            If Sql%Rowcount=0 Then
               Raise_Application_Error(-20001, Gettexto('15'));
            END IF;
         Exception
         When Others Then
          Rollback;
          raise_application_error(-20001, sqlerrm);
         End;
        End If;*/
        Commit;
        if v_vc_tipo_documento = 'P' then--mariano rua mejia 30/04/2020
           Htp.Prn('{"status":"ok","mensaje":"' || Pkg_Utils.Acentos(Gettexto('26')) || '","mayorEdad":"'||V_MAYOR_EDAD||'","programa":"'||Pkg_Utils.Acentos(V_PROGRAMA_ASPIRANTE)||'","jornada":"'||V_JORNADA_ASPIRANTE||'"}') ;
        else
           Htp.Prn('{"status":"ok","mensaje":"' || Pkg_Utils.Acentos(Gettexto('18')) || '","mayorEdad":"'||V_MAYOR_EDAD||'","programa":"'||Pkg_Utils.Acentos(V_PROGRAMA_ASPIRANTE)||'","jornada":"'||V_JORNADA_ASPIRANTE||'"}') ;
        end if;
       Else
        Htp.Prn('{"status":"fail","mensaje":" SALVARDATOSCOMPLEMEM '||V_Retorno||'"}') ;
     End If;
Exception
WHEN utl_http.transfer_timeout THEN --mariano rua mejia 01/10/2020
     Rollback;
     Htp.Prn('{"status":"fail","mensaje": "TIMEOUT_parte2 -> ' || Pkg_Utils.Acentos(Sqlerrm) || '"}') ;
when others then
    rollback;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
end salvarDatosComplemen;

procedure getTimeline(p_codigo number, p_programa varchar2) as
    v_periodo varchar2(8);
    p_anio varchar2(4);
    p_ciclo varchar2(2);
    o_mensaje number;
    o_encuesta number;
    o_guia_activa number;
    v_fecha_prem varchar2(64);
begin
    v_periodo := getPeriodo(p_programa);
    p_anio := substr(v_periodo,0,4);
    p_ciclo := substr(v_periodo,5,2);
    owa_util.mime_header('application/json', false, 'utf8');
    owa_util.http_header_close;
    for tl in (
        select
            case when a.numsnp is not null then 3 else 2 end as form2,
            nvl((select 3 from g_otros_pagos op where op.codigo_est = a.codigo and op.indicador_pago = 'P' and op.activa = 1), 2) as pago_ins,
            1 as resultados,
            a.cod_def,
            revisar_doc(a.cod_def) as docs,
            nvl((select 1 from a_carnet_url ft where a.cod_def is not null and ft.numero_documento = a.cod_def), 0) as foto,
            nvl((select 1 from desarrollospre.cti_enc_respuesta rr inner join desarrollospre.cti_enc_preg_rel rp on rr.id_enc_preg = rp.id_enc_preg where rownum <= 1 and rp.id_encuesta = 2 and rr.codigo_aspirante = a.codigo), 0) as enc2,
            nvl((select 1 from a_usuarios ur where a.cod_def is not null and ur.codigo = a.cod_def), 0) as usr,
            encuestas.contesto_encuesta('1',a.cod_def) enccar,
            tiene_prematricula(a.cod_def) prem,
            a.numdoc documento
        from
            a_aspirantes a
        where
            a.anio = p_anio
            and a.ciclo = p_ciclo
            and a.codigo = p_codigo
    ) loop
        htp.prn('[');
        if tl.form2 = 3 then
            --htp.prn('{"idPaso":1,"estado":' || tl.form2 || ',"etiqueta":"'|| pkg_utils.acentos('Consultar Formulario') || '","link":"#!/timeline/paso1o","activo":0},');
            htp.prn('{"idPaso":1,"estado":' || tl.form2 || ',"etiqueta":"'|| pkg_utils.acentos('Consultar Formulario') || '","link":"#!/timeline/paso1o","activo":0}');
        else
            --htp.prn('{"idPaso":1,"estado":' || tl.form2 || ',"etiqueta":"'|| pkg_utils.acentos('Actualizar Formulario') || '","link":"#!/timeline/paso1","activo":0},');
            htp.prn('{"idPaso":1,"estado":' || tl.form2 || ',"etiqueta":"'|| pkg_utils.acentos('Actualizar Formulario') || '","link":"#!/timeline/paso1","activo":0}');
        end if;
        --htp.prn('{"idPaso":2,"estado":' || tl.pago_ins || ',"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Inscripción') || '","link":"#!/timeline/paso2","activo":0');
        if tl.pago_ins = 3 then
             null;
            --htp.prn(',"mensaje":{"level":3,"header":"Pago realizado","body":"Tu pago se encuentra registrado, gracias.","closeable":true}');
            --htp.prn('"mensaje":{"level":3,"header":"Pago realizado","body":"Tu pago se encuentra registrado, gracias.","closeable":true}');
        end if;
        --htp.prn('},');
        htp.prn(',');
        getResultado(p_codigo, o_mensaje, o_encuesta, o_guia_activa);
        if o_mensaje > 0 and o_guia_activa = 0 then
            htp.prn('{"idPaso":3,"estado":');
            --Los mensajes 4 y 7 representan nodos finales del proceso
            if o_mensaje in (4, 7) then
                htp.prn('3');
            else
                htp.prn('2');
            end if;
            htp.prn(',"etiqueta":"'|| pkg_utils.acentos('Consulta de Resultados') || '","link":"#!/timeline/paso3","activo":0,"mensaje":{"level":2,"header":"Aviso importante","body":"{M0' || o_mensaje || '}","closeable":true}},');
            htp.prn('{"idPaso":4,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":5,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"timeline-formulario.html","activo":0},');
            --htp.prn('{"idPaso":7,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":8,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Inscripción de Materias') || '","link":"timeline-formulario.html","activo":0}');
        elsif o_encuesta > 0 then
            htp.prn('{"idPaso":3,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Consulta de Resultados') || '","link":"#!/timeline/paso3/encuesta1","activo":0},');
            htp.prn('{"idPaso":4,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":5,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"timeline-formulario.html","activo":0},');
            --htp.prn('{"idPaso":7,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":8,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Inscripción de Materias') || '","link":"timeline-formulario.html","activo":0}');
        elsif o_guia_activa > 0 then
            htp.prn('{"idPaso":3,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Consulta de Resultados') || '","activo":0');
            if o_mensaje = 8 then
                htp.prn(',"link":"#!/timeline/paso3/spp"');
            elsif o_mensaje > 0 then
                htp.prn(',"link":"#!/timeline/paso3","mensaje":{"level":2,"header":"Aviso importante","body":"{M0' || o_mensaje || '}","closeable":true}');
            end if;
            htp.prn('},');
            if o_guia_activa = 1 then
                htp.prn('{"idPaso":4,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Matrícula') || '","link":"#!/timeline/paso4","activo":0},');
                htp.prn('{"idPaso":5,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
                htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"timeline-formulario.html","activo":0},');
                --htp.prn('{"idPaso":7,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"timeline-formulario.html","activo":0},');
            elsif o_guia_activa = 2 then
                htp.prn('{"idPaso":4,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Matrícula') || '","link":"#!/timeline/paso4","activo":0},');
                if revisar_doc(tl.cod_def) = 'OK' then
                    htp.prn('{"idPaso":5,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"#!/timeline/paso5","activo":0},');
                    if tl.foto <= 0 then
                        if pkg_estudiantes.esMenorDeEdad(tl.cod_def) > 0 and pkg_admisiones.tieneAutorizacionPadres(tl.documento) <= 0 then
                            htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/paso6","activo":0,"mensaje":{"level":1,"header":"Habeas data","body":"' || pkg_utils.acentos(getTexto('25')) || '","closeable":true}},');
                        else
                            htp.prn('{"idPaso":6,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/paso6","activo":0},');
                        end if;
                    elsif tl.enc2 <= 0 then
                        htp.prn('{"idPaso":6,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/paso6/encuesta2","activo":0},');
                    elsif tl.usr <= 0 then
                        htp.prn('{"idPaso":6,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/paso6/consulta-usr","activo":0},');
                    elsif tl.usr > 0 then
                        htp.prn('{"idPaso":6,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/paso6/consulta-usr","activo":0},');
                    else
                        htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"#!/timeline/","activo":0},');
                    end if;
                else
                    htp.prn('{"idPaso":5,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"#!/timeline/paso5","activo":0},');
                    htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"timeline-formulario.html","activo":0},');
                end if;
                /*if tl.enccar > 0 then
                    htp.prn('{"idPaso":7,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"#!/timeline/paso7","activo":0,"mensaje":{"level":3,"header":"Gracias","body":"Encuesta ya diligenciada","closeable":true}},');
                else
                    --FIXME: encuesta bloqueada
                    --htp.prn('{"idPaso":7,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"#!/timeline/paso7","activo":0},');
                    htp.prn('{"idPaso":7,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"#!/timeline/paso7","activo":0,"mensaje":{"level":2,"header":"Importante","body":"'|| pkg_utils.acentos('Apreciado Estudiante: Esta Encuesta de Caracterización  la podrá realizar durante la Semana de Inducción.') || '","closeable":true}},');
                end if;*/
            end if;
            if tl.prem > 0 then
                htp.prn('{"idPaso":8,"estado":3,"etiqueta":"'|| pkg_utils.acentos('Inscripción de Materias') || '","link":"#!/timeline/paso8","activo":0,"mensaje":{"level":3,"header":"Listo!","body":"Prematricula realizada.","closeable":true}}');
            else
                select trim(to_char(f.fecha_prematricula,'DD','NLS_DATE_LANGUAGE=spanish'))
                    ||' de '
                    || trim(initcap(to_char(f.fecha_prematricula,'MONTH','NLS_DATE_LANGUAGE=spanish')))
                    ||' de '
                    || trim(to_char(f.fecha_prematricula,'IYYY','NLS_DATE_LANGUAGE=spanish')) fecha
                into v_fecha_prem
                from admisiones.a_fechas_de_corte f
                where f.proceso like '%ADM%NUEVO%PREGRADO%';
                htp.prn('{"idPaso":8,"estado":2,"etiqueta":"'|| pkg_utils.acentos('Inscripción de Materias') || '","link":"#!/timeline/paso8","activo":0,"mensaje":{"level":2,"header":"Espera","body":"' || pkg_utils.acentos('Para realizar el proceso de inscripción de materias (Prematrícula), el sistema estará habilitado a partir del ' || v_fecha_prem || '. Recuerde que debe ingresar con el usuario y clave al Sistema de Información Académica (SIA).') || '","closeable":true}}');
            end if;
        else
            htp.prn('{"idPaso":3,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Resultados') || '","link":"#!/timeline/paso3","activo":0},');
            htp.prn('{"idPaso":4,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Imprimir Guía de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":5,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Legalización de Matrícula') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":6,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Consulta de Usuario y Clave') || '","link":"timeline-formulario.html","activo":0},');
            --htp.prn('{"idPaso":7,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Encuesta de Caracterización') || '","link":"timeline-formulario.html","activo":0},');
            htp.prn('{"idPaso":8,"estado":1,"etiqueta":"'|| pkg_utils.acentos('Inscripción de Materias') || '","link":"timeline-formulario.html","activo":0}');
        end if;
        htp.prn(']');
        return;
    end loop;
    htp.prn('{"status":"fail","mensaje":"Sin registros"}');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getTimeline;

procedure getPaises as
    pais doctorados.doc_paises%rowtype;
    cursor c_paises is select * from doctorados.doc_paises where id_pais not in (1) order by nombre_pais;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    open c_paises;
    htp.prn('[');
    htp.prn('{');
    htp.prn('"codigo":1,');
    htp.prn('"nombre":"COLOMBIA"');
    htp.prn('},');
    loop
        fetch c_paises
        into pais;
        if c_paises%found and c_paises%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_paises%notfound;
        htp.prn('{');
        htp.prn('"codigo":' || pais.id_pais || ',');
        htp.prn('"nombre":"' || pkg_utils.acentos(pais.nombre_pais) || '"');
        htp.prn('}');
    end loop;
    htp.prn(']');
    close c_paises;
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
    close c_paises;
end getPaises;

procedure getDepartamentos(
    id_pais doctorados.doc_paises.id_pais%type
) as
    v_codigo a_divipola.codigo_departamento%type;
    v_nombre a_divipola.nom_departamento%type;
    cursor c_deptos is select distinct codigo_departamento, nom_departamento from a_divipola where codigo_departamento <> '99' order by nom_departamento;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    open c_deptos;
    htp.prn('[');
    if id_pais = 1 then
        loop
            fetch c_deptos
            into v_codigo, v_nombre;
            if c_deptos%found and c_deptos%rowcount > 1 then
                htp.prn(',') ;
            end if;
            exit when c_deptos%notfound;
            htp.prn('{');
            htp.prn('"codigo":"' || v_codigo || '",');
            htp.prn('"nombre":"' || pkg_utils.acentos(v_nombre) || '"');
            htp.prn('}');
        end loop;
        close c_deptos;
    else
        htp.prn('{');
        htp.prn('"codigo":"99",');
        htp.prn('"nombre":"Extranjero"');
        htp.prn('}');
    end if;
    htp.prn(']');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
    close c_deptos;
end getDepartamentos;

procedure getMunicipios(
    p_codigo_departamento a_divipola.codigo_departamento%type
) as
    v_codigo a_divipola.codigo_municipio%type;
    v_nombre a_divipola.nom_municipio%type;
    cursor c_mcipios is select distinct codigo_municipio, nom_municipio from admisiones.a_divipola where codigo_departamento = p_codigo_departamento order by nom_municipio;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    open c_mcipios;
    htp.prn('[');
    if p_codigo_departamento <> '99' then
        loop
            fetch c_mcipios
            into v_codigo, v_nombre;
            if c_mcipios%found and c_mcipios%rowcount > 1 then
                htp.prn(',') ;
            end if;
            exit when c_mcipios%notfound;
            htp.prn('{');
            htp.prn('"codigo":"' || v_codigo || '",');
            htp.prn('"nombre":"' || pkg_utils.acentos(v_nombre) || '"');
            htp.prn('}');
        end loop;
        close c_mcipios;
    else
        htp.prn('{');
        htp.prn('"codigo":"999",');
        htp.prn('"nombre":"Extranjero"');
        htp.prn('}');
    end if;
    htp.prn(']');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
    close c_mcipios;
end getMunicipios;

procedure getEntrevistas(
    p_programa a_programacion_entrevistas.codigo_facultad%type
) as
    v_codigo varchar2(128);
    v_nombre varchar2(512);
    cursor c_entrevistas is select
            pe.dia
            ||'-'
            ||to_char(pe.fecha,'YYYYMMDD')
            ||'-'
            ||pe.hora etiqueta,
            trim(to_char(pe.fecha,'Day','NLS_DATE_LANGUAGE=spanish'))
            ||' '
            || trim(to_char(pe.fecha,'DD','NLS_DATE_LANGUAGE=spanish'))
            ||' de '
            || trim(initcap(to_char(pe.fecha,'MONTH','NLS_DATE_LANGUAGE=spanish')))
            ||' de '
            || trim(to_char(pe.fecha,'IYYY','NLS_DATE_LANGUAGE=spanish'))
            ||' a partir de las '
            || substr(pe.hora,1,2)
            ||' horas' calendario
        from admisiones.a_programacion_entrevistas pe
        where
        pe.codigo_facultad        = p_programa
        and pe.fecha                    > sysdate
        and(pe.disponible - pe.ocupado) > 0
        order by pe.fecha,
            pe.hora;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    open c_entrevistas;
    htp.prn('[');
    loop
        fetch c_entrevistas
        into v_codigo, v_nombre;
        if c_entrevistas%found and c_entrevistas%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_entrevistas%notfound;
        htp.prn('{');
        htp.prn('"codigo":"' || v_codigo || '",');
        htp.prn('"nombre":"' || pkg_utils.acentos(v_nombre) || '"');
        htp.prn('}');
    end loop;
    close c_entrevistas;
    htp.prn(']');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
    close c_entrevistas;
end getEntrevistas;

  function tieneDatosFacturaCompletos( p_vc_codigo varchar2) return number as
   v_retorno number;
  begin
    SELECT COUNT(*)
    into  v_retorno
    FROM  A_ASPIRANTES
    WHERE CODIGO              = p_vc_codigo
    AND CODIGO_FACULTAD      IS NOT NULL
    AND JORNADA_FACULTAD     IS NOT NULL
    AND NUMSNP               IS NOT NULL
    AND DIRECCION_RESIDENCIA IS NOT NULL
    AND EMAIL                IS NOT NULL
    AND SEXO                 IS NOT NULL
    AND DIA_NAC              IS NOT NULL
    AND MES_NAC              IS NOT NULL
    AND ANO_NAC              IS NOT NULL;
    return v_retorno;
  end tieneDatosFacturaCompletos;                                                                          

function getStatusPrograma(p_programa varchar2, p_jornada varchar2, p_status varchar2) return number as
    v_retorno number;
begin
    select count(*)
    into v_retorno
    from admisiones.a_facultades
    where codigo          = p_programa
    and jornada           = p_jornada
    and abrir_inscripcion = p_status;
    return v_retorno;
end getStatusPrograma;

function cerradoExtemporaneo(p_programa varchar2, p_jornada varchar2) return number as
    v_retorno number;
begin
    v_retorno := getStatusPrograma(p_programa, p_jornada, 'N');
    if v_retorno = 0 then
        v_retorno := getStatusPrograma(p_programa, p_jornada, 'X');
        if v_retorno > 0 then
            v_retorno := 2;
        end if;
    end if;
    return v_retorno;
end cerradoExtemporaneo;

function estaCerrado(p_programa varchar2, p_jornada varchar2) return number as
begin
    return getStatusPrograma(p_programa, p_jornada, 'N');
end estaCerrado;

function estaAbierto(p_programa varchar2, p_jornada varchar2) return number as
begin
    return getStatusPrograma(p_programa, p_jornada, 'S');
end estaAbierto;

  function tienePagoIncripcion(p_vc_codigo varchar2) return number as
   v_retorno number;
  begin
   select count(*) 
   into   v_retorno
   from   G_OTROS_PAGOS g 
   where  g.CODIGO_EST = p_vc_codigo
   and    g.INDICADOR_PAGO = 'P';
   v_retorno:=1;--mariano rua 17/04/2020
   return v_retorno;
  end tienePagoIncripcion;
  
  procedure validarFacturaInscripcion(p_codigo varchar2, p_programa varchar2, p_jornada varchar2) as
  begin
      /*if tienePagoIncripcion(p_codigo)>0 then
         raise_application_error(-20001, getTexto('11'));
      Elsif Tienedatosfacturacompletos(P_Codigo)=0 Then
         raise_application_error(-20001, getTexto('12')); --mariano rua mejia 16/04/2020
      Els*/if Estacerrado(P_Programa,P_Jornada)>0 Then
         raise_application_error(-20001, getTexto('13'));
      end if;
  exception
  when others then
      raise;
  end validarFacturaInscripcion;
  
  procedure getDatosFactura(P_Parametro In Nclob) as
   Data_C Json Default Json(P_Parametro);
   v_vc_programa  varchar2(100) default data_c.get('programa').get_string;
   v_vc_jornada varchar2(100)   default data_c.get('jornada').get_string;
   V_Vc_Numero_Documento Varchar2(100) Default Data_C.Get('documento').Get_String;
   v_vc_codigo varchar2(100) default null;
   v_vc_nombres varchar2(100) default null;
   v_vc_primer_nombre varchar2(100) default null;
   v_vc_segundo_nombre varchar2(100) default null;
   v_vc_primer_apellido varchar2(100) default null;
   v_vc_segundo_apellido varchar2(100) default null;
   v_vc_sexo varchar2(100) default null;
   v_vc_direccion_residencia varchar2(100) default null;
   v_vc_telefono_residencia varchar2(100) default null;
   v_vc_email varchar2(100) default null;
   v_vc_mes_nac varchar2(100) default null;
   v_vc_dia_nac varchar2(100) default null;
   v_vc_ano_nac varchar2(100) default null;
   v_vc_fecha_nacimiento varchar2(100) default null;
   V_Vc_Tipo_Documento Varchar2(100) Default Null;
   V_Vc_Nombre_Programa Varchar2(100) Default Null;
   V_Vc_Periodo Varchar2(100) Default Getperiodo(V_Vc_Programa);
   V_Nm_Ser_Pilo Number Default 0;
   V_Nm_Tipo_Matricula Number Default 0;
   v_vc_fecha_vencimiento varchar2(100) default null;
  begin
    owa_util.mime_header('application/json', false, 'utf8');
    Owa_Util.Http_Header_Close;
    Utl_Http.Set_Transfer_Timeout (180); -- mariano rua mejia 02/10/2020
    
    select t.codigo
    into   v_vc_codigo
    from   a_aspirantes t
    Where  T.Numdoc = V_Vc_Numero_Documento
    and    t.codigo_facultad = v_vc_programa
    and    t.jornada_facultad = v_vc_jornada;
    Validarfacturainscripcion(V_Vc_Codigo, V_Vc_Programa, V_Vc_Jornada);
    SELECT decode(TIPDOC,'T','TI','C','CC','E','CE','V','VI','P','PS'),
      NOMBRE,
      PRIMER_NOMBRE,
      SEGUNDO_NOMBRE,
      PRIMER_APELLIDO,
      SEGUNDO_APELLIDO,
      SEXO,
      DIRECCION_RESIDENCIA,
      NVL2(TELEFONO_RESIDENCIA,TELEFONO_RESIDENCIA,'0') TELEFONO_RESIDENCIA,
      EMAIL,
      MES_NAC,
      DIA_NAC,
      ANO_NAC,
      (case when to_number(A.DIA_NAC) < 10 then '0'||A.DIA_NAC else A.DIA_NAC end
      ||'/'
      ||DECODE(A.mes_nac,'JAN','01','FEB','02','MAR','03','APR','04','MAY','05','JUN','06','JUL','07','AUG','08','SEP','09','OCT','10','NOV','11','DEC','12')
      ||'/'
      ||A.ANO_NAC) FECHA_NACIMIENTO
    into v_vc_tipo_documento,
         v_vc_nombres,
         v_vc_primer_nombre,
         v_vc_segundo_nombre,
         v_vc_primer_apellido,
         v_vc_segundo_apellido,
         v_vc_sexo,
         v_vc_direccion_residencia,
         v_vc_telefono_residencia,
         v_vc_email,
         v_vc_mes_nac,
         v_vc_dia_nac,
         v_vc_ano_nac,
         v_vc_fecha_nacimiento    
    FROM A_ASPIRANTES A
    Where Numdoc        = V_Vc_Numero_Documento
    AND CODIGO_FACULTAD = v_vc_programa
    And Jornada_Facultad= V_Vc_Jornada;
    Select TRIM(T.Nombre)
    into   V_Vc_Nombre_Programa
    From   A_Facultades T 
    Where  T.Codigo||T.Jornada=V_Vc_Programa||V_Vc_Jornada;
    V_Nm_Ser_Pilo:=Esspp(V_Vc_Numero_Documento);
    If V_Nm_Ser_Pilo > 0 Then
       V_nm_Tipo_Matricula:=33;
    Else
       V_nm_Tipo_Matricula:=30;
    End If;
    Select to_char(Max(X.Fecha),'DD/MM/YYYY')
    Into   V_Vc_Fecha_Vencimiento
    From (
    Select Fecha_Ordinaria Fecha
    From   G_Parametros_Liquidacion Pl 
    Where  Pl.Anio = Substr(V_Vc_Periodo,0,4)
    AND    PL.CICLO= Substr(V_Vc_Periodo,5,2)
    And    Pl.Codtran='30' 
    And    Pl.Codigo_Facultad=V_Vc_Programa
    And    Pl.Jornada_Facultad=V_Vc_Jornada
    Union
    Select Ai.Fecha_Pago_Inscripcion fecha
    From   A_Aspirantes_Interesados Ai
    Where  Ai.Numero_Documento = V_Vc_Numero_Documento
    And    Ai.Codigo_Facultad = V_Vc_Programa
    and    ai.jornada_facultad = V_Vc_Jornada) x;
    LS_PAGO_INS(v_vc_numero_documento, v_vc_programa, V_Vc_Jornada); --registro en g_otros_pagos
    Htp.Prn('{');
    Htp.Prn('"status":"'          || 'ok' || '",');
    Htp.Prn('"tipoDocumento":"'   || v_vc_tipo_documento || '",');
    Htp.Prn('"documento":"'       || v_vc_numero_documento || '",');
    Htp.Prn('"nombres":"'         || V_Vc_Nombres || '",');
    Htp.Prn('"primerNombre":"'    || V_Vc_Primer_Nombre || '",');
    Htp.Prn('"segundoNombre":"'   || V_Vc_Segundo_Nombre || '",');
    Htp.Prn('"primerApellido":"'  || V_Vc_Primer_Apellido|| '",');
    Htp.Prn('"segundoApellido":"' || V_Vc_Segundo_Apellido|| '",');
    Htp.Prn('"sexo":"'            || V_Vc_Sexo|| '",');
    Htp.Prn('"direccionResidencia":"' || V_Vc_Direccion_Residencia|| '",');
    Htp.Prn('"telefonoResidencia":"' || V_Vc_Telefono_Residencia|| '",');
    Htp.Prn('"email":"'           || V_Vc_Email || '",');
    Htp.Prn('"mesNacimiento":"'   || V_Vc_Mes_Nac || '",');
    Htp.Prn('"diaNacimiento":"'   || V_Vc_Dia_Nac || '",');
    Htp.Prn('"codigoFacultad":"'  || v_vc_programa || '",');
    Htp.Prn('"Codigo":"'          || V_Vc_Codigo || '",');
    Htp.Prn('"jornadaFacultad":"' || V_Vc_Jornada || '",');
    Htp.Prn('"anioNacimiento":"'  || V_Vc_Ano_Nac || '",');
    Htp.Prn('"fechaNacimiento":"' || V_Vc_Fecha_Nacimiento || '",');
    Htp.Prn('"nombrePrograma":"'  || V_Vc_Nombre_Programa || '",');
    Htp.Prn('"anio":"'            || Substr(V_Vc_Periodo,0,4) || '",');
    Htp.Prn('"ciclo":"'           || Substr(V_Vc_Periodo,5,2) || '",');
    Htp.Prn('"serPilo":"'         || V_Nm_Ser_Pilo || '",');
    Htp.Prn('"tipoMatricula":"'   || V_nm_Tipo_Matricula || '",');
    Htp.Prn('"fechaVencimiento":"' || V_Vc_Fecha_Vencimiento || '",');
    Htp.Prn('"pais":"'             || '57' || '",');
    Htp.Prn('"departamento":"'     || '11' || '",');
    Htp.Prn('"poblacion":"'        || '1' || '"');
    Htp.Prn('}');
    Exception
    WHEN utl_http.transfer_timeout THEN --mariano rua mejia 02/10/2020
     Rollback;
     Htp.Prn('{"status":"fail","mensaje": "TIMEOUT -> ' || Pkg_Utils.Acentos(Sqlerrm) || '"}') ;
    when others then
    Rollback;
    Htp.Prn('{"status":"fail","mensaje":"' || Pkg_Utils.Acentos(Sqlerrm) || '"}') ;
  End Getdatosfactura;
  
 function tieneInscripcionSPP(p_vc_documento varchar2) return number as
    v_retorno number;
  begin
    Select Count(*)
    into v_retorno
    FROM admisiones.a_aspirantes ap,
      admisiones.beneficiarios_becas bb
    Where Ap.Numdoc=Bb.Documento
    AND ap.ANIO    =bb.ANIO
    AND ap.CICLO   =bb.CICLO
    AND ap.numdoc  =p_vc_documento;
      Return V_Retorno;
   End Tieneinscripcionspp;
   
  Function EstaMatriculado (P_Vc_Documento Varchar2) Return Number as
     v_retorno number;
  begin
    Select Count(*)
    into v_retorno
    FROM admisiones.DATOS_PERSONALES D
    INNER JOIN admisiones.B_ESTUDIANTES B
    On D.Codigo_Estudiante  = B.Codigo
    WHERE B.INDICADOR_PAGO IN ('P','V')
    And D.Numero_Documento  = P_Vc_Documento
    And B.Tipo_De_Ingreso  In ('NV','TE','TI','RA','RI','NR','ME');
    Return V_Retorno;
   End EstaMatriculado;

procedure continuarProceso(
    p_parametro in nclob
) as
    data_c json default json(p_parametro) ;
    p_numdoc varchar2(16) default data_c.get('documento').get_string;
    p_codigo_facultad varchar2(8) default data_c.get('programa').get_string;
    p_jornada_facultad varchar2(4) default data_c.get('jornada').get_string;
    v_periodo varchar2(8);
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_interesado number;
    v_aspirante number;
    v_tipdoc a_aspirantes.tipdoc%type;
    v_cerrado number;
    js_respuesta json := json();
begin
    owa_util.mime_header('application/json', false, 'utf8');
    owa_util.http_header_close;
    if p_codigo_facultad >= '71' then
        json.put(js_respuesta, 'status', 'go');
        json.put(js_respuesta, 'mensaje', getTexto('7'));
        json.htp(js_respuesta);
        return;
    end if;
    v_periodo := getPeriodo(p_codigo_facultad);
    v_anio := substr(v_periodo,0,4);
    v_ciclo := substr(v_periodo,5,2);
    select
        (select count(*) from desarrollospre.cti_interesado i
        where i.numdoc = p_numdoc
        and i.codigo_facultad = p_codigo_facultad
        and i.jornada_facultad = p_jornada_facultad
        and i.anio || i.ciclo = v_anio || v_ciclo) as interesado,
        (select count(*) from a_aspirantes a
        where a.numdoc = p_numdoc
        and a.codigo_facultad = p_codigo_facultad
        and a.jornada_facultad = p_jornada_facultad
        and a.anio || a.ciclo = v_anio || v_ciclo) as aspirante
    into v_interesado, v_aspirante
    from dual;
    
    if v_aspirante > 0 then
        select a.tipdoc
        into v_tipdoc
        from a_aspirantes a
        where a.numdoc = p_numdoc
        and a.codigo_facultad = p_codigo_facultad
        and a.jornada_facultad = p_jornada_facultad
        And A.Anio || A.Ciclo = V_Anio || V_Ciclo;
        if v_tipdoc in ('P','E','V') and esAutorizadoPrograma(p_numdoc, p_codigo_facultad, p_jornada_facultad, v_anio, v_ciclo) <= 0 and esAutorizadoExtranjero(p_numdoc, v_anio, v_ciclo) = 0 then
            json.put(js_respuesta, 'status', 'fail');
            json.put(js_respuesta, 'mensaje', getTexto('8'));
            json.htp(js_respuesta);
            return;
        end if;
    end if;
    
    if v_interesado > 0 and v_aspirante > 0 then
        json.put(js_respuesta, 'status', 'go');
        json.put(js_respuesta, 'mensaje', getTexto('7'));
        json.htp(js_respuesta);
    elsif v_interesado > 0 and v_aspirante <= 0 then
        v_cerrado := estaCerrado(p_codigo_facultad, p_jornada_facultad);
        if v_cerrado > 0 then
            json.put(js_respuesta, 'status', 'fail');
            json.put(js_respuesta, 'mensaje', getTexto('10'));
            json.htp(js_respuesta);
            return;
        end if;
        begin
            insert into a_aspirantes(
                codigo,
                nombre,
                codigo_facultad,
                jornada_facultad,
                fac_origen,
                jor_origen,
                codigo_transaccion,
                apellidos,
                nombres,
                tipdoc,
                numdoc,
                tipoest,
                anio,
                ciclo,
                fecha_inscripcion,
                valor_matricula,
                motivacion,
                email,
                celular,
                entrevista,
                lectura,
                tipo_inscripcion,
                primer_nombre,
                segundo_nombre,
                primer_apellido,
                segundo_apellido
            )
            select
                seq_inscripcion.nextval, 
                regexp_replace(i.primer_apellido || ' ' || i.segundo_apellido || ' ' || i.primer_nombre || ' ' || i.segundo_nombre, '[ ]+', ' '),
                i.codigo_facultad, 
                i.jornada_facultad,
                i.codigo_facultad, 
                i.jornada_facultad,
                '01',
                regexp_replace(i.primer_apellido || ' ' || i.segundo_apellido, '[ ]+', ' '),
                regexp_replace(i.primer_nombre || ' ' || i.segundo_nombre, '[ ]+', ' '),
                i.tipdoc,
                i.numdoc,
                'NUEVO',
                i.anio,
                i.ciclo,
                sysdate,
                0,
                'E',
                i.email,
                i.celular,
                '-',              
                'INTERNET'||' '||to_char(sysdate,'YYYYMMDD HH:MM:SS'),  
                null,
                i.primer_nombre,
                i.segundo_nombre,
                i.primer_apellido,
                i.segundo_apellido
            from desarrollospre.cti_interesado i
            where
                i.numdoc = p_numdoc
                and i.codigo_facultad = p_codigo_facultad
                and i.jornada_facultad = p_jornada_facultad
                --No se pueden agregar los de postgrado
                and i.codigo_facultad < '71'
                and not exists (select 1 from a_aspirantes a where a.numdoc = i.numdoc and a.codigo_facultad = i.codigo_facultad and a.jornada_facultad = i.jornada_facultad)
                and i.anio = v_anio
                and i.ciclo = v_ciclo
                ;
            commit;
            json.put(js_respuesta, 'status', 'go');
            json.put(js_respuesta, 'mensaje', getTexto('7'));
            json.htp(js_respuesta);
        exception
        when others then
            rollback;
            json.put(js_respuesta, 'status', 'fail');
            json.put(js_respuesta, 'mensaje', 'No se logró registrar al aspirante - ' || sqlerrm);
            json.put(js_respuesta, 'sqlerrm', sqlerrm);
            json.htp(js_respuesta);
        end;
    elsif v_interesado <= 0 and v_aspirante <= 0 then
        json.put(js_respuesta, 'status', 'fail');
        json.put(js_respuesta, 'mensaje', getTexto('16'));
        json.htp(js_respuesta);
    elsif v_interesado <= 0 and v_aspirante > 0 then
        begin
            update desarrollospre.cti_interesado i set i.anio = v_anio, i.ciclo = v_ciclo
            where i.numdoc = p_numdoc
            and i.codigo_facultad = p_codigo_facultad
            and i.jornada_facultad = p_jornada_facultad;
            if sql%rowcount != 1 then
                json.put(js_respuesta, 'status', 'go');
                json.put(js_respuesta, 'mensaje', getTexto('7'));
                json.htp(js_respuesta);
            else
                json.put(js_respuesta, 'status', 'fail');
                json.put(js_respuesta, 'mensaje', 'FAIL Aspirante no registrado. [1]');
                json.htp(js_respuesta);
            end if;
            commit;
        exception
        when others then
            rollback;
            json.put(js_respuesta, 'status', 'fail');
            json.put(js_respuesta, 'mensaje', 'Interesado no registrado');
            json.put(js_respuesta, 'sqlerrm', sqlerrm);
            json.htp(js_respuesta);
        end;
    else
        json.put(js_respuesta, 'status', 'fail');
        json.put(js_respuesta, 'mensaje', 'Aspirante no registrado');
        json.htp(js_respuesta);
    end if;
exception
when others then
    json.put(js_respuesta, 'status', 'fail');
    json.put(js_respuesta, 'mensaje', sqlerrm);
    json.put(js_respuesta, 'sqlerrm', sqlerrm);
    json.htp(js_respuesta);
end continuarProceso;   

procedure getMundo as
    pais doctorados.doc_paises%rowtype;
    v_coddepto a_divipola.codigo_departamento%type;
    v_nomdepto a_divipola.nom_departamento%type;
    v_codmcipio a_divipola.codigo_municipio%type;
    v_nommcipio a_divipola.nom_municipio%type;
    CURSOR C_PAISES IS SELECT * FROM DOCTORADOS.DOC_PAISES WHERE ID_PAIS NOT IN (1) ORDER BY NOMBRE_PAIS;
    cursor c_deptos is select distinct codigo_departamento, nom_departamento from a_divipola order by nom_departamento;
    cursor c_mcipios(p_codigo_departamento varchar2) is select distinct codigo_municipio, nom_municipio from admisiones.a_divipola where codigo_departamento = p_codigo_departamento order by nom_municipio;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    htp.prn('[');
    htp.prn('{');
    htp.prn('"codigo":1,');
    htp.prn('"nombre":"COLOMBIA",');
    htp.prn('"deptos":[');
    open c_deptos;
    loop
        fetch c_deptos
        into v_coddepto, v_nomdepto;
        if c_deptos%found and c_deptos%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_deptos%notfound;
        htp.prn('{');
        htp.prn('"codigo":"' || v_coddepto || '",');
        htp.prn('"nombre":"' || pkg_utils.acentos(v_nomdepto) || '",');
        htp.prn('"mcipios":[');
        open c_mcipios(v_coddepto);
        loop
            fetch c_mcipios
            into v_codmcipio, v_nommcipio;
            if c_mcipios%found and c_mcipios%rowcount > 1 then
                htp.prn(',') ;
            end if;
            exit when c_mcipios%notfound;
            htp.prn('{');
            htp.prn('"codigo":"' || v_codmcipio || '",');
            htp.prn('"nombre":"' || pkg_utils.acentos(v_nommcipio) || '"');
            htp.prn('}');
        end loop;
        close c_mcipios;
        htp.prn(']');
        htp.prn('}');
    end loop;
    close c_deptos;
    htp.prn(']');
    htp.prn('},');
    open c_paises;
    loop
        fetch c_paises
        into pais;
        if c_paises%found and c_paises%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_paises%notfound;
        htp.prn('{');
        htp.prn('"codigo":' || pais.id_pais || ',');
        htp.prn('"nombre":"' || pkg_utils.acentos(pais.nombre_pais) || '",');
        htp.prn('"deptos":[{"codigo":"99","nombre":"Extranjero",');
        htp.prn('"mcipios":[{"codigo":"999","nombre":"Extranjero"}]}]');
        htp.prn('}');
    end loop;
    htp.prn(']');
    close c_paises;
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
    close c_paises;
end getMundo;

procedure getEncSatisfaccion (
    p_id_encuesta number default 1
) as
    v_idep desarrollospre.cti_enc_preg_rel.id_enc_preg%type;
    v_idpr desarrollospre.cti_enc_pregunta.id_pregunta%type;
    v_preg desarrollospre.cti_enc_pregunta.pregunta%type;
    v_idpo desarrollospre.cti_enc_preg_opc.id_enc_preg_opc%type;
    v_opci desarrollospre.cti_enc_opcion.opcion%type;
    v_oval desarrollospre.cti_enc_opcion.valor%type;
    cursor c_preguntas(p_id_encuesta numeric) is
        select r.id_enc_preg, p.id_pregunta, p.pregunta
        from desarrollospre.cti_enc_pregunta p
        inner join desarrollospre.cti_enc_preg_rel r
        on p.id_pregunta = r.id_pregunta
        where
        r.id_encuesta = p_id_encuesta
        order by r.id_enc_preg;
    cursor c_opciones(p_id_pregunta numeric) is
        select r.id_enc_preg_opc, o.opcion, o.valor
        from desarrollospre.cti_enc_opcion o
        inner join desarrollospre.cti_enc_preg_opc r
        on o.id_opcion = r.id_opcion
        where
        r.id_pregunta = p_id_pregunta
        order by r.id_enc_preg_opc;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    for enc in (select * from desarrollospre.cti_encuesta e where id_encuesta = p_id_encuesta) loop
        htp.prn('{');
        htp.prn('"titulo":"' || pkg_utils.acentos(enc.nombre_encuesta) || '",');
        htp.prn('"intro":"' || pkg_utils.acentos(enc.texto_intro) || '",');
        htp.prn('"preguntas":[');
        open c_preguntas(enc.id_encuesta);
        loop
            fetch c_preguntas
            into v_idep, v_idpr, v_preg;
            if c_preguntas%found and c_preguntas%rowcount > 1 then
                htp.prn(',') ;
            end if;
            exit when c_preguntas%notfound;
            htp.prn('{');
            htp.prn('"id":' || v_idep || ',');
            htp.prn('"pregunta":"' || pkg_utils.acentos(v_preg) || '",');
            htp.prn('"opciones":[');
            open c_opciones(v_idpr);
            loop
                fetch c_opciones
                into v_idpo, v_opci, v_oval;
                if c_opciones%found and c_opciones%rowcount > 1 then
                    htp.prn(',') ;
                end if;
                exit when c_opciones%notfound;
                htp.prn('{');
                htp.prn('"id":' || v_idpo || ',');
                htp.prn('"opcion":"' || pkg_utils.acentos(v_opci) || '",');
                htp.prn('"valor":"' || pkg_utils.acentos(v_oval) || '"');
                htp.prn('}');
            end loop;
            close c_opciones;
            htp.prn(']');
            htp.prn('}');
        end loop;
        close c_preguntas;
        htp.prn(']');
        htp.prn('}');
    end loop;
end getEncSatisfaccion;

procedure guardarEncuesta(
    p_codigo varchar2,
    p_parametro varchar2
) as
    l_list json_list := json_list(p_parametro);
    v_id number;
    v_valor number;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    for i in 1..l_list.count loop
        v_id := json_ext.get_number(json(l_list.get(i)),'codigo');
        v_valor := to_number(json_ext.get_string(json(l_list.get(i)),'nombre'));
        insert into desarrollospre.cti_enc_respuesta
        select
            p_codigo,
            v_id,
            v_valor
        from dual
        where not exists (select 1 from desarrollospre.cti_enc_respuesta rr where rr.codigo_aspirante = p_codigo and rr.id_enc_preg = v_id);
    end loop;
    commit;
    htp.prn('{"status":"ok","mensaje":"Encuesta almacenada"}') ;
exception
when others then
    rollback;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}') ;
end guardarEncuesta;

procedure getResultado(
    p_codigo in number,
    o_mensaje out number,
    o_encuesta out number,
    o_guia_activa out number
) as
    v_aspirante a_aspirantes%rowtype;
    v_guia number default 0;
    v_espago number;
    v_encuesta number;
    v_fresultados number;
    v_admabierta number;
    v_cerrado number;
    v_spp number;
begin
    select count(*)
    into v_espago
    from g_otros_pagos op
    where op.codigo_est = p_codigo
    and op.indicador_pago = 'P'
    and op.activa = 1;
    --Si pago inscripcion
    if v_espago > 0 then
        select count(*)
        into v_encuesta
        from desarrollospre.cti_enc_respuesta rr inner join desarrollospre.cti_enc_preg_rel rp on rr.id_enc_preg = rp.id_enc_preg
        where rp.id_encuesta = 1
        and rr.codigo_aspirante = p_codigo;
        --No respondio encuesta
        if v_encuesta <= 0 then
            o_mensaje := 0;
            o_encuesta := 1;
            o_guia_activa := 0;
        --Si respondio encuesta
        else
            begin
                select *
                into v_aspirante
                from a_aspirantes a
                where a.codigo = p_codigo;
            exception
            when no_data_found then
                raise_application_error(-20001, 'No existe el aspirante: ' || p_codigo);
            end;
            v_spp := esSPP(v_aspirante.numdoc);
            select count(*)
            into v_fresultados
            from a_fechas_de_corte fc
            where fc.proceso like '%ADMISION ESTUDIANTES NUEVOS-PREGRADO%'
            and sysdate >= fc.fecha_publicacion;
            v_admabierta := admisionAbierta(v_aspirante.codigo_facultad, v_aspirante.jornada_facultad);
            v_cerrado := cerradoExtemporaneo(v_aspirante.codigo_facultad, v_aspirante.jornada_facultad);
            --No resultados activos
            if v_spp > 0 and v_aspirante.cod_def is not null then
                o_mensaje := 8;
                o_encuesta := 0;
                o_guia_activa := 1;
            elsif v_spp > 0 and v_aspirante.cod_def is null then
                o_mensaje := 6;
                o_encuesta := 0;
                o_guia_activa := 0;
            elsif v_fresultados <= 0 then
                --Programa cerrado
                if v_admabierta <= 0 then
                    o_mensaje := 3;
                    o_encuesta := 0;
                    o_guia_activa := 0;
                --Programa abierto
                else
                    --Si tiene codigo definitivo
                    if v_aspirante.cod_def is not null then
                        o_mensaje := 4;
                        o_encuesta := 0;
                        o_guia_activa := 1;
                    --No tiene codigo definitivo
                    else
                        o_mensaje := 3;
                        o_encuesta := 0;
                        o_guia_activa := 0;
                    end if;
                end if;
            --Si resultados activos
            else
                --Programa cerrado
                if v_admabierta <= 0 then
                    o_mensaje := 5;
                    o_encuesta := 0;
                    o_guia_activa := 0;
                --Programa abierto
                else
                    --Programa cerrado
                    if v_cerrado > 0 then
                        --Si tiene codigo definitivo
                        if v_aspirante.cod_def is not null then
                            o_mensaje := 4;
                            o_encuesta := 0;
                            o_guia_activa := 1;
                        --No tiene codigo definitivo
                        else
                            o_mensaje := 7;
                            o_encuesta := 0;
                            o_guia_activa := 0;
                        end if;
                    --Programa abierto
                    else
                        --Si tiene codigo definitivo
                        if v_aspirante.cod_def is not null then
                            o_mensaje := 4;
                            o_encuesta := 0;
                            o_guia_activa := 1;
                        --No tiene codigo definitivo
                        else
                            --Si entrevista mayor a 0 o nula
                            if v_aspirante.pentre is null or v_aspirante.pentre > 0 then
                                o_mensaje := 6;
                                o_encuesta := 0;
                                o_guia_activa := 0;
                            --No entrevista mayor a 0 o nula
                            else
                                o_mensaje := 7;
                                o_encuesta := 0;
                                o_guia_activa := 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    --No pago inscripcion
    else
        o_mensaje := 2;
        o_encuesta := 0;
        o_guia_activa := 0;
    end if;
    if o_guia_activa > 0 then
        select count(*)
        into v_espago
        from
            a_aspirantes a
                inner join
            g_guias_de_pago z
                on a.cod_def = z.codigo_est
        where
        z.activa = 1
        and z.indicador_pago in ('P','V')
        and a.codigo = p_codigo;
        if v_espago > 0 then
            o_guia_activa := 2;
        end if;
    end if;
exception
when others then
    raise;
end getResultado;

function getString(
    p_campo varchar2,
    p_json Json,
    obligatorio number default 1) return varchar2
as
begin
    begin
        return replace(trim(p_json.get(p_campo).get_string) ,'( )+',' ');
    exception
    when others then
        if obligatorio = 1 then
            raise_application_error(-20100, 'El campo ' || p_campo || ' no viene informado y es obligatorio: ' || sqlerrm);
        end if;
    end;
    return null;
end getString;

function admisionAbierta(
    p_facultad a_admision_anticipada.codigo_facultad%type,
    p_jornada a_admision_anticipada.jornada_facultad%type
) return number is
    v_periodo varchar2(8);
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_num number;
begin
    v_periodo := getPeriodo(p_facultad);
    v_anio := substr(v_periodo,0,4);
    v_ciclo := substr(v_periodo,5,2);
    select count(*)
    into v_num
    from a_admision_anticipada
    where codigo_facultad = p_facultad
    and jornada_facultad = p_jornada
    and anio = v_anio
    and ciclo = v_ciclo;
    v_num:=1;--mariano rua mejia 17/04/2020
    return v_num;
end admisionAbierta;

procedure salvarFoto (
    p_codigo number,
    p_ruta a_carnet_url.url%type
) as
    js_respuesta json := json();
    v_id number;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    v_id := seq_foto.nextval;
    insert into a_carnet_url
        (id, numero_documento, tipo, url)
    select v_id,
        a.cod_def,
        'E',
        'estudiantes/' || p_ruta
    from a_aspirantes a
    where a.codigo = p_codigo --Es el código del aspirante, no el del estudiante
    and a.cod_def is not null
    and a.codigo_facultad <= '70'
    and not exists (select 1 from a_carnet_url c where c.numero_documento = a.cod_def)
    union
    select v_id,
        a.cod_def,
        'E',
        'estudiantes/' || p_ruta
    from postgrado.a_aspirantes a
    where a.codigo = p_codigo --Es el código del aspirante, no el del estudiante
    and a.cod_def is not null
    and a.codigo_facultad > '70'
    and not exists (select 1 from a_carnet_url c where c.numero_documento = a.cod_def);
    if sql%rowcount != 1 then
        raise_application_error(-20002,'Registro inexistente o duplicado.');
    end if;
    commit;
    json.put(js_respuesta, 'status', 'ok');
    json.put(js_respuesta, 'mensaje', 'Foto agregada');
    json.htp(js_respuesta);
exception
when others then
    rollback;
    json.put(js_respuesta, 'status', 'fail');
    json.put(js_respuesta, 'mensaje', pkg_utils.acentos(sqlerrm));
    json.htp(js_respuesta);
end salvarFoto;

procedure crearUC (
    p_token in varchar2,
    p_tipo out numeric,
    p_uc out varchar2
) as
    v_codigo varchar2(16);
    v_codest b_estudiantes.codigo%type;
    v_up varchar2(16);
    v_usr a_claves_libres.usuario%type;
    v_psw a_claves_libres.clave%type;
    v_msg varchar2(512);
begin
    v_codigo := pkg_utils.f_leertoken(p_token, 1/*1440*/, '3764613438353137');
    select
        e.codigo,
        (select u.usuario || ',' || u.clave from a_usuarios u where u.codigo = e.codigo)
    into 
        v_codest, v_up
    from
        b_estudiantes e
            inner join
        a_aspirantes a
            on e.codigo = a.cod_def
    where
        e.indicador_pago in ('P','V', 'W')
        --and e.anio || to_number(e.ciclo) = e.ciclo_de_ingreso
        and e.tipo_de_ingreso in ('NV')
        and tiene_datosper(e.codigo) = '1'
        and a.codigo = to_number(v_codigo)
        and e.codigo_facultad <= '70'
    union
    select
        e.codigo,
        (select u.usuario || ',' || u.clave from a_usuarios u where u.codigo = e.codigo)
    from
        postgrado.b_estudiantes e
            inner join
        postgrado.a_aspirantes a
            on e.codigo = a.cod_def
    where
        e.indicador_pago in ('P','V', 'W')
        and e.tipo_de_ingreso in ('NV')--mariano rua mejia 27/05/2020
        and tiene_datosper(e.codigo) = '1'
        and a.codigo = to_number(v_codigo)
        and e.codigo_facultad > '70';
    if substr(v_codest,0,2) <= '70' and revisar_documentos(v_codest, v_msg) != 'OK' then
        raise_application_error(-20004, 'Sin documentos registrados');
    elsif substr(v_codest,0,2) > '70' and postgrado.revisar_documentos(v_codest, v_msg) != 'OK' then
        raise_application_error(-20004, 'Sin documentos registrados');
    end if;
    select cl.usuario, cl.clave
    into v_usr, v_psw
    from a_claves_libres cl
    where cl.indica is null
    and rownum <= 1;
    if v_up is null then
        begin
            select cl.usuario, cl.clave
            into v_usr, v_psw
            from a_claves_libres cl
            where cl.indica is null
            and rownum <= 1;
        exception
        when no_data_found then
            raise_application_error(-20001, 'Sin claves libres');
        end;
        insert into a_usuarios (usuario,clave,codigo,fecha,nombre_usuario,numero_documento)
        select v_usr, v_psw, e.codigo, to_char(sysdate,'DD-MM-YY'), e.nombre, p.numero_documento
        from
            a_aspirantes a
                inner join
            b_estudiantes e
                on e.codigo = a.cod_def
                inner join
            datos_personales p
                on p.codigo_estudiante = e.codigo
        where
            a.codigo = v_codigo
            and e.codigo_facultad <= '70'
            and not exists (select 1 from a_usuarios uu where uu.codigo = e.codigo)
        union
        select v_usr, v_psw, e.codigo, to_char(sysdate,'DD-MM-YY'), e.nombre, p.numero_documento
        from
            postgrado.a_aspirantes a
                inner join
            postgrado.b_estudiantes e
                on e.codigo = a.cod_def
                inner join
            postgrado.datos_personales p
                on p.codigo_estudiante = e.codigo
        where
            a.codigo = v_codigo
            and e.codigo_facultad > '70'
            and not exists (select 1 from a_usuarios uu where uu.codigo = e.codigo);
        if sql%rowcount != 1 then
            raise_application_error(-20002,'Usuario ya asignado o con datos faltantes.');
        end if;
        delete from a_claves_libres where usuario = v_usr and clave = v_psw;
        v_up := v_usr || ',' || v_psw;
        p_tipo := 1;
    else
        p_tipo := 0;
    end if;
    commit;
    p_uc := pkg_utils.f_crearToken(v_up, '3764613438353137');
exception
when no_data_found then
    rollback;
    raise_application_error(-20001, 'Estudiante no matriculado, sin documentos registrados o sin datos personales.');
when others then
    rollback;
    raise;
end crearUC;

procedure consultarUC(
    p_token varchar2
) as
    v_tipo number;
    v_msg varchar2(512);
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    crearUC(p_token, v_tipo, v_msg);
    if v_tipo = 1 then
        htp.prn('{"status":"go","mensaje":"' || v_msg || '"}');
    else
        htp.prn('{"status":"ok","mensaje":"' || v_msg || '"}');
    end if;
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end consultarUC;

FUNCTION ESTAENTRANSFERENCIAS(P_DOCUMENTO VARCHAR2, 
                              P_ANIO VARCHAR2, 
                              p_ciclo Varchar2) Return Number --mariano rua hay aspirantes que se inscriben en las transferencias 12/04/2018
As
 V_Retorno Number;
Begin
 Select Count(*)
 Into   V_Retorno
 From   A_Solicitud_Transferencias T
 Where  T.Numero_Documento = P_Documento
 AND    T.TIPO_TRANSFERENCIA = 'TE'
 and    t.anio||t.ciclo = P_ANIO||p_ciclo;
 return v_retorno;
end Estaentransferencias;

function esAutorizadoTransferencias(p_documento varchar2, p_anio varchar2, p_ciclo varchar2) return number as
    v_retorno number;
begin
  SELECT count(*)
  Into  V_Retorno 
  FROM AUTORIZACION_ADMISIONES t
  Where T.Documento   = P_Documento
  AND t.TIPO          = 'NUEVO'
  AND T.ANIO          = p_anio
  AND T.CICLO         = p_ciclo;
  Return V_Retorno;
end esAutorizadoTransferencias;

function tieneAutorizacionPadres(p_documento varchar2) return number as
    v_retorno number;
BEGIN
  SELECT COUNT(*) 
  INTO   V_RETORNO
  FROM   TBL_AUT_HD_MENORES_NUEVOS T 
  WHERE  t.DOCUMENTO = p_documento;
  RETURN V_RETORNO;
END tieneAutorizacionPadres;

end pkg_admisiones;