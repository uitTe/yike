// ============================================================
// Index.ets
// 首页 — 我的组列表
// 三个 Tab：常用 | 模块 | 我的
// 对应 docs/开发流程梳理.md 中的 pages/index 结构
// ============================================================

import { promptAction, router } from '@kit.ArkUI'
import { Group, Role } from '../../models/types'
import { GroupCard } from '../../components/GroupCard'

interface TabItem {
  label: string
  icon: string
  value: number
}

/** 功能模块类型 */
interface ModuleItem {
  name: string
  icon: string
  enabled: boolean
}

@Entry
@Component
struct Index {
  @State currentTab: number = 0   // 0-常用 1-模块 2-我的

  // 模拟组数据（后续替换为 CloudDB 查询）
  @State groups: Group[] = [
    {
      id: 'group_001',
      name: '我家',
      creatorId: 'user_demo',
      inviteCode: 'ABC123',
      inviteCodeExpireTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      enabledFeatures: ['schedule'],
      createTime: new Date().toISOString(),
      myRole: 'owner'
    } as Group
  ]

  // 功能模块列表
  @State modules: ModuleItem[] = [
    { name: '排班', icon: '📅', enabled: true },
    { name: '记账', icon: '💰', enabled: false },
    { name: '待办', icon: '✅', enabled: false },
    { name: '公告', icon: '📢', enabled: false }
  ]

  // 底部页签
  private tabs: TabItem[] = [
    { label: '常用', icon: '⭐', value: 0 },
    { label: '模块', icon: '▦', value: 1 },
    { label: '我的', icon: '👤', value: 2 }
  ]

  build() {
    Column() {
      // 顶部导航栏
      this.buildNavBar()

      // 内容区
      Column() {
        if (this.currentTab === 0) {
          // ========== 常用 Tab: 组列表 ==========
          this.buildGroupsPage()
        } else if (this.currentTab === 1) {
          // ========== 模块 Tab ==========
          this.buildModulesPage()
        } else {
          // ========== 我的 Tab ==========
          // ========== 我的 Tab ==========
          // router.pushUrl({ url: 'pages/my/MyPage' })
          Column() {
            Text('我的页面')
              .fontSize(16)
              .fontColor('#333333')
          }

        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }

  // ==================== 顶部导航 ====================

  @Builder
  buildNavBar() {
    Row() {
      Text('壹刻')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(50)
    .backgroundColor('#FFFFFF')
  }

  // ==================== 常用 Tab: 组列表 ====================

  @Builder
  buildGroupsPage() {
    Column() {
      // 操作栏
      Row() {
        Text('我的组')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(`(${this.groups.length})`)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // 组卡片列表
      List({ space: 12 }) {
        ForEach(this.groups, (group: Group) => {
          ListItem() {
            GroupCard({
              group: group,
              myRole: group.myRole || 'member'
            })
            .onClick(() => {
              this.onGroupClick(group)
            })
          }
        }, (group: Group) => group.id)

        // 添加组按钮
        ListItem() {
          this.buildAddGroupButton()
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  /** 添加组按钮 */
  @Builder
  buildAddGroupButton() {
    Row() {
      Text('+')
        .fontSize(24)
        .fontColor('#4A9EF5')

      Text('创建/加入组')
        .fontSize(15)
        .fontColor('#4A9EF5')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(52)
    .borderRadius(16)
    .backgroundColor('#F5F8FF')
    .border({ width: 1, color: '#E0ECFA' })
    .onClick(() => {
      this.navigateToCreateGroup()
    })
  }

  /** 组卡片点击 */
  private onGroupClick(group: Group) {
    router.pushUrl({
      url: 'pages/group/GroupDetail',
      params: { groupId: group.id }
    }).catch((err: Error) => {
      promptAction.showToast({ message: '跳转失败' })
    })
  }

  // ==================== 模块 Tab ====================

  @Builder
  buildModulesPage() {
    Column() {
      Text('功能模块')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ bottom: 16 })

      this.GridRow()

      Text('在「设置」中开启更多功能模块')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 20 })
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  GridRow() {
    Row({ space: 12 }) {
      ForEach(this.modules, (mod: ModuleItem) => {
        Column() {
          Text(mod.icon)
            .fontSize(28)
            .margin({ bottom: 6 })

          Text(mod.name)
            .fontSize(13)
            .fontColor(mod.enabled ? '#333333' : '#CCCCCC')

          Text(mod.enabled ? '已开启' : '未开启')
            .fontSize(10)
            .fontColor(mod.enabled ? '#4A9EF5' : '#CCCCCC')
            .margin({ top: 2 })
        }
        .width(80)
        .height(80)
        .backgroundColor(mod.enabled ? '#FFFFFF' : '#F5F5F5')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({
          radius: mod.enabled ? 4 : 0,
          color: mod.enabled ? '#00000008' : '#00000000',
          offsetY: 1
        })
        .onClick(() => {
          this.onModuleClick(mod)
        })
      }, (mod: ModuleItem) => mod.name)
    }
    .width('100%')
  }

  /** 模块点击 */
  private onModuleClick(mod: ModuleItem) {
    if (mod.name === '排班' && mod.enabled) {
      router.pushUrl({
        url: 'pages/group/SchedulePage',
        params: { groupId: 'group_001' }
      }).catch(() => {
        promptAction.showToast({ message: '跳转失败' })
      })
    } else if (!mod.enabled) {
      promptAction.showToast({ message: `${mod.name} 尚未开启` })
    }
  }

  // ==================== 导航 ====================

  private navigateToCreateGroup() {
    router.pushUrl({
      url: 'pages/group/CreateGroupPage'
    }).catch(() => {
      promptAction.showToast({ message: '跳转失败' })
    })
  }
}

/** 单个 GridItem 组件 */
@Component
struct GridItemComponent {
  @Prop name: string = ''
  @Prop icon: string = ''
  @Prop moduleEnabled: boolean


  build() {
    Column() {
      Text(this.icon)
        .fontSize(28)
        .margin({ bottom: 6 })

      Text(this.name)
        .fontSize(13)
        .fontColor(this.moduleEnabled ? '#333333' : '#CCCCCC')

      Text(this.moduleEnabled ? '已开启' : '未开启')
        .fontSize(10)
        .fontColor(this.moduleEnabled ? '#4A9EF5' : '#CCCCCC')
        .margin({ top: 2 })
    }
    .width(80)
    .height(80)
    .backgroundColor(this.moduleEnabled ? '#FFFFFF' : '#F5F5F5')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: this.moduleEnabled ? 4 : 0,
      color: this.moduleEnabled ? '#00000008' : '#00000000',
      offsetY: 1
    })
    .onClick(() => {
      if (this.moduleEnabled) {
        router.pushUrl({
          url: 'pages/group/SchedulePage',
          params: { groupId: 'group_001' }
        }).catch(() => {
          promptAction.showToast({ message: '跳转失败' })
        })
      } else {
        promptAction.showToast({ message: `${this.name} 尚未开启` })
      }
    })
  }
}
