// ============================================================
// CreateGroupPage.ets
// 创建/加入组页面
// 支持新建家庭组或通过邀请码加入已有组
// ============================================================

import { promptAction, router } from '@kit.ArkUI'
import { callCreateGroup, callJoinGroup } from '../../utils/cloudHelper'

interface TabItem {
  label: string
  value: number
}

@Entry
@Component
struct CreateGroupPage {
  @State currentTab: number = 0
  @State groupName: string = ''
  @State inviteCode: string = ''
  @State creating: boolean = false
  private tabs: TabItem[] = [
    { label: '创建组', value: 0 },
    { label: '加入组', value: 1 }
  ]

  /** 创建组 */
  private async handleCreate() {
    if (!this.groupName.trim()) {
      promptAction.showToast({ message: '请输入组名称' })
      return
    }
    if (this.groupName.length > 20) {
      promptAction.showToast({ message: '组名称不超过20个字符' })
      return
    }

    this.creating = true

    // TODO: 替换为真实 userId
    const userId = 'user_demo'

    try {
      const result = await callCreateGroup(this.groupName.trim(), userId)
      if (result.code === 200 && result.data?.groupId) {
        promptAction.showToast({ message: '创建成功' })
        // 跳转到组详情
        router.pushUrl({
          url: 'pages/group/GroupDetail',
          params: { groupId: result.data.groupId }
        })
      } else {
        promptAction.showToast({ message: result.message || '创建失败' })
      }
    } catch (err) {
      promptAction.showToast({ message: '创建失败，请重试' })
    } finally {
      this.creating = false
    }
  }

  /** 加入组 */
  private async handleJoin() {
    const code = this.inviteCode.trim().toUpperCase().replace(/\s/g, '')
    if (code.length !== 6) {
      promptAction.showToast({ message: '请输入6位邀请码' })
      return
    }

    // TODO: 替换为真实 userId
    const userId = 'user_demo'

    try {
      const result = await callJoinGroup(code, userId)
      if (result.code === 200) {
        promptAction.showToast({ message: '加入成功' })
        router.back()
      } else {
        promptAction.showToast({ message: result.message || '加入失败' })
      }
    } catch (err) {
      promptAction.showToast({ message: '加入失败，请重试' })
    }
  }

  build() {
    Column() {
      // 顶部 Tab 切换
      Row() {
        ForEach(this.tabs, (tab: TabItem) => {
          Text(tab.label)
            .fontSize(15)
            .fontWeight(this.currentTab === tab.value ? FontWeight.Bold : FontWeight.Regular)
            .fontColor(this.currentTab === tab.value ? '#4A9EF5' : '#999999')
            .width('50%')
            .textAlign(TextAlign.Center)
            .padding({ top: 12, bottom: 12 })
            .onClick(() => {
              this.currentTab = tab.value
            })
        }, (tab: TabItem) => tab.label)

        // 下划线指示器
        if (this.currentTab === 0) {
          Rect()
            .width(32)
            .height(3)
            .borderRadius(1.5)
            .backgroundColor('#4A9EF5')

            .position({ top: 44 })
        } else {
          Rect()
            .width(32)
            .height(3)
            .borderRadius(1.5)
            .backgroundColor('#4A9EF5')

            .position({ top: 44, x: '50%' })
        }
      }
      .width('100%')
      .position({ x: 0, y: 0 })

      Column({ space: 20 }) {
        if (this.currentTab === 0) {
          // ========== 创建组表单 ==========
          Column({ space: 16 }) {
            Text('组名称')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')

            TextInput({ placeholder: '输入组名称，如：我家' })
              .width('100%')
              .height(44)
              .fontSize(15)
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .onChange((value: string) => {
                this.groupName = value
              })

            Text('创建组后将自动成为组创建者（Owner），拥有最高权限')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .lineHeight(18)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)

          Button(this.creating ? '创建中...' : '创建组')
            .width('85%')
            .height(46)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor(this.creating ? '#A0C4F0' : '#4A9EF5')
            .borderRadius(23)
            .enabled(!this.creating)
            .onClick(() => this.handleCreate())
        } else {
          // ========== 加入组表单 ==========
          Column({ space: 16 }) {
            Text('邀请码')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')

            TextInput({ placeholder: '输入6位邀请码' })
              .width('100%')
              .height(44)
              .fontSize(15)
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .maxLength(6)
              .onChange((value: string) => {
                this.inviteCode = value.toUpperCase()
              })

            Text('邀请码由组创建者提供，请联系家人获取')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .lineHeight(18)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)

          Button('加入组')
            .width('85%')
            .height(46)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#4A9EF5')
            .borderRadius(23)
            .onClick(() => this.handleJoin())
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
    .padding({ top: 20 })
  }
}
