create or replace PACKAGE BODY            PKG_UTILS_FOTO IS

  /* Author  : JOSEPH MONROY*/
  /* Created : 23/07/2020 03:36:43 p.m.*/
  /* Purpose :*/

    FUNCTION GETFOTOCODIGOMAYOR (
        P_CODIGO VARCHAR2
    ) RETURN VARCHAR2 IS
        V_URL_FOTO         VARCHAR2 (512);
        V_DOC_ESTUDIANTE   VARCHAR2 (500);
        V_CODIGO_MAYOR     VARCHAR2 (500);
        V_TIPO_PROGRAMA    VARCHAR2 (500);
    BEGIN
        BEGIN
            SELECT DOC.NUMERO_DOCUMENTO
            INTO V_DOC_ESTUDIANTE
            FROM ADMISIONES.V_ESTUDIANTES_TOTAL DOC
            WHERE DOC.CODIGO = P_CODIGO;

            SELECT MAX (V.CODIGO)
            INTO V_CODIGO_MAYOR
            FROM V_ESTUDIANTES_TOTAL V
            WHERE V.NUMERO_DOCUMENTO = V_DOC_ESTUDIANTE
                  AND EXTRACT (YEAR FROM (TO_DATE (SUBSTR (V.CODIGO, 3, 2), 'RRRR'))) ||
            SUBSTR (V.CODIGO, 5, 1) IN (SELECT MAX (EXTRACT (YEAR FROM (TO_DATE (SUBSTR (V2.CODIGO, 3, 2), 'RRRR'))) ||
                                        SUBSTR (V2.CODIGO, 5, 1))
                                        FROM V_ESTUDIANTES_TOTAL V2
                                        WHERE V2.NUMERO_DOCUMENTO = V_DOC_ESTUDIANTE
                                       );

            V_TIPO_PROGRAMA:=PKG_UTILS_PROGRAMAS.GETTIPOPROGRAMA(V_CODIGO_MAYOR);
            IF V_TIPO_PROGRAMA<>'DOCTORADO' THEN
              SELECT ACU.URL
              INTO V_URL_FOTO
              FROM ADMISIONES.A_CARNET_URL ACU
              WHERE ACU.ID IN (SELECT MAX (F.ID)
                               FROM ADMISIONES.A_CARNET_URL F
                               WHERE F.NUMERO_DOCUMENTO = V_CODIGO_MAYOR
                              )
                    AND ROWNUM <= 1;
              V_URL_FOTO := 'http://zeus.lasalle.edu.co/fotos/' || V_URL_FOTO;
            ELSE
              V_URL_FOTO := GETFOTODOCTORADO(V_CODIGO_MAYOR);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_URL_FOTO := 'http://zeus.lasalle.edu.co/sia/fotos/' ||
                V_CODIGO_MAYOR || '.gif';
        END;

        RETURN (V_URL_FOTO);
    END GETFOTOCODIGOMAYOR;

    --FOTO DOCTORADOS
    FUNCTION GETFOTODOCTORADO (
        P_CODIGO VARCHAR2
    ) RETURN VARCHAR2 IS
        V_URL_FOTO  VARCHAR2 (512);
        V_Id_Doc_Foto Varchar2(4000) Default null ;
    BEGIN
        Select max(T.Foto_Documento_Id)
        INTO V_ID_DOC_FOTO
        From Doctorados.Doc_Aspirantes_New T
        Inner Join postgrado.Datos_Personales Dp On Dp.Numero_Documento = T.Documento
        Where T.Documento =(Select Dp.Numero_Documento From postgrado.Datos_Personales Dp
        Where Dp.Codigo_Estudiante=P_Codigo) and Dp.Codigo_Estudiante=P_Codigo;
        if V_ID_DOC_FOTO is not null then
          V_URL_FOTO:='https://jupiter.lasalle.edu.co:8181/GestionDocumentos/oar/documentos/descargarDocumento/'||Pkg_Utils.F_Creartoken(V_Id_Doc_Foto, '3764613438353137');
        else
          V_URL_FOTO := 'http://zeus.lasalle.edu.co/sia/fotos/' || P_CODIGO || '.gif';
        end if;
        RETURN (V_URL_FOTO);
    END GETFOTODOCTORADO;
END PKG_UTILS_FOTO;

