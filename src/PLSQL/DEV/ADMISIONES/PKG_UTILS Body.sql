create or replace package pkg_utils
as
    function f_leertoken(
            token       varchar2,
            vencimiento number default 1 / 24,
            llave       varchar2 default 'abcdefgh')
        return varchar2;
    function f_creartoken(
            p_datos varchar2,
            llave   varchar2 default 'abcdefgh')
        return varchar2;
    function f_crear_token_cookie(
            p_usuario varchar2,
            p_clave   varchar2)
        return varchar2;
    procedure p_leer_cookie(
            p_usuario in out varchar2,
            p_clave   in out varchar2,
            p_documento out varchar2,
            p_codigo out varchar2,
            p_nombre out varchar2) ;
    procedure p_redirect(
            p_procedimiento varchar2,
            p_parametros    varchar2 default null) ;
    procedure getestudiante(
            p_codigo     varchar2,
            p_encabezado number default 1) ;
    procedure getfacultad(
            p_codigo varchar2,
            p_header number default 1,
            p_activas number default 1) ;
    procedure getfacultades(
            p_tipo   number default 0,
            p_header number default 1,
            p_activas number default 1) ;
    procedure getmateria(
            p_facultad varchar2,
            p_jornada  varchar2,
            p_plan     varchar2,
            p_codigo   varchar2,
            p_header   number default 1) ;
    function porcentajeaprobacion(
            p_codigo b_estudiantes.codigo%type,
            p_anio a_notas.ano%type,
            p_ciclo a_notas.ciclo%type)
        return number;
    function creditosprematriculados(
            p_codigo b_estudiantes.codigo%type)
        return number;
    function semestreinferior(
            p_codigo b_estudiantes.codigo%type)
        return number;
    function acentos(
            texto varchar2)
        return varchar2;
    procedure getaniociclo(
            p_codigo in varchar2,
            p_anio out varchar2,
            p_ciclo out varchar2) ;
    function antesprimeranota(
            p_codigo varchar2,
            p_anio   varchar2,
            p_ciclo  varchar2)
        return number;
    function promedioponderadototal(
            p_codigo b_estudiantes.codigo%type)
        return number;
    function promedioponderadohasta(
            p_codigo b_estudiantes.codigo%type,
            p_anio  varchar2,
            p_ciclo varchar2,
            p_plan number default -1,
            p_round number default -1)
        return number;
    procedure getdocente(
            p_documento      varchar2,
            p_carga          number default 0,
            p_intersemestral number default 0) ;
    function getfoto(
            p_codigo varchar2)
        return varchar2;
    function porcentajecreditosaprobados(
            p_codigo b_estudiantes.codigo%type)
        return number;
    function porcentajecreditoscursados(
            p_codigo b_estudiantes.codigo%type)
        return number;    
    function semestrepromedio(
            p_codigo b_estudiantes.codigo%type)
        return number;
    procedure getaniocicloesquema(
            p_tipo_ciclo in number default 1,
            p_anio out varchar2,
            p_ciclo out varchar2,
            p_schema out varchar2) ;
    procedure aniociclojson(
            p_cod varchar2) ;
    function espilo(
            p_codigo varchar2)
        return number;
    function estasuspendido(
            p_codigo varchar2)
        return number;
    function esreintegro(
            p_codigo varchar2)
        return number;
    function retiromateria(
            p_codigo varchar2,
            p_mplan  varchar2,
            p_anio   varchar2,
            p_ciclo  varchar2)
        return number;
    function esingsinturno(
            p_codigo varchar2,
            p_anio   varchar2,
            p_ciclo  varchar2)
        return number;
    function nomateriasretiradas(
            p_codigo varchar2,
            p_anio   varchar2,
            p_ciclo  varchar2)
        return number;
    procedure getresumencreditos(
            p_codigo in varchar2,
            p_anio   in varchar2,
            p_ciclo  in varchar2,
            p_sem_inf out number,
            p_crd_max out number,
            p_crd_ins out number,
            p_dp in number default 1) ;
    function aplicaart47(
        p_codigo varchar2,
        p_val_dp number default 1)
    return number;
    function numerocreditosaprobados(
            p_codigo b_estudiantes.codigo%type)
        return number;
    procedure getfacultadjornada(
            p_codigo  varchar2,
            p_jornada varchar2,
            p_header  number default 1);
    procedure getfacultadesjornada(
            p_tipo   number default 0,
            p_header number default 1);
    function estaVigente(
            p_proceso varchar2,
            p_tipo number default 1)
        return number;
    procedure actualizarDocumento(
        p_tdoc_old varchar2,
        p_ndoc_old varchar2,
        p_tdoc_new varchar2,
        p_ndoc_new varchar2
    );
    procedure bloqueosGuia (
        p_codigo varchar2
    );

  Function cti_mim_email (p_tipo_documento in varchar,p_documento IN VARCHAR2)
RETURN VARCHAR2;

  Function cti_mim_doc_anterior (p_tipo_documento in varchar,p_documento IN VARCHAR2)
RETURN VARCHAR2;

    function getCredMax (
        p_codigo varchar2
    ) return number;
    procedure sendMail (
        destinatario varchar2,
        asunto varchar2,
        mensaje varchar2,
        cco varchar2 default null
    );
    procedure actualizarDPMulticodigo;
    procedure getPerfiles (
        token varchar2
    );
    function promedioPeriodoSTD (
        p_codigo b_estudiantes.codigo%type,
        p_anio a_notas.ano%type,
        p_ciclo a_notas.ciclo%type,
        p_plan b_estudiantes.plan_estudio%type default null,
        p_sin_perdidas number default 0,
        p_round number default -1
    ) return number;
    function promedioperiodo(
        p_codigo b_estudiantes.codigo%type,
        p_anio a_notas.ano%type,
        p_ciclo a_notas.ciclo%type,
        p_plan b_estudiantes.plan_estudio%type default null
    ) return number;
    function promedioPeriodoAprobadas (
        p_codigo b_estudiantes.codigo%type,
        p_anio a_notas.ano%type,
        p_ciclo a_notas.ciclo%type,
        p_plan b_estudiantes.plan_estudio%type default null
    ) return number;
    function promedioPeriodoCertificado (
        p_codigo b_estudiantes.codigo%type,
        p_anio a_notas.ano%type,
        p_ciclo a_notas.ciclo%type
    ) return number;
    procedure getCodigosXUsername (
        p_username varchar2
    );
    procedure getCodigosXDocumento (
        p_documento varchar2
    );
    function ciclosDespuesDeFinMateriasRA(
        p_codigo b_estudiantes.codigo%type
    ) return number;
    procedure getProgramasACargo(
        p_facultad varchar2
    );
    function esNuevo(
        p_codigo varchar2
    ) return number;
    function toChar(
        p_date date
    ) return varchar2;
end pkg_utils;
/

create or replace PACKAGE BODY PKG_UTILS AS
FUNCTION F_LEERTOKEN(
    TOKEN       VARCHAR2,
    VENCIMIENTO NUMBER DEFAULT 1/24,
    LLAVE       VARCHAR2 DEFAULT 'abcdefgh')
  RETURN VARCHAR2
IS
type tstring
IS
  TABLE OF VARCHAR2(2048);
  valores tstring := NEW tstring();
  v_clear_token VARCHAR2(4096);
  v_datos       VARCHAR2(2048) := '';
BEGIN
  --3764613438353137
  dbms_obfuscation_toolkit.DESDecrypt( input_string => utl_raw.cast_to_varchar2(hextoraw(TOKEN)), key_string => utl_raw.cast_to_varchar2(hextoraw(LLAVE)), decrypted_string => v_clear_token );
  v_clear_token := trim(v_clear_token);
  FOR txt IN
  (SELECT level,
    REGEXP_SUBSTR(v_clear_token, '[^#]+', 1, level) AS txt
  FROM dual
    CONNECT BY level <= LENGTH(regexp_replace(v_clear_token,'[^#]*'))+1
  )
  LOOP
    valores.extend();
    valores(txt.level) := txt.txt;
  END LOOP;
  IF sysdate <= to_date(valores(1), 'SSMIHH24DDMMRRRR') + VENCIMIENTO THEN
    valores.delete(valores.count);
    valores.delete(1);
    FOR i IN 2..(valores.count + 1)
    LOOP
      v_datos := v_datos || valores(i) || '#';
    END LOOP;
    RETURN(SUBSTR(v_datos, 1, LENGTH(v_datos) - 1));
  END IF;
  raise_application_error(-20997, 'Token vencido');
EXCEPTION
WHEN OTHERS THEN
  raise_application_error(-20998, 'Error en token: ' || SQLERRM);
END F_LEERTOKEN;
FUNCTION F_CREARTOKEN(
    P_DATOS VARCHAR2,
    LLAVE   VARCHAR2 DEFAULT 'abcdefgh' )
  RETURN VARCHAR2
IS
  v_token VARCHAR2(4096);
BEGIN
  v_token := TO_CHAR(sysdate, 'SSMIHH24DDMMRRRR') || '#' || p_datos || '#' || ABS(DBMS_RANDOM.RANDOM);
  RETURN(XAMPLECRIPTO(v_token, llave));
END F_CREARTOKEN;
function f_crear_token_cookie(
  p_usuario varchar2,
  p_clave varchar2)
  return varchar2
is
  v_token varchar2(1024);
begin
  select
    u.usuario||';'||u.clave||';'||u.codigo||';'||u.nombre_usuario||';'||u.numero_documento as token
  into
    v_token
  from
    a_usuarios u
  where
    u.usuario = p_usuario
    and u.clave = p_clave;
  return(f_creartoken(v_token, '3764613438353137'));
exception
when others then
    return('{"status":"fail","mensaje":"' || SQLERRM || '"}');
end f_crear_token_cookie;
procedure p_leer_cookie (
  p_usuario in out varchar2,
  p_clave in out varchar2,
  p_documento out varchar2,
  p_codigo out varchar2,
  p_nombre out varchar2
) as
  v_datos varchar2(2048);
  v_cookie owa_cookie.cookie;
begin
    v_cookie := owa_cookie.get('wUFAnew4');
    v_datos := f_leertoken(v_cookie.vals(1), 1/24, '3764613438353137');
    p_usuario := regexp_substr(v_datos,'[^;]+',1,1);
    p_clave := regexp_substr(v_datos,'[^;]+',1,2);
    p_codigo := regexp_substr(v_datos,'[^;]+',1,3);
    p_nombre := regexp_substr(v_datos,'[^;]+',1,4);
    p_documento := regexp_substr(v_datos,'[^;]+',1,5);
exception
when no_data_found then
  raise_application_error(-20999, 'Sesi√≥n no valida. Cierre la ventana y acceda nuevamente.');
when others then
  raise;
end p_leer_cookie;
procedure p_redirect (
  p_procedimiento varchar2,
  p_parametros varchar2 default null
) as
  v_base_url varchar2(128) := 'http://registro.lasalle.edu.co/pls/regadm/';
begin
  if p_parametros is null then
    owa_util.redirect_url(v_base_url || p_procedimiento);
  else
    owa_util.redirect_url(v_base_url || p_procedimiento || '?' || p_parametros);
  end if;
exception
when others then
  htp.p('<h1>' || SQLCODE || ' --- ' || SQLERRM || '</h1>');
end p_redirect;
procedure getEstudiante (
  p_codigo varchar2,
  p_encabezado number default 1
) as
    v_cod_contrario b_estudiantes.codigo%type;
    v_tipo_documento VARCHAR2(30);
    v_numero_documento VARCHAR2(12);
    v_telefono VARCHAR2(20);
    v_direccion VARCHAR2(100);
