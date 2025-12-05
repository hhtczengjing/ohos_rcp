export class UrlHelper {
  static getUrl(url: string, data?: object): string {
    if (!data) return url;

    let newUrl = url;
    const params = Object.keys(data).map(k => `${k}=${encodeURIComponent(data[k])}`).join('&');
    if (newUrl.indexOf('?') != -1) {
      newUrl += '&' + params;
    } else {
      newUrl += '?' + params;
    }
    return newUrl;
  }
}