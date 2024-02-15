//
//  KeyboardHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/21/23.
//

import Foundation
import SwiftUI

// https://stackoverflow.com/questions/60383632/show-hide-navigationbaritems-when-keyboard-visible-non-visible-swiftui
class KeyboardHandler : ObservableObject {
    static let shared = KeyboardHandler()

    @Published var keyboardFrame: CGRect? = nil

    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func willHide() {
        self.keyboardFrame = .zero
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        self.keyboardFrame = keyboardScreenEndFrame
    }
}
