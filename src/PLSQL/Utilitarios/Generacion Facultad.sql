
-- ****************************************************************************************************************************
--  __  __      _      ___   _   _ 
-- |  \/  |    / \    |_ _| | \ | |
-- | |\/| |   / _ \    | |  |  \| |
-- | |  | |  / ___ \   | |  | |\  |
-- |_|  |_| /_/   \_\ |___| |_| \_|
-- ****************************************************************************************************************************

DELETE FROM ADMISIONES.A_MATERIAS_PENDIENTES WHERE CODIGO_ESTUDIANTE = 'MG123456';
DELETE FROM ADMISIONES.A_PROGRAMAS WHERE CODIGO = 'MG'; 
DELETE FROM ADMISIONES.A_FACULTADES_UNICA WHERE CODIGO_FACULTAD = 'MG'; 
DELETE FROM ADMISIONES.A_PLANES_DE_ESTUDIO WHERE CODIGO_FACULTAD = 'MG'; 
DELETE FROM ADMISIONES.A_USUARIOS WHERE USUARIO = 'ZRMG'; 
DELETE FROM ADMISIONES.A_MATERIAS WHERE CODIGO IN ('MDG01', 'MDG02', 'MDG03', 'MDG04', 'MDG05', 'MDG06', 'MDG07', 'MDG08', 'MDG09',
                                                   'MDG10', 'MDG11', 'MDG12', 'MDG13', 'MDG14', 'MDG15', 'FLA14', 'MDG16');
DELETE FROM POSTGRADO.CTI_CREDITOS_PERIODO WHERE CODIGO_FACULTAD = 'MG';                                            
DELETE FROM ADMISIONES.B_ESTUDIANTES WHERE CODIGO = 'MG123456';      
DELETE FROM POSTGRADO.B_ESTUDIANTES WHERE CODIGO = 'MG123456';      
DELETE FROM POSTGRADO.CTI_BOLSA_GENERAL WHERE CODIGO = 'MG123456';  
DELETE FROM ADMISIONES.A_FACULTADES WHERE CODIGO = 'MG';
DELETE FROM POSTGRADO.A_FACULTADES WHERE CODIGO = 'MG';    
                
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE LA FACULTAD. A_FACULTADES (ADMISIONES Y POSTGRADO), A_PROGRAMAS Y A_FACULTADES_UNICA.
-- ****************************************************************************************************************************

INSERT INTO ADMISIONES.A_PROGRAMAS VALUES ('ES', 'MG', 'N', 'MAESTRÍA EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE', 
                                           'M. ESC. VIR.', '707', '003');
                                           
INSERT INTO ADMISIONES.A_FACULTADES (CODIGO, JORNADA, NOMBRE, VALOR_SEMESTRE, RESOLUCION, SEDE, CONSECUTIVO_EGRESADO, DIRECCION,
                                     UBICACION_FACULTAD, HORARIO_ATENCION, TELEFONOS_FACULTAD, NUM_SEMESTRES, VIGENCIA, CODIGO_SEDE,
                                     SNIES, ABREVIATURA, ABRIR_INSCRIPCION, ACTIVA, PROCODIGO, REGISTRO_CALIFICADO, RESOLUCION_MEN,
                                     TITULO_A_OTORGAR, INDICADOR)
                             VALUES ('MG', 'N', 'MAESTRÍA EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE', '0', NULL, 
                                     'CHAPINERO', '0', NULL, NULL, NULL, NULL, NULL, 'S', '02', '91435', 'M. ESC. VIR.', 'N', 'S', 
                                     NULL, 'REGISTRO CALIFICADO', 'RESOLUCION M.E.N. No.6140 DE 29-07-11', 
                                     'MAGISTER EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE', 'S');    
                                     
