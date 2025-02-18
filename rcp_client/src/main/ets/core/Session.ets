import { Configuration } from './Configuration';
import { HTTPMethod } from './HTTPMethod';
import { rcp } from '@kit.RemoteCommunicationKit';
import { Request } from './Request';
import { BusinessError } from '@kit.BasicServicesKit';
import { Interceptor, RequestInterceptor, ResponseInterceptor } from './Interceptor';

export class Session {
  private requests: Map<string, rcp.Request> = new Map<string, rcp.Request>(); // 当前的请求队列
  private session: rcp.Session; // 远程调用会话
  private interceptors: rcp.Interceptor[] = []; // 默认内置的拦截器
  private _interceptors: Interceptor[] = []; // 用户自定义的拦截器
  private cfg: rcp.SessionConfiguration = {
    // 请求配置
    requestConfiguration: {
      // 数据传输行为
      transfer: {
        autoRedirect: true, // 指定HTTP客户端是否应自动遵循重定向
        timeout: {
          connectMs: 5000, // 允许建立连接的最长时间
          transferMs: 20000, // 允许传输数据的最长时间
        },
      },
      tracing: {
        verbose: true
      }
    },
    // 请求头
    headers: {
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

  constructor(config?: Configuration) {
    if (config?.baseURL) {
      this.cfg.baseAddress = config?.baseURL ?? '';
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

  request<T = object | undefined, R = object>(url: string, method: HTTPMethod, data?: T,
    config?: Configuration): Promise<R> {
    return new Promise((resolve, reject) => {
      if (!config) {
        config = new Configuration();
      }
      const traceId = config.traceId;
      const request: Request = Request.create(url, method, config.headers, data as object);
      const req: rcp.Request = request.toRequest as rcp.Request;
      this.requests.set(traceId, req);
      if (!req) {
        reject({ code: -1, message: 'request create failed' });
        return;
      }
      this.session.fetch(req)
        .then((response: rcp.Response) => {
          if (response.statusCode !== 200) {
            reject({ code: response.statusCode, message: JSON.stringify(response) });
            return;
          }
          const body = response.toJSON() as R;
          resolve(body);
        })
        .catch((error: BusinessError) => {
          reject(error);
        })
        .finally(() => {
          this.requests.delete(traceId);
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