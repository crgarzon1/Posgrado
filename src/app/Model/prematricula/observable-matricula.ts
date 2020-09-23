import { GeneralService } from '../../Services/general.service';
import { MatriculaOferta, Grupo } from './matricula-oferta';
import { MatriculaEstudiante } from './matricula-estudiante';
import { BolsaCreditosElectivos } from './bolsa-creditos-electivos';
import moment from 'moment';

export class ObservableMatricula {
  static instance: ObservableMatricula;
  private observers: IObserverMatricula[];

  // Flags.
  public settedAsignaturasDisponiblesPlan: boolean;
  public settedBolsasCreditosElectivos: boolean;
  public settedAsignaturasMatriculadas: boolean;
  public settedMatriculaEstudiante: boolean;

  // Data.
  public asignaturasDisponiblesPlan: MatriculaOferta[] = [];
  public bolsasCreditosElectivos: BolsaCreditosElectivos[] = [];
  public asignaturasMatriculadas: MatriculaOferta[] = [];
  public estudiante: MatriculaEstudiante;

  /**
   * Constructor
   * @param generalService Servicio
   */
  private constructor(public generalService: GeneralService) {
    this.observers = [];
    this.refrescarEstudiante();
    this.refrescarAsignaturasDisponiblesPlan();
    this.refrescarBolsasCreditosElectivos();
    this.refrescarAsignaturasMatriculadas();
  }

  public refrescarPeticiones() {
    this.informarRefrescoForzoso();
    this.settedAsignaturasDisponiblesPlan = false;
    this.settedBolsasCreditosElectivos = false;
    this.settedAsignaturasMatriculadas = false;
    this.settedMatriculaEstudiante = false;
    this.asignaturasDisponiblesPlan = [];
    this.bolsasCreditosElectivos = [];
    this.asignaturasMatriculadas = [];
    this.estudiante = new MatriculaEstudiante();
    this.refrescarEstudiante();
    this.refrescarAsignaturasDisponiblesPlan();
    this.refrescarBolsasCreditosElectivos();
    this.refrescarAsignaturasMatriculadas();
  }

  informarRefrescoForzoso() {
    this.observers.forEach(function (observer) {
      observer.indicarCambioForzoso();
    });
  }

  /**
   * Obtener instancia unica (Singleton).
   * @param generalService Servicio
   */
  public static getInstance(generalService: GeneralService): ObservableMatricula {
    if (ObservableMatricula.instance == undefined) {
      ObservableMatricula.instance = new ObservableMatricula(generalService);
    }
    return ObservableMatricula.instance;
  }

  /**
   * Agregar Observer.
   * @param observer Observador
   */
  public addObserver(observer: IObserverMatricula) {
    this.observers.push(observer);
    this.informarObservers();
  }

  /**
   * Informar Observers.
   */
  private informarObservers() {
    this.observers.forEach(function (observer) {
      observer.refrescarDatos();
    });
  }

  private refrescarAsignaturasDisponiblesPlan() {
    if (!this.settedAsignaturasDisponiblesPlan) {
      this.generalService.getOfertaMatricula().subscribe(
        response => {
          this.settedAsignaturasDisponiblesPlan = true;
          this.asignaturasDisponiblesPlan = response;
          this.asignaturasDisponiblesPlan.map(asign => (asign.bolsa = 0));
        },
        error => {},
        () => {
          this.informarObservers();
        }
      );
    } else {
      this.informarObservers();
    }
  }

  private refrescarAsignaturasMatriculadas() {
    if (!this.settedAsignaturasMatriculadas) {
      this.generalService.getMatricula().subscribe(
        response => {
          this.settedAsignaturasMatriculadas = true;
          this.asignaturasMatriculadas = response;
        },
        error => {},
        () => {
          this.informarObservers();
        }
      );
    } else {
      this.informarObservers();
    }
  }

  private refrescarBolsasCreditosElectivos() {
    if (!this.settedBolsasCreditosElectivos) {
      this.generalService.getBolsaCreditosElectivos().subscribe(
        response => {
          this.settedBolsasCreditosElectivos = true;
          this.bolsasCreditosElectivos = response;
          this.bolsasCreditosElectivos.forEach(x => x.asignaturasDisponibles.forEach(y => (y.bolsa = +x.id)));
        },
        error => {},
        () => {
          this.informarObservers();
        }
      );
    } else {
      this.informarObservers();
    }
  }

  private refrescarEstudiante() {
    if (!this.settedMatriculaEstudiante) {
      this.generalService.getEstudianteMatricula().subscribe(
        response => {
          this.settedMatriculaEstudiante = true;
          this.estudiante = response;
        },
        error => {},
        () => {
          this.informarObservers();
          if (this.estudiante.matricula === undefined) {
            this.estudiante.matricula = null;
          }
        }
      );
    } else {
      this.informarObservers();
    }
  }

  public validarDisponibilidadCreditos(materiaInscrita: MatriculaOferta): boolean {
    let maximos = this.estudiante.creditos_maximos;
    let inscrito = this.estudiante.creditos_inscritos + parseInt(materiaInscrita.materia.creditos);
    // Verificar si hay creditos disponibles.
    return maximos >= inscrito;
  }

