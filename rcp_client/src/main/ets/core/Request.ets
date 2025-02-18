import { rcp } from "@kit.RemoteCommunicationKit";
import { Configuration } from "./Configuration";
import { HTTPHeaders } from "./HTTPHeaders";
import { HTTPMethod } from "./HTTPMethod";

export class Request {
  private _rawRequest: rcp.Request | undefined = undefined;
  private _url: string = "";
  private _timestamp: number = Date.now();
  private _method: HTTPMethod = HTTPMethod.GET;
  private _headers: HTTPHeaders | undefined = undefined;
  private _content: object | undefined = undefined;
  private _config: Configuration | undefined = undefined;

  constructor(request: rcp.Request) {
    this._rawRequest = request;
  }

  static create(url: string, method: HTTPMethod, headers?: HTTPHeaders, parameters?: object): Request {
    const req = new rcp.Request(url, method, headers?.headers, parameters);
    const request = new Request(req);
    return request;
  }

  public get toRequest(): rcp.Request | undefined {
    return this._rawRequest;
  }

  public set url(value: string) {
    this._url = value;
  }

  public get url(): string {
    return this._url;
  }

  public set method(value: HTTPMethod) {
    this._method = value;
  }

  public get method(): HTTPMethod {
    return this._method;
  }

  public set headers(value: HTTPHeaders | undefined) {
    this._headers = value;
  }

  public get headers(): HTTPHeaders | undefined {
    return this._headers;
  }

  public set content(value: object | undefined) {
    this._content = value;
  }

  public get content(): object | undefined {
    return this._content;
  }

  public set timestamp(value: number) {
    this._timestamp = value;
  }

  public get timestamp(): number {
    return this._timestamp;
  }
}