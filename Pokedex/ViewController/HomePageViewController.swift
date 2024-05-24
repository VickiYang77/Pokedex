//
//  HomePageViewController.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit

//struct Pokemon {
//    let id: Int
//    let name: String
//    let types: [String]
//    let thumbnailURL: URL
//}

class HomePageViewController: UIViewController {

    enum ViewMode {
        case list
        case grid
    }
    
    private var collectionView: UICollectionView!
    private var pokemons: [PokemonModel] = []
    private var favoritePokemons: [Int: Bool] = [:]
    private var filteredPokemons: [PokemonModel] = []
    private var isFilteringFavorites = false
    private var viewMode: ViewMode = .list
    private var offset = 0
    private let limit = 20
    private let baseURL = "https://pokeapi.co/api/v2/pokemon"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNavigationBar()
        loadPokemons()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 註冊兩種不同的cell
        let listNib = UINib(nibName: "PokemonListCollectionViewCell", bundle: nil)
        collectionView.register(listNib, forCellWithReuseIdentifier: "PokemonListCell")
        
        let gridNib = UINib(nibName: "PokemonGridCollectionViewCell", bundle: nil)
        collectionView.register(gridNib, forCellWithReuseIdentifier: "PokemonGridCell")
        
        view.addSubview(collectionView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "切換視圖", style: .plain, target: self, action: #selector(toggleViewMode)),
            UIBarButtonItem(title: "過濾收藏", style: .plain, target: self, action: #selector(toggleFavoriteFilter))
        ]
    }
    
    private func loadPokemons() {
        let urlString = "\(baseURL)?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(PokemonResponse.self, from: data)
                
                let dispatchGroup = DispatchGroup()
                
                for entry in response.results {
                    dispatchGroup.enter()
                    self.fetchPokemonDetails(from: entry.url) { pokemon in
                        if let pokemon = pokemon {
                            self.pokemons.append(pokemon)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.offset += self.limit
                    self.pokemons.sort(by: { $0.id < $1.id })
                    self.collectionView.reloadData()
                }
                
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func fetchPokemonDetails(from url: String, completion: @escaping (PokemonModel?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let pokemon = try decoder.decode(PokemonModel.self, from: data)
                completion(pokemon)
            } catch {
                print("Failed to decode Pokemon details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    @objc private func toggleViewMode() {
        viewMode = (viewMode == .list) ? .grid : .list
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    @objc private func toggleFavoriteFilter() {
        isFilteringFavorites.toggle()
        filteredPokemons = pokemons.filter { favoritePokemons[$0.id] == true }
        collectionView.reloadData()
    }
}

extension HomePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFilteringFavorites ? filteredPokemons.count : pokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pokemon = isFilteringFavorites ? filteredPokemons[indexPath.row] : pokemons[indexPath.row]
        
        switch viewMode {
        case .list:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonListCell", for: indexPath) as! PokemonCollectionViewCell
            cell.delegate = self
            cell.configure(with: pokemon)
            return cell
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonGridCell", for: indexPath) as! PokemonCollectionViewCell
            cell.delegate = self
            cell.configure(with: pokemon)
            return cell
        }
    }
}

extension HomePageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemon = isFilteringFavorites ? filteredPokemons[indexPath.row] : pokemons[indexPath.row]
        // 跳轉到詳細頁面 (詳細頁面未實作)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            // 自動加載更多Pokemon數據
            // 此處省略具體實現
        }
    }
}

extension HomePageViewController: PokemonCollectionViewCellDelegate {
    func didToggleFavorite(for pokemon: PokemonModel) {
        let UserDefaultFavorite = UserDefaults.standard.bool(forKey: pokemon.favoriteKey)
        print("vvv_\(UserDefaultFavorite)")
    }
}

extension HomePageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch viewMode {
        case .list:
            return CGSize(width: width - 20, height: 100)
        case .grid:
            return CGSize(width: width / 2 - 10, height: width / 2)
        }
    }
}
