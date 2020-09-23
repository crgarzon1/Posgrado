create or replace trigger trg_actu_gradsieg
  after update on A_GRADUADOS
  for each row
declare
v_documento sieg_celular_temp.documento%type default null;
x           number                           default 0;
y           number                           default 0;
z           number                           default 0;
v_existe    number                           default 0;

cursor celular is
select * from sieg_celular_temp t
where  t.documento=v_documento;

cursor estudios is
select * from sieg_estudio_superior_temp t
where  t.documento=v_documento;

cursor datos_personales_temp is
select * from sieg_datos_basicos_temp t
where  t.documento=v_documento;

c_estudiante datos_personales_temp%rowtype;

begin
IF updating then
   if :NEW.NUMERO_ACTA>0 THEN
       v_documento:=:new.numero_documento;
       select count(*)
       into   v_existe
       from   sieg_datos_basicos_temp t
       where  t.documento = :new.numero_documento and
       t.documento NOT IN (SELECT sdb.documento from sieg.sieg_datos_basicos@uvirtual.lasalle.edu.co sdb WHERE sdb.documento = :new.numero_documento);
       if v_existe>0 then
          --actualizamos sieg datos basicos
          INSERT INTO sieg.sieg_datos_basicos@uvirtual.lasalle.edu.co
          select t.* from sieg_datos_basicos_temp t
          where  t.documento = :new.numero_documento; 
          --actualizamos sieg datos celular
          for v_datos in celular loop
          select sieg.seq_num_celular.nextval@uvirtual.lasalle.edu.co into x from dual;
          INSERT INTO sieg.sieg_celular@uvirtual.lasalle.edu.co
          values(
          x,
          v_datos.documento,
          v_datos.ind_pais,
          v_datos.ind_ciudad,
          v_datos.numero
          );
          end loop;
          --actualizamos sieg datos estudios
          for v_datos in estudios loop
             select sieg.seq_estudio_superior.nextval@uvirtual.lasalle.edu.co  into y from dual;
             INSERT into sieg.sieg_estudio_superior@uvirtual.lasalle.edu.co
             values(
             y,
             v_datos.documento,
             v_datos.nombre,
             v_datos.institucion,
             v_datos.anio_grado,
             v_datos.id_tipoestudio
             );
          end loop;
          --actualizamos sieg datos fecha
          select sieg.seq_fecha_actualizacion.nextval@uvirtual.lasalle.edu.co  into z from dual;
          insert into sieg.sieg_fecha_actualizacion@uvirtual.lasalle.edu.co
          values(
          z,
          v_documento,
          sysdate
          );
       end if;
       
      OPEN  datos_personales_temp;
      FETCH datos_personales_temp INTO c_estudiante;
      update sieg.sieg_datos_basicos@uvirtual.lasalle.edu.co
      set    EMAIL = c_estudiante.email
            ,COD_PAIS_RESIDENCIA = c_estudiante.COD_PAIS_RESIDENCIA
            ,DIR_RESIDENCIA = c_estudiante.DIR_RESIDENCIA
            ,ESTRATO = c_estudiante.ESTRATO
            ,TEL_RESIDENCIA_INDP = c_estudiante.TEL_RESIDENCIA_INDP
            ,TEL_CONTACTO_INDP = c_estudiante.TEL_CONTACTO_INDP
            ,TEL_TRABAJO_INDP = c_estudiante.TEL_TRABAJO_INDP
            ,TRABAJA = c_estudiante.TRABAJA
            ,LUGAR_TRABAJO = c_estudiante.LUGAR_TRABAJO
            ,ID_AREA_DESEMPENIO = c_estudiante.ID_AREA_DESEMPENIO
            ,ID_TIPO_TRABAJO = c_estudiante.ID_TIPO_TRABAJO
            ,ID_TIPO_SECTOR = c_estudiante.ID_TIPO_SECTOR
            ,INGRESO = c_estudiante.INGRESO
            ,ACEPTA_USUARIO_CORREO = c_estudiante.ACEPTA_USUARIO_CORREO
            ,ACEPTA_RECIBIR_INFO = c_estudiante.ACEPTA_RECIBIR_INFO
            ,EMAL_UNISALLE = c_estudiante.EMAL_UNISALLE
            ,TEL_RESIDENCIA_INDC = c_estudiante.TEL_RESIDENCIA_INDC
            ,TEL_RESIDENCIA_NUM = c_estudiante.TEL_RESIDENCIA_NUM
            ,TEL_CONTACTO_INDC = c_estudiante.TEL_CONTACTO_INDC
            ,TEL_CONTACTO_NUM = c_estudiante.TEL_CONTACTO_NUM
            ,TEL_TRABAJO_INDC = c_estudiante.TEL_TRABAJO_INDC
            ,TEL_TRABAJO_NUM = c_estudiante.TEL_TRABAJO_NUM
            ,COD_CIUDAD_RESIDENCIA = c_estudiante.COD_CIUDAD_RESIDENCIA
            ,CARGO = c_estudiante.CARGO
            ,TEL_TRABAJO_EXT = c_estudiante.TEL_TRABAJO_EXT
            ,EMPRESA_TRABAJO = c_estudiante.EMPRESA_TRABAJO
            ,ACEPTA_ENVIO_MENSAJE = c_estudiante.ACEPTA_ENVIO_MENSAJE
            ,ACEPTA_ENVIO_WHATSAPP = c_estudiante.ACEPTA_ENVIO_WHATSAPP
      where documento = v_documento;
      CLOSE datos_personales_temp ;
      
      delete from sieg.sieg_celular@uvirtual.lasalle.edu.co
      where documento = v_documento;
      
      --actualizamos sieg datos celular
      for v_datos in celular loop
        select sieg.seq_num_celular.nextval@uvirtual.lasalle.edu.co into x from dual;
        INSERT INTO sieg.sieg_celular@uvirtual.lasalle.edu.co
        values(
        x,
        v_datos.documento,
        v_datos.ind_pais,
        v_datos.ind_ciudad,
        v_datos.numero
      );
      end loop;
      
      delete from sieg.sieg_estudio_superior@uvirtual.lasalle.edu.co
      where documento = v_documento;
      
      --actualizamos sieg datos estudios
      for v_datos in estudios loop
         select sieg.seq_estudio_superior.nextval@uvirtual.lasalle.edu.co  into y from dual;
         INSERT into sieg.sieg_estudio_superior@uvirtual.lasalle.edu.co
         values(
         y,
         v_datos.documento,
         v_datos.nombre,
         v_datos.institucion,
         v_datos.anio_grado,
         v_datos.id_tipoestudio
         );
      end loop;
      
      --actualizamos sieg datos fecha
      select sieg.seq_fecha_actualizacion.nextval@uvirtual.lasalle.edu.co  into z from dual;
      insert into sieg.sieg_fecha_actualizacion@uvirtual.lasalle.edu.co
      values(
      z,
      v_documento,
      sysdate
      );          
   end if;
END IF;
END;