//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/23.
//

import Foundation

struct PokemonModel: Decodable {
    let id: Int
    let name: String
    let types: [String]
    let spritesImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case types
        case sprites
    }
    
    struct PokemonTypes: Codable {
        let slot: Int
        let type: PokemonType
    }
    
    struct PokemonType: Codable {
        let name: String
    }
    
    struct PokemonSprites: Codable {
        let frontDefault: String
        let other: PokemonSpritesOther
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
            case other
        }
    }
    
    struct PokemonSpritesOther: Codable {
        let officialArtwork: PokemonSpritesOtherOfficialArtwork
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
    
    struct PokemonSpritesOtherOfficialArtwork: Codable {
        let frontDefault: String
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    // 自定義初始化方法
    init(id: Int = 0, name: String = "", types: [String] = [], spritesImageUrl: String = "") {
        self.id = id
        self.name = name
        self.types = types
        self.spritesImageUrl = spritesImageUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let typesContainer = try container.decode([PokemonTypes].self, forKey: .types)
        types = typesContainer.map { $0.type.name }
        
        let spritesContainer = try container.decode(PokemonSprites.self, forKey: .sprites)
        spritesImageUrl = spritesContainer.other.officialArtwork.frontDefault
    }
}

struct PokemonResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonEntry]
    
    struct PokemonEntry: Codable {
        let name: String
        let url: String
    }
}

