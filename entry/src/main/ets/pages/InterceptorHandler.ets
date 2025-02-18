import { Interceptor, Request, Response } from "@devzeng/rcp_client";

export class InterceptorHandler implements Interceptor {
  doRequest(context: Request): Promise<Request> {
    return Promise.resolve(context);
  }

  doResponse(context: Response): Promise<Response> {
    return Promise.resolve(context);
  }
}