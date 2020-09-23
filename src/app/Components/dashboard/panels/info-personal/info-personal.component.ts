import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { Estudiante } from 'src/app/Model/dashboard/estudiante';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { DataSource, IDataSourceObserver, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';

@Component({
  selector: 'app-info-personal',
  templateUrl: './info-personal.component.html',
  styleUrls: ['./info-personal.component.scss']
})
export class InfoPersonalComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  public stringHelper: StringResourceHelper;
  public dataSource: DataSource;
  public blocked: boolean = false;
  public matriculado: string = '';
  public periodoPago: string = '';
  public displayInfoPersonal: boolean = false;

  constructor(private generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-informacion-personal');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  refrescarDatos() {
    if (this.dataSource.estudiante && this.cambioDetectado(this.dataSource)) {
      setTimeout(() => {
        this.blocked = false;
      }, 150);
      this.cambioExitoso(this.dataSource);
      switch (this.dataSource.estudiante.indicadorp) {
        case 'X':
          this.matriculado = 'No matriculado';
          this.periodoPago = '';
          break;
        case 'P':
          this.matriculado = 'Matriculado';
          this.periodoPago = 'pago semestre completo';
          break;
        case 'V':
          this.matriculado = 'Matriculado';
          this.periodoPago = 'pago primer trimestre';
          break;
        case 'W':
          this.matriculado = 'Matriculado';
          this.periodoPago = 'pago segundo trimestre';
          break;
        case 'K':
          this.matriculado = 'Canceló';
          this.periodoPago = 'semestre completo';
          break;
        case 'C':
          this.matriculado = 'Canceló';
          this.periodoPago = 'primer trimestre';
          break;
        case 'D':
          this.matriculado = 'Canceló';
          this.periodoPago = 'segundo trimestre';
          break;
        default:
          this.matriculado = 'No matriculado';
          this.periodoPago = '';
          break;
      }
    }
  }

  openInfoPersonal() {
    this.displayInfoPersonal = true;
  }

  imagenDefecto() {
    this.dataSource.estudiante.foto = 'assets/images/person.png';
  }

  ngOnInit() {}
}
