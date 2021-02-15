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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readFromFile()
    }
    
    func readFromFile() {
        do {
            if let tankBattleMapPath = Bundle.main.path(forResource: file, ofType: "txt", inDirectory: "Data") {
                let contents = try String(contentsOfFile: tankBattleMapPath)
                fileData = contents.components(separatedBy: "\n")
                gridSize = fileData.count - 1
                chunkSize = Double(viewWidth) / Double(gridSize)
                //print(fileData)
                initialRenderMap()
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
                // TODO: Switch to UIImageView
                let view = UIView()
                view.frame = CGRect(x: Double(indexCol) * chunkSize, y: Double(indexRow) * chunkSize, width: chunkSize, height: chunkSize)
                view.backgroundColor = chunk == 1 ? UIColor.black : UIColor.white
                RoundCornerFactory.shared.setCornerAndBorder(view: view, cornerRadius: 1, borderWidth: 0.5, borderColor: UIColor.black.cgColor)
                gameBoardView.addSubview(view)
            }
        }
    }
    
    func updateView() {
        
    }
}
