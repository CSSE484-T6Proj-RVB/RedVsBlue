//
//  LeaderboardViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var leaderboardView: UIView!
    @IBOutlet var leaderboardLabels: [UILabel]!
    @IBOutlet weak var leaderboardSwitcher: UISegmentedControl!
    @IBOutlet weak var leaderboardTitle: UILabel!
    
    var usersRef: CollectionReference!
    var usersDataListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        usersRef = Firestore.firestore().collection("Users")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Leaderboards"
        
        leaderboardView.layer.cornerRadius = 15
        leaderboardView.layer.borderWidth = 4
        leaderboardView.layer.borderColor = UIColor.black.cgColor
        
        startListening(isPlayedMatches: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usersDataListener.remove()
    }
    
    func startListening(isPlayedMatches: Bool) {
        if usersDataListener != nil {
            usersDataListener.remove()
        }
        
        leaderboardTitle.text = isPlayedMatches ? "Matches Played" : "Matches Won"
        
        let query = isPlayedMatches ? usersRef.order(by: "matchesPlayed", descending: true).limit(to: 10).whereField("matchesPlayed", isGreaterThan: 0) : usersRef.order(by: "matchesWon", descending: true).limit(to: 10).whereField("matchesWon", isGreaterThan: 0)
        
        usersDataListener = query.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                for label in self.leaderboardLabels {
                    let index = label.tag
                    if index >= documentSnapshot.documents.count {
                        label.text = ""
                        continue
                    }
                    let playerName = documentSnapshot.documents[index].data()["name"] as! String
                    let playerStats = isPlayedMatches ? documentSnapshot.documents[index].data()["matchesPlayed"] as! Int : documentSnapshot.documents[index].data()["matchesWon"] as! Int
                    label.text = "\(index + 1). \(playerName) : \(String(playerStats))"
                }
            } else {
                print("Error getting user data \(error!)")
                return
            }
        })
    }
    
    @IBAction func switchedLeaderBoardMode(_ sender: Any) {
        switch leaderboardSwitcher.selectedSegmentIndex
        {
        case 0:
            startListening(isPlayedMatches: true)
        case 1:
            startListening(isPlayedMatches: false)
        default:
            break
        }
    }
}
