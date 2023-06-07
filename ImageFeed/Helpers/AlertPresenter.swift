//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Максим on 07.06.2023.
//

import UIKit


protocol AlertPresenterProtocol: AnyObject {
    func show(result: AlertModel)
    var delegate: UIViewController? {get set}
}


final class AlertPresenter: AlertPresenterProtocol {
   weak var delegate: UIViewController?

    func show(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message ?? "",
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: result.okButtonText, style: .default) { _ in
            result.completion()
        }
        let noAction = UIAlertAction(title: result.noButtonText, style: .default) { _ in
            result.completion()
        }

        alert.addAction(okAction)
        alert.addAction(noAction)

        delegate?.present(alert, animated: true, completion: nil)

    }
}


struct AlertModel {
    let title: String
    let message: String?
    let okButtonText: String
    let noButtonText: String?
    let completion: () -> () //замыкание без параметров для действия по кнопке аллерта
}
