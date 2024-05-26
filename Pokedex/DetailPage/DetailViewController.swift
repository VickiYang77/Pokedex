//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import UIKit

class DetailViewController: UIViewController {
    private var favoriteButton: UIBarButtonItem!
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let viewModel: DetailViewModel
    private var evolutionChainView: EvolutionChainView?
    
    private lazy var infoView: DetailInfoView = {
        let infoView = Bundle.main.loadNibNamed("DetailInfoView", owner: nil, options: nil)?.first as! DetailInfoView
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = false
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoView.layer.shadowRadius = 4
        infoView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        infoView.configure(id: self.viewModel.pokemon.id, name: self.viewModel.pokemon.name, types: self.viewModel.pokemon.types, imageUrl: self.viewModel.pokemon.spritesImageUrl)
        return infoView
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        viewModel.fetchEvolutionChain { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.createEvolutionChainView()
            }
        }
    }
    
    private func createEvolutionChainView() {
        guard let evolutionChain = viewModel.evolutionChain else {
            return
        }
        evolutionChainView = EvolutionChainView(evolutionChain: evolutionChain)
        stackView.addArrangedSubview(evolutionChainView!)
    }
    
    private func setupNavigationBar() {
        favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favouriteButtonTapped))
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFavorite = appManager.favoritePokemons[viewModel.pokemon.id] ?? false
        favoriteButton.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
    }
    
    @objc private func favouriteButtonTapped() {
        appManager.updateFavouriteStatus(id: viewModel.pokemon.id)
        updateFavoriteButton()
    }
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        // setup ScrollView
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // setup StackView
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        stackView.addArrangedSubview(infoView)
    }
}


