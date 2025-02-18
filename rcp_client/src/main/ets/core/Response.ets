import { rcp } from "@kit.RemoteCommunicationKit";

export class Response {
  private _rawResponse: rcp.Response | undefined = undefined;
  request: rcp.Request;

  constructor(response: rcp.Response) {
    this._rawResponse = response;
    this.request = response?.request;
  }

  public get statusCode(): number {
    return this._rawResponse?.statusCode ?? 0;
  }

  public get headers(): rcp.RequestHeaders {
    return this._rawResponse?.headers ?? {};
  }

  public toString(): string {
    return this._rawResponse?.toString() ?? "";
  }

  public toJSON(): object | null {
    return this._rawResponse?.toJSON() as object | null;
  }
}