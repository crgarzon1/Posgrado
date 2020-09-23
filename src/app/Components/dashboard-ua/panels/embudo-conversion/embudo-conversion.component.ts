import { Component, OnInit } from '@angular/core';
import { Indicadores } from 'src/app/Model/dashboard-ua/indicadores';
import { GeneralService } from 'src/app/Services/general.service';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-embudo-conversion',
  templateUrl: './embudo-conversion.component.html',
  styleUrls: ['./embudo-conversion.component.scss']
})
export class EmbudoConversionComponent implements OnInit {
  public stringHelper: StringResourceHelper;
  public ind: Indicadores;
  public display: boolean = false;
  public data: any;
  public options: any;
  public url: string;
  public blocked: boolean = false;

  constructor(private services: GeneralService) {
    this.stringHelper = new StringResourceHelper('embudo-conversion-ua');
    this.getIndicadores();
  }

  fillData() {
    this.data = {
      labels: ['HD', 'F1', 'F2', 'PI', 'En', 'Ad', 'Ma'],
      names: ['Habeas Data', 'Formulario 1', 'Formulario 2', 'Pago Inscripcion', 'Entrevista', 'Admitido', 'Matriculado'],
      datasets: [
        {
          label: this.stringHelper.getResource('lbl-grafica'),
          backgroundColor: '#42A5F5',
          borderColor: '#1E88E5',
          data: [
            this.ind.habeasData,
            this.ind.form1,
            this.ind.form2,
            this.ind.pagoInscripcion,
            this.ind.entrevista,
            this.ind.admitido,
            this.ind.matriculado
          ]
        }
      ]
    };

    this.options = {
      tooltips: {
        callbacks: {
          label: function (tooltipItems, data) {
            return data.names[tooltipItems.index] + ': ' + tooltipItems.xLabel;
          }
        }
      },
      legend: {
        position: { display: false }
      },
      plugins: { datalabels: { display: false } },
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
            },
            ticks: {
              min: 0
            }
          }
        ]
      }
    };
  }

  getIndicadores() {
    this.services.getIndicadores().subscribe(
      indicadoresObs => {
        this.ind = indicadoresObs;
      },
      error => {},
      () => {
        if (!this.ind.habeasData && !this.ind.form1 && !this.ind.pagoInscripcion) {
          this.blocked = true;
        }
        this.fillData();
      }
    );
  }

  showDialog(id: number) {
    this.display = true;
    switch (id) {
      case 1:
        this.getUrlPanel('12'); //url externa con parametros
        break;
      case 2:
        this.getUrlPanel('9');
        break;
    }
  }

  ngOnInit() {}

  getUrlPanel(option: string) {
    this.url = environment.urlPostgrado + 'PKG_MENU.CALL_FACADE?P_OPTION_ID=' + option;
  }
}
