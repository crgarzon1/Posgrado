export class HistorialAcademico {
  public codigo: string;
  public nombre: string;
  public facultad: string;
  public documento: string;
  public planfin: string;
  public ciclos: Ciclo[] = [];
  public promedio: string;
  public bolsasDeCreditos: BolsaDeCreditos[] = [];
  public porcentajeCompletitud: number;
  public materiasAprobadas: Materia[] = [];
}

export class Ciclo {
  public anno: string;
  public cicloreal: string;
  public promedio: string;
  public planperiodo: string;
  public periodo_actualizacion: string;
  public materias: Materia[] = [];
  public sumatoriaCreditosAprobados: number;
  public sumatoriaCreditosCursados: number;
  public promedioAcumulado: number;
  public porcentajeCompletitud: number;
}

export class Materia {
  public codigo: string;
  public nombre: string;
  public creditos: string;
  public intensidad_horaria: string;
  public nota: number;
  public notadigito: string;
  public notadecimal: string;
}

export class BolsaDeCreditos {
  public codigo: string;
  public nombre: string;
  public creditosAprobados: number;
  public tope: number;
  public materias: MateriaBolsa[] = [];
}

export class MateriaBolsa {
  public codigo: string;
  public facultad: string;
  public nombre: string;
  public creditos: number;
  public intensidad_horaria: string;
  public nota: string;
  public notadigito: string;
  public notadecimal: string;
}
