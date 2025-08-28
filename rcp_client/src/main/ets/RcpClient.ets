import { HTTPHeaders } from "./core/HTTPHeaders";
import { Interceptor } from "./core/Interceptor";
import { HTTPMethod } from "./core/Request";
import { Session, SessionOptions } from "./core/Session";

export interface RcpClientOptions {
  /**
   * 超时时间, 单位毫秒
   */
  timeout?: number;

  /**
   * 请求地址
   */
  baseURL?: string;
}

export interface RcpRequestOptions extends RcpClientOptions {
  /**
   * 请求头
   */
  headers?: HTTPHeaders;

  /**
   * 请求追踪标识符，针对单个请求有效，用于取消请求，如不指定会自动创建一个
   */
  traceId?: string;
}

export class RcpClient {
  private session: Session;

  constructor(options?: RcpClientOptions) {
    this.session = new Session(options as SessionOptions);
  }

  /**
   * 添加拦截器
   *
   * @param interceptor 拦截器对象, 拦截器会按照添加的顺序执行
   */
  addInterceptor(interceptor: Interceptor): void {
    this.session.addInterceptor(interceptor);
  }

  /**
   * 移除指定的拦截器
   *
   * @param interceptor 要移除的拦截器对象
   */
  removeInterceptor(interceptor: Interceptor): void {
    this.session.removeInterceptor(interceptor);
  }

  /**
   * 使用 GET 方法发送 HTTP 请求
   *
   * @param url 请求的 URL
   * @param config 请求的配置项（可选）
   *
   * @returns 返回一个 Promise，该 Promise 解析为请求返回的数据
   */
  get<R = object | null>(url: string, options?: RcpRequestOptions): Promise<R> {
    return this.session.request(url, HTTPMethod.GET, undefined, options);
  }

  /**
   * 使用 POST 方法发送 HTTP 请求
   *
   * @param url 请求的 URL
   * @param data 请求的数据（可选）
   * @param config 请求的配置项（可选）
   *
   * @returns 返回一个 Promise，该 Promise 解析为请求返回的数据
   */
  post<T = object | null, R = object | null>(url: string, data?: T, options?: RcpRequestOptions): Promise<R> {
    return this.session.request(url, HTTPMethod.POST, data, options);
  }

  /**
   * 使用 DELETE 方法发送 HTTP 请求
   *
   * @param url 请求的 URL
   * @param data 请求的数据（可选）
   * @param config 请求的配置项（可选）
   *
   * @returns 返回一个 Promise，该 Promise 解析为请求返回的数据
   */
  delete<T = object | null, R = object | null>(url: string, data?: T, options?: RcpRequestOptions): Promise<R> {
    return this.session.request(url, HTTPMethod.DELETE, data, options);
  }

  /**
   * 使用 PUT 方法发送 HTTP 请求
   *
   * @param url 请求的 URL
   * @param data 请求的数据（可选）
   * @param config 请求的配置项（可选）
   *
   * @returns 返回一个 Promise，该 Promise 解析为请求返回的数据
   */
  put<T = object | null, R = object | null>(url: string, data?: T, options?: RcpRequestOptions): Promise<R> {
    return this.session.request(url, HTTPMethod.PUT, data, options);
  }

  /**
   * 使用 PATCH 方法发送 HTTP 请求
   *
   * @param url 请求的 URL
   * @param data 请求的数据（可选）
   * @param config 请求的配置项（可选）
   *
   * @returns 返回一个 Promise，该 Promise 解析为请求返回的数据
   */
  patch<T = object | null, R = object | null>(url: string, data?: T, options?: RcpRequestOptions): Promise<R> {
    return this.session.request(url, HTTPMethod.PATCH, data, options);
  }

  /**
   * 取消指定请求
   *
   * @param traceId 请求的唯一追踪标识符
   */
  cancel(traceId: string): void {
    if (!traceId || typeof traceId !== "string") {
      return;
    }
    this.session.cancel([traceId]);
  }

  /**
   * 取消所有请求
   */
  cancelAll(): void {
    this.session.cancel();
  }
}