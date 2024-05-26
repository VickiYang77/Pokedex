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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
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
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
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
        var cell = PokemonCollectionViewCell()
        
        switch self.viewModel.viewMode {
        case .list:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonListCell", for: indexPath) as! PokemonCollectionViewCell
        case .grid:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonGridCell", for: indexPath) as! PokemonCollectionViewCell
        }
        
        viewModel.pokemonList(at: indexPath.row) { pokemon in
            guard let pokemon = pokemon else { return }
            DispatchQueue.main.async {
                cell.configure(id: pokemon.id, name: pokemon.name, types: pokemon.types, imageUrl: pokemon.spritesImageUrl)
            }
        }
        
        return cell
    }
}

extension HomePageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.pokemonList(at: indexPath.row) { [weak self] pokemon in
            guard let self = self, let pokemon = pokemon else { return }
            
            DispatchQueue.main.async {
                let vm = DetailViewModel(pokemon: pokemon)
                let detailVC = DetailViewController(viewModel: vm)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        print("aaa_offsetY:\(offsetY)")
        if offsetY > contentHeight - height {
            print("aaa_======================")
            print("aaa_offsetY:\(offsetY)")
            print("aaa_contentHeight:\(contentHeight)")
            print("aaa_height:\(height)")
        }
    }
}

extension HomePageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch viewModel.viewMode {
        case .list:
            return CGSize(width: width - 20, height: 100)
        case .grid:
            return CGSize(width: width / 3 - 7, height: width / 2.5)
        }
    }
}

extension HomePageViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard !viewModel.isLoadingData else { return }
        
        if !viewModel.isFilteringFavorites && isLastCellVisible() {
            viewModel.loadPokemons()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }
    
    private func isLastCellVisible() -> Bool {
        guard let collectionView = collectionView else { return false }

        // 取得最後一個 section 的索引
        let lastSectionIndex = collectionView.numberOfSections - 1
        guard lastSectionIndex >= 0 else { return false }

        // 取得最後一個 section 中倒數第二個 cell 的 indexPath
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        let lastIndexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)

        // 取得最後一個 cell 的 frame
        guard let lastCellFrame = collectionView.layoutAttributesForItem(at: lastIndexPath)?.frame else { return false }

        // 取得 collectionView 的 contentOffset 和 bounds
        let contentOffsetY = collectionView.contentOffset.y
        let collectionViewHeight = collectionView.bounds.height

        // 檢查最後一個 cell 是否可見
//        print("vvv_isLastCellVisible:\(lastIndexPath), \(lastCellFrame.maxY <= contentOffsetY + collectionViewHeight)")
        return lastCellFrame.maxY <= contentOffsetY + collectionViewHeight
    }
}

