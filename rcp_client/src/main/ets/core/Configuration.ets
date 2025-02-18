import { HTTPHeaders } from "./HTTPHeaders";
import { util } from "@kit.ArkTS";

export class Configuration {
  /**
   * 超时时间
   */
  timeout?: number;;
  /**
   * 请求地址
   */
  baseURL?: string;
  /**
   * 请求头
   */
  headers?: HTTPHeaders;
  /**
   * 请求追踪标识符，针对单个请求有效，用于取消请求，如不指定会自动创建一个
   */
  traceId: string;

  constructor() {
    this.headers = new HTTPHeaders();
    this.traceId = Date.now().toString() + util.generateRandomUUID(true);
  }
}