export class EstudianteBusqueda {
  public codigo: string;
  public nombre: string;
  public matricula: Matricula;
  public facultad: Facultad;
  public plan: Plan;
  public nombreCompuesto: string;
}
export class Matricula {
  public id: number;
  public periodo: string;
  public indicador_pago: string;
}

export class Facultad {
  public codigo: string;
  public jornada: string;
  public nombre: string;
  public abreviatura: string;
  public activa: string;
  public indicador: string;
}

export class Plan {
  public id: string;
  public plan: string;
}
