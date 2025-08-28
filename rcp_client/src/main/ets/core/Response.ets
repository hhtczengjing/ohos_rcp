import { rcp } from "@kit.RemoteCommunicationKit";
import { RcpRequestOptions } from "../RcpClient";

export class Response {
  private _rawResponse: rcp.Response | undefined = undefined;
  private _options: RcpRequestOptions | undefined = undefined;
  request: rcp.Request;

  constructor(response: rcp.Response, options?: RcpRequestOptions) {
    this._rawResponse = response;
    this._options = options;
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

  public get options(): RcpRequestOptions | undefined {
    return this._options;
  }

  public get response(): rcp.Response | undefined {
    return this._rawResponse;
  }
}