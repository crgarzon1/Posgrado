// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: false,

  /** Desplegado en servidor de preproduccion */
  // urlLoginUsuario: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/login',
  // urlPasarela: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/get',
  // urlPerfiles: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/perfiles',
  // urlLiquidar: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/liquidar',
  // urlGuiaAdicionales: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/guia/adicionales',

  // urlAdmisiones: 'http://172.19.0.101:8080/pls/regadm/',
  // urlPostgrado: 'http://172.19.0.101:8080/pls/postgrado/'

  // urlAdmisiones: 'http://pruebasia.lasalle.edu.co/pls/admisionespreprod/',
  // urlPostgrado: 'http://pruebasia.lasalle.edu.co/pls/postgradopreprod/',

  /** Desplegado desde Spring Boot Tools de Alejandro */
  // urlLoginUsuario: 'http://estctiedarevalo.lasalle.edu.co:8080/login',
  // urlPasarela: 'http://estctiedarevalo.lasalle.edu.co:8080/api/get',
  // urlPerfiles: 'http://estctiedarevalo.lasalle.edu.co:8080/api/perfiles',
  // urlLiquidar: 'http://estctiedarevalo.lasalle.edu.co:8080/api/liquidar',
  // urlGuiaAdicionales: 'http://estctiedarevalo.lasalle.edu.co:8080/api/guia/adicionales',
  // urlAdmisiones: 'http://registro.lasalle.edu.co/pls/regadm/',
  // urlPostgrado: 'http://registro.lasalle.edu.co/pls/postgrado/'

  /** Desplegado desde Tomcat de Alejandro con el War */
  // ---- URL pasarela
  // urlLoginUsuario: 'https://rest.lasalle.edu.co/postgrado-backend/login',
  // urlPasarela: 'https://rest.lasalle.edu.co/postgrado-backend/api/get',
  // urlPerfiles: 'https://rest.lasalle.edu.co/postgrado-backend/api/perfiles',
  // urlLiquidar: 'https://rest.lasalle.edu.co/postgrado-backend/api/liquidar',
  // urlGuiaAdicionales: 'https://rest.lasalle.edu.co/postgrado-backend/api/guia/adicionales',

  // urlAdmisiones: 'http://registro.lasalle.edu.co/pls/regadm/',
  // urlPostgrado: 'http://registro.lasalle.edu.co/pls/postgrado/'

  //apuntando a ords
  // urlLoginUsuario: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/login',
  // urlPasarela: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/get',
  // urlPerfiles: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/perfiles',
  // urlLiquidar: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/liquidar',
  // urlGuiaAdicionales: 'http://rest-pruebas.lasalle.edu.co:8080/postgrado-backend/api/guia/adicionales',

  // urlAdmisiones: 'http://tigris.lasalle.edu.co:9090/pls/regadm/',
  // urlPostgrado: 'http://tigris.lasalle.edu.co:9090/pls/postgrado/'

  // NOTA:	En caso de que no sea Alejandro y quiera desplegar ya sea en Spring tools o Tomcat
  // reemplazar el `estctiedarevalo.lasalle.edu.co` por `localhost` o su dominio

  //produccion
  urlLoginUsuario: 'https://rest.lasalle.edu.co/postgrado-backend/login',
  urlPasarela: 'https://rest.lasalle.edu.co/postgrado-backend/api/get',
  urlPerfiles: 'https://rest.lasalle.edu.co/postgrado-backend/api/perfiles',
  urlLiquidar: 'https://rest.lasalle.edu.co/postgrado-backend/api/liquidar',
  urlGuiaAdicionales: 'https://rest.lasalle.edu.co/postgrado-backend/api/guia/adicionales',

  urlAdmisiones: 'http://registro.lasalle.edu.co/pls/regadm/',
  urlPostgrado: 'http://registro.lasalle.edu.co/pls/postgrado/'
};