begin
  if p_encabezado > 0 then
      owa_util.mime_header('application/json', FALSE, 'iso-8859-1');
      owa_util.http_header_close;
  end if;
  for est in (
      select e.codigo, e.tipo_de_ingreso, e.nombre, e.ciclo_de_ingreso, e.indicador_pago, e.anio, e.ciclo, e.codigo_facultad, e.jornada_facultad, (select m.correo from correos_institucionales m where m.codigo = e.codigo) as correo, e.matriculados_ciclo_anterior from b_estudiantes e where e.codigo = p_codigo
      union
      select e.codigo, e.tipo_de_ingreso, e.nombre, e.ciclo_de_ingreso, e.indicador_pago, e.anio, e.ciclo, e.codigo_facultad, e.jornada_facultad, (select m.correo from correos_institucionales m where m.codigo = e.codigo) as correo, e.matriculados_ciclo_anterior from postgrado.b_estudiantes e where e.codigo = p_codigo
      union
      select e.codigo, e.tipo_de_ingreso, e.nombre, e.ciclo_de_ingreso, e.indicador_pago, e.anio, e.ciclo, e.codigo_facultad, e.jornada_facultad, (select m.correo from correos_institucionales m where m.codigo = e.codigo) as correo, e.matriculados_ciclo_anterior from yopal.b_estudiantes e where e.codigo = p_codigo
      UNION
      SELECT  T.Cod_Def CODIGO, 'NV' TIPO_DE_INGRESO, T.Nombre, T.ANIO||TO_NUMBER(T.CICLO) CICLO_DE_INGRESO,
      NVL((SELECT B.INDICADOR_PAGO FROM POSTGRADO.B_ESTUDIANTES B WHERE B.CODIGO = T.COD_DEF AND B.ANIO||B.CICLO=T.ANIO||T.CICLO),'X') INDICADOR_PAGO,
      T.ANIO, T.CICLO, T.Codigo_Facultad, T.Jornada_Facultad, 
       (SELECT m.correo FROM correos_institucionales m WHERE m.codigo = T.COD_dEF
        ) AS correo,
       NVL((SELECT B.Matriculados_Ciclo_Anterior FROM POSTGRADO.B_ESTUDIANTES B WHERE B.CODIGO = T.COD_DEF AND B.ANIO||B.CICLO=T.ANIO||T.CICLO),'X')  matriculados_ciclo_anterior
      FROM POSTGRADO.A_Aspirantes T WHERE T.Cod_Def=p_codigo
      UNION
      SELECT  T.Cod_Def CODIGO, 'NV' TIPO_DE_INGRESO, T.Nombre, T.ANIO||TO_NUMBER(T.CICLO) CICLO_DE_INGRESO,
      NVL((SELECT B.INDICADOR_PAGO FROM B_ESTUDIANTES B WHERE B.CODIGO = T.COD_DEF AND B.ANIO||B.CICLO=T.ANIO||T.CICLO),'X') INDICADOR_PAGO,
      T.ANIO, T.CICLO, T.Codigo_Facultad, T.Jornada_Facultad, 
       (SELECT m.correo FROM correos_institucionales m WHERE m.codigo = T.COD_dEF
        ) AS correo,
       NVL((SELECT B.Matriculados_Ciclo_Anterior FROM B_ESTUDIANTES B WHERE B.CODIGO = T.COD_DEF AND B.ANIO||B.CICLO=T.ANIO||T.CICLO),'X')  matriculados_ciclo_anterior
      FROM A_Aspirantes T WHERE T.Cod_Def=p_codigo
    ) loop
    htp.prn('{"codigo":"' || est.codigo || '",');
    htp.prn('"tingreso":"' || est.tipo_de_ingreso || '",');
    htp.prn('"nombre":"' || pkg_utils.acentos(est.nombre) || '",');
    htp.prn('"indicadorp":"' || est.indicador_pago || '",');
    htp.prn('"cingreso":"' || est.ciclo_de_ingreso || '",');
    htp.prn('"facultad":"' || est.codigo_facultad || '",');
    htp.prn('"jornada":"' || est.jornada_facultad || '",');
    htp.prn('"foto":"' || pkg_utils.getFoto(est.codigo) || '",');
    if est.correo is not null then
        htp.prn('"correo":"' || est.correo || '",');
    end if;
    v_cod_contrario := b_prematricula_spring.f_get_codigo_contrario(p_codigo,est.anio,est.ciclo);
    if v_cod_contrario is not null then
        htp.prn('"codContrario":"' || v_cod_contrario || '",') ;
        htp.prn('"art47a":' || pkg_utils.aplicaArt47(p_codigo, 0) || ',') ;
        htp.prn('"art47b":' || pkg_utils.aplicaArt47(v_cod_contrario, 0) || ',') ;
    end if;
    htp.prn('"pilo":' || pkg_utils.espilo(p_codigo) || ',') ;
    htp.prn('"art47":' || pkg_utils.aplicaArt47(p_codigo) || ',') ;
    htp.prn('"prueba":' || pkg_utils.estaSuspendido(p_codigo) || ',') ;
    htp.prn('"reintegro":' || pkg_utils.esReintegro(p_codigo) || ',') ;
    htp.prn('"matcicloant":"' || est.matriculados_ciclo_anterior || '",') ;
    if to_number(est.ciclo_de_ingreso) > to_number(est.anio || to_number(est.ciclo)) then
        htp.prn('"ciclo":"' || est.ciclo_de_ingreso || '"');
    else
        htp.prn('"ciclo":"' || est.anio || to_number(est.ciclo) || '", ');
    end if;
    begin
        select nombre_documento, numero_documento, telefono, direccion 
        into v_tipo_documento, v_numero_documento, v_telefono, v_direccion
        from (select nombre_documento, numero_documento, nvl(telefono_casa, 'N/A') || ', ' ||  nvl(TELEFONO_OFICINA, 'N/A') || ', ' ||  nvl(TELEFONO_OTRO, 'N/A') telefono, direccion from admisiones.datos_personales where codigo_estudiante = p_codigo union
              select nombre_documento, numero_documento, nvl(telefono_casa, 'N/A') || ', ' ||  nvl(TELEFONO_OFICINA, 'N/A') || ', ' ||  nvl(TELEFONO_OTRO, 'N/A') telefono, direccion  from postgrado.datos_personales where codigo_estudiante = p_codigo union
              select nombre_documento, numero_documento, nvl(telefono_casa, 'N/A') || ', ' ||  nvl(TELEFONO_OFICINA, 'N/A') || ', ' ||  nvl(TELEFONO_OTRO, 'N/A') telefono, direccion  from yopal.datos_personales where codigo_estudiante = p_codigo);
        htp.prn('"tipoDocumento":"' || nvl(v_tipo_documento, '') || '", ');
        htp.prn('"numeroDocumento":"' || nvl(v_numero_documento, '') || '", ');
        htp.prn('"telefono":"' || nvl(v_telefono, '') || '", ');
        htp.prn('"direccion":"' || replace(nvl(v_direccion, ''), '"' , '') || '"');
    exception
        when others then
            htp.prn('"tipoDocumento":"", ');
            htp.prn('"numeroDocumento":"", ');
            htp.prn('"telefono":"", ');
            htp.prn('"direccion":""');
    end;
    
    htp.prn('}');
    return;
  end loop;
  raise_application_error(-20999, 'Registro no encontrado: ' || p_codigo);
exception
when others then
  htp.prn('{"status":"fail","mensaje":"' || SQLCODE || ' - ' || SUBSTR(SQLERRM,1,200) || '"}');
end getEstudiante;
procedure getFacultad (
  p_codigo varchar2,
  p_header number default 1,
  p_activas number default 1
) as
    type t_jornadas is ref cursor;
    jornadas t_jornadas;
    v_jornada a_facultades.jornada%type;
    v_insabierta a_facultades.abrir_inscripcion%type;
    v_fecha_resultados_adm varchar2(10);
begin
  if p_header > 0 then
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
  end if;
  for fac in (select f.codigo_facultad, f.nombre, d.email, d.contacto || ', ' || d.telefono as contacto from a_facultades_unica f left join directorio_programas d on f.codigo_facultad = d.codigo_facultad where f.codigo_facultad = p_codigo) loop
    htp.prn('{"codigo":"' || fac.codigo_facultad || '",');
    htp.prn('"nombre":"' || pkg_utils.acentos(fac.nombre) || '",');
    if fac.codigo_facultad < '71' then
        htp.prn('"tipo":0,');
        begin
            select to_char(fc.fecha_publicacion, 'DD/MM/RRRR')
            into v_fecha_resultados_adm
            from a_fechas_de_corte fc
            where fc.proceso like '%ADMISION ESTUDIANTES NUEVOS-PREGRADO%';
            htp.prn('"fa":"' || v_fecha_resultados_adm || '",');
        exception
        when no_data_found then
            null;
        end;
    else
        htp.prn('"tipo":1,');
    end if;
    begin
        htp.prn('"jornadas":[');
        if p_activas = 1 then
            open jornadas for select distinct ff.jornada, ff.abrir_inscripcion from a_facultades ff where ff.activa in ('S') and ff.codigo = p_codigo;
        elsif p_activas = 2 then
            open jornadas for select distinct ff.jornada, ff.abrir_inscripcion from a_facultades ff where ff.indicador in ('S') and ff.codigo = p_codigo;
        else
            open jornadas for select distinct ff.jornada, ff.abrir_inscripcion from a_facultades ff where ff.codigo = p_codigo;
        end if;
        loop fetch jornadas into v_jornada, v_insabierta;
            if jornadas%found and jornadas%rowcount > 1 then
                htp.prn(',');
            end if;
            exit when jornadas%notfound;
            htp.prn('{"jornada":"' || v_jornada || '","inscripcion":"' || v_insabierta || '"}');
        end loop;
        close jornadas;
        htp.prn('],');
    exception
    when others then
        close jornadas;
    end;
    htp.prn('"correo":"' || regexp_substr(fac.email, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 1, 1) || '",');
    htp.prn('"contacto":"' || pkg_utils.acentos(fac.contacto) || '"');
    htp.prn('}');
    return;
  end loop;
  raise_application_error(-20999, 'Registro no encontrado: ' || p_codigo);
exception
when others then
  htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getFacultad;
procedure getFacultades (
  p_tipo number default 0,
  p_header number default 1,
  p_activas number default 1
) as
  type t_facus IS REF CURSOR;
  facus t_facus;
  v_codfacu a_facultades.codigo%type;
begin
    if p_header > 0 then
        owa_util.mime_header('application/json', FALSE, 'utf-8');
        owa_util.http_header_close;
    end if;
    if p_activas = 1 then
        if p_tipo = 1 then
            open facus for select distinct f.codigo from a_facultades f where f.activa in ('S') and codigo <= '71' and codigo not in ('46');
        elsif p_tipo = 2 then
            open facus for select distinct f.codigo from a_facultades f where f.activa in ('S') and codigo > '71' and codigo not in ('DE','DA');
        elsif p_tipo = 3 then
            open facus for select distinct f.codigo from a_facultades f where f.activa in ('S') and codigo in ('46');
        elsif p_tipo = 4 then
            open facus for select distinct f.codigo from a_facultades f where f.activa in ('S') and codigo in ('DE','DA');
        else
            open facus for select distinct f.codigo from a_facultades f where f.activa in ('S');
        end if;
    elsif p_activas = 2 then
        if p_tipo = 1 then
            open facus for select distinct f.codigo from a_facultades f where f.indicador in ('S') and codigo <= '71' and codigo not in ('46');
        elsif p_tipo = 2 then
            open facus for select distinct f.codigo from a_facultades f where f.indicador in ('S') and codigo > '71' and codigo not in ('DE','DA');
        elsif p_tipo = 3 then
            open facus for select distinct f.codigo from a_facultades f where f.indicador in ('S') and codigo in ('46');
        elsif p_tipo = 4 then
            open facus for select distinct f.codigo from a_facultades f where f.indicador in ('S') and codigo in ('DE','DA');
        else
            open facus for select distinct f.codigo from a_facultades f where f.indicador in ('S');
        end if;
    else
        if p_tipo = 1 then
            open facus for select distinct f.codigo from a_facultades f where codigo <= '71' and codigo not in ('46');
        elsif p_tipo = 2 then
            open facus for select distinct f.codigo from a_facultades f where codigo > '71' and codigo not in ('DE','DA');
        elsif p_tipo = 3 then
            open facus for select distinct f.codigo from a_facultades f where codigo in ('46');
        elsif p_tipo = 4 then
            open facus for select distinct f.codigo from a_facultades f where codigo in ('DE','DA');
        else
            open facus for select distinct f.codigo from a_facultades f;
        end if;
    end if;
    htp.prn('[');
    loop fetch facus into v_codfacu;
        if facus%found and facus%rowcount > 1 then
            htp.prn(',');
        end if;
        exit when facus%notfound;
        pkg_utils.getFacultad(v_codfacu, 0, p_activas);
    end loop;
    close facus;
    htp.prn(']');
exception
when others then
    close facus;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getFacultades;
procedure getMateria (
  p_facultad varchar2,
  p_jornada varchar2,
  p_plan varchar2,
  p_codigo varchar2,
  p_header number default 1
) as
begin
  if p_header > 0 then
    owa_util.mime_header('application/json', FALSE, 'iso-8859-1');
    owa_util.http_header_close;
  end if;
  htp.prn('{');
  for mat in (
      select codigo, nombre, semestre, creditos, codigo_facultad, jornada_facultad, plan_estudio, intensidad_horaria from a_materias where codigo_facultad = p_facultad and jornada_facultad = p_jornada and plan_estudio = p_plan and codigo = p_codigo
      union
      select codigo, nombre, semestre, creditos, codigo_facultad, jornada_facultad, plan_estudio, intensidad_horaria from postgrado.a_materias where codigo_facultad = p_facultad and jornada_facultad = p_jornada and plan_estudio = p_plan and codigo = p_codigo
      union
      select codigo, nombre, semestre, creditos, codigo_facultad, jornada_facultad, plan_estudio, intensidad_horaria from yopal.a_materias where codigo_facultad = p_facultad and jornada_facultad = p_jornada and plan_estudio = p_plan and codigo = p_codigo
    ) loop
    htp.prn('"codigo":"' || mat.codigo || '",');
    htp.prn('"nombre":"' || pkg_utils.acentos(mat.nombre) || '",');
    htp.prn('"semestre":"' || mat.semestre || '",');
    htp.prn('"creditos":' || mat.creditos || ',');
    htp.prn('"facultad":"' || mat.codigo_facultad || '",');
    htp.prn('"jornada":"' || mat.jornada_facultad || '",');
    htp.prn('"ih":' || to_number(nvl(mat.intensidad_horaria, 0)) || ',');
    htp.prn('"plan":' || mat.plan_estudio);
    exit;
  end loop;
  htp.prn('}');
exception
when others then
  htp.prn('{"status":"fail","mensaje":"' || SQLCODE || ' - ' || SUBSTR(SQLERRM,1,200) || '"}');
end getMateria;
function porcentajeAprobacion (
  p_codigo b_estudiantes.codigo%type,
  p_anio a_notas.ano%type,
  p_ciclo a_notas.ciclo%type
) return number
is
  v_tomadas number;
  v_aprobadas number;
begin
  select count(*) 
  into v_tomadas
  from   a_notas n
  where  n.ano=p_anio
  and    n.ciclo=p_ciclo
  and    n.codigo_estudiante=p_codigo;

  select count(*) 
  into v_aprobadas
  from   a_notas n
  where  n.ano=p_anio
  and    n.ciclo=p_ciclo
  and    n.codigo_estudiante=p_codigo
  and   ((n.valor>=3.5 AND n.indicador='V') OR (n.valor>=3.0 AND n.indicador<>'V'));
  if v_tomadas = 0 then
    return(-1);
  end if;
  return(v_aprobadas / v_tomadas);
end porcentajeAprobacion;
function promedioPeriodoSTD (
  p_codigo b_estudiantes.codigo%type,
  p_anio a_notas.ano%type,
  p_ciclo a_notas.ciclo%type,
  p_plan b_estudiantes.plan_estudio%type default null,
  p_sin_perdidas number default 0,
  p_round number default -1
) return number
is
    v_notacrd number;
    v_creditos number;
    v_plan number;
    v_round number;
