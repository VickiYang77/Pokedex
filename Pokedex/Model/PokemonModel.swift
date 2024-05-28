//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/23.
//

struct PokemonModel: Decodable {
    let id: Int
    let name: String
    let types: [String]
    let speciesUrl: String
    let spritesImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case types
        case species
        case sprites
    }
    
    // MARK: - Type
    struct PokemonTypes: Decodable {
        let slot: Int
        let type: PokemonType
    }
    
    struct PokemonType: Decodable {
        let name: String
    }
    
    // MARK: - Species
    struct PokemonSpecies: Decodable {
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case url
        }
    }
    
    // MARK: - Sprites
    struct PokemonSprites: Decodable {
//        let frontDefault: String?
        let other: PokemonSpritesOther
        
        enum CodingKeys: String, CodingKey {
//            case frontDefault = "front_default"
            case other
        }
    }
    
    struct PokemonSpritesOther: Decodable {
        let officialArtwork: PokemonSpritesOtherOfficialArtwork
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
    
    struct PokemonSpritesOtherOfficialArtwork: Decodable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    // MARK: - init
    init(id: Int = 0, name: String = "", types: [String] = [], speciesUrl: String = "", spritesImageUrl: String = "") {
        self.id = id
        self.name = name
        self.types = types
        self.speciesUrl = speciesUrl
        self.spritesImageUrl = spritesImageUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let typesContainer = try container.decode([PokemonTypes].self, forKey: .types)
        types = typesContainer.map { $0.type.name }
        
        let speciesContainer = try container.decode(PokemonSpecies.self, forKey: .species)
        speciesUrl = speciesContainer.url
        
        let spritesContainer = try container.decode(PokemonSprites.self, forKey: .sprites)
        spritesImageUrl = spritesContainer.other.officialArtwork.frontDefault ?? ""
    }
}
