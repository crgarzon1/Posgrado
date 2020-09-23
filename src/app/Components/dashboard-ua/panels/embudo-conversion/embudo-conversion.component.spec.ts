import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { EmbudoConversionComponent } from './embudo-conversion.component';

describe('EmbudoConversionComponent', () => {
  let component: EmbudoConversionComponent;
  let fixture: ComponentFixture<EmbudoConversionComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [EmbudoConversionComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(EmbudoConversionComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
