//
//  DetailViewModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

class DetailViewModel {
    var pokemon: PokemonModel
    var species: PokemonSpeciesModel?
    var evolutionChain: EvolutionChainModel?

    init(pokemon: PokemonModel) {
        self.pokemon = pokemon
    }
    
    func fetchPokemonSpecies(completion: @escaping (Result<PokemonSpeciesModel, Error>) -> Void) {
        apiManager.fetchPokemonSpecies(url: pokemon.speciesUrl) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let species):
                self.species = species
                completion(.success(species))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchEvolutionChain(url: String, completion: @escaping (Result<EvolutionChainModel, Error>) -> Void) {
        apiManager.fetchEvolutionChain(url: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let evolutionChain):
                self.evolutionChain = evolutionChain
                completion(.success(evolutionChain))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
