import { Component, OnInit, DoCheck } from '@angular/core';
import { MenuItem } from 'primeng/components/common/menuitem';
import { GeneralService } from 'src/app/Services/general.service';
import { EstudianteBusqueda } from 'src/app/Model/menu/estudiante-busqueda';
import { Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
import { MenuUsuario, Params, ValueParams } from 'src/app/Model/menu/menu-usuario';
import { PerfilUsuario } from 'src/app/Model/menu/perfil-usuario';
import { Respuesta } from 'src/app/Model/prematricula/respuesta';
import { ObservableMatricula } from 'src/app/Model/prematricula/observable-matricula';
import { MessageService, ConfirmationService } from 'primeng/api';
import { GuiaPago, Periodo } from 'src/app/Model/menu/guia-pago';
import { DataSource } from 'src/app/Model/dashboard/data-source';
import { environment } from 'src/environments/environment';
import { InformacionUsuario } from 'src/app/Model/dashboard-ua/informacion-usuario';

/**
 * Nota... Por mucho tiempo he querido arreglar esta clase masiva y horrible
 * Pero no se ha dado la oportunidad, lo siento.
 */
@Component({
  selector: 'app-main-menu',
  templateUrl: './main-menu.component.html',
  styleUrls: ['./main-menu.component.scss'],
  providers: [MessageService, ConfirmationService]
})
export class MainMenuComponent implements OnInit, DoCheck {
  public itemsMenu: MenuItem[] = [];
  public displaySideBar: boolean = false;
  public displaySearchEst: boolean = false;
  public display: boolean = false;
  public displayDialogBusqueda: boolean = false;
  public dashboard: boolean = false;
  public displayAccessPoint: boolean = false;
  public displayCodigoPrematricula: boolean = false;
  public displayCodigoConsultaGeneral: boolean = false;
  public displayCodigoGuiaPago: boolean = false;
  public cargaPeriodos: boolean = false;
  public progress: boolean = false;
  public url: string;
  public estudianteBusqueda: EstudianteBusqueda;
  public estudiantesBusqueda: EstudianteBusqueda[] = [];
  public disableBusquedaEstudiante: boolean = true;
  public tituloModal = '';
  public menu: MenuUsuario[];
  public unidadAcademica: boolean = false;
  public estudiante: boolean = false;
  public urlAccessPoint: string;
  public paramsAccessPoint: Params[];
  public paramsAccessFill: ValueParams[] = [];
  public perfiles: PerfilUsuario[];
  public respuestaCodigo: Respuesta;
  public ventana = '';
  public codigoEstudiante = '';
  public periodosGuia: GuiaPago = new GuiaPago();
  public periodoSelected: Periodo = new Periodo();
  public buttonGuiaDisabled = true;
  public urlExt: string = environment.urlAdmisiones + 'validar_u_bak';
  public externo: boolean = false;
  public logo: boolean = true;
  public generarGuia: string = 'Generar Guía';
  public estudiantePrematricula: any = null;
  public codigoEstudianteConsultaGeneral: string = null;
  public labelPerfil: string = '';

  public cargo: string = '';
  public programa: string = '';
  public nombre: string = '';

  constructor(
    private services: GeneralService,
    private cookie: CookieService,
    private router: Router,
    private messageService: MessageService,
    private confirmationService: ConfirmationService
  ) {
    if (sessionStorage.getItem('s3ent3d13b') === 'apd3jkqcq3#$2v243%6#v6#') this.unidadAcademica = true;
    else if (sessionStorage.getItem('z5e6t3d19a') === 'ag75jkqcq3#$ffs243gmkr00') {
      this.estudiante = true;
      DataSource.getInstance(this.services).setCodigoEstudianteCookie();
    } else if (sessionStorage.getItem('extsj3h1') === '2v243#$2v24apd3jkqcq3') {
      this.externo = true;
      this.logo = false;
    }
    this.labelPerfil = sessionStorage.getItem('l4b3l');
    var token = this.cookie.get('wUFAnew4');
    if (token) {
      this.getMenuUsuario();
    } else {
      this.router.navigateByUrl('login');
    }
  }

  ngOnInit() {}

  loadMenuBar() {
    let items = [];
    if (!this.externo) {
      items = this.services.getMenuUsuario();
    }
    this.itemsMenu = this.fillItems(items);
    if (!this.services.getPerfilesUsuario()) {
      this.loadPerfiles();
    } else {
      this.menuCambioPerfiles();
    }
  }

  loadPerfiles() {
    this.services.getPerfilUsuario().subscribe(
      perfilesObs => {
        this.perfiles = perfilesObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No se han podido cargar perfiles para el usuario',
          detail: error.error.mensaje
        });
      },
      () => {
        this.services.setPerfilesUsuario(this.perfiles);
        this.menuCambioPerfiles();
      }
    );
  }

  menuCambioPerfiles() {
    this.getInformacionUsuario();
    if (this.services.getPerfilesUsuario().length) {
      this.itemsMenu.push({
        label: 'Cambio perfil',
        items: this.fillPerfiles()
      });
    }
    this.itemsMenu.push({
      label: 'Cerrar sesion',
      command: event => {
        this.progress = true;
        sessionStorage.clear();
        this.cookie.delete('wUFAnew4', '/', '.lasalle.edu.co');
        this.cookie.delete('UEPMDRPLS', '/', '.lasalle.edu.co');
        // setTimeout(() => {
        this.router.navigateByUrl('/login');
        // }, 1000);
        //location.reload();
      }
    });
  }

  fillPerfiles(): MenuItem[] {
    var childItems: MenuItem[] = [];
    for (let i = 0; i < this.services.getPerfilesUsuario().length; i++) {
      childItems.push({
        label: this.services.getPerfilesUsuario()[i].etiqueta,
        command: event => this.changePerfil(this.services.getPerfilesUsuario()[i])
      });
    }
    return childItems;
  }

  changePerfil(perfil: PerfilUsuario) {
    if (this.displaySideBar) this.displaySideBar = false;
    this.services.getPerfilUsuario().subscribe(
      perfilesObs => {
        this.perfiles = perfilesObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No se han podido cargar perfiles para el usuario',
          detail: error.error.mensaje
        });
      },
      () => {
        var perfilParam: PerfilUsuario = new PerfilUsuario();
        perfilParam = this.perfiles.find(perfilObs => perfilObs.etiqueta == perfil.etiqueta);
        sessionStorage.setItem('l4b3l', perfilParam.etiqueta);
        this.labelPerfil = perfilParam.etiqueta;
        this.setInfoPerfil(perfilParam);
      }
    );
  }

  getInformacionUsuario() {
    this.services.setInfoUsuario(new InformacionUsuario());
    this.programa = '';
    this.cargo = '';
    this.nombre = '';
    this.services.getInformacionUsuario().subscribe(infoObs => {
      this.services.setInfoUsuario(infoObs);
      for (let i = 0; i < infoObs.propiedades.length; i++) {
        if (infoObs.propiedades[i].key == 'Programa') this.programa += infoObs.propiedades[i].value;
      }
      for (let i = 0; i < infoObs.propiedades.length; i++) {
        if (infoObs.propiedades[i].key == 'Cargo') this.cargo += infoObs.propiedades[i].value + ' ';
      }
      this.nombre = infoObs.nombre;
      this.messageService.add({ key: 'c', severity: 'success', detail: 'Bienvenido' });
    });
  }

  setInfoPerfil(perfilParam: PerfilUsuario) {
    if (perfilParam.token && !perfilParam.tokenSia) {
      this.cookie.set('wUFAnew4', perfilParam.token, 0.039, '/', '.lasalle.edu.co');
    } else if (perfilParam.tokenSia && !perfilParam.token) {
      this.cookie.set('wUFAnew4', perfilParam.tokenSia, 0.039, '/', '.lasalle.edu.co');
    }
    sessionStorage.removeItem('s3ent3d13b');
    sessionStorage.removeItem('z5e6t3d19a');
    sessionStorage.removeItem('extsj3h1');
    if (PerfilUsuario.esEstudiante(perfilParam.codigoPerfil)) {
      if (perfilParam.token && !perfilParam.tokenSia) {
        this.cookie.set('wUFAnew4', perfilParam.token, 0.039, '/', '.lasalle.edu.co');
        this.getCodigo();
        this.unidadAcademica = false;
        this.logo = true;
        this.estudiante = true;
        this.externo = false;
      } else if (perfilParam.tokenSia && !perfilParam.token) {
        this.cookie.set('wUFAnew4', perfilParam.tokenSia, 0.039, '/', '.lasalle.edu.co');
        this.logo = false;
        this.urlExt = '';
        this.itemsMenu = [];
        this.menuCambioPerfiles();
        setTimeout(() => {
          this.urlExt = environment.urlAdmisiones + 'validar_u_bak';
          this.unidadAcademica = false;
          this.estudiante = false;
          this.externo = true;
          this.cookie.set('dOe7LafrI8ph', perfilParam.tokenSia, 0.04, '/', '.lasalle.edu.co');
          sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
        }, 150);
      }
    } else if (PerfilUsuario.esUnidadAcademica(perfilParam.codigoPerfil)) {
      if (perfilParam.token && !perfilParam.tokenSia) {
        this.services.setCodigoFacultad(perfilParam.codigoFacultad);
        sessionStorage.setItem('s3ent3d13b', 'apd3jkqcq3#$2v243%6#v6#');
        this.getMenuUsuario();
        this.unidadAcademica = true;
        this.estudiante = false;
        this.logo = true;
        this.externo = false;
        this.router.navigateByUrl('/dummy', { skipLocationChange: true }).then(() => this.router.navigate(['mainMenu']));
      } else if (perfilParam.tokenSia && !perfilParam.token) {
        this.urlExt = '';
        this.itemsMenu = [];
        this.menuCambioPerfiles();
        this.logo = false;
        setTimeout(() => {
          this.urlExt = environment.urlAdmisiones + 'validar_u_bak';
          this.unidadAcademica = false;
          this.estudiante = false;
          this.externo = true;
          this.cookie.set('dOe7LafrI8ph', perfilParam.tokenSia, 0.04, '/', '.lasalle.edu.co');
          sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
        }, 150);
      }
    } else {
      this.urlExt = '';
      this.itemsMenu = [];
      this.menuCambioPerfiles();
      this.logo = false;
      setTimeout(() => {
        this.urlExt = environment.urlAdmisiones + 'validar_u_bak';
        this.unidadAcademica = false;
        this.estudiante = false;
        this.externo = true;
        this.cookie.set('dOe7LafrI8ph', perfilParam.tokenSia, 0.04, '/', '.lasalle.edu.co');
        sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
      }, 150);
    }
  }

  fillItems(items: MenuUsuario[]): MenuItem[] {
    var childItems: MenuItem[] = [];
    for (let i = 0; i < items.length; i++) {
      childItems.push({
        label: items[i].label,
        disabled: !items[i].enabled,
        items: items[i].items.length > 0 ? this.fillItems(items[i].items) : undefined,
        command: event => (!items[i].items.length ? this.displayModal(items[i].label, items[i]) : null)
      });
    }
    return childItems;
  }

  getMenuUsuario() {
    // this.getInformacionUsuario();
    this.services.getMenuUsuarioService().subscribe(
      menuObs => {
        this.menu = menuObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No es posible cargar un menú para el usuario',
          detail: error.error.mensaje
        });
      },
      () => {
        this.services.setMenuUsuario(this.menu);
        this.loadMenuBar();
      }
    );
  }

  displayBarSide() {
    this.displaySideBar = !this.displaySideBar;
    if (this.displaySearchEst) this.displaySearchEst = !this.displaySearchEst;
  }

  displaySearch() {
    this.displaySearchEst = !this.displaySearchEst;
    if (this.displaySideBar) this.displaySideBar = !this.displaySideBar;
  }

  displayModal(label: string, item: MenuUsuario) {
    this.tituloModal = label;
    if (this.displaySideBar) this.displaySideBar = false;
    if (item.typeId === '4') {
      this.ventana = 'url';
      if (!item.params.length) {
        this.display = true;
        this.url = item.urlRef;
      } else {
        this.paramsAccessFill = [];
        this.paramsAccessPoint = item.params;
        this.urlAccessPoint = item.urlRef;
        for (let i = 0; i < this.paramsAccessPoint.length; i++) {
          this.paramsAccessFill.push({
            key: this.paramsAccessPoint[i].identifier,
            value: ''
          });
        }
        this.displayAccessPoint = true;
      }
    } else if (item.typeId === '3') {
      this.codigoEstudiante = '';
      switch (item.urlRef) {
        case '/creditosAdicionales':
          this.ventana = 'creditosAdicionales';
          setTimeout(() => {
            this.display = true;
          }, 300);
          break;
        case '/prematricula':
          this.estudiantePrematricula = null;
          this.displayCodigoPrematricula = true;
          break;
        case '/integrados':
          this.ventana = 'integrados';
          this.display = true;
          break;
        case '/consultagen':
          this.codigoEstudianteConsultaGeneral = '';
          this.displayCodigoConsultaGeneral = true;
          break;
        case '/guiaDePago':
          this.services.getGuiaAdicionales().subscribe(
            resp => {
              if (resp.status == 'ok') {
                this.ventana = 'url';
                this.url = 'https://facturacion.lasalle.edu.co/GuiasPago-war/VerGuiaPos?numGuia=' + resp.mensaje;
                this.display = true;
                this.cargaPeriodos = false;
                this.messageService.add({
                  key: 'guias',
                  severity: 'info',
                  summary: 'Guia de pago',
                  detail: 'Créditos adicionales'
                });
              } else if (resp.status == 'fail') {
                if (this.estudiante) {
                  this.codigoEstudiante = this.services.codigoEstudiante;
                  this.displayGuiaPago();
                } else if (this.unidadAcademica) {
                  this.displayCodigoGuiaPago = true;
                }
                this.cargaPeriodos = false;
              }
            },
            error => {
              if (error.error.status == 'fail') {
                if (this.estudiante) {
                  this.codigoEstudiante = this.services.codigoEstudiante;
                  this.displayGuiaPago();
                } else if (this.unidadAcademica) {
                  this.displayCodigoGuiaPago = true;
                }
                this.cargaPeriodos = false;
              }
            }
          );
          // this.cargaPeriodos = false;
          break;
      }
    }
  }

  filterEstudiantes(event) {
    let query = event.query;
    var regexConNumero = /^.*[0-9]+.*$/;
    var regexCodigo = /^[A-Za-z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$/;

    if (query.length >= 7 && regexCodigo.test(query)) {
      this.llamarServicioBusqueda('C', query.toUpperCase());
    } else if (!regexConNumero.test(query)) {
      this.llamarServicioBusqueda('N', query);
    } else if (query.length >= 4) {
      this.llamarServicioBusqueda('D', query);
    }
  }

  llamarServicioBusqueda(criterio: string, valor: string) {
    this.services.getEstudianteBusqueda(criterio, encodeURI(valor.trim().replace(/[\s]+/, '%'))).subscribe(
      busquedaObs => {
        this.estudiantesBusqueda = busquedaObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No es posible hacer la busqueda de estudiante',
          detail: 'Por favor recargue esta página.'
        });
      },
      () => {
        if (this.estudiantesBusqueda.length) {
          this.estudiantesBusqueda.forEach(e => (e.nombreCompuesto = `${e.codigo} - ${e.nombre}`));
          this.disableBusquedaEstudiante = false;
        } else {
          this.disableBusquedaEstudiante = true;
        }
      }
    );
  }

  verificarMaximo(e) {
    if (String(this.estudianteBusqueda).length < 3) this.disableBusquedaEstudiante = true;
  }

  buscarEstudiante() {
    if (this.estudianteBusqueda) {
      if (!this.estudianteBusqueda.codigo) {
        if (this.estudiantesBusqueda.length > 0) {
          this.estudianteBusqueda = this.estudiantesBusqueda[0];
        } else return;
      }
      this.dashboard = false;
      this.dashboardEstudiante(this.estudianteBusqueda, true);
      this.estudianteBusqueda = new EstudianteBusqueda();
      this.disableBusquedaEstudiante = true;
    }
  }

  dashboardEstudiante(estudiante: EstudianteBusqueda, dashboard: boolean) {
    this.estudianteBusqueda = new EstudianteBusqueda();
    DataSource.getInstance(this.services).setCodigoEstudiante(estudiante.codigo);
    this.dashboard = dashboard;
  }

  doOnSelect($event) {
    this.buscarEstudiante();
  }

  displayModalAccessPoint() {
    this.urlAccessPoint = this.urlAccessPoint.replace('[PARAMSPLACEHOLDER]', JSON.stringify(this.paramsAccessFill));
    if (this.displaySideBar) this.displaySideBar = false;
    this.displayAccessPoint = false;
    this.display = true;
    this.url = this.urlAccessPoint;
  }

  displayModalPrematricula() {
    this.services.getEstudianteBusqueda('C', this.codigoEstudiante.toUpperCase().trim()).subscribe(
      estudianteObs => {
        if (estudianteObs.length) {
          this.services.setCodigoEstudiante(this.codigoEstudiante.trim());
          this.estudiantePrematricula = estudianteObs[0];
          if (this.displaySideBar) this.displaySideBar = false;
          ObservableMatricula.getInstance(this.services).refrescarPeticiones();
          this.displayCodigoPrematricula = false;
          this.progress = true;
          setTimeout(() => {
            this.ventana = 'matricula';
            this.display = true;
            this.codigoEstudiante = '';
            this.progress = false;
          }, 1050);
        } else {
          this.messageService.add({
            severity: 'warn',
            summary: 'No se ha encontrado al usuario',
            detail: 'El usuario no existe o no hace parte de la unidad académica.'
          });
        }
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No se ha encontrado al usuario',
          detail: error.error.mensaje
        });
      }
    );
  }

  displayGuiaPago() {
    this.periodoSelected = new Periodo();
    this.buttonGuiaDisabled = true;
    this.services.getPeriodosGuiaPago(this.codigoEstudiante.trim()).subscribe(
      guiaObs => {
        this.periodosGuia = guiaObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No ha sido posible generar los periodos de pago.',
          detail: error.error.mensaje
        });
      },
      () => {
        this.cargaPeriodos = true;
        this.displayCodigoGuiaPago = false;
        setTimeout(() => {
          this.displayCodigoGuiaPago = true;
          this.messageService.add({
            key: 'guias',
            severity: 'info',
            summary: 'Guia de pago',
            detail: 'Periodo académico'
          });
        }, 1);
      }
    );
  }

  displayConsultaGeneral() {
    if (this.codigoEstudianteConsultaGeneral.substr(0, 2) !== sessionStorage.getItem('fctcdg')) {
      this.messageService.clear();
      this.messageService.add({
        severity: 'warn',
        summary: 'Código incorrecto',
        detail: 'El código es incorrecto o no corresponde al programa'
      });
      return;
    }
    this.url = `http://registro.lasalle.edu.co/pls/postgrado/estudio_posgrados?p_codest=${this.codigoEstudianteConsultaGeneral}&p_usuario=ROUS`;
    this.tituloModal = 'Consulta General Posgrados';
    this.ventana = 'url';
    this.display = true;

    this.codigoEstudianteConsultaGeneral = '';
    this.displayCodigoConsultaGeneral = false;
  }

  openGuia() {
    this.buttonGuiaDisabled = true;
    this.cargaPeriodos = false;

    if (this.periodosGuia.guia > 0) {
      this.confirmationService.confirm({
        header: 'El usuario ya tiene activas ' + this.periodosGuia.guia + ' guia(s).',
        message: 'Al generar una nueva guía de pago la anterior quedará inhabilitada.',
        accept: () => {
          this.obtenerGuiaPago();
        },
        reject: () => {
          this.messageService.add({
            severity: 'info',
            summary: 'No se ha generado la guía de pago'
          });
        },
        acceptLabel: 'Si',
        rejectLabel: 'No'
      });
    } else {
      this.obtenerGuiaPago();
    }
  }

  buscarEstGuia(e) {
    this.displayGuiaPago();
  }

  buscarEstPrem(e) {
    this.displayModalPrematricula();
  }

  buscarEstConsGeneral(e) {
    this.displayConsultaGeneral();
  }

  obtenerGuiaPago() {
    var codigoEst = '';
    if (!this.estudiante) {
      codigoEst = this.codigoEstudiante.trim();
    }
    this.generarGuia = 'Cargando...';
    this.progress = true;
    this.messageService.clear();
    this.services.getGuiaPago(codigoEst, this.periodoSelected.id).subscribe(
      guiaObs => {
        this.progress = false;
        if (guiaObs.status === 'ok') {
          this.ventana = 'url';
          this.url = guiaObs.mensaje.split(';')[1];
          this.display = true;
        } else if (guiaObs.status === 'fail') {
          this.messageService.add({
            severity: 'warn',
            detail: guiaObs.mensaje
          });
        }
      },
      error => {
        this.progress = false;
        this.messageService.add({
          severity: 'warn',
          summary: 'No es posible obtener la guía de pago',
          detail: error.error.mensaje
        });
        this.generarGuia = 'Generar Guía';
        this.buttonGuiaDisabled = false;
      },
      () => {
        this.generarGuia = 'Generar Guía';
        this.buttonGuiaDisabled = false;
        this.progress = false;
      }
    );
  }

  seleccionGuia() {
    this.buttonGuiaDisabled = false;
  }

  getCodigo() {
    this.services.getCodigoEstudiante().subscribe(
      respuestaObs => {
        this.respuestaCodigo = respuestaObs;
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No es posible cargar el código de estudiante',
          detail: error.error.mensaje
        });
      },
      () => {
        if (this.respuestaCodigo.status === 'ok') {
          sessionStorage.setItem('z5e6t3d19a', 'ag75jkqcq3#$ffs243gmkr00');
          this.services.setCodigoEstudiante(this.respuestaCodigo.mensaje);
          sessionStorage.setItem('cf0416fo35t', 'csf02321ssh%' + this.respuestaCodigo.mensaje + '%003057234%cf04fo174');
          let estudiante: EstudianteBusqueda = new EstudianteBusqueda();
          estudiante.codigo = this.respuestaCodigo.mensaje;
          this.dashboardEstudiante(estudiante, false);
          this.unidadAcademica = false;
          this.estudiante = true;
          this.externo = false;
          this.getMenuUsuario();
        } else if (this.respuestaCodigo.status === 'fail') {
        }
      }
    );
  }

  ngDoCheck(): void {
    var currentTime = new Date().getTime();
    var totalTime = currentTime - Number(sessionStorage.getItem('t0u1emt'));
    if (totalTime > 3120000) {
      //57 minutos 3120000
      this.confirmationService.confirm({
        message: 'Su sesión ha caducado, por favor ingrese nuevamente.',
        header: 'Sesión caducada',
        icon: 'pi pi-exclamation-triangle',
        accept: () => {
          this.router.navigateByUrl('login');
        },
        rejectVisible: false,
        acceptLabel: 'Ingresar',
        key: 'cookieDialog'
      });
    }
  }
}
