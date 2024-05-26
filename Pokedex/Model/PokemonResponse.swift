//
//  PokemonResponse.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

struct PokemonResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonEntry]
    
    struct PokemonEntry: Decodable {
        let name: String
        let url: String
    }
}
