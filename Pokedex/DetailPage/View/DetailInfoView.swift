//
//  DetailInfoView.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/25.
//

import UIKit

class DetailInfoView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    
    func configure(id: Int, name: String, types: [String], imageUrl: String) {
        idLabel.text = String(format: "#%04d", id)
        nameLabel.text = name
        typesLabel.text = types.joined(separator: ", ")
        
        if let url = URL(string: imageUrl) {
            appManager.setPokemonImage(for: imageView, with: url)
        }
    }
}
