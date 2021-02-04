//
//  ViewController.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import UIKit
import Moya

class ViewController: UIViewController {
    lazy var viewModelController = ViewModelController()
    weak var itemsTable: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /**Performing request after all UI elements have been initialized.*/
        viewModelController.getItems(success: {indices in

            self.itemsTable?.insertRows(at: indices, with: .left)
        }, failure: {error in
            self.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again")
        })
    }
    
    /**Initialization of UI elements.*/
    private func setUpTable() {
        let table = UITableView(frame: view.frame, style: .plain)
        itemsTable = table
        table.backgroundColor = .clear
        view.addSubview(table)
        NSLayoutConstraint.activate(table.makeConstraintsTo(view, constraints: [
            .top: (.top, UIView.ConstraintSettings()),
            .bottom: (.bottom, UIView.ConstraintSettings()),
            .leading: (.leading, UIView.ConstraintSettings()),
            .trailing: (.trailing, UIView.ConstraintSettings())
        ]))
        table.delegate = self
        table.dataSource = self
        table.register(ItemCell.self, forCellReuseIdentifier: String(describing: ItemCell.self))
    }
}

    // MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 7
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == viewModelController.itemsCount - 1 {
            viewModelController.getItems(success: {indices in
                self.itemsTable?.insertRows(at: indices, with: .left)
            }, failure: {error in
                self.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again")
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newVC = DetailedViewController()
        newVC.picture = viewModelController.itemAtIndex(indexPath.item)
        navigationController?.pushViewController(newVC, animated: true)
    }
}

    // MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelController.itemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCell.self), for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        cell.picture = viewModelController.itemAtIndex(indexPath.item)
        cell.layoutIfNeeded()
        return cell
    }
    
    
}

