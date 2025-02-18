import { rcp } from "@kit.RemoteCommunicationKit";

type HTTPHeadersValue = string | string[] | undefined;

export class HTTPHeaders {
  private _headers: rcp.RequestHeaders;

  constructor(headers?: Record<string, HTTPHeadersValue>) {
    if (!headers) {
      headers = {
        "Content-Type": 'application/json',
        "Accept": 'application/json'
      } as Record<string, HTTPHeadersValue>;
    }
    this._headers = headers
  }

  public get headers(): rcp.RequestHeaders {
    return this._headers;
  }

  set(headerName: string, value: HTTPHeadersValue): HTTPHeaders {
    this._headers[headerName] = value;
    return this
  }

  get(headerName: string): HTTPHeadersValue {
    return this._headers[headerName];
  }

  static concat(...targets: Array<HTTPHeaders|Record<string, HTTPHeadersValue>>): HTTPHeaders {
    const headers = new HTTPHeaders();
    for (const target of targets) {
      if (target instanceof HTTPHeaders) {
        for (const key of Object.keys(target.headers)) {
          headers.set(key, target.get(key));
        }
      } else if (typeof target === "object") {
        for (const key of Object.keys(target)) {
          headers.set(key, target[key]);
        }
      }
    }
    return headers;
  }
}