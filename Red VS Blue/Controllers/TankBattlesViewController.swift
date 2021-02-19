//
//  TankBattlesViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/15.
//

import Foundation
import UIKit

class TankBattlesViewController: UIViewController {
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    @IBOutlet weak var gameBoardView: UIView!
    var chunkImageViews = [[UIImageView]]()
    var mapData = [[Int]]()
    
    let file = "TankBattlesMap"
    let viewWidth = UIScreen.main.bounds.width
    let direction = [[0, -1, 0], [1, 0, Double.pi / 2], [0, 1, Double.pi], [-1, 0, -Double.pi / 2]]
    
    var gridSize: Int!
    var chunkSize: Double!
    var fileData = [String]()
    
    let brickWall = #imageLiteral(resourceName: "brick_wall.png")
    let stoneWall = #imageLiteral(resourceName: "stone_wall.png")
    let blueTankImage = #imageLiteral(resourceName: "blue_tank.png")
    let redTankImage = #imageLiteral(resourceName: "red_tank.png")
    let greyBullet = #imageLiteral(resourceName: "grey_bullet.png")
    let laser = #imageLiteral(resourceName: "laser.png")
    let collision = #imageLiteral(resourceName: "collision.png")
    
    var myTankImageView: UIImageView!
    var myTankImage: UIImage!
    var myTankX: Int!
    var myTankY: Int!
    var myFaceTo: Int!
    let myXField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_hostX : kKeyTankBattles_clientX
    let myYField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_hostY : kKeyTankBattles_clientY
    let myFaceToField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_hostFaceTo : kKeyTankBattles_clientFaceTo
    let myFireField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_hostFire : kKeyTankBattles_clientFire
    
    var opponentTankImageView: UIImageView!
    var opponentTankImage: UIImage!
    var opponentTankX: Int!
    var opponentTankY: Int!
    var opponentFaceTo: Int!
    let opponentXField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_clientX : kKeyTankBattles_hostX
    let opponentYField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_clientY : kKeyTankBattles_hostY
    let opponentFaceToField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_clientFaceTo : kKeyTankBattles_hostFaceTo
    let opponentFireField = RoomStatusStorage.shared.isHost ? kKeyTankBattles_clientFire : kKeyTankBattles_hostFire

    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue

