import { Component } from '@angular/core';
import { GeneralService } from './Services/general.service';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
declare var gtag;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'Posgrado';
  constructor(private service: GeneralService, private router: Router) {
    service.getCodigoSession();
    const navEndEvent = this.router.events.pipe(filter(event => event instanceof NavigationEnd));
    navEndEvent.subscribe((event: NavigationEnd) => {
      gtag('config', 'UA-154216959-1', {
        page_path: event.urlAfterRedirects
      });
    });
  }
}
