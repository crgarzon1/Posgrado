import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { EstadoNotas } from 'src/app/Model/dashboard-ua/estado-notas';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-estado-notas',
  templateUrl: './estado-notas.component.html',
  styleUrls: ['./estado-notas.component.scss']
})
export class EstadoNotasComponent implements OnInit {
  public stringHelper: StringResourceHelper;
  public estadoNotas: EstadoNotas;
  public data: any;
  public options: any;
  public display: boolean = false;
  public url: string;
  public blocked: boolean = false;

  constructor(private services: GeneralService) {
    this.stringHelper = new StringResourceHelper('estado-notas-ua');
    this.getEstadoNotas();
  }

  ngOnInit() {}

  getEstadoNotas() {
    this.services.getEstadoNotas().subscribe(
      estadoNotasObs => {
        this.estadoNotas = estadoNotasObs;
      },
      error => {},
      () => {
        if (this.estadoNotas.status == 'Error' || this.estadoNotas.status == 'fail') this.blocked = true;
        else {
          if (this.estadoNotas.estudiantesMatriculados === 0) {
            this.blocked = true;
          } else this.fillData();
        }
      }
    );
  }

  fillData() {
    var x = (this.estadoNotas.estudiantesMatriculadosConNota * 100) / this.estadoNotas.estudiantesMatriculados;
    var y = this.estadoNotas.estudiantesMatriculados - x;
    //var x = (15 * 100) / 82;
    //var y = 82 - x;
    this.data = {
      labels: [this.stringHelper.getResource('lbl-con-nota'), this.stringHelper.getResource('lbl-sin-nota')],
      datasets: [
        {
          label: this.stringHelper.getResource('lbl-grafica'),
          data: [x, y],
          backgroundColor: ['rgb(54, 162, 235)', 'rgb(255, 99, 132)']
        }
      ]
    };
    this.options = {
      circumference: Math.PI,
      rotation: Math.PI,
      cutoutPercentage: 70,
      plugins: {
        datalabels: {
          backgroundColor: 'rgb(54, 162, 235)',
          borderColor: '#ffffff',
          color: '#ffffff',
          font: function (context) {
            var w = context.chart.width;
            return {
              size: w < 512 ? 14 : 16
            };
          },
          align: 'start',
          anchor: 'start',
          offset: 5,
          borderRadius: 4,
          borderWidth: 1,
          formatter: function (value, context) {
            var i = context.dataIndex;
            var len = context.dataset.data.length - 1;
            if (i == len) return null;
            return value.toFixed(2) + '%';
          }
        }
      },
      legend: {
        display: true,
        onClick: e => e.stopPropagation()
      },
      tooltips: {
        enabled: false
      }
    };
  }

  showDialog() {
    this.display = true;
    this.url = environment.urlPostgrado + 'PKG_MENU.CALL_FACADE?P_OPTION_ID=11';
  }
}
