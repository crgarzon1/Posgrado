import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
import { InformacionUsuario } from 'src/app/Model/dashboard-ua/informacion-usuario';
import { MessageService } from 'primeng/api';

@Component({
  selector: 'app-main-ua',
  templateUrl: './main-ua.component.html',
  styleUrls: ['./main-ua.component.scss'],
  providers: [MessageService]
})
export class MainUaComponent implements OnInit {
  public infoUsuario: InformacionUsuario;
  public showButtonInfo: boolean = true;
  public cargo: string = '';
  public programa: string = '';
  public nombre: string = '';

  constructor(
    private services: GeneralService,
    private router: Router,
    private cookie: CookieService,
    private messageService: MessageService
  ) {
    this.infoUsuario = new InformacionUsuario();
    let token = this.cookie.get('wUFAnew4');
    if (!token) {
      this.router.navigateByUrl('login');
    } else {
      this.getInformacionUsuario();
    }
  }

  getInformacionUsuario() {
    this.services.getInformacionUsuario().subscribe(
      infoObs => {
        this.infoUsuario = infoObs;
        this.services.setInfoUsuario(infoObs);
      },
      error => {
        this.messageService.add({
          severity: 'warn',
          summary: 'No fue posible obtener la información del usuario',
          detail: 'Seleccione el perfil de nuevo en el botón "Cambio perfil".'
        });
        this.showButtonInfo = false;
      },
      () => {
        for (let i = 0; i < this.infoUsuario.propiedades.length; i++) {
          if (this.infoUsuario.propiedades[i].key == 'Programa') this.programa += this.infoUsuario.propiedades[i].value;
        }
        for (let i = 0; i < this.infoUsuario.propiedades.length; i++) {
          if (this.infoUsuario.propiedades[i].key == 'Cargo') this.cargo += this.infoUsuario.propiedades[i].value + ' ';
        }
        this.nombre = this.infoUsuario.nombre;
        this.messageService.add({ key: 'c', severity: 'success', detail: 'Bienvenido' });
        this.infoUsuario = this.services.getInfoUsuario();
      }
    );
  }

  showTooltip() {
    this.messageService.clear();
    setTimeout(() => {
      this.messageService.add({ key: 'c', severity: 'info', detail: '' });
    }, 10);
  }

  ngOnInit() {}
}
