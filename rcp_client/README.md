# ohos_rcp

rcp adapter for HarmonyOS.

## 安装

```shell
ohpm i @devzeng/rcp_client
```

OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

## 使用

### 创建实例

```javascript
const client = new RcpClient();
```

### 拦截器

```javascript
// 添加拦截器
client.addInterceptor(new InterceptorHandler());

// 拦截器实现类
export class InterceptorHandler implements Interceptor {
    doRequest(context: Request): Promise<Request> {
        // 可通过 request.options 获取请求的自定义参数配置，如自定义请求头、是否需要加密等
        // const options = request.options as RcpRequestOptions; 
        // ...
        return Promise.resolve(context);
    }

    doResponse(context: Response): Promise<Response> {
        // 可通过 request.options 获取请求的自定义参数配置，如是否需要解密等
        // const options = request.options as RcpRequestOptions; 
        // ...
        return Promise.resolve(context);
    }
}
```

### 发起请求

```javascript
// 发起GET请求
const params = { 'postId': 1 } as Record<string, string|number>;
client.get('https://jsonplaceholder.typicode.com/comments', params).then((response) => {
    console.log(JSON.stringify(response));
}).catch((error: BusinessError) => {
    console.error(JSON.stringify(error));
});

// 发起POST请求
const data = { 'title': 'foo', 'body': 'bar', 'userId': 1 } as Record<string, string|number>;
client.post('https://jsonplaceholder.typicode.com/posts', data).then((response) => {
    console.log(JSON.stringify(response));
}).catch((error: BusinessError) => {
    console.error(JSON.stringify(error));
});
```