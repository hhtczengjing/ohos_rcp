import { rcp } from "@kit.RemoteCommunicationKit";
import { RcpRequestOptions } from "../RcpClient";
import { HTTPHeaders } from "./HTTPHeaders";

export enum HTTPMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE',
  PATCH = 'PATCH',
  HEAD = 'HEAD',
  OPTIONS = 'OPTIONS'
}

export class Request {
  private _rawRequest: rcp.Request | undefined = undefined;
  private _url: string = "";
  private _timestamp: number = Date.now();
  private _method: HTTPMethod = HTTPMethod.GET;
  private _headers: HTTPHeaders | undefined = undefined;
  private _content: object | string | undefined = undefined;
  private _options: RcpRequestOptions | undefined = undefined;

  constructor(request: rcp.Request, options?: RcpRequestOptions) {
    this._rawRequest = request;
    this._url = request.url.toString();
    this._timestamp = Date.now();
    this._method = request.method as HTTPMethod;
    this._headers = new HTTPHeaders(request.headers);
    this._content = request.content;
    this._options = options;
  }

  static create(url: string, method: HTTPMethod, headers?: HTTPHeaders, parameters?: object, options?: RcpRequestOptions): Request {
    const req = new rcp.Request(url, method, headers?.headers, parameters);
    const request = new Request(req, options);
    return request;
  }

  public get toRequest(): rcp.Request | undefined {
    return this._rawRequest;
  }

  public get id(): string {
    return this.toRequest?.id ?? '0';
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
    if (this.options && this.options.headers) {
      if (this._headers) {
        this._headers = HTTPHeaders.concat(this._headers, this.options.headers);
      } else {
        this._headers = this.options.headers;
      }
    }
    return this._headers;
  }

  public set content(value: object | string | undefined) {
    this._content = value;
  }

  public get content(): object | string | undefined {
    return this._content;
  }

  public set timestamp(value: number) {
    this._timestamp = value;
  }

  public get timestamp(): number {
    return this._timestamp;
  }

  public get options(): RcpRequestOptions | undefined {
    return this._options;
  }

  public set options(value: RcpRequestOptions | undefined) {
    this._options = value;
  }
}