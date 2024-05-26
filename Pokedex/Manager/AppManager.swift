//
//  appManager.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import Foundation

let appManager = APPManager.shared

class APPManager {
    static let shared = APPManager()
    
    var pokemons: [Int: PokemonModel] = [:]
    var pokemonNameToIDMap: [String: Int] = [:]     // key: pokemonName, Value: id
    private(set) var favoritePokemons: [Int: Bool] = [:]
    private let favoriteIDKey = "favoriteIDs"
    
    private init() {
        loadFavoritePokemons()
    }
    
    func getPokemonWith(name: String) -> PokemonModel? {
        if let id = pokemonNameToIDMap[name] {
            return pokemons[id]
        }
        return nil
    }
    
    func toggleFavorite(pokemonID: Int) {
        if let _ = favoritePokemons[pokemonID] {
            favoritePokemons.removeValue(forKey: pokemonID)
        } else {
            favoritePokemons[pokemonID] = true
        }
        updateFavoritePokemons()
    }
    
    private func loadFavoritePokemons() {
        if let favoriteString = UserDefaults.standard.string(forKey: favoriteIDKey) {
            print("vvv_First_favoriteString：\(favoriteString)")
            let favoriteIDs = favoriteString.split(separator: ",").compactMap { Int($0) }
            for id in favoriteIDs {
                favoritePokemons[id] = true
            }
            
            print("vvv_First===============================")
        }
    }
    
    private func updateFavoritePokemons() {
        print("vvv_favoritePokemons：\(favoritePokemons)")
        let favoriteIDs = favoritePokemons.map { String($0.key) }
        let favoriteString = favoriteIDs.joined(separator: ",")
        print("vvv_favoriteString：\(favoriteString)")
        UserDefaults.standard.set(favoriteString, forKey: favoriteIDKey)
        UserDefaults.standard.synchronize()
    }
}