begin
    if p_plan is null then
        select
            to_number(e.plan_estudio)
        into v_plan
        from
            b_estudiantes e
        where
            e.codigo = p_codigo
        union
        select
            to_number(e.plan_estudio)
        from
            postgrado.b_estudiantes e
        where
            e.codigo = p_codigo
        union
        select
            to_number(e.plan_estudio)
        from
            yopal.b_estudiantes e
        where
            e.codigo = p_codigo;
    elsif p_plan = 'N' then
        v_plan := 1;
    else
        v_plan := to_number(p_plan);
    end if;
    if p_round >= 0 then
        v_round := p_round;
    else
        -- 13/07/2018 (jdcarranza) Seg√∫n solicitud de la OAR y por el estatuto todos los promedios se muestran con 1 entero 1 decimal.
        --Solo los estudiantes que entraron entre el 20041 y el 20081 tienen 2 cifras decimales
        /*select nvl((select 2 from b_estudiantes e where e.codigo = p_codigo and to_number(e.ciclo_de_ingreso) between 20041 and 20081), 1)
        into v_round
        from dual;*/
        v_round := 1;
    end if;
    if p_sin_perdidas <= 0 then
        if v_plan >= 3 then
            select
                x, y
            into v_notacrd, v_creditos
            from
                (
                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
                from b_estudiantes e
                inner join a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                union
                select sum(valor * creditos) x,
                    sum(creditos) y
                from (select valor, creditos
                      from postgrado.b_estudiantes e
                      inner join postgrado.a_notas n
                      on  e.codigo = n.codigo_estudiante
                      inner join postgrado.a_materias m
                      on  n.codigo_materia   = m.codigo
                      and e.codigo_facultad  = m.codigo_facultad
                      and e.jornada_facultad = m.jornada_facultad
                      where n.ano            = p_anio
                      and n.ciclo            = p_ciclo
                      and e.codigo           = p_codigo
                      union
                      SELECT     N.VALOR,
                                 M.CREDITOS
                      FROM       POSTGRADO.B_ESTUDIANTES E 
                      INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                      INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                      -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                      INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                        AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                        AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                        AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                        AND N.CODIGO_ESTUDIANTE = E.CODIGO
                      -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                      INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                           AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                           AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                           AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                      INNER JOIN ADMISIONES.A_FACULTADES F ON     F.CODIGO  = M.CODIGO_FACULTAD
                                                              AND F.JORNADA = M.JORNADA_FACULTAD
                      WHERE     E.CODIGO = p_codigo
                            AND  n.ano            = p_anio
                            and n.ciclo            = p_ciclo)
                union
                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
                from yopal.b_estudiantes e
                inner join yopal.a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join yopal.a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                ) z
            where
                z.x is not null;
            if v_creditos != 0 then
                return(round(v_notacrd/v_creditos, v_round));
            else
                return(0);
            end if;
        else
            select
                x
            into v_notacrd
            from
                (
                select avg(n.valor) x
                from b_estudiantes e
                inner join a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                union
                select avg(valor) x
                from (select valor, creditos
                      from postgrado.b_estudiantes e
                      inner join postgrado.a_notas n
                      on  e.codigo = n.codigo_estudiante
                      inner join postgrado.a_materias m
                      on  n.codigo_materia   = m.codigo
                      and e.codigo_facultad  = m.codigo_facultad
                      and e.jornada_facultad = m.jornada_facultad
                      where n.ano            = p_anio
                      and n.ciclo            = p_ciclo
                      and e.codigo           = p_codigo
                      union
                      SELECT     N.VALOR,
                                 M.CREDITOS
                      FROM       POSTGRADO.B_ESTUDIANTES E 
                      INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                      INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                      -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                      INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                        AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                        AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                        AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                        AND N.CODIGO_ESTUDIANTE = E.CODIGO
                      -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                      INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                           AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                           AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                           AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                      INNER JOIN ADMISIONES.A_FACULTADES F ON     F.CODIGO  = M.CODIGO_FACULTAD
                                                              AND F.JORNADA = M.JORNADA_FACULTAD
                      WHERE     E.CODIGO = p_codigo
                            AND  n.ano            = p_anio
                            and n.ciclo            = p_ciclo)
                union
                select avg(n.valor) x
                from yopal.b_estudiantes e
                inner join yopal.a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join yopal.a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                ) z
            where
                z.x is not null;
            return(round(v_notacrd, v_round));
        end if;
    else
        if v_plan >= 3 then
            select
                x, y
            into v_notacrd, v_creditos
            from
                (
                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
                from b_estudiantes e
                inner join a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                union
                select sum(valor * creditos) x,
                    sum(creditos) y
                from (select valor, creditos
                      from postgrado.b_estudiantes e
                      inner join postgrado.a_notas n
                      on  e.codigo = n.codigo_estudiante
                      inner join postgrado.a_materias m
                      on  n.codigo_materia   = m.codigo
                      and e.codigo_facultad  = m.codigo_facultad
                      and e.jornada_facultad = m.jornada_facultad
                      where n.ano            = p_anio
                      and n.ciclo            = p_ciclo
                      and e.codigo           = p_codigo
                      and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                      union
                      SELECT     N.VALOR,
                                 M.CREDITOS
                      FROM       POSTGRADO.B_ESTUDIANTES E 
                      INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                      INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                      -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                      INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                        AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                        AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                        AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                        AND N.CODIGO_ESTUDIANTE = E.CODIGO
                      -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                      INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                           AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                           AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                           AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                      INNER JOIN ADMISIONES.A_FACULTADES F ON     F.CODIGO  = M.CODIGO_FACULTAD
                                                              AND F.JORNADA = M.JORNADA_FACULTAD
                      WHERE     E.CODIGO = p_codigo
                            AND  n.ano            = p_anio
                            and n.ciclo            = p_ciclo
                            and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5)))
                union
                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
                from yopal.b_estudiantes e
                inner join yopal.a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join yopal.a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                ) z
            where
                z.x is not null;
            if v_creditos != 0 then
                return(round(v_notacrd/v_creditos, v_round));
            else
                return(0);
            end if;
        else
            select
                x
            into v_notacrd
            from
                (
                select avg(n.valor) x
                from b_estudiantes e
                inner join a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                union
                select avg(n.valor) x
                from postgrado.b_estudiantes e
                inner join postgrado.a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join postgrado.a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                union
                select avg(n.valor) x
                from yopal.b_estudiantes e
                inner join yopal.a_notas n
                on  e.codigo = n.codigo_estudiante
                inner join yopal.a_materias m
                on  n.codigo_materia   = m.codigo
                and e.codigo_facultad  = m.codigo_facultad
                and e.jornada_facultad = m.jornada_facultad
                where n.ano            = p_anio
                and n.ciclo            = p_ciclo
                and e.codigo           = p_codigo
                and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
                ) z
            where
                z.x is not null;
            return(round(v_notacrd, v_round));
        end if;
    end if;
exception
when no_data_found then
    return(0);
when others then
    return(sqlcode);
end promedioPeriodoSTD;
function promedioPeriodo (
  p_codigo b_estudiantes.codigo%type,
  p_anio a_notas.ano%type,
  p_ciclo a_notas.ciclo%type,
  p_plan b_estudiantes.plan_estudio%type default null
) return number
is
begin
    return(promedioPeriodoSTD(p_codigo, p_anio, p_ciclo, p_plan));
end promedioPeriodo;
function promedioPeriodoAprobadas (
  p_codigo b_estudiantes.codigo%type,
  p_anio a_notas.ano%type,
  p_ciclo a_notas.ciclo%type,
  p_plan b_estudiantes.plan_estudio%type default null
) return number
is
begin
    return(promedioPeriodoSTD(p_codigo, p_anio, p_ciclo, p_plan, 1));
end promedioPeriodoAprobadas;
function promedioPeriodoCertificado (
    p_codigo b_estudiantes.codigo%type,
    p_anio a_notas.ano%type,
    p_ciclo a_notas.ciclo%type
) return number
is
    n_es_graduado number;
begin
    select count( *)
    into n_es_graduado
    from admisiones.b_estudiantes e
    join admisiones.a_graduados a
    on(e.codigo                 = a.codigo_estudiante)
    where(e.materias_pendientes = 0
     or e.porcred_aprobado     >= 100)
    and a.fecha_grado          <= trunc(sysdate)
    and a.fecha_grado           > to_date('01/01/1960', 'DD/MM/YYYY')
    and(upper(a.tipo_grado)    <> 'POS'
     or a.tipo_grado           is null)
    and e.codigo                = p_codigo;
    if n_es_graduado > 0 then
        return(promedioPeriodoSTD(p_codigo, p_anio, p_ciclo, null, 1));
    else
        return(promedioPeriodoSTD(p_codigo, p_anio, p_ciclo, null, 0));
    end if;
exception
when others then
    dbms_output.put_line(sqlerrm);
    return(sqlcode);
end promedioPeriodoCertificado;
function creditosPrematriculados (
  p_codigo b_estudiantes.codigo%type
) return number
is
  v_creditos number;
    v_isRA number;
begin
    select count(*)
    into v_isRA
    from b_estudiantes e
    where e.codigo = p_codigo
    and e.tipo_de_ingreso in ('RA','NR','ME')
    and e.ciclo_de_ingreso = e.anio || to_number(e.ciclo);
    if v_isRA <= 0 then
        select sum(m.creditos)
        into v_creditos
        from
        b_estudiantes e
        inner join
        b_prematricula p
        on e.codigo = p.codigo_estudiante
        inner join
        a_materias m
        on m.codigo = p.materia_plan and m.plan_estudio = e.plan_estudio and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad
        where
        e.codigo = p_codigo and p.anio = e.anio and p.ciclo = e.ciclo;
    else
        select sum(m.creditos)
        into v_creditos
        from
        b_estudiantes e
        inner join
        b_prematricula p
        on e.codigo = p.codigo_estudiante
        inner join
        a_materias m
        on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad
        where
        e.codigo = p_codigo and p.anio = e.anio and p.ciclo = e.ciclo;
    end if;
    return(v_creditos);
exception
when others then
  return(-1);
end creditosPrematriculados;
function semestreInferior (
  p_codigo b_estudiantes.codigo%type
) return number
is
  v_semestre number;
begin
  select min(m.semestre)
  into v_semestre
  from
  b_estudiantes e
  inner join
  b_prematricula p
  on e.codigo = p.codigo_estudiante
  inner join
  a_materias m
  on m.codigo = p.materia_plan and m.plan_estudio = e.plan_estudio and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad
  where
  e.codigo = p_codigo and p.anio = e.anio and p.ciclo = e.ciclo;
  return(v_semestre);
exception
when others then
  return(-1);
end semestreInferior;
FUNCTION acentos(
    texto VARCHAR2 )
  RETURN VARCHAR2
IS
  txt VARCHAR2(4000);
