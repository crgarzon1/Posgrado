create or replace PACKAGE PKG_ESTUDIANTE AS 

    PROCEDURE CREAR_ESTUDIANTE_POSTGRADO
(
        P_CODIGO_ESTUDIANTE VARCHAR2 DEFAULT NULL
    );

    FUNCTION GET_ULTIMO_PLAN_ESTUDIOS
(
        V_CODIGO_FACULTAD    B_ESTUDIANTES.CODIGO_FACULTAD%TYPE,
        V_JORNADA_FACULTAD   B_ESTUDIANTES.JORNADA_FACULTAD%TYPE
    )
RETURN VARCHAR2;

procedure crear_usuario
(
        p_codigo admisiones.a_usuarios.codigo%type
    );

    procedure add_est_bolsa_electiva
(
        p_codigo admisiones.a_usuarios.codigo%type
    );
    
    procedure del_est_bolsa_electiva
(
        p_codigo admisiones.a_usuarios.codigo%type
    );
    
     FUNCTION es_transferencia_reintegro
(
        p_codigo_estudiante b_estudiantes.codigo%TYPE
    )
RETURN NUMBER;

END PKG_ESTUDIANTE;