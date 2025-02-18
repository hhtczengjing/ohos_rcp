import { RcpClient } from '@devzeng/rcp_client';
import { BusinessError } from '@kit.BasicServicesKit';
import { InterceptorHandler } from './InterceptorHandler';

@Extend(Text)
function headerStyle() {
  .textAlign(TextAlign.Start)
  .width('100%')
  .padding({ left: 16, right: 16 })
  .fontSize(16)
  .fontColor('#7E8388')
}

@Extend(Text)
function outputStyle() {
  .textAlign(TextAlign.Start)
  .width('100%')
  .margin({ top: 10 })
  .padding({ left: 16, right: 16 })
  .fontSize(16)
  .fontColor('#020F22')
}

@Extend(Button)
function btnStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Regular)
  .backgroundColor('#344F9C')
  .width('35%')
}

const client = new RcpClient();
client.addInterceptor(new InterceptorHandler())

@Entry
@Component
struct Index {
  @State output: string = '';

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Row() {
        Button('发起GET请求')
          .btnStyle()
          .onClick(() => {
            this.sendGetRequest();
          })
          .width('80%')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
      .margin({ top: 20 })
      .width('100%')

      Row() {
        Button('发起POST请求')
          .btnStyle()
          .onClick(() => {
            this.sendPostRequest();
          })
          .width('80%')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
      .margin({ top: 20 })
      .width('100%')

      if (this.output) {
        Scroll() {
          Column() {
            Text('Output')
              .headerStyle()

            if (this.output) {
              Text(`${this.output}`)
                .outputStyle()
                .margin({ top: 10 })
            }

            Blank()
          }
          .margin({ top: 20 })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .margin({ top: 20 })
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  private sendGetRequest() {
    client.get('https://jsonplaceholder.typicode.com/posts').then((response) => {
      console.log(JSON.stringify(response));
      this.output = JSON.stringify(response);
    }).catch((error: BusinessError) => {
      console.error(JSON.stringify(error));
      this.output = JSON.stringify(error);
    });
  }

  private sendPostRequest() {
    client.post('https://jsonplaceholder.typicode.com/posts', {
      'title': 'foo',
      'body': 'bar',
      'userId': 1,
    } as Record<string, string|number>).then((response) => {
      console.log(JSON.stringify(response));
      this.output = JSON.stringify(response);
    }).catch((error: BusinessError) => {
      console.error(JSON.stringify(error));
      this.output = JSON.stringify(error);
    });
  }
}