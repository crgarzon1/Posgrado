import { Component, OnInit } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { WebServiceResponse } from 'src/app/Model/creditos-adicionales/web-service-response';
import { MessageService } from 'primeng/api';
import { Estudiante } from 'src/app/Model/creditos-adicionales/estudiante';
import { ConfirmationService } from 'primeng/api';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';

@Component({
  selector: 'app-creditos-adicionales',
  templateUrl: './creditos-adicionales.component.html',
  styleUrls: ['./creditos-adicionales.component.scss'],
  providers: [MessageService, ConfirmationService]
})
export class CreditosAdicionalesComponent implements OnInit {
  public stringHelper: StringResourceHelper;
  public mostrarDialog = false;
  public mostrarResultadoBusqueda = false;
  public respuesta: WebServiceResponse;
  public estudiantes: Estudiante[];
  public resultadoBusqueda: Estudiante;
  public criterioBusqueda: string;
  public columnas: any[];
  public estados: any[];
  public valoresCreditosAdicionales: any[];
  public numeroGuiaPago: string;
  public guiaFinanciera: string;
  public url: string;
  public mostrarGuiaDePago = false;
  public creditosAdicionales: any;
  public disableButton = true;
  public cantidadCreditos: any[] = [];

  constructor(
    public service: GeneralService,
    private messageService: MessageService,
    private confirmationService: ConfirmationService
  ) {
    this.stringHelper = new StringResourceHelper('creditos-adicionales-component');
  }

  ngOnInit() {
    this.resultadoBusqueda = new Estudiante();
    this.columnas = [
      { field: 'codigoEstudiante', header: 'Codigo Estudiantil', minHeader: 'Codigo' },
      { field: 'nombreEstudiante', header: 'Nombre', minHeader: 'Nombre' },
      { field: 'numeroCreditosAdicionales', header: 'Creditos Adicionales', minHeader: 'Creditos' },
      { field: 'guia', header: 'Ver Guia de Pago', minHeader: 'Guia' },
      { field: 'cancelar', header: 'Cancelar Solicitud', minHeader: 'Cancelar Solicitud' },
      { field: 'estado', header: 'Estado', minHeader: 'Estado' }
    ];
    this.estados = [
      { label: 'Autorizado', value: 'Autorizado' },
      { label: 'Revocado', value: 'Revocado' },
      { label: 'Pagado', value: 'Pagado' }
    ];
    this.refrescarTabla();
  }

  desplegarDialog() {
    this.criterioBusqueda = '';
    this.resultadoBusqueda = new Estudiante();
    this.mostrarDialog = true;
    this.mostrarResultadoBusqueda = false;
  }

  refrescarTabla() {
    this.service.listarEstudiantes().subscribe(
      msj => {
        this.respuesta = msj;
      },
      error => {
        this.messageService.add({ severity: 'error', summary: error.error.mensaje });
      },
      () => {
        if (this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID) {
          this.estudiantes = this.respuesta.values as Estudiante[];
          this.estudiantes.map(est => {
            if (est.estado == 'Cancelado') {
              est.estado = 'Revocado';
            }
          });
          this.estudiantes.sort((a, b) => {
            if (a.estado > b.estado) {
              return 1;
            }
            if (a.estado < b.estado) {
              return -1;
            }
            return 0;
          });
        } else if (this.respuesta.statusId == WebServiceResponse.ERROR_STATUS_ID && this.respuesta.message) {
          this.messageService.add({
            severity: 'warn',
            summary: this.respuesta.message
          });
        }
      }
    );
  }

