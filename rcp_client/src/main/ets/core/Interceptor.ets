import { BusinessError } from "@kit.BasicServicesKit";
import { Request } from "./Request";
import { Response } from "./Response";
import { rcp } from "@kit.RemoteCommunicationKit";

const TAG = "[RequestInterceptor]";

export class RequestInterceptor implements rcp.Interceptor {
  private _handler?: Interceptor = undefined;

  constructor(handler?: Interceptor) {
    this._handler = handler;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    if (!this._handler) {
      return next.handle(context);
    }

    try {
      const newReq: Request | undefined = await this._handler?.doRequest(new Request(context.request));
      if (newReq) {
        if (newReq.headers) {
          context.request.headers = newReq.headers.headers as rcp.RequestHeaders;
        }
        if (newReq.content) {
          context.request.content = newReq.content;
        }
      }
      return next.handle(context);
    } catch (err) {
      const e = err as BusinessError;
      console.error(TAG, `Error in RequestInterceptor: ${e.message}`);
      return next.handle(context);
    }
  }
}

export class ResponseInterceptor implements rcp.Interceptor {
  private _handler?: Interceptor;

  constructor(handler?: Interceptor) {
    this._handler = handler;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    if (!this._handler) {
      return next.handle(context);
    }

    try {
      const resp = await next.handle(context);
      const newResp = await this._handler?.doResponse(new Response(resp));
      if (newResp) {
        return Promise.resolve(newResp as rcp.Response);
      } else {
        return Promise.resolve(resp);
      }
    } catch (err) {
      const e = err as BusinessError;
      console.error(TAG, `Error in ResponseInterceptor: ${e.message}`);
      return next.handle(context);
    }
  }
}

export interface Interceptor {
  doRequest(context: Request): Promise<Request>;

  doResponse(context: Response): Promise<Response>;
}