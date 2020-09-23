import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CreditosAdicionalesComponent } from './creditos-adicionales.component';

describe('CreditosAdicionalesComponent', () => {
  let component: CreditosAdicionalesComponent;
  let fixture: ComponentFixture<CreditosAdicionalesComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [CreditosAdicionalesComponent]
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CreditosAdicionalesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
