//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import UIKit

class DetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let viewModel: DetailViewModel
    
    private lazy var infoView: DetailInfoView = {
        let infoView = Bundle.main.loadNibNamed("DetailInfoView", owner: nil, options: nil)?.first as! DetailInfoView
        infoView.backgroundColor = .lightGray
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = true
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
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
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
        stackView.backgroundColor = .yellow
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
        
        let secondSubview = UIView()
        secondSubview.backgroundColor = .cyan
        secondSubview.heightAnchor.constraint(equalToConstant: 200).isActive = true
        stackView.addArrangedSubview(secondSubview)
    }
}


