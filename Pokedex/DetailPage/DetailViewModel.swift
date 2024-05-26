//
//  DetailViewModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

class DetailViewModel {
    var pokemon: PokemonModel
    var evolutionChain: EvolutionChainModel?

    init(pokemon: PokemonModel) {
        self.pokemon = pokemon
    }
    
    func fetchEvolutionChain(completion: @escaping (Error?) -> Void) {
        apiManager.fetchPokemonSpecies(url: pokemon.speciesUrl) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let species):
                apiManager.fetchEvolutionChain(url: species.evolutionChain.url) { result in
                    switch result {
                    case .success(let evolutionChain):
                        self.evolutionChain = evolutionChain
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
}
