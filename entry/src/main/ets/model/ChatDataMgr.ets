import { ChatItem } from './ChatItem';

export class ChatDataMgr {
  private total: ChatItem[] = [];

  constructor() {
    for (let i = 0; i < 100; i++) {
      this.total.push({
        id: i + 1,
        name: `用户${i + 1}`,
        message: `最新消息 ${i + 1}`,
        time: ['10:30', '昨天', '星期一'][i % 3],
        unread: i % 5
      });
    }
  }

  page(start: number, size: number): ChatItem[] {
    return this.total.slice(start, start + size);
  }

  refresh(): ChatItem[] {
    const top = this.total.slice(0, 20)
      .sort(() => Math.random() - 0.5);
    this.total.splice(0, 20, ...top);
    return this.page(0, 20);
  }
}

export const chatDataMgr = new ChatDataMgr();