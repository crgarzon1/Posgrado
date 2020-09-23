CREATE OR REPLACE VIEW MATERIAS_DOCENTE_BLOQUES AS
    SELECT NUMERO_DOCUMENTO,
           CODIGO_FACULTAD,
           JORNADA_FACULTAD,
           CODIGO_MATERIA,
           NOMBRE_MATERIA,
           GRUPO,
           DIA ID_DIA,
           CASE TO_NUMBER (DIA)
               WHEN 1   THEN
                   'Lunes'
               WHEN 2   THEN
                   'Martes'
               WHEN 3   THEN
                   'Miercoles'
               WHEN 4   THEN
                   'Jueves'
               WHEN 5   THEN
                   'Viernes'
               WHEN 6   THEN
                   'Sabado'
               WHEN 7   THEN
                   'Domingo'
           END DIA,
           HORA,
           AREA,
           SALON
    FROM A_BLOQUES
    WHERE TO_NUMBER (DIA) IN ('1', '2', '3', '4', '5', '6', '7')
    UNION
    SELECT NUMERO_DOCUMENTO,
           CODIGO_FACULTAD,
           JORNADA_FACULTAD,
           CODIGO_MATERIA,
           NOMBRE_MATERIA,
           GRUPO,
           DIA ID_DIA,
           CASE TO_NUMBER (DIA)
               WHEN 1   THEN
                   'Lunes'
               WHEN 2   THEN
                   'Martes'
               WHEN 3   THEN
                   'Miercoles'
               WHEN 4   THEN
                   'Jueves'
               WHEN 5   THEN
                   'Viernes'
               WHEN 6   THEN
                   'Sabado'
               WHEN 7   THEN
                   'Domingo'
           END DIA,
           HORA,
           AREA,
           SALON
    FROM A_BLOQUES_POS
    WHERE TO_NUMBER (DIA) IN ('1', '2', '3', '4', '5', '6', '7')
    ORDER BY 1,
             2,
             3,
             4,
             6,
             8,
             9;
/