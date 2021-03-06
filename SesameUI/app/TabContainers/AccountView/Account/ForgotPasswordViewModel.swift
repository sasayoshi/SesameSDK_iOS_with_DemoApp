//
//  ForgotPasswordViewModel.swift
//  SesameUI
//
//  Created by YuHan Hsiao on 2020/6/23.
//  Copyright © 2020 CandyHouse. All rights reserved.
//

import Foundation
import AWSMobileClient

public protocol ForgotPasswordViewModelDelegate {
    func dismissTapped()
}

public final class ForgotPasswordViewModel: ViewModel {
    public enum SignUpViewError: Error {
        case unknow
    }
    
    private var forgotPasswordResult: ForgotPasswordResult?
    
    public var statusUpdated: ViewStatusHandler?
    public var delegate: ForgotPasswordViewModelDelegate?
    
    private(set) var backButtonImage = "icons_filled_close"
    private(set) var confirmationCodeAlertTitle = "Code Sent"
    private(set) var emailLabelText = "co.candyhouse.sesame-sdk-test-app.Email".localized
    private(set) var confirmationCodeLabelText = "Verification".localized
    private(set) var newPasswordLabelText = "co.candyhouse.sesame-sdk-test-app.NewPassword".localized
    private(set) var confirmationButtonTitle = "co.candyhouse.sesame-sdk-test-app.VerificationCode".localized
    private(set) var resendEmailButtonTitle = "co.candyhouse.sesame-sdk-test-app.SendVerificationCode".localized
    public var confirmationCodeSendDestination: String? {
        forgotPasswordResult?.codeDeliveryDetails?.destination
    }
    public var confirmationCodeSendAlertMessage: String {
        if let confirmationCodeSendDestination = confirmationCodeSendDestination {
            return "Code resent to \(confirmationCodeSendDestination)"
        } else {
            return "Code resent"
        }
    }
    private(set) var confirmationCodeActionTitle = "co.candyhouse.sesame-sdk-test-app.OK".localized
    
    private(set) var email: String
    private(set) var password: String?
    
    init(email: String) {
        self.email = email
    }
    
    func backTapped() {
        delegate?.dismissTapped()
    }
    
    func hideContent() -> Bool {
        forgotPasswordResult != nil ? false : true
    }
    
    func resendEmailTapped(_ email: String) {
        self.email = email
        
        AWSMobileClient
            .default()
            .forgotPassword(username: email) { forgotPasswordResult, error in
                if let error = error {
                    self.statusUpdated?(.finished(.failure(error)))
                } else if let result = forgotPasswordResult {
                    self.statusUpdated?(.finished(.success(result)))
                } else {
                    self.statusUpdated?(.finished(.failure(SignUpViewError.unknow)))
                }
        }
    }
    
    func confirmTapped(email: String, password: String, confirmationCode: String) {
        self.email = email
        self.password = password
        AWSMobileClient
            .default()
            .confirmForgotPassword(username: email,
                                   newPassword: password,
                                   confirmationCode: confirmationCode)
            { forgotPasswordResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.statusUpdated?(.finished(.failure(error)))
                    } else {
                        self.statusUpdated?(.finished(.success(forgotPasswordResult!)))
                    }
                }
        }
    }
}
