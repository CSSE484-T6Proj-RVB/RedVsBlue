//
//  AlertDialog.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 2/1/21.
//

import Foundation
import UIKit

class AlertDialog: UIViewController {
    static func showAlertDialog(viewController: UIViewController,
                                title: String?, message: String,
                                confirmTitle: String, finishHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        
        alertController.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { (UIAlertAction) in
            finishHandler?()
        }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
