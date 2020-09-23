import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MainMatriculaComponent } from './main-matricula.component';

describe('MainMatriculaComponent', () => {
  let component: MainMatriculaComponent;
  let fixture: ComponentFixture<MainMatriculaComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [MainMatriculaComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MainMatriculaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
