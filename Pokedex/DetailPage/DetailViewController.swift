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
        let view = Bundle.main.loadNibNamed("DetailInfoView", owner: nil, options: nil)?.first as! DetailInfoView
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.configure(id: self.viewModel.pokemon.id, name: self.viewModel.pokemon.name, types: self.viewModel.pokemon.types, imageUrl: self.viewModel.pokemon.spritesImageUrl)
        return view
    }()
    
    private lazy var descView: DescriptionView = {
        let view = Bundle.main.loadNibNamed("DescriptionView", owner: nil, options: nil)?.first as! DescriptionView
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
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
        
        viewModel.fetchPokemonSpecies { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let species):
                    self.descView.configure(description: self.viewModel.descriptionText)
                    
                    self.viewModel.fetchEvolutionChain(url: species.evolutionChain.url) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                self.createEvolutionChainView()
                            case .failure(let error):
                                print("Failed to fetch evolution chain: \(error)")
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to fetch species: \(error)")
                }
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = viewModel.pokemon.name
        favoriteButton = createBarButton(with: "heart", action: #selector(favouriteButtonTapped))
        let homeButton = createBarButton(with: "house", action: #selector(homeButtonTapped))
        navigationItem.rightBarButtonItems = [favoriteButton, homeButton]
        updateFavoriteButton()
    }
    
    private func createBarButton(with systemName: String, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return UIBarButtonItem(customView: btn)
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
        stackView.addArrangedSubview(descView)
    }
    
    private func createEvolutionChainView() {
        guard let evolutionChain = viewModel.evolutionChain else {
            return
        }
        evolutionChainView = EvolutionChainView(evolutionChain: evolutionChain)
        evolutionChainView?.delegate = self
        stackView.addArrangedSubview(evolutionChainView!)
    }
    
    @objc private func homeButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func favouriteButtonTapped() {
        appManager.toggleFavorite(pokemonID: viewModel.pokemon.id)
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFavorite = appManager.favoritePokemons[viewModel.pokemon.id] ?? false
        if let button = favoriteButton.customView as? UIButton {
            button.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
        }
    }
}

extension DetailViewController: EvolutionChainViewDelegate {
    func gotoDetailPageWith(pokemon: PokemonModel) {
        if pokemon.name != viewModel.pokemon.name {
            let vm = DetailViewModel(pokemon: pokemon)
            let detailVC = DetailViewController(viewModel: vm)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
