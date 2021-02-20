//
//  LeaderboardViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import UIKit

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var leaderboardView: UIView!
    @IBOutlet var leaderboardLabels: [UILabel]!
    @IBOutlet weak var leaderboardSwitcher: UISegmentedControl!
    @IBOutlet weak var leaderboardTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Leaderboards"
    
        RoundCornerFactory.shared.setCornerAndBorder(view: leaderboardView, cornerRadius: 15, borderWidth: 4, borderColor: UIColor.black.cgColor)
        
        UsersManager.shared.beginListeningForLeaderboard(isMatchesPlayed: true, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserManager.shared.stopListening()
    }
    
    func updateView() {
        for label in self.leaderboardLabels {
            let index = label.tag
            if index >= UsersManager.shared.getQueryDocumentCount() {
                label.text = ""
                continue
            }
            label.text = "\(index + 1). \(UsersManager.shared.getNameAtIndex(index: index)) : \(String(leaderboardSwitcher.selectedSegmentIndex == 0 ? UsersManager.shared.getMatchesPlayedAtIndex(index: index) : UsersManager.shared.getMatchesWonAtIndex(index: index)))"
        }
    }
    
    @IBAction func switchedLeaderBoardMode(_ sender: Any) {
        switch leaderboardSwitcher.selectedSegmentIndex
        {
        case 0:
            leaderboardTitle.text = "Matches Played"
            UsersManager.shared.stopListening()
            UsersManager.shared.beginListeningForLeaderboard(isMatchesPlayed: true, changeListener: updateView)
        case 1:
            leaderboardTitle.text = "Matches Won"
            UsersManager.shared.stopListening()
            UsersManager.shared.beginListeningForLeaderboard(isMatchesPlayed: false, changeListener: updateView)
        default:
            break
        }
    }
}
