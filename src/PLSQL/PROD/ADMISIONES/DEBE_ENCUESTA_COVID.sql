CREATE OR REPLACE FUNCTION DEBE_ENCUESTA_COVID (
    P_CODIGO_ESTUDIANTE VARCHAR2
) RETURN NUMBER IS
    V_RESPONSE NUMBER DEFAULT 0;
BEGIN
    RETURN 0;
    SELECT CASE
        WHEN RESPUESTA = 0 THEN
            1
        ELSE
            0
    END
    INTO V_RESPONSE
    FROM (SELECT COUNT (*) RESPUESTA
          FROM SIE.SIE_VW_ENCUESTA_GUIA_PAGO@UVIRTUAL.LASALLE.EDU.CO
          WHERE CODIGO = P_CODIGO_ESTUDIANTE
                AND CONTESTO = 'SI'
         ) A;

    RETURN V_RESPONSE;
END;
/

GRANT EXECUTE ON DEBE_ENCUESTA_COVID TO POSTGRADO;

UPDATE G_GUIAS_DE_PAGO SET ACTIVA = '0' WHERE TRUNC(FECHA_GEN) = TRUNC(SYSDATE) AND CODIGO_EST IN('DA182206', 'DE181200', 'DE192200', 'DE172208', 'DE182220', '78192204', '76182201', '74182210', '73192201' ,'72182200', '85191209', 'MG201208', '93201217');

SELECT CODIGO_EST, COUNT(CODIGO_EST) FROM G_GUIAS_DE_PAGO WHERE TRUNC(FECHA_GEN) = TRUNC(SYSDATE) AND CODIGO_EST IN('DA182206', 'DE181200', 'DE192200', 'DE172208', 'DE182220', '78192204', '76182201', '74182210', '73192201' ,'72182200', '85191209', 'MG201208', '93201217')
GROUP BY CODIGO_EST;

update G_GUIAS_DE_PAGO SET ACTIVA = '0' WHERE codigo_guia in (
select a.codigo_guia from g_guias_de_pago a inner join b_estudiantes b on a.codigo_est = b.codigo where TRUNC(FECHA_GEN) = TRUNC(SYSDATE)
union
select a.codigo_guia from g_guias_de_pago a inner join postgrado.b_estudiantes b on a.codigo_est = b.codigo where TRUNC(FECHA_GEN) = TRUNC(SYSDATE));

select a.codigo_guia from g_guias_de_pago a inner join b_estudiantes b on a.codigo_est = b.codigo where TRUNC(FECHA_GEN) = TRUNC(SYSDATE)
union
select a.codigo_guia from g_guias_de_pago a inner join postgrado.b_estudiantes b on a.codigo_est = b.codigo where TRUNC(FECHA_GEN) = TRUNC(SYSDATE);

 select 
          FROM SIE.SIE_VW_ENCUESTA_GUIA_PAGO@UVIRTUAL.LASALLE.EDU.CO where codigo = 'MG201208';

SELECT CASE
    WHEN RESPUESTA = 0 THEN
        1
    ELSE
        0
END
FROM (SELECT COUNT (*) RESPUESTA
      FROM SIE.SIE_VW_ENCU_AUTO_PRE_SALL_ESTU@UVIRTUAL.LASALLE.EDU.CO
      WHERE CODIGO = '94201206'
            AND CONTESTO = 'SI'
     ) A; 
      
      -- pruebas.
     select * from admisiones.view_enc_guias;
     
     SELECT *
          FROM SIE.SIE_VW_ENCUESTA_GUIA_PAGO@UVIRTUAL.LASALLE.EDU.CO
          WHERE CODIGO = '94201206';
     
  
  select distinct substr(codigo, 0, 2)
      --from sie.sie_vw_encu_satis_estu@uvirtual.lasalle.edu.co
      from sie.sie_VW_ENCUESTA_guia_pago@uvirtual.lasalle.edu.co;
      
      select * from a_facultades;