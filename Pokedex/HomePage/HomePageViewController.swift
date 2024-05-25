//
//  HomePageViewController.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit

class HomePageViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let viewModel: HomePageViewModel
    private var modeButton: UIBarButtonItem!
    private var favoriteFilterButton: UIBarButtonItem!
    
    init(viewModel: HomePageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNavigationBar()
        setupViewModel()
        viewModel.loadPokemons()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let listNib = UINib(nibName: "PokemonListCollectionViewCell", bundle: nil)
        collectionView.register(listNib, forCellWithReuseIdentifier: "PokemonListCell")
        
        let gridNib = UINib(nibName: "PokemonGridCollectionViewCell", bundle: nil)
        collectionView.register(gridNib, forCellWithReuseIdentifier: "PokemonGridCell")
        
        view.addSubview(collectionView)
    }
    
    private func setupNavigationBar() {
        favoriteFilterButton = createBarButton(with: "heart", action: #selector(showFavorite))
        modeButton = createBarButton(with: "square.grid.2x2", action: #selector(changeViewMode))
        navigationItem.rightBarButtonItems = [favoriteFilterButton, modeButton]
    }
    
    private func createBarButton(with systemName: String, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // 固定大小
        return UIBarButtonItem(customView: btn)
    }
    
    private func setupViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @objc private func changeViewMode() {
        viewModel.viewMode = (viewModel.viewMode == .list) ? .grid : .list
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        
        if let button = modeButton.customView as? UIButton {
            button.setImage(UIImage(systemName: viewModel.viewMode == .list ? "square.grid.2x2" : "list.bullet"), for: .normal)
        }
    }
    
    @objc private func showFavorite() {
        viewModel.toggleFavoriteFilter()
        
        if let button = favoriteFilterButton.customView as? UIButton {
            button.setImage(UIImage(systemName: viewModel.isFilteringFavorites ? "heart.fill" : "heart"), for: .normal)
        }
    }
}

extension HomePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pokemonList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pokemon = viewModel.pokemonList(at: indexPath.row)
        
        switch viewModel.viewMode {
        case .list:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonListCell", for: indexPath) as! PokemonCollectionViewCell
            cell.delegate = self
            cell.configure(id: pokemon.id, name: pokemon.name, types: pokemon.types, imageUrl: pokemon.spritesImageUrl, isFavorite: viewModel.favoritePokemons[pokemon.id] ?? false)
            return cell
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonGridCell", for: indexPath) as! PokemonCollectionViewCell
            cell.delegate = self
            cell.configure(id: pokemon.id, name: pokemon.name, types: pokemon.types, imageUrl: pokemon.spritesImageUrl, isFavorite: viewModel.favoritePokemons[pokemon.id] ?? false)
            return cell
        }
    }
}

extension HomePageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemon = viewModel.pokemonList(at: indexPath.row)
        let vm = DetailViewModel(pokemon: pokemon)
        let detailVC = DetailViewController(viewModel: vm)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            // 自動加載更多Pokemon數據
//            print("vvv_offset:\(viewModel.offset)")
//            viewModel.loadPokemons()
        }
    }
}

extension HomePageViewController: PokemonCollectionViewCellDelegate {
    func favoriteBtnTapped(id: Int, isFavorite: Bool) {
        viewModel.favoritePokemons[id] = isFavorite
    }
    
//    func favoriteBtnTapped(for pokemon: PokemonModel) {
//        let UserDefaultFavorite = UserDefaults.standard.bool(forKey: pokemon.favoriteKey)
//    }
}

extension HomePageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch viewModel.viewMode {
        case .list:
            return CGSize(width: width - 20, height: 100)
        case .grid:
            return CGSize(width: width / 2 - 10, height: width / 2)
        }
    }
}
