//
//  TankBattlesViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/15.
//

import Foundation
import UIKit

class TankBattlesViewController: UIViewController {
    @IBOutlet weak var gameBoardView: UIView!
    
    let file = "TankBattlesMap"
    let viewWidth = UIScreen.main.bounds.width
    var gridSize: Int!
    var chunkSize: Double!
    var fileData = [String]()
    
    let brickWall = #imageLiteral(resourceName: "brick_wall.png")
    let stoneWall = #imageLiteral(resourceName: "stone_wall.png")
    let yellowTank = #imageLiteral(resourceName: "yellow_tank.png")
    let greyBullet = #imageLiteral(resourceName: "grey_bullet.png")
    
    var tankX = 4
    var tankY = 8
    var tankImageView: UIImageView!
    
    var faceTo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tankImageView = UIImageView()
        tankImageView.image = yellowTank

        readFromFile()
        initialRenderMap()
        updateTankPos(x: tankX, y: tankY)
        gameBoardView.addSubview(tankImageView)
    }
    
    func readFromFile() {
        do {
            if let tankBattleMapPath = Bundle.main.path(forResource: file, ofType: "txt", inDirectory: "Data") {
                let contents = try String(contentsOfFile: tankBattleMapPath)
                fileData = contents.components(separatedBy: "\n")
                gridSize = fileData.count - 1
                chunkSize = Double(viewWidth) / Double(gridSize)
//                print(fileData)
            }
        } catch {
            print("Error reading dic")
        }
    }
    
    func initialRenderMap() {
        for indexRow in 0..<fileData.count - 1 {
            let oneRow = fileData[indexRow].components(separatedBy: " ")
            for indexCol in 0..<oneRow.count {
                let chunk = Int(oneRow[indexCol])
                let view = UIImageView()
                view.frame = CGRect(x: Double(indexCol) * chunkSize, y: Double(indexRow) * chunkSize, width: chunkSize, height: chunkSize)
                view.backgroundColor = UIColor.black
                if chunk == 1 {
                    view.image = stoneWall
                } else if chunk == 2 {
                    view.image = brickWall
                } else {
                    RoundCornerFactory.shared.setCornerAndBorder(view: view, cornerRadius: 1, borderWidth: 1, borderColor: UIColor.black.cgColor)
                }
                gameBoardView.addSubview(view)
            }
        }
    }
    
    func updateTankPos(x: Int, y: Int) {
        tankImageView.frame = CGRect(x: Double(x) * chunkSize, y: Double(y) * chunkSize, width: chunkSize, height: chunkSize)
    }
    
    func updateView() {
        
    }
    
    @IBAction func pressedDirectionButtons(_ sender: Any) {
        let button = sender as! UIButton
        switch button.tag {
        case 0:
            faceTo = "up"
            tankY -= 1
            tankImageView.image = yellowTank.rotate(radians: 0)
        case 1:
            faceTo = "right"
            tankX += 1
            tankImageView.image = yellowTank.rotate(radians: .pi / 2)
        case 2:
            faceTo = "down"
            tankY += 1
            tankImageView.image = yellowTank.rotate(radians: .pi)
        case 3:
            faceTo = "left"
            tankX -= 1
            tankImageView.image = yellowTank.rotate(radians: -.pi / 2)

        default:
            print("error")
        }
        
        //TODO: Check if position is valid
        if !isPosValid(x: tankX, y: tankY) {
            return
        }
        updateTankPos(x: tankX, y: tankY)
    }
    
    @IBAction func pressedFireButton(_ sender: Any) {
    }
    
    func isPosValid(x: Int, y: Int) -> Bool {
        return true
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
