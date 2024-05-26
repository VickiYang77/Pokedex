//
//  PokemonSpeciesModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

struct PokemonSpeciesModel: Decodable {
    let flavorTextEntries: [FlavorTextEntry]
    let evolutionChain: EvolutionChain
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case evolutionChain = "evolution_chain"
    }
    
    struct FlavorTextEntry: Decodable {
        let flavorText: String
        let language: Language
        let version: Version
        
        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language
            case version
        }
        
        struct Language: Decodable {
            let name: String
            let url: String
        }

        struct Version: Decodable {
            let name: String
            let url: String
        }
    }
    
    struct EvolutionChain: Decodable {
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case url
        }
    }
}

