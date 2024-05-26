//
//  PokemonSpeciesModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

struct PokemonSpeciesModel: Decodable {
    let evolutionChain: EvolutionChain
    
    enum CodingKeys: String, CodingKey {
        case evolutionChain = "evolution_chain"
    }
    
    struct EvolutionChain: Decodable {
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case url
        }
    }
}

