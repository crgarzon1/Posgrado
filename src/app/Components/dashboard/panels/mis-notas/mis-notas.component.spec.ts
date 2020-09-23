import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MisNotasComponent } from './mis-notas.component';

describe('MisNotasComponent', () => {
  let component: MisNotasComponent;
  let fixture: ComponentFixture<MisNotasComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [MisNotasComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MisNotasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
