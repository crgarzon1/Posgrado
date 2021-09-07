import { HistorialAcademico } from './historial-academico';
import { StringResourceHelper } from '../util/string-resource-helper';
import { ProcesoAcademico } from './proceso-academico';
import { GeneralService } from '../../Services/general.service';
import { PrematriculaEstudiante } from './prematricula-estudiante';
import { Estudiante } from './estudiante';
import { Pendientes } from './pendientes';
import { Generalidades } from './generalidades';
import { stringify } from 'querystring';

export class DataSource {
  static instance: DataSource;
  estudiante: Estudiante = undefined;
  historialAcademico: HistorialAcademico = undefined;
  procesoAcademico: ProcesoAcademico = undefined;
  prematricula: PrematriculaEstudiante = undefined;
  pendientes: Pendientes = undefined;
  generalidades: Generalidades = undefined;
  private observers: IDataSourceObserver[];

  private constructor(public generalService: GeneralService) {
    this.observers = [];
  }

  public static getInstance(generalService: GeneralService): DataSource {
    if (DataSource.instance == undefined) {
      DataSource.instance = new DataSource(generalService);
    }
    return DataSource.instance;
  }

  addObserver(observer: IDataSourceObserver) {
    this.observers.push(observer);
    this.informarObservers();
  }

  informarObservers() {
    this.observers.forEach(function (observer) {
      observer.refrescarDatos();
    });
  }

  public setCodigoEstudianteCookie() {
    this.obtenerDatos(1);
  }

  public setCodigoEstudiante(codigoEstudiante: string) {
    this.generalService.setCodigoEstudiante(codigoEstudiante);
    this.obtenerDatos(1);
  }

  public getCodigoEstudiante(): string {
    return this.generalService.getCodigoEstudianteService();
  }

  private reiniciarDatos() {
    this.estudiante = undefined;
    this.historialAcademico = undefined;
    this.procesoAcademico = undefined;
    this.prematricula = undefined;
    this.pendientes = undefined;
    this.generalidades = undefined;
  }

