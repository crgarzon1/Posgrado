import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { IDataSourceObserver, DataSource, DataSourceChangeIdentifier } from 'src/app/Model/dashboard/data-source';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';

@Component({
  selector: 'app-mis-notas',
  templateUrl: './mis-notas.component.html',
  styleUrls: ['./mis-notas.component.scss']
})
export class MisNotasComponent extends DataSourceChangeIdentifier implements OnInit, IDataSourceObserver {
  dataSource: DataSource;
  stringHelper: StringResourceHelper;
  data: any;
  options: any;
  blocked: boolean = false;

  constructor(private generalService: GeneralService) {
    super();
    this.stringHelper = new StringResourceHelper('panel-mis-notas');
    this.dataSource = DataSource.getInstance(generalService);
    this.dataSource.addObserver(this);
    setTimeout(() => {
      this.blocked = true;
    }, 0);
  }

  refrescarDatos() {
    if (
      this.cambioDetectado(this.dataSource) &&
      this.dataSource.prematricula &&
      this.dataSource.prematricula.materias &&
      this.dataSource.prematricula.materias.length > 0
    ) {
      let materias = [];
      let notas = [];
      let nombres = [];
      this.dataSource.prematricula.materias.map(materia => {
        materias.push(materia.codMateria);
        nombres.push(materia.nombreMateria);
        notas.push(parseFloat(!materia.notas.definitiva ? '0.0' : materia.notas.definitiva.toString().replace(',', '.')));
      });
      this.refrescarTabla(materias, notas, nombres);
      setTimeout(() => {
        this.blocked = false;
      }, 0);
      this.cambioExitoso(this.dataSource);
    }
  }

  refrescarTabla(materias: string[], notas: string[], nombres: string[]) {
    this.data = {
      labels: materias,
      nombres: nombres,
      texto: this.stringHelper.getResource('lbl-nota'),
      datasets: [
        {
          backgroundColor: '#42A5F5',
          data: notas
        }
      ]
    };

    this.options = {
      tooltips: {
        callbacks: {
          label: function (tooltipItems, data) {
            return data.nombres[tooltipItems.index] + ' - ' + data.texto + ': ' + tooltipItems.xLabel;
          }
        }
      },
      legend: { position: { display: false } },
      scales: { xAxes: [{ ticks: { stepSize: 1, beginAtZero: true, max: 5 } }] },
      plugins: { datalabels: { display: false } }
    };
  }

  ngOnInit() {}
}
