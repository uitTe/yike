// ============================================================
// SchedulePage.ets
// 排班模块页面 - 修正版
// ============================================================

import { promptAction, router } from '@kit.ArkUI'
import { Schedule, Shift } from '../../models/types'

interface RouterParams {
  groupId: string
  groupName?: string
}

@Entry
@Component
struct SchedulePage {
  @State schedules: Schedule[] = []
  @State currentMonth: string = '2026-06'
  @State showShiftPicker: boolean = false
  @State selectedDate: string = ''
  @State selectedShift: Shift = '早'
  private groupId: string = ''
  private shifts: Shift[] = ['早', '晚', '休']
  private shiftColors: Record<Shift, string> = {
    '早': '#4A9EF5',
    '晚': '#FF9800',
    '休': '#9E9E9E'
  }
  private shiftBgLight: Record<Shift, string> = {
    '早': '#E8F4FD',
    '晚': '#FFF3E0',
    '休': '#F5F5F5'
  }

  aboutToAppear() {
    const params = router.getParams() as RouterParams
    this.groupId = params?.groupId || ''
    this.loadMockData()
  }

  private loadMockData() {
    this.schedules = [
      { id: '1', groupId: this.groupId, userId: 'user_demo', date: '2026-06-15', shift: '早', remark: '正常早班', updateTime: new Date().toISOString() },
      { id: '2', groupId: this.groupId, userId: 'user_demo', date: '2026-06-16', shift: '晚', remark: '', updateTime: new Date().toISOString() },
      { id: '3', groupId: this.groupId, userId: 'user_demo', date: '2026-06-17', shift: '休', remark: '休息一天', updateTime: new Date().toISOString() }
    ]
  }

  private getDaysInMonth(year: number, month: number): number {
    return new Date(year, month + 1, 0).getDate()
  }

  private getFirstDayOfWeek(year: number, month: number): number {
    return new Date(year, month, 1).getDay()
  }

  private formatDate(year: number, month: number, day: number): string {
    const m = String(month + 1).padStart(2, '0')
    const d = String(day).padStart(2, '0')
    return `${year}-${m}-${d}`
  }

  private getScheduleForDate(date: string): Schedule | undefined {
    return this.schedules.find(s => s.date === date)
  }

  private openShiftPicker(date: string) {
    this.selectedDate = date
    const existing = this.getScheduleForDate(date)
    this.selectedShift = existing?.shift ?? '早'
    this.showShiftPicker = true
  }

  private saveShift() {
    const dateStr = this.selectedDate
    const shift = this.selectedShift
    const existing = this.getScheduleForDate(dateStr)
    if (existing) {
      existing.shift = shift
      existing.updateTime = new Date().toISOString()
    } else {
      this.schedules.push({ id: String(Date.now()), groupId: this.groupId, userId: 'user_demo', date: dateStr, shift: shift, remark: '', updateTime: new Date().toISOString() })
    }
    this.showShiftPicker = false
    promptAction.showToast({ message: `已设置: ${dateStr} ${shift}` })
  }

  build() {
    // 使用 Stack 作为根容器，方便弹窗置顶
    Stack() {
      // 主页面内容
      Column() {
        // 标题栏
        Row() {
          Text('排班').fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
          Text('+').fontSize(22).fontColor('#4A9EF5')
            .onClick(() => promptAction.showToast({ message: '添加排班' }))
        }.width('100%').height(50)

        // 月份
        Row() {
          Text('‹').onClick(() => promptAction.showToast({ message: '上个月' }))
          Text(this.currentMonth).layoutWeight(1).textAlign(TextAlign.Center)
          Text('›').onClick(() => promptAction.showToast({ message: '下个月' }))
        }.width('100%')

        // 星期头
        Row() {
          ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
            Text(day).width(44).textAlign(TextAlign.Center)
          }, (day: string) => day)
        }.width('100%')

        // 日历网格 (使用 Grid)
        Grid() {
          // 前置空格
          ForEach(Array.from<number>({ length: this.getFirstDayOfWeek(2026, 5) }).map((_: number, i: number) => i), (index: number) => {
            GridItem() {
              // 修正：Blank 放在 Column 里
              Column() {
                Blank().height(48)
              }
            }
          }, (index: number) => `empty-${index}`)

          // 日期
          ForEach(Array.from<number>({ length: this.getDaysInMonth(2026, 5) }).map((_: number, i: number) => i + 1), (day: number) => {
            GridItem() {
              this.dayCell(2026, 6, day)
            }
          }, (day: number) => `day-${day}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
        .width('100%')
        .height(300) // 给 Grid 一个固定高度防止撑开

        // 图例
        Row({ space: 16 }) {
          ForEach(this.shifts, (shift: Shift) => {
            Row() {
              // 修正：使用 Shape + Rect 画圆点
              Shape() {
                Rect().width(10).height(10).radius(5)
              }.fill(this.shiftColors[shift]).width(10).height(10)
              Text(shift).margin({ left: 4 })
            }
          }, (shift: string) => shift)
        }.margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F6F8')
      .padding(16)

      // 弹窗层 (条件渲染)
      if (this.showShiftPicker) {
        this.shiftPickerDialog()
      }
    }.width('100%').height('100%')
  }

  @Builder
  dayCell(year: number, month: number, day: number) {
    Column() {
      Text(day.toString())
      if (this.getScheduleForDate(this.formatDate(year, month - 1, day))) {
        Text(this.getScheduleForDate(this.formatDate(year, month - 1, day))!.shift)
          .fontSize(10)
          .backgroundColor(this.shiftBgLight[this.getScheduleForDate(this.formatDate(year, month - 1, day))!.shift])
          .borderRadius(4)
      } else {
        Text('+').fontColor('#CCC')
      }
    }
    .width(44).height(48).justifyContent(FlexAlign.Center)
    .backgroundColor(this.getScheduleForDate(this.formatDate(year, month - 1, day)) ? this.shiftBgLight[this.getScheduleForDate(this.formatDate(year, month - 1, day))!.shift] : '#FFF')
    .borderRadius(8)
    .onClick(() => this.openShiftPicker(this.formatDate(year, month - 1, day)))
  }

  @Builder
  shiftPickerDialog() {
    Column() {
      Text('选择班次').fontSize(16).fontWeight(FontWeight.Bold)
      Row({ space: 12 }) {
        ForEach(this.shifts, (shift: Shift) => {
          Text(shift)
            .padding(10)
            .borderRadius(20)
            .backgroundColor(this.selectedShift === shift ? this.shiftColors[shift] : '#FFF')
            .fontColor(this.selectedShift === shift ? '#FFF' : this.shiftColors[shift])
            .onClick(() => this.selectedShift = shift)
        })
      }
      Button('确认').margin({ top: 20 }).onClick(() => this.saveShift())
    }
    .padding(24)
    .backgroundColor('#FFF')
    .borderRadius(16)
    .onClick(() => { /* 拦截点击，防止穿透 */ })
  }
}