BEGIN
  --txt := regexp_replace(txt, '\', '\u005c');
  txt := regexp_replace(texto, '[\/]+', '\u002f');
  txt := regexp_replace(txt, 'Ò', '\u00f1');
  txt := regexp_replace(txt, '·', '\u00e1');
  txt := regexp_replace(txt, 'È', '\u00e9');
  txt := regexp_replace(txt, 'Ì', '\u00ed');
  txt := regexp_replace(txt, 'Û', '\u00f3');
  txt := regexp_replace(txt, '˙', '\u00fa');
  txt := regexp_replace(txt, '¸', '\u00fc');
  txt := regexp_replace(txt, '—', '\u00d1');
  txt := regexp_replace(txt, '¡', '\u00c1');
  txt := regexp_replace(txt, '…', '\u00c9');
  txt := regexp_replace(txt, 'Õ', '\u00cd');
  txt := regexp_replace(txt, '”', '\u00d3');
  txt := regexp_replace(txt, '⁄', '\u00da');
  txt := regexp_replace(txt, '‹', '\u00dc');
  txt := regexp_replace(txt, '"', '\u0022');
  txt := regexp_replace(txt, '[^A-Za-z0-9,:-_\\ \.&]+', ' ');
  txt := regexp_replace(txt, '[ ]+', ' ');
  txt := regexp_replace(txt, '(ORA)( )*(-)*[0-9]+(:)*( )*', '');
  RETURN(trim(txt));
EXCEPTION
WHEN OTHERS THEN
  RETURN(texto);
END acentos;
procedure getAnioCiclo (
  p_codigo in varchar2,
  p_anio out varchar2,
  p_ciclo out varchar2
) as
  v_tipo_ciclo number;
begin
  if length(p_codigo) < 8 then
    v_tipo_ciclo := 1;
  elsif substr(p_codigo, 1, 2) = '46' then
    v_tipo_ciclo := 3;
  elsif substr(p_codigo, 1, 2) > '71' then
    v_tipo_ciclo := 2;
  else
    v_tipo_ciclo := 1;
  end if;
  if v_tipo_ciclo in (1, 2) then
    select pr.anio,
      pr.ciclo
    into p_anio,
      p_ciclo
    from desarrollospre.ss_periodo pr
    where pr.id_ciclo = v_tipo_ciclo
    and pr.id_estado_periodo = 1;
  else
    begin
      select
        ye.anio, ye.ciclo
      into
        p_anio, p_ciclo
      from
        yopal.b_estudiantes ye
      where
        --to_number(ye.ciclo_de_ingreso) <= to_number(ye.anio || to_number(ye.ciclo)) and
        ye.codigo = p_codigo;
    exception
    when others then
      raise_application_error(-20998, 'Estudiante no disponible aun:' || p_codigo || ' - ' || SQLERRM);
    end;
  end if;
end getAnioCiclo;
function antesPrimeraNota(
  p_codigo varchar2,
  p_anio varchar2,
  p_ciclo varchar2
) return number
is
  v_tipo_ciclo number;
  v_ind_fecha number;
begin
  if substr(p_codigo, 1, 2) = '46' then
    v_tipo_ciclo := 3;
  elsif substr(p_codigo, 1, 2) > '71' then
    v_tipo_ciclo := 2;
  else
    v_tipo_ciclo := 1;
  end if;
  if v_tipo_ciclo = 2 then
    --return(0);
    select count(*) into v_ind_fecha from postgrado.b_prematricula_notas_depurada where anio = p_anio and ciclo = p_ciclo;
  elsif v_tipo_ciclo = 1 then
    --select count(*) into v_ind_fecha from a_fechas_notas where anio = p_anio and ciclo = p_ciclo and sysdate >= fecha_inicial_primer_corte;
    select count(*) into v_ind_fecha from b_prematricula_notas_depurada where anio = p_anio and ciclo = p_ciclo;
  else
    --select count(*) into v_ind_fecha from yopal.ah_horizontal_actual where fecha_inicial_primer_corte is not null and sysdate >= fecha_inicial_primer_corte and anio = p_anio and ciclo = p_ciclo;
    select count(*) into v_ind_fecha from yopal.b_prematricula_notas_depurada where anio = p_anio and ciclo = p_ciclo;
  end if;
  if v_ind_fecha > 0 then
    v_ind_fecha := 1;
  end if;
  return(v_ind_fecha);
end antesPrimeraNota;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER PROMEDIO PONDERADO DE TODA LA CARRERA.
-- ****************************************************************************************************************************
    FUNCTION PROMEDIOPONDERADOTOTAL (
        P_CODIGO B_ESTUDIANTES.CODIGO%TYPE
    ) RETURN NUMBER IS
        V_ANIO  VARCHAR2 (4);
        V_CICLO VARCHAR2 (2);
    BEGIN
        -- OBENER A—O Y CICLO ACTUAL DEL ESQUEMA EN EL QUE SE ENCUENTRA EL ESTUDIANTE (ADMISIONES, POSTGRADO O YOLA).
        PKG_UTILS.GETANIOCICLO (P_CODIGO, V_ANIO, V_CICLO);
        -- EL SEGUNDO PERIODO TIENE EL ID '03' PARA TODAS LAS CARRERAS EXCEPTO INGENIERIA AGRONOMICA (YOPAL).
        IF SUBSTR (P_CODIGO, 0, 2) != '46' AND V_CICLO = '02' THEN
            V_CICLO := '03';
        END IF;
        -- OBTENIENDO PROMEDIO HASTA ULTIMO PERIODO ACTUAL.
        RETURN (PKG_UTILS.PROMEDIOPONDERADOHASTA (P_CODIGO, V_ANIO, V_CICLO));
    END PROMEDIOPONDERADOTOTAL;

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- OBTENER PROMEDIO DESDE INGRESO DEL ESTUDIANTE HASTA PERIODO DADO.
-- ****************************************************************************************************************************

    FUNCTION PROMEDIOPONDERADOHASTA (
        P_CODIGO B_ESTUDIANTES.CODIGO%TYPE, 
        P_ANIO   VARCHAR2, 
        P_CICLO  VARCHAR2,
        P_PLAN   NUMBER DEFAULT -1, 
        P_ROUND  NUMBER DEFAULT -1
    ) RETURN NUMBER IS
        V_CODIGO_MATERIA_ANTERIOR A_MATERIAS.CODIGO%TYPE DEFAULT 'zzz';
        PASS                      NUMBER DEFAULT 0;
        SUMCRED                   NUMBER DEFAULT 0;
        SUMNOTA                   NUMBER DEFAULT 0;
        V_PLAN                    NUMBER;
        V_PLAN_TXT                VARCHAR2 (4);
        V_ROUND                   NUMBER DEFAULT 1;
    BEGIN
        -- OBTENCION DEL PLAN DE ESTUDIO SI NO VIENE EN LA PETICION.
        IF (P_PLAN < 0) THEN    
            SELECT E.PLAN_ESTUDIO
            INTO   V_PLAN_TXT
            FROM   B_ESTUDIANTES E
            WHERE  E.CODIGO = P_CODIGO
            UNION
            SELECT E.PLAN_ESTUDIO
            FROM   POSTGRADO.B_ESTUDIANTES E
            WHERE  E.CODIGO = P_CODIGO
            UNION
            SELECT E.PLAN_ESTUDIO
            FROM   YOPAL.B_ESTUDIANTES E
            WHERE  E.CODIGO = P_CODIGO;

            -- SE VERIFICA SI EL ID DEL PLAN DE ESTUDIO OBTENIDO ES NUMERICO.
            IF REGEXP_LIKE(TRIM(V_PLAN_TXT), '^[0-9]+$') THEN
                V_PLAN := TO_NUMBER(V_PLAN_TXT);
            ELSE
                V_PLAN := -1;
            END IF;
        ELSE 
            V_PLAN := P_PLAN;
        END IF;

        -- CALCULAR PROMEDIO PONDERADO SI EL PLAN ES MAYOR QUE 3.
        IF (V_PLAN >= 3) THEN
            -- ITERANDO SOBRE LAS NOTAS OBTENIDAS POR EL ESTUDIANTE DESDE QUE INGRESO HASTA EL PERIODO SOLICITADO
            -- TENIENDO EN CUENTA LOS CREDITOS PARA HACER EL PROMEDIO PONDERADO.
            FOR NOTA IN (SELECT     N.CODIGO_MATERIA CODIGO_MATERIA_PLAN, 
                                    M.CREDITOS CREDITOS,
                                    N.VALOR NOTA,
                                    N.INDICADOR INDICADOR
                         FROM       B_ESTUDIANTES E
                         INNER JOIN A_NOTAS N ON     E.CODIGO       = N.CODIGO_ESTUDIANTE 
                                                 AND N.IND_HNVOPLAN = TO_CHAR(V_PLAN)
                         INNER JOIN A_MATERIAS M  ON     M.CODIGO           = N.CODIGO_MATERIA 
                                                     -- 16/08/2018 (JDCARRANZA) SE TRATA EL CASO DE ESTUDIANTES POR MOVILIDAD ENTRANTE SR36956.
                                                     AND M.PLAN_ESTUDIO     = (CASE WHEN E.TIPO_DE_INGRESO = 'ME' THEN M.PLAN_ESTUDIO ELSE N.IND_HNVOPLAN END)
                                                     AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD 
                                                     AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                         WHERE          N.CICLO NOT IN ('00')
                                    AND N.CODIGO_ESTUDIANTE = P_CODIGO
                                    -- VERIFICA QUE EL A—O Y CICLO ACTUAL SEAN INFERIORES A LOS DE LA PETICION.
                                    AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                                    -- 17/07/2018 (JDCARRANZA) SE OMITEN MATERIAS QUE PROVIENEN DE REINTEGRO POR ACTUALIZACI”N.
                                    AND CONCAT(N.ANO,N.CICLO) NOT IN (SELECT CONCAT(HE.ANIO, DECODE(HE.CICLO, '01', '01', '02', '03')) AS ANIOCICLO 
                                                                      FROM   HISTORICO_ESTUDIANTES HE 
                                                                      WHERE      HE.CODIGO=P_CODIGO 
                                                                             AND HE.TIPO_DE_INGRESO = 'RA'
                                                                             AND HE.INDICADOR_PAGO IN ('P','V'))
                         UNION ALL
                         SELECT CODIGO,
                                CREDITOS,
                                VALOR,
                                'V' INDICADOR
                         FROM   (-- MISMA CONSULTA PERO EN POSTGRADO.
                                 SELECT     M.CODIGO,
                                            M.CREDITOS,
                                            N.VALOR
                                 FROM       POSTGRADO.B_ESTUDIANTES E
                                 INNER JOIN POSTGRADO.A_NOTAS N ON     E.CODIGO       = N.CODIGO_ESTUDIANTE 
                                                                   AND N.IND_HNVOPLAN = TO_CHAR(V_PLAN)
                                 INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA 
                                                                      AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN 
                                                                      AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                                      AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                                 WHERE          N.CICLO NOT IN ('00')
                                            AND N.CODIGO_ESTUDIANTE = P_CODIGO
                                            AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                                            AND CONCAT(N.ANO,N.CICLO) NOT IN (SELECT CONCAT(HE.ANIO, DECODE(HE.CICLO, '01', '01', '02', '03')) AS ANIOCICLO 
                                                                              FROM   POSTGRADO.HISTORICO_ESTUDIANTES HE 
                                                                              WHERE      HE.CODIGO = P_CODIGO 
                                                                                     AND HE.TIPO_DE_INGRESO = 'RA' 
                                                                                     AND HE.INDICADOR_PAGO IN ('P','V'))                         
                                 UNION -- USANDO UNION PARA EVITAR DUPLICADOS.
                                 -- MATERIAS TOMADAS COMO ELECTIVAS DE LA BOLSA DE CREDITOS.
                                 SELECT     M.CODIGO,
                                            M.CREDITOS,
                                            N.VALOR
                                 FROM       POSTGRADO.B_ESTUDIANTES E 
                                 INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                                 INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                                 -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                                 INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                                   AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                                   AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                                   AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                                   AND N.CODIGO_ESTUDIANTE = E.CODIGO
                                 -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                                 INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                                      AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                                      AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                                      AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                                 WHERE      E.CODIGO = P_CODIGO) A
                         UNION ALL
                         -- MISMA CONSULTA PERO EN YOPAL (NO SE HACE JOIN CON A_NOTAS UTILIZANDO EL IND_HNVOPLAN).
                         SELECT     N.CODIGO_MATERIA,
                                    M.CREDITOS,
                                    N.VALOR,
                                    N.INDICADOR
                         FROM       YOPAL.B_ESTUDIANTES E
                         INNER JOIN YOPAL.A_NOTAS N ON E.CODIGO = N.CODIGO_ESTUDIANTE
                         INNER JOIN YOPAL.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA 
                                                          AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN 
                                                          AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD 
                                                          AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                         WHERE          N.CICLO NOT IN ('00')
                                    AND N.CODIGO_ESTUDIANTE = P_CODIGO
                                    AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                         ORDER BY   1, 
                                    3 DESC) LOOP
                -- VERIFICANDO SI LA MATERIA CAMBI” (LAS MATERIAS SE PUEDEN REPETIR EN LA CONSULTA).
                IF (V_CODIGO_MATERIA_ANTERIOR != NOTA.CODIGO_MATERIA_PLAN) THEN
                    V_CODIGO_MATERIA_ANTERIOR := NOTA.CODIGO_MATERIA_PLAN;
                    -- VERIFICANDO SI LA MATERIA FUE APROBADA O REPROBADA.
                    IF (   (NOTA.INDICADOR != 'V' AND NOTA.NOTA >= 3) 
                        OR (NOTA.INDICADOR = 'V' AND NOTA.NOTA >= 3.5)) THEN
                        PASS := 1;
                    ELSE
                        PASS := 0;
                    END IF;
                    SUMNOTA := SUMNOTA + (NOTA.CREDITOS * NOTA.NOTA);
                    SUMCRED := SUMCRED + NOTA.CREDITOS;
                -- SI ES LA MISMA MATERIA Y NO HA SIDO APROBADA (EN TEORIA NUNCA DEBERÕA PASAR POR ACA GRACIAS AL ORDENAMIENTO).
                ELSIF PASS != 1 THEN
                    SUMNOTA := SUMNOTA + (NOTA.CREDITOS * NOTA.NOTA);
                    SUMCRED := SUMCRED + NOTA.CREDITOS;
                END IF;
            END LOOP;
        -- CALCULAR EL PROMEDIO ARITMETICO.
        ELSE
            -- ITERANDO SOBRE LAS NOTAS OBTENIDAS POR EL ESTUDIANTE DESDE QUE INGRESO HASTA EL PERIODO SOLICITADO.
            FOR NOTA IN (
                SELECT N.CODIGO_MATERIA MPLAN,
                       N.VALOR N,
                       N.INDICADOR I
                FROM   A_NOTAS N
                WHERE      N.CICLO NOT IN ('00')
                       AND (   N.IND_HNVOPLAN = TO_CHAR(V_PLAN) 
                            OR N.IND_HNVOPLAN = (CASE V_PLAN WHEN 1 THEN 'N' WHEN 0 THEN 'A' ELSE 'NOMATCH' END))
                       AND N.CODIGO_ESTUDIANTE = P_CODIGO
                       AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                       -- 17/07/2018 (JDCARRANZA) SE OMITEN MATERIAS QUE PROVIENEN DE REINTEGRO POR ACTUALIZACI”N.
                       AND CONCAT(N.ANO,N.CICLO) NOT IN (SELECT CONCAT(HE.ANIO, DECODE(HE.CICLO, '01', '01','02', '03')) AS ANIOCICLO 
                                                         FROM   HISTORICO_ESTUDIANTES HE 
                                                         WHERE      HE.CODIGO=P_CODIGO 
                                                                AND HE.TIPO_DE_INGRESO = 'RA' 
                                                                AND HE.INDICADOR_PAGO IN ('P','V'))
                UNION ALL
                -- POSTGRADO.
                SELECT MPLAN,
                       N,
                       'V' I
                FROM   (-- ASIGNATURAS CURSADAS POR EL ESTUDIANTE.
                        SELECT N.CODIGO_MATERIA MPLAN,
                               N.VALOR N
                        FROM   POSTGRADO.A_NOTAS N
                        WHERE      N.CICLO NOT IN ('00')
                               AND (   N.IND_HNVOPLAN = TO_CHAR(V_PLAN) 
                                    OR N.IND_HNVOPLAN = (CASE V_PLAN WHEN 1 THEN 'N' WHEN 0 THEN 'A' ELSE 'NOMATCH' END))
                               AND N.CODIGO_ESTUDIANTE = P_CODIGO
                               AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                               -- 17/07/2018 (JDCARRANZA) SE OMITEN MATERIAS QUE PROVIENEN DE REINTEGRO POR ACTUALIZACI”N.
                               AND CONCAT(N.ANO,N.CICLO) NOT IN (SELECT CONCAT(HE.ANIO,DECODE(HE.CICLO,'01','01','02','03')) AS ANIOCICLO 
                                                                 FROM   POSTGRADO.HISTORICO_ESTUDIANTES HE 
                                                                 WHERE      HE.CODIGO=P_CODIGO 
                                                                        AND HE.TIPO_DE_INGRESO = 'RA'
                                                                        AND HE.INDICADOR_PAGO IN ('P','V'))
                        UNION -- USANDO UNION PARA EVITAR DUPLICADOS.
                        -- MATERIAS TOMADAS COMO ELECTIVAS DE LA BOLSA DE CREDITOS.
                        SELECT     M.CODIGO,
                                   N.VALOR
                        FROM       POSTGRADO.B_ESTUDIANTES E 
                        INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
                        INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                        -- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
                        INNER JOIN POSTGRADO.A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                                                          AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                                                          AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                                                          AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                                                          AND N.CODIGO_ESTUDIANTE = E.CODIGO
                        -- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
                        INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                                                             AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                                                             AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                                             AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
                        WHERE      E.CODIGO = P_CODIGO) A
                UNION ALL
                -- YOPAL.
                SELECT   N.CODIGO_MATERIA MPLAN,
                         N.VALOR N,
                         N.INDICADOR I
                FROM     YOPAL.A_NOTAS N
                WHERE        N.CICLO NOT IN ('00')
                         AND (   N.IND_HNVOPLAN = TO_CHAR(V_PLAN) 
                              OR N.IND_HNVOPLAN = (CASE V_PLAN WHEN 1 THEN 'N' WHEN 0 THEN 'A' ELSE 'NOMATCH' END))
                         AND N.CODIGO_ESTUDIANTE = P_CODIGO
                         AND TO_NUMBER(N.ANO || TO_NUMBER(REGEXP_REPLACE(N.CICLO, '[^0-9]+', '0'))) <= TO_NUMBER(P_ANIO || TO_NUMBER(P_CICLO))
                ORDER BY 1, 
                         2 DESC) LOOP
                -- VERIFICANDO SI LA MATERIA CAMBI” (LAS MATERIAS SE PUEDEN REPETIR EN LA CONSULTA).
                IF (V_CODIGO_MATERIA_ANTERIOR != NOTA.MPLAN) THEN
                    V_CODIGO_MATERIA_ANTERIOR := NOTA.MPLAN;
                    -- VERIFICANDO SI LA MATERIA FUE APROBADA O REPROBADA.
                    IF (   (NOTA.I != 'V' AND NOTA.N >= 3) 
                        OR (NOTA.I = 'V' AND NOTA.N >= 3.5)) THEN
                        PASS := 1;
                    ELSE
                        PASS := 0;
                    END IF;
                    SUMNOTA := SUMNOTA + NOTA.N;
                    SUMCRED := SUMCRED + 1;
                ELSIF PASS != 1 THEN
                    SUMNOTA := SUMNOTA + NOTA.N;
                    SUMCRED := SUMCRED + 1;
                END IF;
            END LOOP;
        END IF;
        -- VERIFICANDO SI SE ENCONTRARON ASIGNATURAS.
        IF (SUMCRED != 0) THEN
            IF (P_ROUND >= 0) THEN
                V_ROUND := P_ROUND;
            END IF;
            RETURN(ROUND(SUMNOTA / SUMCRED, V_ROUND));
        ELSE
            RETURN(0);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN(SQLCODE);        
    END PROMEDIOPONDERADOHASTA;

procedure getDocente (
    p_documento varchar2,
    p_carga number default 0,
    p_intersemestral number default 0
) as
    cursor carga(p_doc varchar2, p_anio varchar2, p_ciclo varchar2) is
        select distinct b.consecutivo from a_bloques b where b.numero_documento = p_doc and b.anio = p_anio and b.ciclo = p_ciclo
        union
        select distinct b.consecutivo from cactualpre.a_bloques b where b.numero_documento = p_doc and b.anio = p_anio and b.ciclo = p_ciclo
        union
        select distinct b.consecutivo from a_bloques_pos b where b.numero_documento = p_doc and b.anio = p_anio and b.ciclo = p_ciclo
        union
        select distinct b.consecutivo from cactualpre.a_bloques_pos b where b.numero_documento = p_doc and b.anio = p_anio and b.ciclo = p_ciclo;
    cursor carga_intersemestral(p_doc varchar2) is
        select
            f.codigo as codFacultad,
            trim(f.nombre) as nombreFacultad,
            f.jornada,
            f.sede,
            to_number(h.grupo_materia) as grupo,
            m.plan_estudio as plan,
            m.codigo as codMateria,
            trim(m.nombre) as nombreMateria
        from
            ah_horizontal_actual_curvac h
                inner join
            a_facultades f
                on h.codigo_facultad = f.codigo and h.jornada_facultad = f.jornada
                inner join
            a_materias m
                on m.codigo = h.codigo_materia and m.codigo_facultad = f.codigo and m.jornada_facultad = f.jornada
        where
            h.numero_documento = p_doc;
    v_anio varchar2(8);
    v_ciclo varchar2(4);
    v_consecutivo number;
    v_codF a_facultades.codigo%type;
    v_nomF a_facultades.nombre%type;
    v_jorF a_facultades.jornada%type;
    v_sedF a_facultades.sede%type;
    v_grup number;
    v_plan a_materias.plan_estudio%type;
    v_codM a_materias.codigo%type;
    v_nomM a_materias.nombre%type;
begin
    owa_util.mime_header('application/json', FALSE, 'iso-8859-1');
    owa_util.http_header_close;
    for doc in (
            select p.cedula, p.nombres, p.apellidos, (select m.correo from correos_docentes m where m.codigo = p.cedula) as email from ls_plantilla p where p.cedula=p_documento
            union
            select p.cedula, p.nombres, p.apellidos, (select m.correo from correos_docentes m where m.codigo = p.cedula) as email from cactualpre.ls_plantilla p where p.cedula=p_documento
            union
            select p.cedula, p.nombres, p.apellidos, (select m.correo from correos_docentes m where m.codigo = p.cedula) as email from cti_docentes_curvac p where p.cedula=p_documento) loop
        htp.prn('{');
        htp.prn('"documento":"' || doc.cedula || '",');
        htp.prn('"nombres":"' || doc.nombres || '",');
        htp.prn('"apellidos":"' || doc.apellidos || '",');
        htp.prn('"plantilla":' || aprobado_plantilla(doc.cedula) || ',');
        if p_carga = 0 then
            htp.prn('"email":"' || doc.email || '"');
        else
            pkg_utils.getAnioCiclo('0', v_anio, v_ciclo);
            htp.prn('"email":"' || doc.email || '",');
            htp.prn('"carga":');
            htp.prn('[');
            if p_intersemestral < 1 then
                open carga(doc.cedula, v_anio, v_ciclo);
                loop fetch carga into v_consecutivo;
                    if carga%found and carga%rowcount > 1 then
                        htp.prn(',');
                    end if;
                    exit when carga%notfound;
                    pkg_prematricula.grupo_json(v_consecutivo, 0);
                end loop;
                close carga;
            else
                open carga_intersemestral(doc.cedula);
                loop fetch carga_intersemestral into v_codF, v_nomF, v_jorF, v_sedF, v_grup, v_plan, v_codM, v_nomM;
                    if carga_intersemestral%found and carga_intersemestral%rowcount > 1 then
                        htp.prn(',');
                    end if;
                    exit when carga_intersemestral%notfound;
                    htp.prn('{');
                    htp.prn('"consecutivo":0,');
                    htp.prn('"cupo":0,');
                    htp.prn('"cupoDisponible":0,');
                    htp.prn('"eliminable":0,');
                    htp.prn('"facultadCursar":{"codFacultad":"' || v_codF || '","nombreFacultad":"' || v_nomF || '","jornada":"' || v_jorF || '","sede":{"sede":"' || v_sedF || '"}},');
                    htp.prn('"grupo":' || v_grup || ',');
                    htp.prn('"horario":[],');
                    htp.prn('"materiaCursar":{"codMateria":"' || v_codM || '","nombreMateria":"' || pkg_utils.acentos(v_nomM) || '","plan":"' || v_plan || '"}');
                    htp.prn('}');
                end loop;
                close carga_intersemestral;
            end if;
            htp.prn(']');
        end if;
        htp.prn('}');
        return;
    end loop;
    raise_application_error(-20111, 'Docente no existe');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || acentos(sqlerrm) || '"}') ;
