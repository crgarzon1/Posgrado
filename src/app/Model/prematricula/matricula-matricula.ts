export class MatriculaMatricula {
  public materia: Materia;
  public bolsa: number;
  public grupos: Grupo;
}

export class Materia {
  public codigo: string;
  public semestre: string;
  public nombre: string;
  public creditos: number;
}

export class Grupo {
  public id: string;
  public indicador: string;
  public abierto: string;
  public materia: Materia;
}
