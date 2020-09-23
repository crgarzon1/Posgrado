CREATE OR REPLACE VIEW HTTP_REQUEST_LOG_CRM AS
    SELECT ROW_NUMBER () OVER (
               PARTITION BY TIPO_DOCUMENTO, NUMERO_DOCUMENTO, PROGRAMA
               ORDER BY HTTP_REQUEST_LOG_ID DESC
           ) NUMERO_PETICION,
           A.*
    FROM (SELECT HTTP_REQUEST_LOG_ID,
                 REQUEST_DATE,
                 TO_CHAR (REQUEST_DATE, 'YYYY-MM-DD HH:MI AM') SIMPLE_REQUEST_DATE,
                 HTTP_METHOD,
                 URL,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 1) + 1, INSTR (CONTENT, '&', 1, 1) - INSTR (CONTENT, '=', 1, 1) - 1) PRIMER_NOMBRE,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 2) + 1, INSTR (CONTENT, '&', 1, 2) - INSTR (CONTENT, '=', 1, 2) - 1) SEGUNDO_NOMBRE,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 3) + 1, INSTR (CONTENT, '&', 1, 3) - INSTR (CONTENT, '=', 1, 3) - 1) PRIMER_APELLIDO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 4) + 1, INSTR (CONTENT, '&', 1, 4) - INSTR (CONTENT, '=', 1, 4) - 1) SEGUNDO_APELLIDO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 5) + 1, INSTR (CONTENT, '&', 1, 5) - INSTR (CONTENT, '=', 1, 5) - 1) TIPO_DOCUMENTO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 6) + 1, INSTR (CONTENT, '&', 1, 6) - INSTR (CONTENT, '=', 1, 6) - 1) NUMERO_DOCUMENTO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 7) + 1, INSTR (CONTENT, '&', 1, 7) - INSTR (CONTENT, '=', 1, 7) - 1) EMAIL,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 8) + 1, INSTR (CONTENT, '&', 1, 8) - INSTR (CONTENT, '=', 1, 8) - 1) CELULAR,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 9) + 1, INSTR (CONTENT, '&', 1, 9) - INSTR (CONTENT, '=', 1, 9) - 1) PROGRAMA,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 10) + 1, INSTR (CONTENT, '&', 1, 10) - INSTR (CONTENT, '=', 1, 10) - 1) ORIGEN,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 11) + 1, INSTR (CONTENT, '&', 1, 11) - INSTR (CONTENT, '=', 1, 11) - 1) FECHA,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 12) + 1, INSTR (CONTENT, '&', 1, 12) - INSTR (CONTENT, '=', 1, 12) - 1) HABEAS_DATA,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 13) + 1, INSTR (CONTENT, '&', 1, 13) - INSTR (CONTENT, '=', 1, 13) - 1) PAGO_INSCRIPCION,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 14) + 1, INSTR (CONTENT, '&', 1, 14) - INSTR (CONTENT, '=', 1, 14) - 1) ENTREVISTA,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 15) + 1, INSTR (CONTENT, '&', 1, 15) - INSTR (CONTENT, '=', 1, 15) - 1) ADMITIDO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 16) + 1, INSTR (CONTENT, '&', 1, 16) - INSTR (CONTENT, '=', 1, 16) - 1) MATRICULADO,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 17) + 1, INSTR (CONTENT, '&', 1, 17) - INSTR (CONTENT, '=', 1, 17) - 1) SPP,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 18) + 1, INSTR (CONTENT, '&', 1, 18) - INSTR (CONTENT, '=', 1, 18) - 1) FORMULARIO1,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 19) + 1, INSTR (CONTENT, '&', 1, 19) - INSTR (CONTENT, '=', 1, 19) - 1) FORMULARIO2,
                 SUBSTR (CONTENT, INSTR (CONTENT, '=', 1, 20) + 1, INSTR (CONTENT, '&', 1, 20) - INSTR (CONTENT, '=', 1, 20) - 1) NUEVO,
                 CONTENT,
                 RESPONSE
          FROM HTTP_REQUEST_LOG
         ) A;