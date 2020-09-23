export class PrematriculaEstudiante {
  public codFacultad: string;
  public nombreFacultad: string;
  public jornadaFacultad: string;
  public materias: Materia[];
}

export class Materia {
  public docente: string;
  public codMateria: string;
  public semestre: string;
  public creditos: string;
  public intencidadHoraria: string;
  public post: string;
  public propia: string;
  public nombreMateria: string;
  public indicador: string;
  public notas: Notas;
  public fallas: Fallas;
  public grupos: Grupo[];
  public planDeEstudiosActual: string;
}

export class Notas {
  public definitiva: string;
  public primerCorte: number;
  public segundoCorte: number;
  public tercerCorte: number;
}

export class Fallas {
  public primerCorte: number;
  public segundoCorte: number;
  public tercerCorte: number;
  public fallasTotales: number;
  public perdidaPorFallas: string;
}

export class Grupo {
  public grupo: string;
  public materiaCursar: MateriaCursar;
  public horario: Horario[];
  public facultadCursar: FacultadCursar;
}

export class FacultadCursar {
  public codFacultad: string;
  public nombreFacultad: string;
  public sede: Sede;
}

export class Sede {
  public sede: string;
}

export class MateriaCursar {
  public codMateria: string;
  public nombreMateria: string;
  public syllabus: string;
}

export class Horario {
  public idDia: string;
  public dia: string;
  public hora: Hora[];
}

export class Hora {
  public inicio: string;
  public fin: string;
  public salon: string;
}
