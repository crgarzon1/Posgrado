import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Generalidades } from '../Model/dashboard/generalidades';
import { HistorialAcademico } from '../Model/dashboard/historial-academico';
import { ProcesoAcademico } from '../Model/dashboard/proceso-academico';
import { PrematriculaEstudiante } from '../Model/dashboard/prematricula-estudiante';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Estudiante } from '../Model/dashboard/estudiante';
import { Pendientes } from '../Model/dashboard/pendientes';
import { MatriculaOferta } from '../Model/prematricula/matricula-oferta';
import { MatriculaEstudiante } from '../Model/prematricula/matricula-estudiante';
import { Respuesta } from '../Model/prematricula/respuesta';
import { EstadisticaNotas } from '../Model/dashboard-ua/estadistica-notas';
import { Indicadores } from '../Model/dashboard-ua/indicadores';
import { EstudianteTipoIngreso } from '../Model/dashboard-ua/estudiante-tipo-ingreso';
import { EstadoNotas } from '../Model/dashboard-ua/estado-notas';
import { EstudianteBusqueda } from '../Model/menu/estudiante-busqueda';
import { MenuUsuario } from '../Model/menu/menu-usuario';
import { PerfilUsuario } from '../Model/menu/perfil-usuario';
import { CookieService } from 'ngx-cookie-service';
import { BarChart } from 'src/app/Model/dashboard-ua/bar-chart';
import { WebServiceResponse } from '../Model/creditos-adicionales/web-service-response';
import { BolsaCreditosElectivos } from '../Model/prematricula/bolsa-creditos-electivos';
import { FacultadesIntegrados } from '../Model/integrados/facultades-integrados';
import { MateriasIntegrados } from '../Model/integrados/materias-integrados';
import { InformacionUsuario } from '../Model/dashboard-ua/informacion-usuario';
import { GuiaPago } from '../Model/menu/guia-pago';

@Injectable({
  providedIn: 'root'
})
export class GeneralService {
  public codigoEstudiante: string = undefined;
  private jornadaFacultad = 'N';
  private menuUsuario: MenuUsuario[];
  private perfilesUsuario: PerfilUsuario[];
  private infoUsuario: InformacionUsuario = new InformacionUsuario();

  constructor(private http: HttpClient, private cookie: CookieService) {}

  pasarela(obj: any): Observable<any> {
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);

    const param = new HttpParams().set('peticion', JSON.stringify(obj));

