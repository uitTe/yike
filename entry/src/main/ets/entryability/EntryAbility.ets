import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const HILOG_DOMAIN = 0x0000;
const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate() {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(HILOG_DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/index/Index', (err) => {
      if (err.code) {
        hilog.error(HILOG_DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(HILOG_DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(HILOG_DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}
