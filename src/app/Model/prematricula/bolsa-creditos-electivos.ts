import { MatriculaOferta } from './matricula-oferta';

export class BolsaCreditosElectivos {
  public id: string = '';
  public nombre: string = '';
  public asignaturasDisponibles: MatriculaOferta[] = [];
  public facultades: any[] = [];
}
