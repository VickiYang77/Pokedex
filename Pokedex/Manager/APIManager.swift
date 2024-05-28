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
    case timeout
}

let apiManager = APIManager.shared

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    private let pokemonDetailUrl = "https://pokeapi.co/api/v2/pokemon/"
    private let pokemonListUrl = "https://pokeapi.co/api/v2/pokemon"
    
    func fetchPokemonList(limit: Int, offset: Int, completion: @escaping (Result<PokemonResponse, Error>) -> Void) {
        let urlString = "\(pokemonListUrl)?limit=\(limit)&offset=\(offset)"
        fetchData(from: urlString, completion: completion)
    }
    
    func fetchPokemonDetail(for id: Int, completion: @escaping (PokemonModel?) -> Void) {
        let urlString = pokemonDetailUrl + "\(id)"
        fetchPokemonDetail(from: urlString, completion: completion)
    }

    func fetchPokemonDetail(for name: String, completion: @escaping (PokemonModel?) -> Void) {
        let urlString = pokemonDetailUrl + name
        fetchPokemonDetail(from: urlString, completion: completion)
    }

    func fetchPokemonDetail(from url: String, completion: @escaping (PokemonModel?) -> Void) {
        fetchData(from: url) { (result: Result<PokemonModel, Error>) in
            switch result {
            case .success(let pokemon):
                appManager.pokemons[pokemon.id] = pokemon
                appManager.pokemonNameToIDMap[pokemon.name] = pokemon.id
                appManager.pokemonIDToNameMap[pokemon.id] = pokemon.name
                completion(pokemon)
            case .failure(let error):
                print("Failed to fetch Pokemon detail: \(error)")
                completion(nil)
            }
        }
    }
    
    func fetchPokemonSpecies(url: String, completion: @escaping (Result<PokemonSpeciesModel, Error>) -> Void) {
        fetchData(from: url, completion: completion)
    }

    func fetchEvolutionChain(url: String, completion: @escaping (Result<EvolutionChainModel, Error>) -> Void) {
        fetchData(from: url, completion: completion)
    }
    
    private func fetchData<T: Decodable>(from urlString: String, retryCount: Int = 3, retryDelay: TimeInterval = 2, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                if (error as NSError).code == NSURLErrorTimedOut {
                    if retryCount > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                            self.fetchData(from: urlString, retryCount: retryCount - 1, retryDelay: retryDelay, completion: completion)
                        }
                    } else {
                        completion(.failure(APIError.timeout))
                    }
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
