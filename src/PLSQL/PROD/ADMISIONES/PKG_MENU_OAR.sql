set define off;
create or replace package body pkg_menu_oar
as
    procedure html
    as
        p_usuario a_usuarios.usuario%type;
        p_clave a_usuarios.clave%type;
        p_documento a_usuarios.numero_documento%type;
        p_codigo a_usuarios.codigo%type;
        p_nombre a_usuarios.nombre_usuario%type;
    begin
        pkg_utils.p_leer_cookie(p_usuario, p_clave, p_documento, p_codigo, p_nombre);
        if p_codigo not in ('007','006','005') then
            raise_application_error(-20000, 'Usuario no autorizado: ' || p_nombre);
        end if;
        htp.prn('<!doctype html>');
        htp.prn('<html>');
        htp.prn('<head>');
        htp.prn('    <title>Universidad de La Salle</title>');
        htp.prn('    <meta charset="utf-8">');
        htp.prn('    <meta name="viewport" content="width=device-width, initial-scale=1">');
        htp.prn('    <link rel="stylesheet" href="http://zeus.lasalle.edu.co/oar/bootstrap/css/bootstrap.min.css">');
        htp.prn('    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.2/css/font-awesome.min.css">');
        htp.prn('    <script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/jquery/js/jquery-1.11.1.min.js"></script>');
        htp.prn('    <script type="text/javascript" src="http://zeus.lasalle.edu.co/oar/bootstrap/js/bootstrap.min.js"></script>');
        htp.prn('    <style>');
        htp.prn('    html, body {');
        htp.prn('        margin: 0;');
        htp.prn('        padding: 0;');
        htp.prn('        font-size: 12px;');
        htp.prn('    }');
        htp.prn('    section {');
        htp.prn('        position: relative;');
        htp.prn('    }');
        htp.prn('    .navbar-default {');
        htp.prn('        background-color: #002547;');
        htp.prn('        border-color: #e3af00;');
        htp.prn('    }');
        htp.prn('    .navbar-default .navbar-nav>li>a {');
        htp.prn('        text-align: center;');
        htp.prn('        color: #ffffff;');
        htp.prn('    }');
        htp.prn('    .navbar-default .navbar-header a, .navbar-default .navbar-header a:hover, .navbar-default .navbar-header a:focus, .navbar-default .navbar-nav>li>a:hover, .navbar-default .navbar-nav>li>a:focus {');
        htp.prn('        color: #e3af00;');
        htp.prn('    }');
        htp.prn('    .navbar-default .navbar-nav>li>a:hover {');
        htp.prn('        text-decoration: underline;');
        htp.prn('    }');
        htp.prn('    .navbar-default .navbar-nav>.open>a, .navbar-default .navbar-nav>.open>a:hover, .navbar-default .navbar-nav>.open>a:focus {');
        htp.prn('        background-color: #e3af00;');
        htp.prn('        color: #002547;');
        htp.prn('    }');
        htp.prn('	.navbar-default .navbar-brand {');
        htp.prn('		color: #e3af00 !important;');
        htp.prn('	}');
        htp.prn('    @media (max-width: 767px) {');
        htp.prn('        h3 {');
        htp.prn('            font-size: 10px;');
        htp.prn('        }');
        htp.prn('        h5 {');
        htp.prn('            font-size: 8px;');
        htp.prn('        }');
        htp.prn('    }');
        htp.prn('    .vcenter {');
        htp.prn('        position: absolute;');
        htp.prn('        top: 50%;');
        htp.prn('        -webkit-transform: translateY(-50%);');
        htp.prn('        -ms-transform: translateY(-50%);');
        htp.prn('        transform: translateY(-50%);');
        htp.prn('    }');
        htp.prn('    p.vcenter {');
        htp.prn('        width: 100%;');
        htp.prn('    }');
        htp.prn('    .custom-overlay {');
        htp.prn('        background: none repeat scroll 0 0 #002547;');
        htp.prn('        height: 100%;');
        htp.prn('        left: 0;');
        htp.prn('        opacity: 0.6;');
        htp.prn('        position: absolute;');
        htp.prn('        top: 0;');
        htp.prn('        width: 100%;');
        htp.prn('        z-index: 99;');
        htp.prn('        color: #e3af00;');
        htp.prn('        font-size: 5em;');
        htp.prn('    }');
        htp.prn('    </style>');
        htp.prn('</head>');
        htp.prn('');
        htp.prn('');
        htp.prn('<body class="container-fluid">');
        htp.prn('<header>');
        htp.prn('<div class="row">');
        htp.prn('    <div class="col-lg-6 col-md-3 col-sm-2 col-xs-1">');
        htp.prn('        <img src="http://registro.lasalle.edu.co/images/LOGOSALLE.gif" alt="Universidad de La Salle">	');
        htp.prn('    </div>');
        htp.prn('    <div class="col-lg-6 col-md-9 col-sm-10 col-xs-11 text-right">');
        htp.prn('        <h3>SISTEMA DE INFORMACI&Oacute;N ACAD&Eacute;MICA</h3>');
        htp.prn('        <h5>Oficina de Admisiones y Registro</h5>');
        htp.prn('    </div>');
        htp.prn('</div>');
        htp.prn('<div class="row">');
        htp.prn('    <div class="col-md-12">');
        htp.prn('        <h4>Bienvenido(a): ' || p_nombre || '</h4>');
        htp.prn('    </div>');
        htp.prn('</div>');
        htp.prn('<nav class="navbar navbar-default">');
        htp.prn('	<div class="container-fluid">');
        htp.prn('        <div class="navbar-header">');
        htp.prn('            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#menu-ppal" aria-expanded="false">');
        htp.prn('                <span class="icon-bar"></span>');
        htp.prn('                <span class="icon-bar"></span>');
        htp.prn('                <span class="icon-bar"></span>');
        htp.prn('            </button>');
        htp.prn('            <div class="navbar-brand text-center"><i class="fa fa-star" aria-hidden="true"></i></div>');
        htp.prn('        </div>');
        htp.prn('        <div class="collapse navbar-collapse" id="menu-ppal">');
        htp.prn('            <form id="search-form" class="navbar-form navbar-left" name="formulario1" role="search" action="ls_tipo_consulta_estudiante" method="post" target="detalle">');
        htp.prn('                <div class="form-group">');
        htp.prn('                    <input id="in-txt" type="text" name="p_codigo" class="form-control" placeholder="c&oacute;digo, documento o apellidos" data-toggle="tooltip" data-placement="bottom" title="Digite el c&oacute;digo, el documento o los apellidos del estudiante" autocomplete="off">');
        htp.prn('                    <input id="search-opt" type="hidden" name="p_opcion">');
        htp.prn('                </div>');
        htp.prn('                <button id="btn-search" type="button" class="btn btn-info" title="de clic para consultar el estudiante">');
        htp.prn('                    <i class="fa fa-search" aria-hidden="true"></i>');
        htp.prn('                </button>');
        if p_codigo in ('007') then
            htp.prn('				<button id="btn-menest" type="button" class="btn btn-danger" title="de clic para entrar como el estudiante">');
            htp.prn('                    <i class="fa fa-user-secret" aria-hidden="true"></i>');
            htp.prn('                </button>');
        end if;
        htp.prn('            </form>');
        if p_codigo in ('005') then
            htp.prn('			<ul class="nav navbar-nav">');
            htp.prn('				<li><a href="iframe_pdfs" target="detalle">Historias acad&eacute;micas</a></li>');
            htp.prn('				<li><a href="m_crear_estudiante" target="detalle">Crear Estudiante</a></li>');
            htp.prn('				<li><a href="pkg_estudiantes.dp_html" target="detalle">Crear estudiante Doble Programa</a></li>');
            htp.prn('			</ul>');
        elsif p_codigo in ('007') then
            htp.prn('			<ul class="nav navbar-nav">');
            htp.prn('				<li class="dropdown">');
            htp.prn('					<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa fa-university" aria-hidden="true"></i> Unidades Acad&eacute;micas (pregrado)<span class="caret"></span></a>');
            htp.prn('					<ul class="dropdown-menu">');
            for fac in (select f.codigo_facultad, f.nombre from a_facultades_unica f where f.codigo_facultad < '72' and f.codigo_facultad in (
                select distinct ff.codigo from a_facultades ff where ff.vigencia = 'S' or ff.activa = 'S' or ff.abrir_inscripcion in ('S')
                ) order by 2) loop
                htp.prn('						<li><a href="pkg_menu_oar.go?cod=' || fac.codigo_facultad || '" target="detalle">' || fac.nombre || '</a></li>');
            end loop;
            htp.prn('					</ul>');
            htp.prn('				</li>');
            htp.prn('				<li><a class="no-loading" href="http://zeus.lasalle.edu.co/oar/sia/postgrado/#/login" target="_blank"><i class="fa fa-university" aria-hidden="true"></i> Unidades Acad&eacute;micas (postgrado)</a></li>');
            htp.prn('				<li><a class="no-loading" href="ls_menu_dir_v2" target="_blank"><i class="fa fa-line-chart" aria-hidden="true"></i> Estad&iacute;sticas</a></li>');
            htp.prn('				<li class="dropdown">');
            htp.prn('					<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa fa-cogs" aria-hidden="true"></i> Utilidades<span class="caret"></span></a>');
            htp.prn('					<ul class="dropdown-menu">');
            htp.prn('						<li><a href="pkg_estudiantes.dp_html" target="detalle">Crear estudiante Doble Programa</a></li>');
            htp.prn('						<li><a href="http://jupiter.lasalle.edu.co/certificados/sia" target="detalle">Certificados</a></li>');
            htp.prn('						<li><a href="/pls/postgrado/pkg_prematricula_report.html" target="detalle">Matricula Postgrado</a></li>');
            htp.prn('					</ul>');
            htp.prn('				</li>');
            htp.prn('			</ul>');
        end if;
        if p_codigo in ('005','006') then
            htp.prn('     <ul class="nav navbar-nav">');
            htp.prn('       <li class="dropdown">');
            htp.prn('         <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa fa-cogs" aria-hidden="true"></i> Utilidades<span class="caret"></span></a>');
            htp.prn('         <ul class="dropdown-menu">');
            htp.prn('           <li><a href="http://jupiter.lasalle.edu.co/certificados/sia" target="detalle">Certificados</a></li>');
            htp.prn('           <li><a  id="puestos" href="#" onclick="$(''#puestos'').attr(''href'',''http://registro.lasalle.edu.co/pls/regadm/NEW_LISTADO_PROMEDIOSMI?p_codest=''+$(''#in-txt'').val());" target="detalle">Puestos Ocupados</a></li>');
            htp.prn('         </ul>');
            htp.prn('       </li>');
            htp.prn('     </ul>');
        end if;
        htp.prn('			<ul class="nav navbar-nav navbar-right">');
        htp.prn('				<li><a href="cti_exit"><i class="fa fa-sign-out" aria-hidden="true"></i> salir</a></li>');
        htp.prn('			</ul>');
        htp.prn('		</div>');
        htp.prn('	</div><!-- /.container-fluid -->');
        htp.prn('</nav>');
        htp.prn('</header>');
        htp.prn('<section>');
        htp.prn('    <div class="custom-overlay text-center">');
        htp.prn('        <p class="vcenter text-center"><i class="fa fa-clock-o" aria-hidden="true"></i></p>');
        htp.prn('    </div>');
        htp.prn('    <iframe id="detalle-frm" name="detalle" src="about:blank" style="width: 100%; height: 20vh; border: none; overflow: hidden;"></iframe>');
        htp.prn('</section>');
        htp.p('<script type="text/javascript">');
        htp.p('$(document).ready(function () {');
        htp.p('    $(''#in-txt'').parent().removeClass(''has-error'');');
        htp.p('    $(''#in-txt'').parent().removeClass(''has-success'');');
        htp.p('    $(''[data-toggle="tooltip"]'').tooltip();');
        htp.p('    $(''#btn-search'').click(function () {');
        htp.p('        var isCode = /^[0-9A-Z]{2}[0-9]{2}(1|2){1}[0-9]{3}$/i;');
        htp.p('        var isDocument = /^[0-9]+$/i;');
        htp.p('        var value = $(''#in-txt'').val();');
        htp.p('        if (value.length < 1) {');
        htp.p('            $(''#in-txt'').parent().addClass(''has-error'');');
        htp.p('            return false;');
        htp.p('        }');
        htp.p('        $(''.custom-overlay'').show(''fast'');');
        htp.p('        $(''#in-txt'').parent().addClass(''has-success'');');
        htp.p('        $(''#in-txt'').val($.trim($(''#in-txt'').val().toUpperCase()));');
        htp.p('        if (isCode.test(value)) {');
        htp.p('            $(''#search-opt'').val(1);');
        htp.p('        } else if (isDocument.test(value)) {');
        htp.p('            $(''#search-opt'').val(4);');
        htp.p('        } else {');
        htp.p('            $(''#search-opt'').val(2);');
        htp.p('        }');
        htp.p('        $(''#search-form'').submit();');
        htp.p('    });');
        htp.p('    $(''nav a'').click(function () {');
        htp.p('        if (!$(this).hasClass(''dropdown-toggle'') && !$(this).hasClass(''no-loading'')) {');
        htp.p('            $(''.custom-overlay'').show(''fast'');');
        htp.p('        }');
        htp.p('        return true;');
        htp.p('    });');
        htp.p('    $(''#btn-menest'').click(function () {');
        htp.p('        $(''#detalle-frm'').attr(''src'',''pkg_menu_oar.go?cod='' + $(''#in-txt'').val());');
        htp.p('    });');
        htp.p('    $(''#detalle-frm'').height($(window).height() - $(''header'').height() - 30);');
        htp.p('    $(''#detalle-frm'').on(''load'', function() {');
        htp.p('        $(''.custom-overlay'').hide(''slow'');');
        htp.p('    });');
        htp.p('    $(window).resize(function() {');
        htp.p('        $(''#detalle-frm'').height($(window).height() - $(''header'').height() - 30);');
        htp.p('    });');
        htp.p('    $(''.custom-overlay'').hide();');
        htp.p('});');
        htp.p('</script>');
        htp.p('<script type="text/javascript">');
        htp.p('(function(i,s,o,g,r,a,m){i[''GoogleAnalyticsObject'']=r;i[r]=i[r]||function(){');
        htp.p('(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),');
        htp.p('m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)');
        htp.p('})(window,document,''script'',''//www.google-analytics.com/analytics.js'',''ga'');');
        htp.p('ga(''create'', ''UA-64300266-1'', ''auto'');');
        htp.p('ga(''send'',''pageview'');');
        htp.p('</script>');
        htp.prn('</body>');
        htp.prn('</html>');
    exception
    when others then
        cti_pantalla_error('No puede acceder', sqlerrm);
    end html;
    
    procedure go (
        cod varchar2
    ) as
        p_usuario a_usuarios.usuario%type;
        p_clave a_usuarios.clave%type;
        p_documento a_usuarios.numero_documento%type;
        p_codigo a_usuarios.codigo%type;
        p_nombre a_usuarios.nombre_usuario%type;
        v_fac varchar2(2);
    begin
        pkg_utils.p_leer_cookie(p_usuario, p_clave, p_documento, p_codigo, p_nombre);
        if p_codigo not in ('007') then
            raise_application_error(-20000, 'Usuario no autorizado: ' || p_nombre);
        end if;
        if regexp_like(cod, '^[A-Z0-9]{2}$') then
            if cod = '46' then
                cti_redirect('ls_menu_fac', 3);
            elsif cod >= '71' then
                cti_redirect('menu_fac2_decano_pruebas?p_fac=' || cod, 2);
            else
                cti_redirect('ls_menu_fac?p_fac=' || cod);
            end if;
        elsif regexp_like(cod, '^[A-Z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$') then
            v_fac := substr(cod, 0, 2);
            if v_fac = '46' then
                cti_redirect('ls_menu_estudiante', 3);
            elsif v_fac >= '71' then
                cti_redirect('menu_estudiante?p_cod=' || cod, 2);
            else
                cti_redirect('ls_menu_estudiante?p_cod=' || cod);
            end if;
        else
            raise_application_error(-20003, 'Opcion no valida.');
        end if;
    exception
    when others then
        cti_pantalla_error('Mensaje importante', sqlerrm);
    end go;
    
end pkg_menu_oar;