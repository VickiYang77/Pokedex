//
//  HomePageViewModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import Foundation

let favoriteKey = "favoriteStatus"

class HomePageViewModel {
    
    enum ViewMode {
        case list
        case grid
    }
    
    private(set) var pokemons: [PokemonModel] = []
    private var filteredPokemons: [PokemonModel] = []
    private var offset = 0
    private let limit = 20
    private let pokemonListUrl = "https://pokeapi.co/api/v2/pokemon"
    var favoritePokemons: [Int: Bool] = [:]
    var isFilteringFavorites = false
    var viewMode: ViewMode = .list
    
    var onDataLoaded: (() -> Void)?
    
    func loadPokemons() {
        let urlString = "\(pokemonListUrl)?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(PokemonResponse.self, from: data)
                
                let dispatchGroup = DispatchGroup()
                
                for entry in response.results {
                    dispatchGroup.enter()
                    self.fetchPokemonDetails(from: entry.url) { pokemon in
                        if let pokemon = pokemon {
                            let isFavorite = UserDefaults.standard.bool(forKey: favoriteKey+"\(pokemon.id)")
                            self.favoritePokemons[pokemon.id] = isFavorite
                            self.pokemons.append(pokemon)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.offset += self.limit
                    self.pokemons.sort(by: { $0.id < $1.id })
                    self.onDataLoaded?()
                }
                
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func fetchPokemonDetails(from url: String, completion: @escaping (PokemonModel?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let pokemon = try decoder.decode(PokemonModel.self, from: data)
                completion(pokemon)
            } catch {
                print("Failed to decode Pokemon details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func toggleFavoriteFilter() {
        isFilteringFavorites.toggle()
        filteredPokemons = pokemons.filter { favoritePokemons[$0.id] == true }
        onDataLoaded?()
    }
    
    func pokemonList() -> [PokemonModel] {
        return isFilteringFavorites ? filteredPokemons : pokemons
    }
    
    func pokemonList(at index: Int) -> PokemonModel {
        return pokemonList()[index]
    }
}
