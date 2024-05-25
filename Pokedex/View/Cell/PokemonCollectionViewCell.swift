//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit
import Kingfisher

protocol PokemonCollectionViewCellDelegate: AnyObject {
    func favoriteBtnTapped(id: Int, isFavorite: Bool)
}

class PokemonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    var id: Int = 0
    
    weak var delegate: PokemonCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        idLabel.text = ""
        nameLabel.text = ""
        typesLabel.text = ""
        imageView.image = nil
        id = 0
    }
    
    func configure(id: Int, name: String, types: [String], imageUrl: String, isFavorite: Bool = false) {
        self.id = id
        idLabel.text = "#\(id)"
        nameLabel.text = name
        typesLabel.text = types.joined(separator: ", ")
        
        // 加載縮略圖，這裡可以使用SDWebImage或其他庫
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url)
        }
        
        updateFavoriteButton(isFavorite: isFavorite)
    }
    
//    func configure(with pokemon: PokemonModel) {
//        self.pokemon = pokemon
//        idLabel.text = "#\(pokemon.id)"
//        nameLabel.text = pokemon.name
//        typesLabel.text = pokemon.types.joined(separator: ", ")
//        
//        // 加載縮略圖，這裡可以使用SDWebImage或其他庫
//        if let url = URL(string: pokemon.thumbnailURL) {
//            imageView.kf.setImage(with: url)
//        }
//        
//        updateFavoriteButton()
//    }
    
    private func updateFavoriteButton(isFavorite: Bool = false) {
//        let isFavorite = UserDefaults.standard.bool(forKey: pokemon.favoriteKey)
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func favoriteBtnTapped(_ sender: UIButton) {
        let newFavoriteStatus = !UserDefaults.standard.bool(forKey: favoriteKey+"\(id)")
        UserDefaults.standard.set(newFavoriteStatus, forKey: favoriteKey+"\(id)")
        UserDefaults.standard.synchronize()
        updateFavoriteButton(isFavorite: newFavoriteStatus)
        delegate?.favoriteBtnTapped(id: id, isFavorite: newFavoriteStatus)
    }
}