end getDocente;
function getFoto(
    p_codigo varchar2
) return varchar2 is
    v_url_foto varchar2(512);
begin
    begin
        select acu.url
        into v_url_foto 
        from admisiones.a_carnet_url acu
        where acu.id in (select max(f.id) from admisiones.a_carnet_url f where f.numero_documento = p_codigo) and rownum <= 1;
        v_url_foto := 'http://zeus.lasalle.edu.co/fotos/' || v_url_foto;
    exception
    when no_data_found then
        v_url_foto := 'http://zeus.lasalle.edu.co/sia/fotos/' || p_codigo || '.gif';
    end;
    return(v_url_foto);
end getFoto;
function porcentajeCreditosAprobados (
    p_codigo b_estudiantes.codigo%type
) return number is
    sumcred number default 0;
    v_plan number;
    v_total_cred number;
    v_semestres number;
begin
    select sum(x), sum(y), sum(z)
    into v_plan, v_total_cred, v_semestres
    from
    (select max(e.plan_estudio) x, sum(m.creditos) y, max(m.semestre) z
    from b_estudiantes e inner join a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    union
    select max(e.plan_estudio), sum(m.creditos), max(m.semestre)
    from postgrado.b_estudiantes e inner join postgrado.a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    Union
    Select Max(E.Plan_Estudio), Sum(M.Creditos), Max(M.Semestre)
    From Yopal.B_Estudiantes E Inner Join Yopal.A_Materias M On E.Codigo_Facultad = M.Codigo_Facultad And E.Jornada_Facultad = M.Jornada_Facultad /*and e.plan_estudio = m.plan_estudio*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
    where m.semestre > 0 and e.codigo = p_codigo and m.plan_estudio=(select be.plan_estudio from yopal.b_estudiantes be where be.codigo=p_codigo)) zz;

    if v_total_cred = 0 then
        return(-1);
    end if;
    select sum(cr)
    into sumcred
    from
    (select
        nvl(sum(m.creditos),0) cr
    from
    b_estudiantes e
        inner join
    A_Notas N
        On E.Codigo = N.Codigo_Estudiante And E.Plan_Estudio = N.Ind_Hnvoplan
        inner join
    A_Materias M
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    postgrado.b_estudiantes e
        inner join
    postgrado.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    postgrado.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and n.valor >= 3.5
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    Yopal.B_Estudiantes E
        inner join
    Yopal.A_Notas N
        on e.codigo = n.codigo_estudiante /*and e.plan_estudio = n.ind_hnvoplan*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
        inner join
    Yopal.A_Materias M
        on m.codigo = n.codigo_materia /*and m.plan_estudio = n.ind_hnvoplan*/ and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    ) zz;
    return(nvl(sumcred, 0) / v_total_cred);
exception
when others then
    return(SQLCODE);
end porcentajeCreditosAprobados;
--------------------------------------------------------------------------------------------------------------------------------
--01mar2019
function porcentajeCreditosCursados (
    p_codigo b_estudiantes.codigo%type
) return number is
    sumcred number default 0;
    v_plan number;
    v_total_cred number;
    v_semestres number;
begin
    select sum(x), sum(y), sum(z)
    into v_plan, v_total_cred, v_semestres
    from
    (select max(e.plan_estudio) x, sum(m.creditos) y, max(m.semestre) z
    from b_estudiantes e inner join a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    union
    select max(e.plan_estudio), sum(m.creditos), max(m.semestre)
    from postgrado.b_estudiantes e inner join postgrado.a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    Union
    Select Max(E.Plan_Estudio), Sum(M.Creditos), Max(M.Semestre)
    From Yopal.B_Estudiantes E Inner Join Yopal.A_Materias M On E.Codigo_Facultad = M.Codigo_Facultad And E.Jornada_Facultad = M.Jornada_Facultad /*and e.plan_estudio = m.plan_estudio*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
    where m.semestre > 0 and e.codigo = p_codigo and m.plan_estudio=(select be.plan_estudio from yopal.b_estudiantes be where be.codigo=p_codigo)) zz;

    if v_total_cred = 0 then
        return(-1);
    end if;
    select sum(cr)
    into sumcred
    from
    (select
        nvl(sum(m.creditos),0) cr
    from
    b_estudiantes e
        inner join
    A_Notas N
        On E.Codigo = N.Codigo_Estudiante And E.Plan_Estudio = N.Ind_Hnvoplan
        inner join
    A_Materias M
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    ---and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    postgrado.b_estudiantes e
        inner join
    postgrado.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    postgrado.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    --and n.valor >= 3.5
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    Yopal.B_Estudiantes E
        inner join
    Yopal.A_Notas N
        on e.codigo = n.codigo_estudiante /*and e.plan_estudio = n.ind_hnvoplan*/ --mariano rua 12/04/2018 en yopal hay estudiantes con asignaturas en 2 planes ('4','7')
        inner join
    Yopal.A_Materias M
        on m.codigo = n.codigo_materia /*and m.plan_estudio = n.ind_hnvoplan*/ and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    --and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    ) zz;
    return(nvl(sumcred, 0) / v_total_cred);
exception
when others then
    return(SQLCODE);
end porcentajeCreditosCursados;
-------------------------------------------------
function semestrePromedio (
    p_codigo b_estudiantes.codigo%type
) return number is
    sumcred number default 0;
    v_plan number;
    v_total_cred number;
    v_semestres number;
begin
    select sum(x), sum(y), sum(z)
    into v_plan, v_total_cred, v_semestres
    from
    (select max(e.plan_estudio) x, sum(m.creditos) y, max(m.semestre) z
    from b_estudiantes e inner join a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    union
    select max(e.plan_estudio), sum(m.creditos), max(m.semestre)
    from postgrado.b_estudiantes e inner join postgrado.a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo
    union
    select max(e.plan_estudio), sum(m.creditos), max(m.semestre)
    from yopal.b_estudiantes e inner join yopal.a_materias m on e.codigo_facultad = m.codigo_facultad and e.jornada_facultad = m.jornada_facultad and e.plan_estudio = m.plan_estudio
    where m.semestre > 0 and e.codigo = p_codigo) zz;

    if v_total_cred = 0 then
        return(-1);
    end if;
    select sum(cr)
    into sumcred
    from
    (select
        sum(m.creditos) cr
    from
    b_estudiantes e
        inner join
    a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    union
    select
        sum(m.creditos) cr
    from
    postgrado.b_estudiantes e
        inner join
    postgrado.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    postgrado.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and n.valor >= 3.5
    union
    select
        sum(m.creditos) cr
    from
    yopal.b_estudiantes e
        inner join
    yopal.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    yopal.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    ) zz
    ;
    return(v_semestres * sumcred / v_total_cred);
exception
when others then
    return(SQLCODE);
