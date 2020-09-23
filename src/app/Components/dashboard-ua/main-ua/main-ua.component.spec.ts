import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MainUaComponent } from './main-ua.component';

describe('MainUaComponent', () => {
  let component: MainUaComponent;
  let fixture: ComponentFixture<MainUaComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [MainUaComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MainUaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
