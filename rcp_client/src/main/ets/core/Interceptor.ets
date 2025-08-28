import { BusinessError } from "@kit.BasicServicesKit";
import { Request } from "./Request";
import { Response } from "./Response";
import { rcp } from "@kit.RemoteCommunicationKit";
import { Contexts } from "./Contexts";
import { Logger } from "../utils/Logger";

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
      const rawReq = context.request
      const options = Contexts.shared().get(rawReq.id);
      const wrappedReq = new Request(rawReq, options);
      const newReq: Request | undefined = await this._handler?.doRequest(wrappedReq);
      if (newReq) {
        if (newReq.headers) {
          context.request.headers = newReq.headers?.headers as rcp.RequestHeaders;
        }
        if (newReq.content) {
          context.request.content = newReq.content;
        }
      }
      return next.handle(context);
    } catch (err) {
      const e = err as BusinessError;
      Logger.error(TAG, `Error in RequestInterceptor: ${e.message}`);
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
      const rawResp = await next.handle(context);
      const options = Contexts.shared().get(rawResp.request.id);
      const wrappedResp = new Response(rawResp, options);
      const newResp = await this._handler?.doResponse(wrappedResp);
      if (newResp) {
        return Promise.resolve(newResp.response as rcp.Response);
      } else {
        return Promise.resolve(rawResp);
      }
    } catch (err) {
      const e = err as BusinessError;
      Logger.error(TAG, `Error in ResponseInterceptor: ${e.message}`);
      return Promise.reject(e);
    }
  }
}

export interface Interceptor {
  /**
   * 处理请求
   *
   * @param request 原始的请求
   *
   * @returns 修改后的请求
   */
  doRequest(request: Request): Promise<Request>;

  /**
   * 处理响应
   *
   * @param response 原始的响应
   *
   * @returns 修改后的响应
   */
  doResponse(response: Response): Promise<Response>;
}