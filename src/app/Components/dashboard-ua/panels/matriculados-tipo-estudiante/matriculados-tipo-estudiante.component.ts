import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { BarChart } from 'src/app/Model/dashboard-ua/bar-chart';
import { EstudianteTipoIngreso } from 'src/app/Model/dashboard-ua/estudiante-tipo-ingreso';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { environment } from 'src/environments/environment';
import { EstudianteBusqueda } from 'src/app/Model/menu/estudiante-busqueda';
import { Planes } from 'src/app/Model/dashboard-ua/planes';
import { ConfirmationService, MessageService } from 'primeng/api';

@Component({
  selector: 'app-matriculados-tipo-estudiante',
  templateUrl: './matriculados-tipo-estudiante.component.html',
  styleUrls: ['./matriculados-tipo-estudiante.component.scss'],
  providers: [MessageService]
})
export class MatriculadosTipoEstudianteComponent implements OnInit {
  public stringHelper: StringResourceHelper;
  public selectedChart: any;
  public dropDownOptions: any[];
  public charts: BarChart[];
  public estudiantes: EstudianteTipoIngreso[];
  public data: any;
  public options: any;
  public display: boolean = false;
  public mostrarEstudiantesTipoIngreso: boolean = false;
  public mostrarEstudiantesPlanEstudio: boolean = false;
  public url: string;
  public blocked = false;
  public labelTooltip: string = '';
  public codigoEstudiante: string = '';
  public estudiantesBusqueda: EstudianteBusqueda[] = [];
  public estudianteBusqueda: EstudianteBusqueda;
  public mostrarCambioPlan: boolean = false;
  public planesDisp: Planes[] = [];
  public planSelected: Planes;

