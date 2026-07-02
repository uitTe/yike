// ============================================================
// MyPage.ets
// 「我的」页面 — 个人信息、设置入口
// ============================================================

import { promptAction } from '@kit.ArkUI'
import { User } from '../../models/types'

@Entry
@Component
struct MyPage {
  @State nickname: string = '用户'
  @State avatarUrl: string = ''
  @State groups: string[] = []

  build() {
    Column() {
      // 头部用户信息
      Column() {
        // 头像占位
        Stack() {
          Text('👤')
            .fontSize(36)
            .fontColor('#FFFFFF')
        }
        .width(72)
        .height(72)
        .borderRadius(36)
        .backgroundColor('#4A9EF5')

        Text(this.nickname)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ top: 12 })

        Text('家庭协作助手')
          .fontSize(13)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .width('100%')
      .padding({ top: 40, bottom: 30 })
      .alignItems(HorizontalAlign.Center)

      // 分组菜单
      Column() {
        this.menuItem('📋', '我的组', '查看和管理你的家庭组')
        this.menuItem('⚙️', '设置', '通知、隐私等全局设置')
        this.menuItem('❓', '帮助与反馈', '使用指南、常见问题')
        this.menuItem('📖', '关于', '版本信息')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }

  /** 菜单项构建器 */
  @Builder
  menuItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(22)
        .margin({ right: 14 })

      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Text(desc)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('›')
        .fontSize(20)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      this.onMenuClick(title)
    })
  }

  private onMenuClick(title: string): void {
    switch (title) {
      case '我的组':
        promptAction.showToast({ message: '跳转到我的组列表' })
        break
      case '设置':
        promptAction.showToast({ message: '打开全局设置' })
        break
      case '帮助与反馈':
        promptAction.showToast({ message: '打开帮助页面' })
        break
      case '关于':
        promptAction.showToast({ message: '家庭协作 V1.0.0' })
        break
    }
  }
}
