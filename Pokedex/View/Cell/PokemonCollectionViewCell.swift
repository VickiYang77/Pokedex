//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit

protocol PokemonCollectionViewCellDelegate: AnyObject {
    func didToggleFavorite(for pokemon: PokemonModel)
}

class PokemonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: PokemonCollectionViewCellDelegate?
    private var pokemon: PokemonModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        idLabel.text = ""
        nameLabel.text = ""
        typesLabel.text = ""
        imageView.image = nil
    }
    
    func configure(with pokemon: PokemonModel) {
        self.pokemon = pokemon
        idLabel.text = "#\(pokemon.id)"
        nameLabel.text = pokemon.name
        typesLabel.text = pokemon.types.joined(separator: ", ")
        
        // 加載縮略圖，這裡可以使用SDWebImage或其他庫
        // imageView.sd_setImage(with: pokemon.thumbnailURL)
        
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        // 檢查是否收藏 (從UserDefaults或CoreData)
        let isFavorite = false // 根據需要進行修改
        let buttonTitle = isFavorite ? "Unfavorite" : "Favorite"
        favoriteButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction func favoriteBtnTapped(_ sender: UIButton) {
        guard let pokemon = pokemon else { return }
        delegate?.didToggleFavorite(for: pokemon)
    }
}

