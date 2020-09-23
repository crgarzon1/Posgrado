import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MisAsignaturasComponent } from './mis-asignaturas.component';

describe('MisAsignaturasComponent', () => {
  let component: MisAsignaturasComponent;
  let fixture: ComponentFixture<MisAsignaturasComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [MisAsignaturasComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MisAsignaturasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
