/*INTERESADOS.*/
SELECT *
FROM CTI_ESTADO_INTERESADO
ORDER BY FECHA_CREACION_INTERESADO DESC;

delete from cti_interesado_crm;
SELECT * FROM CTI_ESTADO_INTERESADO where interesado = '1234566917';

CALL DESARROLLOSPRE.PKG_INTERESADOS_CRM.REFRESH_INTERESADO ('C', '1095802755', '86', 'N', '2020', '02');

SELECT ANIO,
       CICLO,
       PROCESO
FROM ADMISIONES.A_FECHAS_DE_CORTE
WHERE PROCESO IN (
    'ADMISION ESTUDIANTES NUEVOS-PREGRADO',
    'ADMISION ESTUDIANTES NUEVOS-POSTGRADO'
);
   
/* PETICIONES.*/

SELECT HTTP_REQUEST_LOG_ID,
       TO_CHAR (REQUEST_DATE, 'YYYY-MM-DD HH:MI'),
       HTTP_METHOD,
       URL,
       CONTENT,
       RESPONSE
FROM HTTP_REQUEST_LOG
WHERE TRUNC (REQUEST_DATE) = TRUNC (SYSDATE)
ORDER BY HTTP_REQUEST_LOG_ID DESC;

/* EXCEPCIONES.*/

SELECT LOG.EXCEPTION_LOG_ID     EXCEPTION_LOG_ID,
       TO_CHAR (LOG.TRIGGERING_DATE, 'YYYY-MM-DD HH:MI:SS') TRIGGERING_DATE,
       EXCEPTION.EXCEPTION_ID   EXCEPTION_ID,
       EXCEPTION.DESCRIPTION    DESCRIPTION,
       LOG.STACK_TRACE          STACK_TRACE,
       LOG.ADDITIONAL_INFO      ADDITIONAL_INFO
FROM CTI_EXCEPTION_LOG   LOG
INNER JOIN CTI_EXCEPTION       EXCEPTION ON LOG.EXCEPTION_ID = EXCEPTION.EXCEPTION_ID
WHERE TRUNC (LOG.TRIGGERING_DATE) = TRUNC (SYSDATE)
ORDER BY LOG.EXCEPTION_LOG_ID DESC;
/


    INSERT INTO DESARROLLOSPRE.CTI_INTERESADO VALUES (
        'C',
        '12332441312',
        '37',
        'D',
        'MIGUEL111',
        'ANGEL111',
        'SARMIENTO111',
        'ALONSO111',
        '3126854051',
        'zeussar@hotmail.com',
        'coex4axi',
        '2020',
        '01',
        SYSDATE
    );
    
    
    SELECT * FROM A_BLOQUES;
    SELECT * 
    FROM A_BLOQUES;
    SELECT * FROM a_horario_vertical;
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
DROP TRIGGER TEMP_LOG_TRG;
DROP SEQUENCE TEMP_LOG_SEQ;
DROP TABLE TEMP_LOG;

CREATE SEQUENCE TEMP_LOG_SEQ START WITH 1;
/* CREACION DE TABLA.*/

CREATE TABLE TEMP_LOG(
TEMP_LOG_ID NUMBER,
CONTENIDO VARCHAR2(2000)
);

CREATE TRIGGER TEMP_LOG_TRG BEFORE
    INSERT ON TEMP_LOG
    FOR EACH ROW
BEGIN
    SELECT TEMP_LOG_SEQ.NEXTVAL
    INTO :NEW.TEMP_LOG_ID
    FROM DUAL;

END;
/

SELECT * FROM TEMP_LOG ORDER BY TEMP_LOG_ID;
TRUNCATE TABLE TEMP_LOG;
/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
DECLARE
    V_NUMERO_REGISTROS NUMBER;
