//
//  EvolutionChainView.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import UIKit

protocol EvolutionChainViewDelegate: AnyObject {
    func pokemonButtonTapped(pokemon: PokemonModel)
}

class EvolutionChainView: UIView {
    weak var delegate: EvolutionChainViewDelegate?
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private var stackViews: [UIStackView] = []
    let itemSize: CGFloat = 120
    var itemMaxCount = 1
    var currentLevel = 0
    
    init(evolutionChain: EvolutionChainModel) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        configureStackViews(with: [evolutionChain.chain])
        configureTitleLabel()
        configureContainerView()
        layoutStackViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStackViews(with evolutionChain: [EvolutionChainModel.Chain]) {
        currentLevel += 1
        let currentLevelItemCount = evolutionChain.count
        itemMaxCount = max(currentLevelItemCount, itemMaxCount)
        
        let nextChain = evolutionChain.first?.evolvesTo ?? []
        let haveNextLevel = !nextChain.isEmpty
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        for (index, item) in evolutionChain.enumerated() {
            let itemView = Bundle.main.loadNibNamed("EvolutionItemView", owner: nil, options: nil)?.first as! EvolutionItemView
            itemView.configure(name: item.species.name)
            itemView.delegate = self
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: itemSize),
                itemView.widthAnchor.constraint(equalToConstant: itemSize)
            ])
            
            if haveNextLevel {
                itemView.rightCenterLineView.isHidden = false
            }
            
            if currentLevel != 1 {
                itemView.leftCenterLineView.isHidden = false
            }
            
            if currentLevelItemCount != 1 {
                itemView.leftUpLineView.isHidden = false
                itemView.leftDownLineView.isHidden = false
                if index == 0 {
                    itemView.leftUpLineView.isHidden = true
                } else if index == currentLevelItemCount - 1 {
                    itemView.leftDownLineView.isHidden = true
                }
            }
            
            stackView.addArrangedSubview(itemView)
        }
        
        stackViews.append(stackView)
        
        if haveNextLevel {
            configureStackViews(with: nextChain)
        }
    }
    
    private func configureTitleLabel() {
        titleLabel.text = "Evolution Chain"
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: itemSize * CGFloat(itemMaxCount)+20)
        ])
    }
    
    private func layoutStackViews() {
        for (index, stackView) in stackViews.enumerated() {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                stackView.leadingAnchor.constraint(equalTo: index == 0 ? containerView.leadingAnchor : stackViews[index - 1].trailingAnchor)
            ])

            if index == stackViews.count - 1 {
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            }
        }
    }
}

extension EvolutionChainView: EvolutionItemViewDelegate {
    func pokemonButtonTapped(pokemon: PokemonModel) {
        delegate?.pokemonButtonTapped(pokemon: pokemon)
    }
}