  buscarEstudiante() {
    this.mostrarDialog = false;
    if (this.criterioBusqueda && this.criterioBusqueda.length >= 5) {
      this.service.buscarEstudiantes(this.criterioBusqueda).subscribe(
        msj => {
          this.respuesta = msj;
        },
        error => {
          this.messageService.add({ severity: 'error', summary: error.error.mensaje });
        },
        () => {
          if (this.respuesta.status != 'Error') {
            let auxiliarEstudiante = this.respuesta.values[0] as Estudiante;
            if (
              this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID &&
              this.respuesta.values.length == 1 &&
              auxiliarEstudiante &&
              !auxiliarEstudiante.guiaFinanciera
            ) {
              this.resultadoBusqueda = this.respuesta.values[0] as Estudiante;
              this.resultadoBusqueda.creditosAdicionalesAutorizados = 0;
              this.mostrarResultadoBusqueda = true;
              this.mostrarDialog = true;
              this.setCantidadCreditos();
            } else if (
              this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID &&
              (!auxiliarEstudiante || auxiliarEstudiante.guiaFinanciera)
            ) {
              if (this.estudiantes.map(x => x.codigoEstudiante).includes(this.criterioBusqueda)) {
                this.messageService.add({
                  severity: 'warn',
                  summary:
                    this.stringHelper.getResource('msj-warn-creditos-1') +
                    this.criterioBusqueda +
                    this.stringHelper.getResource('msj-warn-creditos-2')
                });
              } else {
                this.messageService.add({
                  severity: 'warn',
                  summary:
                    this.stringHelper.getResource('msj-warn-creditos-1') +
                    this.criterioBusqueda +
                    this.stringHelper.getResource('msj-warn-matriculado-2')
                });
              }
              this.mostrarResultadoBusqueda = false;
              this.mostrarDialog = true;
            } else if (this.respuesta.statusId == WebServiceResponse.ERROR_STATUS_ID && this.respuesta.message) {
              this.messageService.add({
                severity: 'warn',
                summary: this.respuesta.message
              });
            }
          } else {
            this.messageService.clear();
            this.messageService.add({
              severity: 'warn',
              summary: this.respuesta.message
            });
          }
        }
      );
    } else {
      this.messageService.add({
        severity: 'info',
        summary: this.stringHelper.getResource('msj-warn-codigo-no-cumple')
      });
      this.mostrarDialog = true;
    }
  }

  setCantidadCreditos() {
    this.cantidadCreditos = [];
    this.creditosAdicionales = null;
    this.disableButton = true;
    if (this.resultadoBusqueda.creditosAdicionalesDisponibles) {
      for (let i = 0; i < this.resultadoBusqueda.creditosAdicionalesDisponibles; i++) {
        var index = i + 1 + '';
        this.cantidadCreditos.push({ index: index });
      }
    }
  }

  imagenDefecto() {
    this.resultadoBusqueda.foto = 'assets/images/person.png';
  }

  cancelarCreditos(autorizacionId: string) {
    this.confirmationService.confirm({
      message: this.stringHelper.getResource('cnf-cancelar-creditos'),
      accept: () => {
        this.service.cancelarCreditosAdicionales(autorizacionId).subscribe(
          msj => {
            this.respuesta = msj;
          },
          error => {
            this.messageService.add({ severity: 'error', summary: error.error.mensaje });
          },
          () => {
            if (this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID) {
              this.messageService.add({
                severity: 'success',
                summary: this.stringHelper.getResource('msj-eliminado-correct')
              });
              this.refrescarTabla();
            } else if (this.respuesta.statusId == WebServiceResponse.ERROR_STATUS_ID && this.respuesta.message) {
              this.messageService.add({
                severity: 'warn',
                summary: this.respuesta.message
              });
            }
          }
        );
      }
    });
  }

