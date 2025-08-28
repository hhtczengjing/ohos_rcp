export class Logger {

  public static error(tag: string, msg: string): void {
    console.error(tag, msg);
  }
}