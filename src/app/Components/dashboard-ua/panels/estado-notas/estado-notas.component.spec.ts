import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { EstadoNotasComponent } from './estado-notas.component';

describe('EstadoNotasComponent', () => {
  let component: EstadoNotasComponent;
  let fixture: ComponentFixture<EstadoNotasComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [EstadoNotasComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EstadoNotasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
