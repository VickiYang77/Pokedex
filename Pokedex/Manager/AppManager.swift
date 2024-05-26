//
//  appManager.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import Foundation

let favoriteKey = "favoriteStatus"
let appManager = APPManager.shared

class APPManager {
    static let shared = APPManager()
    private init() {}
    
    var favoritePokemons: [Int: Bool] = [:]
    
    func updateFavouriteStatus(id: Int) {
        let favoriteIdKey = "\(favoriteKey)\(id)"
        let newStatus = !UserDefaults.standard.bool(forKey: favoriteIdKey)
        
        if newStatus {
            UserDefaults.standard.set(newStatus, forKey: favoriteIdKey)
            favoritePokemons[id] = true
        } else {
            UserDefaults.standard.removeObject(forKey: favoriteIdKey)
            favoritePokemons.removeValue(forKey: id)
        }
        UserDefaults.standard.synchronize()
    }
}

