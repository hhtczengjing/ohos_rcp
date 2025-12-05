import { rcp } from '@kit.RemoteCommunicationKit';
import { HTTPMethod } from './Request';
import { BusinessError } from '@kit.BasicServicesKit';
import { Interceptor, RequestInterceptor, ResponseInterceptor } from './Interceptor';
import { RcpRequestOptions } from '../RcpClient';
import { Contexts } from './Contexts';
import { util } from '@kit.ArkTS';
import { UrlHelper } from '../utils/UrlHelper';

export interface SessionOptions {
  /**
   * 请求根地址
   */
  baseURL?: string;
  /**
   * 超时时间，单位毫秒
   */
  timeout?: number;
  /**
   * 通用的请求头
   */
  headers?: Record<string, string>;
}

export class Session {
  private requests: Map<string, rcp.Request> = new Map<string, rcp.Request>(); // 当前的请求队列
  private session: rcp.Session; // 远程调用会话
  private interceptors: rcp.Interceptor[] = []; // 默认内置的拦截器
  private _interceptors: Interceptor[] = []; // 用户自定义的拦截器
  private _options?: SessionOptions;
  private cfg: rcp.SessionConfiguration = {
    // 请求配置
    requestConfiguration: {
      // 数据传输行为
      transfer: {
        autoRedirect: true, // 指定HTTP客户端是否应自动遵循重定向
        timeout: {
          connectMs: this._options?.timeout ?? 5000, // 允许建立连接的最长时间
          transferMs: 20000, // 允许传输数据的最长时间
        },
      },
      tracing: {
        verbose: true
      }
    },
    // 请求头
    headers: this._options?.headers ?? {
      "Content-Type": "application/json"
    },
    // cookies
    cookies: {},
    // 连接配置
    connectionConfiguration: {
      maxConnectionsPerHost: 10, // 单个主机允许的最大并发 TCP 连接数（主机与主机名+端口号对相同）
      maxTotalConnections: 100 // 此会话中允许的最大同时 TCP 连接总数
    }
  };

  constructor(options?: SessionOptions) {
    this._options = options;
    if (options?.baseURL) {
      this.cfg.baseAddress = options.baseURL;
    }
    this.session = rcp.createSession(this.cfg);
  }

  addInterceptor(interceptor: Interceptor): void {
    this._interceptors = this._interceptors.filter((i) => i !== interceptor);
    this._interceptors.push(interceptor);
    this.rebuildSession();
  }

  removeInterceptor(interceptor: Interceptor): void {
    this._interceptors = this._interceptors.filter((i) => i !== interceptor);
    this.rebuildSession();
  }

  request<T = object | undefined, R = object>(url: string, method: HTTPMethod, data?: T, options?: RcpRequestOptions): Promise<R> {
    return new Promise((resolve, reject) => {
      if (!options) {
        options = {} as RcpRequestOptions;
      }
      if (!options.traceId) {
        const uuid = util.generateRandomUUID(true);
        options.traceId = (new Date).getTime() + uuid.toLowerCase().replaceAll('-', '');
      }
      let newUrl = url
      if (method === HTTPMethod.GET && data) {
        newUrl = UrlHelper.getUrl(url, data as object);
      }
      const traceId = options.traceId;
      const request = new rcp.Request(newUrl, method, options.headers?.headers, data as object);
      this.requests.set(traceId, request);
      Contexts.shared().add(request.id, options);
      if (!request) {
        reject({ code: -1, message: 'request create failed' });
        return;
      }
      this.session.fetch(request).then((response: rcp.Response) => {
        if (response.statusCode !== 200) {
          reject({ code: response.statusCode, message: JSON.stringify(response) });
          return;
        }
        const body = response.toJSON() as R;
        resolve(body);
      }).catch((error: BusinessError) => {
        reject(error);
      }).finally(() => {
        this.requests.delete(request.id);
        Contexts.shared().remove(request.id);
      });
    });
  }

  cancel(traceIds?: string[]): void {
    if (!traceIds || traceIds.length <= 0) {
      traceIds = Array.from(this.requests.keys());
    }
    for (const traceId of traceIds ?? []) {
      if (this.requests.has(traceId)) {
        const request = this.requests.get(traceId);
        if (request) {
          this.session.cancel(request);
          this.requests.delete(traceId);
        }
      }
    }
  }

  private rebuildSession() {
    const interceptors: rcp.Interceptor[] = [];
    for (let index = 0; index < this._interceptors.length; index++) {
      const handler = this._interceptors[index];
      interceptors.push(new RequestInterceptor(handler))
      interceptors.push(new ResponseInterceptor(handler))
    }
    if (interceptors && interceptors.length > 0) {
      this.cfg.interceptors = [...this.interceptors, ...interceptors];
      this.session = rcp.createSession(this.cfg);
    }
  }
}