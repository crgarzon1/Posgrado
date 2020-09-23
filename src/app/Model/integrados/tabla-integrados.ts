import { FacultadesIntegrados } from './facultades-integrados';
import { PlanesIntegrados } from './planes-integrados';
import { MateriasIntegrados } from './materias-integrados';

export class TablaIntegrados {
  public programaIntegrado: FacultadesIntegrados;
  public planIntegrado: PlanesIntegrados;
  public materiaIntegrado: MateriasIntegrados;
  public semestre: string;
  public codigo: string;
  public creditos: string;
  public programaEncargado: FacultadesIntegrados;
  public planEncargado: PlanesIntegrados;
  public materiaEncargado: MateriasIntegrados;
}