  constructor(
    private services: GeneralService,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {
    this.stringHelper = new StringResourceHelper('matriculados-tipo-ua');
    this.requestData();
  }

  ngOnInit() {}

  requestData() {
    this.services.getEstTipoIngreso().subscribe(
      response => {
        this.charts = response;
      },
      error => {},
      () => {
        if (this.charts) {
          this.setInitialSettings();
          this.requestDetails();
        }
      }
    );
  }

  requestDetails() {
    this.services.getDetallesEstTipoIngreso().subscribe(
      response => {
        this.estudiantes = response;
      },
      error => {},
      () => {}
    );
  }

  setInitialSettings() {
    this.dropDownOptions = this.charts.map(x => this.createDropDownItem(x.label, x));
    this.selectedChart = this.charts[0];
    this.labelTooltip = 'Matriculados por ' + this.selectedChart.label;
    this.fillData();
  }

  createDropDownItem(label, value) {
    return { label: label, value: value };
  }

  onChartChange(event) {
    this.fillData();
  }

  fillData() {
    this.labelTooltip = 'Matriculados por ' + this.selectedChart.label;
    this.data = {
      labels: this.selectedChart.barChartItems.map(x => x.key),
      datasets: [
        {
          label: this.stringHelper.getResource('lbl-grafica'),
          data: this.selectedChart.barChartItems.map(x => x.value),
          backgroundColor: '#42A5F5',
          borderColor: '#1E88E5',
          fullLabel: this.selectedChart.barChartItems.map(x => x.label)
        }
      ]
    };
    this.options = {
      legend: {
        position: { display: false }
      },
      plugins: {
        datalabels: {
          display: false
        }
      },
      tooltips: {
        enabled: true,
        mode: 'single',
        callbacks: {
          label: function (tooltipItems, data) {
            return data.datasets[0].fullLabel[tooltipItems.index] + ': ' + tooltipItems.yLabel;
          },
          title: function (tooltipItems, data) {
            return '';
          }
        }
      },
      scales: {
        yAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: this.selectedChart.yAxisLabel
            },
            ticks: { min: 0 }
          }
        ],
        xAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: this.selectedChart.xAxisLabel
            }
          }
        ]
      }
    };
  }

  showDialog() {
    switch (this.selectedChart.label) {
      case this.charts[0].label:
        this.mostrarEstudiantesTipoIngreso = false;
        this.mostrarEstudiantesPlanEstudio = false;
        this.url = environment.urlPostgrado + 'PKG_MENU.CALL_FACADE?P_OPTION_ID=10';
        this.display = true;
        break;
      case this.charts[1].label:
        this.mostrarEstudiantesTipoIngreso = false;
        this.mostrarEstudiantesPlanEstudio = false;
        this.url = environment.urlPostgrado + 'PKG_MENU.CALL_FACADE?P_OPTION_ID=15';
        this.display = true;
        break;
      case this.charts[2].label:
        this.mostrarEstudiantesTipoIngreso = true;
        this.mostrarEstudiantesPlanEstudio = false;
        this.display = true;
        break;
      case this.charts[3].label:
        this.mostrarEstudiantesTipoIngreso = false;
        this.mostrarEstudiantesPlanEstudio = true;
        this.display = false;
        this.mostrarCambioPlan = false;
        break;
    }
  }

  filterEstudiantes(event) {
    let query = event.query;
    var regexConNumero = /^.*[0-9]+.*$/;
    var regexCodigo = /^[A-Za-z0-9]{2}[0-9]{2}(1|2){1}[0-9]{3}$/;

    if (query.length >= 7 && regexCodigo.test(query)) {
      this.llamarServicioBusqueda('C', query.toUpperCase());
    } else if (!regexConNumero.test(query)) {
      this.llamarServicioBusqueda('N', query);
    } else if (query.length >= 4) {
      this.llamarServicioBusqueda('D', query);
    }
  }

  llamarServicioBusqueda(criterio: string, valor: string) {
    this.services.getEstudianteBusqueda(criterio, valor.trim().replace(/[\s]+/, ' ')).subscribe(
      busquedaObs => {
        this.estudiantesBusqueda = busquedaObs;
      },
      error => {},
      () => {}
    );
  }

  doOnSelect($event) {
    this.buscarEstudiante();
  }

  buscarEstudiante() {
    if (this.estudianteBusqueda) {
      if (!this.estudianteBusqueda.codigo) {
        if (this.estudiantesBusqueda.length > 0) {
          this.estudianteBusqueda = this.estudiantesBusqueda[0];
        } else return;
      }
      this.getPlanes();
    }
  }

  getPlanes() {
    this.services.getPlanes(this.estudianteBusqueda.codigo).subscribe(
      resp => {
        if (resp.status == 'ok') {
          this.planesDisp = resp.planes;
        }
      },
      error => {
        console.error('Error getPlanes');
      },
      () => {
        this.planesDisp.map(plan => {
          if (plan.activo == 1) {
            this.planSelected = plan;
          }
        });
        if (!this.planSelected) {
          this.planSelected = this.planesDisp[0];
        }
        this.mostrarCambioPlan = true;
      }
    );
  }

  guardarPlanNuevo() {
    this.confirmationService.confirm({
      message: 'Está seguro que desea cambiar el plan de estudio del estudiante: ' + this.estudianteBusqueda.nombre + '?',
      acceptLabel: 'Si',
      rejectLabel: 'No',
      header: 'Confirmación',
      accept: () => {
        this.services.actualizarPlan(this.estudianteBusqueda.codigo, this.planSelected.planEstudio).subscribe(
          resp => {
            if (resp.status == 'ok') {
              this.messageService.add({
                severity: 'success',
                summary: 'Plan actualizado',
                detail: resp.mensaje
              });
            } else {
              this.messageService.add({
                severity: 'warn',
                summary: 'El plan no se actualizó',
                detail: resp.mensaje
              });
            }
          },
          error => {
            if (error.status == '400') {
              this.messageService.add({
                severity: 'warn',
                summary: 'El plan no se actualizó',
                detail: error.error.mensaje
              });
            }
          },
          () => {
            this.mostrarEstudiantesPlanEstudio = false;
            this.estudianteBusqueda = new EstudianteBusqueda();
            this.planSelected = new Planes();
          }
        );
      }
    });
  }
}
