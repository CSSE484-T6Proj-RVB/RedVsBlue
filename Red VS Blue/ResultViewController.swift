//
//  ResultViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/23.
//

import UIKit

class ResultViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func pressedOKButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
