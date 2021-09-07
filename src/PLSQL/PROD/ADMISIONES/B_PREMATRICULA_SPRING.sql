create or replace PACKAGE BODY B_PREMATRICULA_SPRING
IS
FUNCTION F_PREMATRICULA_ACTIVA(
    p_anio  VARCHAR2,
    p_ciclo VARCHAR2)
  RETURN NUMERIC
IS
  v_estado VARCHAR(8);
BEGIN
  SELECT a.activacion_prematricula
  INTO v_estado
  FROM a_ciclos_academicos a
  WHERE a.tipo = 'P'
  AND a.ciclo  = p_anio
    || to_number(p_ciclo);
  IF v_estado != 'S' THEN
    RETURN(0);
  END IF;
  RETURN(1);
EXCEPTION
WHEN OTHERS THEN
  RETURN(-1);
END F_PREMATRICULA_ACTIVA;
FUNCTION F_VALIDAR_ESTUDIANTE_NUEVO(
    p_codigo VARCHAR2)
  RETURN NUMERIC
IS
  msg       VARCHAR2(100);
  res       VARCHAR2(100);
  num       NUMBER;
  v_niw     VARCHAR2(10);
  v_tipoest VARCHAR2(10);
BEGIN
  /*res          := revisar_documentos( p_codigo, msg);
  IF trim(res) != 'OK' THEN
    RETURN(0);
  END IF;
  num   :=existe_usuario(p_codigo);
  IF num < 1 THEN
    RETURN(0);
  END IF;
  SELECT AP.CODIGO,
    AP.TIPOEST
  INTO V_NIW,
    V_TIPOEST
  FROM A_ASPIRANTES AP
  WHERE AP.COD_DEF=p_codigo;
  num            :=ENCUESTAS.CONTESTO_ENCUESTA(V_NIW,p_codigo);
  IF num          < 1 THEN
    RETURN(0);
  END IF;*/
  RETURN(1);
EXCEPTION
WHEN OTHERS THEN
  RETURN(-1);
END F_VALIDAR_ESTUDIANTE_NUEVO;
FUNCTION F_GET_HORARIO(
    p_codigo VARCHAR2,
    p_anio   VARCHAR2,
    p_ciclo  VARCHAR2)
  RETURN T_HORARIO
