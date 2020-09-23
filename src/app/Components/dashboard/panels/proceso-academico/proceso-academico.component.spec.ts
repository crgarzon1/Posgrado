import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ProcesoAcademicoComponent } from './proceso-academico.component';

describe('ProcesoAcademicoComponent', () => {
  let component: ProcesoAcademicoComponent;
  let fixture: ComponentFixture<ProcesoAcademicoComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ProcesoAcademicoComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ProcesoAcademicoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