/*INSERT INTO POSTGRADO.A_FACULTADES (CODIGO,  JORNADA, NOMBRE, VALOR_SEMESTRE, RESOLUCION, SEDE, CONSECUTIVO_EGRESADO, DIRECCION,
                                    UBICACION_FACULTAD, HORARIO_ATENCION, TELEFONOS_FACULTAD, NUM_SEMESTRES, VIGENCIA, CODIGO_SEDE,
                                    SNIES, ABREVIATURA, SELECCION)
                            VALUES ('MG', 'N', 'MAESTRÍA EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE', '0', NULL, 
                                    'CHAPINERO', '0', NULL, NULL, NULL, NULL, NULL, 'S', '02', '91435', 'M. ESC. VIR.', 'N');*/
                                     
INSERT INTO ADMISIONES.A_FACULTADES_UNICA (NOMBRE, CODIGO_FACULTAD, NUMERO_SEMESTRES, VALOR_SEMESTRE, INICIO_SEMESTRE, FIN_SEMESTRE,
                                           VALOR_SIG_SEMESTRE, NOMBRE_ABREVIADO, PESO_BIOL_ANT, PESO_QUIM_ANT, PESO_FIS_ANT, PESO_SOC_ANT,
                                           PESO_APTVER_ANT, PESO_ESPAN_ANT, PESO_APTMAT_ANT, PESO_CONMAT_ANT, PESO_BIOL_NVA, PESO_MATE_NVA,
                                           PESO_FILO_NVA, PESO_FISI_NVA, PESO_HIST_NVA, PESO_QUIM_NVA, PESO_LENG_NVA, PESO_GEOG_NVA, PESO_ICFES,
                                           PESO_ENTREVISTA, SELECCION, PESO_LENGEXT_ANT, PESO_LENGEXT_NVA)
                                   VALUES ('MAESTRÍA EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE', 'MG', NULL, NULL, NULL, NULL, 
                                           NULL, NULL, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
                                           'S', '0', '0');    
                                          
INSERT INTO A_PLANES_DE_ESTUDIO (CODIGO_FACULTAD, JORNADA_FACULTAD, PLAN_ESTUDIO, DESCRIPCION) VALUES('MG', 'N', '1', 'ACTUALIZACION');
                                          
INSERT INTO ADMISIONES.A_USUARIOS (USUARIO, CLAVE, CODIGO) 
                           VALUES ('ZRMG', 'MGZR', 'dMG');
                           

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- INSERCION DE LAS MATERIAS.
-- ****************************************************************************************************************************     

-- PRIMER SEMESTRE.

INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG01', 'ESTRATEGIAS COMUNICATIVAS Y ACOMPAÑAMIENTO', '10', '1', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');   
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG02', 'COGNICION Y APRENDIZAJE EN ESCENARIOS VIRTUALES', '10', '1', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');     
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG03', 'FUNDAMENTOS DE DISEÑO INSTRUCCIONAL', '10', '1', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');      
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG04', 'PLATAFORMAS DIGITALES DE APRENDIZAJE', '10', '1', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');      
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG05', 'INVESTIGACION I', '10', '1', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');              

-- SEGUNDO SEMESTRE.       
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG06', 'COMPETENCIAS COMUNICATIVAS EN LENGUA EXTRANJERA I', '8', '2', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');                               
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG07', 'DISEÑO DE CURSOS B-LEARNING', '10', '2', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');                                 
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG08', 'DISEÑO DE CURSOS B-LEARNING - DIRIGIDOS Y AUTOGESTIONABLES', '10', '2', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');                                 
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG09', 'INVESTIGACION II', '10', '2', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');             

-- TERCER SEMESTRE.        
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG10', 'COMPETENCIAS COMUNICATIVAS EN LENGUA EXTRANJERA II', '8', '3', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG11', 'EVALUACION SISTEMICA EN ESCENARIOS VIRTUALES', '10', '3', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG12', 'CURADURIA Y PRODUCCION RECURSOS EDUCATIVOS DIGITALES BASICOS', '10', '3', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG13', 'INVESTIGACION III', '10', '3', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');              

-- CUARTO SEMESTRE.        

INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG14', 'GESTION DE PROYECTOS VIRTUALES', '10', '4', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG15', 'PRODUCCION DE RECURSOS EDUCATIVOS DIGITALES AVANZADOS', '10', '4', '20192', 'MG', 'N', '3', '1', 'P', SYSDATE, '108');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('FLA14', 'HUMANISMO Y CIENCIA', '8', '4', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');  
                                     
INSERT INTO POSTGRADO.A_MATERIAS (CODIGO, NOMBRE, INTENSIDAD_HORARIA, SEMESTRE, VIGENCIA, CODIGO_FACULTAD, JORNADA_FACULTAD, CREDITOS, 
                                  PLAN_ESTUDIO, AREA, FECHA, HOR_TRABAJO_INDEPENDIENTE)
                          VALUES ('MDG16', 'INVESTIGACION IV', '10', '4', '20192', 'MG', 'N', '2', '1', 'P', SYSDATE, '72');              
               
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE CREDITOS POR PERIODO.
-- ****************************************************************************************************************************     

-- PRIMER SEMESTRE.

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '1', '0', '13');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '1', '1', '8');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '1', '2', '5');

-- SEGUNDO SEMESTRE.

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '2', '0', '10');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '2', '1', '5');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '2', '2', '5');

-- TERCER SEMESTRE.

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '3', '0', '10');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '3', '1', '8');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '3', '2', '2');

-- CUARTO SEMESTRE.

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '4', '0', '10');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '4', '1', '8');

INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO VALUES('MG', 'N', '1', '4', '2', '2');
             
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE ESTUDIANTE.
-- ****************************************************************************************************************************        

/*                          
INSERT INTO ADMISIONES.B_ESTUDIANTES (CODIGO, NOMBRE, ICFES, INGLES, SEXO, CICLO_DE_INGRESO, SISTEMAS, TIPO_DE_INGRESO, GRADUADO, DOCUMENTO, 
                                      CODIGO_FACULTAD, JORNADA_FACULTAD, INDICADOR_PAGO, SEMESTRE, ARTICULO11, PROMEDIO_ACUMULADO, 
                                      MATRICULADOS_CICLO_ANTERIOR, INDICADO_PAGO_BANCOS, PLAN_ESTUDIO, DIGITO_CHEQUEO, CODIGO_TRANSACCION, 
                                      VALOR_PAGAR, INTENSIDAD_HORARIA, SEMESTRE_SUPERIOR, MATRICULADOS_CICLO_ACTUAL, MATERIAS_PENDIENTES, 
                                      SEMESTRE_INFERIOR, NUMERO_MATERIAS_VALIDAS, MOTIVO_ANULACION, TOTAL_CREDITOS, CODCOLE, ULTIMO_CICLO_CURSADO, 
                                      CODMIL, PROMEDIO_PONDERADO, ANIO, CICLO, PRUEBA_ACADEMICA, APELLIDOS, NOMBRES, PROMEDIO_BECA, PORCRED_APROBADO,
                                      TOTAL_CREDITOS_APROBADOS, TOTAL_CREDITOS_HOMOLOGADOS, FECHA_MODIFICACION,FECHA_ACTUALIZACION_OAR) 
                              VALUES ('MG123456', 'APELLIDO1 APELLIDO2 NOMBRE1 NOMBRE2', NULL, 'S', 'M', '20192', 'S', 'NV', NULL, '201101NV', 'MG', 
                                      'N', 'P', NULL, NULL, 0, 'C', NULL, '1', NULL, 'SI', NULL, 0, '08', NULL, 2, '08', 1, NULL, 17, '008375', '20192', 
                                      '132111040',3.2, '2019', '02', 0, 'APELLIDO1 APELLIDO2', 'NOMBRE1 NOMBRE2', 3.159, 88.3, 159, 0, 
                                      TO_TIMESTAMP ('14-OCT-14 03.46.47.000000000 PM', 'DD-MON-RR HH.MI.SSXFF AM'), NULL);*/

