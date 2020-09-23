export class InformacionUsuario {
  public nombre: string;
  public propiedades: Propiedad[] = [];
}

export class Propiedad {
  public key: string;
  public value: string;
}
