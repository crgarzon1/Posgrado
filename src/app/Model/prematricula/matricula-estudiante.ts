export class MatriculaEstudiante {
  public codigo: string;
  public nombre: string;
  public matricula: Matricula;
  public facultad: Facultad;
  public plan: Plan;
  public creditos_maximos: number;
  public semestre_inferior: number;
  public creditos_inscritos: number;
  public creditos_bolsa: number;
  public fecha_pivote: string;
  public fecha_inicio: string;
  public fecha_fin: string;
}

export class Matricula {
  public id: number;
  public periodo: string;
  public indicadorPago: string;
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
