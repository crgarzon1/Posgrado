export class ProcesoAcademico {
  public plan: Plan[];
  public plan_estudio: string;
  public programa: string;
  public totalAsignaturasPlan: number;
  public maximoAsignaturasPorSemestre: number;
}

export class Plan {
  public semestre: string;
  public semestreValorOrdinal: string;
  public materias: Materia[];
}

export class Materia {
  public codigo: string;
  public nombre: string;
  public creditos: string;
  public intensidad_horaria: string;
  public semestre: string;
  public estado: number;
  public nota: number;
}