  private obtenerDatos(indice: number) {
    switch (indice) {
      case 1: {
        this.reiniciarDatos();
        this.generalService.getEstudiante().subscribe(
          result => {
            this.estudiante = result;
          },
          error => {
            this.estudiante = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
      case 2: {
        this.generalService.getPendientes().subscribe(
          result => {
            this.pendientes = result;
          },
          error => {
            this.pendientes = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
      case 3: {
        this.generalService.getHistorialAcademico().subscribe(
          result => {
            this.historialAcademico = result;
            this.sumarCreditosDeBolsa();
            this.definirEstadoMateriasEnHistorial();
            this.actualizarCreditosCursadosPorSemestre();
          },
          error => {
            this.historialAcademico = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
      case 4: {
        this.generalService.getPlanDeEstudios().subscribe(
          result => {
            this.procesoAcademico = result;
            this.calcularNumeroAsignaturasPlan();
            this.calcularPorcentajesDeCompletitud();
          },
          error => {
            this.procesoAcademico = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
      case 5: {
        this.generalService.getPrematricula().subscribe(
          result => {
            this.prematricula = result;
            this.definirEstadoMateriasEnPlan();
            this.setMateriasPendientes();
            this.setCreditosBolsaPendientes();
          },
          error => {
            this.prematricula = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
      case 6: {
        this.generalService.getGeneralidadesEstudiante().subscribe(
          result => {
            this.generalidades = result;
          },
          error => {
            this.generalidades = undefined;
          },
          () => {
            this.informarObservers();
            this.obtenerDatos(indice + 1);
          }
        );
        break;
      }
    }
  }

  private sumarCreditosDeBolsa() {
    if (this.historialAcademico) {
      for (let i = 0; i < this.historialAcademico.bolsasDeCreditos.length; i++) {
        this.historialAcademico.bolsasDeCreditos[i].creditosAprobados = 0;
        this.historialAcademico.bolsasDeCreditos[i].materias.map(x => {
          if (x.creditos && parseInt(x.nota) >= 3.5) {
            this.historialAcademico.bolsasDeCreditos[i].creditosAprobados += x.creditos;
          }
        });
      }
    }
  }

  private calcularNumeroAsignaturasPlan() {
    this.procesoAcademico.totalAsignaturasPlan = 0;
    this.procesoAcademico.maximoAsignaturasPorSemestre = 0;
    if (this.procesoAcademico) {
      for (let i = 0; i < this.procesoAcademico.plan.length; i++) {
        this.procesoAcademico.totalAsignaturasPlan += this.procesoAcademico.plan[i].materias.length;
        if (this.procesoAcademico.plan[i].materias.length > this.procesoAcademico.maximoAsignaturasPorSemestre) {
          this.procesoAcademico.maximoAsignaturasPorSemestre = this.procesoAcademico.plan[i].materias.length;
        }
      }
    }
  }

  private calcularPorcentajesDeCompletitud() {
    let porcentajeCompletitud = 0;
    let materiasAprobadasPorSemestre = 0;
    let cicloAuxiliar;
    if (this.procesoAcademico && this.historialAcademico) {
      for (let i = 0; i < this.historialAcademico.ciclos.length; i++) {
        cicloAuxiliar = this.historialAcademico.ciclos[i];
        materiasAprobadasPorSemestre = 0;
        for (let j = 0; j < cicloAuxiliar.materias.length; j++) {
          if (parseFloat(cicloAuxiliar.materias[j].nota) >= 3.5) {
            materiasAprobadasPorSemestre++;
          }
        }
        porcentajeCompletitud += (materiasAprobadasPorSemestre / this.procesoAcademico.totalAsignaturasPlan) * 100;
        this.historialAcademico.ciclos[i].porcentajeCompletitud = parseFloat(porcentajeCompletitud.toFixed(2));
      }
      this.historialAcademico.porcentajeCompletitud = parseInt(parseFloat(porcentajeCompletitud.toFixed(2)).toString());
    }
  }

  private definirEstadoMateriasEnHistorial() {
    if (this.historialAcademico) {
      this.historialAcademico.materiasAprobadas = [];
      for (let i = 0; i < this.historialAcademico.ciclos.length; i++) {
        for (let j = 0; j < this.historialAcademico.ciclos[i].materias.length; j++) {
          if (this.historialAcademico.ciclos[i].materias[j].nota >= 3.5) {
            this.historialAcademico.materiasAprobadas.push(this.historialAcademico.ciclos[i].materias[j]);
          }
        }
      }
    }
  }

  private actualizarCreditosCursadosPorSemestre() {
    if (this.historialAcademico) {
      let acumulado = 0;
      let counter = 0;

      for (let i = 0; i < this.historialAcademico.ciclos.length; i++) {
        if (
          this.historialAcademico.ciclos[i].cicloreal == 'PRIMER PERIODO' ||
          this.historialAcademico.ciclos[i].cicloreal == 'SEGUNDO PERIODO'
        ) {
          counter++;
          this.historialAcademico.ciclos[i].sumatoriaCreditosCursados = 0;
          this.historialAcademico.ciclos[i].sumatoriaCreditosAprobados = 0;
          acumulado += parseFloat(this.historialAcademico.ciclos[i].promedio);
          for (let j = 0; j < this.historialAcademico.ciclos[i].materias.length; j++) {
            this.historialAcademico.ciclos[i].sumatoriaCreditosCursados += parseInt(
              this.historialAcademico.ciclos[i].materias[j].creditos
            );
            if (this.historialAcademico.ciclos[i].materias[j].nota >= 3.5) {
              this.historialAcademico.ciclos[i].sumatoriaCreditosAprobados += parseInt(
                this.historialAcademico.ciclos[i].materias[j].creditos
              );
            }
            this.historialAcademico.ciclos[i].promedioAcumulado = parseFloat((acumulado / counter).toFixed(2));
          }
        }
      }
    }
  }

  private definirEstadoMateriasEnPlan() {
    if (this.procesoAcademico && this.historialAcademico && this.prematricula) {
      let materiasAprobadas = this.historialAcademico.materiasAprobadas;
      let materiasCursando = this.prematricula.materias.map(x => x.codMateria);
      let cicloAuxiliar;

      for (let j = 0; j < this.procesoAcademico.plan.length; j++) {
        cicloAuxiliar = this.procesoAcademico.plan[j];
        for (let i = 0; i < cicloAuxiliar.materias.length; i++) {
          if (materiasAprobadas.map(x => x.codigo).includes(cicloAuxiliar.materias[i].codigo)) {
            this.procesoAcademico.plan[j].materias[i].estado = 1;
            this.procesoAcademico.plan[j].materias[i].nota = materiasAprobadas.find(
              x => x.codigo == cicloAuxiliar.materias[i].codigo
            ).nota;
          } else if (materiasCursando.includes(cicloAuxiliar.materias[i].codigo)) {
            this.procesoAcademico.plan[j].materias[i].estado = 2;
          } else {
            this.procesoAcademico.plan[j].materias[i].estado = 3;
          }
          var re = /[&\/\\#,+()$~%.'":*?<>{}]/g;
          this.procesoAcademico.plan[j].materias[i].nombre = this.procesoAcademico.plan[j].materias[i].nombre.replace(re, '. ');
        }
      }
    }
  }

  private setMateriasPendientes() {
    this.pendientes.materias = 0;
    this.procesoAcademico.plan.map(pl =>
      pl.materias.map(mat => {
        if (mat.estado != 1) this.pendientes.materias++;
      })
    );
  }

  private setCreditosBolsaPendientes() {
    this.pendientes.bolsas = 0;
    this.historialAcademico.bolsasDeCreditos.map(bolsas => {
      if (bolsas.creditosAprobados != bolsas.tope) this.pendientes.bolsas++;
    });
  }

  traducirAnnoCiclo(anno: string, cicloReal: string): string {
    let returnable = '';
    switch (cicloReal) {
      case 'PRIMER PERIODO': {
        returnable = anno + '-01';
        break;
      }
      case 'SEGUNDO PERIODO': {
        returnable = anno + '-02';
        break;
      }
      default: {
        returnable = anno + '-' + cicloReal.substring(0, 3) + '...';
        break;
      }
    }
    return returnable;
  }
}

export class DataSourceChangeIdentifier {
  private ultimoCodigo: string = undefined;

  protected cambioDetectado(dataSource: DataSource): boolean {
    return !this.ultimoCodigo || this.ultimoCodigo != dataSource.getCodigoEstudiante();
  }

  protected cambioExitoso(dataSource: DataSource) {
    this.ultimoCodigo = dataSource.getCodigoEstudiante();
  }
}

export interface IDataSourceObserver {
  refrescarDatos();
}