INSERT INTO POSTGRADO.B_ESTUDIANTES (CODIGO, NOMBRE, ICFES, INGLES, SEXO, CICLO_DE_INGRESO, SISTEMAS, TIPO_DE_INGRESO, GRADUADO, DOCUMENTO, 
                                     CODIGO_FACULTAD, JORNADA_FACULTAD, INDICADOR_PAGO, SEMESTRE, ARTICULO11, PROMEDIO_ACUMULADO, 
                                     MATRICULADOS_CICLO_ANTERIOR, INDICADO_PAGO_BANCOS, PLAN_ESTUDIO, DIGITO_CHEQUEO, CODIGO_TRANSACCION, 
                                     VALOR_PAGAR, INTENSIDAD_HORARIA, SEMESTRE_SUPERIOR, MATRICULADOS_CICLO_ACTUAL, MATERIAS_PENDIENTES, 
                                     SEMESTRE_INFERIOR, NUMERO_MATERIAS_VALIDAS, MOTIVO_ANULACION, TOTAL_CREDITOS, CODCOLE, ULTIMO_CICLO_CURSADO, 
                                     CODMIL, PROMEDIO_PONDERADO, ANIO, CICLO, PRUEBA_ACADEMICA, APELLIDOS, NOMBRES, TOTAL_CREDITOS_APROBADOS, 
                                     FECHA_MODIFICACION, FECHA_ACTUALIZACION_OAR) 
                             VALUES ('MG123456', 'APELLIDO1 APELLIDO2 NOMBRE1 NOMBRE2', NULL, 'S', 'M', '20192', 'S', 'NV', NULL, '201101NV', 'MG', 
                                     'N', 'P', NULL, NULL, 0, 'C', NULL, '1', NULL, 'SI', NULL, 0, '08', NULL, 2, '08', 1, NULL, 17, '008375', '20192', 
                                     '132111040',3.2, '2019', '02', 0, 'APELLIDO1 APELLIDO2', 'NOMBRE1 NOMBRE2', 159,  
                                     TO_TIMESTAMP ('14-OCT-14 03.46.47.000000000 PM', 'DD-MON-RR HH.MI.SSXFF AM'), NULL);

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE MATERIAS PENDIENTES DEL ESTUDIANTE.
-- **************************************************************************************************************************** 

/*
INSERT INTO A_MATERIAS_PENDIENTES (CODIGO_FACULTAD, JORNADA_FACULTAD, CODIGO_MATERIA, CODIGO_ESTUDIANTE, INDICADOR_PAGO, NOMBRE_MATERIA, SEMESTRE, 
                                   NOMBRE_ESTUDIANTE, ESTADO, PLAN_ESTUDIO, APROBADA) 
    SELECT 'MG', 'N', CODIGO, 'MG123456', NULL, NOMBRE, SEMESTRE, 'APELLIDO1 APELLIDO2 NOMBRE1 NOMBRE2', NULL, '1', NULL
    FROM   A_MATERIAS
    WHERE  CODIGO_FACULTAD = 'MG';*/

-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE BOLA DE CREDITOS.
-- **************************************************************************************************************************** 

INSERT INTO POSTGRADO.CTI_BOLSAS_CREDITOS (ID_BOLSA, CODIGO_FACULTAD, JORNADA_FACULTAD, PLAN_ESTUDIO, NOMBRE, FN_CUMPLIMIENTO, FN_OFERTA, TOPE, ACTIVO) 
                                   VALUES (2, 'MG', 'N', '1', 'Bolsa de créditos electivos', 'pkg_bolsa_electivos.cumple', 'pkg_bolsa_electivos.oferta', 6, 1);
                                   
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION DE BOLA GENERAL DEL ESTUDIANTE.
-- **************************************************************************************************************************** 

INSERT INTO POSTGRADO.CTI_BOLSA_GENERAL VALUES ('MG123456', '2019', '02', '16', '5');
  
-- ****************************************************************************************************************************
-- REMARKS
-- ****************************************************************************************************************************
-- CREACION CREDITOS MAXIMOS POR TRIMESTRE TODAS LAS FACULTADES.
-- **************************************************************************************************************************** 