  autorizarCreditos() {
    if (this.resultadoBusqueda.creditosAdicionalesAutorizados && this.resultadoBusqueda.creditosAdicionalesAutorizados > 0) {
      this.confirmationService.confirm({
        message:
          this.stringHelper.getResource('cnf-autorizar-creditos-adicionales-1') +
          this.resultadoBusqueda.creditosAdicionalesAutorizados +
          this.stringHelper.getResource('cnf-autorizar-creditos-adicionales-2') +
          this.resultadoBusqueda.nombreEstudiante +
          this.stringHelper.getResource('cnf-autorizar-creditos-adicionales-3') +
          this.resultadoBusqueda.codigoEstudiante +
          this.stringHelper.getResource('cnf-autorizar-creditos-adicionales-4'),
        accept: () => {
          this.numeroGuiaPago = '';
          this.service
            .getGuiaPagoCreditosAdicionales(
              this.resultadoBusqueda.codigoEstudiante,
              this.resultadoBusqueda.creditosAdicionalesAutorizados
            )
            .subscribe(
              msj => {
                if (msj.status == 'ok') {
                  this.numeroGuiaPago = msj.mensaje.split(';', 3)[0];
                  this.guiaFinanciera = msj.mensaje.split(';', 3)[2];
                  this.service
                    .autorizarCreditosAdicionales(
                      this.resultadoBusqueda.codigoEstudiante,
                      this.resultadoBusqueda.creditosAdicionalesAutorizados,
                      this.numeroGuiaPago,
                      this.guiaFinanciera
                    )
                    .subscribe(
                      msj => {
                        this.respuesta = msj;
                      },
                      error => {
                        this.messageService.add({ severity: 'error', summary: error });
                      },
                      () => {
                        if (this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID) {
                          this.messageService.add({
                            severity: 'success',
                            summary: this.stringHelper.getResource('msj-creditos-autorizados-correct')
                          });
                          this.mostrarDialog = false;
                          this.refrescarTabla();
                        } else if (this.respuesta.statusId == WebServiceResponse.ERROR_STATUS_ID && this.respuesta.message) {
                          this.messageService.add({
                            severity: 'error',
                            summary: this.respuesta.message
                          });
                        }
                      }
                    );
                } else {
                  this.messageService.add({ severity: 'error', summary: msj.mensaje });
                }
              },
              error => {
                this.messageService.add({ severity: 'error', summary: error.error.mensaje });
              },
              () => {
                if (this.respuesta.statusId == WebServiceResponse.SUCESS_STATUS_ID) {
                  this.mostrarDialog = false;
                } else if (this.respuesta.statusId == WebServiceResponse.ERROR_STATUS_ID && this.respuesta.message) {
                  this.messageService.add({
                    severity: 'warn',
                    summary: this.respuesta.message
                  });
                }
              }
            );
        }
      });
    } else {
      this.messageService.add({
        severity: 'info',
        summary: this.stringHelper.getResource('msj-necesario-asignar')
      });
      this.mostrarDialog = true;
    }
  }

  checkCreditosDisponibles() {
    if (this.resultadoBusqueda.creditosAdicionalesDisponibles == 0) {
      this.messageService.add({
        severity: 'info',
        summary: 'No tiene créditos disponibles para autorizar.'
      });
      this.disableButton = true;
    }
  }

  checkMaxValue() {
    var regex = /^[0-9]$/;
    if (this.creditosAdicionales.index.trim() == '' || this.creditosAdicionales.index.trim() == '0') {
      this.disableButton = true;
    } else {
      if (
        (this.creditosAdicionales.index.trim() != '' && !regex.test(this.creditosAdicionales.index)) ||
        +this.creditosAdicionales.index > this.resultadoBusqueda.creditosAdicionalesDisponibles
      ) {
        this.messageService.clear();
        this.creditosAdicionales.index = '0';
        this.messageService.add({
          severity: 'info',
          summary:
            'Solo puede autorizar ' +
            this.resultadoBusqueda.creditosAdicionalesDisponibles +
            ' credito(s) adicionales para el estudiante actual.'
        });
        this.disableButton = true;
      } else {
        this.disableButton = false;
        this.resultadoBusqueda.creditosAdicionalesAutorizados = +this.creditosAdicionales.index.trim();
      }
    }
  }

  securityBreach() {
    this.messageService.add({
      severity: 'error',
      summary: 'Security Breach.'
    });
  }

  mostrarDialogGuiaDePago(url: string) {
    this.mostrarGuiaDePago = true;
    this.url = 'https://facturacion.lasalle.edu.co/GuiasPago-war/VerGuiaPos?numGuia=' + url;
    // https://facturacion.lasalle.edu.co/GuiasPago-war/VerGuiaPos?numGuia=1350171
  }
}
