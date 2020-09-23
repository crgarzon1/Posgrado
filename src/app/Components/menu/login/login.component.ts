import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { Respuesta } from 'src/app/Model/prematricula/respuesta';
import { CookieService } from 'ngx-cookie-service';
import { Router } from '@angular/router';
import { PerfilUsuario } from 'src/app/Model/menu/perfil-usuario';
import { MenuUsuario } from 'src/app/Model/menu/menu-usuario';
import { MessageService } from 'primeng/components/common/messageservice';
import { DataSource } from 'src/app/Model/dashboard/data-source';
declare var gtag: Function;

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss'],
  providers: [MessageService]
})
export class LoginComponent implements OnInit {
  public usuario: string;
  public contrasena: string;
  public hide: boolean = true;
  public respuestaLogin: Respuesta;
  public perfiles: PerfilUsuario[];
  public perfilSelected: PerfilUsuario = new PerfilUsuario();
  public menu: MenuUsuario[];
  public displaySelect: boolean = false;
  public spinnerLoad: boolean = false;
  public respuestaCodigo: Respuesta;
  public sinCookie: boolean = true;

  constructor(
    private services: GeneralService,
    private cookie: CookieService,
    private router: Router,
    private messageService: MessageService
  ) {
    var cookiePortal = this.cookie.get('UEPMDRPLS');
    if (cookiePortal) {
      this.sinCookie = false;
      this.usuario = 'SulWvK5SqnKmiu6t';
      this.contrasena = cookiePortal;
      this.login();
    }
    this.spinnerLoad = false;
  }

  ngOnInit() {}

  login() {
    gtag('send', 'event', {
      event_category: 'Evento',
      event_label: 'Prueba Evento',
      value: 'Perfil',
      event_action: 'Cambiar de perfil'
    });
    this.spinnerLoad = true;
    this.services.loginUsuario(this.usuario.trim(), this.contrasena.trim()).subscribe(
      respuestaObs => {
        this.respuestaLogin = respuestaObs;
      },
      error => {
        this.spinnerLoad = false;
        this.messageService.add({
          severity: 'warn',
          summary: 'No se ha podido iniciar sesión',
          detail: 'Por favor verifique sus datos.'
        });
        if (!this.sinCookie) {
          this.usuario = '';
          this.contrasena = '';
        }
        this.sinCookie = true;
      },
      () => {
        this.spinnerLoad = false;
        sessionStorage.setItem('tnkptcn', this.respuestaLogin.mensaje);
        this.getPerfil();
        if (!this.sinCookie) {
          this.usuario = '';
          this.contrasena = '';
        }
      }
    );
  }

  getPerfil() {
    this.spinnerLoad = true;
    this.services.getPerfilUsuario().subscribe(
      perfilesObs => {
        this.perfiles = perfilesObs;
      },
      error => {
        this.spinnerLoad = false;
        this.messageService.add({ severity: 'warn', summary: 'No se han podido seleccionar perfiles' });
      },
      () => {
        this.spinnerLoad = false;
        this.services.setPerfilesUsuario(this.perfiles);
        if (!this.perfiles.length) {
          this.messageService.add({ severity: 'warn', summary: 'No tiene perfiles disponibles' });
        } else if (this.perfiles.length > 1) {
          this.displaySelect = true;
        } else {
          this.perfilSelected = this.perfiles[0];
          this.perfilSeleccionado();
        }
      }
    );
  }

  getMenu() {
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
        this.router.navigateByUrl('mainMenu');
      }
    );
  }

  getInformacionUsuario() {
    this.services.getInformacionUsuario().subscribe(infoObs => {
      this.services.setInfoUsuario(infoObs);
    });
  }

  perfilSeleccionado() {
    this.getInformacionUsuario();
    sessionStorage.setItem('l4b3l', this.perfilSelected.etiqueta);
    sessionStorage.setItem('t0u1emt', String(new Date().getTime()));
    if (this.perfilSelected.token && !this.perfilSelected.tokenSia) {
      this.cookie.set('wUFAnew4', this.perfilSelected.token, 0.04, '/', '.lasalle.edu.co');
    } else if (this.perfilSelected.tokenSia && !this.perfilSelected.token) {
      this.cookie.set('wUFAnew4', this.perfilSelected.tokenSia, 0.04, '/', '.lasalle.edu.co');
    }
    sessionStorage.removeItem('s3ent3d13b');
    sessionStorage.removeItem('z5e6t3d19a');
    sessionStorage.removeItem('extsj3h1');

    if (PerfilUsuario.esEstudiante(this.perfilSelected.codigoPerfil)) {
      if (this.perfilSelected.token && !this.perfilSelected.tokenSia) {
        this.getCodigo();
      } else if (this.perfilSelected.tokenSia && !this.perfilSelected.token) {
        this.cookie.set('dOe7LafrI8ph', this.perfilSelected.tokenSia, 0.04, '/', '.lasalle.edu.co');
        sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
        this.getMenu();
      }
    } else if (PerfilUsuario.esUnidadAcademica(this.perfilSelected.codigoPerfil)) {
      if (this.perfilSelected.token && !this.perfilSelected.tokenSia) {
        this.services.setCodigoFacultad(this.perfilSelected.codigoFacultad);
        sessionStorage.setItem('s3ent3d13b', 'apd3jkqcq3#$2v243%6#v6#');
        this.getMenu();
      } else if (this.perfilSelected.tokenSia && !this.perfilSelected.token) {
        this.cookie.set('dOe7LafrI8ph', this.perfilSelected.tokenSia, 0.04, '/', '.lasalle.edu.co');
        sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
        this.getMenu();
      }
    } else {
      this.cookie.set('dOe7LafrI8ph', this.perfilSelected.tokenSia, 0.04, '/', '.lasalle.edu.co');
      sessionStorage.setItem('extsj3h1', '2v243#$2v24apd3jkqcq3');
      this.getMenu();
    }
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
          sessionStorage.setItem('cf0416fo35t', 'csf02321ssh%' + this.respuestaCodigo.mensaje + '%003057234%cf04fo174');
          this.services.getCodigoSession();
          DataSource.getInstance(this.services).setCodigoEstudiante(this.respuestaCodigo.mensaje);
          this.getMenu();
        } else if (this.respuestaCodigo.status === 'fail') {
          this.messageService.add({ severity: 'warn', summary: 'No es posible cargar el código de estudiante' });
        }
      }
    );
  }
}