end semestrePromedio;
procedure getAnioCicloEsquema (
    p_tipo_ciclo in number default 1,
    p_anio out varchar2,
    p_ciclo out varchar2,
    p_schema out varchar2
) as
begin
    select pr.anio,
        pr.ciclo,
        sh.schema
    into p_anio,
        p_ciclo,
        p_schema
    from desarrollospre.ss_periodo pr
    inner join desarrollospre.ss_schema sh
    on  pr.id_schema         = sh.id_schema
    where pr.id_ciclo        = p_tipo_ciclo
    and pr.id_estado_periodo = 1;
exception
when others then
    p_anio := null;
    p_ciclo := null;
    p_schema := null;
end getAnioCicloEsquema;
procedure anioCicloJson (
    p_cod varchar2
) as
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_schema varchar2(64);
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    pkg_utils.getAnioCicloEsquema(p_cod, v_anio, v_ciclo, v_schema);
    htp.prn('{');
    htp.prn('"anio":"' || v_anio || '",');
    htp.prn('"ciclo":"' || v_ciclo || '",');
    htp.prn('"esquema":"' || v_schema || '"');
    htp.prn('}');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || substr(sqlerrm,1,200) || '"}') ;
end anioCicloJson;
function esPilo (
    p_codigo varchar2
) return number is
    v_pertenece varchar2(8);
    v_convenio cti_convenio.nombre%type;
begin
    return pkg_util_convenios.perteneceAlConvenio(p_codigo, 1);
exception
when others then
    return(-1);
end esPilo;
function estaSuspendido (
    p_codigo varchar2
) return number is
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_ind number;
begin
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    if v_ciclo = '01' then
        v_anio := trim(to_char(to_number(v_anio) - 1, '0000'));
        v_ciclo := '02';
    elsif v_ciclo = '02' then
        v_ciclo := '01';
    end if;
    select to_number(pp.indicador)
    into v_ind
    from a_periodo_prueba pp
    where pp.codigo_estudiante = p_codigo and
    ((pp.ano = v_anio and pp.ciclo = v_ciclo) or pp.indicador >= 3)
    and rownum <= 1
    ;
    return(v_ind);
exception
when no_data_found then
    return(0);
when others then
    return(-1);
end estaSuspendido;
function esReintegro (
    p_codigo varchar2
) return number is
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_ind number;
begin
    pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    select count(*)
    into v_ind
    from a_solicitud_reintegro r
    where r.codigo_estudiante = p_codigo
    and r.anio = v_anio
    and r.ciclo = v_ciclo;
    if v_ind > 0 then
        v_ind := 1;
    else
        select count(*)
        into v_ind
        from b_estudiantes e
        where
        e.codigo = p_codigo
        and e.indicador_pago in ('P','V')
        and e.tipo_de_ingreso in ('RI')
        and e.ciclo_de_ingreso = e.anio || to_number(e.ciclo);
    end if;
    return(v_ind);
exception
when others then
    return(-1);
end esReintegro;
function retiroMateria (
    p_codigo varchar2,
    p_mplan varchar2,
    p_anio varchar2,
    p_ciclo varchar2
) return number is
    v_ip b_estudiantes.indicador_pago%type;
begin
    select he.indicador_pago
    into v_ip
    from historico_estudiantes he
    where he.codigo = p_codigo
    and he.anio = p_anio
    and he.ciclo = p_ciclo;
    if v_ip not in ('P','V') then
        return(0);
    end if;
    execute immediate
        'select p.indicador_pago from prematricula_' || p_anio || to_number(p_ciclo) || ' p where p.codigo_estudiante = :a and p.anio = :b and p.ciclo = :c and p.materia_plan = :d'
    into v_ip
    using p_codigo, p_anio, p_ciclo, p_mplan;
    if v_ip in ('K','C') then
        return(1);
    end if;
    return(0);
exception
when no_data_found then
    return(0);
when others then
    return(-1);
end retiroMateria;
function esIngSinTurno (
    p_codigo varchar2,
    p_anio varchar2,
    p_ciclo varchar2
) return number is
    v_ind number;
    v_anioa varchar2(4);
    v_cicloa varchar2(2);
begin
    if p_ciclo = '01' then
        v_cicloa := '02';
        v_anioa := trim(to_char(to_number(p_anio) - 1, '0000'));
    elsif p_ciclo = '02' then
        v_cicloa := '01';
        v_anioa := p_anio;
    end if;
    select
        count(e.codigo)
    into v_ind
    from
    b_estudiantes e
        inner join
    a_programas p
        on e.codigo_facultad = p.codigo and e.jornada_facultad = p.jornada
        inner join
    a_periodo_prueba pp
        on e.codigo = pp.codigo_estudiante and pp.ano = v_anioa and pp.ciclo = v_cicloa
    where
    p.facultad in ('IN','AC')--Se agregan Administrativas y Contables por requerimiento 26/04/2018
    and pp.indicador = 1
    and e.codigo = p_codigo;
    if v_ind > 0 then
        return(1);
    end if;
    select
        count(e.codigo)
    into v_ind
    from
    b_estudiantes e
        inner join
    a_programas p
        on e.codigo_facultad = p.codigo and e.jornada_facultad = p.jornada
        inner join
    a_periodo_prueba pp
        on e.codigo = pp.codigo_estudiante and e.ultimo_ciclo_cursado = pp.ano || to_number(pp.ciclo)
        inner join
    a_solicitud_reintegro r
        on e.codigo = r.codigo_estudiante
    where
    p.facultad in ('IN','AC')--Se agregan Administrativas y Contables por requerimiento 26/04/2018
    and pp.indicador between 1 and 2
    and r.anio = p_anio
    and r.ciclo = p_ciclo
    and e.codigo = p_codigo;
    if v_ind > 0 then
        return(2);
    end if;
    return(0);
exception
when others then
    return(-1);
end esIngSinTurno;
function noMateriasRetiradas (
    p_codigo varchar2,
    p_anio varchar2,
    p_ciclo varchar2
) return number is
    v_ip historico_estudiantes.indicador_pago%type;
    v_n number default 0;
begin
    select he.indicador_pago
    into v_ip
    from historico_estudiantes he
    where he.codigo = p_codigo
    and he.anio = p_anio
    and he.ciclo = p_ciclo;
    if v_ip not in ('P','V') then
        return(0);
    end if;
    execute immediate
        'select count(*) from prematricula_' || p_anio || to_number(p_ciclo) || ' p where p.codigo_estudiante = :a and p.anio = :b and p.ciclo = :c and p.indicador_pago in (''C'',''K'')'
    into v_n
    using p_codigo, p_anio, p_ciclo;
    return(v_n);
exception
when no_data_found then
    return(0);
when others then
    return(-1);
end noMateriasRetiradas;
procedure getResumenCreditos (
    p_codigo in varchar2,
    p_anio in varchar2,
    p_ciclo in varchar2,
    p_sem_inf out number,
    p_crd_max out number,
    p_crd_ins out number,
    p_dp in number default 1
) as
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_cod_dp varchar2(8);
    v_sem_inf_dp number;
    v_crd_max_dp number;
    v_crd_ins_dp number;
begin
    if substr(p_codigo, 0, 2) <= '71' and substr(p_codigo, 0, 2) not in ('46') then
        pkg_utils.getAnioCicloEsquema(1, v_anio, v_ciclo, v_esquema);
    elsif substr(p_codigo, 0, 2) > '71' then
        pkg_utils.getAnioCicloEsquema(2, v_anio, v_ciclo, v_esquema);
    else
        raise_application_error(-20001, 'Estudiante de Yopal no definido: ' || p_codigo);
    end if;
    if v_anio || v_ciclo = p_anio || p_ciclo then
        if v_esquema = 'admisiones' then
                select sum(to_number(m.creditos)), min(to_number(m.semestre))
                into p_crd_ins, p_sem_inf
                from b_estudiantes e inner join b_prematricula p on e.codigo = p.codigo_estudiante and e.anio = p.anio and e.ciclo = p.ciclo
                inner join a_materias m on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio
                where m.semestre > 0
                and p.indicador_reglamento is null
                and e.codigo = p_codigo;
        elsif v_esquema = 'cactualpre' then
                select sum(to_number(m.creditos)), min(to_number(m.semestre))
                into p_crd_ins, p_sem_inf
                from b_estudiantes e inner join cactualpre.b_prematricula p on e.codigo = p.codigo_estudiante and e.anio = p.anio and e.ciclo = p.ciclo
                inner join a_materias m on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio
                where m.semestre > 0
                and p.indicador_reglamento is null
                and e.codigo = p_codigo;
        elsif v_esquema = 'postgrado' then
                select sum(to_number(m.creditos)), min(to_number(m.semestre))
                into p_crd_ins, p_sem_inf
                from b_estudiantes e inner join b_prematricula p on e.codigo = p.codigo_estudiante and e.anio = p.anio and e.ciclo = p.ciclo
                inner join a_materias m on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio
                where m.semestre > 0
                and p.indicador_reglamento is null
                and e.codigo = p_codigo;
        elsif v_esquema = 'cactualpos' then
                select sum(to_number(m.creditos)), min(to_number(m.semestre))
                into p_crd_ins, p_sem_inf
                from b_estudiantes e inner join b_prematricula p on e.codigo = p.codigo_estudiante and e.anio = p.anio and e.ciclo = p.ciclo
                inner join a_materias m on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio
                where m.semestre > 0
                and p.indicador_reglamento is null
                and e.codigo = p_codigo;
        else
                raise_application_error(-20002, 'Esquema no definido: ' || v_esquema);
        end if;
        select
            cs.creditos
        into p_crd_max
        from
            creditosxsemestre cs
                inner join
            b_estudiantes e
                on cs.codigo_facultad = e.codigo_facultad and cs.jornada_facultad = e.jornada_facultad and cs.plan_estudio = e.plan_estudio
        where
            e.codigo = p_codigo
            and e.anio = p_anio
            and e.ciclo = p_ciclo
            and cs.semestre = p_sem_inf;
        if p_dp > 0 then
            v_cod_dp := b_prematricula_spring.f_get_codigo_contrario(p_codigo, p_anio, p_ciclo);
            if v_cod_dp is not null then
                pkg_utils.getResumenCreditos(v_cod_dp, p_anio, p_ciclo, v_sem_inf_dp, v_crd_max_dp, v_crd_ins_dp, 0);
                if v_sem_inf_dp <= 0 then
                    return;
                elsif v_crd_ins_dp > p_crd_ins then
                    p_sem_inf := v_sem_inf_dp;
                    p_crd_max := v_crd_max_dp;
                elsif v_crd_ins_dp = p_crd_ins and v_sem_inf_dp < p_sem_inf then
                    p_sem_inf := v_sem_inf_dp;
                    p_crd_max := v_crd_max_dp;
                elsif v_crd_ins_dp = p_crd_ins and v_sem_inf_dp = p_sem_inf and v_cod_dp < p_codigo then
                    p_sem_inf := v_sem_inf_dp;
                    p_crd_max := v_crd_max_dp;
                end if;
                p_crd_ins := p_crd_ins + v_crd_ins_dp;
                --dbms_output.put_line('<-- DP ' || p_codigo || ',' || v_cod_dp || ' -->');
            end if;
        end if;
    else
        execute immediate
            'select sum(to_number(m.creditos)), min(to_number(m.semestre)) ' ||
            'from historico_estudiantes e inner join prematricula_' || p_anio || to_number(p_ciclo) || ' p on e.codigo = p.codigo_estudiante and e.anio = p.anio and e.ciclo = p.ciclo ' ||
            'inner join a_materias m on m.codigo = p.materia_plan and m.codigo_facultad = e.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio ' ||
            'where m.semestre > 0 ' ||
            'and p.indicador_pago in (''P'',''V'',''K'',''C'') ' ||
            'and e.codigo = :a'
        into p_crd_ins, p_sem_inf
        using p_codigo;
        select
            cs.creditos
        into p_crd_max
        from
            creditosxsemestre cs
                inner join
            historico_estudiantes e
                on cs.codigo_facultad = e.codigo_facultad and cs.jornada_facultad = e.jornada_facultad and cs.plan_estudio = e.plan_estudio
        where
            e.codigo = p_codigo
            and e.anio = p_anio
            and e.ciclo = p_ciclo
            and cs.semestre = p_sem_inf;
        --TODO: Implementar l√≥gica para los DP de periodos anteriores
    end if;
exception
when no_data_found then
    p_sem_inf := 0;
    p_crd_max := 0;
    p_crd_ins := 0;
when others then
    p_sem_inf := -1;
    p_crd_max := -1;
    p_crd_ins := -1;
end getResumenCreditos;
function aplicaArt47 (
    p_codigo varchar2,
    p_val_dp number default 1
) return number is
begin
    return pkg_estudiantes.aplicaArt44(p_codigo, p_val_dp);
end aplicaArt47;
function numeroCreditosAprobados (
    p_codigo b_estudiantes.codigo%type
) return number is
    sumcred number default 0;
begin
    select sum(cr)
    into sumcred
    from
    (select
        nvl(sum(m.creditos),0) cr
    from
    b_estudiantes e
        inner join
    a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    postgrado.b_estudiantes e
        inner join
    postgrado.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    postgrado.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and n.valor >= 3.5
    union
    select
        nvl(sum(m.creditos),0) cr
    from
    yopal.b_estudiantes e
        inner join
    yopal.a_notas n
        on e.codigo = n.codigo_estudiante and e.plan_estudio = n.ind_hnvoplan
        inner join
    yopal.a_materias m
        on m.codigo = n.codigo_materia and m.plan_estudio = n.ind_hnvoplan and m.codigo_facultad = n.codigo_facultad and m.jornada_facultad = n.jornada_facultad
    where
    n.codigo_estudiante = p_codigo
    and ((n.indicador != 'V' and n.valor >= 3) or (n.indicador = 'V' and n.valor >= 3.5))
    ) zz;
    return(sumcred);
exception
when others then
    return(SQLCODE);
