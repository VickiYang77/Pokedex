//
//  EvolutionItemView.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import UIKit

protocol EvolutionItemViewDelegate: AnyObject {
    func gotoDetailPageWith(pokemon: PokemonModel)
}

class EvolutionItemView: UIView {
    weak var delegate: EvolutionItemViewDelegate?
    private var pokemon: PokemonModel?
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftUpLineView: UIView!
    @IBOutlet weak var leftCenterLineView: UIView!
    @IBOutlet weak var leftDownLineView: UIView!
    @IBOutlet weak var rightCenterLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLineColor()
    }
    
    func configure(name: String) {
        nameLabel.text = name
        
        if let pokemon = appManager.getPokemonWith(name: name) {
            self.pokemon = pokemon
            if let url = URL(string: pokemon.spritesImageUrl) {
                appManager.setPokemonImage(for: imageView, with: url)
            }
        } else {
            apiManager.fetchPokemonDetail(for: name) { [weak self] pokemon in
                if let pokemon = pokemon {
                    self?.pokemon = pokemon
                    if let url = URL(string: pokemon.spritesImageUrl) {
                        if let imageView = self?.imageView {
                            appManager.setPokemonImage(for: imageView, with: url)
                        }
                    }
                }
            }
        }
    }
    
    private func setLineColor() {
        let lineColor: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        leftUpLineView.backgroundColor = lineColor
        leftCenterLineView.backgroundColor = lineColor
        leftDownLineView.backgroundColor = lineColor
        rightCenterLineView.backgroundColor = lineColor
    }
    
    @IBAction func evolutionChainPokemonTapped(_ sender: UIButton) {
        guard let pokemon = pokemon else { return }
        delegate?.gotoDetailPageWith(pokemon: pokemon)
    }
}
