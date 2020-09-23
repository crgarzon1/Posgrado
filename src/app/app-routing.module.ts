import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { LoginComponent } from './Components/menu/login/login.component';
import { MainMenuComponent } from './Components/menu/main-menu/main-menu.component';
import { DummyComponent } from './Components/dummy/dummy.component';

const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'mainMenu', component: MainMenuComponent },
  { path: 'dummy', component: DummyComponent }
];

/*const routes: Routes = [];*/

@NgModule({
  imports: [RouterModule.forRoot(routes, { useHash: true })], // Produccion
  // imports: [RouterModule.forRoot(routes)], //Local
  exports: [RouterModule]
})
export class AppRoutingModule {}
