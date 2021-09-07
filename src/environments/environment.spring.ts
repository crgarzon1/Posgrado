export const environment = {
  production: false,

  /** Desplegado desde Spring Boot Tools de Alejandro */
  urlLoginUsuario: 'http://estctiedarevalo.lasalle.edu.co:8080/login',
  urlPasarela: 'http://estctiedarevalo.lasalle.edu.co:8080/api/get',
  urlPerfiles: 'http://estctiedarevalo.lasalle.edu.co:8080/api/perfiles',
  urlLiquidar: 'http://estctiedarevalo.lasalle.edu.co:8080/api/liquidar',
  urlGuiaAdicionales: 'http://estctiedarevalo.lasalle.edu.co:8090/api/guia/adicionales',
  urlAdmisiones: 'http://registro.lasalle.edu.co/pls/regadm/',
  urlPostgrado: 'http://registro.lasalle.edu.co/pls/postgrado/'

  // urlAdmisiones: 'http://pruebasia.lasalle.edu.co/pls/admisionespreprod/',
  // urlPostgrado: 'http://pruebasia.lasalle.edu.co/pls/postgradopreprod/'

  // urlAdmisiones: 'http://tigris.lasalle.edu.co:9090/pls/regadm/',
  // urlPostgrado: 'http://tigris.lasalle.edu.co:9090/pls/postgrado/'
};

// NOTA:	En caso de que no sea Alejandro y quiera desplegar ya sea en Spring tools o Tomcat
// reemplazar el `estctiedarevalo.lasalle.edu.co` por `localhost` o su dominio
