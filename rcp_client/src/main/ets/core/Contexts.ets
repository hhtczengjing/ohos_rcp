import { RcpRequestOptions } from "../RcpClient";

export class Contexts {
  private static instance: Contexts;
  private mappings: Map<string, RcpRequestOptions> = new Map<string, RcpRequestOptions>();

  public static shared(): Contexts {
    if (!Contexts.instance) {
      Contexts.instance = new Contexts();
    }
    return Contexts.instance;
  }

  public add(key: string, config: RcpRequestOptions) {
    this.mappings.set(key, config);
  }

  public get(key: string): RcpRequestOptions | undefined {
    return this.mappings.get(key);
  }

  public remove(key: string) {
    this.mappings.delete(key);
  }

  public clear() {
    this.mappings.clear();
  }
}