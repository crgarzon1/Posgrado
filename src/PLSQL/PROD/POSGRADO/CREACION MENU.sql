GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
GRANT EXECUTE ON PG_CRED_DOC2 TO POSTGRADO;
GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
GRANT SELECT ON CTI_TIPO_EJECUCION TO POSTGRADO;
DELETE FROM CTI_MENU;
DELETE FROM CTI_PROCESOS;
DELETE FROM CTI_TIPO_EJECUCION;
DELETE FROM CTI_PARAMETRO_PROCESO;

SET DEFINE OFF;

INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('1', 'URL parametrizable');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('2', 'URL Externa');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('3', 'Componente Angular');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('4', 'PL/SQL');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('5', 'Sin accion');

INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('31', 'Carga Acad�mica', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('1', 'Ciclo Actual', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=7', '4', '31', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('2', 'Proximo Ciclo', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=1', '4', '31', 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('3', 'Listados', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('4', 'Utilidades', '#', '5', NULL, 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('5', 'Planes de Estudio', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=2', '4', '3', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('6', 'Listado de Reintegros', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=3', '4', '3', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('18', 'Egresados no Graduados', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=16', '4', '3', 1);
       
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('7', 'Credenciales Docentes y/o Estudiantes', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=4', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('8', 'Imprimir Guia de Pago', '/guiaDePago', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('9', 'Registrar Solicitudes de Reintegro', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=5&P_PARAMS=[PARAMSPLACEHOLDER]', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('10', 'Crear Materias', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=6', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('13', 'Creditos Adicionales', '/creditosAdicionales', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('14', 'Inscripci�n de Materias', '/prematricula', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('15', 'Materias Integradas', '/integrados', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('19', 'Syllabus Hist�rico', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=17', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('20', 'Resultados Elecciones', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=18', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('33', 'Acompa�amiento Tutorial', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=27', '4', '4', 1);
            
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('32', 'Votaciones', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=26', '4', NULL, 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('16', 'Certificados', 'http://jupiter.lasalle.edu.co/certificados/sia', '4', NULL, 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('21', 'Utilidades', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('22', 'Resultados Elecciones', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=19', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('23', 'Actualizaci�n de Datos', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=20', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('24', 'Evaluaci�n Docente', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=21', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('25', 'Solicitud de Reintegro', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=22', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('34', 'Encuesta de Satisfacci�n Institucional', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=28', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, PRE_EJECUCION, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('35', 'Encuesta Retorno Seguro II Ciclo Acad�mico 2020', 'ADMISIONES.DEBE_ENCUESTA_COVID', 'http://tigris.lasalle.edu.co/siencuestas-war/', '4', '21', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('36', 'Consulta General', '/consultagen', '3', '4', 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('26', 'Biblioteca', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('27', 'Sistema Integrado de B�squeda', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=22', '4', '26', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('28', 'Bases de Datos Acad�micas', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=23', '4', '26', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('29', 'Cat�logo Sibbila', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=24', '4', '26', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('30', 'Repositorio Ciencia Unisalle', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=25', '4', '26', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('36', 'Consulta General', '/consultagen', '3', '4', 1);
                                                      
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('1', '3',  '31');   
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('2', '4',  '31');             
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('3', '3',  '3');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('4', '3',  '4');                
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('6', '7',  '8'); 
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('7', '7',  '32');   
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('12', '7',  '16');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('13', '7',  '21');             
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('14', '7',  '26');   
              
INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('1', '9', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');
INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('2', '8', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');

-------------------------------------------------------------------------------------------------         
select * from cti_parametro_proceso;
select * from cti_tipo_ejecucion;
select * from cti_menu;

select * from cti_procesos;
--3: Listados (Directores)
--4: Utilidades (Directores)
--8: Imprimir guia de pago (Estudiantes)
--16: Certificados (Estudiantes)
--21: Utilidades (Estudiantes)
--26: Biblioteca (Estudiantes)
--31: Carga Académica (Directores y Asistentes)
--32: Acompañamiento tutorial (Directores)

select * from cti_perfiles;
--3: Director de programa
--4: Asistente de programa
--7: Estudiante
                            