BEGIN 
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO;
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO
    WHERE ORIGEN = 'sepRebr5';
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO sepRebr5:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO_CRM:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;
    
    DBMS_OUTPUT.PUT_LINE('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
    
    UPDATE DESARROLLOSPRE.CTI_INTERESADO a 
    SET a.PRIMER_NOMBRE = a.PRIMER_NOMBRE || ' ' where a.origen = 'sepRebr5' and not exists(select * from DESARROLLOSPRE.CTI_INTERESADO_CRM b where   a.TIPDOC = b.TIPDOC
                                   AND a.NUMDOC = b.NUMDOC
                                   AND a.CODIGO_FACULTAD = b.CODIGO_FACULTAD
                                   AND a.JORNADA_FACULTAD = b.JORNADA_FACULTAD
                                   AND a.ANIO = b.ANIO
                                   AND a.CICLO = b.CICLO);
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO;
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO
    WHERE ORIGEN = 'sepRebr5';
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO sepRebr5:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;
    
    DBMS_OUTPUT.PUT_LINE('CTI_INTERESADO_CRM:' || V_NUMERO_REGISTROS);
    
    SELECT COUNT(*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;
    
    DBMS_OUTPUT.PUT_LINE('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
END;
/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
DECLARE
    V_NUMERO_REGISTROS NUMBER;
BEGIN
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;

    DBMS_OUTPUT.PUT_LINE ('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
    INNER JOIN (SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'PREGRADO' ESQUEMA
                FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                UNION
                SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'POSTGRADO' ESQUEMA
                FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
    ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                   AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                   AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                   AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                   AND INTERESADO.ANIO = ASPIRANTE.ANIO
                   AND INTERESADO.CICLO = ASPIRANTE.CICLO
    INNER JOIN ADMISIONES.G_OTROS_PAGOS        PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                            AND PAGO_INSCRIPCION.ACTIVA = 1
                                                            AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                            AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
                                                            AND INTERESADO.ORIGEN            = 'sepRebr5';

    DBMS_OUTPUT.PUT_LINE ('G_OTROS_PAGOS TOTAL CON ASPIRANTE:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
    INNER JOIN (SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'PREGRADO' ESQUEMA
                FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                UNION
                SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'POSTGRADO' ESQUEMA
                FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
    ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                   AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                   AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                   AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                   AND INTERESADO.ANIO = ASPIRANTE.ANIO
                   AND INTERESADO.CICLO = ASPIRANTE.CICLO
    INNER JOIN ADMISIONES.G_OTROS_PAGOS        PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                            AND PAGO_INSCRIPCION.INDICADOR_PAGO = 'P'
                                                            AND PAGO_INSCRIPCION.ACTIVA = 1
                                                            AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                            AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
                                                            AND INTERESADO.ORIGEN            = 'sepRebr5';

    DBMS_OUTPUT.PUT_LINE ('G_OTROS_PAGOS TOTAL CON ASPIRANTE PAGO:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
    INNER JOIN (SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'PREGRADO' ESQUEMA
                FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                UNION
                SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'POSTGRADO' ESQUEMA
                FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
    ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                   AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                   AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                   AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                   AND INTERESADO.ANIO = ASPIRANTE.ANIO
                   AND INTERESADO.CICLO = ASPIRANTE.CICLO
    INNER JOIN ADMISIONES.G_OTROS_PAGOS        PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                            AND PAGO_INSCRIPCION.INDICADOR_PAGO = 'X'
                                                            AND PAGO_INSCRIPCION.ACTIVA = 1
                                                            AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                            AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
                                                            AND INTERESADO.ORIGEN            = 'sepRebr5';

    DBMS_OUTPUT.PUT_LINE ('G_OTROS_PAGOS TOTAL CON ASPIRANTE SIN PAGO:' || V_NUMERO_REGISTROS);
    FOR V_PAGO IN (SELECT ID_FACTURA,
                          INDICADOR_PAGO
                   FROM DESARROLLOSPRE.CTI_INTERESADO   INTERESADO
                   INNER JOIN (SELECT CODIGO,
                                      TIPDOC,
                                      NUMDOC,
                                      CODIGO_FACULTAD,
                                      JORNADA_FACULTAD,
                                      ANIO,
                                      CICLO,
                                      'PREGRADO' ESQUEMA
                               FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                               UNION
                               SELECT CODIGO,
                                      TIPDOC,
                                      NUMDOC,
                                      CODIGO_FACULTAD,
                                      JORNADA_FACULTAD,
                                      ANIO,
                                      CICLO,
                                      'POSTGRADO' ESQUEMA
                               FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
                   ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                                  AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                                  AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                                  AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                                  AND INTERESADO.ANIO = ASPIRANTE.ANIO
                                  AND INTERESADO.CICLO = ASPIRANTE.CICLO
                   INNER JOIN ADMISIONES.G_OTROS_PAGOS        PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                                           AND PAGO_INSCRIPCION.INDICADOR_PAGO IN (
                       'X',
                       'P'
                   )
                                                                           AND PAGO_INSCRIPCION.ACTIVA = 1
                                                                           AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                                           AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
                                                                           AND INTERESADO.ORIGEN            = 'sepRebr5'
                  ) LOOP
        UPDATE ADMISIONES.G_OTROS_PAGOS
        SET
            INDICADOR_PAGO =
                CASE
                    WHEN INDICADOR_PAGO = 'X' THEN
                        'P'
                    ELSE
                        'X'
                END
        WHERE ID_FACTURA = V_PAGO.ID_FACTURA;

        UPDATE ADMISIONES.G_OTROS_PAGOS
        SET
            INDICADOR_PAGO =
                CASE
                    WHEN INDICADOR_PAGO = 'X' THEN
                        'P'
                    ELSE
                        'X'
                END
        WHERE ID_FACTURA = V_PAGO.ID_FACTURA;

    END LOOP;

    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;

    DBMS_OUTPUT.PUT_LINE ('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
END;
/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
DECLARE
    V_NUMERO_REGISTROS NUMBER;
BEGIN
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;

    DBMS_OUTPUT.PUT_LINE ('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;

    DBMS_OUTPUT.PUT_LINE ('CTI_INTERESADO_CRM:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
    INNER JOIN (SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'PREGRADO' ESQUEMA
                FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                UNION
                SELECT CODIGO,
                       TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO,
                       'POSTGRADO' ESQUEMA
                FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
    ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                   AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                   AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                   AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                   AND INTERESADO.ANIO = ASPIRANTE.ANIO
                   AND INTERESADO.CICLO = ASPIRANTE.CICLO
    WHERE INTERESADO.ORIGEN = 'sepRebr5'
          AND INTERESADO.ANIO = '2020';

    DBMS_OUTPUT.PUT_LINE ('ASPIRANTES:' || V_NUMERO_REGISTROS);
    FOR V_ASPIRANTE IN (SELECT ASPIRANTE.CODIGO,
                               ASPIRANTE.TIPDOC,
                               ASPIRANTE.NUMDOC,
                               ASPIRANTE.CODIGO_FACULTAD,
                               ASPIRANTE.JORNADA_FACULTAD,
                               ASPIRANTE.ANIO,
                               ASPIRANTE.CICLO,
                               ASPIRANTE.ESQUEMA
                        FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
                        INNER JOIN (SELECT CODIGO,
                                           TIPDOC,
                                           NUMDOC,
                                           CODIGO_FACULTAD,
                                           JORNADA_FACULTAD,
                                           ANIO,
                                           CICLO,
                                           'PREGRADO' ESQUEMA
                                    FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                                    UNION
                                    SELECT CODIGO,
                                           TIPDOC,
                                           NUMDOC,
                                           CODIGO_FACULTAD,
                                           JORNADA_FACULTAD,
                                           ANIO,
                                           CICLO,
                                           'POSTGRADO' ESQUEMA
                                    FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
                        ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                                       AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                                       AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                                       AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                                       AND INTERESADO.ANIO = ASPIRANTE.ANIO
                                       AND INTERESADO.CICLO = ASPIRANTE.CICLO
                        WHERE INTERESADO.ORIGEN = 'sepRebr5'
                              AND INTERESADO.ANIO = '2020'
                       ) LOOP IF (V_ASPIRANTE.ESQUEMA = 'PREGRADO') THEN
        UPDATE ADMISIONES.A_ASPIRANTES
        SET
            SEGUNDO_NOMBRE = SEGUNDO_NOMBRE || ' '
        WHERE A_ASPIRANTES.TIPDOC = V_ASPIRANTE.TIPDOC
              AND A_ASPIRANTES.NUMDOC            = V_ASPIRANTE.NUMDOC
              AND A_ASPIRANTES.CODIGO_FACULTAD   = V_ASPIRANTE.CODIGO_FACULTAD
              AND A_ASPIRANTES.JORNADA_FACULTAD  = V_ASPIRANTE.JORNADA_FACULTAD
              AND A_ASPIRANTES.ANIO              = V_ASPIRANTE.ANIO
              AND A_ASPIRANTES.CICLO             = V_ASPIRANTE.CICLO;

    ELSE
        UPDATE POSTGRADO.A_ASPIRANTES
        SET
            SEGUNDO_NOMBRE = SEGUNDO_NOMBRE || ' '
        WHERE A_ASPIRANTES.TIPDOC = V_ASPIRANTE.TIPDOC
              AND A_ASPIRANTES.NUMDOC            = V_ASPIRANTE.NUMDOC
              AND A_ASPIRANTES.CODIGO_FACULTAD   = V_ASPIRANTE.CODIGO_FACULTAD
              AND A_ASPIRANTES.JORNADA_FACULTAD  = V_ASPIRANTE.JORNADA_FACULTAD
              AND A_ASPIRANTES.ANIO              = V_ASPIRANTE.ANIO
              AND A_ASPIRANTES.CICLO             = V_ASPIRANTE.CICLO;
    END IF;
    END LOOP;

    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM HTTP_REQUEST_LOG;

    DBMS_OUTPUT.PUT_LINE ('HTTP_REQUEST_LOG:' || V_NUMERO_REGISTROS);
    SELECT COUNT (*)
    INTO V_NUMERO_REGISTROS
    FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;

    DBMS_OUTPUT.PUT_LINE ('CTI_INTERESADO_CRM:' || V_NUMERO_REGISTROS);
END;
/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/
/* ****************************************************************************************************/

    SELECT * FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;
    
    
    SELECT ID_FACTURA
    FROM ADMISIONES.G_OTROS_PAGOS;
    SELECT COUNT(*)
    FROM DESARROLLOSPRE.CTI_INTERESADO_CRM;
    SELECT COUNT(*)
    FROM HTTP_REQUEST_LOG;
    

select * from DESARROLLOSPRE.CTI_INTERESADO a left join DESARROLLOSPRE.CTI_INTERESADO_CRM b ON a.TIPDOC = b.TIPDOC
                                   AND a.NUMDOC = b.NUMDOC
                                   AND a.CODIGO_FACULTAD = b.CODIGO_FACULTAD
                                   AND a.JORNADA_FACULTAD = b.JORNADA_FACULTAD
                                   AND a.ANIO = b.ANIO
                                   AND a.CICLO = b.CICLO where a.origen = 'sepRebr5' and b.numdoc is null;


SELECT ASPIRANTE.CODIGO,
                                       ASPIRANTE.TIPDOC,
                                       ASPIRANTE.NUMDOC,
                                       ASPIRANTE.CODIGO_FACULTAD,
                                       ASPIRANTE.JORNADA_FACULTAD,
                                       ASPIRANTE.ANIO,
                                       ASPIRANTE.CICLO,
                                       ASPIRANTE.ESQUEMA
                    FROM DESARROLLOSPRE.CTI_INTERESADO INTERESADO
                    INNER JOIN (SELECT CODIGO,
                                       TIPDOC,
                                       NUMDOC,
                                       CODIGO_FACULTAD,
                                       JORNADA_FACULTAD,
                                       ANIO,
                                       CICLO,
                                       'PREGRADO' ESQUEMA
                                FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                                UNION
                                SELECT CODIGO,
                                       TIPDOC,
                                       NUMDOC,
                                       CODIGO_FACULTAD,
                                       JORNADA_FACULTAD,
                                       ANIO,
                                       CICLO,
                                       'POSTGRADO' ESQUEMA
                                FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
                    ) ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                                   AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                                   AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                                   AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                                   AND INTERESADO.ANIO = ASPIRANTE.ANIO
                                   AND INTERESADO.CICLO = ASPIRANTE.CICLO
                    WHERE INTERESADO.ORIGEN = 'sepRebr5'
                          AND INTERESADO.ANIO = '2020';


SELECT * FROM (
            SELECT INTERESADO.TIPDOC,
                   INTERESADO.NUMDOC,
                   INTERESADO.CODIGO_FACULTAD,
                   INTERESADO.JORNADA_FACULTAD,
                   INTERESADO.ANIO,
                   INTERESADO.CICLO,
                   ADMISIONES.PKG_ESTADO_INTERESADO.HABEAS_DATA(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) HABEAS_DATA,
                   ADMISIONES.PKG_ESTADO_INTERESADO.PAGO_INSCRIPCION(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) PAGO_INSCRIPCION,
                   ADMISIONES.PKG_ESTADO_INTERESADO.ENTREVISTA(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) ENTREVISTA,
                   ADMISIONES.PKG_ESTADO_INTERESADO.ADMITIDO(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) ADMITIDO,
                   ADMISIONES.PKG_ESTADO_INTERESADO.MATRICULADO(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) MATRICULADO,
                   ADMISIONES.PKG_ESTADO_INTERESADO.SPP(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) SPP,
                   ADMISIONES.PKG_ESTADO_INTERESADO.FORMULARIO1(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) FORMULARIO1,
                   ADMISIONES.PKG_ESTADO_INTERESADO.FORMULARIO2(INTERESADO.TIPDOC, INTERESADO.NUMDOC, INTERESADO.CODIGO_FACULTAD, INTERESADO.JORNADA_FACULTAD, INTERESADO.ANIO, INTERESADO.CICLO) FORMULARIO2
            FROM DESARROLLOSPRE.CTI_INTERESADO                   INTERESADO);



   SELECT TIPDOC,
                       NUMDOC,
                       CODIGO_FACULTAD,
                       JORNADA_FACULTAD,
                       ANIO,
                       CICLO
                FROM (SELECT CODIGO,
                             TIPDOC,
                             NUMDOC,
                             CODIGO_FACULTAD,
                             JORNADA_FACULTAD,
                             ANIO,
                             CICLO
                      FROM ADMISIONES.A_ASPIRANTES ASPIRANTE_PREGRADO
                      UNION
                      SELECT CODIGO,
                             TIPDOC,
                             NUMDOC,
                             CODIGO_FACULTAD,
                             JORNADA_FACULTAD,
                             ANIO,
                             CICLO
                      FROM POSTGRADO.A_ASPIRANTES ASPIRANTE_POSTGRADO
                ) ASPIRANTE
                WHERE CODIGO = '250630';

SELECT * FROM POSTGRADO.A_ASPIRANTES WHERE CODIGO = '56346';

            SELECT INTERESADO.TIPDOC,
                   INTERESADO.NUMDOC,
                   INTERESADO.CODIGO_FACULTAD,
                   INTERESADO.JORNADA_FACULTAD,
                   INTERESADO.ANIO,
                   INTERESADO.CICLO,
                   1 HABEAS_DATA,
                   CASE WHEN PAGO_INSCRIPCION.CODIGO_EST IS NOT NULL THEN '1' ELSE '0' END PAGO_INSCRIPCION,
                   CASE WHEN ASPIRANTE.PENTRE IS NOT NULL THEN '1' ELSE '0' END ENTREVISTA,
                   CASE WHEN ASPIRANTE.IND1 = 2 THEN '1' ELSE '0' END  ADMITIDO,
                   CASE WHEN ESTUDIANTE.CODIGO IS NOT NULL THEN '1' ELSE '0' END MATRICULADO,
                   CASE WHEN ESTUDIANTE_SPP.DOCUMENTO IS NOT NULL THEN '1' ELSE '0' END SPP,
                   CASE WHEN ASPIRANTE.CODIGO IS NOT NULL THEN '1' ELSE '0' END  FORMULARIO1,
                   CASE WHEN ASPIRANTE.NUMSNP IS NOT NULL THEN '1' ELSE '0' END  FORMULARIO2
            FROM CTI_INTERESADO                   INTERESADO
            LEFT JOIN ADMISIONES.A_ASPIRANTES          ASPIRANTE ON INTERESADO.TIPDOC = ASPIRANTE.TIPDOC
                                                           AND INTERESADO.NUMDOC = ASPIRANTE.NUMDOC
                                                           AND INTERESADO.CODIGO_FACULTAD = ASPIRANTE.CODIGO_FACULTAD
                                                           AND INTERESADO.JORNADA_FACULTAD = ASPIRANTE.JORNADA_FACULTAD
                                                           AND INTERESADO.ANIO = ASPIRANTE.ANIO
                                                           AND INTERESADO.CICLO = ASPIRANTE.CICLO
            LEFT JOIN ADMISIONES.G_OTROS_PAGOS         PAGO_INSCRIPCION ON PAGO_INSCRIPCION.CODIGO_EST = ASPIRANTE.CODIGO
                                                                   AND PAGO_INSCRIPCION.INDICADOR_PAGO = 'P'
                                                                   AND PAGO_INSCRIPCION.ACTIVA = 1
                                                                   AND PAGO_INSCRIPCION.ANIO = ASPIRANTE.ANIO
                                                                   AND PAGO_INSCRIPCION.CICLO = ASPIRANTE.CICLO
            LEFT JOIN ADMISIONES.BENEFICIARIOS_BECAS   ESTUDIANTE_SPP ON ESTUDIANTE_SPP.DOCUMENTO = ASPIRANTE.NUMDOC
                                                                       AND ESTUDIANTE_SPP.ANIO = ASPIRANTE.ANIO
                                                                       AND ESTUDIANTE_SPP.CICLO = ASPIRANTE.CICLO
            LEFT JOIN ADMISIONES.B_ESTUDIANTES         ESTUDIANTE ON ESTUDIANTE.CODIGO = ASPIRANTE.COD_DEF
                                                             AND ESTUDIANTE.INDICADOR_PAGO IN ('P','V')
            WHERE INTERESADO.TIPDOC = P_TIPDOC
                  AND INTERESADO.NUMDOC            = P_NUMDOC
                  AND INTERESADO.CODIGO_FACULTAD   = P_CODIGO_FACULTAD
                  AND INTERESADO.JORNADA_FACULTAD  = P_JORNADA_FACULTAD
                  AND INTERESADO.ANIO              = P_ANIO
                  AND INTERESADO.CICLO             = P_CICLO
                  AND INTERESADO.ORIGEN            = 'sepRebr5';