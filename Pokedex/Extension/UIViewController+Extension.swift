//
//  UIViewController+Extension.swift
//  Pokedex
//
//  Created by Vicki Yang   on 2024/5/28.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertForNoData() {
        showAlert(message: "Data not found.\nPlease try again later.")
    }
}

