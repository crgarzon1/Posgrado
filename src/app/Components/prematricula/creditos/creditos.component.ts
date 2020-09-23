import { Component, OnInit, Input } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { MatriculaEstudiante } from 'src/app/Model/prematricula/matricula-estudiante';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { ObservableMatricula, IObserverMatricula } from 'src/app/Model/prematricula/observable-matricula';

@Component({
  selector: 'app-creditos',
  templateUrl: './creditos.component.html',
  styleUrls: ['./creditos.component.scss']
})
export class CreditosComponent implements OnInit, IObserverMatricula {
  stringHelper: StringResourceHelper;
  showTable: boolean = false;
  // private observableMatricula: ObservableMatricula;
  settedCreditos: boolean = false;

  @Input() observableMatricula: ObservableMatricula;

  constructor(private services: GeneralService) {
    this.stringHelper = new StringResourceHelper('matricula-creditos');
    this.observableMatricula = ObservableMatricula.getInstance(services);
    this.observableMatricula.addObserver(this);
  }

  refrescarDatos() {
    if (this.observableMatricula.settedMatriculaEstudiante && !this.settedCreditos) {
      this.settedCreditos = true;
      if (this.observableMatricula.estudiante.matricula !== null && this.observableMatricula.estudiante.matricula !== undefined) {
        this.showTable = true;
      }
    }
  }

  indicarCambioForzoso() {
    this.settedCreditos = false;
    this.showTable = false;
  }

  ngOnInit() {}
}
