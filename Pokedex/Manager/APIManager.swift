//
//  APIManager.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noData
}
let apiManager = APIManager.shared

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    let pokemonDetailUrl = "https://pokeapi.co/api/v2/pokemon/"
    
    func fetchPokemonDetail(from url: String, completion: @escaping (PokemonModel?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        print("vvv_dataTask_fetchPokemonDetail：\(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let pokemon = try decoder.decode(PokemonModel.self, from: data)
                appManager.pokemons[pokemon.id] = pokemon
                appManager.pokemonNameToIDMap[pokemon.name] = pokemon.id
                completion(pokemon)
            } catch {
                print("Failed to decode Pokemon details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchPokemonSpecies(url: String, completion: @escaping (Result<PokemonSpeciesModel, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let species = try decoder.decode(PokemonSpeciesModel.self, from: data)
                completion(.success(species))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchEvolutionChain(url: String, completion: @escaping (Result<EvolutionChainModel, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let evolutionChain = try decoder.decode(EvolutionChainModel.self, from: data)
                completion(.success(evolutionChain))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
