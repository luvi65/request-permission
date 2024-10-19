import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { AlertCusDialog } from '../components/AlertDialog';

enum TIPS_TYPE {
  NULL,
  // 无系统权限
  NO_SYS_PERMISSION,
  // 无应用权限
  NO_APP_PERMISSION
}

@Entry
@Component
struct Index {
  // 定位结果
  @State result: string = ""
  // 弹窗文本
  @State tips: string = ""
  // 弹窗类型
  @State tipsType: TIPS_TYPE = TIPS_TYPE.NULL
  // 自定义弹窗
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertCusDialog({
      text: this.tips,
      cancelCall: () => {
        this.dialogController?.close()
      },
      successCall: () => {
        if (this.tipsType == TIPS_TYPE.NO_SYS_PERMISSION) {
          // 打开系统定位设置
          this._openSysSetting()
        }
        if (this.tipsType == TIPS_TYPE.NO_APP_PERMISSION) {
          // 打开app设置
          this._openAppSetting()
        }
        // 关闭弹窗
        this.dialogController?.close()
      }
    }),
    autoCancel: false,
    offset: { dx: 0, dy: 0 },
    isModal: true,
    customStyle: true,
  })

  aboutToAppear(): void {

  }

  /**
   * 获取定位
   */
  async _requestPermission(): Promise<boolean> {
    this.tipsType = TIPS_TYPE.NULL
    return new Promise((r, j) => {
      let permissionList: Permissions[] = ["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"]
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(getContext(), permissionList,
        (err: BusinessError, data: PermissionRequestResult) => {
          if (err) {
            console.error(`luvi > requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
            r(false)
          } else {
            console.info('luvi > data:' + JSON.stringify(data));
            console.info('luvi > data permissions:' + data.permissions);
            console.info('luvi > data authResults:' + data.authResults);
            console.info('luvi > data dialogShownResults:' + data.dialogShownResults);
            r(true)
          }
        });
    })
  }

  /**
   * 获取定位
   */
  async _loadLocation() {
    let flag = await this._requestPermission()
    if (!flag) {
      return
    }
    // 用户授权，可以继续访问目标操作
    let request: geoLocationManager.SingleLocationRequest =
      { 'locatingTimeoutMs': 10000, 'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_ACCURACY };
    try {
      geoLocationManager.getCurrentLocation(request).then((result) => {
        console.log('luvi current location: ' + JSON.stringify(result));
        // 经纬度换城市名
        let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
          { "latitude": result.latitude, "longitude": result.longitude, "maxItems": 1 };
        try {
          geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
            if (err) {
              console.error('getAddressesFromLocation: err=' + JSON.stringify(err));
            }
            if (data) {
              let res =
                `roadName: ${data[0].roadName}, locality: ${data[0].locality}, countryName: ${data[0].countryName}`
              this.result = res
              console.log("luvi > res " + res)
            }
          });
        } catch (err) {
          console.error("luvi > errCode:" + JSON.stringify(err));
        }
      })
        .catch((err: BusinessError) => {
          // 应用定位权限未开启
          if (err.code == 201) {
            this.tipsType = TIPS_TYPE.NO_APP_PERMISSION
            this.tips = "应用定位权限未开启，前往开启"
            this.dialogController?.open()
          }
          console.log("luvi > errCode:" + JSON.stringify(err));
        })
    } catch (err) {
      console.log("luvi > errCode:" + JSON.stringify(err));
      // 位置信息获取失败，没有开启系统定位
      if (err.code == 3301100) {
        this.tipsType = TIPS_TYPE.NO_SYS_PERMISSION
        this.tips = "系统定位权限未开启，前往开启"
        this.dialogController?.open()
      }
    }
  }

  /**
   * 打开系统设置
   */
  _openSysSetting() {
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings', //设置应用bundleName
      abilityName: 'com.huawei.hmos.settings.MainAbility', //设置应用abilityName
      uri: "location_manager_settings"
    }
    context.startAbility(want)
  }

  /**
   * 打开应用设置
   */
  _openAppSetting() {
    let context = getContext(this) as common.UIAbilityContext;
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings', //设置应用bundleName
      abilityName: 'com.huawei.hmos.settings.MainAbility', //设置应用abilityName
      uri: "application_info_entry", //通知管理页面
      parameters: {
        pushParams: context.abilityInfo.bundleName
      }
    }
    context.startAbility(want)
  }

  onPageShow(): void {

  }

  build() {
    RelativeContainer() {
      Column() {
        Text(this.result)
          .width(300)
          .margin({ bottom: 30 })

        Button("获取当前定位")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this._loadLocation()
          })
      }
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .height('100%')
    .width('100%')
  }
}