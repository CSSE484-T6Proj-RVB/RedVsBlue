//
//  ResultViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/23.
//

import UIKit
import Firebase

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    
    var winImg = #imageLiteral(resourceName: "You_Win.png")
    var loseImg = #imageLiteral(resourceName: "You_Lose.png")
    var tieImg = #imageLiteral(resourceName: "Tie_Game.png")
    var isWin: Bool?
    
    var clientScore: Int!
    var hostScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if clientScore == hostScore {
            // Tie
            resultImage.image = tieImg
            isWin = false
        } else if (hostScore - clientScore > 0) == RoomManager.shared.isHost {
            // Win
            resultImage.image = winImg
            isWin = true
        } else {
            // Lose
            resultImage.image = loseImg
            isWin = false
        }
        
        UserManager.shared.beginListeningForSingleUser(uid: Auth.auth().currentUser!.uid, changeListener: nil)
        updateRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserManager.shared.stopListening()
    }
    
    func updateRecord() {
        UserManager.shared.updateMatchesPlayed(matchesPlayed: UserManager.shared.matchesPlayed + 1)
        UserManager.shared.updateMatchesWon(matchesWon: UserManager.shared.matchesWon + (isWin! ? 1 : 0))
    }
    
    @IBAction func pressedOKButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
