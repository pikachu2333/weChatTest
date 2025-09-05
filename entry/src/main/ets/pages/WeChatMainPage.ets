import { ChatItem } from '../model/ChatItem';
import { chatDataMgr } from '../model/ChatDataMgr';
import { SwipeDelWrapper } from '../view/SwipeDelWrapper';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct WeChatMainPage {
  @State @Watch('doRefresh') isRefresh: boolean = false;
  @State chats: ChatItem[] = [];
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.chats = chatDataMgr.page(0, 20);
  }

  // 下拉刷新回调
  doRefresh() {
    if (this.isRefresh) {
      setTimeout(() => {
        this.chats = chatDataMgr.refresh();
        this.isRefresh = false;
      }, 800);
    }
  }

  build() {
    Column() {
      this.TopBar();
      this.ChatList();
      this.TabBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED');
  }

  @Builder
  TopBar() {
    Row() {
      Text('微信').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 16 });
      Blank();
      Image($r('app.media.ic_search')).width(24).height(24).margin({ right: 16 });
      Image($r('app.media.ic_add')).width(24).height(24).margin({ right: 16 });
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ChatList() {
    // 低版本 Refresh 只有 refreshing / offset
    Refresh({
      refreshing: this.isRefresh,
      offset: 64
    }) {
      List({ space: 0, scroller: this.scroller }) {
        if (this.chats.length === 0) {
          ListItem() { EmptyPlaceholder(); }
        }
        ForEach(this.chats, (item: ChatItem, idx: number) => {
          ListItem() {
            SwipeDelWrapper({
              content: () => { ChatRow({ item }); },
              onDelete: () => {
                animateTo({ duration: 250 }, () => { this.chats.splice(idx, 1); });
              }
            });
          }
        }, (item: ChatItem) => item.id.toString());
      }
      .layoutWeight(1)
      .width('100%')
      .onReachEnd(() => {
        const more = chatDataMgr.page(this.chats.length, 15);
        if (more.length) this.chats.push(...more);
      });
    }
  }

  @Builder
  TabBar() {
    Row() {
      TabItem({ icon: $r('app.media.ic_wechat_active'), title: '微信', active: true });
      TabItem({ icon: $r('app.media.ic_contacts'),   title: '通讯录', active: false });
      TabItem({ icon: $r('app.media.ic_discover'),   title: '发现', active: false });
      TabItem({ icon: $r('app.media.ic_me'),         title: '我', active: false });
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
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

@Component
struct ChatRow {
  @Prop item: ChatItem;

  build() {
    Row() {
      Image($r('app.media.ic_avatar'))
        .width(48).height(48).borderRadius(24).margin({ right: 12, left: 16 });
      Column() {
        Row() {
          Text(this.item.name).fontSize(16).fontWeight(FontWeight.Medium).flexShrink(1);
          Blank();
          Text(this.item.time).fontSize(12).fontColor('#999999');
        }
        Row() {
          Text(this.item.message).fontSize(14).fontColor('#666666').maxLines(1).flexShrink(1);
          Blank();
          if (this.item.unread > 0) {
            Text(this.item.unread.toString())
              .fontSize(12).fontColor(Color.White)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#FA5151').borderRadius(10)
              .onClick(() => { this.item.unread = 0; });
          }
        }
        .width('100%').margin({ top: 4 });
      }
      .layoutWeight(1).height(68);
    }
    .width('100%').height(80)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#EEEEEE' })
    .onClick(() => {
      // 跳转 + 传参
      router.push({
        url: 'pages/ChatDetailPage',
        params: { chatId: this.item.id, chatName: this.item.name }
      });
      // 清零未读
      this.item.unread = 0;
    });
  }
}

@Component
struct EmptyPlaceholder {
  build() {
    Column() {
      // 用系统图标先跑通，后续换自己的 ic_empty
      Image($r('sys.media.ohos_ic_public_more'))
        .width(120).height(120).opacity(0.3);
      Text('暂无会话').fontSize(14).fontColor('#999999').margin({ top: 12 });
    }
    .width('100%')
    .padding({ top: 120 })
    .alignItems(HorizontalAlign.Center);
  }
}