//
//  Extensions.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import Foundation
import UIKit
import Moya

extension String {
    
    /// UTF* encoded representation of the string.
    var utf8Encoded: Data {
        guard let data = data(using: .utf8) else {
            fatalError("String cannot be encoded into Data.")
        }
        return data
    }
}

extension Response {
    
    /// Same as map(_:atKeyPath:using:failsOnEmptyData:), but can map through deep keyPath.
    /// - Parameters:
    ///   - keyPath: Deep key path in format "key:anotherKey:someOtherKey"
    ///   - type: Type of the object which parsed for.
    ///   - decoder: A `JSONDecoder` instance which is used to decode data to an object.
    ///   - failsOnEmptyData: flag for terminating execution of mapping if empty data is found.
    /// - Returns: Returns an object of given type.
    func mapWithNestedKeyPath<D: Decodable>(_ keyPath: String?, _ type: D.Type, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        if var pathArray = keyPath?.split(whereSeparator: {$0 == ":"}), pathArray.count > 1  {
            guard let jsonObject = try? self.mapJSON() as? NSDictionary,
                  let deeperJSON = jsonObject.value(forKey: String(pathArray.removeFirst())),
                  let jsonData = try? JSONSerialization.data(withJSONObject: deeperJSON) else {
                throw MoyaError.jsonMapping(self)
            }
            let wrapperResponse = Response(statusCode: self.statusCode, data: jsonData)
            do {
                let object = try wrapperResponse.mapWithNestedKeyPath(String(pathArray.removeFirst()), type, using: decoder, failsOnEmptyData: failsOnEmptyData)
                return object
            } catch {
                throw error
            }
        } else {
            do {
                let object = try map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                return object
            } catch {
                throw error
            }
        }
    }
}

extension UIView {
    
    /// Simple struct wrapper for constrains arguments.
    struct ConstraintSettings {
        var constant: CGFloat = 0
        var multiplier: CGFloat = 1
        var relation: NSLayoutConstraint.Relation = .equal
    }
    
    /// Makes NSLayoutConstraint array.
    /// - Parameters:
    ///   - view: To which constraints are needed to be applied. Can be self.
    ///   - constraints: Array of dictionaries which contains attribute of the view initiated method as a key and a tuple of the attribute of the view to which constaints needed to refer and value of constraint arguments.
    /// - Returns: Array of created NSLayoutConstraints.
    func makeConstraintsTo(_ view: UIView, constraints: [NSLayoutConstraint.Attribute: (viewAttribute: NSLayoutConstraint.Attribute, settings: ConstraintSettings)]) -> [NSLayoutConstraint] {
        var newConstraints: [NSLayoutConstraint] = []
        constraints.forEach({selfAttribute, value in
            if self == view, value.viewAttribute == .notAnAttribute {
                newConstraints.append(NSLayoutConstraint(item: self, attribute: selfAttribute, relatedBy: value.settings.relation, toItem: nil, attribute: .notAnAttribute, multiplier: value.settings.multiplier, constant: value.settings.constant))
            } else {
                newConstraints.append(NSLayoutConstraint(item: self, attribute: selfAttribute, relatedBy: value.settings.relation, toItem: view, attribute: value.viewAttribute, multiplier: value.settings.multiplier, constant: value.settings.constant))
            }
        })
        return newConstraints
    }
}

extension UIViewController {
    /// Creates an alert with given title, message and button title and shows it on the screen.
    ///
    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: The message of the alert.
    ///   - buttonTitle: The text that appears on the button.
    ///
    func generateAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let newVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            newVC.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: { action in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }))
            self.present(newVC, animated: true, completion: nil)
        }
    }
}
