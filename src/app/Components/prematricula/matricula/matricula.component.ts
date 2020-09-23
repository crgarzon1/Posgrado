import { Component, OnInit, Output, EventEmitter, Input } from '@angular/core';
import { GeneralService } from 'src/app/Services/general.service';
import { ObservableMatricula, IObserverMatricula } from 'src/app/Model/prematricula/observable-matricula';
import { MatriculaOferta, Grupo } from 'src/app/Model/prematricula/matricula-oferta';
import { ConfirmationService } from 'primeng/components/common/confirmationservice';
import { Message } from '@angular/compiler/src/i18n/i18n_ast';
import { StringResourceHelper } from 'src/app/Model/util/string-resource-helper';
import { MessageService } from 'primeng/components/common/messageservice';
import { Respuesta } from 'src/app/Model/prematricula/respuesta';

@Component({
  selector: 'app-matricula',
  templateUrl: './matricula.component.html',
  styleUrls: ['./matricula.component.scss'],
  providers: [ConfirmationService, MessageService]
})
export class MatriculaComponent implements OnInit, IObserverMatricula {
  public stringHelper: StringResourceHelper;
  public settedMatricula: boolean = false;
  // private observableMatricula: ObservableMatricula;
  public msgs: Message[] = [];
  public respuestaDesinscribir: Respuesta;

  @Output() showProgress = new EventEmitter<boolean>();
  @Input() observableMatricula: ObservableMatricula;

  constructor(
    public generalService: GeneralService,
    private confirmationService: ConfirmationService,
    private messageService: MessageService
  ) {
    this.stringHelper = new StringResourceHelper('matricula-inscritos');
    this.observableMatricula = ObservableMatricula.getInstance(generalService);
    this.observableMatricula.addObserver(this);
  }

  refrescarDatos() {
    if (this.observableMatricula.settedAsignaturasMatriculadas && !this.settedMatricula) {
      this.settedMatricula = true;
    }
  }

  indicarCambioForzoso() {
    this.settedMatricula = false;
  }

  eliminarMateria(mat: MatriculaOferta, grupoActual: Grupo) {
    this.confirmationService.confirm({
      message:
        this.stringHelper.getResource('dlg-message') + mat.grupos[0].materia.nombre + this.stringHelper.getResource('dlg-signo'),
      accept: () => {
        this.changeProgress(true);
        this.cancelarInsMateria(mat, grupoActual);
      }
    });
  }

  public cancelarInsMateria(materiaCancelada: MatriculaOferta, grupoCancelado: Grupo) {
    // {"c":"codigoMateria", "m":"codigoPlan", "n":"consecutivo", "b":"id_bolsa"}
    let consecutivo = '0';
    loop: for (let i = 0; i < this.observableMatricula.bolsasCreditosElectivos.length; i++) {
      let bolsa = this.observableMatricula.bolsasCreditosElectivos[i];
      for (let j = 0; j < bolsa.asignaturasDisponibles.length; j++) {
        if (bolsa.asignaturasDisponibles[j].materia.codigo === materiaCancelada.materia.codigo) {
          consecutivo = bolsa.id;
          break loop;
        }
      }
    }
    let p_arg = {
      c: this.generalService.codigoEstudiante,
      m: materiaCancelada.materia.codigo,
      n: grupoCancelado.id,
      b: consecutivo
    };

    this.generalService.desinscribirMateria(p_arg).subscribe(
      response => {
        this.respuestaDesinscribir = response;
      },
      error => {
        this.changeProgress(false);
        this.messageService.add({
          severity: 'warn',
          summary: this.stringHelper.getResource('alr-error-tit'),
          detail: error.error.mensaje
        });
      },
      () => {
        this.changeProgress(false);
        if (this.respuestaDesinscribir.status === 'ok') {
          this.observableMatricula.cancelarInscripcion(materiaCancelada, grupoCancelado);
          this.messageService.add({
            severity: 'success',
            summary: this.stringHelper.getResource('alr-materia-eliminada-tit'),
            detail: this.stringHelper.getResource('alr-materia-eliminada-det')
          });
        } else {
          this.messageService.add({
            severity: 'error',
            summary: this.stringHelper.getResource('alr-error-tit'),
            detail: this.stringHelper.getResource('alr-error-det') + this.respuestaDesinscribir.mensaje
          });
        }
      }
    );
  }

  ngOnInit() {}

  changeProgress(progress: boolean) {
    this.showProgress.emit(progress);
  }
}
