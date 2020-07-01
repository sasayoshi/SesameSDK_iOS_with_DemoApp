//
//  SSM2SettingViewModel.swift
//  SesameUI
//
//  Created by YuHan Hsiao on 2020/6/19.
//  Copyright © 2020 CandyHouse. All rights reserved.
//

import UIKit
import SesameSDK
import AWSMobileClient

public final class SSM2SettingViewModel: ViewModel {
    private let id = UUID()
    // Data
    private var ssm: CHSesameBleInterface
    // Display
    private var delay = 0
    private var version = ""
    // Status
    private var isHiddenAutoLockDisplay = true
    private var switchIsOn = false {
        didSet {
            if switchIsOn == false {
                isHiddenAutoLockDisplay = true
            }
        }
    }
    private var isHiddenPicker = true
    
    public var statusUpdated: ViewStatusHandler?
    
    private var dfuHelper: DFUHelper?
    
    var delegate: SSM2SettingViewModelDelegate?
    
    // MARK: - Properties
    private(set) var changeNameIndicator = "Change Sesame Name".localStr
    private(set) var enterSesameName = "Enter Sesame name".localStr
    private(set) var angleIndicator = "Configure Angles".localStr
    private(set) var dfuIndicator = "SesameOS Update".localStr
    private(set) var removeSesameText = "Delete this Sesame".localStr
    private(set) var dropKeyText = "Drop key".localStr
    private(set) var autoLockLabel1Text = "autolock".localStr
    private(set) var autoLockLabel2Text = "After".localStr
    private(set) var autoLockLabel3Text = "sec".localStr
    private(set) var arrowImg = "arrow"
    private(set) var uuidTitleText = "UUID".localStr
    
    var title: String {
//        let storage = AnyObjectStore<SSMProperty>()
//        guard let storedSSM = storage.valueForKey(ssm.deviceId!.uuidString),
//            let deviceName = storedSSM.ssmName else {
//                return ssm.deviceId!.uuidString
//        }
//        return deviceName
        
        if let device = SSMStore.shared.getPropertyForDevice(ssm) {
            return device.name ?? device.uuid!.uuidString
        } else {
            return ssm.deviceId.uuidString
        }
    }
    
    var uuidValueText: String {
        ssm.deviceId.uuidString
    }
    
    var autolockSwitchIsEnabled: Bool {
        ssm.deviceStatus.loginStatus() == .login
    }
    
    var isAutoLockSwitchOn: Bool {
        switchIsOn
    }
    
    var autoLockDisplay: String {
        String(delay)
    }
    
    var isAutoLockSecondHidden: Bool {
        isHiddenAutoLockDisplay
    }
    
    var isAutoLockLabel1Hidden: Bool {
        false
    }
    
    var isAutoLockLabel2Hidden: Bool {
        isHiddenAutoLockDisplay
    }
    
    var isAutoLockLabel3Hidden: Bool {
        isHiddenAutoLockDisplay
    }
    
    var secondPickerIsHidden: Bool {
        isHiddenPicker
    }
    
    var ssmVersionText: String {
        version
    }

    var autoLockSecondText: String {
        String(delay)
    }
    
    init(ssm: CHSesameBleInterface) {
        self.ssm = ssm
//        self.ssm.updateObserver(self)
//        self.ssm.updateObserver(self, forKey: id.uuidString)

        self.ssm.connect()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: .SesamePropertyChanged,
                                               object: nil)
    }

    // MARK: - User interaction
    
    public func viewWillAppear() {
        getAutoLockSetting()
        getVersionTag()
        isHiddenPicker = true
        ssm.delegate = self
    }
    
    public func viewDidDisappear() {
        dfuHelper?.abort()
        dfuHelper = nil
    }
    
    @objc func updateUI() {
        executeOnMainThread {
            self.statusUpdated?(.received)
        }
    }
    
    @objc func autoLockSwitchChanged(sender: UISwitch) {
        if !sender.isOn {
            ssm.disableAutolock() { [weak self] (delay) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.statusUpdated?(.received)
            }
            isHiddenPicker = true
        } else {
            isHiddenPicker = false
        }
        switchIsOn = sender.isOn
        statusUpdated?(.received)
    }
    
    // MARK: - Business logic
    
    private func getAutoLockSetting() {
        ssm.getAutolockSetting { [weak self] autolock in
            guard let strongSelf = self else {
                return
            }
            strongSelf.switchIsOn = autolock != 0
        }
    }
    
    private func getVersionTag() {
        ssm.getVersionTag { [weak self] (version, _) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.version = version
            strongSelf.statusUpdated?(.received)
        }
    }
    
    deinit {
        L.d("SSM2SettingViewModel deinit")
    }
}

