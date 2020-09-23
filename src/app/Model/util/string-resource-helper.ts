import StringResource from 'src/assets/es.json';

export class StringResourceHelper {
  constructor(private rootNode: string) {}

  public getResource(nodeLeaf: string) {
    return StringResource[this.rootNode][nodeLeaf];
  }
}
