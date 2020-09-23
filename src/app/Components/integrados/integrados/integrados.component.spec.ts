import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { IntegradosComponent } from './integrados.component';

describe('IntegradosComponent', () => {
  let component: IntegradosComponent;
  let fixture: ComponentFixture<IntegradosComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [IntegradosComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(IntegradosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
