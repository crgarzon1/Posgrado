import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { FacultadesIntegrados } from 'src/app/Model/integrados/facultades-integrados';
import { PlanesIntegrados } from 'src/app/Model/integrados/planes-integrados';
import { MateriasIntegrados } from 'src/app/Model/integrados/materias-integrados';
import { TablaIntegrados } from 'src/app/Model/integrados/tabla-integrados';
import { GeneralService } from 'src/app/Services/general.service';
import { MessageService } from 'primeng/components/common/messageservice';
import { Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
import { ConfirmationService } from 'primeng/api';
import { Message } from '@angular/compiler/src/i18n/i18n_ast';

@Component({
  selector: 'app-integrados',
  templateUrl: './integrados.component.html',
  styleUrls: ['./integrados.component.scss'],
  providers: [MessageService, ConfirmationService]
})
export class IntegradosComponent implements OnInit {
  public progress: boolean = true;
  public msgs: Message[] = [];

  public facultadesEncargado: FacultadesIntegrados[] = [];
  public facultadEncargado: FacultadesIntegrados;
  public planesEncargado: PlanesIntegrados[];
  public planEncargado: PlanesIntegrados;
  public materiasEncargado: MateriasIntegrados[] = [];
  public materiaEncargado: MateriasIntegrados;

  public facultadesIntegradas: FacultadesIntegrados[] = [];
  public facultadIntegrada: FacultadesIntegrados;
  public planesIntegrados: PlanesIntegrados[] = [];
  public planIntegrado: PlanesIntegrados;
  public materiasIntegrado: MateriasIntegrados[] = [];
  public materiaIntegrada: MateriasIntegrados;

  public habilitarMateriasE: boolean = true;
  public habilitarPlanesE: boolean = true;
  public habilitarProgramasI: boolean = true;
  public habilitarPlanesI: boolean = true;
  public habilitarMateriasI: boolean = true;

  public totalMateriasIntegradas: TablaIntegrados[] = [];
  public materiasIntegradasActuales: TablaIntegrados[] = [];

  public token: string;

  public estados: Array<number> = new Array(5);

  constructor(
    private servicio: GeneralService,
    private messageService: MessageService,
    private router: Router,
    private cookie: CookieService,
    private confirmationService: ConfirmationService
  ) {
    this.token = sessionStorage.getItem('tnkptcn');
    var cookieTkn = this.cookie.get('wUFAnew4');
    if (cookieTkn && this.token) {
      this.getFacultades();
    } else {
      this.router.navigateByUrl('login');
    }
  }

  ngOnInit() {}

  onChangePlanesEncargado(e) {
    this.progress = true;
    this.habilitarMateriasE = false;
    this.getMaterias(this.servicio.getCodigoFactultad(), this.servicio.getJornadaFacultad(), e.value.id, 'encargado');
    this.materiasIntegradasActuales = [];
    this.totalMateriasIntegradas = [];
    this.materiaEncargado = null;
    this.habilitarProgramasI = true;
    this.habilitarPlanesI = true;
    this.habilitarMateriasI = true;
    this.estados = [2, 1, 0, 0, 0];
  }

  onChangeMateriasEncargado(e) {
    this.progress = true;
    this.materiasIntegradasActuales = [];
    this.totalMateriasIntegradas = [];
    this.getMateriasIntegradas(this.planEncargado.id, e.value.codigo);
    this.setIntegradasActuales();
    this.habilitarProgramasI = false;
    this.habilitarPlanesI = true;
    this.habilitarMateriasI = true;
    this.planIntegrado = null;
    this.facultadIntegrada = null;
    this.materiaIntegrada = null;
    this.estados = [2, 2, 1, 0, 0];
  }

  onChangeProgramaIntegrado(e) {
    this.habilitarPlanesI = false;
    this.planesIntegrados = e.value.planes;
    this.planesIntegrados.forEach(p => (p.nombrePlan = `${p.id} - ${p.plan}`));
    this.habilitarMateriasI = true;
    this.planIntegrado = null;
    this.materiaIntegrada = null;
    this.materiasIntegrado = [];
    this.estados = [2, 2, 2, 1, 0];
  }

  onChangePlanesIntegrado(e) {
    this.progress = true;
    this.habilitarMateriasI = false;
    this.getMaterias(this.facultadIntegrada.codigo, this.facultadIntegrada.jornada, e.value.id, 'integrado');
    this.estados = [2, 2, 2, 2, 1];
  }

  onChangeMateriasIntegrado(e) {
    this.confirmationService.confirm({
      message: `¿Estás seguro de integrar ${this.materiaEncargado.nombre} con ${this.materiaIntegrada.nombre}?`,
      header: 'Integrar materia',
      accept: () => {
        this.progress = true;
        const agregada = {
          codigo_facultad: this.facultadEncargado.codigo,
          jornada_facultad: this.facultadEncargado.jornada,
          plan_estudio: this.planEncargado.id, //number
          codigo_materia: this.materiaEncargado.codigo,
          codigo_facultad_eq: this.facultadIntegrada.codigo,
          jornada_facultad_eq: this.facultadIntegrada.jornada,
          plan_estudio_eq: this.planIntegrado.id, //number
          codigo_materia_eq: this.materiaIntegrada.codigo
        };
        let error = false;
        this.servicio.guardarMateriaIntegrada(agregada).subscribe(
          data => {
            this.progress = false;
            if (data['status'] === 'fail') {
              error = true;
              this.messageService.add({
                severity: 'error',
                summary: 'Error',
                detail: data['mensaje']
              });
            } else {
              this.messageService.add({
                severity: 'success',
                summary: 'Materia integrada satisfactoriamente.'
              });
            }
          },
          error => {
            this.progress = false;
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: error
            });
          }
        );

        var newField = {
          programaIntegrado: this.facultadIntegrada,
          planIntegrado: this.planIntegrado,
          materiaIntegrado: this.materiaIntegrada,
          semestre: this.materiaIntegrada.semestre,
          codigo: this.materiaIntegrada.codigo,
          creditos: this.materiaIntegrada.creditos + '',
          programaEncargado: this.facultadEncargado,
          planEncargado: this.planEncargado,
          materiaEncargado: this.materiaEncargado
        };
        if (!error) {
          this.totalMateriasIntegradas.push(newField);
          this.materiasIntegradasActuales.push(newField);
        }

        const materias = this.materiasIntegrado.filter(p => p.codigo != e.value.codigo);
        this.materiasIntegrado = materias;
      }
    });
  }

  getFacultades() {
    this.servicio.getFacultades().subscribe(
      facultadesObs => {
        this.facultadesEncargado = facultadesObs;
        this.facultadesIntegradas = facultadesObs;
        this.progress = false;
      },
      error => {},
      () => {
        this.facultadEncargado = this.getFacultadEncargado();
        this.planesEncargado = this.facultadEncargado.planes;
        this.planesEncargado.forEach(p => (p.nombrePlan = `${p.id} - ${p.plan}`));
      }
    );
  }

  getFacultadEncargado(): FacultadesIntegrados {
    var facultadReturn: FacultadesIntegrados = new FacultadesIntegrados();
    for (let i = 0; i < this.facultadesEncargado.length; i++) {
      if (this.facultadesEncargado[i].codigo === this.servicio.getCodigoFactultad()) {
        facultadReturn = this.facultadesEncargado[i];
        break;
      }
    }
    this.estados = [1, 0, 0, 0, 0];
    return facultadReturn;
  }

  getMaterias(codigoFacultad: string, jornadaFacultad: string, planEstudio: string, dirigido: string) {
    this.servicio.getMaterias(codigoFacultad, jornadaFacultad, planEstudio).subscribe(
      materiasObs => {
        if (dirigido === 'encargado') {
          this.materiasEncargado = materiasObs;
          for (let i = 0; i < this.materiasEncargado.length; i++) {
            this.materiasEncargado[i].nombre = this.materiasEncargado[i].codigo + ' ' + this.materiasEncargado[i].nombre;
          }
        } else if (dirigido === 'integrado') {
          this.materiasIntegrado = materiasObs;
          this.filtrarMaterias();
          for (let i = 0; i < this.materiasIntegrado.length; i++) {
            this.materiasIntegrado[i].nombre = this.materiasIntegrado[i].codigo + ' ' + this.materiasIntegrado[i].nombre;
          }
        }
        this.progress = false;
      },
      error => {},
      () => {}
    );
  }

  getMateriasIntegradas(planEstudio: string, codigoMateria: string) {
    this.servicio.getMateriasIntegradas(planEstudio, codigoMateria).subscribe(
      integradasObs => {
        integradasObs.forEach(element => {
          var tabla = {
            programaIntegrado: element.facultad,
            planIntegrado: element.plan,
            materiaIntegrado: element,
            semestre: element.semestre,
            codigo: element.codigo,
            creditos: element.creditos,
            programaEncargado: this.facultadEncargado,
            planEncargado: this.planEncargado,
            materiaEncargado: this.materiaEncargado
          };
          const busqueda = this.totalMateriasIntegradas.find(res => {
            if (
              tabla.programaIntegrado === res.programaIntegrado &&
              tabla.planIntegrado === res.planIntegrado &&
              tabla.materiaIntegrado === res.materiaIntegrado
            ) {
              return true;
            }
          });
          if (!busqueda) {
            this.totalMateriasIntegradas.push(tabla);
            this.materiasIntegradasActuales.push(tabla);
          }
        });
        this.progress = false;
      },
      error => {}
    );
  }

  setIntegradasActuales() {
    this.materiasIntegradasActuales = [];
    this.totalMateriasIntegradas.forEach(element => {
      if (
        element.programaEncargado.nombre === this.facultadEncargado.nombre &&
        element.planEncargado.plan === this.planEncargado.plan &&
        element.materiaEncargado.nombre === this.materiaEncargado.nombre
      ) {
        this.materiasIntegradasActuales.push(element);
      }
    });
  }

  filtrarMaterias() {
    if (this.materiasIntegradasActuales.length !== 0) {
      var ids = this.materiasIntegrado.filter(obj => {
        for (var a in this.materiasIntegradasActuales) {
          if (
            (obj.codigo === this.materiasIntegradasActuales[a].codigo &&
              obj.nombre.split(' ')[1] == this.materiasIntegradasActuales[a].materiaIntegrado.nombre.split(' ')[1]) ||
            (obj.nombre.split(' ')[1] == this.materiaEncargado.nombre.split(' ')[1] && obj.codigo == this.materiaEncargado.codigo)
          ) {
            return false;
          }
        }
        return true;
      });
      this.materiasIntegrado = ids;
    }
  }

  eliminar(e) {
    this.confirmationService.confirm({
      message: '¿Estás seguro eliminar la materia integrada?',
      header: 'Eliminar integrado',
      accept: () => {
        this.progress = true;
        const materias = this.totalMateriasIntegradas.filter(p => {
          if (
            p.programaIntegrado === e.programaIntegrado &&
            p.planIntegrado === e.planIntegrado &&
            p.materiaIntegrado === e.materiaIntegrado &&
            p.semestre === e.semestre &&
            p.codigo === e.codigo
          ) {
            return;
          } else {
            return p;
          }
        });
        this.totalMateriasIntegradas = materias;
        this.setIntegradasActuales();

        const eliminada = {
          codigo_facultad: e.programaEncargado.codigo,
          jornada_facultad: e.programaEncargado.jornada,
          plan_estudio: e.planEncargado.id, //number
          codigo_materia: e.materiaEncargado.codigo,
          codigo_facultad_eq: e.programaIntegrado.codigo,
          jornada_facultad_eq: e.programaIntegrado.jornada,
          plan_estudio_eq: e.planIntegrado.id, //number
          codigo_materia_eq: e.materiaIntegrado.codigo
        };
        this.servicio.eliminarMateriaIntegrada(eliminada).subscribe(
          data => {
            this.progress = false;
            if (data['status'] === 'fail') {
              this.messageService.add({
                severity: 'error',
                summary: 'Error',
                detail: data['mensaje']
              });
            } else {
              this.messageService.add({
                severity: 'success',
                summary: 'Materia eliminada satisfactoriamente.'
              });
              this.materiasIntegrado.push({
                codigo: e.materiaIntegrado.codigo,
                creditos: e.materiaIntegrado.creditos,
                nombre: e.materiaIntegrado.codigo + ' ' + e.materiaIntegrado.nombre,
                semestre: e.materiaIntegrado.semestre
              });
            }
          },
          error => {
            this.progress = false;
            this.messageService.add({
              severity: 'error',
              summary: 'Error',
              detail: error
            });
          }
        );
      }
    });
  }

  getEstadoColor(indice: number): string {
    switch (this.estados[indice]) {
      case 0:
        return '#808080';
      case 1:
        return '#daaa00';
      case 2:
        return '#4a773c';
      default:
        return '#808080';
    }
  }
}
