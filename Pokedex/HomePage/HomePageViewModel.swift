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
    private(set) var pokemons: [PokemonModel] = []
    private(set) var filteredPokemons: [PokemonModel] = []
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
                
                for entry in response.results {
                    dispatchGroup.enter()
                    apiManager.fetchPokemonDetail(from: entry.url) { pokemon in
                        if let pokemon = pokemon {
                            let isFavorite = UserDefaults.standard.bool(forKey: favoriteKey+"\(pokemon.id)")
                            appManager.favoritePokemons[pokemon.id] = isFavorite
                            self.pokemons.append(pokemon)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.offset += self.limit
                    self.pokemons.sort(by: { $0.id < $1.id })
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
        filteredPokemons = pokemons.filter { appManager.favoritePokemons[$0.id] == true }
        onDataLoaded?()
    }
    
    func pokemonList() -> [PokemonModel] {
        return isFilteringFavorites ? filteredPokemons : pokemons
    }
    
    func pokemonList(at index: Int) -> PokemonModel {
        return pokemonList()[index]
    }
}
