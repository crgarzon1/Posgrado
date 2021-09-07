import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { MessageService } from 'primeng/api';
import { Session } from 'protractor';
import { GeneralService } from 'src/app/Services/general.service';

@Component({
  selector: 'app-main-dashboard',
  templateUrl: './main-prematricula.component.html',
  styleUrls: ['./main-prematricula.component.scss'],
  providers: [MessageService]
})
export class MainDashboardComponent implements OnInit {
  public mensajes: any = [];
  public encuesta: boolean = true;
  public urlEncuesta: string = '';
  public censo: boolean = true;
  public urlCenso: string = '';
  constructor(private router: Router, private messageService: MessageService, private services: GeneralService) {
    this.hizoEncuesta();
    this.encuestaCenso();
    let token = sessionStorage.getItem('tnkptcn');
    if (!token) {
      this.router.navigateByUrl('login');
    }

    if (!sessionStorage.getItem('s3ent3d13b')) {
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
  }

  hizoEncuesta() {
    if (sessionStorage.getItem('s3ent3d13b')) {
      this.encuesta = true;
      this.urlEncuesta = '';
    } else {
      this.services.actualizoDatos().subscribe(res => {
        if (res.status == 'ok') {
          this.encuesta = true;
          this.urlEncuesta = '';
        } else {
          this.encuesta = false;
          this.urlEncuesta = 'http://jupiter.lasalle.edu.co/SGE-web/IndexEstudiante';
        }
      });
    }
  }

  finalizar() {
    location.reload();
  }

  encuestaCenso() {
    if (sessionStorage.getItem('s3ent3d13b')) {
      this.censo = true;
      this.urlCenso = '';
    } else {
      this.services.censo().subscribe(res => {
        if (res.status == 'ok') {
          this.censo = true;
          this.urlCenso = '';
        } else {
          this.censo = false;
          this.urlCenso = 'https://es.surveymonkey.com/r/CLS_2021';
        }
      });
    }
  }

  cerrar() {
    this.censo = true; // location.reload();
  }

  ngOnInit() {}
}
