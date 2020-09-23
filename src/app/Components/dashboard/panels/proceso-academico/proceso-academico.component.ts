import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { GeneralService } from 'src/app/Services/general.service';
import { DataSource, IDataSourceObserver, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';

@Component({
  selector: 'app-proceso-academico',
  templateUrl: './proceso-academico.component.html',
  styleUrls: ['./proceso-academico.component.scss']
})
export class ProcesoAcademicoComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  dataSource: DataSource;
  stringHelper: StringResourceHelper;
  data: any;
  options: any;
  display: boolean = false;
  blocked: boolean = false;

  tablaTitulos: string[] = [];
  tablaValores: any = [];
  porcentajeCompletitud: number = 0;

  constructor(public generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-proceso-academico');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  ngOnInit() {}

  showDialog() {
    this.display = true;
  }

  getEstado(index: number): string {
    switch (index) {
      case 1:
        return this.stringHelper.getResource('tbl-aprobada');
      case 2:
        return this.stringHelper.getResource('tbl-cursando');
      case 3:
        return this.stringHelper.getResource('tbl-pendiente');
    }
  }

  refrescarDatos() {
    if (
      this.dataSource.historialAcademico &&
      this.dataSource.historialAcademico.ciclos &&
      this.dataSource.procesoAcademico &&
      this.dataSource.procesoAcademico.plan &&
      this.dataSource.prematricula &&
      this.cambioDetectado(this.dataSource)
    ) {
      this.porcentajeCompletitud = this.dataSource.historialAcademico.porcentajeCompletitud;
      this.refrescarTabla();
      this.refrescarChart();
      setTimeout(() => {
        this.blocked = false;
      }, 250);
      this.cambioExitoso(this.dataSource);
    }
  }

  refrescarTabla() {
    this.tablaTitulos = this.dataSource.procesoAcademico.plan.map(x => x.semestreValorOrdinal);
    this.obtenerMateriasPivoteadasPorSemestre();
  }

  obtenerMateriasPivoteadasPorSemestre() {
    let maximoMaterias = this.dataSource.procesoAcademico.maximoAsignaturasPorSemestre;
    let materiasSemestre = [];
    let cicloAuxiliar;
    this.tablaValores = [];
    this.tablaTitulos = this.dataSource.procesoAcademico.plan.map(x => x.semestreValorOrdinal);

    for (let i = 0; i < maximoMaterias; i++) {
      materiasSemestre = [];
      for (let j = 0; j < this.dataSource.procesoAcademico.plan.length; j++) {
        cicloAuxiliar = this.dataSource.procesoAcademico.plan[j];
        if (i < cicloAuxiliar.materias.length) {
          materiasSemestre.push(this.dataSource.procesoAcademico.plan[j].materias[i]);
        } else {
          materiasSemestre.push(null);
        }
      }
      this.tablaValores.push(materiasSemestre);
    }
  }

  refrescarChart() {
    this.data = {
      ciclos: [this.stringHelper.getResource('chr-inicio')].concat(
        this.dataSource.historialAcademico.ciclos.map(x => x.anno + '-' + x.cicloreal)
      ),
      labels: [this.stringHelper.getResource('chr-inicio')].concat(
        this.dataSource.historialAcademico.ciclos.map(x => this.dataSource.traducirAnnoCiclo(x.anno, x.cicloreal))
      ),
      datasets: [
        {
          lineTension: 0,
          label: this.stringHelper.getResource('header-titulo'),
          data: [0].concat(this.dataSource.historialAcademico.ciclos.map(x => x.porcentajeCompletitud)),
          fill: false,
          borderColor: '#565656'
        }
      ]
    };
    this.options = {
      legend: {
        display: false
      },
      scales: {
        yAxes: [
          {
            display: true,
            ticks: {
              beginAtZero: true,
              stepSize: 25,
              suggestedMax: 100
            }
          }
        ]
      },
      tooltips: {
        enabled: true,
        mode: 'single',
        callbacks: {
          label: function (tooltipItems, data) {
            return data.ciclos[tooltipItems.index] + ': ' + tooltipItems.yLabel + '%';
          },
          title: function (tooltipItems, data) {
            return '';
          }
        }
      },
      plugins: {
        datalabels: {
          display: false
        }
      }
    };
  }
}
