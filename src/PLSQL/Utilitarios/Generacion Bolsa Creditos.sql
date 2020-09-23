DELETE FROM POSTGRADO.CTI_BOLSA_EST_MAT WHERE CODIGO_MATERIA = '80102';
select * from postgrado.A_MATERIAS WHERE CODIGO LIKE 'DE%';
select * from postgrado.CTI_BOLSA_EST_MAT;
select * from postgrado.a_notas where CODIGO_ESTUDIANTE = 'MG182210';
select admisiones.pkg_utils.PROMEDIOPONDERADOTOTAL('MG182210')
from dual;
DELETE FROM POSTGRADO.a_notas where CODIGO_ESTUDIANTE = 'MG182210' AND CODIGO_MATERIA = '80102';
GRANT SELECT ON POSTGRADO.CTI_BOLSAS_CREDITOS TO ADMISIONES;
GRANT SELECT ON POSTGRADO.CTI_BOLSA_ESTUDIANTE TO ADMISIONES;
GRANT SELECT ON POSTGRADO.CTI_BOLSA_EST_MAT TO ADMISIONES;
GRANT SELECT ON POSTGRADO.CTI_BOLSAS_CREDITOS TO SGCERTIFICADOS;
GRANT SELECT ON POSTGRADO.CTI_BOLSA_ESTUDIANTE TO SGCERTIFICADOS;
GRANT SELECT ON POSTGRADO.CTI_BOLSA_EST_MAT TO SGCERTIFICADOS;
INSERT INTO POSTGRADO.CTI_BOLSAS_CREDITOS (ID_BOLSA, CODIGO_FACULTAD, JORNADA_FACULTAD, PLAN_ESTUDIO, NOMBRE, FN_CUMPLIMIENTO, FN_OFERTA, TOPE, ACTIVO) 
                                   VALUES (1, '85', 'N', '4', 'Bolsa de créditos electivos', 'pkg_bolsa_electivos.cumple', 'POSTGRADO.PKG_BOLSAS_ELECTIVAS.GET_MATERIAS_BOLSA_ELECTIVA', 6, 1);
INSERT INTO CTI_BOLSA_ESTUDIANTE VALUES ('2', 'MG182210', '2');                                    
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', '80202', '1', '83', 'N', '2019', '02', '1');                
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', '80204', '1', '83', 'N', '2019', '02', '1');                
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', '80702', '2', '83', 'N', '2019', '02', '1');
INSERT INTO A_NOTAS VALUES ('MG182210', '80202', '83', 'N', '2018', '03', 'SEGUNDO CICLO', 4.4, 'N', '1', 0 ,'911982234');
INSERT INTO A_NOTAS VALUES ('MG182210', '80204', '83', 'N', '2019', '01', 'PRIMER CICLO', 4.4, 'N', '1', 0 ,'911982234');
INSERT INTO A_NOTAS VALUES ('MG182210', '80702', '83', 'N', '2019', '03', 'SEGUNDO CICLO', 4.4, 'N', '2', 0 ,'911982234');
INSERT INTO A_NOTAS VALUES ('MG182210', '80702', '83', 'N', '2019', '01', 'PRIMER CICLO', 2.5, 'N', '2', 0 ,'911982234');

          
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', 'DES20', '3', 'DE', 'N', '2018', '01', '1');    
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', 'DES21', '3', 'DE', 'N', '2017', '02', '1');    
INSERT INTO CTI_BOLSA_EST_MAT VALUES('2', 'DES43', '3', 'DE', 'N', '2017', '02', '1');    
INSERT INTO A_NOTAS VALUES ('MG182210', 'DES20', 'DE', 'N', '2018', '01', 'PRIMER CICLO', 1.0, 'N', '3', 0 ,'911982234');
INSERT INTO A_NOTAS VALUES ('MG182210', 'DES21', 'DE', 'N', '2017', '03', 'SEGUNDO CICLO', 1.0, 'N', '3', 0 ,'911982234');
INSERT INTO A_NOTAS VALUES ('MG182210', 'DES43', 'DE', 'N', '2017', '03', 'SEGUNDO CICLO', 1.0, 'N', '3', 0 ,'911982234');

