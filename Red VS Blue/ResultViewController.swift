//
//  ResultViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/23.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    
    var winImg = #imageLiteral(resourceName: "You_Win.png")
    var loseImg = #imageLiteral(resourceName: "You_Lose.png")
    var tieImg = #imageLiteral(resourceName: "Tie_Game.png")
    
    var clientScore: Int!
    var hostScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if clientScore == hostScore {
            // Tie
            resultImage.image = tieImg
        } else if (hostScore - clientScore > 0) == RoomManager.shared.isHost {
            // Win
            resultImage.image = winImg
        } else {
            // Lose
            resultImage.image = loseImg
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func pressedOKButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
