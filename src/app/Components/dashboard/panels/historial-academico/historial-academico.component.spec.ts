import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { HistorialAcademicoComponent } from './historial-academico.component';

describe('HistorialAcademicoComponent', () => {
  let component: HistorialAcademicoComponent;
  let fixture: ComponentFixture<HistorialAcademicoComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [HistorialAcademicoComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(HistorialAcademicoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
