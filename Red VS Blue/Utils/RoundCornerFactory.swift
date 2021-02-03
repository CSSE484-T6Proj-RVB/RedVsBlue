//
//  RoundCornerFactory.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/3.
//

import UIKit

class RoundCornerFactory {
    
    static let shared = RoundCornerFactory()
    
    private init() {}
    
    func setCornerAndBorder(view: UIView, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor
    }
    
    func setCornerAndBorder(button: UIButton, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor) {
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = borderColor
    }
    
    func setCornerAndBorder(textView: UITextView, cornerRadius: CGFloat, borderWidth: CGFloat) {
        textView.layer.cornerRadius = cornerRadius
        textView.layer.borderWidth = borderWidth
    }
}
