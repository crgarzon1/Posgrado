export class PerfilUsuario {
  public id: string;
  public etiqueta: string;
  public etiqueta2: string;
  public token: string;
  public tokenSia: string;
  public codigoPerfil: string;
  public codigoFacultad: string;

  static esEstudiante(codigoPerfil: string) {
    return codigoPerfil == Perfil.estudiante;
  }

  static esUnidadAcademica(codigoPerfil: string) {
    return [
      Perfil.secretarioAcademico.toString(),
      Perfil.directorDePrograma.toString(),
      Perfil.asistenteDePrograma.toString()
    ].includes(codigoPerfil);
  }
}

enum Perfil {
  secretarioAcademico = '2',
  directorDePrograma = '3',
  asistenteDePrograma = '4',
  estudiante = '7'
}
