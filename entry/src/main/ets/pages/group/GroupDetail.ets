// ============================================================
// GroupDetail.ets
// 组详情页 — 功能 Tabs + 管理按钮
// 根据 docs/开发流程梳理.md 中的 GroupDetail 示例完善
// ============================================================

import { promptAction } from '@kit.ArkUI'
import router from '@system.router'
import { Role, Group, GroupMember, Schedule, FeaturePermissions } from '../../models/types'
import { checkPermission, ensurePermission, isInviteCodeExpired, formatInviteCode } from '../../utils/cloudHelper'
import { GroupCard } from '../../components/GroupCard'

interface RouterParams {
  groupId?: string
}

@Entry
@Component
struct GroupDetail {
  @State group: Group = {} as Group
  @State myRole: Role = 'member'
  @State members: GroupMember[] = []
  @State currentTab: number = 0  // 0-排班 1-成员 2-设置
  @State isLoading: boolean = true
  private groupId: string = ''
  private tabs: string[] = ['排班', '成员', '设置']

  aboutToAppear() {
    const params = router.getParams() as RouterParams
    this.groupId = params?.groupId || ''
    this.loadGroupInfo()
    this.loadMyRole()
  }

  /** 加载组信息（实际项目中从 CloudDB 查询） */
  private async loadGroupInfo() {
    // TODO: 替换为真实 CloudDB 查询
    const groupData: Group = {
      id: this.groupId,
      name: '我家',
      creatorId: 'user_demo',
      inviteCode: 'ABC123',
      inviteCodeExpireTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      enabledFeatures: ['schedule'] as string[],
      featurePermissions: JSON.stringify({
        schedule: { member: 'self', admin: 'all', owner: 'all' }
      } as FeaturePermissions),
      createTime: new Date().toISOString(),
      myRole: 'owner'
    }
    this.group = groupData
    this.isLoading = false
  }

  /** 加载当前用户角色（实际项目中从 GroupMember 表查询） */
  private async loadMyRole() {
    // TODO: 替换为真实 CloudDB 查询
    this.myRole = 'owner'
    this.group.myRole = this.myRole
  }

