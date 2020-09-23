GRANT EXECUTE ON PG_CRED_DOC2 TO POSTGRADO;
GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
DROP TABLE CTI_PARAMETRO_PROCESO;
DELETE FROM CTI_MENU;
DELETE FROM CTI_PROCESOS;
DELETE FROM CTI_TIPO_EJECUCION;

SET DEFINE OFF;

CREATE TABLE CTI_PARAMETRO_PROCESO (
    ID_PARAMETRO NUMBER PRIMARY KEY NOT NULL,
    ID_PROCESO NUMBER REFERENCES CTI_PROCESOS (ID_PROCESO),
    LABEL VARCHAR2 (256) NOT NULL,
    IDENTIFIER VARCHAR2 (256) NOT NULL
);
GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('1', 'URL parametrizable');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('2', 'URL Externa');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('3', 'Componente Angular');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('4', 'PL/SQL');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('5', 'Sin accion');

INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('1', 'Carga Académica Ciclo Actual', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=7', '4', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('2', 'Carga Académica Proximo Ciclo', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=1', '4', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('3', 'Listados', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('4', 'Utilidades', '#', '5', NULL, 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('5', 'Planes de Estudio', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=2', '4', '3', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('6', 'Listado de Reintegros', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=3', '4', '3', 1);
       
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('7', 'Credenciales Docentes y/o Estudiantes', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=4', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('8', 'Imprimir Guia de Pago', '/guiaDePago', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('9', 'Registrar Solicitudes de Reintegro', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=5&P_PARAMS=[PARAMSPLACEHOLDER]', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('10', 'Crear Materias', 'http://pruebasia.lasalle.edu.co/pls/postgradodes/PKG_MENU.CALL_FACADE?P_OPTION_ID=6', '4', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('13', 'Creditos Adicionales', '/creditosAdicionales', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('14', 'Matricula', '/prematricula', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('15', 'Materias Integradas', '/integrados', '3', '4', 1);
                  
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('1', '3',  '1');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('2', '3',  '2');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('3', '3',  '3');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('4', '3',  '4');             
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('6', '7',  '8');  
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('7', '4',  '1');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('8', '4',  '2');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('9', '4',  '3');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('10', '4',  '4'); 

INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('1', '9', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');
INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('2', '8', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');
                             
                             
                             
                                                         


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------



GRANT EXECUTE ON PG_CRED_DOC2 TO POSTGRADO;
GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
DROP TABLE CTI_PARAMETRO_PROCESO;
DELETE FROM CTI_MENU;
DELETE FROM CTI_PROCESOS;
DELETE FROM CTI_TIPO_EJECUCION;

CREATE TABLE CTI_PARAMETRO_PROCESO (
    ID_PARAMETRO NUMBER PRIMARY KEY NOT NULL,
    ID_PROCESO NUMBER REFERENCES CTI_PROCESOS (ID_PROCESO),
    LABEL VARCHAR2 (256) NOT NULL,
    IDENTIFIER VARCHAR2 (256) NOT NULL
);

SET DEFINE OFF;

GRANT SELECT ON CTI_PARAMETRO_PROCESO TO POSTGRADO;
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('1', 'URL parametrizable');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('2', 'URL Externa');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('3', 'Componente Angular');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('4', 'PL/SQL');
INSERT INTO CTI_TIPO_EJECUCION (ID_TIPO_EJECUCION, TIPO_EJECUCION) VALUES('5', 'Sin accion');

INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('1', 'Carga Académica Ciclo Actual', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=7', '4', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('2', 'Carga Académica Proximo Ciclo', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=1', '4', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('3', 'Listados', '#', '5', NULL, 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('4', 'Utilidades', '#', '5', NULL, 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('5', 'Planes de Estudio', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=2', '4', '3', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('6', 'Listado de Reintegros', 'http://registro.lasalle.edu.co/pls/postgrado/PKG_MENU.CALL_FACADE?P_OPTION_ID=3', '4', '3', 1);
       
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
                  VALUES ('14', 'Inscripción de Materias', '/prematricula', '3', '4', 1);
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('15', 'Materias Integradas', '/integrados', '3', '4', 1);
                  
INSERT INTO CTI_PROCESOS (ID_PROCESO, PROCESO, EJECUCION, ID_TIPO_EJECUCION, ID_PROCESO_PADRE, HABILITADO)
                  VALUES ('16', 'Certificados', 'http://jupiter.lasalle.edu.co/certificados/sia', '4', NULL, 1);
                  
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('1', '3',  '1');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('2', '3',  '2');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('3', '3',  '3');              
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('4', '3',  '4');             
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('6', '7',  '8');             
INSERT INTO CTI_MENU (ID_OPCION, ID_PERFIL, ID_PROCESO)
              VALUES ('7', '7',  '16');  

INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('1', '9', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');
INSERT INTO CTI_PARAMETRO_PROCESO (ID_PARAMETRO, ID_PROCESO, LABEL, IDENTIFIER) 
                             VALUES ('2', '8', 'Codigo Estudiantil', '[P_CODIGO_ESTUDIANTE]');
                             