SELECT * FROM A_MATERIAS ORDER BY NOMBRE;
 
 DELETE FROM CTI_CREDITOS_PERIODO;
 SELECT * FROM CTI_CREDITOS_PERIODO;
 
 CALL INSERT_CREDITOS_PERIODO('87', 'N', '6', '7'); -- ESP. EN GERENCIA DE EMPRESAS AGROPECUARIAS
 CALL INSERT_CREDITOS_PERIODO('78', 'N', '5', '7'); -- ESP. MEDICINA INTERNA DE PEQUEÑOS ANIMALES
 CALL INSERT_CREDITOS_PERIODO('DA', 'N', '3', '8'); -- DOCTORADO EN AGROCIENCIAS
 CALL INSERT_CREDITOS_PERIODO('MA', 'N', '5', '7'); -- MAESTRIA EN AGROCIENCIAS
 CALL INSERT_CREDITOS_PERIODO('86', 'N', '5', '6'); -- MAESTRIA EN AGRONEGOCIOS
 CALL INSERT_CREDITOS_PERIODO('76', 'N', '8', '7'); -- MAESTRIA EN CIENCIAS VETERINARIAS
 CALL INSERT_CREDITOS_PERIODO('76', 'N', '9', '8'); -- MAESTRIA EN CIENCIAS VETERINARIAS
 CALL INSERT_CREDITOS_PERIODO('76', 'N', '10', '7'); -- MAESTRIA EN CIENCIAS VETERINARIAS
 CALL INSERT_CREDITOS_PERIODO('98', 'N', '6', '7'); -- ESP. EN CONSULTORIA EN FAMILIA Y REDES SOCIALES
 CALL INSERT_CREDITOS_PERIODO('82', 'N', '5', '7'); -- ESP. EN GERENCIA FINANCIERA
 CALL INSERT_CREDITOS_PERIODO('93', 'N', '4', '7'); -- ESP. EN PLANEAC. GESTION Y CTROL. DEL DES SOC
 CALL INSERT_CREDITOS_PERIODO('72', 'N', '6', '6'); -- MAESTRIA EN ESTUDIOS Y GESTION DEL DESARROLLO
 CALL INSERT_CREDITOS_PERIODO('72', 'N', '7', '6'); -- MAESTRIA EN ESTUDIOS Y GESTION DEL DESARROLLO
 CALL INSERT_CREDITOS_PERIODO('74', 'N', '5', '7'); -- MAESTRIA EN GESTION DOCUMENTAL Y ADMON DE ARCHIVOS
 CALL INSERT_CREDITOS_PERIODO('EV', 'N', '5', '6'); -- ESPECIALIZACION EN VOLUNTARIADO
 CALL INSERT_CREDITOS_PERIODO('73', 'N', '5', '8'); -- MAESTRIA EN FILOSOFIA
 CALL INSERT_CREDITOS_PERIODO('MP', 'N', '5', '5'); -- MAESTRIA EN POLITICA Y RELACIONES INTERNACIONALES
 CALL INSERT_CREDITOS_PERIODO('MP', 'N', '6', '7'); -- MAESTRIA EN POLITICA Y RELACIONES INTERNACIONALES 
 CALL INSERT_CREDITOS_PERIODO('DE', 'N', '3', '9'); -- DOCTORADO EN EDUCACION Y SOCIEDAD
 CALL INSERT_CREDITOS_PERIODO('DE', 'N', '5', '8'); -- DOCTORADO EN EDUCACION Y SOCIEDAD 
 CALL INSERT_CREDITOS_PERIODO('MD', 'N', '5', '8'); -- MAESTRIA EN DIDACTICA DE LAS LENGUAS 
 CALL INSERT_CREDITOS_PERIODO('MG', 'N', '1', '7'); -- MAESTRIA EN DISEÑO Y GESTION DE ESCENARIOS VIRTUALES DE APRENDIZAJE -- !IMPORTANTE: VERIFICAR PLAN DE ESTUDIO.
 CALL INSERT_CREDITOS_PERIODO('85', 'N', '4', '7'); -- MAESTRIA EN DOCENCIA 
 CALL INSERT_CREDITOS_PERIODO('OT', 'N', '5', '7'); -- ESPECIALIZACION EN ORTOPTICA Y TERAPIA VISUAL 
 CALL INSERT_CREDITOS_PERIODO('79', 'N', '5', '7'); -- MAESTRIA EN CIENCIAS DE LA VISION
 CALL INSERT_CREDITOS_PERIODO('79', 'N', '6', '7'); -- MAESTRIA EN CIENCIAS DE LA VISION 
 CALL INSERT_CREDITOS_PERIODO('MR', 'N', '5', '6'); -- MAESTRIA EN RECURSO HIDRICO CONTINENTAL
 CALL INSERT_CREDITOS_PERIODO('MR', 'N', '6', '6'); -- MAESTRIA EN RECURSO HIDRICO CONTINENTAL 
 CALL INSERT_CREDITOS_PERIODO('83', 'N', '5', '8'); -- ESP. EN GERENCIA DE MERCADEO
 CALL INSERT_CREDITOS_PERIODO('EI', 'N', '5', '8'); -- ESP. EN AUDITORIA INT. Y ASEGURAM. DE INFORMACION 
 CALL INSERT_CREDITOS_PERIODO('81', 'N', '4', '8'); -- MAESTRIA EN ADMINISTRACION
 CALL INSERT_CREDITOS_PERIODO('81', 'N', '5', '7'); -- MAESTRIA EN ADMINISTRACION 
 CALL INSERT_CREDITOS_PERIODO('94', 'N', '5', '7'); -- ESP. EN GESTION ENERGETICA Y AMBIENTAL 
 CALL INSERT_CREDITOS_PERIODO('91', 'N', '7', '7'); -- ESP. GERENCIA PROYECTOS EN INGENIERIA 
 CALL INSERT_CREDITOS_PERIODO('ES', 'N', '5', '7'); -- ESP. SISTEMAS DE CALIDAD E INOCUIDAD EN ALIMENTOS 
 CALL INSERT_CREDITOS_PERIODO('MH', 'N', '5', '8'); -- MAESTRIA EN HABITAT Y GESTION DEL TERRITORIO
 CALL INSERT_CREDITOS_PERIODO('MH', 'N', '6', '8'); -- MAESTRIA EN HABITAT Y GESTION DEL TERRITORIO
                
 CREATE OR REPLACE PROCEDURE INSERT_CREDITOS_PERIODO(P_CODIGO_FACULTAD VARCHAR2,
                                         P_JORNADA_FACULTAD VARCHAR2,
                                         P_PLAN_ESTUDIO VARCHAR2,
                                         P_CREDITOS_TRIMESTRE NUMBER) IS
    BEGIN
        INSERT INTO POSTGRADO.CTI_CREDITOS_PERIODO
            SELECT DISTINCT *
            FROM   (SELECT   DISTINCT M.CODIGO_FACULTAD,
                                      M.JORNADA_FACULTAD,
                                      P_PLAN_ESTUDIO,
                                      TO_NUMBER(M.SEMESTRE), 
                                      P.ID_PERIODO,
                                      CASE
                                           WHEN P.ID_PERIODO = 0 THEN P_CREDITOS_TRIMESTRE * 2
                                           ELSE P_CREDITOS_TRIMESTRE
                                      END
                    FROM              A_MATERIAS M, 
                                      CTI_PERIODO P
                    WHERE                 CODIGO_FACULTAD = P_CODIGO_FACULTAD
                                      AND JORNADA_FACULTAD = P_JORNADA_FACULTAD
                                     AND SEMESTRE != '00'
                    ORDER BY         M.SEMESTRE,
                                     P.ID_PERIODO) A;
    END;
                                        
                
                
                
                
                
                
                
                
                
                
                