  build() {
    Column() {
      if (this.isLoading) {
        // 加载中骨架屏
        Column() {
          Progress({ value: 50 })
            .width('30%')
            .color('#4A9EF5')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /** 正常内容区 */
  @Builder
  buildContent() {
    Column() {
      // ---- 组头信息 ----
      this.buildGroupHeader()

      // ---- 功能 Tabs ----
      Tabs({ index: this.currentTab }) {
        // Tab 0: 排班
        TabContent() {
          this.buildScheduleTab()
        }.tabBar('排班')

        // Tab 1: 成员管理
        TabContent() {
          this.buildMembersTab()
        }.tabBar('成员')

        // Tab 2: 组设置
        TabContent() {
          this.buildSettingsTab()
        }.tabBar('设置')
      }
      .zIndex(0)
      .onChange((index: number) => {
        this.currentTab = index
      })


    }
    .width('100%')
    .height('100%')
  }

  // ==================== 组头信息 ====================

  @Builder
  buildGroupHeader() {
    Column() {
      Row() {
        Text(this.group.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        // 编辑按钮（owner/admin）
        if (['owner', 'admin'].includes(this.myRole)) {
          Text('编辑')
            .fontSize(14)
            .fontColor('#4A9EF5')
            .onClick(() => {
              promptAction.showToast({ message: '编辑组信息' })
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // 邀请码行
      Row() {
        Text(`邀请码: ${formatInviteCode(this.group.inviteCode)}`)
          .fontSize(13)
          .fontColor('#666666')

        Text('复制')
          .fontSize(12)
          .fontColor('#4A9EF5')
          .margin({ left: 8 })
          .onClick(() => {
            promptAction.showToast({ message: `已复制邀请码: ${this.group.inviteCode}` })
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 邀请码过期提示
      if (isInviteCodeExpired(this.group.inviteCodeExpireTime)) {
        Text('邀请码已过期，请联系创建者重置')
          .fontSize(12)
          .fontColor('#FF6B6B')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ bottom: 8 })
      }

      // 功能标签
      Row() {
        Text(this.group.enabledFeatures.map(f => {
          return f === 'schedule' ? '排班' : f
        }).join(' · '))
          .fontSize(12)
          .fontColor('#4A9EF5')
      }
      .width('100%')
      .padding({ left: 16, bottom: 12 })
    }
    .backgroundColor('#FFFFFF')
  }

  // ==================== 排班 Tab ====================

  @Builder
  buildScheduleTab() {
    Column() {
      // 月份切换
      Row() {
        Text('‹')
          .fontSize(24)
          .fontColor('#666666')
          .width(40)
          .textAlign(TextAlign.Center)

        Text('2026年6月')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('›')
          .fontSize(24)
          .fontColor('#666666')
          .width(40)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ top: 16, bottom: 12 })

      // 星期头
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
          Text(day)
            .fontSize(12)
            .fontColor('#999999')
            .width(44)
            .textAlign(TextAlign.Center)
        }, (day: string) => day)
      }
      .width('100%')
      .padding({ bottom: 8 })

      // 日期网格（简化版 — 第一周）
      GridContainer({ columns: 7 }) {
        ForEach(Array.from<number>({ length: 35 }).map((_: number, i: number) => i + 1), (day: number) => {
          GridItem() {
            if (day <= 30) {
              Column() {
                Text(day.toString())
                  .fontSize(14)
                  .fontColor(day === 30 ? '#4A9EF5' : '#333333')
                  .fontWeight(day === 30 ? FontWeight.Bold : FontWeight.Regular)

                // 当天排班占位
                if (day === 15) {
                  Text('早')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#4A9EF5')
                    .borderRadius(4)
                    .padding({ left: 4, right: 4 })
                    .margin({ top: 2 })
                } else if (day === 16) {
                  Text('晚')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FF9800')
                    .borderRadius(4)
                    .padding({ left: 4, right: 4 })
                    .margin({ top: 2 })
                }
              }
              .width(44)
              .height(52)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
          }
        }, (day: number) => day.toString())
      }
      .width('100%')


      // 添加排班按钮
      if (['owner', 'admin'].includes(this.myRole)) {
        Button('+ 添加排班')
          .width('80%')
          .margin({ top: 20 })
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A9EF5')
          .borderRadius(20)
          .onClick(() => {
            promptAction.showToast({ message: '添加排班' })
          })
      }
    }
    .width('100%')
    .padding(16)
  }

  // ==================== 成员 Tab ====================

  @Builder
  buildMembersTab() {
    Column() {
      // 成员列表头部
      Row() {
        Text('成员管理')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(`(${this.members.length}人)`)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ bottom: 12 })

      // 成员列表
      List() {
        // Owner 行
        ListItem() {
          this.memberRow('创建者', 'owner', '你')
        }

        // Admin 行
        ListItem() {
          this.memberRow('管理员', 'admin', '张三')
        }

        // Member 行
        ListItem() {
          this.memberRow('成员', 'member', '李四')
        }
        ListItem() {
          this.memberRow('成员', 'member', '王五')
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
  }

  /** 单行成员 */
  @Builder
  memberRow(label: string, role: string, name: string) {
    Row() {
      // 头像占位
      Text(name.charAt(0))
        .fontSize(14)
        .fontColor('#FFFFFF')
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('#4A9EF5')
        .textAlign(TextAlign.Center)

      Column() {
        Text(name)
          .fontSize(15)
          .fontColor('#1A1A1A')
        Text(label)
          .fontSize(12)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      // 管理按钮（仅 owner 可见）
      if (this.myRole === 'owner' && role !== 'owner') {
        Text(role === 'admin' ? '取消管理' : '设为管理')
          .fontSize(12)
          .fontColor('#4A9EF5')
          .onClick(() => {
            promptAction.showToast({ message: `操作: ${name}` })
          })
      }
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }

  // ==================== 设置 Tab ====================

  @Builder
  buildSettingsTab() {
    Column() {
      Text('组设置')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Column({ space: 12 }) {
        // 修改组名
        if (['owner', 'admin'].includes(this.myRole)) {
          Button('修改组名')
            .width('90%')
            .fontSize(14)
            .fontColor('#4A9EF5')
            .backgroundColor('#F5F8FF')
            .borderRadius(12)
            .onClick(() => {
              promptAction.showToast({ message: '修改组名' })
            })
        }

        // 重置邀请码
        if (['owner', 'admin'].includes(this.myRole)) {
          Button('重置邀请码')
            .width('90%')
            .fontSize(14)
            .fontColor('#4A9EF5')
            .backgroundColor('#F5F8FF')
            .borderRadius(12)
            .onClick(async () => {
              try {
                ensurePermission(checkPermission(this.myRole, 'manageInvite'))
                // TODO: 调用重置邀请码云函数
                promptAction.showToast({ message: '邀请码已重置' })
              } catch (err) {
                promptAction.showToast({ message: (err as Error).message })
              }
            })
        }

        // 解散组（仅 owner）
        if (this.myRole === 'owner') {
          Button('解散组')
            .width('90%')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF4444')
            .borderRadius(12)
            .onClick(() => {
              this.showDismissConfirm()
            })
        }
      }
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(16)
  }

  /** 解散组确认弹窗 */
  private showDismissConfirm() {
    promptAction.showDialog({
      title: '解散组',
      message: '确定要解散本组吗？此操作不可撤销，组内所有数据将被清除。',
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '确定',
          color: '#FF0000' // 危险操作用红色
        }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        // 点击了“确定”
        try {
          // TODO: 调用 dismissGroup 云函数
          promptAction.showToast({ message: '组已解散' })
          router.back()
        } catch (err) {
          promptAction.showToast({ message: '解散失败' })
        }
      }
      // index === 0 为“取消”，无需处理
    }).catch(() => {
      // 弹窗异常
    })
  }
}
