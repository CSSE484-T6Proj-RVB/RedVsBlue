//
//  HangmanViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/3.
//

import UIKit

class HangmanViewController: UIViewController {
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    @IBOutlet weak var letterStatusStackView: UIStackView!
    @IBOutlet weak var opponentLetterStatusStackView: UIStackView!
    
    @IBOutlet weak var hangmanImageView: UIImageView!
    
    @IBOutlet var letterButtons: [UIButton]!
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue
    }
    
    @IBAction func pressedLetterButton(_ sender: Any) {
        
    }
}
