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
    
    func loadPokemons() {
        guard !isLoadingData else { return }
        
        isLoadingData = true
        apiManager.fetchPokemonList(limit: limit, offset: offset) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingData = false
            
            switch result {
            case .success(let response):
                self.handlePokemonDetail(response)
            case .failure(let error):
                print("Failed to load Pokemons: \(error)")
            }
        }
    }
    
    private func handlePokemonDetail(_ response: PokemonResponse) {
        let dispatchGroup = DispatchGroup()
        
        for item in response.results {
            if let pokemon = appManager.getPokemonWith(name: item.name) {
                self.pokemonslist.append(pokemon.id)
            } else {
                dispatchGroup.enter()
                apiManager.fetchPokemonDetail(from: item.url) { [weak self] pokemon in
                    if let pokemon = pokemon {
                        self?.pokemonslist.append(pokemon.id)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.offset += self.limit
            self.pokemonslist.sort(by: <)
            self.onDataLoaded?()
        }
    }
    
    func reloadFilteredPokemons() {
        if isFilteringFavorites {
            filteredPokemons = appManager.favoritePokemons.map { $0.key }
            filteredPokemons.sort(by: <)
        }
    }
    
    func toggleFavoriteFilter() {
        isFilteringFavorites.toggle()
        reloadFilteredPokemons()
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
            completion(pokemon)
        } else {
            apiManager.fetchPokemonDetail(for: pokemonID) { pokemon in
                if let pokemon = pokemon {
                    completion(pokemon)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
