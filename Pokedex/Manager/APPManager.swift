//
//  APPManager.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import Foundation
import UIKit
import Kingfisher

let appManager = APPManager.shared

class APPManager {
    static let shared = APPManager()
    var pokemons: [Int: PokemonModel] = [:]
    var pokemonIDToNameMap: [Int: String] = [:]
    var pokemonNameToIDMap: [String: Int] = [:]
    private(set) var favoritePokemons: [Int: Bool] = [:]
    private let favoriteIDKey = "favoriteIDs"
    
    private init() {
        loadFavoritePokemons()
    }
    
    func getPokemonDetailWith(for name: String, completion: @escaping (PokemonModel?) -> Void) {
        if let id = pokemonNameToIDMap[name] {
            getPokemonDetailWith(for: id, completion: completion)
        } else {
            apiManager.fetchPokemonDetail(for: name) { pokemon in
                completion(pokemon)
            }
        }
    }
    
    func getPokemonDetailWith(for id: Int, completion: @escaping (PokemonModel?) -> Void) {
        if let pokemon = pokemons[id] {
            completion(pokemon)
        } else {
            apiManager.fetchPokemonDetail(for: id) { pokemon in
                completion(pokemon)
            }
        }
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
            let favoriteIDs = favoriteString.split(separator: ",").compactMap { Int($0) }
            for id in favoriteIDs {
                favoritePokemons[id] = true
            }
        }
    }
    
    private func updateFavoritePokemons() {
        let favoriteIDs = favoritePokemons.map { String($0.key) }
        let favoriteString = favoriteIDs.joined(separator: ",")
        UserDefaults.standard.set(favoriteString, forKey: favoriteIDKey)
        UserDefaults.standard.synchronize()
    }
}

extension APPManager {
    func setPokemonImage(for imageView: UIImageView?, with url: URL) {
        guard let imageView = imageView else { return }
        let placeholderImage = UIImage(named: "Pokeball")
        imageView.kf.setImage(with: url, placeholder: placeholderImage)
    }
}


