//
//  GetReadableText.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/4/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation

extension String {
    
    func getReadableText() -> String {
        switch self{
        case "R":
            return "Rapido"
        case "Rs":
            return "Rapidos"
        case "M":
            return "Medio"
        case "Ms":
            return "Medios"
        case "L":
            return "Lento"
        case "Ls":
            return "Lentos"
        case "C":
            return "Do"
        case "Eb":
            return "Mi bemol"
        case "F":
            return "Fa"
        case "G":
            return "Sol"
        case "Bb":
            return "Si bemol"
        case "Do":
            return "C"
        case "Mib":
            return "Eb"
        case "Fa":
            return "F"
        case "Sol":
            return "G"
        case "Sib":
            return "Bb"
        default:
            return ""
        }
    }
}
