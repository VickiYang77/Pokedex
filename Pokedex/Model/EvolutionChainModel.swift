//
//  EvolutionChainModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/26.
//

struct EvolutionChainModel: Decodable {
    let id: Int
    let chain: Chain
    
    struct Chain: Decodable {
        let species: Species
        let evolvesTo: [Chain]?
        
        enum CodingKeys: String, CodingKey {
            case species
            case evolvesTo = "evolves_to"
        }
    }

    struct Species: Decodable {
        let name: String
        let url: String
    }
}