end numeroCreditosAprobados;
procedure getFacultadJornada (
  p_codigo varchar2,
  p_jornada varchar2,
  p_header number default 1
) as
begin
  if p_header > 0 then
    owa_util.mime_header('application/json', FALSE, 'iso-8859-1');
    owa_util.http_header_close;
  end if;
  for fac in (select f.codigo, f.nombre, f.jornada, d.email from a_facultades f left join directorio_programas d on f.codigo = d.codigo_facultad where f.codigo = p_codigo and f.jornada = p_jornada) loop
    htp.prn('{"codigo":"' || fac.codigo || '",');
    htp.prn('"nombre":"' || pkg_utils.acentos(trim(fac.nombre)) || '",');
    htp.prn('"jornada":"' || fac.jornada || '",');
    htp.prn('"correo":"' || REGEXP_SUBSTR(fac.email, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 1, 1) || '"}');
    return;
  end loop;
  raise_application_error(-20999, 'Registro no encontrado: ' || p_codigo);
exception
when others then
  htp.prn('{"status":"fail","mensaje":"' || SQLCODE || ' - ' || SUBSTR(SQLERRM,1,200) || '"}');
end getFacultadJornada;
procedure getFacultadesJornada (
  p_tipo number default 0,
  p_header number default 1
) as
  type t_facus IS REF CURSOR;
  facus t_facus;
  v_codfacu a_facultades.codigo%type;
  v_jorfacu a_facultades.jornada%type;
begin
  if p_header > 0 then
    owa_util.mime_header('application/json', FALSE, 'iso-8859-1');
    owa_util.http_header_close;
  end if;
  if p_tipo = 1 then
    open facus for select distinct f.codigo, f.jornada from a_facultades f where f.activa in ('S') and f.codigo <= '71' order by f.codigo;
  elsif p_tipo = 2 then
    open facus for select distinct f.codigo, f.jornada from a_facultades f where f.activa in ('S') and f.codigo > '71' order by f.codigo;
  else
    open facus for select distinct f.codigo, f.jornada from a_facultades f where f.activa in ('S') order by f.codigo;
  end if;
  htp.prn('[');
  loop fetch facus into v_codfacu, v_jorfacu;
    if facus%found and facus%rowcount > 1 then
      htp.prn(',');
    end if;
    exit when facus%notfound;
    pkg_utils.getFacultadJornada(v_codfacu, v_jorfacu, 0);
  end loop;
  close facus;
  htp.prn(']');
exception
when others then
  htp.prn('{"status":"fail","mensaje":"' || SQLCODE || ' - ' || SUBSTR(SQLERRM,1,200) || '"}');
end getFacultadesJornada;
function estaVigente(
        p_proceso varchar2,
        p_tipo number default 1)
    return number
is
    v_anio varchar2(4);
    v_ciclo varchar2(2);
    v_esquema varchar2(32);
    v_i number default 0;
begin
    pkg_utils.getAnioCicloEsquema(p_tipo, v_anio, v_ciclo, v_esquema);
    select
        count(*)
    into v_i
    from
        a_fechas_de_corte f
    where
        f.proceso = p_proceso
        and f.anio = v_anio
        and f.ciclo = v_ciclo
        and sysdate between f.fecha_inicio and f.fecha_finalizacion;
    if v_i > 0 then
        return(1);
    else
        return(0);
    end if;
exception
when others then
    return(sqlcode);
end estaVigente;
procedure actualizarDocumento(
    p_tdoc_old varchar2,
    p_ndoc_old varchar2,
    p_tdoc_new varchar2,
    p_ndoc_new varchar2
) as
    v_id number;
    v_ini number default 1;
    v_tdoc_old a_tipo_documento.codigo%type default p_tdoc_old;
    v_tdoc_new a_tipo_documento.codigo%type default p_tdoc_new;
begin
    begin
        if p_tdoc_old is not null and p_ndoc_old is not null then
            if p_tdoc_old = '07' then
                v_tdoc_old := '01';
            end if;
            select doc.id_identificacion
            into v_id
            from cti_doc_identificacion doc
            where doc.tipo_documento = v_tdoc_old
            and doc.documento = p_ndoc_old;
        else
            select doc.id_identificacion
            into v_id
            from cti_doc_identificacion doc
            where doc.tipo_documento = v_tdoc_new
            and doc.documento = p_ndoc_new;
        end if;
        v_ini := 0;
    exception
    when no_data_found then
        v_id := seq_identificacion.nextval;
    end;
    if p_tdoc_new = '07' then
        v_tdoc_new := '01';
    end if;
    if (v_ini = 1) or (v_tdoc_old is not null and p_ndoc_old is not null and v_tdoc_old != v_tdoc_new) then
        update cti_doc_identificacion set estado = 0, fecha_modificacion = sysdate
        where id_identificacion = v_id;
        update cti_doc_identificacion set estado = 1, fecha_modificacion = sysdate
        where id_identificacion = v_id and tipo_documento = v_tdoc_new and documento = p_ndoc_new;
        delete from cti_doc_identificacion
        where id_identificacion = v_id and documento = p_ndoc_new and tipo_documento = v_tdoc_new;
        insert into cti_doc_identificacion (id_identificacion, documento, tipo_documento, estado, flag_doc_inicial, fecha_registro, fecha_modificacion)
        select v_id, p_ndoc_new, v_tdoc_new, 1, v_ini, sysdate, sysdate from dual
        where not exists (select 1 from cti_doc_identificacion where tipo_documento = v_tdoc_new and documento = p_ndoc_new);
    elsif v_tdoc_old = v_tdoc_new and p_ndoc_old != p_ndoc_new then
        delete from cti_doc_identificacion
        where id_identificacion = v_id and documento = p_ndoc_new;
        update cti_doc_identificacion set documento = p_ndoc_new, fecha_modificacion = sysdate
        where id_identificacion = v_id and tipo_documento = v_tdoc_new;
    end if;
    if p_tdoc_new is not null and p_ndoc_new is not null and p_tdoc_old is not null and p_ndoc_old is not null then
        insert into cti_movimientos_documento (tipo_documento_new, numero_documento_new, tipo_documento_old, numero_documento_old,fecha)
        values (p_tdoc_new, p_ndoc_new, p_tdoc_old, p_ndoc_old, sysdate);
    end if;
end actualizarDocumento;
procedure bloqueosGuia (
    p_codigo varchar2
) as
    v_prem integer default -1;
    v_msg varchar2(512);
    v_esNuevo number default 0;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    v_esNuevo := esNuevo(p_codigo);
    htp.prn('[');
    if v_esNuevo > 0 then
        htp.prn('{"tipo":"documentos","valor":"OK"},');
        v_prem := 1;
    elsif substr(p_codigo, 0, 2) > '71' then
        v_prem := 1;
        htp.prn('{"tipo":"documentos","valor":"' || pkg_utils.acentos(postgrado.revisar_documentos(p_codigo,v_msg)) || '"},');
    else
        select sum(n)
        into v_prem
        from
        (select count(*) n
        from b_prematricula p inner join b_estudiantes e on p.codigo_estudiante = e.codigo and p.anio = e.anio and p.ciclo = e.ciclo
        where e.codigo = p_codigo
        union all
        select count(*) n
        from cactualpre.b_prematricula p inner join b_estudiantes e on p.codigo_estudiante = e.codigo and p.anio = e.anio and p.ciclo = e.ciclo
        where e.codigo = p_codigo
        ) x;
        htp.prn('{"tipo":"documentos","valor":"' || pkg_utils.acentos(revisar_documentos(p_codigo,v_msg)) || '"},');
    end if;
    if v_prem <= 0 then
        htp.prn('{"tipo":"prematricula","valor":"SIN PREMATRICULA"},');
    else
        htp.prn('{"tipo":"prematricula","valor":"OK"},');
    end if;
    htp.prn('{"tipo":"financiera","valor":"' || pkg_utils.acentos(verificar_deuda_financiera(p_codigo)) || '"},');
    htp.prn('{"tipo":"biblioteca","valor":"' || pkg_utils.acentos(verificar_deuda_biblioteca(p_codigo)) || '"}');
    htp.prn(']');
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end bloqueosGuia;

Function cti_mim_email (p_tipo_documento in varchar,p_documento IN VARCHAR2)
RETURN VARCHAR2 
IS
v_otro_email        datos_personales.otro_email%type              default null;
v_existe            number                                        default 0;
BEGIN
select count(*)
into   v_existe
from   cti_doc_identificacion di
where  di.tipo_documento=p_tipo_documento
and    di.documento=p_documento
and    di.estado=1;

if v_existe>0 then
   v_otro_email:=null;
   select DECODE(LTRIM(RTRIM(dp.otro_email)),'0',NULL,LTRIM(RTRIM(dp.otro_email)))
   into   v_otro_email
   from   datos_personales dp
   where  dp.codigo_estudiante in(
          select max(dp.codigo_estudiante)
          from   datos_personales dp
          where  DECODE(dp.codtipo_documento,'07','01',DP.CODTIPO_DOCUMENTO)=p_tipo_documento
          and    dp.numero_documento=p_documento
   );
   RETURN v_otro_email;
   else
   v_existe:=0;
   v_otro_email:=null;
   select count(*)
   into   v_existe
   from   v_mim_codest_email v
   where  v.numero_documento=p_documento;
   if v_existe=1 then
      select DECODE(LTRIM(RTRIM(v.otro_email)),'0',NULL,LTRIM(RTRIM(v.otro_email)))
      into   v_otro_email
      from   v_mim_codest_email v
      where  v.numero_documento=p_documento;
      RETURN v_otro_email;
      else
      RETURN v_otro_email;
   end if;
end if;
exception
when others then
    --insert into pig values(p_tipo_documento,null,null);
    --commit;
        htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');

END cti_mim_email;
/*
Function cti_mim_doc_anterior (p_tipo_documento in varchar,p_documento IN VARCHAR2)
RETURN VARCHAR2
IS
v_registros         number                                        default 0;
v_id_identificacion cti_doc_identificacion.id_identificacion%type default null;
v_numdoc_anterior   varchar2(30)                                  default null;
v_existe            number                                        default 0;
v_NumeroError       number;
v_TextoError        varchar2(200);
BEGIN
select count(*)
into   v_existe
from   cti_movimientos_documento md
where  md.tipo_documento_new=p_tipo_documento
and    md.numero_documento_new=p_documento;
if v_existe>0 then
   select DECODE(md.tipo_documento_old,'07','01',md.tipo_documento_old)||RTRIM(LTRIM(md.numero_documento_old))
   into   into   v_numdoc_anterior
   from   cti_movimientos_documento md,a_tipo_documento td
   where  md.tipo_documento_new=td.codigo
   and    md.numero_documento_new=p_documento
   and    TO_CHAR(md.fecha,'RRRRMMDDHH24MISS') in
   (
          select max(TO_CHAR(md.fecha,'RRRRMMDDHH24MISS'))
          from   cti_movimientos_documento md
          where  md.numero_documento_new=p_documento
          AND   (md.tipo_documento_new!=md.tipo_documento_old AND md.numero_documento_new=md.numero_documento_old) 
          OR (md.tipo_documento_new!=md.tipo_documento_old AND md.numero_documento_new!=md.numero_documento_old)
          OR (md.tipo_documento_new=md.tipo_documento_old AND md.numero_documento_new!=md.numero_documento_old)
   );
   RETURN v_numdoc_anterior;
   else
   v_numdoc_anterior:=null;
   RETURN v_numdoc_anterior;
end if;
exception
when others then
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
END cti_mim_doc_anterior;
*/
Function cti_mim_doc_anterior (p_tipo_documento in varchar,p_documento IN VARCHAR2)
RETURN VARCHAR2
IS
v_registros         number                                        default 0;       
v_id_identificacion cti_doc_identificacion.id_identificacion%type default null;
--v_numdoc_anterior   cti_doc_identificacion.documento%type         default null;
v_numdoc_anterior   varchar2(30)                                    DEFAULT NULL;
v_existe            number                                        default 0;
v_NumeroError     number;
v_TextoError      VARCHAR2(200); 
BEGIN
select count(*)
into   v_existe
from   cti_doc_identificacion di
where  di.tipo_documento=p_tipo_documento
and    di.documento=p_documento
and    di.estado=1;
if v_existe>0 then
    select di.id_identificacion
    into   v_id_identificacion
    from   cti_doc_identificacion di
    where  di.tipo_documento=p_tipo_documento
    and    di.documento=p_documento
    and    di.estado=1;

    select count(*)
    into   v_registros
    from   cti_doc_identificacion di
    where  di.id_identificacion=v_id_identificacion
    and    di.estado=0
    AND    DI.TIPO_DOCUMENTO NOT IN('09');
    if v_registros>=1 then
       select td.tipo||RTRIM(LTRIM(di.documento))
       into   v_numdoc_anterior
       from   cti_doc_identificacion di,a_tipo_documento td
       where  di.tipo_documento=td.codigo
       and    di.estado=0
       and    di.id_identificacion=v_id_identificacion
       AND    DI.TIPO_DOCUMENTO NOT IN('09')
       --and    TO_CHAR(di.fecha_modificacion,'RRRRMMDDHH24MISS') in
       and    TO_CHAR(di.fecha_registro,'RRRRMMDDHH24MISS') in
       (
              --select max(TO_CHAR(di.fecha_modificacion,'RRRRMMDDHH24MISS'))
              select max(TO_CHAR(di.fecha_registro,'RRRRMMDDHH24MISS'))
              from   cti_doc_identificacion di
              where  di.id_identificacion=v_id_identificacion
              and    di.estado=0
              AND    DI.TIPO_DOCUMENTO NOT IN('09')
       );
       RETURN v_numdoc_anterior;
       else
       v_numdoc_anterior:=null;
       RETURN v_numdoc_anterior;
    end if;
    else
    v_numdoc_anterior:=null;
    RETURN v_numdoc_anterior;
