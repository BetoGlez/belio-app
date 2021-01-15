//
//  CommonFunctions.swift
//  belio-app
//
//  Created by Alberto González Hernández on 15/01/21.
//

import Foundation

class CommonFunctions {
        
    public func convertSecondsToMinutesSeconds (seconds : Int) -> (String, String) {
        let sec = (seconds % 3600) % 60
        return (String((seconds % 3600) / 60), (String(sec).count < 2 ? "0\(sec)" : String(sec)))
    }
}
