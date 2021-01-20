//
//  Game.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import Foundation
import UIKit

protocol Game {
    
    var name: String { get }
    var description: String { get }
    var gameIconImage: UIImage { get }
    
}
