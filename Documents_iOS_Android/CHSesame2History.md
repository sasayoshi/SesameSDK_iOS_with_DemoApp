## iOS

```swift
public enum CHSesame2History {
    case manualElse(CHSesame2HistoryData)
    case manualLocked(CHSesame2HistoryData)
    case manualUnlocked(CHSesame2HistoryData)
    case bleLock(CHSesame2HistoryData)                               // BLEコマンドによる施錠
    case bleUnLock(CHSesame2HistoryData)                             // BLEコマンドによる解錠
    case autoLock(CHSesame2HistoryData)                              // セサミデバイスがオートロックしました
    case autoLockUpdated(CHSesame2AutoLockUpdatedHistoryData)        // オートロックの設定が変更されました
    case mechSettingUpdated(CHSesame2MechSettingUpdatedHistoryData)  // 施解錠角度の設定が変更されました
    case timeChanged(CHSesame2TimeChangedHistoryData)                // セサミデバイスの内部時計が校正された
}
public class CHSesame2HistoryData {
  public  let recordID:Int32      　　　　　　// 連続でない(将来的に連続になるように修正する予定)、セサミデバイスがリセットされるまで当履歴の唯1つのID、 小→大
  public  let date: Date          　　　　　　// 1970/1/1 00:00:00 から秒単位のタイムスタンプ
  public  let historyTag: Data?   　　　　　　// 鍵に付いてるタグやメモ 0 ~ 21bytes
}
public class CHSesame2AutoLockUpdatedHistoryData :CHSesame2HistoryData{
    public  let enabledBefore:Int16　　　　　// 設定が変更される前のオートロックの秒数; 0秒はオートロックがオフとの特例。
    public  let enabledAfter:Int16         // 設定が変更される後のオートロックの秒数
}
public class CHSesame2MechSettingUpdatedHistoryData :CHSesame2HistoryData{
 
    public  let lockTargetBefore:Int16     // 設定が変更される前の施錠状態の角度、範圍： -32767~0~32767 ; -32768 は意義のない的デフォルト值。 例0˚ ⇄ 0 で 360˚ ⇄ 1024 
    public  let lockTargetAfter:Int16      // 設定が変更される後の施錠状態の角度
    public  let unlockTargetBefore:Int16   // 設定が変更される前の解錠状態の角度
    public  let unlockTargetAfter:Int16    // 設定が変更される後の解錠状態の角度

}
public class CHSesame2TimeChangedHistoryData :CHSesame2HistoryData{
    public let timeAfter:Date              // 設定が校正される前の、セサミデバイス内部の時計の時刻、例えば、 西暦1970年1月1日00時00分06秒
    public let timeBefore:Date             // 設定が校正される後の、セサミデバイス内部の時計の時刻、例えば、 西暦2020年8月4日15時04分02秒。SesameSDKが裏で自動的にセサミデバイス内部の時計を校正している。
}
/*
manualLocked
手動で施錠 ( ケース2またケース3 から ケース1 になった場合 )

manualUnlocked
手動で解錠 ( ケース1またケース3 から ケース2 になった場合 )

manualElse
解錠の点または施錠の点から、サムターンに動きがあった場合（　ケース１からケース３になった場合、またはケース２からケース３になった場合）



補足１：現時点では状態は以下の３つのみとなっています。
＜ケース１：施錠＞
サムターンが施錠の点にある場合、
施錠　1
解錠　0　
＜ケース２：解錠＞
サムターンが解錠の点にある場合、
施錠　0
解錠　1
＜ケース３：それ以外（※現時点では「解錠」とUI上で表示しています。 ＞
サムターンが以上の２点以外にある場合、
施錠　0
解錠　0


補足２：現時点のSDKとAPPでは解錠と施錠は「点」となっておりますが、今後ユーザー様が解錠/施錠状態を範囲で設定出来る様に変更予定で、ファームウェアには既にその機能は実装しております。
*/
```
### iOS sample code
```swift 
let history = ... mock from sesame2.getHistories.first

switch history {

  case .autoLock(let data),.bleLock(let data),.bleUnLock(let data),
       .manualElse(let data),.manualLocked(let data),.manualUnlocked(let data):
     L.d("recordID",data.recordID)
     L.d("date",data.date)
     L.d("historyTag",data.historyTag)
  case .autoLockUpdated(let data):
     L.d("recordID",data.recordID)
     L.d("date",data.date)
     L.d("historyTag",data.historyTag)
     L.d(data.enabledAfter)
     L.d(data.enabledBefore)

  case .mechSettingUpdated(let data):
     L.d("recordID",data.recordID)
     L.d("date",data.date)
     L.d("historyTag",data.historyTag)
     L.d("lockTargetAfter",data.lockTargetAfter)
     L.d("lockTargetBefore",data.lockTargetBefore)
     L.d("unlockTargetAfter",data.unlockTargetAfter)
     L.d("unlockTargetBefore",data.unlockTargetBefore)

  case .timeChanged(let data):
     L.d("recordID",data.recordID)
     L.d("date",data.date)
     L.d("historyTag",data.historyTag)
     L.d("timeBefore",data.timeBefore)
     L.d("timeAfter",data.timeAfter)
}
```


## Android

```kotlin
sealed class CHSesame2History() {
   val recordID: Long
   var date:Date 
   val historyTag: ByteArray?
     class ManualElse : CHSesame2History
     class ManualLocked : CHSesame2History
     class ManualUnlocked : CHSesame2History
     class BLELock : CHSesame2History
     class BLEUnlock : CHSesame2History
     class AutoLock : CHSesame2History
     // event with params
     class AutoLockUpdated: CHSesame2History {
        val enabledBefore:Short
        val enabledAfter:Short
    }
     class MechSettingUpdated: CHSesame2History {
        val lockTargetBefore:Short
        val lockTargetAfter:Short
        val unlockTargetBefore:Short
        val unlockTargetAfter:Short
    }
     class TimeChanged: CHSesame2History {
        val timeBefore: Date
        val timeAfter: Date
    }
}
```

### Android sample code
```kotlin
val history = ... mock from sesame2.getHistories.first

   Log.d("tag","recordID:"+history.recordID.toString())
   Log.d("tag","date"+history.date.toString())
   Log.d("tag","historyTag"+history.historyTag.toString())
   when(history){
         is CHSesame2History.AutoLockUpdated  -> {
            Log.d("tag","enabledBefore:"+history.enabledBefore.toString())
            Log.d("tag","enabledAfter"+history.enabledAfter.toString())
         }
         is CHSesame2History.MechSettingUpdated -> {
            Log.d("tag","lockTargetBefore"+history.lockTargetBefore.toString())
            Log.d("tag","lockTargetAfter"+history.lockTargetAfter.toString())
            Log.d("tag","unlockTargetBefore"+history.unlockTargetBefore.toString())
            Log.d("tag","unlockTargetAfter"+history.unlockTargetAfter.toString())
         }           
         is CHSesame2History.TimeChanged -> {
            Log.d("tag","timeBefore"+history.timeBefore.toString())
            Log.d("tag","timeAfter"+history.timeAfter.toString())
         }
   }

```
