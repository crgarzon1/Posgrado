import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { GeneralService } from 'src/app/Services/general.service';
import { Generalidades } from 'src/app/Model/dashboard/generalidades';
import { Chart } from 'chart.js';
import { IDataSourceObserver, DataSource, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';
import 'chartjs-plugin-datalabels';

@Component({
  selector: 'app-mis-asignaturas',
  templateUrl: './mis-asignaturas.component.html',
  styleUrls: ['./mis-asignaturas.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class MisAsignaturasComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  dataSource: DataSource;
  stringHelper: StringResourceHelper;
  mostrarMaterias: boolean;
  chartData: any;
  options: any;
  blocked: boolean = false;
  labelTotal: string = '';

  constructor(public generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-mis-asignaturas');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  ngOnInit() {
    this.mostrarMaterias = true;
  }

  refrescarDatos() {
    if (this.dataSource.generalidades && this.cambioDetectado(this.dataSource)) {
      this.refrescarChart();
      setTimeout(() => {
        this.blocked = false;
      }, 0);
      this.cambioExitoso(this.dataSource);
      this.labelTotal = 'Total Materias: ' + this.dataSource.generalidades.totalMateriasPlan;
    }
  }

  cambiarTipoDatoChart() {
    this.mostrarMaterias = !this.mostrarMaterias;
    this.refrescarChart();
    this.labelTotal = this.mostrarMaterias
      ? 'Total Materias: ' + this.dataSource.generalidades.totalMateriasPlan
      : 'Total Créditos: ' + this.dataSource.generalidades.creditosPlan;
  }

  refrescarChart() {
    let labels = [];
    let data = [];
    let colors = ['#36A2EB', '#FFCE56', '#FF6384'];
    if (this.dataSource.generalidades.totalMateriasPlan > 0 && this.dataSource.generalidades.creditosPlan > 0) {
      if (this.mostrarMaterias) {
        labels.push(this.stringHelper.getResource('lbl-materias-aprobadas'));
        labels.push(this.stringHelper.getResource('lbl-materias-cursando'));
        labels.push(this.stringHelper.getResource('lbl-materias-faltantes'));
        data.push(this.dataSource.generalidades.materiasAprobadas);
        data.push(this.dataSource.generalidades.materiasCursando);
        data.push(
          this.dataSource.generalidades.materiasFaltantes - this.dataSource.generalidades.materiasCursando < 0
            ? 0
            : this.dataSource.generalidades.materiasFaltantes - this.dataSource.generalidades.materiasCursando
        );
      } else {
        labels.push(this.stringHelper.getResource('lbl-creditos-aprobadas'));
        labels.push(this.stringHelper.getResource('lbl-creditos-cursando'));
        labels.push(this.stringHelper.getResource('lbl-creditos-faltantes'));
        data.push(this.dataSource.generalidades.creditosAprobados);
        data.push(this.dataSource.generalidades.creditosCursando);
        data.push(
          this.dataSource.generalidades.creditosFaltantes - this.dataSource.generalidades.creditosCursando < 0
            ? 0
            : this.dataSource.generalidades.creditosFaltantes - this.dataSource.generalidades.creditosCursando
        );
      }

      this.chartData = {
        labels: labels,
        datasets: [
          {
            data: data,
            backgroundColor: colors,
            hoverBackgroundColor: colors
          }
        ]
      };

      this.options = {
        plugins: {
          datalabels: {
            formatter: (value, ctx) => {
              if (value <= 0) return '';
              let sum = 0;
              let dataArr = ctx.chart.data.datasets[0].data;
              dataArr.map(data => {
                sum += data;
              });
              let percentage = ((value * 100) / sum).toFixed(2) + '%';
              return percentage;
            },
            font: {
              weight: 'bold'
            }
          }
        }
      };
    }
  }
}