  public verificarInscrita(materiaInscrita: MatriculaOferta) {
    if (this.asignaturasMatriculadas.filter(x => x.materia.codigo == materiaInscrita.materia.codigo).length > 0) {
      return true;
    }
    return false;
  }

  public validarFechaPivote(grupo: Grupo): boolean {
    const actualDate = new Date();
    if (
      moment(actualDate).isSameOrAfter(this.estudiante.fecha_pivote) &&
      moment(actualDate).isSameOrBefore(this.estudiante.fecha_fin) &&
      moment(grupo.fechaInicial).isSameOrAfter(this.estudiante.fecha_pivote) &&
      moment(grupo.fechaInicial).isSameOrBefore(this.estudiante.fecha_fin) &&
      moment(actualDate).isSameOrBefore(grupo.fechaFinal) &&
      grupo.fechaInicial &&
      grupo.fechaFinal
    ) {
      return true;
    } else if (
      moment(actualDate).isBefore(this.estudiante.fecha_pivote) &&
      moment(actualDate).isSameOrBefore(grupo.fechaFinal) &&
      grupo.fechaInicial &&
      grupo.fechaFinal
    ) {
      return true;
    } else {
      return true; // FIXME: Esto se agrega porque solicitan que esta validacion no importe
    }
  }

  public inscribirAsignatura(materiaInscrita: MatriculaOferta, grupoInscrito: Grupo) {
    if (this.asignaturasMatriculadas.filter(x => x.materia.codigo == materiaInscrita.materia.codigo).length <= 0) {
      // Agregamos la materia si no existe.
      let materiaResultante = new MatriculaOferta();
      materiaResultante.materia = materiaInscrita.materia;
      materiaResultante.bolsa = materiaInscrita.bolsa;
      this.asignaturasMatriculadas.push(materiaResultante);
    }
    // Inicializamos el arreglo de grupos si es nulo.
    if (!this.asignaturasMatriculadas.find(x => x.materia.codigo == materiaInscrita.materia.codigo).grupos) {
      this.asignaturasMatriculadas.find(x => x.materia.codigo == materiaInscrita.materia.codigo).grupos = [];
    }
    // Agregamos el grupo si no existe ya.
    if (
      this.asignaturasMatriculadas
        .find(x => x.materia.codigo == materiaInscrita.materia.codigo)
        .grupos.filter(x => x.grupo == grupoInscrito.grupo).length <= 0
    ) {
      this.asignaturasMatriculadas.find(x => x.materia.codigo == materiaInscrita.materia.codigo).grupos.push(grupoInscrito);
      this.estudiante.creditos_inscritos += parseInt(materiaInscrita.materia.creditos);
    }
    // Ponemos la asignatura como inscrita.
    this.cambiarEstadoInscripcion(materiaInscrita.materia.codigo, true);
  }

  public cancelarInscripcion(materiaCancelada: MatriculaOferta, grupoCancelado: Grupo) {
    // Hacer llamado utilizando la estrucutura de eliminación
    // La bolsa sale de la iteración de las bolsas
    // Verificamos que el grupo y la materia exista.
    if (
      this.asignaturasMatriculadas
        .find(x => x.materia.codigo == materiaCancelada.materia.codigo)
        .grupos.filter(x => x.grupo == grupoCancelado.grupo).length > 0
    ) {
      // Si es el unico grupo removemos la materia.
      if (this.asignaturasMatriculadas.find(x => x.materia.codigo == materiaCancelada.materia.codigo).grupos.length == 1) {
        this.asignaturasMatriculadas = this.asignaturasMatriculadas.filter(
          x => x.materia.codigo != materiaCancelada.materia.codigo
        );
      } else {
        // Si existen multiples grupos removemos el grupo.
        this.asignaturasMatriculadas.find(
          x => x.materia.codigo == materiaCancelada.materia.codigo
        ).grupos = this.asignaturasMatriculadas
          .find(x => x.materia.codigo == materiaCancelada.materia.codigo)
          .grupos.filter(x => x.grupo != grupoCancelado.grupo);
      }
    }
    this.cambiarEstadoInscripcion(materiaCancelada.materia.codigo, false);
    this.estudiante.creditos_inscritos -= parseInt(materiaCancelada.materia.creditos);
  }

  public cambiarEstadoInscripcion(codigoMateria: string, estado: boolean) {
    // Cambiando de estado las asignaturas del plan.
    for (let i = 0; i < this.asignaturasDisponiblesPlan.length; i++) {
      if (this.asignaturasDisponiblesPlan[i].materia.codigo == codigoMateria) {
        this.asignaturasDisponiblesPlan[i].inscrita = estado;
      }
    }
    // Cambiando de estado las asignaturas de las bolsas electivas.
    for (let i = 0; i < this.bolsasCreditosElectivos.length; i++) {
      for (let j = 0; j < this.bolsasCreditosElectivos[i].asignaturasDisponibles.length; j++) {
        if (this.bolsasCreditosElectivos[i].asignaturasDisponibles[j].materia.codigo == codigoMateria) {
          this.bolsasCreditosElectivos[i].asignaturasDisponibles[j].inscrita = estado;
        }
      }
    }
  }
}

export interface IObserverMatricula {
  refrescarDatos();
  indicarCambioForzoso();
}
