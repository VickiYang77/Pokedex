//
//  PokemonListModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

struct PokemonListModel: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListResult]
    
    struct PokemonListResult: Decodable {
        let name: String
        let url: String
    }
}
