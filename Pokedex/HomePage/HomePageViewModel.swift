//
//  HomePageViewModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import Foundation

class HomePageViewModel {
    
    enum ViewMode {
        case list
        case grid
    }
    
    var isFilteringFavorites = false
    var viewMode: ViewMode = .list
    var onDataLoaded: (() -> Void)?
    private(set) var pokemonslist: [Int] = []
    private(set) var filteredPokemons: [Int] = []
    private(set) var isLoadingData = false
    private var offset = 0
    private let limit = 20
    private let pokemonListUrl = "https://pokeapi.co/api/v2/pokemon"
    
    func loadPokemons() {
        guard !isLoadingData else { return }
        
        isLoadingData = true
        
        let urlString = "\(pokemonListUrl)?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        
        print("vvv_dataTask：\(urlString)")
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                self?.isLoadingData = false
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(PokemonResponse.self, from: data)
                
                let dispatchGroup = DispatchGroup()
                
                for item in response.results {
                    if let pokemon = appManager.getPokemonWith(name: item.name) {
                        print("vvv_exist_pokemons:\(pokemon.id)")
                        self.pokemonslist.append(pokemon.id)
                    } else {
                        dispatchGroup.enter()
                        apiManager.fetchPokemonDetail(from: item.url) { pokemon in
                            if let pokemon = pokemon {
                                self.pokemonslist.append(pokemon.id)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.offset += self.limit
                    self.pokemonslist.sort(by: <)
                    self.onDataLoaded?()
                    self.isLoadingData = false
                }
                
            } catch {
                print("Failed to decode JSON: \(error)")
                self.isLoadingData = false
            }
        }
        task.resume()
    }
    
    func toggleFavoriteFilter() {
        isFilteringFavorites.toggle()
        if isFilteringFavorites {
            filteredPokemons = appManager.favoritePokemons.map { $0.key }
            filteredPokemons.sort(by: <)
        }
        onDataLoaded?()
    }
    
    func pokemonList() -> [Int] {
        return isFilteringFavorites ? filteredPokemons : pokemonslist
    }
    
    func pokemonList(at index: Int, completion: @escaping (PokemonModel?) -> Void) {
        let pokemonIDs = pokemonList()
        guard index < pokemonIDs.count else {
            completion(nil)
            return
        }
        
        let pokemonID = pokemonIDs[index]
        if let pokemon = appManager.pokemons[pokemonID] {
            print("vvv_exist_pokemons:\(pokemonID)")
            completion(pokemon)
        } else {
            let url = apiManager.pokemonDetailUrl + "\(pokemonID)"
            apiManager.fetchPokemonDetail(from: url) { pokemon in
                if let pokemon = pokemon {
                    completion(pokemon)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
