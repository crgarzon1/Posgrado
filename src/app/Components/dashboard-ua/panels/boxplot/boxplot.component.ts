import { Component, OnInit } from '@angular/core';
import { BoxPlotItem } from 'src/app/Model/dashboard-ua/box-plot-item';
import { GeneralService } from 'src/app/Services/general.service';
import { EstadisticaNotas } from 'src/app/Model/dashboard-ua/estadistica-notas';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-boxplot',
  templateUrl: './boxplot.component.html',
  styleUrls: ['./boxplot.component.scss']
})
export class BoxplotComponent implements OnInit {
  estadisticasNotas: EstadisticaNotas[];
  public stringHelper: StringResourceHelper;
  data: any;
  options: any;
  display: boolean = false;
  url: string;
  blocked: boolean = false;

  constructor(public generalService: GeneralService) {
    this.stringHelper = new StringResourceHelper('caja-bigotes-ua');
  }

  ngOnInit() {
    this.mostrasEstadisticas();
  }

  mostrasEstadisticas() {
    this.generalService.getEstadisticasNotas().subscribe(
      respuesta => {
        this.estadisticasNotas = respuesta;
      },
      error => {},
      () => {
        this.estadisticasNotas.map(estad => {
          if (estad.status === 'Error') {
            this.blocked = true;
          }
        });
        this.data = {
          // define label tree
          labels: this.estadisticasNotas.map(x => x.nombreDataSet),
          datasets: [
            {
              backgroundColor: 'rgba(255,0,0,0.5)',
              borderColor: 'red',
              borderWidth: 1,
              outlierColor: '#999999',
              padding: 10,
              itemRadius: 0,
              data: this.estadisticasNotas.map(
                x => new BoxPlotItem(x.primerCuartil, x.mediana, x.tercerCuartil, x.valorMinimo, x.valorMaximo, 0, 5, x.outliers)
              )
            }
          ]
        };

        this.options = {
          legend: {
            display: false,
            position: 'top'
          },
          plugins: {
            datalabels: { display: false }
          },
          scales: {
            yAxes: [
              {
                scaleLabel: {
                  display: true,
                  labelString: this.stringHelper.getResource('lbl-eje-y')
                }
              }
            ],
            xAxes: [
              {
                scaleLabel: {
                  display: true,
                  labelString: this.stringHelper.getResource('lbl-eje-x')
                }
              }
            ]
          }
        };
      }
    );
  }

  showDialog(id: number) {
    this.display = true;
    switch (id) {
      case 1:
        this.getUrlPanel('13');
        break;
      case 2:
        this.getUrlPanel('14');
        break;
    }
  }

  getUrlPanel(option: string) {
    this.url = environment.urlPostgrado + 'PKG_MENU.CALL_FACADE?P_OPTION_ID=' + option;
  }
}
