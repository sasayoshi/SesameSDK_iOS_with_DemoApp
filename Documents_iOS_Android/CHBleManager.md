## iOS

```Swift
CHBleManager.shared.delegate  
//このメソッドを使用すると CANDY HOUSE のBLEデバイス の電波が変動や現れたらSDKからアプリUIにイベントを送る。アプリUIが通知されたら、セサミデバイスとのオブジェクトが取得でき、オブジェクトにはセサミデバイスのUUIDが含まれている。
CHBleManager.shared.disableScan(result: @escaping (CHResult<CHEmpty>)) //BLEスキャンのスイッチをオフする
CHBleManager.shared.enableScan(result: @escaping (CHResult<CHEmpty>)) //BLEスキャンのスイッチをオンする
CHBleManager.shared.disConnectAll(result: @escaping (CHResult<CHEmpty>) //全てのBLEデバイスとアプリとの間のBluetooth接続を切断。
```
## Android

```Kotlin

//このメソッドを使用すると CANDY HOUSE のBLEデバイス の電波が変動や現れたらSDKからアプリUIにイベントを送る。アプリUIが通知されたら、セサミデバイスとのオブジェクトが取得でき、オブジェクトにはセサミデバイスのUUIDが含まれている。
object CHBleManager {
  var delegate: CHBleManagerDelegate
  fun disableScan(result: CHResult<CHEmpty>) //BLEスキャンのスイッチをオフする
  fun enableScan(result: CHResult<CHEmpty>) //BLEスキャンのスイッチをオンする
  fun disConnectAll(result: CHResult<CHEmpty>) //全てのBLEデバイスとアプリとの間のBluetooth接続を切断。
}
```