// MARK: - Delegate
extension SSM2SettingViewModel: CHSesameBleDeviceDelegate {
    public func onBleDeviceStatusChanged(device: CHSesameBleInterface,
                                         status: CHDeviceStatus) {
        if device.deviceId == ssm.deviceId,
            status == .receiveBle {
            device.connect()
        }
    }
}

// MARK: - AutoLock
extension SSM2SettingViewModel {
    var second: [Int] {
        [1,2,3,4,5,6,7,8,9,10,11,12,13]
    }

    func numberOfComponents() -> Int {
        1
    }
    
    func numberOfRowInComponent() -> Int {
        return second.count
    }
    
    func pickerTextForRow(_ row: Int) -> String {
        String(second[row])
    }
    
    func autolockSecondTapped() {
        defer {
            statusUpdated?(.received)
        }
        if delay == 0 {
            isHiddenPicker = true
            switchIsOn = false
            return
        } else {
            switchIsOn = true
            isHiddenAutoLockDisplay = false
        }
        isHiddenPicker.toggle()
    }
    
    func pickerDidSelectRow(_ row: Int) {
//        L.d(String(row)+"-"+String(component))
        ssm.enableAutolock(delay: second[row]) { [weak self] (delay) -> Void in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.delay = delay
                strongSelf.isHiddenAutoLockDisplay = delay > 0 ? false : true
                strongSelf.isHiddenPicker = true
                strongSelf.statusUpdated?(.received)
            }
        }
    }
}

// MARK: - DFU
extension SSM2SettingViewModel {
    public func dfuActionText() -> String {
        "SesameOS Update".localStr
    }
    
    public func dfuActionWithObserver(_ observer: DFUHelperObserver) {
        guard let filePath = Constant
            .resourceBundle
            .url(forResource: nil,
                 withExtension: ".zip"),
            let zipData = try? Data(contentsOf: filePath) else {
                return
        }
        
        ssm.updateFirmware { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let peripheral):
                guard let peripheral = peripheral.data else {
                    L.d("Request commad failed.")
                    return
                }
                L.d("Success.")
                strongSelf.dfuHelper = CHDFUHelper(peripheral: peripheral, zipData: zipData)
                strongSelf.dfuHelper?.observer = observer
                strongSelf.dfuHelper?.start()
            case .failure(let error):
                L.d(ErrorMessage.descriptionFromError(error: error))
                strongSelf.statusUpdated?(.finished(.failure(error)))
            }
            
        }
    }
    
    public func cancelDFU() {
        dfuHelper?.abort()
        dfuHelper = nil
    }
}

// MARK: - Rename
extension SSM2SettingViewModel {
    func renamePlaceholder() -> String {
        if let device = SSMStore.shared.getPropertyForDevice(ssm) {
            return device.name ?? device.uuid!.uuidString
        } else {
            return ssm.deviceId.uuidString
        }
    }
    
    func rename(_ name: String) {
        SSMStore.shared.savePropertyForDevice(ssm, withName: name)
        NotificationCenter.default.post(name: .SesamePropertyChanged, object: nil)
    }
}

// MARK: - Friends
extension SSM2SettingViewModel {
    
    public func deleteSesameTitle() -> String {
        "Delete this Sesame".localStr
    }
    
    public func deleteSeesameAction() {
        statusUpdated?(.loading)
        let deleteComplete = {
            SSMStore.shared.deletePropertyForDevice(self.ssm)
            self.delegate?.sesameDeleted()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                NotificationCenter.default.post(name: .SesameDeleted, object: nil)
            }
        }
        
        guard AWSMobileClient.default().isSignedIn == true else {
            ssm.resetSesame()
            deleteComplete()
            return
        }
        ssm.resetSesame()
        deleteComplete()
    }
    
    func dropKey() {
        SSMStore.shared.deletePropertyForDevice(self.ssm)
        ssm.dropKey()
        delegate?.sesameDeleted()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(name: .SesameDeleted, object: nil)
        }
    }
}

public protocol SSM2SettingViewModelDelegate {
    func setAngleForSSM(_ ssm: CHSesameBleInterface)
    func shareSSMTapped(_ ssm: CHSesameBleInterface)
    func sesameDeleted()
}

// MARK: - Navigation
extension SSM2SettingViewModel {
    func setAngleTapped() {
        delegate?.setAngleForSSM(ssm)
    }
    
    func shareSSMTapped() {
        delegate?.shareSSMTapped(ssm)
    }
}