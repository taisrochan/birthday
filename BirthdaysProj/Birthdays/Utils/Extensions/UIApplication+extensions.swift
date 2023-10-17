//
//  UIApplication+extensions.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 19/07/23.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