SELECT * FROM ADMISIONES.B_PREMATRICULA WHERE CODIGO_ESTUDIANTE = 'MG182210';

INSERT INTO postgrado.B_PREMATRICULA (CODIGO_ESTUDIANTE,FACULTAD,MATERIA_PLAN,FACULTAD_CURSAR,MATERIA_CURSAR,GRUPO,JORNADA_FACULTAD,INDICADOR_REGLAMENTO,FECHA,FLAG_PROCESADO,OTROS,INDICADOR_PAGO,FECHA_IMPRESION,ANIO,CICLO,CODMIL,PRIMER_PARCIAL,SEGUNDO_PARCIAL,EXAMEN_FINAL,DEFINITIVA,PRIMER_PARCIALT,PRIMER_PARCIALP,SEGUNDO_PARCIALT,SEGUNDO_PARCIALP,EXAMEN_FINALT,EXAMEN_FINALP,FALLAS_PRIMER_CORTE,FALLAS_SEGUNDO_CORTE,TOTAL_FALLAS,NOMBRE,DEFINITIVA_DEPURADA,DEFINITIVA_ORIGINAL,ID_CURSO) VALUES 
('MG182210','83','80702','83','80702','1','N',NULL,TO_DATE('10-JUN-19','DD-MON-RR'),NULL,NULL,'P',NULL,'2019','02','262152154',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CELY MORENO MARIA PAULA',NULL,NULL,71973);

Insert into postgrado.B_PREMATRICULA (CODIGO_ESTUDIANTE,FACULTAD,MATERIA_PLAN,FACULTAD_CURSAR,MATERIA_CURSAR,GRUPO,JORNADA_FACULTAD,INDICADOR_REGLAMENTO,FECHA,FLAG_PROCESADO,OTROS,INDICADOR_PAGO,FECHA_IMPRESION,ANIO,CICLO,CODMIL,DEFINITIVA,NOMBRE,TOTAL_FALLAS,CONSECUTIVO) values 
('MG182210','83','80702','83','80702','1','N',null,to_date('09-JUL-19','DD-MON-RR'),null,null,'P',null,'2019','02','782191204',null,'FONSECA GAMBA YENY PATRICIA',null,0);


DELETE FROM A_NOTAS WHERE CODIGO_ESTUDIANTE = 'MG182210' AND CODIGO_MATERIA IN ('80102', '80202', '80204', '80702');
DELETE FROM ADMISIONES.B_PREMATRICULA WHERE CODIGO_ESTUDIANTE = 'MG182210';

select * from postgrado.B_PREMATRICULA where rownum < 2;

select * from a_materias where CODIGO IN ('80102', '80202', '80204', '80702');
-------- TEST ZONE
-------- TEST ZONE
-------- TEST ZONE
-------- TEST ZONE
-------- TEST ZONE
-------- TEST ZONE
-------- TEST ZONE

SELECT     M.CODIGO,
           M.NOMBRE,
           N.VALOR
FROM       POSTGRADO.B_ESTUDIANTES E 
INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
INNER JOIN POSTGRADO.CTI_BOLSAS_CREDITOS BC ON BC.ID_BOLSA = BE.ID_BOLSA
INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
-- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
INNER JOIN ADMISIONES.A_NOTAS N ON     N.CODIGO_MATERIA   = BEM.CODIGO_MATERIA
                        AND N.IND_HNVOPLAN     = BEM.PLAN_ESTUDIO
                        AND N.CODIGO_FACULTAD  = BEM.CODIGO_FACULTAD
                        AND N.JORNADA_FACULTAD = BEM.JORNADA_FACULTAD
-- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
INNER JOIN A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                           AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                           AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                           AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
WHERE          BE.CODIGO           = 'ASD';




SELECT     M.CODIGO,
           M.NOMBRE,
           N.VALOR,
           e.codigo
FROM       POSTGRADO.B_ESTUDIANTES E 
INNER JOIN POSTGRADO.CTI_BOLSA_ESTUDIANTE BE ON BE.CODIGO = E.CODIGO
INNER JOIN POSTGRADO.CTI_BOLSAS_CREDITOS BC ON BC.ID_BOLSA = BE.ID_BOLSA
INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
-- CRUZANDO NOTAS CON MATERIAS ELECTIVAS.
INNER JOIN A_NOTAS N ON     N.CODIGO_MATERIA    = BEM.CODIGO_MATERIA
                        AND N.IND_HNVOPLAN      = BEM.PLAN_ESTUDIO
                        AND N.CODIGO_FACULTAD   = BEM.CODIGO_FACULTAD
                        AND N.JORNADA_FACULTAD  = BEM.JORNADA_FACULTAD
                        AND N.CODIGO_ESTUDIANTE = E.CODIGO
-- OBTENCION DE INFORMACION DE LA MATERIA ELECTIVA (!IMPORTANTE).
INNER JOIN A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA
                           AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN
                           AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                           AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD;


select * from b_estudiantes where codigo = 'MG182210';
select * from a_planes_de_estudio where codigo_facultad = 'MG';
select * from POSTGRADO.CTI_BOLSAS_CREDITOS where codigo_facultad = 'MG';
select * from POSTGRADO.CTI_BOLSA_EST_MAT;
select * from POSTGRADO.A_NOTAS WHERE CODIGO_ESTUDIANTE = 'MG182210';
select * from ESTADISTICA_INSCR_201902_00 where rownum < 2;

Insert into ESTADISTICA_INSCR_201902_00 (CODIGO_FACULTAD,JORNADA_FACULTAD,NOMFAC,FORMULARIOS_REG_ANT,INSCRITOS_REG_ANT,ENTREVISTADOS_REG_ANT,ADMITIDOS_REG_ANT,MATRICULADOS_REG_ANT,FORMULARIOS_SPP_ANT,INSCRITOS_SPP_ANT,ENTREVISTADOS_SPP_ANT,ADMITIDOS_SPP_ANT,MATRICULADOS_SPP_ANT,FECHA_INICIAL,FECHA_FINAL,SEMANA,FORMP1_REG_ANT,FORMP1_SPP_ANT) 
values ('MG','N','MAESTRÍA EN DISEÑO Y GESTIÓN DE ESCENARIOS VIRTUALES DE APRENDIZAJE',9,5,2,2,0,0,0,0,0,0,to_date('22-JAN-19','DD-MON-RR'),to_date('28-APR-19','DD-MON-RR'),'Semana I',154,4);


select *
;
UPDATE ESTADISTICA_INSCR_201902_00 SET FECHA_FINAL =TO_DATE('11/21/2019', 'MM/DD/YYYY');
UPDATE postgrado.estadistica_inscripciones SET FECHA_FINAL =TO_DATE('11/21/2019', 'MM/DD/YYYY');
SELECT * FROM postgrado.estadistica_inscripciones;
select n.inscritos_ant
        from    postgrado.estadistica_inscripciones n
        where  TO_CHAR(SYSDATE,'YYYYMMDD') BETWEEN TO_CHAR(n.FECHA_INICIAL,'YYYYMMDD') AND TO_CHAR(n.FECHA_FINAL,'YYYYMMDD');
        
from   ESTADISTICA_INSCR_201902_00 i;
--AND    TO_CHAR(SYSDATE,'YYYYMMDD') BETWEEN TO_CHAR(i.FECHA_INICIAL,'YYYYMMDD') AND TO_CHAR(i.FECHA_FINAL,'YYYYMMDD');

SELECT * FROM A_FACULTADES;

SELECT * FROM A_NOTAS WHERE ROWNUM <2;

-- MISMA CONSULTA PERO EN POSTGRADO.
 SELECT     M.CODIGO,
            M.CREDITOS,
            N.VALOR
 FROM       POSTGRADO.B_ESTUDIANTES E
 INNER JOIN POSTGRADO.A_NOTAS N ON     E.CODIGO       = N.CODIGO_ESTUDIANTE 
 INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = N.CODIGO_MATERIA 
                                      AND M.PLAN_ESTUDIO     = N.IND_HNVOPLAN 
                                      AND M.CODIGO_FACULTAD  = N.CODIGO_FACULTAD
                                      AND M.JORNADA_FACULTAD = N.JORNADA_FACULTAD
 WHERE          N.CICLO NOT IN ('00')
            AND N.CODIGO_ESTUDIANTE = 'MG182210'
            AND CONCAT(N.ANO,N.CICLO) NOT IN (SELECT CONCAT(HE.ANIO, DECODE(HE.CICLO, '01', '01', '02', '03')) AS ANIOCICLO 
                                              FROM   POSTGRADO.HISTORICO_ESTUDIANTES HE 
                                              WHERE      HE.CODIGO='MG182210' 
                                                     AND HE.TIPO_DE_INGRESO = 'RA' 
                                                     AND HE.INDICADOR_PAGO IN ('P','V'))                         
 UNION -- USANDO UNION PARA EVITAR DUPLICADOS.
 
 
 
 SELECT 		M.CODIGO,
                TO_NUMBER(M.SEMESTRE) SEM,
                M.CREDITOS,
                M.INTENSIDAD_HORARIA,
                CASE
                    WHEN BC.CODIGO_MATERIA IS NOT NULL THEN BC.CODIGO_MATERIA || ' (Electiva)'
                    ELSE M.NOMBRE
                END NOMBRE,
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
    FROM        POSTGRADO.B_ESTUDIANTES E
    INNER JOIN  POSTGRADO.B_PREMATRICULA P ON     E.CODIGO = P.CODIGO_ESTUDIANTE
                                              AND E.ANIO   = P.ANIO
                                              AND E.CICLO  = P.CICLO 
    INNER JOIN POSTGRADO.A_MATERIAS M ON     M.CODIGO           = P.MATERIA_PLAN
                                         AND M.CODIGO_FACULTAD  = E.CODIGO_FACULTAD
                                         AND M.JORNADA_FACULTAD = E.JORNADA_FACULTAD
                                         AND (	  M.PLAN_ESTUDIO = E.PLAN_ESTUDIO
                                             OR (	 E.TIPO_DE_INGRESO IN ('RA', 'NR', 'ME')
                                                 AND E.CICLO_DE_INGRESO = E.ANIO || TO_NUMBER(E.CICLO))) 
    -- QUERY PARA IDENTIFICAR MATERIAS CURSADAS POR CREDITOS ELECTIVOS.
    LEFT JOIN       (SELECT     CODIGO_MATERIA,
                                PLAN_ESTUDIO,
                                CODIGO_FACULTAD,
                                JORNADA_FACULTAD
                     FROM       POSTGRADO.CTI_BOLSA_ESTUDIANTE BE
                     INNER JOIN POSTGRADO.CTI_BOLSA_EST_MAT BEM ON BEM.ID_BOLSA_ESTUDIANTE = BE.ID_BOLSA_EST
                     WHERE      BE.CODIGO = 'MG182210') BC ON     BC.CODIGO_MATERIA   = M.CODIGO
                                                            AND BC.PLAN_ESTUDIO     = M.PLAN_ESTUDIO
                                                            AND BC.CODIGO_FACULTAD  = M.CODIGO_FACULTAD
                                                            AND BC.JORNADA_FACULTAD = M.JORNADA_FACULTAD
    WHERE 		      E.CODIGO = 'MG182210';
 
 select * from POSTGRADO.b_estudiantes where CODIGO = 'MG182210';




                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
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
                                 M.CREDITOS,
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
                      WHERE     E.CODIGO = P_CODIGO_ESTUDIANTE
                            AND  n.ano            = p_anio
                              and n.ciclo            = p_ciclo);



                select sum(n.valor * m.creditos) x,
                    sum(m.creditos) y
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
                      where n.ano            =  '2018'
                      and n.ciclo            = '01'
                      and e.codigo           = 'MG182210'
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
                      WHERE     E.CODIGO = 'MG182210'
                            AND  n.ano            = '2018'
                              and n.ciclo            = '01');

select valor, creditos
                      from postgrado.b_estudiantes e
                      inner join postgrado.a_notas n
                      on  e.codigo = n.codigo_estudiante
                      inner join postgrado.a_materias m
                      on  n.codigo_materia   = m.codigo
                      and e.codigo_facultad  = m.codigo_facultad
                      and e.jornada_facultad = m.jornada_facultad
                      where n.ano            =  '2018'
                      and n.ciclo            = '01'
                      and e.codigo           = 'MG182210';
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
                      WHERE     E.CODIGO = 'MG182210'
                            AND  n.ano            = '2018'
                              and n.ciclo            = '01';

