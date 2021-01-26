//
//  GamePageViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/27.
//

import UIKit

class GamePageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var selectedIndex: Int?
    
    let gameDetailSegueIdentifier = "DetailSegue"
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndex = -1
        navigationController?.setNavigationBarHidden(true, animated: false)
        updateView()
    }
    
    func updateView() {
        var y = 0;
        let verticalGap = 10, horizontalGap = 20, stackHeight = 80, stackSpacing = 50
        let screenWidth = Int(UIScreen.main.bounds.width)
        let buttonWidth = screenWidth - stackHeight - 2 * horizontalGap - stackSpacing
        
        for index in 0 ..< GameCollection.shared.games.count {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center // .leading .firstBaseline .center .trailing .lastBaseline
            stackView.distribution = .equalSpacing // .fillEqually .fillProportionally .equalSpacing .equalCentering
            stackView.spacing = CGFloat(stackSpacing)
            stackView.frame = CGRect(x: 0, y: y, width: screenWidth - horizontalGap * 2, height: stackHeight)
            
            let image = UIImageView()
            image.image = GameCollection.shared.games[index].gameIconImage
            image.widthAnchor.constraint(equalToConstant: CGFloat(stackHeight)).isActive = true
            image.heightAnchor.constraint(equalToConstant: CGFloat(stackHeight)).isActive = true
            
            let button = UIButton(type: .custom) as UIButton
//            button.frame = CGRect(x: 0, y: 0, width: 250, height: 80)
            //button.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20).isActive = true
            //button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 100).isActive = true
            //button.backgroundColor = UIColor.white
            button.widthAnchor.constraint(equalToConstant: CGFloat(buttonWidth)).isActive = true
            button.heightAnchor.constraint(equalToConstant: CGFloat(stackHeight)).isActive = true
            button.contentHorizontalAlignment = .leading
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            button.tag = index
            button.setTitle(GameCollection.shared.games[index].name, for: .normal)
            button.addTarget(self, action: #selector(pressedGameIcon), for: .touchUpInside)
            // for horizontal stack view, you might want to add width constraint to label or whatever view you're adding.
            //stackView.arrangedSubviews[0].frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            
            stackView.addArrangedSubview(image)
            stackView.addArrangedSubview(button)
            //stackView.backgroundColor = UIColor.purple
            scrollView.addSubview(stackView)
            
            y += stackHeight + verticalGap
        }
        scrollView.contentSize = CGSize(width: CGFloat(Int(UIScreen.main.bounds.width) - horizontalGap * 2), height: CGFloat(y))
    }
    
    @objc func pressedGameIcon(sender: UIButton!) {
        selectedIndex = sender.tag
        performSegue(withIdentifier: gameDetailSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameDetailSegueIdentifier {
            (segue.destination as! GameDetailPageController).selectedGameIndex = selectedIndex
        }
    }
}
