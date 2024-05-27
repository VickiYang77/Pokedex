//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/22.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    private var pokemonID: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        idLabel.text = ""
        nameLabel.text = ""
        typesLabel.text = ""
        imageView.image = UIImage(named: "Pokeball")
        pokemonID = 0
    }
    
    func configure(id: Int, name: String, types: [String], imageUrl: String) {
        pokemonID = id
        idLabel.text = String(format: "#%04d", id)
        nameLabel.text = name
        typesLabel.text = types.joined(separator: ", ")
        
        if let url = URL(string: imageUrl) {
            appManager.setPokemonImage(for: imageView, with: url)
        }
        
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFavorite = appManager.favoritePokemons[pokemonID] ?? false
        let image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favoriteButton.setImage(image, for: .normal)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        appManager.toggleFavorite(pokemonID: pokemonID)
        updateFavoriteButton()
    }
}

