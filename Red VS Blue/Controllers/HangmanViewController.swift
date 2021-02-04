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
    
    var word: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue
        
        //removeAllArrangedSubviews(stackView: letterStatusStackView)
        
        word = RandomStringGenerator.shared.generateRandomHangmanWord()
        
        for _ in 0..<word.count {
            letterStatusStackView.addArrangedSubview(generateOneLetterStackView(fontSize: 30))
        }
        for index in 0..<letterStatusStackView.arrangedSubviews.count {
            changeStackViewLabel(stackView: letterStatusStackView.arrangedSubviews[index] as! UIStackView, letter: String(Array(word)[index]))
        }
    }
    
    @IBAction func pressedLetterButton(_ sender: Any) {
        
    }
    
    func removeAllArrangedSubviews(stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
    }
    
    func generateOneLetterStackView(fontSize: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill // .leading .firstBaseline .center .trailing .lastBaseline
        stackView.distribution = .fill // .fillEqually .fillProportionally .equalSpacing .equalCentering
        stackView.spacing = 1
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.text = "K"
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
        
        let underscoreLabel = UILabel()
        underscoreLabel.text = "‾‾‾"
        underscoreLabel.textColor = UIColor.black
        underscoreLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        stackView.addArrangedSubview(underscoreLabel)
        
        return stackView
    }
    
    func changeStackViewLabel(stackView: UIStackView, letter: String) {
        
    }
}
