import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { GeneralService } from 'src/app/Services/general.service';
import { Generalidades } from 'src/app/Model/dashboard/generalidades';
import { HistorialAcademico } from 'src/app/Model/dashboard/historial-academico';
import { DataSource, IDataSourceObserver, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';

@Component({
  selector: 'app-historial-academico',
  templateUrl: './historial-academico.component.html',
  styleUrls: ['./historial-academico.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class HistorialAcademicoComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  public dataSource: DataSource;
  public stringHelper: StringResourceHelper;
  public settedInformacion: boolean = false;
  public data: any;
  public options: any;
  public display: boolean = false;
  public blocked: boolean = false;

  constructor(public generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-historial-academico');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  indicarCambioForzoso() {
    this.settedInformacion = false;
  }

  showDialog() {
    this.display = true;
  }

  refrescarDatos() {
    if (
      this.dataSource.historialAcademico &&
      this.dataSource.historialAcademico.ciclos &&
      this.dataSource.historialAcademico.ciclos.length > 0 &&
      this.cambioDetectado(this.dataSource)
    ) {
      this.refrescarChart();

      setTimeout(() => {
        this.blocked = false;
      }, 150);
      this.cambioExitoso(this.dataSource);
    }
  }

  refrescarChart() {
    let promedios = [];
    let periodos = [];

    for (let i = 0; i < this.dataSource.historialAcademico.ciclos.length; i++) {
      promedios.push(this.dataSource.historialAcademico.ciclos[i].promedio);
      periodos.push(
        this.dataSource.traducirAnnoCiclo(
          this.dataSource.historialAcademico.ciclos[i].anno,
          this.dataSource.historialAcademico.ciclos[i].cicloreal
        )
      );
    }
    this.data = {
      ciclos: this.dataSource.historialAcademico.ciclos.map(x => x.anno + '-' + x.cicloreal),
      labels: periodos,
      datasets: [
        {
          label: this.stringHelper.getResource('header-titulo'),
          backgroundColor: '#42A5F5',
          borderColor: '#1E88E5',
          data: promedios
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
              stepSize: 1,
              suggestedMax: 5
            }
          }
        ]
      },
      tooltips: {
        enabled: true,
        mode: 'single',
        callbacks: {
          label: function (tooltipItems, data) {
            return data.ciclos[tooltipItems.index] + ': ' + tooltipItems.yLabel;
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

  ngOnInit() {}
}
