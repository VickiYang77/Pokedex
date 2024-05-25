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
    let thumbnailURL: String
    
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
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    // 自定義初始化方法
    init(id: Int = 0, name: String = "", types: [String] = [], thumbnailURL: String = "") {
        self.id = id
        self.name = name
        self.types = types
        self.thumbnailURL = thumbnailURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // 解析types
        let typesContainer = try container.decode([PokemonTypes].self, forKey: .types)
        types = typesContainer.map { $0.type.name }
        
        // 解析圖片URL
        let spritesContainer = try container.decode(PokemonSprites.self, forKey: .sprites)
        thumbnailURL = spritesContainer.frontDefault
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

