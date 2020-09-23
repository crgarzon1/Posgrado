import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { Pendientes } from 'src/app/Model/dashboard/pendientes';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { DataSource, IDataSourceObserver, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-pendientes',
  templateUrl: './pendientes.component.html',
  styleUrls: ['./pendientes.component.scss']
})
export class PendientesComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  dataSource: DataSource;
  stringHelper: StringResourceHelper;
  settedInformacion: boolean = false;
  blocked: boolean = false;
  completo: boolean = false;
  financiera: number = 1;
  biblioteca: number = 1;
  documentos: number = 1;
  url: string = '';
  displaypys: boolean = false;
  pys: boolean = false;

  constructor(private service: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-pendientes');
    this.dataSource = DataSource.getInstance(service);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  refrescarDatos() {
    if (
      this.cambioDetectado(this.dataSource) &&
      this.dataSource.pendientes &&
      this.dataSource.procesoAcademico &&
      this.dataSource.prematricula
    ) {
      this.verificarIcono();
      this.checkItems();
      this.verificarMaterias();
      setTimeout(() => {
        this.blocked = false;
      }, 0);
      this.cambioExitoso(this.dataSource);
    }
  }

  verificarIcono() {
    this.completo =
      this.dataSource.pendientes.financiera <= 0 &&
      this.dataSource.pendientes.biblioteca <= 0 &&
      this.dataSource.pendientes.documentos <= 0;
  }

  checkItems() {
    this.financiera = this.dataSource.pendientes.financiera <= 0 ? 1 : 0;
    this.biblioteca = this.dataSource.pendientes.biblioteca <= 0 ? 1 : 0;
    this.documentos = this.dataSource.pendientes.documentos <= 0 ? 1 : 0;
  }

  verificarMaterias() {
    // this.pys = this.dataSource.pendientes.bolsas == 0 && this.dataSource.pendientes.materias == 0;
    this.pys = false;
    this.displaypys = false;
    this.service.getTerminacionPlan().subscribe(
      resp => {
        if (resp.periodoTerminacion) {
          this.pys = true;
        } else {
          console.log('No ha terminado');
        }
      },
      error => {
        console.error(error);
      }
    );
  }

  openPYS() {
    this.displaypys = true;
    this.url = environment.urlPostgrado + 'GENERAR_PYS_POS?p_cod=' + this.service.getCodigoEstudianteService();
  }

  ngOnInit() {}
}
