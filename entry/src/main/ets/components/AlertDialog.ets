@CustomDialog
export struct AlertCusDialog {
  alertDialogController: CustomDialogController
  text: string = ""
  // 成功回调
  successCall: () => void = () => {
  }
  // 失败回调
  cancelCall: () => void = () => {
  }

  build() {
    RelativeContainer() {
      Column() {
        Text(this.text)
          .textAlign(TextAlign.Center)
          .width("100%")
          .fontSize(15)
          .fontColor("#ff393939")
          .border({
            width: {
              top: 0,
              left: 0,
              right: 0,
              bottom: 1
            }, color: "#fff6f6f6"
          })
          .padding({ bottom: 20 })
          .margin({ top: 8, bottom: 20 })
        Row() {
          Text("取消")
            .fontSize(14)
            .fontColor("#ff4c4c4c")
            .textAlign(TextAlign.Center)
            .width("50%")
            .onClick(() => {
              this.cancelCall()
            })
          Text("前往")
            .fontSize(14)
            .fontColor("#ff406fff")
            .textAlign(TextAlign.Center)
            .width("50%")
            .onClick(() => {
              this.successCall()
            })
        }.width("100%")
      }
      .width(300)
      .backgroundColor("#fff")
      .borderRadius(15)
      .padding(20)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .width("100%")
    .height("100%")
  }
}