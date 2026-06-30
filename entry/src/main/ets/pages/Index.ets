// Index.ets
// 淡蓝背景 + 下拉刷新列表 + 底部沉浸光感悬浮页签

import { promptAction } from '@kit.ArkUI'



@Entry
@Component
struct Index {

    @State isRefreshing: boolean = false
    @State currentTab: number = 0   // 0-常用 1-模块 2-我的
    @State listData: string[] = [
        '列表项 1','列表项 2','列表项 3','列表项 4','列表项 5',
        '列表项 6','列表项 7','列表项 8','列表项 9','列表项 10',
        '列表项 11','列表项 12'
    ]

    // 页签标题
    private tabs: string[] = ['常用', '模块', '我的']

    /** 模拟刷新 */
    private doRefresh() {
        setTimeout(() => {
            // 这里换成真接口
            this.listData = ['新 · 常用项 A', '新 · 常用项 B', ...this.listData.slice(0, 8)]
            this.isRefreshing = false
            try {
                promptAction.showToast({ message: '刷新成功' })
            }catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                console.error(`showToast args error code is ${code}, message is ${message}`);
            };
        }, 1500)
    }

    build() {
        Stack() {
            /* ===== 1. 主内容区 ===== */
            Refresh({ refreshing: $$this.isRefreshing, promptText: '正在刷新…' }) {
                List({ space: 4 }) {
                    ForEach(this.listData, (item: string) => {
                        ListItem() {
                            Row() {
                                // 左边小图标占位
                                Stack() {
                                    Text('☁')
                                        .fontSize(22)
                                        .fontColor('#88C1F9')
                                }
                                .width(40)
                                .height(40)
                                .borderRadius(12)
                                .backgroundColor($r('sys.color.comp_background_list_card'))

                                Column() {
                                    Text(item)
                                        .fontSize(16)
                                        .fontWeight(FontWeight.Medium)
                                        .fontColor('#1A1A1A')
                                    Text('副标题示例')
                                        .fontSize(12)
                                        .fontColor('#999999')
                                }
                                .margin({ left: 12 })
                                .alignItems(HorizontalAlign.Start)
                            }
                            .width('92%')
                            .height(72)
                            .borderRadius(16)
                            .padding({ left: 16, right: 16 })
                            .backgroundColor('#4A9EF5')
                            .shadow({
                                radius: 12,
                                color: '#00000008',
                                offsetY: 2
                            })
                            .justifyContent(FlexAlign.Center)
                        }
                    }, (item: string) => item)
                }
                .width('100%')
                .height('100%')
                .padding({ top: 16, bottom: 96 }) // 给底部页签留悬空间
                .scrollBar(BarState.Off)
                .alignListItem(ListItemAlign.Center)
            }
            .refreshOffset(80)
            .pullToRefresh(true)
            .onRefreshing(() => this.doRefresh())
            .width('100%')
            .height('100%')

            /* ===== 2. 底部悬浮页签（沉浸光感）===== */
            Row() {
                ForEach(this.tabs, (tab: string, idx: number) => {
                    Column() {
                        // 小图标占位（可按需换成 SymbolGlyph）
                        // Text(idx === 0 ? '⭐' : idx === 1 ? '▦' : '👤')
                        //   .fontSize(20)
                        //   .fontColor(this.currentTab === idx ? '#FFFFFF' : '#88C1F9')

                        Text(tab)
                            .fontSize(16)
                            .fontColor(this.currentTab === idx ? '#FFFFFF' : '#88C1F9')
                    }
                    .width(96)
                    .height(48)
                    .borderRadius(24)
                    .backgroundColor(
                        this.currentTab === idx ? '#4A9EF5' : 'rgba(255,255,255,0.25)'
                    )
                    .onClick(() => {
                        animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
                            this.currentTab = idx
                        })
                    })
                    .margin({ left: 6, right: 6 })
                }, (_tab: string, idx: number) => idx.toString())
            }
            // ———— 光感关键参数 ————
            .width('88%')
            .height(64)
            .borderRadius(32)
            .padding({ top: 8, bottom: 8 })
            .alignSelf(ItemAlign.Center)
            .position({ bottom: 24, left: '6%' })   // 悬浮在底部
            .backgroundColor('rgba(180,210,245,0.35)')   // 半透明蓝白基底
            .backdropBlur(24)                            // 磨砂
            .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                    ['rgba(255,255,255,0.45)', 0],
                    ['rgba(180,210,245,0.15)', 1]
                ]
            })
            .shadow({
                radius: 28,
                color: 'rgba(100,160,255,0.35)',   // 蓝白光晕
                offsetY: 4
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
    }
}