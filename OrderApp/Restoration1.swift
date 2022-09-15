//
//  Restoration1.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 23/08/2022.
//

import Foundation

extension NSUserActivity {
    
    var order: Order? {
        get {
            guard let jsonData = userInfo?["order"] as? Data else {
                return nil
            }
            return try? JSONDecoder().decode(Order.self, from: jsonData)
        }
        
        set {
            if let newValue = newValue, let jsonData = try? JSONEncoder().encode(newValue) {
                addUserInfoEntries(from: ["order": jsonData])
            } else {
                userInfo?["order"] = nil
            }
            
        }
    }
    
}
