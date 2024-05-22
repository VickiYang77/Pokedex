//
//  HomePageViewController.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit

struct Pokemon {
    let id: Int
    let name: String
    let types: [String]
    let thumbnailURL: URL
}

class HomePageViewController: UIViewController {

    enum ViewMode {
        case list
        case grid
    }
    
    private var collectionView: UICollectionView!
    private var pokemons: [Pokemon] = []
    private var favoritePokemons: [Int: Bool] = [:]
    private var filteredPokemons: [Pokemon] = []
    private var isFilteringFavorites = false
    private var viewMode: ViewMode = .list
    
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
        
//        collectionView.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: "PokemonCell")
        view.addSubview(collectionView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "切換視圖", style: .plain, target: self, action: #selector(toggleViewMode)),
            UIBarButtonItem(title: "過濾收藏", style: .plain, target: self, action: #selector(toggleFavoriteFilter))
        ]
    }
    
    private func loadPokemons() {
        // 假設從API獲取數據
        // 這裡簡化為本地生成
        for i in 1...30 {
            let pokemon = Pokemon(
                id: i,
                name: "Pokemon \(i)",
                types: ["Type1", "Type2"],
                thumbnailURL: URL(string: "https://example.com/\(i).png")!
            )
            pokemons.append(pokemon)
        }
        collectionView.reloadData()
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
    func didToggleFavorite(for pokemon: Pokemon) {
        print("vvv_\(pokemon.name)")
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
