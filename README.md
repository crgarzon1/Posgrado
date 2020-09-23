# Posgrado

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 8.0.3.

## Development server

Es necesario tener configurado el archivo de hosts con alguna de las url disponibles en el proyecto backend para que no tenga problemas con los CORS, para configurar las url en el proyecto backend en:
`..\postgrado-backend\src\main\java\co\edu\lasalle\postgrado\utils\security\SecurityConfig.java` en el método `CorsConfigurationSource`.

> Para modificar alguna de las url de los ambientes en este proyecto Angular, se puede hacer desde los archivos `environment.ts` para ambiente preproducción, `environment.prod.ts`, para ambiente de producción y `environmente.spring.ts` para ambiente local utilizando Spring Boot.

#### Local deploy

> Esto se puede luego ver en `http://localhost:4200/` o en el host establecido para funcionar como local

- ##### Utilizando backend apuntando a preproducción (172.19.5.102)
  `ng serve --disable-host-check`
- ##### Utilizando Backend apuntando a producción
  `ng serve --prod --disable-host-check`
- ##### Utilizando Backend apuntando a Spring Boot Local
  `ng serve -c=spring --disable-host-check`

#### Server deploy

> Esto se puede subir luego a la carpeta de despliegue del servidor. El proyecto construido se almacenará en la carpeta `dist/postgrado/`

- ##### Utilizando backend apuntando a preproducción (172.19.5.102)
  `ng build --base-href /oar/sia/postgrado/`
- ##### Utilizando Backend apuntando a producción
  `ng build --prod --base-href /oar/sia/postgrado/`
- ##### Utilizando Backend apuntando a Spring Boot Local
  `ng build -c=spring --base-href /oar/sia/postgrado/`

### Running unit tests

###### Para correr Mock Server con respuestas de prueba:

- Instalar: `npm install -g json-server`
- Correr: `json-server --watch test/mock.json`

Para correr los test unitarios con [Karma](https://karma-runner.github.io): `ng test`

## PLUGINS

- Para instalar los label de chartjs: `npm install chartjs-plugin-labels`

  **Para solucionar el siguiente error:**
  ERROR in node_modules/chartjs-plugin-datalabels/types/index.d.ts(5,16): error TS2665: Invalid module name in augmentation. Module `chart.js` resolves to an untyped module at `D:/Posgrado/node_modules/chart.js/dist/Chart.js`, which cannot be augmented.

  **Solucion:**
  Modificar en `node_modules/chartjs-plugin-datalabels/types/index.d.ts(5,16)` cambiar `chart.js` por `nodemodules/chart.js`

- Para instalar el plugin del box plot (panel 'Notas parciales'): `npm install --save chart.js chartjs-chart-box-and-violin-plot`

- Para instalar el servicio de manejo de Cookies: `npm install ngx-cookie-service --save` (esto sólo es una vez) lo ponemos acá por si se necesita para otro proyecto o actualización.
