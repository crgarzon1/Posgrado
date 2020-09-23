create or replace procedure "MENU_FAC2_DECANO_PRUEBAS"(
    p_usuario   varchar2 default null,
    p_clave     varchar2 default null,
    p_codigo    varchar2 default null,
    v_tipo      varchar2 default null,
    p_fac       varchar2 default null
)is
begin
    htp.prn('<!doctype html>');
    htp.prn('<html>');
    htp.prn('	<head>');
    htp.prn('		<title>.:: Postgrado ::.</title>');
    htp.prn('	</head>');
    htp.prn('	<body>');
    htp.prn('		<h1>Redireccionando...</h1>');
    htp.prn('		<script>location.href="http://zeus.lasalle.edu.co/oar/sia/postgrado/";</script>');
    htp.prn('	</body>');
    htp.prn('</html>');
end menu_fac2_decano_pruebas;