    return this.http.get<any>(environment.urlPasarela, { headers: header, params: param, withCredentials: true });
  }

  actualizoDatos(): Observable<any> {
    const obj = {
      e: '2',
      p: 'PKG_CTI_ACTUALIZO_DATOS.ACTUALIZO_DATOS',
      ps: { COD_EST: `${this.codigoEstudiante}` },
      c: '0'
    };
    return this.pasarela(obj);
  }

  censo(): Observable<any> {
    const obj = {
      e: '2',
      p: 'PKG_CTI_CENSO.CENSO',
      // p: 'PRC_ES_PAGO_POS',
      ps: { COD_EST: `${this.codigoEstudiante}` },
      c: '0'
    };
    return this.pasarela(obj);
  }

  // censo(): Observable<any> {
  //   const obj = {
  //     e: '1',
  //     p: 'PRC_ES_PAGO_POS',
  //     ps: { p_codigo: `${this.codigoEstudiante}` },
  //     c: '0'
  //   };
  //   return this.pasarela(obj);
  // }

  getGeneralidadesEstudiante(): Observable<Generalidades> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.GET_GENERALIDADES',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getHistorialAcademico(): Observable<HistorialAcademico> {
    const obj = {
      e: '1',
      p: 'SGCERTIFICADOS.SP_CE_ACADEMICO_POSGRADO.PR_HISTORIA_ACAD_JSON',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getPlanDeEstudios(): Observable<ProcesoAcademico> {
    const obj = {
      e: '1',
      p: 'SGCERTIFICADOS.SP_CE_ACADEMICO_POSGRADO.PR_PLAN_DE_ESTUDIO',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getTerminacionPlan(): Observable<any> {
    const obj = {
      e: '1',
      p: 'SGCERTIFICADOS.SP_CE_ACADEMICO.PR_TERMINACION_PLAN_JSON',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getPrematricula(): Observable<PrematriculaEstudiante> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.GET_PREMATRICULA_ESTUDIANTE',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstudiante(): Observable<Estudiante> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.ESTUDIANTE',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getPendientes(): Observable<Pendientes> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.GET_PENDIENTES',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getOfertaMatricula(): Observable<MatriculaOferta[]> {
    const obj = {
      e: '2',
      p: 'PKG_MATRICULA.GETOFERTA',
      ps: { P_CODIGO: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getBolsaCreditosElectivos(): Observable<BolsaCreditosElectivos[]> {
    const obj = {
      e: '2',
      p: 'PKG_BOLSAS_ELECTIVAS.GET_BOLSAS',
      ps: { P_CODIGO_ESTUDIANTE: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getMatricula(): Observable<MatriculaOferta[]> {
    const obj = {
      e: '2',
      p: 'PKG_MATRICULA.GETMATRICULA',
      ps: { P_CODIGO: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstudianteMatricula(): Observable<MatriculaEstudiante> {
    const obj = {
      e: '2',
      p: 'PKG_MATRICULA.GETESTUDIANTE',
      ps: { P_CODIGO: this.codigoEstudiante },
      c: '0'
    };
    return this.pasarela(obj);
  }

  inscribirMateria(p_arg: any): Observable<Respuesta> {
    const obj = {
      e: '2',
      p: 'PKG_MATRICULA.INSCRIBIR',
      ps: { P_ARG: encodeURI(JSON.stringify(p_arg)) },
      c: '0',
      u: '1'
    };
    return this.pasarela(obj);
  }

  desinscribirMateria(p_arg: any): Observable<Respuesta> {
    const obj = {
      e: '2',
      p: 'PKG_MATRICULA.DESINSCRIBIR',
      ps: { P_ARG: encodeURI(JSON.stringify(p_arg)) },
      c: '0',
      u: '1'
    };
    return this.pasarela(obj);
  }

  getIndicadores(): Observable<Indicadores> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.get_indicadores',
      ps: { p_codigo_facultad: this.getCodigoFactultad(), p_jornada_facultad: this.jornadaFacultad },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstTipoIngreso(): Observable<BarChart[]> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.get_estudiantes_tipo_ing',
      ps: { p_codigo_facultad: this.getCodigoFactultad(), p_jornada_facultad: this.jornadaFacultad },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getDetallesEstTipoIngreso(): Observable<EstudianteTipoIngreso[]> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.get_detalles_est_tipo_ing',
      ps: { p_codigo_facultad: this.getCodigoFactultad(), p_jornada_facultad: this.jornadaFacultad },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstadoNotas(): Observable<EstadoNotas> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.get_estado_notas',
      ps: { p_codigo_facultad: this.getCodigoFactultad() },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstadisticasNotas(): Observable<EstadisticaNotas[]> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.get_estadisticas_notas',
      ps: { p_codigo_facultad: this.getCodigoFactultad(), p_jornada_facultad: this.jornadaFacultad },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getEstudianteBusqueda(criterio: string, valor: string): Observable<EstudianteBusqueda[]> {
    const obj = {
      e: '2',
      p: 'pkg_cti_dashboard_posgrados.buscar_estudiante',
      ps: {
        p_criterio_busqueda: criterio,
        p_valor: valor,
        p_codigo_facultad: this.getCodigoFactultad(),
        p_jornada_facultad: this.jornadaFacultad
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  loginUsuario(usuario: string, contrasena: string): Observable<Respuesta> {
    const obj = { usuario, contrasenia: contrasena };
    const body = JSON.stringify(obj);
    return this.http.post<Respuesta>(environment.urlLoginUsuario, body);
  }

  getPerfilUsuario(): Observable<PerfilUsuario[]> {
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);

    return this.http.get<any>(environment.urlPerfiles, { headers: header, withCredentials: true });
  }

  getMenuUsuarioService(): Observable<MenuUsuario[]> {
    const token = this.cookie.get('wUFAnew4');
    const obj = {
      e: '2',
      p: 'PKG_UTILS.GETMENU',
      ps: { TOKEN: token },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getCodigoEstudiante(): Observable<Respuesta> {
    const token = this.cookie.get('wUFAnew4');
    const obj = {
      e: '2',
      p: 'PKG_UTILS.GET_CODIGO_ESTUDIANTE',
      ps: { TOKEN: token },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getInformacionUsuario(): Observable<InformacionUsuario> {
    const obj = {
      e: '2',
      p: 'PKG_UTILS.GET_PORTAL_INFO',
      ps: {},
      c: '0'
    };
    return this.pasarela(obj);
  }

  getUrlFrame(option: string): Observable<any> {
    // Este no implementa el método de pasarela porque necesita enviar la tookie en la petición, y el llamado http cambia
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);

    const obj = { e: '2', p: 'PKG_MENU.CALL_FACADE', ps: { P_OPTION_ID: option }, c: '0' };
    const param = new HttpParams().set('peticion', JSON.stringify(obj));
    return this.http.get<any>(environment.urlPasarela, { headers: header, params: param, withCredentials: true });
  }

  getPeriodosGuiaPago(codigo: string): Observable<GuiaPago> {
    const obj = {
      e: '2',
      p: 'PKG_LIQUIDACION.LISTADOPERIODOS',
      ps: { P_CODIGO: codigo },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getGuiaPago(codigo: string, periodo: number): Observable<any> {
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);
    let url = '';
    if (codigo === '') {
      url = environment.urlLiquidar + '/' + periodo;
    } else {
      url = environment.urlLiquidar + '/' + codigo + '/' + periodo;
    }
    return this.http.get<any>(url, { headers: header, withCredentials: true });
  }

  getGuiaAdicionales(): Observable<any> {
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);
    return this.http.get<any>(environment.urlGuiaAdicionales, { headers: header, withCredentials: true });
  }

  getGuiaPagoCreditosAdicionales(codigo: string, creditosAdicionales: number): Observable<any> {
    const tokenAuth = sessionStorage.getItem('tnkptcn');
    let header = new HttpHeaders();
    header = header.append('Authorization', 'Bearer ' + tokenAuth);
    const url = environment.urlLiquidar + '/' + codigo + '/0';
    const param = new HttpParams().set('adicionales', creditosAdicionales.toString());
    return this.http.get<any>(url, { headers: header, params: param, withCredentials: true });
  }

  getPlanes(codigo: string): Observable<any> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.GET_PLANES',
      ps: { P_CODIGO_ESTUDIANTE: codigo },
      c: '0'
    };
    return this.pasarela(obj);
  }

  actualizarPlan(codigo: string, nuevoPlan: string): Observable<any> {
    const obj = {
      e: '1',
      p: 'PKG_EXPOSED_SERVICES_FACADE.ACTUALIZAR_PLAN_POSTGRADO',
      ps: { P_CODIGO_ESTUDIANTE: codigo, P_PLAN_ESTUDIO: nuevoPlan },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getCodigoSession() {
    if (this.codigoEstudiante === undefined) {
      const codigo = sessionStorage.getItem('cf0416fo35t');
      if (codigo !== null) {
        this.codigoEstudiante = codigo.split('%')[1];
      }
    }
  }

  // ---------------------------------------------CREDITOS ADICIONALES----------------------------------------------------------------------------//
  listarEstudiantes(): Observable<WebServiceResponse> {
    const obj = {
      e: '2',
      p: 'PKG_CREDITOS_ADICIONALES.LISTAR_ESTUDIANTES',
      ps: { P_CODIGO_FACULTAD: this.getCodigoFactultad(), P_JORNADA_FACULTAD: this.jornadaFacultad },
      c: '0'
    };
    return this.pasarela(obj);
  }

  buscarEstudiantes(criteria: string): Observable<WebServiceResponse> {
    const obj = {
      e: '2',
      p: 'PKG_CREDITOS_ADICIONALES.BUSCAR_ESTUDIANTE',
      ps: {
        P_CRITERIO_BUSQUEDA: criteria,
        P_CODIGO_FACULTAD: this.getCodigoFactultad(),
        P_JORNADA_FACULTAD: this.jornadaFacultad
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  cancelarCreditosAdicionales(autorizationId: string): Observable<WebServiceResponse> {
    const obj = {
      e: '2',
      p: 'PKG_CREDITOS_ADICIONALES.CANCELAR_CREDITOS',
      ps: {
        P_AUTORIZACION_ID: autorizationId,
        P_CODIGO_FACULTAD: this.getCodigoFactultad(),
        P_JORNADA_FACULTAD: this.jornadaFacultad
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  autorizarCreditosAdicionales(
    codigoEstudiante: string,
    numeroCreditos: number,
    guiaDePago: string,
    guiaFinanciera: string
  ): Observable<WebServiceResponse> {
    const obj = {
      e: '2',
      p: 'PKG_CREDITOS_ADICIONALES.AUTORIZAR_CREDITOS',
      ps: {
        P_CODIGO_ESTUDIANTE: codigoEstudiante,
        P_NUMERO_CREDITOS: numeroCreditos,
        P_NUMERO_GUIA_PAGO: guiaDePago,
        P_GUIA_FINANCIERA: guiaFinanciera,
        P_CODIGO_FACULTAD: this.getCodigoFactultad(),
        P_JORNADA_FACULTAD: this.jornadaFacultad
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  // Llama mensajes para estudiantes desde la BD
  getInfoMensajes(codEst: string) {
    const obj = {
      e: '1',
      p: 'GET_MENSAJES',
      ps: {
        P_CODIGO_ESTUDIANTE: codEst
      },
      c: '0'
    };
    return this.pasarela(obj);
  }
  // --------------------------------------INTEGRADOS-----------------------------------------------------------------------------------//

  getFacultades(): Observable<FacultadesIntegrados[]> {
    const obj = {
      e: '2',
      p: 'PKG_PENSUM.getFacultades',
      ps: {},
      c: '0'
    };
    return this.pasarela(obj);
  }

  getMaterias(codigoFacultad: string, jornadaFacultad: string, planEstudio: string): Observable<MateriasIntegrados[]> {
    const obj = {
      e: '2',
      p: 'PKG_PENSUM.getMaterias',
      ps: {
        p_codigo_facultad: codigoFacultad,
        p_jornada_facultad: jornadaFacultad,
        p_plan_estudio: planEstudio
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  getMateriasIntegradas(planEstudio: string, codigoMateria: string): Observable<any[]> {
    const obj = {
      e: '2',
      p: 'PKG_PENSUM.getMateriasIntegradas',
      ps: {
        p_codigo_facultad: this.getCodigoFactultad(),
        p_jornada_facultad: this.jornadaFacultad,
        p_plan_estudio: planEstudio,
        p_codigo_materia: codigoMateria
      },
      c: '0'
    };
    return this.pasarela(obj);
  }

  guardarMateriaIntegrada(p_arg: any) {
    const obj = {
      e: '2',
      p: 'PKG_INTEGRADOS.salvar',
      ps: { p_arg: encodeURI(JSON.stringify(p_arg)) },
      c: '0'
    };
    return this.pasarela(obj);
  }

  eliminarMateriaIntegrada(p_arg: any) {
    const obj = {
      e: '2',
      p: 'PKG_INTEGRADOS.eliminar',
      ps: { p_arg: encodeURI(JSON.stringify(p_arg)) },
      c: '0'
    };
    return this.pasarela(obj);
  }

  // -------------------------------------------------------------------------------------------------------------------------//

  setCodigoFacultad(codigoFacultad: string) {
    sessionStorage.setItem('fctcdg', codigoFacultad);
  }

  setCodigoEstudiante(codigo: string) {
    this.codigoEstudiante = codigo;
  }

  getCodigoEsttudiante() {
    return this.codigoEstudiante;
  }

  setMenuUsuario(menuUsuario: MenuUsuario[]) {
    this.menuUsuario = menuUsuario;
  }

  getMenuUsuario(): MenuUsuario[] {
    return this.menuUsuario;
  }

  setPerfilesUsuario(perfilesUsuario: PerfilUsuario[]) {
    this.perfilesUsuario = perfilesUsuario;
  }

  getPerfilesUsuario(): PerfilUsuario[] {
    return this.perfilesUsuario;
  }

  getCodigoFactultad(): string {
    return sessionStorage.getItem('fctcdg');
  }

  getJornadaFacultad(): string {
    return this.jornadaFacultad;
  }

  getCodigoEstudianteService(): string {
    return this.codigoEstudiante;
  }

  setInfoUsuario(infoUsuario: InformacionUsuario) {
    this.infoUsuario = infoUsuario;
  }

  getInfoUsuario(): InformacionUsuario {
    return this.infoUsuario;
  }
}
