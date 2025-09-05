@Component
export struct SwipeDelWrapper {
  /* 1. 给 BuilderParam 一个运行时独立的默认值 */
  @BuilderParam content: () => void = this.defaultContent;

  onDelete: () => void = () => {};

  @State offsetX: number = 0;

  /* 2. 默认空 Builder */
  @Builder
  defaultContent() {}

  build() {
    Stack() {
      Row() {
        Blank();
        Text('删除')
          .width(80)
          .height('100%')
          .backgroundColor('#FF3B30')
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onDelete());
      }

      Row() {
        this.content();
      }
      .offset({ x: this.offsetX })
      .gesture(
        PanGesture()
          .onActionUpdate((e: GestureEvent) => {
            const x = e.offsetX;
            if (x < 0) this.offsetX = x;
          })
          .onActionEnd(() => {
            animateTo({ curve: Curve.EaseOut, duration: 200 }, () => {
              this.offsetX = this.offsetX < -40 ? -80 : 0;
            });
          })
      )
    }
    .width('100%')
    .clip(true);
  }
}