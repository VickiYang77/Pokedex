//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit
import Kingfisher

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
    private var pokemon: PokemonModel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pokemon = PokemonModel()
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
        if let url = URL(string: pokemon.thumbnailURL) {
            imageView.kf.setImage(with: url)
        }
        
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFavorite = UserDefaults.standard.bool(forKey: pokemon.favoriteKey)
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func favoriteBtnTapped(_ sender: UIButton) {
        let isFavorite = UserDefaults.standard.bool(forKey: pokemon.favoriteKey)
        UserDefaults.standard.set(!isFavorite, forKey: pokemon.favoriteKey)
        UserDefaults.standard.synchronize()
        updateFavoriteButton()
        delegate?.didToggleFavorite(for: pokemon)
    }
}

