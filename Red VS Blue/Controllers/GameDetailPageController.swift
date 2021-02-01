//
//  GameDetailPageController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/27.
//

import UIKit

class GameDetailPageController: UIViewController {
    
    @IBOutlet weak var gameIconImage: UIImageView!
    @IBOutlet weak var gameTextView: UITextView!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    var selectedGameIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        gameIconImage.image = GameCollection.shared.games[selectedGameIndex].gameIconImage
        gameNameLabel.text = GameCollection.shared.games[selectedGameIndex].name
        gameTextView.text = GameCollection.shared.games[selectedGameIndex].description
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
}
