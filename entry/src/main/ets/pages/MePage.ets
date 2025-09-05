import router from '@ohos.router';

@Entry
@Component
struct MePage {
  build() {
    Column() {
      Text('我').fontSize(20).fontWeight(FontWeight.Bold).width('100%').padding(16)
        .backgroundColor(Color.White).height(56);

      Text('个人信息 / 设置 / 关于').layoutWeight(1).width('100%').padding(16);

      this.TabBar();
    }
    .width('100%').height('100%').backgroundColor('#EDEDED');
  }

  @Builder TabBar() {
    Row() {
      TabItem({ icon: $r('app.media.ic_wechat_active'), title: '微信', active: false });
      TabItem({ icon: $r('app.media.ic_contacts'),   title: '通讯录', active: false });
      TabItem({ icon: $r('app.media.ic_discover'),   title: '发现', active: false });
      TabItem({ icon: $r('app.media.ic_me'),         title: '我', active: true });
    }
    .width('100%').height(56).backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceAround);
  }
}

/* 子组件：构造参数注入，ArkTS 不再要求初始化 */@Component
struct TabItem {
  public icon: Resource   = $r('app.media.ic_wechat_active');
  public title: string    = '';
  public active: boolean  = false;

  build() {
    Column() {
      Image(this.icon).width(24).height(24);
      Text(this.title).fontSize(12).fontColor(this.active ? '#07C160' : '#999999');
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.active) return; // 当前页不跳
      const map: Record<string, string> = {
        '微信': 'pages/WeChatMainPage',
        '通讯录': 'pages/ContactsPage',
        '发现': 'pages/DiscoverPage',
        '我': 'pages/MePage'
      };
      router.replaceUrl({ url: map[this.title] });
    });
  }
}