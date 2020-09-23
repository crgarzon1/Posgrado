import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { GeneralService } from 'src/app/Services/general.service';

@Component({
  selector: 'app-main-dashboard',
  templateUrl: './main-prematricula.component.html',
  styleUrls: ['./main-prematricula.component.scss'],
  providers: [MessageService]
})
export class MainDashboardComponent implements OnInit {
  public mensajes: any = [];
  constructor(private router: Router, private messageService: MessageService, private services: GeneralService) {
    let token = sessionStorage.getItem('tnkptcn');
    if (!token) {
      this.router.navigateByUrl('login');
    }

    setTimeout(() => {
      this.services.getInfoMensajes(this.services.getCodigoEsttudiante()).subscribe(res => {
        if (res.status == 'ok') {
          this.mensajes = res.response;
          if (this.mensajes) {
            this.mensajes.map(r => {
              this.messageService.add({
                severity: 'info',
                summary: r.titulo,
                detail: r.mensaje,
                life: 10000
              });
            });
          }
        }
      });
    }, 1500);
  }

  ngOnInit() {}
}
