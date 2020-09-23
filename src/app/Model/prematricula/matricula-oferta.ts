export class MatriculaOferta {
  public materia: Materia;
  public grupos: Grupo[];
  public bolsa: number;
  public inscrita: boolean = false;
}

export class Materia {
  public codigo: string;
  public semestre: string;
  public nombre: string;
  public creditos: string;
  public facultad: Facultad;
  public plan: string;
}

export class Facultad {
  public codigo: string;
  public jornada: string;
  public nombre: string;
  public abreviatura: string;
  public activa: string;
  public indicador: string;
}

export class Grupo {
  public id: string;
  public grupo: string;
  public abierto: string;
  public materia: Materia;
  public fechaInicial: string = '';
  public fechaFinal: string = '';
}
