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
    var updateDataStatus: ((String) -> Void)?
    private(set) var fetchedPokemonIDs: [Int] = []
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
                self.updateDataStatus?("No Pokémon Found")
                print("Failed to load Pokemons: \(error)")
            }
        }
    }
    
    private func handlePokemonDetail(_ response: PokemonListModel) {
        var newFetchedPokemonIDs: [Int] = []
        
        for item in response.results {
            if let id = extractPokemonID(from: item.url) {
                appManager.pokemonIDToNameMap[id] = item.name
                appManager.pokemonNameToIDMap[item.name] = id
                newFetchedPokemonIDs.append(id)
            }
        }
        
        self.offset += self.limit
        newFetchedPokemonIDs.sort(by: <)
        self.fetchedPokemonIDs.append(contentsOf: newFetchedPokemonIDs)
        self.onDataLoaded?()
        self.updateDataStatus?("")
    }
    
    private func extractPokemonID(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let pathComponents = url.pathComponents
        return pathComponents.last.flatMap { Int($0) }
    }
    
    func reloadFilteredPokemons() {
        if isFilteringFavorites {
            if fetchedPokemonIDs.count != 0 {
                filteredPokemons = appManager.favoritePokemons.map { $0.key }
                filteredPokemons.sort(by: <)
            } else {
                filteredPokemons = []
            }
        }
    }
    
    func toggleFavoriteFilter() {
        isFilteringFavorites.toggle()
        reloadFilteredPokemons()
        onDataLoaded?()
    }
    
    func displayedPokemonIDs() -> [Int] {
        return isFilteringFavorites ? filteredPokemons : fetchedPokemonIDs
    }
    
    func getDisplayedPokemon(at index: Int, completion: @escaping (PokemonModel?) -> Void) {
        let pokemonIDs = displayedPokemonIDs()
        guard index < pokemonIDs.count else {
            completion(nil)
            return
        }
        
        let pokemonID = pokemonIDs[index]
        appManager.getPokemonDetailWith(for: pokemonID) { pokemon in
            completion(pokemon)
        }
    }
}
