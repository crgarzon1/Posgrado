import { Component, OnInit, ViewEncapsulation, Output, EventEmitter, Input } from '@angular/core';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { GeneralService } from 'src/app/Services/general.service';
import { MatriculaOferta, Grupo } from 'src/app/Model/prematricula/matricula-oferta';
import { ObservableMatricula, IObserverMatricula } from 'src/app/Model/prematricula/observable-matricula';
import { Respuesta } from 'src/app/Model/prematricula/respuesta';
import { MessageService } from 'primeng/components/common/messageservice';
import { SelectItem } from 'primeng/components/common/selectitem';
import moment from 'moment';

@Component({
  selector: 'app-oferta',
  templateUrl: './oferta.component.html',
  styleUrls: ['./oferta.component.scss'],
  encapsulation: ViewEncapsulation.None,
  providers: [MessageService]
})
export class OfertaComponent implements OnInit, IObserverMatricula {
  public display: boolean = false;
  public stringHelper: StringResourceHelper;
  public materiaActual: MatriculaOferta;
  //private observableMatricula: ObservableMatricula;
  public respuestaInscribir: Respuesta;
  settedOferta: boolean = false;

  brands: SelectItem[] = [{ label: 'Toda las facultades', value: null }];
  cols: any[] = [];

  @Output() showProgress = new EventEmitter<boolean>();
  @Input() observableMatricula: ObservableMatricula;

  constructor(public generalService: GeneralService, private messageService: MessageService) {
    this.stringHelper = new StringResourceHelper('matricula-oferta');
    this.observableMatricula = ObservableMatricula.getInstance(generalService);
    this.observableMatricula.addObserver(this);
  }

  ngOnInit() {
    this.cols = [
      { field: 'facultad', header: 'Facultad' },
      { field: 'codigo Materia Plan', header: 'Codigo Materia Plan' },
      { field: 'materia Plan', header: 'Materia Plan' },
      { field: 'semestre', header: 'Semestre' },
      { field: 'creditos', header: 'Creditos' }
    ];
  }

  /**
   * Verifica los arreglos de asignaturas disponibles y asignaturas por bolsa de creditos, y les asigna el estado de la
   * inscripcion.
   */
  refrescarDatos() {
    // Se verifica si ya fueron obtenidos los datos en el observable.
    if (
      this.observableMatricula.settedAsignaturasDisponiblesPlan &&
      this.observableMatricula.settedAsignaturasMatriculadas &&
      this.observableMatricula.settedBolsasCreditosElectivos &&
      !this.settedOferta
    ) {
      this.settedOferta = true;
      // Iteracion sobre asignaturas disponibles del plan.
      for (let i = 0; i < this.observableMatricula.asignaturasDisponiblesPlan.length; i++) {
        // Asignando como inscrita a las materias que estan en el arreglo asignaturasMatriculadas.
        this.observableMatricula.asignaturasDisponiblesPlan[i].inscrita = this.observableMatricula.asignaturasMatriculadas
          .map(x => x.materia.codigo)
          .includes(this.observableMatricula.asignaturasDisponiblesPlan[i].materia.codigo);
      }
      // Iteracion sobre bolsas de creditos electivos.
      for (let i = 0; i < this.observableMatricula.bolsasCreditosElectivos.length; i++) {
        let todasFacultades = this.observableMatricula.bolsasCreditosElectivos[i].asignaturasDisponibles.map(x =>
          this.createFilter(x.materia.facultad.nombre, x.materia.facultad.codigo)
        );

        // Obtencion de las facultades de las bolsas de creditos electivos.
        this.observableMatricula.bolsasCreditosElectivos[i].facultades = [];

        this.observableMatricula.bolsasCreditosElectivos[i].facultades.push(this.createFilter('TODAS LAS FACULTADES', null));
        // Iterando para simular un Distinct.
        for (let j = 0; j < todasFacultades.length; j++) {
          if (!this.observableMatricula.bolsasCreditosElectivos[i].facultades.find(x => x.value == todasFacultades[j].value)) {
            this.observableMatricula.bolsasCreditosElectivos[i].facultades.push(todasFacultades[j]);
          }
        }
        this.observableMatricula.bolsasCreditosElectivos[i].facultades.sort((a, b) => {
          if (a.label > b.label) return 1;
          if (a.label < b.label) return -1;
          return 0;
        });
        setTimeout(() => {
          // Iteracion sobre las asignaturas disponibles de la bolsa.
          for (let j = 0; j < this.observableMatricula.bolsasCreditosElectivos[i].asignaturasDisponibles.length; j++) {
            // Asignando como inscrita a las materias que estan en el arreglo asignaturasMatriculadas.
            this.observableMatricula.bolsasCreditosElectivos[i].asignaturasDisponibles[
              j
            ].inscrita = this.observableMatricula.asignaturasMatriculadas
              .map(x => x.materia.codigo)
              .includes(this.observableMatricula.bolsasCreditosElectivos[i].asignaturasDisponibles[j].materia.codigo);
          }
        }, 2000);
      }
    }
  }

  indicarCambioForzoso() {
    this.settedOferta = false;
  }

  createFilter(label: string, value: string): any {
    var myObject = { label: label, value: value };
    return myObject;
  }