end if;
exception
when others then
--31MAY2017  
----------------------------------------------------------    
ENVIAR_MAIL_MIM('Error en cti_mim_doc_anterior '||p_tipo_documento||' '||p_documento||'
','drincon@lasalle.edu.co,maymonroy@lasalle.edu.co,jdrojas@lasalle.edu.co');
----------------------------------------------------------    
RAISE_APPLICATION_ERROR(-20001,'p_tipo_documento='||p_tipo_documento||'p_documento='||p_documento);
--------------------------------------------------------------------------------------------------
    --insert into pig values(p_documento,null,null);
    --commit;
    --htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
END cti_mim_doc_anterior;
function getCredMax (
    p_codigo varchar2
) return number is
    v_crd number;
begin
    select c.creditos
    into v_crd
    from b_estudiantes e inner join creditosxsemestre c
    on e.codigo_facultad = c.codigo_facultad and e.jornada_facultad = c.jornada_facultad and e.plan_estudio = c.plan_estudio and c.semestre = e.semestre_inferior 
    where e.codigo = p_codigo 
    union
    select c.creditos
    from postgrado.b_estudiantes e inner join postgrado.creditosxsemestre c
    On E.Codigo_Facultad = C.Codigo_Facultad And E.Jornada_Facultad = C.Jornada_Facultad And E.Plan_Estudio = C.Plan_Estudio And C.Semestre = E.Semestre_Inferior 
    where e.codigo = p_codigo 
    union
    select c.creditos
    from yopal.b_estudiantes e inner join yopal.creditosxsemestre c
    on e.codigo_facultad = c.codigo_facultad and e.jornada_facultad = c.jornada_facultad and e.plan_estudio = c.plan_estudio and c.semestre = e.semestre_inferior 
    where e.codigo = p_codigo ;
    return(v_crd);
exception
when others then
    return(0);
end getCredMax;
procedure sendMail (
    destinatario varchar2,
    asunto varchar2,
    mensaje varchar2,
    cco varchar2 default null
) as
begin
    utl_mail.send(
        sender => '"Universidad de La Salle - OAR" <no-reply@lasalle.edu.co>',
        recipients => destinatario,
        subject => asunto,
        message => mensaje,
        bcc => cco,
        mime_type => 'text/plain; charset=iso-8859-1'
    );
    dbms_output.put_line('[MAIL] ' || destinatario);
exception
when others then
    raise;
end sendMail;
procedure actualizarDPMulticodigo
as
    v_email correos_institucionales.correo%type;
begin
    --Listado de cambios a procesar.
    for ch in (select c.codigo, c.documento_old, c.documento_new from cti_tmp_chdp c) loop
        begin
            select cr.correo
            into v_email
            from correos_institucionales cr
            where cr.codigo = ch.codigo;
        exception
        when no_data_found then
            v_email := null;
        end;
        --Listado de un registro con los datos personales que van a ser escritos.
        for dp0 in (
            select dp.codigo_estudiante,dp.fecha_actualizacion,dp.codtipo_documento,dp.nombre_documento,dp.numero_documento,dp.coddepto_documento,dp.departamento_documento,dp.codmuni_documento,dp.ciudad_documento,dp.coddepto_nacimiento,dp.departamento_nacimiento,dp.codmuni_nacimiento,dp.ciudad_nacimiento,dp.fecha_nacimiento,dp.codestado_civil,dp.estado_civil,dp.coddepto_residencia,dp.departamento_residencia,dp.codmuni_residencia,dp.ciudad_residencia,dp.direccion,dp.barrio,dp.telefono_casa,dp.telefono_oficina,dp.telefono_otro,dp.email,dp.otro_email,dp.codestrato_servicios,dp.estrato_servicios,dp.fecha_actualizacion_oar,dp.nombre,dp.codigo_facultad,dp.jornada_facultad,dp.sexo,dp.cod_eps,dp.nombre_eps,dp.coddepto_eps,dp.departamento_eps,dp.codmuni_eps,dp.ciudad_eps,dp.primer_apellido,dp.segundo_apellido,dp.primer_nombre,dp.segundo_nombre
            from datos_personales dp
            where dp.codigo_estudiante = ch.codigo
        ) loop
            --Listado de documentos relacionados al documento original.
            for dp1 in (
                select dp.codigo_estudiante from datos_personales dp where dp.codtipo_documento || dp.numero_documento = ch.documento_old and dp.codigo_estudiante not in (ch.codigo)
            ) loop
                --Se escriben los datos personales del original sobre los relacionados.
                update datos_personales set
                    fecha_actualizacion=dp0.fecha_actualizacion,
                    codtipo_documento=dp0.codtipo_documento,
                    nombre_documento=dp0.nombre_documento,
                    numero_documento=dp0.numero_documento,
                    coddepto_documento=dp0.coddepto_documento,
                    departamento_documento=dp0.departamento_documento,
                    codmuni_documento=dp0.codmuni_documento,
                    ciudad_documento=dp0.ciudad_documento,
                    coddepto_nacimiento=dp0.coddepto_nacimiento,
                    departamento_nacimiento=dp0.departamento_nacimiento,
                    codmuni_nacimiento=dp0.codmuni_nacimiento,
                    ciudad_nacimiento=dp0.ciudad_nacimiento,
                    fecha_nacimiento=dp0.fecha_nacimiento,
                    codestado_civil=dp0.codestado_civil,
                    estado_civil=dp0.estado_civil,
                    coddepto_residencia=dp0.coddepto_residencia,
                    departamento_residencia=dp0.departamento_residencia,
                    codmuni_residencia=dp0.codmuni_residencia,
                    ciudad_residencia=dp0.ciudad_residencia,
                    direccion=dp0.direccion,
                    barrio=dp0.barrio,
                    telefono_casa=dp0.telefono_casa,
                    telefono_oficina=dp0.telefono_oficina,
                    telefono_otro=dp0.telefono_otro,
                    email=dp0.email,
                    otro_email=dp0.otro_email,
                    codestrato_servicios=dp0.codestrato_servicios,
                    estrato_servicios=dp0.estrato_servicios,
                    fecha_actualizacion_oar=dp0.fecha_actualizacion_oar,
                    nombre=dp0.nombre,
                    codigo_facultad=dp0.codigo_facultad,
                    jornada_facultad=dp0.jornada_facultad,
                    sexo=dp0.sexo,
                    cod_eps=dp0.cod_eps,
                    nombre_eps=dp0.nombre_eps,
                    coddepto_eps=dp0.coddepto_eps,
                    departamento_eps=dp0.departamento_eps,
                    codmuni_eps=dp0.codmuni_eps,
                    ciudad_eps=dp0.ciudad_eps,
                    primer_apellido=dp0.primer_apellido,
                    segundo_apellido=dp0.segundo_apellido,
                    primer_nombre=dp0.primer_nombre,
                    segundo_nombre=dp0.segundo_nombre
                where codigo_estudiante = dp1.codigo_estudiante;
                if v_email is not null then
                    update correos_institucionales
                    set correo = v_email
                    where codigo = dp1.codigo_estudiante;
                end if;
            end loop;
        end loop;
    end loop;
    commit;
    delete from cti_tmp_chdp where codigo is not null;
    commit;
exception
when others then
    dbms_output.put_line(sqlerrm);
    rollback;
end actualizarDPMulticodigo;
procedure getPerfiles (
    token varchar2
) as
    v_documento varchar2(32);
    v_id varchar2(256);
    v_label varchar2(256);
    v_label2 varchar2(256);
    v_respuesta json := json();
    v_list json_list := json_list();
    v_perfil json;
    cursor c_listado_perfiles(p_documento varchar2) is
    select
        pkg_utils.f_crearToken(u.usuario || ';' || u.clave, '3764613438353137') as id,
        p.etiqueta,
        case
        when p.id_perfil = 7 then
            u.codigo
        when p.id_perfil between 1 and 4 then
            (select pr.nombre from a_programas pr where (pr.facultad = substr(u.codigo, 2, 2) or pr.codigo = substr(u.codigo, 2, 2)) and rownum <= 1)
        else
            null
        end as etiqueta2
    from a_usuarios u inner join cti_perfiles p on p.cod_perfil = u.codigo or regexp_like(u.codigo, p.regexp)
    where not regexp_like(u.usuario, '^(ZR).{2}$') and u.numero_documento = p_documento
    and not regexp_like(u.codigo, '^(&)+$')
    order by 2, 3;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    v_documento := pkg_utils.f_leertoken(token, 1/1440, '3764613438353137');
    open c_listado_perfiles(v_documento);
    loop
        fetch c_listado_perfiles
        into v_id, v_label, v_label2;
        exit when c_listado_perfiles%notfound;
        v_perfil := json();
        json.put(v_perfil,'id',v_id);
        json.put(v_perfil,'etiqueta',v_label);
        json.put(v_perfil,'etiqueta2',v_label2);
        json_list.append(v_list,v_perfil.to_json_value);
    end loop;
    close c_listado_perfiles;
    json_list.htp(v_list,false);
exception
when others then
    begin
        close c_listado_perfiles;
    exception
    when others then
        null;
    end;
    json.put(v_respuesta,'status','fail');
    json.put(v_respuesta,'mensaje',sqlerrm);
    json.htp(v_respuesta,false);
end getPerfiles;
procedure getCodigosXDocumento (
        p_documento varchar2
    ) as
    v_codigo b_estudiantes.codigo%type;
    cursor c_listado_codigos is
    select dp.codigo_estudiante
    from datos_personales dp
    where dp.numero_documento = p_documento;
begin
    owa_util.mime_header('application/json', false, 'utf-8');
    owa_util.http_header_close;
    htp.prn('[');
    open c_listado_codigos;
    loop
        fetch c_listado_codigos
        into v_codigo;
        if c_listado_codigos%found and c_listado_codigos%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_listado_codigos%notfound;
        pkg_utils.getEstudiante(v_codigo, 0);
    end loop;
    close c_listado_codigos;
    htp.prn(']');
exception
when others then
    close c_listado_codigos;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getCodigosXDocumento;
procedure getCodigosXUsername (
    p_username varchar2
) as
    v_codigo b_estudiantes.codigo%type;
    cursor c_listado_codigos is
    select ci.codigo from b_estudiantes e inner join correos_institucionales ci on e.codigo = ci.codigo where substr(ci.correo, 0, length(ci.correo) - 16) = p_username
    union
    select ci.codigo from postgrado.b_estudiantes e inner join correos_institucionales ci on e.codigo = ci.codigo where substr(ci.correo, 0, length(ci.correo) - 16) = p_username;
begin
    owa_util.mime_header('application/json', false, 'utf-8');
    owa_util.http_header_close;
    htp.prn('[');
    open c_listado_codigos;
    loop
        fetch c_listado_codigos
        into v_codigo;
        if c_listado_codigos%found and c_listado_codigos%rowcount > 1 then
            htp.prn(',') ;
        end if;
        exit when c_listado_codigos%notfound;
        pkg_utils.getEstudiante(v_codigo, 0);
    end loop;
    close c_listado_codigos;
    htp.prn(']');
exception
when others then
    close c_listado_codigos;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getCodigosXUsername;
function ciclosDespuesDeFinMateriasRA(
    p_codigo b_estudiantes.codigo%type
) return number
is
    v_periodos number;
begin
    select
    2*((e.anio + (case when e.ciclo = '01' then 0 else 0.5 end))-(to_number(v.anio) + (case when v.ciclo = '01' then 0 else 0.5 end))) as n
    into v_periodos
    from
    b_estudiantes e inner join
    (select x.codigo, x.anio, x.ciclo from (
    select he.codigo, he.anio, he.ciclo from historico_estudiantes he where he.codigo = p_codigo and he.materias_pendientes = 0 order by anio, ciclo) x
    where rownum <= 1)
    v on e.codigo = v.codigo
    where
    e.tipo_de_ingreso in ('RA')
    and e.codigo = p_codigo;
    return(v_periodos);
exception
when no_data_found then
    return(-1);
end ciclosDespuesDeFinMateriasRA;
procedure getProgramasACargo(
    p_facultad varchar2
) as
    cursor facus is select distinct f.codigo from a_facultades f where f.codigo = p_facultad
    union
    select distinct f.codigo from a_facultades f inner join a_programas p on f.codigo = p.codigo and f.jornada = p.jornada
    where p.facultad = p_facultad
    order by 1;
    v_codfacu a_facultades.codigo%type;
begin
    owa_util.mime_header('application/json', FALSE, 'utf-8');
    owa_util.http_header_close;
    htp.prn('[');
    open facus;
    loop fetch facus into v_codfacu;
        if facus%found and facus%rowcount > 1 then
            htp.prn(',');
        end if;
        exit when facus%notfound;
        htp.prn('"' || v_codfacu || '"');
    end loop;
    htp.prn(']');
    close facus;
exception
when others then
    close facus;
    htp.prn('{"status":"fail","mensaje":"' || pkg_utils.acentos(sqlerrm) || '"}');
end getProgramasACargo;
function esNuevo(
    p_codigo varchar2
) return number
is
    v_cod number;
begin
    begin
        select min(x.n)
        into v_cod
        from (
            select 1 n
            from b_estudiantes e
            where e.codigo = p_codigo
            and (e.ciclo_de_ingreso = e.anio || to_number(e.ciclo) or exists (select 1 from a_aspirantes a where a.cod_def = e.codigo and a.anio || to_number(a.ciclo) = e.ciclo_de_ingreso))
            and e.tipo_de_ingreso in (select t.tipo from a_tipo_estudiante t, cti_grupo_tipo_est gr where t.codigo  = gr.codigo_tipo and gr.id_grupo = 1 union select 'NV' from dual union select 'DT' from dual)
            union
            select 1
            from postgrado.b_estudiantes e
            where e.codigo = p_codigo
            and (e.ciclo_de_ingreso = e.anio || to_number(e.ciclo) or exists (select 1 from postgrado.a_aspirantes a where a.cod_def = e.codigo and a.anio || to_number(a.ciclo) = e.ciclo_de_ingreso))
            union
            select 2 from a_aspirantes a where a.cod_def = p_codigo and a.ind1 = '2' and not exists (select 1 from b_estudiantes e where e.codigo = p_codigo)
            union
            select 2 from postgrado.a_aspirantes a where a.cod_def = p_codigo and a.ind1 = '2' and not exists (select 1 from b_estudiantes e where e.codigo = p_codigo)
        ) x;
        if v_cod is null then
            return 0;
        end if;
        return 1;
    exception
    when no_data_found then
        return 0;
    end;
exception
when no_data_found then
    return 0;
when others then
    return -1;
end esNuevo;

function toChar(
    p_date date
) return varchar2
is
begin
    return to_char(p_date, 'RRRR/MM/DD HH24:MI:SS');
end;
END PKG_UTILS;