//
//  TankBattlesGame.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/15.
//

import Foundation
import UIKit

class TankBattlesGame: Game {
    var name = "Tank Battles"
    var segueName = "TankBattlesSegue"
    var description = "Your tank can shoot and move in four directions. Your mission is to hit the opponent's tank. The brick walls can be destroyed while stone walls cannot. The first player hitting the opponent's tank wins."
    var gameIconImage = #imageLiteral(resourceName: "GameIcon_TankBattles.PNG")
}
