export class Facultad {
  constructor(public codigoFacultad: string, public jornadaFacultad: string) {}

  public esValida(): boolean {
    return this.codigoFacultad != null && this.codigoFacultad != '' && this.jornadaFacultad != null && this.jornadaFacultad != '';
  }
}
