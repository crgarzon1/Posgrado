SELECT * FROM CTI_DESCUENTO;
SELECT * FROM CTI_PERIODO;
SELECT * FROM CTI_DESCUENTO_COD_TRAN;
                       
DROP TRIGGER CTI_DESC_PERIOD_TRG;
DROP TRIGGER CTI_DESCUENTO_TRG;  
DROP SEQUENCE CTI_DESC_PERIOD;   
DROP SEQUENCE CTI_DESCUENTO_SEQ;    
DROP TABLE CTI_DESCUENTO_COD_TRAN;       
DROP TABLE CTI_DESCUENTO;   

-- CREACION DE TABLA.
CREATE TABLE CTI_DESCUENTO(
    ID_DESCUENTO NUMBER PRIMARY KEY NOT NULL, 
	DESCRIPCION VARCHAR2(2000 BYTE) NOT NULL, 
	OPERACION VARCHAR2(200 BYTE) NOT NULL, 
	PRIORIDAD NUMBER NOT NULL, 
	CONSTRAINT "PRIORIDAD_CHECK" CHECK (PRIORIDAD >= 1)
);
CREATE TABLE CTI_DESCUENTO_COD_TRAN(
    ID_DESCUENTO_IND_PAGO NUMBER PRIMARY KEY,
    ID_DESCUENTO NUMBER NOT NULL,
    ID_PERIODO NUMBER NOT NULL,
    CODIGO_TRANSACCION NUMBER NOT NULL,
    CONSTRAINT CTI_DESC_IND_PAGO FOREIGN KEY (ID_DESCUENTO) REFERENCES CTI_DESCUENTO(ID_DESCUENTO),
    CONSTRAINT CTI_DESC_PERIODO FOREIGN KEY (ID_PERIODO) REFERENCES CTI_PERIODO(ID_PERIODO),
    CONSTRAINT UC_PERIODO_TR UNIQUE (ID_DESCUENTO, ID_PERIODO)
);
                   
-- CREACION DE SECUENCIA.
CREATE SEQUENCE CTI_DESCUENTO_SEQ START WITH 1;
CREATE SEQUENCE CTI_DESC_PERIOD START WITH 1;

-- CREACION DE TRIGGER.
CREATE OR REPLACE TRIGGER CTI_DESCUENTO_TRG
BEFORE INSERT ON CTI_DESCUENTO 
FOR EACH ROW
BEGIN
  SELECT CTI_DESCUENTO_SEQ.NEXTVAL
  INTO   :NEW.ID_DESCUENTO
  FROM   DUAL;
END;
/
CREATE TRIGGER CTI_DESC_PERIOD_TRG 
BEFORE INSERT ON CTI_DESCUENTO_COD_TRAN 
FOR EACH ROW
BEGIN
  SELECT CTI_DESC_PERIOD.NEXTVAL
  INTO   :NEW.ID_DESCUENTO_IND_PAGO
  FROM   DUAL;
END;
/

-- INSERCION DE DESCUENTOS.
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes egresados de un programa de pregrado nuevos', 'PKG_DESCUENTOS.ES_EGRESADO_NUEVO', '10');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes egresados de un programa de pregrado antiguos', 'PKG_DESCUENTOS.ES_EGRESADO_ANTIGUO', '20');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes de transferencia interna', 'PKG_DESCUENTOS.ES_TRANSFERENCIA_INTERNA', '30');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes de transferencia externa', 'PKG_DESCUENTOS.ES_TRANSFERENCIA_EXTERNA', '40');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes de reintegro', 'PKG_DESCUENTOS.ES_REINTEGRO', '50');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes de reintegro de actualizacion', 'PKG_DESCUENTOS.ES_REINTEGRO_ACTUALIZACION', '60');
INSERT INTO CTI_DESCUENTO(DESCRIPCION, OPERACION, PRIORIDAD) VALUES ('Descuento aplicado a estudiantes de movilidad entrante', 'PKG_DESCUENTOS.ES_MOVILIDAD_ENTRANTE', '70');

-- INSERCION DE CODIGOS DE TRANSACCION.
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('1', '0', '63');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('1', '1', '80');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('1', '2', '84');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('2', '0', '64');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('2', '1', '81');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('2', '2', '85');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('3', '0', '4');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('3', '1', '83');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('3', '2', '87');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('4', '0', '5');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('4', '1', '83');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('4', '2', '87');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('5', '0', '3');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('5', '1', '82');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('5', '2', '86');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('6', '0', '13');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('6', '1', '82');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('6', '2', '86');
INSERT INTO CTI_DESCUENTO_COD_TRAN(ID_DESCUENTO, ID_PERIODO, CODIGO_TRANSACCION) VALUES('7', '0', '81');

-- VERIFICACION DE DESCUENTOS.
SELECT * 
FROM   (SELECT PKG_LIQUIDACION.GET_DESCUENTO(CODIGO, '1') CODIGO_TRANSACCION,
               CODIGO, 
               TIPO_DE_INGRESO, 
               CICLO_DE_INGRESO,
               ANIO || TO_NUMBER(CICLO) CICLO_ACTUAL
       FROM B_ESTUDIANTES) A
WHERE      CODIGO_TRANSACCION IS NOT NULL
       AND CODIGO_TRANSACCION NOT IN ('80', '81');
       
SELECT * FROM B_ESTUDIANTES WHERE codigo = '81201206';
select * from ADMISIONES.a_graduados where numero_acta not in ('0', '8888');
select pkg_utils.PROMEDIOPONDERADOTOTAL('72162219') from dual;
select * from admisiones.a_notas where codigo_estudiante = '10092269';
select * from postgrado.datos_personales where codigo_estudiante = '72162219';

select * from admisiones.g_guias_de_pago where codigo_est= '81201206' and total_cred_adicionales > '0';
