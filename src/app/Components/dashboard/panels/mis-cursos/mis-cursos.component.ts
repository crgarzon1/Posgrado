import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { DataSource, IDataSourceObserver, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';

@Component({
  selector: 'app-mis-cursos',
  templateUrl: './mis-cursos.component.html',
  styleUrls: ['./mis-cursos.component.scss'],
  encapsulation: ViewEncapsulation.None
  //providers: [ConfirmationService]
})
export class MisCursosComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  public dataSource: DataSource;
  public stringHelper: StringResourceHelper;
  public materias: any[] = [];
  public settedInformacion: boolean = false;
  public displayMateriasInscritas: boolean = false;

  public displayDialog: boolean = false;
  public fullHorario: any[] = [];
  public miniHorario: any[] = [];
  public url: string;
  public openSyllabusBool: boolean;

  public blocked: boolean = false;

  constructor(private generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-mis-cursos');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);

    if (
      this.dataSource.prematricula &&
      this.dataSource.prematricula.materias &&
      this.dataSource.prematricula.materias.length > 0
    ) {
      setTimeout(() => {
        this.blocked = false;
      }, 0);
    } else {
      setTimeout(() => {
        this.blocked = true;
      }, 0);
    }
    this.fillPreMiniHorario();
  }

  refrescarDatos() {
    if (
      this.dataSource.prematricula &&
      this.dataSource.prematricula.materias &&
      this.dataSource.prematricula.materias.length > 0 &&
      this.cambioDetectado(this.dataSource)
    ) {
      this.settedInformacion = true;
      this.materias = [];
      this.fullHorario = [];
      this.miniHorario = [];
      this.fillPreMiniHorario();

      this.dataSource.prematricula.materias.map(materia => {
        this.materias.push({
          nombre: materia.nombreMateria,
          codigo: materia.codMateria,
          creditos: materia.creditos,
          docente: materia.docente,
          horario: this.fillHorario(
            materia.grupos[0].horario,
            materia.grupos[0].facultadCursar ? materia.grupos[0].facultadCursar.sede.sede : ''
          ),
          syllabus: materia.grupos[0].materiaCursar.syllabus,
          semestre: materia.semestre,
          intensidadHoraria: materia.intencidadHoraria,
          sede: materia.grupos[0].facultadCursar ? materia.grupos[0].facultadCursar.sede.sede : '',
          facCursar: materia.grupos[0].facultadCursar ? materia.grupos[0].facultadCursar.nombreFacultad : '',
          codMateriaCursar: materia.grupos[0].materiaCursar ? materia.grupos[0].materiaCursar.codMateria : '',
          materiaCursar: materia.grupos[0].materiaCursar ? materia.grupos[0].materiaCursar.nombreMateria : '',
          grupo: materia.grupos[0].grupo,
          tiempoHorario: this.tiempoHorario(materia.grupos[0].horario)
        });
        this.fillMiniHorario(materia.grupos[0].horario, materia.nombreMateria);
        this.fillFullHorario(materia.grupos[0].horario, materia.nombreMateria);
      });
      setTimeout(() => {
        this.blocked = false;
      }, 0);
      this.cambioExitoso(this.dataSource);
    }
  }

  tiempoHorario(horario: any[]): any {
    var arrHorario = { lun: '', mar: '', mie: '', jue: '', vie: '', sab: '' };
    if (horario && horario.length > 0) {
      for (var i = 0; i < horario.length; i++) {
        let horaInicio = horario[i].hora[0].inicio.split(':')[0];
        let horaFin = horario[i].hora[0].fin.split(':')[0];
        arrHorario = {
          lun: horario[i].idDia === 0 ? horaInicio + '-' + horaFin : arrHorario.lun,
          mar: horario[i].idDia === 1 ? horaInicio + '-' + horaFin : arrHorario.mar,
          mie: horario[i].idDia === 2 ? horaInicio + '-' + horaFin : arrHorario.mie,
          jue: horario[i].idDia === 3 ? horaInicio + '-' + horaFin : arrHorario.jue,
          vie: horario[i].idDia === 4 ? horaInicio + '-' + horaFin : arrHorario.vie,
          sab: horario[i].idDia === 5 ? horaInicio + '-' + horaFin : arrHorario.sab
        };
      }
    }
    return arrHorario;
  }

  fillMiniHorario(horario: any[], nombreMateria: string) {
    if (horario && horario.length > 0) {
      horario.map(hor => {
        this.miniHorario[hor.idDia].dia = hor.dia;
        this.miniHorario[hor.idDia].materias.push({
          nombre: nombreMateria,
          inicio: hor.hora[0].inicio,
          fin: hor.hora[0].fin
        });
      });
    }
  }

  fillHorario(horario: any[], sede: string) {
    var currentDay = new Date().getDay() - 1;
    var horarios: any[] = [];
    if (horario && horario.length > 0) {
      horario.map(hor => {
        if (hor.idDia === currentDay || hor.idDia === currentDay + 1) {
          horarios.push({
            horario: hor.dia + ', Inicio: ' + hor.hora[0].inicio + ' Fin: ' + hor.hora[0].fin,
            salon: hor.hora[0].salon,
            sede: sede
          });
        }
      });
    }

    return horarios;
  }

  showDialog() {
    this.displayDialog = true;
  }

  fillFullHorario(horario: any[], materia: string) {
    if (horario && horario.length > 0) {
      for (var i = 7; i <= 21; i++) {
        var horaIndex = (i + '').length === 1 ? '0' + i + ':00' : i + ':00';
        var horas = this.fullHorario.find(horasAux => horasAux.hora === horaIndex);
        if (horas === undefined) {
          this.fullHorario[i - 7] = {
            hora: horaIndex,
            lunes: null,
            martes: null,
            miercoles: null,
            jueves: null,
            viernes: null,
            sabado: null
          };
        }

        horario.map(hor => {
          var dia = +hor.idDia;
          var hora = +hor.hora[0].inicio.substring(0, 2);
          var tiempo = Math.abs(hora - +hor.hora[0].fin.substring(0, 2));
          if (tiempo > 0 && hora === i) {
            this.fullHorario[i - 7].hora = this.fullHorario[i - 7].hora;
            this.fullHorario[i - 7].lunes = dia === 0 ? materia : this.fullHorario[i - 7].lunes;
            this.fullHorario[i - 7].martes = dia === 1 ? materia : this.fullHorario[i - 7].martes;
            this.fullHorario[i - 7].miercoles = dia === 2 ? materia : this.fullHorario[i - 7].miercoles;
            this.fullHorario[i - 7].jueves = dia === 3 ? materia : this.fullHorario[i - 7].jueves;
            this.fullHorario[i - 7].viernes = dia === 4 ? materia : this.fullHorario[i - 7].viernes;
            this.fullHorario[i - 7].sabado = dia === 5 ? materia : this.fullHorario[i - 7].sabado;
            hor.hora[0].inicio = this.sumHoraInicio(hor.hora[0].inicio);
          }
        });
      }
    }
  }

  sumHoraInicio(hora: string) {
    var rTime = +hora.substring(0, 2);
    if (rTime < 9) return '0' + (rTime + 1) + ':00';
    else return rTime + 1 + ':00';
  }

  fillPreMiniHorario() {
    for (var i = 0; i < 6; i++) {
      this.miniHorario.push({
        idDia: i,
        dia: null,
        materias: []
      });
    }
  }

  abrirMateriasInscritas() {
    this.displayMateriasInscritas = true;
  }

  openSyllabus(mat) {
    this.url = mat.syllabus;
    this.openSyllabusBool = true;
  }

  ngOnInit(): void {}
}
