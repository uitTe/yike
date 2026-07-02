// ============================================================
// Index.ets
// 首页 — 我的组列表
// 三个 Tab：常用 | 模块 | 我的
// ✅ 使用 HdsTabs + 沉浸光感（UIDesignKit）
// ============================================================

import { promptAction, router } from '@kit.ArkUI'
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit'
import { Group } from '../../models/types'
import { GroupCard } from '../../components/GroupCard'

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
  private tabsController: HdsTabsController = new HdsTabsController()

  // 模拟组数据
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
    }
  ]

  // 功能模块列表
  @State modules: ModuleItem[] = [
    { name: '排班', icon: '📅', enabled: true },
    { name: '记账', icon: '💰', enabled: false },
    { name: '待办', icon: '✅', enabled: false },
    { name: '公告', icon: '📢', enabled: false }
  ]

  build() {
    Stack() {
      // ===== 主内容区 =====
      Column() {
        this.buildNavBar()

        // 各 Tab 页面
        if (this.currentTab === 0) {
          this.buildGroupsPage()
        } else if (this.currentTab === 1) {
          this.buildModulesPage()
        } else {
          this.buildMyPage()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F6F8')

      // ===== HdsTabs 底部悬浮导航 =====
      HdsTabs({
        controller: this.tabsController,
        index: this.currentTab
      }) {
        TabContent()
          .tabBar(new BottomTabBarStyle('⭐', '常用'))

        TabContent()
          .tabBar(new BottomTabBarStyle('▦', '模块'))

        TabContent()
          .tabBar(new BottomTabBarStyle('👤', '我的'))
      }
      .barOverlap(true)                     // ✅ 关键：悬浮在内容上
      .barPosition(BarPosition.End)
      .vertical(false)
      .barFloatingStyle({
        barWidth: { mediumWidth: 320 },
        barBottomMargin: 24,
        gradientMask: {
          maskColor: '#66F1F3F5',
          maskHeight: 92
        },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,   // ✅ 沉浸光感
          materialLevel: hdsMaterial.MaterialLevel.EXQUISITE
        }
      })
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
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

  // ==================== 常用 Tab ====================
  @Builder
  buildGroupsPage() {
    Column() {
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

      List({ space: 12 }) {
        ForEach(this.groups, (group: Group) => {
          ListItem() {
            GroupCard({
              group: group,
              myRole: group.myRole ?? 'member'
            })
              .onClick(() => this.onGroupClick(group))
          }
        }, (group: Group) => group.id)

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
    .onClick(() => this.navigateToCreateGroup())
  }

  private onGroupClick(group: Group) {
    router.pushUrl({
      url: 'pages/group/GroupDetail',
      params: { groupId: group.id }
    }).catch(() => {
      promptAction.showToast({ message: '跳转失败', duration: 2000 })
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
        .onClick(() => this.onModuleClick(mod))
      }, (mod: ModuleItem) => mod.name)
    }
    .width('100%')
  }

  private onModuleClick(mod: ModuleItem) {
    if (mod.name === '排班' && mod.enabled) {
      router.pushUrl({
        url: 'pages/group/SchedulePage',
        params: { groupId: 'group_001' }
      }).catch(() => {
        promptAction.showToast({ message: '跳转失败', duration: 2000 })
      })
    } else if (!mod.enabled) {
      promptAction.showToast({ message: `${mod.name} 尚未开启`, duration: 2000 })
    }
  }

  // ==================== 我的 Tab ====================
  @Builder
  buildMyPage() {
    Column() {
      Text('我的页面')
        .fontSize(16)
        .fontColor('#333333')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 导航 ====================
  private navigateToCreateGroup() {
    router.pushUrl({
      url: 'pages/group/CreateGroupPage'
    }).catch(() => {
      promptAction.showToast({ message: '跳转失败', duration: 2000 })
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
          promptAction.showToast({ message: '跳转失败', duration: 2000 })
        })
      } else {
        promptAction.showToast({ message: `${this.name} 尚未开启`, duration: 2000 })
      }
    })
  }
}