  /**
   * Asigna la materia seleccionada a variable y muestra el Dialog.
   * @param materiaSeleccionada
   */
  mostrarDialog(materiaSeleccionada: MatriculaOferta) {
    this.materiaActual = materiaSeleccionada;
    this.display = true;
  }

  /**
   *
   * @param grupoSeleccionado
   */
  inscribirMateria(grupoSeleccionado: Grupo) {
    if (true) {
      // Si hay materia y grupo seleccionados.
      if (this.materiaActual && grupoSeleccionado) {
        //FIXME: Este || true se agrega porque solicitan que esta validacion no importe
        if (moment(new Date()).isBefore(grupoSeleccionado.fechaFinal) || true) {
          this.changeProgress(true);
          // Si la materia ya esta inscrita.
          if (this.observableMatricula.verificarInscrita(this.materiaActual)) {
            this.changeProgress(false);
            this.messageService.add({
              severity: 'info',
              summary: this.stringHelper.getResource('alr-inscrita-tit'),
              detail: ''
            });
          } else if (!this.observableMatricula.validarFechaPivote(grupoSeleccionado)) {
            this.changeProgress(false);
            this.messageService.add({
              severity: 'warn',
              summary: this.stringHelper.getResource('alr-error-fecha-pivote-tit'),
              detail: this.stringHelper.getResource('alr-error-fecha-pivote-det')
            });
          } else {
            this.inscribir(this.materiaActual, grupoSeleccionado);
            this.changeProgress(false);
          }
        } else {
          this.messageService.add({
            severity: 'warn',
            summary: this.stringHelper.getResource('alr-error-tiempo-tit'),
            detail: this.stringHelper.getResource('alr-error-tiempo-det')
          });
        }
      }
    }
    this.display = false;
  }

  /**
   *
   * @param materiaInscrita
   * @param grupoInscrito
   */
  public inscribir(materiaInscrita: MatriculaOferta, grupoInscrito: Grupo) {
    // {"c":"codigoEstudiante", "m":"codigoMateria", "n":"consecutivo", "b":"id_bolsa"}
    let consecutivo = '0';
    loop: for (let i = 0; i < this.observableMatricula.bolsasCreditosElectivos.length; i++) {
      let bolsa = this.observableMatricula.bolsasCreditosElectivos[i];
      for (let j = 0; j < bolsa.asignaturasDisponibles.length; j++) {
        if (bolsa.asignaturasDisponibles[j].materia.codigo === materiaInscrita.materia.codigo) {
          consecutivo = bolsa.id;
          break loop;
        }
      }
    }
    let p_arg = {
      c: this.generalService.codigoEstudiante,
      m: materiaInscrita.materia.codigo,
      n: grupoInscrito.id,
      b: consecutivo
    };
    this.generalService.inscribirMateria(p_arg).subscribe(
      response => {
        this.respuestaInscribir = response;
      },
      error => {
        this.changeProgress(false);
        this.messageService.add({
          severity: 'error',
          summary: this.stringHelper.getResource('alr-error-tit'),
          detail: error.error.mensaje
        });
      },
      () => {
        this.changeProgress(false);
        if (this.respuestaInscribir.status === 'ok') {
          // Si la respuesta es OK, se hacen los cambios necesarios en el front para evitar llamar
          // los servicios nuevamente.
          this.observableMatricula.inscribirAsignatura(materiaInscrita, grupoInscrito);
          this.messageService.add({
            severity: 'success',
            summary: this.stringHelper.getResource('alr-materia-agregada-tit'),
            detail: this.stringHelper.getResource('alr-materia-agregada-det')
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.stringHelper.getResource('alr-error-tit'),
            detail: this.stringHelper.getResource('alr-error-det') + this.respuestaInscribir.mensaje
          });
        }
      }
    );
  }

  changeProgress(progress: boolean) {
    this.showProgress.emit(progress);
  }

  onFacultadChange(event, dt) {
    dt.filter(event.value, 'materia.facultad.codigo', 'equals');
  }

  /**
   * @param rowData
   * @returns [0]='cursor', [1]='color(font)', [2]='font-weight'
   */
  colorRow(rowData: Grupo): string[] {
    var actualDate = new Date();
    if (
      moment(actualDate).isSameOrAfter(this.observableMatricula.estudiante.fecha_pivote) &&
      moment(actualDate).isSameOrBefore(this.observableMatricula.estudiante.fecha_fin) &&
      moment(rowData.fechaInicial).isSameOrAfter(this.observableMatricula.estudiante.fecha_pivote) &&
      moment(rowData.fechaInicial).isSameOrBefore(this.observableMatricula.estudiante.fecha_fin) &&
      moment(actualDate).isSameOrBefore(rowData.fechaFinal) &&
      rowData.fechaInicial &&
      rowData.fechaFinal
    ) {
      return ['pointer', '#000000', 'normal'];
    } else if (
      moment(actualDate).isBefore(this.observableMatricula.estudiante.fecha_pivote) &&
      moment(actualDate).isSameOrBefore(rowData.fechaFinal) &&
      rowData.fechaInicial &&
      rowData.fechaFinal
    ) {
      return ['pointer', '#000000', 'normal'];
    } else {
      return ['pointer', '#000000', 'normal'];
      //FIXME: Esto se agrega porque solicitan que esta validacion no importe
      // return ["not-allowed", "#93272c", "bold"];
    }
  }
}
