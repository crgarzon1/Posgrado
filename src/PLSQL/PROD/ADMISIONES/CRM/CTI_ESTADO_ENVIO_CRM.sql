CREATE OR REPLACE VIEW CTI_ESTADO_ENVIO_CRM AS
    SELECT DISTINCT A.TIPDOC,
                    A.INTERESADO,
                    A.CRM,
                    A.ASPIRANTE,
                    A.PRIMER_NOMBRE,
                    A.SEGUNDO_NOMBRE,
                    A.PRIMER_APELLIDO,
                    A.SEGUNDO_APELLIDO,
                    A.ORIGEN,
                    A.CODIGO CODIGO_PROGRAMA,
                    A.JORNADA,
                    A.NOMBRE,
                    A.FECHA_CREACION_INTERESADO,
                    A.FECHA_CREACION_SIMPLIFICADA,
                    A.ANIO,
                    A.CICLO,
                    CASE
                        WHEN B.RESPONSE IS NULL THEN
                            'NO ENVIADO'
                        WHEN B.RESPONSE LIKE '%ERROR%' THEN
                            'FALLIDA'
                        ELSE
                            'EXITOSA'
                    END ULTIMA_PETICION,
                    CASE
                        WHEN C.NUMDOC IS NOT NULL THEN
                            'SI'
                        ELSE
                            'NO'
                    END RECIBIDO_CRM,
                    B.REQUEST_DATE LAST_REQUEST_DATE,
                    B.SIMPLE_REQUEST_DATE LAST_REQUEST_SIMPLE_DATE,
                    B.CONTENT LAST_SENDED_CONTENT,
                    B.RESPONSE LAST_SENDED_RESPONSE
    FROM CTI_ESTADO_INTERESADO     A
    LEFT JOIN HTTP_REQUEST_LOG_CRM      B ON A.INTERESADO = B.NUMERO_DOCUMENTO
                                        AND A.CODIGO || A.JORNADA = B.PROGRAMA
                                        AND B.NUMERO_PETICION = '1'
    LEFT JOIN CTI_INTERESADOS_CRM_LOG   C ON A.INTERESADO = C.NUMDOC
                                           AND A.TIPDOC = C.TIPDOC
                                           AND A.CODIGO = C.CODIGO_FACULTAD
                                           AND A.JORNADA = C.JORNADA_FACULTAD
                                           AND A.ANIO = C.ANIO
                                           AND A.CICLO = C.CICLO