// ============================================================
// GroupCard.ets
// 公共组件 — 组卡片展示
// 用于首页组列表展示
// ============================================================

import { Group, Role } from '../models/types'

@Component
export struct GroupCard {
  @Prop group: Group = {} as Group
  @Prop myRole: Role = 'member'

  build() {
    Column() {
      Row() {
        // 左侧图标占位
        Stack() {
          Text('🏠')
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#E8F4FD')

        Column() {
          // 组名 + 角色标签
          Row() {
            Text(this.group.name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')

            Text(this.roleLabel())
              .fontSize(11)
              .fontColor(this.roleColor())
              .backgroundColor(this.roleBgColor())
              .borderRadius(6)
              .padding({ left: 6, right: 6 })
              .margin({ left: 8 })
          }
          .width('100%')

          // 邀请码
          Text(`邀请码: ${this.group.inviteCode}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })

          // 功能标签
          Text(this.featureLabels())
            .fontSize(11)
            .fontColor('#4A9EF5')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetY: 2
    })
    .onClick(() => {
      // 由外部处理跳转
      this.onGroupClick()
    })
  }

  /** 角色显示文本 */
  private roleLabel(): string {
    switch (this.myRole) {
      case 'owner': return '创建者'
      case 'admin': return '管理员'
      default: return '成员'
    }
  }

  /** 角色文字颜色 */
  private roleColor(): string {
    switch (this.myRole) {
      case 'owner': return '#FFFFFF'
      case 'admin': return '#4A9EF5'
      default: return '#666666'
    }
  }

  /** 角色背景色 */
  private roleBgColor(): string {
    switch (this.myRole) {
      case 'owner': return '#4A9EF5'
      case 'admin': return '#E8F4FD'
      default: return '#F5F5F5'
    }
  }

  /** 功能标签拼接 */
  private featureLabels(): string {
    if (!this.group.enabledFeatures || this.group.enabledFeatures.length === 0) {
      return '暂无功能'
    }
    const labelMap: Record<string, string> = {
      'schedule': '排班'
    }
    return this.group.enabledFeatures.map(f => labelMap[f] ?? f).join(' · ')
  }

  /** 组卡片点击回调 — 由父组件注入 */
  private onGroupClick(): void {
    // 占位：父组件可通过 @Link 或回调注入
  }
}