IS
  v_sede a_facultades.sede%type DEFAULT NULL;
  v_facultad    VARCHAR2(2) DEFAULT NULL;
  v_NumeroError NUMBER;
  v_TextoError  VARCHAR2(200);
  v_nombre_facultad a_facultades_unica.nombre%type DEFAULT NULL;
  v_semestre VARCHAR(2);
  v_jornada  VARCHAR(1);
  v_minsemestre PLS_INTEGER;
  v_maxsemestre PLS_INTEGER;
  v_ciclo_ingreso b_estudiantes.ciclo_de_ingreso%TYPE;--25-07-2006
  v_tipo_ingreso b_estudiantes.tipo_de_ingreso%TYPE;  --25-07-2006
  v_ciclo_actual a_ciclos_academicos.ciclo%TYPE;      --25-07-2006
  v_tiene_notas       NUMBER DEFAULT 0;
  v_disponible        VARCHAR2(7) DEFAULT NULL;
  v_grupo             VARCHAR2(2) DEFAULT NULL;
  v_creditos          NUMBER := 0;
  v_materia_integrada VARCHAR2(256);
  n                   INTEGER := 0;
  ret_horario T_HORARIO       := T_HORARIO();
  v_response VARCHAR2(1024);
  CURSOR c_Horario(p_codigo VARCHAR2,p_facultad VARCHAR2,p_jornada VARCHAR2,p_semestre VARCHAR2)
  IS
    SELECT h.consecutivo,
      m.semestre,
      h.codigo_materia,
      m.nombre nombre_materia,
      fu.codigo_facultad,
      fu.nombre facultad,
      m.jornada_facultad,
      p.codigo_materia materia_cursar,
      m.intensidad_horaria,
      h.grupo_materia,
      h.cupo - h.cupo_utilizado cupo_disponible,
      h.lunes,
      h.martes,
      h.miercoles,
      h.jueves,
      h.viernes,
      h.sabado,
      DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
      h.creditos,
      H.CUPO,
      (SELECT MAX(DECODE(bl.bloque
        ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
        || ','
        || MAX(DECODE(bl.bloque
        ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      FROM a_bloques bl
      WHERE bl.codigo_facultad=m.codigo_facultad
      AND BL.CODIGO_MATERIA   =p.codigo_materia
      AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
      GROUP BY bl.codigo_facultad,
        bl.codigo_materia,
        bl.grupo
      ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    0 AS postgradual
  FROM A_horario_horizontal h,
    a_materias m,
    a_materias_pendientes p,
    a_facultades_unica fu
  WHERE h.codigo_facultad = m.codigo_facultad
  AND h.jornada_facultad  = m.jornada_facultad
  AND h.codigo_materia    = m.codigo
  AND m.codigo            = p.codigo_materia
  AND m.codigo_facultad   = fu.codigo_facultad
  AND p.codigo_estudiante = p_codigo
  AND h.codigo_facultad   = p_facultad
  AND h.jornada_facultad  = p_jornada
  AND m.semestre          = p_semestre
  AND h.cupo              >0
    --AND (h.cupo - h.cupo_utilizado)>0
  AND h.jornada_facultad =v_jornada
  AND h.abierto          ='S'
  AND p.aprobada        IS NULL
  UNION
  SELECT h.consecutivo,
    p.semestre,
    p.codigo_materia,
    p.nombre_materia ,
    i.facultad_equivalente,
    f.nombre,
    i.jornada_equivalente,
    i.materia_equivalente,
    m.intensidad_horaria,
    h.grupo_materia,
    h.cupo - h.cupo_utilizado,
    h.lunes,
    h.martes,
    h.miercoles,
    h.jueves,
    h.viernes,
    h.sabado,
    DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
    h.creditos,
    H.CUPO,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    0 AS postgradual
  FROM
    a_materias_pendientes p
    inner join a_materias_integradas i on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
    inner join a_horario_horizontal h on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
    inner join a_facultades_unica f on (i.facultad_equivalente = f.codigo_facultad)
    inner join a_materias m on (p.codigo_materia = m.codigo AND i.codigo_facultad = m.codigo_facultad AND i.jornada_facultad = m.jornada_facultad)
  WHERE
    p.codigo_estudiante          = p_codigo
    AND p.codigo_facultad        = p_facultad
    AND p.jornada_facultad       = v_jornada
    AND m.semestre               = p_semestre
    AND i.jornada_equivalente    = p.jornada_facultad
    AND p.aprobada              IS NULL
    AND h.cupo                   > 0
    AND h.abierto                = 'S'
  UNION
  SELECT h.consecutivo,
    p.semestre,
    p.codigo_materia,
    p.nombre_materia ,
    i.facultad_equivalente,
    f.nombre,
    i.jornada_equivalente,
    i.materia_equivalente,
    m.intensidad_horaria,
    h.grupo_materia,
    h.cupo - h.cupo_utilizado,
    h.lunes,
    h.martes,
    h.miercoles,
    h.jueves,
    h.viernes,
    h.sabado,
    DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
    h.creditos,
    H.CUPO,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    0 AS postgradual
  FROM
    a_materias_pendientes p
    inner join a_materias_integradas i on (p.codigo_facultad = i.codigo_facultad and p.jornada_facultad = i.jornada_facultad and p.codigo_materia = i.codigo_materia)
    inner join a_horario_horizontal h on (i.materia_equivalente = h.codigo_materia and i.facultad_equivalente = h.codigo_facultad and i.jornada_equivalente = h.jornada_facultad)
    inner join a_facultades_unica f on (i.facultad_equivalente = f.codigo_facultad)
    inner join a_materias m on (p.codigo_materia = m.codigo AND i.codigo_facultad = m.codigo_facultad AND i.jornada_facultad = m.jornada_facultad)
  WHERE
    p.codigo_estudiante          = p_codigo
    AND p.codigo_facultad        = p_facultad
    AND p.jornada_facultad       = v_jornada
    AND m.semestre               = p_semestre
    AND i.jornada_equivalente    = DECODE(P.JORNADA_FACULTAD,'D','N','N','D')
    AND p.aprobada              IS NULL
    AND h.cupo                   > 0
    AND h.abierto                = 'S'
    AND p.codigo_materia  IN (SELECT CJ.MATERIA FROM A_CAMBIO_JORNADA CJ WHERE CJ.CODIGO =p.codigo_estudiante)
  UNION
  SELECT h.consecutivo,
    p.semestre,
    p.codigo_materia,
    p.nombre_materia ,
    i.facultad_equivalente,
    f2.nombre,
    i.jornada_equivalente,
    i.materia_equivalente,
    m1.intensidad_horaria,
    h.grupo_materia,
    h.cupo - h.cupo_utilizado,
    h.lunes,
    h.martes,
    h.miercoles,
    h.jueves,
    h.viernes,
    h.sabado,
    DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
    h.creditos,
    H.CUPO,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.'))) dia
    FROM a_bloques_pos bl
    WHERE bl.codigo_facultad=i.facultad_equivalente
    AND BL.CODIGO_MATERIA   =p.codigo_materia
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    1 AS postgradual
  FROM a_materias_pendientes p
  INNER JOIN a_materias_integradas i
  ON (p.codigo_materia   = i.codigo_materia
  AND p.codigo_facultad  = i.codigo_facultad
  AND p.jornada_facultad = i.jornada_facultad)
  INNER JOIN a_materias m1
  ON (p.CODIGO_MATERIA=m1.codigo
  AND p.PLAN_ESTUDIO  =m1.PLAN_ESTUDIO)
  INNER JOIN a_facultades_unica f1
  ON (f1.CODIGO_FACULTAD = m1.CODIGO_FACULTAD)
  INNER JOIN postgrado.a_materias m2
  ON (i.MATERIA_EQUIVALENTE =m2.CODIGO
  AND i.FACULTAD_EQUIVALENTE=m2.CODIGO_FACULTAD
  AND i.JORNADA_EQUIVALENTE =m2.JORNADA_FACULTAD)
  INNER JOIN A_FACULTADES_UNICA f2
  ON (f2.CODIGO_FACULTAD=m2.CODIGO_FACULTAD)
  INNER JOIN POSTGRADO.A_HORARIO_HORIZONTAL h
  ON (m2.CODIGO             = h.CODIGO_MATERIA
  AND m2.CODIGO_FACULTAD    =h.CODIGO_FACULTAD
  AND m2.JORNADA_FACULTAD   =h.JORNADA_FACULTAD)
  WHERE p.codigo_estudiante =p_codigo
  AND i.codigo_facultad     =p_facultad
  AND m1.semestre           =p_semestre;
  ----------------------------------------------------------------------------------
  -- OFERTA NO REGULARES
  ----------------------------------------------------------------------------------
  CURSOR todaLaOfertaPragramada(p_codigo VARCHAR2, p_anio VARCHAR2, p_ciclo VARCHAR2)
  IS
    SELECT h.consecutivo,
      m.semestre,
      h.codigo_materia,
      m.nombre nombre_materia,
      f.codigo AS codigo_facultad,
      f.nombre facultad,
      m.jornada_facultad,
      m.codigo materia_cursar,
      m.intensidad_horaria,
      h.grupo_materia,
      h.cupo - h.cupo_utilizado cupo_disponible,
      h.lunes,
      h.martes,
      h.miercoles,
      h.jueves,
      h.viernes,
      h.sabado,
      DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
      h.creditos,
      h.CUPO,
      (SELECT MAX(DECODE(bl.bloque
        ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
        || ','
        || MAX(DECODE(bl.bloque
        ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      FROM a_bloques bl
      WHERE bl.codigo_facultad=m.codigo_facultad
      AND BL.CODIGO_MATERIA   =m.codigo
      AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
      GROUP BY bl.codigo_facultad,
        bl.codigo_materia,
        bl.grupo
      ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    0 AS postgradual
  FROM B_ESTUDIANTES e
  INNER JOIN A_FACULTADES f
  ON (e.CODIGO_FACULTAD = f.CODIGO)
    --AND e.JORNADA_FACULTAD = f.JORNADA)
  INNER JOIN a_materias m
  ON (m.CODIGO_FACULTAD  = f.CODIGO
  AND m.JORNADA_FACULTAD = f.JORNADA)
    --AND m.PLAN_ESTUDIO     = e.PLAN_ESTUDIO)
  INNER JOIN A_HORARIO_HORIZONTAL h
  ON (m.CODIGO           = h.CODIGO_MATERIA
  AND m.CODIGO_FACULTAD  = h.CODIGO_FACULTAD
  AND m.JORNADA_FACULTAD = h.JORNADA_FACULTAD
  AND m.PLAN_ESTUDIO     = h.PLAN_ESTUDIO
  AND h.ANIO             = e.ANIO
  AND h.CICLO            = e.CICLO)
  WHERE h.CUPO           > h.CUPO_UTILIZADO
  AND e.CODIGO           = p_codigo
  AND e.ANIO             = p_anio
  AND e.CICLO            = p_ciclo
  /*UNION
  SELECT h.consecutivo,
    mp.semestre,
    h.codigo_materia,
    m.nombre nombre_materia,
    f2.codigo AS codigo_facultad,
    f2.nombre facultad,
    f2.jornada AS jornada_facultad,
    m.codigo materia_cursar,
    m.intensidad_horaria,
    h.grupo_materia,
    h.cupo - h.cupo_utilizado cupo_disponible,
    h.lunes,
    h.martes,
    h.miercoles,
    h.jueves,
    h.viernes,
    h.sabado,
    DECODE(h.sede,'01','CANDELARIA','02','CHAPINERO','03','NORTE','04','CANDELARIA','05','CHAPINERO','06','NORTE','07','CANDELARIA','08','CHAPINERO','09','NORTE') sede,
    h.creditos,
    h.CUPO,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'11',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'21',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS slunes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'32',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'42',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smartes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'53',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'63',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS smiercoles,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'74',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'84',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sjueves,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'95',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'105',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS sviernes,
    (SELECT MAX(DECODE(bl.bloque
      ||bl.dia,'116',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
      || ','
      || MAX(DECODE(bl.bloque
      ||bl.dia,'126',DECODE(bl.Asigsal,'S',BL.SALON,'LAB.')))
    FROM a_bloques bl
    WHERE bl.codigo_facultad=m.codigo_facultad
    AND BL.CODIGO_MATERIA   =m.codigo
    AND to_number(BL.GRUPO) =to_number(h.grupo_materia)
    GROUP BY bl.codigo_facultad,
      bl.codigo_materia,
      bl.grupo
    ) AS ssabado,
    0 AS postgradual
  FROM B_ESTUDIANTES e
  INNER JOIN A_FACULTADES f
  ON (e.CODIGO_FACULTAD = f.CODIGO)
    --AND e.JORNADA_FACULTAD = f.JORNADA)
  INNER JOIN A_MATERIAS mp
  ON (mp.CODIGO_FACULTAD  = f.CODIGO
  AND mp.JORNADA_FACULTAD = f.JORNADA)
    --AND mp.PLAN_ESTUDIO     = e.PLAN_ESTUDIO)
  INNER JOIN A_MATERIAS_INTEGRADAS i
  ON (mp.CODIGO           = i.CODIGO_MATERIA
  AND mp.CODIGO_FACULTAD  = i.CODIGO_FACULTAD
  AND mp.JORNADA_FACULTAD = i.JORNADA_FACULTAD)
  INNER JOIN A_MATERIAS m
  ON (m.CODIGO           = i.MATERIA_EQUIVALENTE
  AND m.CODIGO_FACULTAD  = i.FACULTAD_EQUIVALENTE
  AND m.JORNADA_FACULTAD = i.JORNADA_EQUIVALENTE)
  INNER JOIN A_FACULTADES f2
  ON (m.CODIGO_FACULTAD  = f2.CODIGO
  AND m.JORNADA_FACULTAD = f2.JORNADA)
  INNER JOIN A_HORARIO_HORIZONTAL h
  ON (m.CODIGO           = h.CODIGO_MATERIA
  AND m.CODIGO_FACULTAD  = h.CODIGO_FACULTAD
  AND m.JORNADA_FACULTAD = h.JORNADA_FACULTAD
  AND m.PLAN_ESTUDIO     = h.PLAN_ESTUDIO
  AND h.ANIO             = e.ANIO
  AND h.CICLO            = e.CICLO)
  WHERE h.CUPO           > h.CUPO_UTILIZADO
  AND f2.codigo NOT     IN ('01','02','03','04','05','06','07','08','09')
  AND h.abierto          ='S'
  AND e.CODIGO           = p_codigo
  AND e.ANIO             = p_anio
  AND e.CICLO            = p_ciclo*/
  ORDER BY semestre,
    codigo_materia;
  --v_integrada a_materias.nombre%TYPE;
  v_ciclo a_ciclos_academicos.ciclo%TYPE;
  v_periodo    VARCHAR2(2);
  v_anio_ciclo VARCHAR2(6) DEFAULT NULL;
  hay_pdf      NUMBER DEFAULT 0;
  v_nomarc a_pdfs.nombre_archivo%type DEFAULT NULL;
  v_existe      NUMBER DEFAULT 0;
  hay_pdf_nvo   NUMBER DEFAULT 0;
  v_nomarc_real VARCHAR2(256) DEFAULT NULL;
  V_PLANCAR     VARCHAR2(1) DEFAULT NULL;
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    RETURN(NULL);
  END IF;
  SELECT COUNT(*)
  INTO v_NumeroError
  FROM a_materias_pendientes mp
  WHERE mp.codigo_estudiante = p_codigo
  AND mp.aprobada           IS NULL;
  v_facultad              := SUBSTR(p_codigo,1,2);
  SELECT be.jornada_facultad,
    be.ciclo_de_ingreso,
    be.tipo_de_ingreso,
    fu.nombre,
    be.plan_estudio
  INTO v_jornada,
    v_ciclo_ingreso,
    v_tipo_ingreso,
    v_nombre_facultad,
    V_PLANCAR
  FROM b_estudiantes be,
    a_facultades_unica fu
  WHERE be.codigo       = p_codigo
  AND be.codigo_facultad=fu.codigo_facultad;
  IF v_NumeroError           > 0 THEN
    SELECT UNIQUE F.CODIGO_SEDE
    INTO v_sede
    FROM a_facultades f
    WHERE f.codigo=SUBSTR(p_codigo,1,2)
    AND f.jornada =v_jornada;
    v_anio_ciclo :=p_anio||p_ciclo;
    --SELECT MAX(hh.anio||hh.ciclo) INTO v_anio_ciclo FROM a_horario_horizontal hh;
    SELECT DECODE(SUBSTR(v_anio_ciclo,5,2),'01','I','02','II')
    INTO v_periodo
    FROM dual;
    --v_facultad:=SUBSTR(p_codigo,1,2);
    SELECT MAX(t.ciclo)
    INTO v_ciclo_actual
    FROM a_ciclos_academicos t
    WHERE t.tipo      ='P';
    IF v_ciclo_actual = v_ciclo_ingreso AND v_tipo_ingreso IN('NV','HM','IH','SA') THEN
      SELECT MIN(p.semestre),
        MAX(p.semestre)
      INTO v_minsemestre,
        v_maxsemestre
      FROM a_materias_pendientes p
      WHERE p.codigo_estudiante = p_codigo
      AND p.aprobada           IS NULL;--19-05-2004 Se agrego esta condicion
    ELSE
      SELECT MIN(p.semestre),
        MAX(p.semestre)
      INTO v_minsemestre,
        v_maxsemestre
      FROM a_materias_pendientes p
      WHERE p.codigo_estudiante = p_codigo
      AND p.aprobada           IS NULL;--19-05-2004 Se agrego esta condicion
    END IF;
    --MODIFICADO EL 17-JAN-2007
    SELECT COUNT(*)
    INTO v_tiene_notas
    FROM a_notas n
    WHERE v_ciclo_actual   = v_ciclo_ingreso
    AND v_tipo_ingreso    IN('NV','HM','IH','SA')
    AND n.codigo_estudiante=p_codigo;
    IF v_tiene_notas       >0 THEN
      v_minsemestre       := '01';
      v_maxsemestre       := '10';
    END IF;
    FOR i IN v_minsemestre..v_maxsemestre
    LOOP
      IF i         <10 THEN
        v_semestre:='0'||i;
      ELSE
        v_semestre:=i;
      END IF;
      FOR v_Horario IN c_Horario(p_codigo,v_facultad,v_jornada,v_semestre)
      LOOP
        IF v_plancar  <'3' THEN
          v_creditos := -1;
        ELSE
          SELECT m.creditos
          INTO v_creditos
          FROM a_materias m
          WHERE m.codigo         = v_Horario.codigo_materia
          AND m.codigo_facultad  = v_facultad
          AND m.jornada_facultad = v_jornada;
        END IF;
        IF v_Horario.codigo_materia <> v_Horario.materia_cursar OR (v_Horario.codigo_materia = v_Horario.materia_cursar AND v_facultad <> v_Horario.codigo_facultad) THEN
          IF v_Horario.postgradual   < 1 THEN
            SELECT m.nombre
            INTO v_materia_integrada
            FROM a_materias m
            WHERE m.codigo         = v_Horario.materia_cursar
            AND m.codigo_facultad  = v_Horario.codigo_facultad
            AND m.jornada_facultad = v_Horario.jornada_facultad;
          ELSE
            SELECT m.nombre
            INTO v_materia_integrada
            FROM postgrado.a_materias m
            WHERE m.codigo         = v_Horario.materia_cursar
            AND m.codigo_facultad  = v_Horario.codigo_facultad
            AND m.jornada_facultad = v_Horario.jornada_facultad;
          END IF;
        ELSE
          v_materia_integrada := v_Horario.NOMBRE_MATERIA;
        END IF;
        v_disponible   := v_Horario.cupo_disponible;
        IF v_disponible <0 THEN
          v_disponible :=0;
        END IF;
        ret_horario.extend;
        n              := n + 1;
        ret_horario(n) := OBJ_HORARIO( v_facultad, v_nombre_facultad, v_jornada, to_number(v_semestre), v_Horario.codigo_materia, v_Horario.NOMBRE_MATERIA, to_number(v_creditos), to_number(v_Horario.intensidad_horaria), to_number(v_Horario.consecutivo), v_horario.codigo_facultad, v_horario.facultad, v_horario.jornada_facultad, v_Horario.materia_cursar, v_materia_integrada, to_number(v_Horario.grupo_materia), to_number(v_Horario.CUPO), to_number(v_Horario.cupo_disponible), v_Horario.lunes, v_Horario.martes, v_Horario.miercoles, v_Horario.jueves, v_Horario.viernes, v_Horario.sabado, v_Horario.slunes, v_Horario.smartes, v_Horario.smiercoles, v_Horario.sjueves, v_Horario.sviernes, v_Horario.ssabado, v_Horario.sede );
      END LOOP;
    END LOOP;
  ELSE
    SELECT COUNT(*)
    INTO v_NumeroError
    FROM B_ESTUDIANTES
    WHERE tipo_de_ingreso IN ('NR', 'RA', 'ME')
    AND codigo             =p_codigo
    AND anio               =p_anio
    AND ciclo              =p_ciclo;
    IF v_NumeroError       > 0 THEN
      FOR v_Horario IN todaLaOfertaPragramada(p_codigo, p_anio, p_ciclo)
      LOOP
        ret_horario.extend;
        n              := n + 1;
        ret_horario(n) := OBJ_HORARIO( v_facultad, v_nombre_facultad, v_jornada, to_number(v_Horario.semestre), v_Horario.codigo_materia, v_Horario.NOMBRE_MATERIA, to_number(v_Horario.creditos), to_number(v_Horario.intensidad_horaria), to_number(v_Horario.consecutivo), v_horario.codigo_facultad, v_horario.facultad, v_horario.jornada_facultad, v_Horario.materia_cursar, v_Horario.NOMBRE_MATERIA, to_number(v_Horario.grupo_materia), to_number(v_Horario.CUPO), to_number(v_Horario.cupo_disponible), v_Horario.lunes, v_Horario.martes, v_Horario.miercoles, v_Horario.jueves, v_Horario.viernes, v_Horario.sabado, v_Horario.slunes, v_Horario.smartes, v_Horario.smiercoles, v_Horario.sjueves, v_Horario.sviernes, v_Horario.ssabado, v_Horario.sede );
      END LOOP;
    END IF;
  END IF;
  RETURN(ret_horario);
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line(SQLCODE || ' --- ' || SUBSTR(SQLERRM,1,200));
  RETURN(NULL);
END F_GET_HORARIO;
FUNCTION F_TIENE_TURNO(
    p_codigo VARCHAR2,
    p_perfil VARCHAR2,
    p_anio   VARCHAR2,
    p_ciclo  VARCHAR2)
  RETURN NUMERIC
IS
  v_turno NUMBER:= 0;
BEGIN
  begin
    select tipo_oferta - 2
    into v_turno
    from cti_turnos_prematricula
    where codigo_estudiante = p_codigo
    and sysdate between inicio and fin;
    return(v_turno);
  exception
  when no_data_found then
    v_turno := 0;
  end;
  if regexp_like(p_perfil, '^UA|NV$') then
    select (
      case
        when count(*) > 0
        then 2
        else 0
      end)
    into v_turno
    from admisiones.turnos_prematricula tp
    where tp.codigo_tipo_estudiante in
      (select tipo.codigo
      from admisiones.a_tipo_estudiante tipo
      where tipo.tipo=p_perfil
      )
    and tp.anio =p_anio
    and tp.ciclo=p_ciclo
    and sysdate between tp.inicio_turno and tp.fin_turno;
    if p_perfil = 'NV' and F_VALIDAR_ESTUDIANTE_NUEVO(p_codigo) = 0 then
      return(-99);
    end if;
  end if;
  return(v_turno);
END F_TIENE_TURNO;
FUNCTION F_GET_CODIGO_CONTRARIO(
    p_codigo VARCHAR2,
    p_anio   VARCHAR2,
    p_ciclo  VARCHAR2)
  RETURN VARCHAR2
IS
  v_cuenta    NUMERIC;
  v_documento VARCHAR2(16);
  v_codigo    VARCHAR2(16);
  v_anio varchar2(4);
  v_ciclo varchar2(2);
  V_SUSPENDIDO NUMBER;
  V_AUTORIZADO NUMBER;
BEGIN
    SELECT dp.numero_documento
    INTO v_documento
    FROM datos_personales dp
    WHERE dp.codigo_estudiante=p_codigo;
    pkg_utils.getAnioCiclo(p_codigo, v_anio, v_ciclo);
    if v_anio = p_anio and v_ciclo = p_ciclo then
        SELECT COUNT(*)
        INTO v_cuenta
        FROM b_estudiantes e
        INNER JOIN datos_personales dp
        ON e.codigo                         = dp.codigo_estudiante
        WHERE dp.numero_documento           =v_documento
        AND e.MATERIAS_PENDIENTES           > 0; 
        IF v_cuenta                         < 1 THEN
            RETURN(NULL);
        END IF;
        SELECT e.codigo
        INTO v_codigo
        FROM b_estudiantes e
        INNER JOIN datos_personales dp
        ON e.codigo               = dp.codigo_estudiante
        WHERE dp.numero_documento =v_documento
        AND e.MATERIAS_PENDIENTES > 0
        and (e.MATRICULADOS_CICLO_ANTERIOR in ('P', 'V') or e.CICLO_DE_INGRESO = e.ANIO || to_number(e.ciclo) or (e.TIPO_DE_INGRESO = 'RI' and exists (select 1 from A_SOLICITUD_REINTEGRO where codigo_estudiante = e.codigo and anio=e.anio and ciclo=e.ciclo)))
        AND e.codigo NOT         IN (p_codigo)
        and e.codigo_facultad != substr(p_codigo, 0, 2)
        --and e.codigo > p_codigo
        AND e.anio                =v_anio
        AND e.ciclo               =v_ciclo;
    else
        v_anio := p_anio;
        v_ciclo := p_ciclo;
        SELECT COUNT(*)
        INTO v_cuenta
        FROM historico_estudiantes e
        INNER JOIN datos_personales dp
        ON e.codigo                         = dp.codigo_estudiante
        WHERE dp.numero_documento           =v_documento
        and e.anio = v_anio
        and e.ciclo = v_ciclo
        AND e.MATERIAS_PENDIENTES           > 0;
        IF v_cuenta                         < 1 THEN
            RETURN(NULL);
        END IF;
        SELECT e.codigo
        INTO v_codigo
        FROM historico_estudiantes e
        INNER JOIN datos_personales dp
        ON e.codigo               = dp.codigo_estudiante
        WHERE dp.numero_documento =v_documento
        AND e.MATERIAS_PENDIENTES > 0
        and (e.MATRICULADOS_CICLO_ANTERIOR in ('P', 'V') or e.CICLO_DE_INGRESO = e.ANIO || to_number(e.ciclo) or (e.TIPO_DE_INGRESO = 'RI' and exists (select 1 from A_SOLICITUD_REINTEGRO where codigo_estudiante = e.codigo and anio=e.anio and ciclo=e.ciclo)))
        AND e.codigo NOT         IN (p_codigo)
        and e.codigo_facultad != substr(p_codigo, 0, 2)
        --and e.codigo > p_codigo
        AND e.anio                =v_anio
        AND e.ciclo               =v_ciclo;
    end if;
    
    SELECT COUNT(*)
    INTO V_SUSPENDIDO
    FROM A_PERIODO_PRUEBA PP
    WHERE PP.CODIGO_ESTUDIANTE = V_CODIGO AND PP.INDICADOR >= 3;
    SELECT COUNT(*)
    INTO   V_AUTORIZADO
    FROM   AUTORIZACIONES_SUSPENSION T
    WHERE  T.CODIGO_ESTUDIANTE = V_CODIGO;
    
    IF V_SUSPENDIDO > 0 AND V_AUTORIZADO = 0 THEN
        RETURN NULL;
    END IF;
    
    RETURN(v_codigo);
EXCEPTION
WHEN OTHERS THEN
    --dbms_output.put_line(SQLCODE || ' --- ' || SUBSTR(SQLERRM,1,200));
    RETURN(NULL);
END F_GET_CODIGO_CONTRARIO;
FUNCTION F_GET_USUARIO_CON_TURNO(
    p_codigo VARCHAR2,
    p_anio   VARCHAR2,
    p_ciclo  VARCHAR2)
  RETURN T_USUARIO
IS
  v_usuario obj_usuario;
  v_ciclo_ingreso VARCHAR2(5);
  v_turno         NUMBER;
  v_codcontrario  VARCHAR2(16);
  v_referente     VARCHAR2(16) DEFAULT NULL;
  v_cred_ext      NUMBER;
  v_semestre_inf  NUMBER;
  v_cred_max      NUMBER;
  v_num_notas     NUMBER;
  ret_usuario T_USUARIO := T_USUARIO();
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    RETURN(NULL);
  END IF;
  P_GET_CREDITOS_MAX(p_codigo, p_anio, p_ciclo, 0, v_semestre_inf, v_cred_max, v_referente);
  ------------------------------------------------------------------------------
  SELECT obj_usuario(e.codigo,
    (SELECT d.numero_documento
    FROM admisiones.a_datos_personales d
    WHERE d.codigo_estudiante=e.codigo
    AND rownum              <=1
    ), NVL(
    (SELECT t.tipo
    FROM admisiones.a_tipo_estudiante t
    WHERE t.tipo = e.tipo_de_ingreso
    ), 'AN'), e.nombres, e.apellidos,
    (SELECT c.correo
    FROM admisiones.correos_institucionales c
    WHERE c.codigo=e.codigo
    ), v_semestre_inf, nvl(v_cred_max,0) , e.codigo_facultad, f.nombre, f.jornada, f.sede, v_referente,
    (SELECT NVL(
      (SELECT ext.tope_creditos
      FROM admisiones.a_prematricula_autorizados ext
      WHERE ext.codigo_estudiante = p_codigo
      AND rownum                 <= 1
      ), 0)
    FROM dual
    ), 0, F_GET_CODIGO_CONTRARIO(p_codigo, p_anio, p_ciclo), e.plan_estudio),
    e.ciclo_de_ingreso
  INTO v_usuario,
    v_ciclo_ingreso
  FROM admisiones.b_estudiantes e
  INNER JOIN admisiones.a_facultades f
  ON (e.codigo_facultad = f.codigo
  AND e.jornada_facultad=f.jornada)
  WHERE e.codigo        =p_codigo
  AND e.anio            =p_anio
  AND e.ciclo           =p_ciclo
  /****************************************************************************/
  and (
    e.matriculados_ciclo_anterior in ('P', 'V')
    or e.ciclo_de_ingreso = e.anio || to_number(e.ciclo)
    or (e.tipo_de_ingreso = 'RI' and exists (select 1 from A_SOLICITUD_REINTEGRO sr where sr.codigo_estudiante = e.codigo and sr.anio=e.anio and sr.ciclo=e.ciclo))
  )
  /****************************************************************************/
  AND NOT EXISTS
    (SELECT 1
    FROM admisiones.a_periodo_prueba pr
    WHERE pr.ano            =e.anio
    AND pr.ciclo            =e.ciclo
    AND pr.codigo_estudiante=e.codigo
    AND pr.indicador       >= 2
    );
  begin
    select 'NV'
    into v_usuario.perfil
    from dual
    where v_usuario.perfil in (Select T.Tipo From A_Tipo_Estudiante T ,Cti_Grupo_Tipo_Est Gr WHERE T.Codigo = Gr.Codigo_Tipo AND Gr.Id_Grupo = 1 Union Select 'NV' From Dual);
  exception when no_data_found then
    null;
  end;
  IF v_usuario.perfil != 'RA' AND v_usuario.perfil != 'NR' AND v_usuario.perfil != 'ME' AND v_ciclo_ingreso != p_anio || to_number(p_ciclo) THEN
    v_usuario.perfil  := 'AN';
  --ELSIF regexp_like(v_usuario.perfil, '^CA|GM|HM|IH|PI|SA|GF|SE|SL$') AND v_ciclo_ingreso = p_anio || to_number(p_ciclo) THEN
  --  v_usuario.perfil  := 'NV';
  ELSIF regexp_like(v_usuario.perfil, '^RA$') AND v_ciclo_ingreso <> p_anio || to_number(p_ciclo) THEN
    return(null);
		ELSIF regexp_like(v_usuario.perfil, '^ME$') then
			 v_usuario.perfil  := 'NR';
  END IF;
  IF v_usuario.perfil = 'NV' THEN
    SELECT COUNT(*)
    INTO v_num_notas
    FROM admisiones.a_notas
    WHERE codigo_estudiante=p_codigo;
    IF v_num_notas         > 0 THEN
      v_usuario.perfil    := 'AN';
    END IF;
  END IF;
  IF v_referente     IS NOT NULL THEN
    v_usuario.perfil := 'DT';
  END IF;
  ------------------------------------------------------------------------------
  v_usuario.turno := F_TIENE_TURNO(v_usuario.codigo, v_usuario.perfil, p_anio, p_ciclo);
  ret_usuario.extend;
  ret_usuario(1) := v_usuario;
  RETURN(ret_usuario);
END F_GET_USUARIO_CON_TURNO;
PROCEDURE P_PREMATRICULAR(
    p_codigo      IN VARCHAR2,
    p_perfil      IN VARCHAR2,
    p_materia     IN VARCHAR2,
    p_consecutivo IN NUMERIC,
    p_anio        IN VARCHAR2,
    p_ciclo       IN VARCHAR2,
    o_respuesta OUT NUMERIC,
    o_semestre_min OUT NUMBER,
    o_creditos_max OUT NUMBER,
    o_referente OUT VARCHAR2)
AS
  v_grupo a_horario_horizontal%ROWTYPE;
  v_grupo_post POSTGRADO.A_HORARIO_HORIZONTAL%ROWTYPE;
  v_creditos        NUMBER:= -1;
  v_facultad        VARCHAR2(4);
  v_jornada         VARCHAR2(4);
  v_plan_estudio    VARCHAR2(2);
  v_tipo_estudiante VARCHAR2(8);
  v_codmil          VARCHAR2(9);
  v_nombre_est      VARCHAR2(50);
  v_semestre        NUMBER;
  v_cred_mat        NUMBER;
  v_cred_ext        NUMBER;
  v_vista           NUMBER;
  v_postgradual     NUMBER;
  v_cruces          NUMBER;
  v_mplan           NUMBER;
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    o_respuesta                            := -999;
    RETURN;
  END IF;
  IF b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 THEN
    o_respuesta                                                               := -1;
    RETURN;
  END IF;
  SELECT est.codigo_facultad,
    est.jornada_facultad,
    est.plan_estudio,
    est.codmil,
    (
    CASE
      WHEN LENGTH(est.nombre) > 50
      THEN SUBSTR(est.nombre, 0, 50)
      ELSE est.nombre
    END),
    est.tipo_de_ingreso
  INTO v_facultad,
    v_jornada,
    v_plan_estudio,
    v_codmil,
    v_nombre_est,
    v_tipo_estudiante
  FROM admisiones.b_estudiantes est
  WHERE est.codigo      =p_codigo;
  IF v_tipo_estudiante <> 'NR' AND v_tipo_estudiante <> 'RA' AND v_tipo_estudiante <> 'ME' THEN
    SELECT COUNT(*)
    INTO v_vista
    FROM b_prematricula_historico h
    WHERE h.codigo_estudiante=p_codigo
    AND h.materia_cursar    IN
      (SELECT ah.codigo_materia
      FROM a_horario_horizontal ah
      WHERE ah.consecutivo=p_consecutivo
      )
    AND h.indicador_pago      IN ('P', 'V')
    AND h.definitiva_depurada >= 3;
    IF v_vista                >= 1 THEN
      o_respuesta             := -5;
      RETURN;
    END IF;
    SELECT to_number(m.semestre),
      to_number(m.creditos)
    INTO v_semestre,
      v_cred_mat
    FROM admisiones.a_materias m
    WHERE m.codigo        =p_materia
    AND m.codigo_facultad =v_facultad
    AND m.jornada_facultad=v_jornada
    AND m.plan_estudio    =v_plan_estudio;
    P_GET_CREDITOS_MAX(p_codigo, p_anio, p_ciclo, v_cred_mat, o_semestre_min, o_creditos_max, o_referente);
    IF v_semestre     < o_semestre_min THEN
      o_semestre_min := v_semestre;
      SELECT cs.creditos
      INTO o_creditos_max
      FROM admisiones.b_estudiantes es
      INNER JOIN admisiones.creditosxsemestre cs
      ON (es.codigo_facultad     =cs.codigo_facultad
      AND es.jornada_facultad    =cs.jornada_facultad
      AND es.plan_estudio        =cs.plan_estudio)
      WHERE es.codigo            = p_codigo
      AND to_number(cs.semestre) = o_semestre_min;
    END IF;
    IF o_referente IS NULL THEN
      SELECT NVL(SUM(m.creditos), 0)
      INTO v_creditos
      FROM admisiones.b_estudiantes e
      INNER JOIN admisiones.b_prematricula p
      ON e.codigo = p.codigo_estudiante
      INNER JOIN admisiones.a_materias m
      ON (p.materia_plan        = m.codigo
      AND p.facultad            = m.codigo_facultad
      AND e.jornada_facultad    = m.jornada_facultad)
      WHERE p.codigo_estudiante = p_codigo
      AND p.anio                =p_anio
      AND p.ciclo               =p_ciclo;
    ELSE
      SELECT NVL(SUM(m.creditos), 0)
      INTO v_creditos
      FROM admisiones.b_estudiantes e
      INNER JOIN admisiones.b_prematricula p
      ON e.codigo = p.codigo_estudiante
      INNER JOIN admisiones.a_materias m
      ON (p.materia_plan        = m.codigo
      AND p.facultad            = m.codigo_facultad
      AND e.jornada_facultad    = m.jornada_facultad)
      WHERE p.codigo_estudiante =p_codigo
      AND p.anio                =p_anio
      AND p.ciclo               =p_ciclo;
    END IF;
    SELECT NVL(
      (SELECT ext.tope_creditos
      FROM admisiones.a_prematricula_autorizados ext
      WHERE ext.codigo_estudiante = p_codigo
      AND rownum                 <= 1
      ), 0)
    INTO v_cred_ext
    FROM dual;
    IF o_creditos_max = 0 THEN
      o_creditos_max := v_cred_mat;
    END IF;
    IF (v_creditos                 + v_cred_mat) > (o_creditos_max+ v_cred_ext) THEN
      o_respuesta               := -3;
      RETURN;
    END IF;
  END IF;
  BEGIN
    SELECT *
    INTO v_grupo
    FROM admisiones.a_horario_horizontal hh
    WHERE hh.consecutivo = p_consecutivo
    AND hh.abierto       ='S'
    AND hh.anio          =p_anio
    AND hh.ciclo         =p_ciclo;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_postgradual := 1;
  END;
  IF v_postgradual > 0 THEN
    SELECT *
    INTO v_grupo_post
    FROM POSTGRADO.A_HORARIO_HORIZONTAL hh
    WHERE hh.consecutivo = p_consecutivo
    AND hh.abierto       ='S'
    AND hh.anio          =p_anio
    AND hh.ciclo         =p_ciclo;
  END IF;
  IF v_grupo.consecutivo IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_cruces
    FROM
      (SELECT COUNT(consecutivo) AS y
      FROM
        (SELECT hv.consecutivo,
          hv.dia
          || hv.hora AS x
        FROM a_horario_vertical hv
        INNER JOIN b_prematricula p
        ON hv.consecutivo         = p.id_curso
        WHERE p.codigo_estudiante = p_codigo
        UNION
        SELECT hv.consecutivo,
          hv.dia
          || hv.hora AS x
        FROM a_horario_vertical hv
        WHERE hv.consecutivo=v_grupo.consecutivo
        ) y
      GROUP BY x
      HAVING COUNT(consecutivo) > 1
      ) z;
    IF v_cruces    > 0 THEN
      o_respuesta := -2;
      RETURN;
    END IF;
    SELECT COUNT(*)
    INTO v_mplan
    FROM b_prematricula
    WHERE materia_plan   =p_materia
    AND codigo_estudiante=p_codigo
    AND anio             =p_anio
    AND ciclo            =p_ciclo;
    IF v_mplan           > 0 THEN
      o_respuesta       := -2;
      RETURN;
    END IF;
    INSERT
    INTO B_PREMATRICULA
      (
        codigo_estudiante,
        facultad,
        materia_plan,
        facultad_cursar,
        materia_cursar,
        grupo,
        jornada_facultad,
        fecha,
        flag_procesado,
        anio,
        ciclo,
        codmil,
        nombre,
        id_curso
      )
    SELECT p_codigo,
      v_facultad,
      p_materia,
      v_grupo.codigo_facultad,
      v_grupo.codigo_materia,
      to_number(v_grupo.grupo_materia),
      v_grupo.jornada_facultad,
      SYSDATE,
      NULL,
      p_anio,
      p_ciclo,
      be.codmil,
      v_nombre_est,
      p_consecutivo
    FROM admisiones.b_estudiantes be
    WHERE be.codigo=p_codigo
    AND EXISTS
      (SELECT 1
      FROM admisiones.a_horario_horizontal hh
      WHERE hh.cupo_utilizado + 1 <= hh.cupo
      AND hh.consecutivo           =p_consecutivo
      AND hh.anio                  =p_anio
      AND hh.ciclo                 =p_ciclo
      );
  elsif v_grupo_post.consecutivo IS NOT NULL THEN
    INSERT
    INTO B_PREMATRICULA
      (
        codigo_estudiante,
        facultad,
        materia_plan,
        facultad_cursar,
        materia_cursar,
        grupo,
        jornada_facultad,
        fecha,
        flag_procesado,
        anio,
        ciclo,
        codmil,
        nombre,
        id_curso
      )
    SELECT p_codigo,
      v_facultad,
      p_materia,
      v_grupo_post.codigo_facultad,
      v_grupo_post.codigo_materia,
      to_number(v_grupo_post.grupo_materia),
      v_grupo_post.jornada_facultad,
      SYSDATE,
      NULL,
      p_anio,
      p_ciclo,
      be.codmil,
      v_nombre_est,
      p_consecutivo
    FROM admisiones.b_estudiantes be
    WHERE be.codigo=p_codigo
    AND EXISTS
      (SELECT 1
      FROM postgrado.a_horario_horizontal hh
      WHERE hh.consecutivo =p_consecutivo
      AND hh.anio          =p_anio
      AND hh.ciclo         =p_ciclo
      );
  ELSE
    o_respuesta := -2;
    ROLLBACK;
    RETURN;
  END IF;
  IF sql%rowcount != 1 THEN
    o_respuesta   := -4;
    ROLLBACK;
    RETURN;
  END IF;
  actualizar_estudiante(p_codigo_estudiante => p_codigo);
  o_respuesta := 1;
  COMMIT;
  P_GET_CREDITOS_MAX(p_codigo, p_anio, p_ciclo, 0, o_semestre_min, o_creditos_max, o_referente);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  o_respuesta := -2;
  ROLLBACK;
WHEN OTHERS THEN
  dbms_output.put_line(SQLCODE || ' --- ' || SUBSTR(SQLERRM,1,200));
  o_respuesta := -99;
  ROLLBACK;
END P_PREMATRICULAR;
PROCEDURE P_DESPREMATRICULAR(
    p_codigo          IN VARCHAR2,
    p_perfil          IN VARCHAR2,
    p_materia_plan    IN VARCHAR2,
    p_facultad_cursar IN VARCHAR2,
    p_materia_cursar  IN VARCHAR2,
    p_grupo           IN NUMBER,
    p_anio            IN VARCHAR2,
    p_ciclo           IN VARCHAR2,
    o_respuesta OUT NUMBER,
    o_semestre_min OUT NUMBER,
    o_creditos_max OUT NUMBER,
    o_referente OUT VARCHAR2 )
AS
  v_cred_ext        NUMBER;
  v_cupos           NUMBER;
  v_tipo_estudiante VARCHAR2(8);
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    o_respuesta                            := -999;
    RETURN;
  END IF;
  IF b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 THEN
    o_respuesta                                                               := -1;
    RETURN;
  END IF;
  DELETE
  FROM b_prematricula
  WHERE codigo_estudiante = p_codigo
  AND materia_plan        = p_materia_plan
  AND facultad_cursar     = p_facultad_cursar
  AND materia_cursar      = p_materia_cursar
  AND to_number(grupo)    = p_grupo;
  -----------------------------------------------------------------------------
  SELECT est.tipo_de_ingreso
  INTO v_tipo_estudiante
  FROM admisiones.b_estudiantes est
  WHERE est.codigo      =p_codigo;
  IF v_tipo_estudiante <> 'NR' AND v_tipo_estudiante <> 'RA' AND v_tipo_estudiante <> 'ME' AND p_facultad_cursar < '71' THEN
    SELECT cupo - cupo_utilizado
    INTO v_cupos
    FROM admisiones.a_horario_horizontal
    WHERE codigo_facultad        =p_facultad_cursar
    AND codigo_materia           =p_materia_cursar
    AND to_number(grupo_materia) = p_grupo;
    IF v_cupos                   = 1 THEN
      o_respuesta               := 2;
    ELSE
      o_respuesta := 1;
    END IF;
  ELSE
    o_respuesta := 1;
  END IF;
  P_GET_CREDITOS_MAX(p_codigo, p_anio, p_ciclo, 0, o_semestre_min, o_creditos_max, o_referente);
  actualizar_estudiante(p_codigo_estudiante => p_codigo);
  COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  o_respuesta := -2;
  ROLLBACK;
WHEN OTHERS THEN
  dbms_output.put_line(SQLCODE || ' --- ' || SUBSTR(SQLERRM,1,200));
  o_respuesta := -99;
  ROLLBACK;
END P_DESPREMATRICULAR;
PROCEDURE P_GET_CREDITOS_MAX(
    p_codigo   IN VARCHAR2,
    p_anio     IN VARCHAR2,
    p_ciclo    IN VARCHAR2,
    p_cred_sum IN NUMBER,
    o_semestre_min OUT NUMBER,
    o_creditos_max OUT NUMBER,
    o_referente OUT VARCHAR2)
AS
  v_contrario VARCHAR2(16);
  v_cred_c1   NUMBER;
  v_cred_c2   NUMBER;
BEGIN
  v_contrario    := F_GET_CODIGO_CONTRARIO(p_codigo, p_anio, p_ciclo);
  IF v_contrario IS NOT NULL THEN
    SELECT NVL(SUM(m.creditos), 0)
    INTO v_cred_c1
    FROM admisiones.b_estudiantes e
    INNER JOIN admisiones.b_prematricula p
    ON e.codigo = p.codigo_estudiante
    INNER JOIN admisiones.a_materias m
    ON (p.materia_plan        = m.codigo
    AND p.facultad            = m.codigo_facultad
    AND e.jornada_facultad    = m.jornada_facultad)
    WHERE p.codigo_estudiante =p_codigo
    AND p.anio                =p_anio
    AND p.ciclo               =p_ciclo;
    SELECT NVL(SUM(m.creditos), 0)
    INTO v_cred_c2
    FROM admisiones.b_estudiantes e
    INNER JOIN admisiones.b_prematricula p
    ON e.codigo = p.codigo_estudiante
    INNER JOIN admisiones.a_materias m
    ON (p.materia_plan        = m.codigo
    AND p.facultad            = m.codigo_facultad
    AND e.jornada_facultad    = m.jornada_facultad)
    WHERE p.codigo_estudiante =v_contrario
    AND p.anio                =p_anio
    AND p.ciclo               =p_ciclo;
    IF v_cred_c2              > (v_cred_c1 + p_cred_sum) THEN
      o_referente            := v_contrario;
    ELSE
      o_referente := p_codigo;
    END IF;
  END IF;
  SELECT NVL(MIN(to_number(m.semestre)), 0)
  INTO o_semestre_min
  FROM admisiones.b_estudiantes e
  INNER JOIN admisiones.b_prematricula p
  ON e.codigo = p.codigo_estudiante
  INNER JOIN admisiones.a_materias m
  ON (p.materia_plan       = m.codigo
  AND p.facultad           = m.codigo_facultad
  AND e.jornada_facultad   = m.jornada_facultad)
  WHERE p.codigo_estudiante=p_codigo
  AND p.anio               =p_anio
  AND p.ciclo              =p_ciclo;
  IF o_semestre_min        > 0 THEN
    SELECT cs.creditos
    INTO o_creditos_max
    FROM admisiones.b_estudiantes es
    INNER JOIN admisiones.creditosxsemestre cs
    ON (es.codigo_facultad     =cs.codigo_facultad
    AND es.jornada_facultad    =cs.jornada_facultad
    AND es.plan_estudio        =cs.plan_estudio)
    WHERE es.codigo            = p_codigo
    AND to_number(cs.semestre) = o_semestre_min;
  ELSE
    o_creditos_max := 0;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line(SQLCODE || ' --- ' || SUBSTR(SQLERRM,1,200));
END P_GET_CREDITOS_MAX;
PROCEDURE P_PREMATRICULAR_JSON(
    p_codigo      IN VARCHAR2,
    p_perfil      IN VARCHAR2,
    p_materia     IN VARCHAR2,
    p_consecutivo IN NUMERIC,
    p_anio        IN VARCHAR2,
    p_ciclo       IN VARCHAR2,
    o_respuesta OUT NUMERIC)
AS
  v_grupo a_horario_horizontal%ROWTYPE;
  v_grupo_post POSTGRADO.A_HORARIO_HORIZONTAL%ROWTYPE;
  v_creditos        NUMBER:= -1;
  v_facultad        VARCHAR2(4);
  v_jornada         VARCHAR2(4);
  v_plan_estudio    VARCHAR2(2);
  v_tipo_estudiante VARCHAR2(8);
  v_nombre_est      VARCHAR2(50);
  v_semestre        NUMBER;
  v_cred_mat        NUMBER;
  v_cred_ext        NUMBER;
  v_cred_max        NUMBER;
  v_vista           NUMBER;
  v_postgradual     NUMBER;
  v_cruces          NUMBER;
  v_mplan           NUMBER;
  v_NumeroError     NUMBER;
  v_TextoError      VARCHAR2(200);
  --BUG: JDRJ 20150616 11:10
  v_mcursar         number;
  
  v_maxsem number;
  v_veces number;
  
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    o_respuesta                            := -999;
    RETURN;
  END IF;
  IF b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 THEN
    o_respuesta                                                               := -1;
    RETURN;
  END IF;
  SELECT est.codigo_facultad,
    est.jornada_facultad,
    est.plan_estudio,
    (
    CASE
      WHEN LENGTH(est.nombre) > 50
      THEN SUBSTR(est.nombre, 0, 50)
      ELSE est.nombre
    END),
    est.CICLO_DE_INGRESO
    || est.tipo_de_ingreso
  INTO v_facultad,
    v_jornada,
    v_plan_estudio,
    v_nombre_est,
    v_tipo_estudiante
  FROM admisiones.b_estudiantes est
  WHERE est.codigo      =p_codigo;
  IF v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'NR' AND v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'RA' AND v_tipo_estudiante <> p_anio || to_number(p_ciclo) || 'ME' THEN
    begin
      select to_number(m1.semestre)
        into v_semestre
      from
      b_estudiantes e
      inner join a_materias m1 on (m1.codigo_facultad=e.codigo_facultad and m1.jornada_facultad=e.jornada_facultad and m1.plan_estudio=e.plan_estudio)
      where m1.codigo=p_materia and e.codigo=p_codigo;
      --Ojo con los postgraduales
      select
        x.cr + (select m1.creditos from a_materias m1 where m1.codigo=p_materia and m1.codigo_facultad=e.codigo_facultad and m1.jornada_facultad=e.jornada_facultad and m1.plan_estudio=e.plan_estudio),
        cr.creditos + nvl((select pa.tope_creditos from a_prematricula_autorizados pa where pa.codigo_estudiante=e.codigo), 0) as cr_max
      into
        v_creditos,
        v_cred_max
      from
      b_estudiantes e
      inner join creditosxsemestre cr on (cr.codigo_facultad = e.codigo_facultad and cr.jornada_facultad = e.jornada_facultad and cr.plan_estudio = e.plan_estudio)
      inner join (select sum(m.creditos) as cr, min(to_number(m.semestre)) as sm from
      b_estudiantes e
      inner join b_prematricula p on e.codigo = p.codigo_estudiante
      inner join a_materias m on (p.materia_plan = m.codigo and p.facultad = m.codigo_facultad and m.jornada_facultad = e.jornada_facultad and e.plan_estudio = m.plan_estudio)
      where e.codigo=p_codigo and p.indicador_reglamento is null) x on (case when v_semestre < x.sm then v_semestre else x.sm end) = to_number(cr.semestre)
      where e.codigo=p_codigo;
      if v_creditos > v_cred_max then
        o_respuesta             := -3;
        RETURN;
      end if;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('sin prematricula');
    END;
    --BUG: caso 41111110: materia inscrita desde diferentes lugares, no los atrapa la sesion.
    select count(*) into v_mcursar from b_prematricula p1 where
    p1.materia_cursar in (
    select h1.codigo_materia from a_horario_horizontal h1 where h1.consecutivo = p_consecutivo
    union
    select h2.codigo_materia from postgrado.a_horario_horizontal h2 where h2.consecutivo = p_consecutivo
    ) and
    p1.anio= p_anio and p1.ciclo= p_ciclo and p1.codigo_estudiante= p_codigo
    and p1.indicador_reglamento is null;
    IF v_mcursar >= 1 THEN
      DBMS_OUTPUT.PUT_LINE('Ya prematricula: ' || v_mcursar);
      o_respuesta := -5;
      RETURN;
    END IF;
    --FIN BUG
    SELECT COUNT(*)
    INTO v_vista
    FROM b_prematricula_historico h
    WHERE h.codigo_estudiante=p_codigo
    AND h.materia_cursar    IN
      (SELECT ah.codigo_materia
      FROM a_horario_horizontal ah
      WHERE ah.consecutivo=p_consecutivo
      )
    AND h.indicador_pago      IN ('P', 'V')
    AND h.definitiva_depurada >= 3;
    IF v_vista                >= 1 THEN
      o_respuesta             := -5;
      RETURN;
    END IF;
  END IF;
  BEGIN
    SELECT *
    INTO v_grupo
    FROM admisiones.a_horario_horizontal hh
    WHERE hh.consecutivo = p_consecutivo
    AND hh.abierto       ='S'
    AND hh.anio          =p_anio
    AND hh.ciclo         =p_ciclo;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_postgradual := 1;
  END;
  IF v_postgradual > 0 THEN
    SELECT *
    INTO v_grupo_post
    FROM POSTGRADO.A_HORARIO_HORIZONTAL hh
    WHERE hh.consecutivo = p_consecutivo
    AND hh.abierto       ='S'
    AND hh.anio          =p_anio
    AND hh.ciclo         =p_ciclo;
  END IF;
  IF v_grupo.consecutivo IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_cruces
    FROM
      (SELECT COUNT(consecutivo) AS y
      FROM
        (SELECT hv.consecutivo,
          hv.dia
          || hv.hora AS x
        FROM a_horario_vertical hv
        INNER JOIN b_prematricula p
        ON hv.consecutivo         = p.id_curso
        WHERE p.codigo_estudiante = p_codigo
        AND hv.ANIO               =p_anio
        AND hv.CICLO              =p_ciclo
        and p.indicador_reglamento is null
        --No tener en cuenta los cancelados?
        and p.indicador_pago not in ('C','K')
        UNION
        SELECT hv.consecutivo,
          hv.dia
          || hv.hora AS x
        FROM a_horario_vertical hv
        WHERE hv.consecutivo=v_grupo.consecutivo
        AND hv.ANIO         =p_anio
        AND hv.CICLO        =p_ciclo
        ) y
      GROUP BY x
      HAVING COUNT(consecutivo) > 1
      ) z;
    DBMS_OUTPUT.PUT_LINE('cruces: ' || v_cruces);
    IF v_cruces    > 0 THEN
      o_respuesta := -6;
      RETURN;
    END IF;
    SELECT COUNT(*)
    INTO v_mplan
    FROM b_prematricula
    WHERE materia_plan   =p_materia
    AND codigo_estudiante=p_codigo
    AND anio             =p_anio
    AND ciclo            =p_ciclo;
    --and indicador_reglamento is null;
    DBMS_OUTPUT.PUT_LINE('mplan prematriculada: ' || v_mplan);
    IF v_mplan           > 0 THEN
      o_respuesta       := -7;
      RETURN;
    END IF;

    /*begin
        select (select max(to_number(cxs.semestre)) from creditosxsemestre cxs where cxs.codigo_facultad=e2.codigo_facultad and cxs.jornada_facultad=e2.jornada_facultad and cxs.plan_estudio=e2.plan_estudio) as sem
        ,(select count(*) as n from b_prematricula p inner join a_materias m on p.facultad = m.codigo_facultad and p.materia_plan = m.codigo
            where m.nombre like 'CULTURA RELIGIOSA%'
            and p.codigo_estudiante = e2.codigo
            and m.plan_estudio = e2.plan_estudio
            and m.jornada_facultad = e2.jornada_facultad
            and m.codigo not in ('FL411')) as veces
        into v_maxsem, v_veces
        from b_estudiantes e2
        inner join a_materias m2
        on(m2.codigo_facultad   = e2.codigo_facultad
        and m2.jornada_facultad = e2.jornada_facultad
        and m2.plan_estudio     = e2.plan_estudio)
        where e2.codigo         = p_codigo
        and m2.nombre like 'CULTURA RELIGIOSA%'
        and m2.codigo in (p_materia)
        and (select hh.codigo_materia from a_horario_horizontal hh where hh.consecutivo = p_consecutivo) not in ('FL411')
        and not exists (select 1 from b_prematricula_historico bph where bph.codigo_estudiante=e2.codigo and bph.materia_cursar = 'FL411' and bph.total_fallas <= 8 and bph.definitiva_depurada >= 3)
        and not exists (select 1 from b_prematricula pp where pp.codigo_estudiante = e2.codigo and pp.materia_cursar in ('FL411'))
        and (select count(*) as n from a_materias_pendientes p inner join a_materias m on p.codigo_facultad = m.codigo_facultad and p.jornada_facultad = m.jornada_facultad and p.codigo_materia = m.codigo and p.plan_estudio = m.plan_estudio
            where m.nombre like 'CULTURA RELIGIOSA%'
            and p.codigo_estudiante = e2.codigo) >= 2;
        if (v_maxsem < 10 and v_veces >= 1) or (v_maxsem >= 10 and v_veces >= 2) then
            --debe ver la materia FL411
            o_respuesta := -9;
            return;
        end if;
    exception
    when no_data_found then
        null;
    end;*/

    INSERT
    INTO B_PREMATRICULA
      (
        codigo_estudiante,
        facultad,
        materia_plan,
        facultad_cursar,
        materia_cursar,
        grupo,
        jornada_facultad,
        fecha,
        flag_procesado,
        anio,
        ciclo,
        codmil,
        nombre,
        id_curso
      )
    SELECT p_codigo,
      v_facultad,
      p_materia,
      v_grupo.codigo_facultad,
      v_grupo.codigo_materia,
      to_number(v_grupo.grupo_materia),
      v_grupo.jornada_facultad,
      SYSDATE,
      NULL,
      p_anio,
      p_ciclo,
      be.codmil,
      v_nombre_est,
      p_consecutivo
    FROM admisiones.b_estudiantes be
    WHERE be.codigo=p_codigo
    AND EXISTS
      (SELECT 1
      FROM admisiones.a_horario_horizontal hh
      WHERE hh.cupo_utilizado + 1 <= hh.cupo
      AND hh.consecutivo           =p_consecutivo
      AND hh.anio                  =p_anio
      AND hh.ciclo                 =p_ciclo
      );
    DBMS_OUTPUT.PUT_LINE('prematricula pre');
  elsif v_grupo_post.consecutivo IS NOT NULL THEN
    INSERT
    INTO B_PREMATRICULA
      (
        codigo_estudiante,
        facultad,
        materia_plan,
        facultad_cursar,
        materia_cursar,
        grupo,
        jornada_facultad,
        fecha,
        flag_procesado,
        anio,
        ciclo,
        codmil,
        nombre,
        id_curso
      )
    SELECT p_codigo,
      v_facultad,
      p_materia,
      v_grupo_post.codigo_facultad,
      v_grupo_post.codigo_materia,
      to_number(v_grupo_post.grupo_materia),
      v_grupo_post.jornada_facultad,
      SYSDATE,
      NULL,
      p_anio,
      p_ciclo,
      be.codmil,
      v_nombre_est,
      p_consecutivo
    FROM admisiones.b_estudiantes be
    WHERE be.codigo=p_codigo
    AND EXISTS
      (SELECT 1
      FROM postgrado.a_horario_horizontal hh
      WHERE hh.consecutivo =p_consecutivo
      AND hh.anio          =p_anio
      AND hh.ciclo         =p_ciclo
      );
  ELSE
    o_respuesta := -8;
    ROLLBACK;
    RETURN;
  END IF;
  IF sql%rowcount != 1 THEN
    o_respuesta   := -4;
    ROLLBACK;
    RETURN;
  END IF;
  o_respuesta := 1;
  COMMIT;
  actualizar_estudiante(p_codigo_estudiante => p_codigo);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  o_respuesta := -2;
  ROLLBACK;
WHEN OTHERS THEN
  o_respuesta := -99;
  ROLLBACK;
  v_NumeroError := SQLCODE;
  v_TextoError  := SUBSTR(SQLERRM,1,200);
  DBMS_OUTPUT.PUT_LINE(v_NumeroError || ' : ' || v_TextoError);
  INSERT
  INTO b_log
    (
      codigo,
      mensaje,
      informacion
    )
    VALUES
    (
      v_NumeroError,
      v_TextoError,
      '[FAIL] Prematricular ('
      || p_codigo
      || ', '
      || p_consecutivo
      || ') >> '
      || TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS')
    );
  COMMIT;
END P_PREMATRICULAR_JSON;
PROCEDURE P_DESPREMATRICULAR_JSON
  (
    p_codigo      IN VARCHAR2,
    p_perfil      IN VARCHAR2,
    p_consecutivo IN NUMERIC,
    p_anio        IN VARCHAR2,
    p_ciclo       IN VARCHAR2,
    o_respuesta OUT NUMBER
  )
AS
  v_NumeroError NUMBER;
  v_TextoError  VARCHAR2(200);
BEGIN
  IF F_PREMATRICULA_ACTIVA(p_anio, p_ciclo) < 1 THEN
    o_respuesta                            := -999;
    RETURN;
  END IF;
  IF b_prematricula_spring.f_tiene_turno(p_codigo, p_perfil, p_anio, p_ciclo) <= 0 THEN
    o_respuesta                                                               := -1;
    RETURN;
  END IF;
  DELETE
  FROM b_prematricula
  WHERE codigo_estudiante = p_codigo
  AND id_curso            = p_consecutivo
  AND anio                = p_anio
  AND ciclo               = p_ciclo
		and indicador_pago not in ('K','C');
		if sql%rowcount <> 1 then
			o_respuesta := -2;
			rollback;
		else
			o_respuesta := 1;
			COMMIT;
			actualizar_estudiante(p_codigo_estudiante => p_codigo);
		end if;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  o_respuesta := -2;
  ROLLBACK;
WHEN OTHERS THEN
  o_respuesta := -99;
  ROLLBACK;
  v_NumeroError := SQLCODE;
  v_TextoError  := SUBSTR(SQLERRM,1,200);
  INSERT
  INTO b_log
    (
      codigo,
      mensaje,
      informacion
    )
    VALUES
    (
      v_NumeroError,
      v_TextoError,
      '[FAIL] Desprematricular ('
      || p_codigo
      || ', '
      || p_consecutivo
      || ') >> '
      || TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS')
    );
  COMMIT;
END P_DESPREMATRICULAR_JSON;
END B_PREMATRICULA_SPRING;