import { Component, OnInit, Input } from '@angular/core';
import { Router } from '@angular/router';
import { CookieService } from 'ngx-cookie-service';
import { ObservableMatricula, IObserverMatricula } from 'src/app/Model/prematricula/observable-matricula';
import { GeneralService } from 'src/app/Services/general.service';

@Component({
  selector: 'app-main-matricula',
  templateUrl: './main-matricula.component.html',
  styleUrls: ['./main-matricula.component.scss']
})
export class MainMatriculaComponent implements OnInit, IObserverMatricula {
  public progress: boolean = false;
  public obsMatricula: ObservableMatricula;
  @Input() estudiante: any;

  constructor(private service: GeneralService, private router: Router, private cookie: CookieService) {
    this.obsMatricula = ObservableMatricula.getInstance(service);
    this.obsMatricula.addObserver(this);

    let token = this.cookie.get('wUFAnew4');
    if (!token) {
      this.router.navigateByUrl('login');
    }
  }

  refrescarDatos() {}

  indicarCambioForzoso() {}

  ngOnInit() {}

  changeShowProgress($event) {
    this.progress = $event;
  }
}
