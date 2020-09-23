import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { AppRoutingModule } from './app-routing.module';
import { CookieService } from 'ngx-cookie-service';

// Componentes creados
import { AppComponent } from './app.component';
import { SafePipePipe } from './Pipes/safe-pipe.pipe';
import { MainDashboardComponent } from './Components/dashboard/main/main-prematricula.component';
import { MisAsignaturasComponent } from './Components/dashboard/panels/mis-asignaturas/mis-asignaturas.component';
import { HistorialAcademicoComponent } from './Components/dashboard/panels/historial-academico/historial-academico.component';
import { ProcesoAcademicoComponent } from './Components/dashboard/panels/proceso-academico/proceso-academico.component';
import { InfoPersonalComponent } from './Components/dashboard/panels/info-personal/info-personal.component';
import { PendientesComponent } from './Components/dashboard/panels/pendientes/pendientes.component';
import { MisNotasComponent } from './Components/dashboard/panels/mis-notas/mis-notas.component';
import { MisCursosComponent } from './Components/dashboard/panels/mis-cursos/mis-cursos.component';
import { MainMatriculaComponent } from './Components/prematricula/main/main-matricula.component';
import { OfertaComponent } from './Components/prematricula/oferta/oferta.component';
import { CreditosComponent } from './Components/prematricula/creditos/creditos.component';
import { MatriculaComponent } from './Components/prematricula/matricula/matricula.component';
import { MainUaComponent } from './Components/dashboard-ua/main-ua/main-ua.component';
import { EmbudoConversionComponent } from './Components/dashboard-ua/panels/embudo-conversion/embudo-conversion.component';
import { MatriculadosTipoEstudianteComponent } from './Components/dashboard-ua/panels/matriculados-tipo-estudiante/matriculados-tipo-estudiante.component';
import { EstadoNotasComponent } from './Components/dashboard-ua/panels/estado-notas/estado-notas.component';
import { MainMenuComponent } from './Components/menu/main-menu/main-menu.component';
import { LoginComponent } from './Components/menu/login/login.component';
import { CreditosAdicionalesComponent } from './Components/creditos-adicionales/creditos-adicionales/creditos-adicionales.component';
import { IntegradosComponent } from './Components/integrados/integrados/integrados.component';
import { DummyComponent } from './Components/dummy/dummy.component';

// Plugins externos
import 'chartjs-chart-box-and-violin-plot/build/Chart.BoxPlot.js';
import { BoxplotComponent } from './Components/dashboard-ua/panels/boxplot/boxplot.component';

// Componentes PrimeNg
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { PanelModule } from 'primeng/panel';
import { SelectButtonModule } from 'primeng/selectbutton';
import { ChartModule } from 'primeng/chart';
import { DialogModule } from 'primeng/dialog';
import { TableModule } from 'primeng/table';
import { DropdownModule } from 'primeng/dropdown';
import { TooltipModule } from 'primeng/tooltip';
import { CheckboxModule } from 'primeng/checkbox';
import { BlockUIModule } from 'primeng/blockui';
import { TabViewModule } from 'primeng/tabview';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule } from 'primeng/toast';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { MenubarModule } from 'primeng/menubar';
import { InputTextModule } from 'primeng/inputtext';
import { ToolbarModule } from 'primeng/toolbar';
import { MegaMenuModule } from 'primeng/megamenu';
import { SlideMenuModule } from 'primeng/slidemenu';
import { SidebarModule } from 'primeng/sidebar';
import { SplitButtonModule } from 'primeng/splitbutton';
import { InplaceModule } from 'primeng/inplace';
import { AutoCompleteModule } from 'primeng/autocomplete';
import { ListboxModule } from 'primeng/listbox';
import { MultiSelectModule } from 'primeng/multiselect';
import { OverlayPanelModule } from 'primeng/overlaypanel';

@NgModule({
  declarations: [
    AppComponent,
    MainDashboardComponent,
    MainMatriculaComponent,
    InfoPersonalComponent,
    PendientesComponent,
    MisNotasComponent,
    MisCursosComponent,
    HistorialAcademicoComponent,
    ProcesoAcademicoComponent,
    OfertaComponent,
    CreditosComponent,
    MatriculaComponent,
    MainUaComponent,
    BoxplotComponent,
    EmbudoConversionComponent,
    SafePipePipe,
    MatriculadosTipoEstudianteComponent,
    EstadoNotasComponent,
    MainMenuComponent,
    LoginComponent,
    CreditosAdicionalesComponent,
    IntegradosComponent,
    MisAsignaturasComponent,
    DummyComponent
  ],
  imports: [
    TabViewModule,
    TooltipModule,
    DropdownModule,
    TableModule,
    DialogModule,
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    ButtonModule,
    CardModule,
    PanelModule,
    SelectButtonModule,
    ChartModule,
    CheckboxModule,
    BlockUIModule,
    ConfirmDialogModule,
    ToastModule,
    ProgressSpinnerModule,
    MenubarModule,
    InputTextModule,
    ToolbarModule,
    MegaMenuModule,
    SlideMenuModule,
    SidebarModule,
    SplitButtonModule,
    InplaceModule,
    AutoCompleteModule,
    ListboxModule,
    MultiSelectModule,
    OverlayPanelModule
  ],
  providers: [CookieService],
  bootstrap: [AppComponent]
})
export class AppModule {}
