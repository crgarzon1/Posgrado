export class MenuUsuario {
  public label: string;
  public urlRef: string;
  public typeId: string;
  public params: Params[];
  public enabled: boolean;
  public items: MenuUsuario[];
}

export class Params {
  public idParametro: number;
  public identifier: string;
  public label: string;
  public key;
}

export class ValueParams {
  public key: string;
  public value: string;
}
