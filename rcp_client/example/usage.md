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
        return Promise.resolve(context);
    }

    doResponse(context: Response): Promise<Response> {
        return Promise.resolve(context);
    }
}
```

### 发起请求

```javascript
// 发起GET请求
client.get('https://jsonplaceholder.typicode.com/posts').then((response) => {
    console.log(JSON.stringify(response));
}).catch((error: BusinessError) => {
    console.error(JSON.stringify(error));
});
// 发起POST请求
client.post('https://jsonplaceholder.typicode.com/posts', { 
    'title': 'foo',
    'body': 'bar',
    'userId': 1,
} as Record<string, string|number>).then((response) => {
    console.log(JSON.stringify(response));
}).catch((error: BusinessError) => {
    console.error(JSON.stringify(error));
});
```