        GameDataManager.shared.setReference(roomId: roomId, gameName: kTankBattlesGameName)
        RoomManager.shared.setReference(roomId: roomId)

        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kTankBattlesGameName)
        }

        RoomManager.shared.beginListening(changeListener: updateScoreLabel) // Score and ids
        UsersManager.shared.beginListening(changeListener: updateNameAndBio) // Name and bio
        GameDataManager.shared.beginListening(changeListener: updateView) // gamedata
        
        myTankImageView = UIImageView()
        opponentTankImageView = UIImageView()
        
        if RoomStatusStorage.shared.isHost {
            myTankImageView.image = redTankImage
            myTankX = 5
            myTankY = 1
            myFaceTo = 2
            opponentTankImageView.image = blueTankImage
            myTankImage = redTankImage
            opponentTankImage = blueTankImage

        } else {
            myTankImageView.image = blueTankImage
            myTankX = 4
            myTankY = 8
            myFaceTo = 0
            myTankImage = blueTankImage
            opponentTankImage = redTankImage
            opponentTankImageView.image = redTankImage
        }

        readFromFile()
        initialRenderMap()
        updateTankPos(x: myTankX, y: myTankY)
        gameBoardView.addSubview(myTankImageView)
        gameBoardView.addSubview(opponentTankImageView)
    }
    
    func readFromFile() {
        do {
            if let tankBattleMapPath = Bundle.main.path(forResource: file, ofType: "txt", inDirectory: "Data") {
                let contents = try String(contentsOfFile: tankBattleMapPath)
                fileData = contents.components(separatedBy: "\n")
                gridSize = fileData.count - 1
                mapData = [[Int]](repeating: [Int](), count: gridSize)
                for indexRow in 0..<fileData.count - 1 {
                    let oneRow = fileData[indexRow].components(separatedBy: " ")
                    for indexCol in 0..<oneRow.count {
                        mapData[indexRow].append(Int(oneRow[indexCol])!)
                    }
                }
                chunkSize = Double(viewWidth) / Double(gridSize)
                chunkImageViews = [[UIImageView]](repeating: [UIImageView](), count: gridSize)
                
            }
        } catch {
            print("Error reading dic")
        }
    }
    
    func initialRenderMap() {
        for indexRow in 0..<mapData.count {
            for indexCol in 0..<mapData[indexRow].count {
                let chunk = mapData[indexRow][indexCol]
                let view = UIImageView()
                view.frame = CGRect(x: Double(indexCol) * chunkSize, y: Double(indexRow) * chunkSize, width: chunkSize, height: chunkSize)
                view.backgroundColor = UIColor.black
                if chunk == 1 {
                    view.image = stoneWall
                } else if chunk == 2 {
                    view.image = brickWall
                } else {
                    RoundCornerFactory.shared.setCornerAndBorder(view: view, cornerRadius: 1, borderWidth: 0, borderColor: UIColor.black.cgColor)
                }
                gameBoardView.addSubview(view)
                chunkImageViews[indexRow].append(view)
            }
        }
    }
    
    func updateScoreLabel() {
        if isHost {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
            yourScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
        } else {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
            yourScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
        }
    }
    
    func updateNameAndBio() {
        let hostId = RoomManager.shared.hostId
        let clientId = RoomManager.shared.clientId!
        
        if isHost {
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
        } else {
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
        }
    }
    
    func updateTankPos(x: Int, y: Int) {
        myTankImageView.frame = CGRect(x: Double(x) * chunkSize, y: Double(y) * chunkSize, width: chunkSize, height: chunkSize)
        myTankImageView.image = myTankImage.rotate(radians: CGFloat(direction[myFaceTo][2]))
    }
    
    func updateView() {
        guard let _ = GameDataManager.shared.getDataWithField(fieldName: kKeyTankBattles_clientFire) as? Bool else {
            return
        }
        opponentTankX = (GameDataManager.shared.getDataWithField(fieldName: opponentXField) as! Int)
        opponentTankY = (GameDataManager.shared.getDataWithField(fieldName: opponentYField) as! Int)
        opponentTankImageView.frame = CGRect(x: Double(opponentTankX) * chunkSize, y: Double(opponentTankY) * chunkSize, width: chunkSize, height: chunkSize)
        let opponentFaceTo = GameDataManager.shared.getDataWithField(fieldName: opponentFaceToField) as! Int
        opponentTankImageView.image = opponentTankImage.rotate(radians: CGFloat(direction[opponentFaceTo][2]))
        
        let isOpponentFire = GameDataManager.shared.getDataWithField(fieldName: opponentFireField) as! Bool
        if isOpponentFire {
            updateLaser(whoseFireField: opponentFireField, whoseFaceTo: opponentFaceTo, whoseTankX: opponentTankX, whoseTankY: opponentTankY)
        }
        
    }
    
    @IBAction func pressedDirectionButtons(_ sender: Any) {
        let button = sender as! UIButton
        
        var testX = myTankX!
        var testY = myTankY!
        
        myFaceTo = button.tag
        testX += Int(direction[button.tag][0])
        testY += Int(direction[button.tag][1])
        myTankImageView.image = myTankImage.rotate(radians: CGFloat(direction[button.tag][2]))
        
        GameDataManager.shared.updateDataWithField(fieldName: myFaceToField, value: myFaceTo!)
        if getMapDataAtCoordinate(x: testX, y: testY) != 0 {
            return
        }
        
        myTankX = testX
        myTankY = testY
        //GameDataManager.shared.updateDataWithField(fieldName: myFaceToField, value: myFaceTo!)
        GameDataManager.shared.updateDataWithField(fieldName: myXField, value: myTankX!)
        GameDataManager.shared.updateDataWithField(fieldName: myYField, value: myTankY!)
        updateTankPos(x: myTankX, y: myTankY)
    }
    
    @IBAction func pressedFireButton(_ sender: Any) {
//        GameDataManager.shared.updateDataWithField(fieldName: myFireField, value: true)
//        var testX = myTankX + Int(direction[myFaceTo][0])
//        var testY = myTankY + Int(direction[myFaceTo][1])
//        var tempArr = [UIImageView]()
//        while getMapDataAtCoordinate(x: testX, y: testY) == 0 {
//            tempArr.append(chunkImageViews[testY][testX])
//            chunkImageViews[testY][testX].image = laser.rotate(radians: CGFloat(direction[myFaceTo!][2]) + .pi / 2)
//            testX += Int(direction[myFaceTo][0])
//            testY += Int(direction[myFaceTo][1])
//        }
//        var brickToRemove: UIImageView?
//        if self.getMapDataAtCoordinate(x: testX, y: testY) == 2 {
//            brickToRemove = chunkImageViews[testY][testX]
//            brickToRemove!.image = collision
//            self.mapData[testY][testX] = 0
//        }
//        print("\(testX) \(testY) \(getMapDataAtCoordinate(x: testX, y: testY))")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            // Put your code which should be executed with a delay here
//            for current in tempArr {
//                current.image = nil
//            }
//            brickToRemove?.image = nil
//            GameDataManager.shared.updateDataWithField(fieldName: self.myFireField, value: false)
//        }
        updateLaser(whoseFireField: myFireField, whoseFaceTo: myFaceTo, whoseTankX: myTankX, whoseTankY: myTankY)
    }
    
    func updateLaser(whoseFireField: String, whoseFaceTo: Int, whoseTankX: Int, whoseTankY: Int) {
        GameDataManager.shared.updateDataWithField(fieldName: whoseFireField, value: true)
        var testX = whoseTankX + Int(direction[whoseFaceTo][0])
        var testY = whoseTankY + Int(direction[whoseFaceTo][1])
        var tempArr = [UIImageView]()
        while getMapDataAtCoordinate(x: testX, y: testY) == 0 {
            tempArr.append(chunkImageViews[testY][testX])
            chunkImageViews[testY][testX].image = laser.rotate(radians: CGFloat(direction[whoseFaceTo][2]) + .pi / 2)
            testX += Int(direction[whoseFaceTo][0])
            testY += Int(direction[whoseFaceTo][1])
        }
        var brickToRemove: UIImageView?
        if self.getMapDataAtCoordinate(x: testX, y: testY) == 2 {
            brickToRemove = chunkImageViews[testY][testX]
            brickToRemove!.image = collision
            self.mapData[testY][testX] = 0
        }
        print("\(testX) \(testY) \(getMapDataAtCoordinate(x: testX, y: testY))")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Put your code which should be executed with a delay here
            for current in tempArr {
                current.image = nil
            }
            brickToRemove?.image = nil
            GameDataManager.shared.updateDataWithField(fieldName: whoseFireField, value: false)
        }
    }
    
    func getMapDataAtCoordinate(x: Int, y: Int) -> Int {
        return mapData[y][x]
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
