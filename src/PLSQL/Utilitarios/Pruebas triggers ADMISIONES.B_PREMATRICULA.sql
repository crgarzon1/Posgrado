-- =============================================================================
-- PRUEBA DE TRIGGER EN PREGRADO.
-- =============================================================================
DELETE FROM ADMISIONES.B_PREMATRICULA WHERE CODIGO_ESTUDIANTE = '26152154' AND ID_CURSO = '71973';
INSERT INTO ADMISIONES.B_PREMATRICULA (CODIGO_ESTUDIANTE, FACULTAD, MATERIA_PLAN, FACULTAD_CURSAR, MATERIA_CURSAR, GRUPO, JORNADA_FACULTAD,
                                       INDICADOR_REGLAMENTO, FECHA, FLAG_PROCESADO, OTROS, INDICADOR_PAGO, FECHA_IMPRESION, ANIO, CICLO,
                                       CODMIL, DEFINITIVA, NOMBRE, TOTAL_FALLAS, ID_CURSO) 
VALUES ('26152154', '26', 'DLR35', '26', 'DL9R1', '1', 'D', NULL, TO_DATE('10-JUN-19','DD-MON-RR'), NULL, NULL, 'P', NULL, '2019', '02', '262152154',
        NULL, 'CELY MORENO MARIA PAULA', NULL, 71973);
-- =============================================================================
-- PRUEBA DE TRIGGER EN PREGRADO CON MATERIAS DE POSTGRADO.
-- =============================================================================
DELETE FROM ADMISIONES.B_PREMATRICULA WHERE CODIGO_ESTUDIANTE = '26152154' AND ID_CURSO = '74356';
INSERT INTO ADMISIONES.B_PREMATRICULA (CODIGO_ESTUDIANTE, FACULTAD, MATERIA_PLAN, FACULTAD_CURSAR, MATERIA_CURSAR, GRUPO, JORNADA_FACULTAD,
                                       INDICADOR_REGLAMENTO, FECHA, FLAG_PROCESADO, OTROS, INDICADOR_PAGO, FECHA_IMPRESION, ANIO, CICLO,
                                       CODMIL, DEFINITIVA, NOMBRE, TOTAL_FALLAS, ID_CURSO)  
VALUES ('26152154', '78', 'EMA23', '78', 'EMA23', '01', 'N', NULL, TO_DATE('09-JUL-19','DD-MON-RR'), NULL, NULL, 'P', NULL, '2019', '02', '782191204',
        NULL, 'FONSECA GAMBA YENY PATRICIA', NULL, 74356);
-- =============================================================================
-- PRUEBA DE TRIGGER EN POSTGRADO.
-- =============================================================================
DELETE FROM POSTGRADO.B_PREMATRICULA WHERE CODIGO_ESTUDIANTE = '78191204' AND CONSECUTIVO = '74356';
INSERT INTO POSTGRADO.B_PREMATRICULA (CODIGO_ESTUDIANTE, FACULTAD, MATERIA_PLAN, FACULTAD_CURSAR, MATERIA_CURSAR, GRUPO, JORNADA_FACULTAD,
                                      INDICADOR_REGLAMENTO, FECHA, FLAG_PROCESADO, OTROS, INDICADOR_PAGO, FECHA_IMPRESION, ANIO, CICLO,
                                      CODMIL, DEFINITIVA, NOMBRE, TOTAL_FALLAS, CONSECUTIVO)  
VALUES ('78191204', '78', 'EMA23', '78', 'EMA23', '01', 'N', NULL, TO_DATE('09-JUL-19','DD-MON-RR'), NULL, NULL, 'P', NULL, '2019', '02', '782191204',
        NULL, 'FONSECA GAMBA YENY PATRICIA', NULL, 74356);
-- =============================================================================
-- CUPOS.
-- =============================================================================
SELECT CUPO_UTILIZADO, CUPO FROM ADMISIONES.A_HORARIO_HORIZONTAL WHERE CONSECUTIVO = '71973';
SELECT CUPO_UTILIZADO, CUPO FROM POSTGRADO.A_HORARIO_HORIZONTAL WHERE CONSECUTIVO = '74356';
-- =============================================================================
-- RESETEAR CUPOS.
-- =============================================================================
UPDATE ADMISIONES.A_HORARIO_HORIZONTAL SET CUPO_UTILIZADO = '0' WHERE CONSECUTIVO = '71973';
UPDATE POSTGRADO.A_HORARIO_HORIZONTAL SET CUPO_UTILIZADO = '0' WHERE CONSECUTIVO = '74356';
UPDATE ADMISIONES.A_HORARIO_HORIZONTAL SET CUPO_UTILIZADO = '23' WHERE CONSECUTIVO = '71973';
UPDATE POSTGRADO.A_HORARIO_HORIZONTAL SET CUPO_UTILIZADO = '15' WHERE CONSECUTIVO = '74356';