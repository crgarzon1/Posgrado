import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MatriculadosTipoEstudianteComponent } from './matriculados-tipo-estudiante.component';

describe('MatriculadosTipoEstudianteComponent', () => {
  let component: MatriculadosTipoEstudianteComponent;
  let fixture: ComponentFixture<MatriculadosTipoEstudianteComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [MatriculadosTipoEstudianteComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MatriculadosTipoEstudianteComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
