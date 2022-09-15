//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 08/08/2022.
//

import UIKit

class OrderTableViewController: UITableViewController {
    // MARK: - Properties
    var minutesToPrepareOrder = 0
    var imageLoadTask: [IndexPath: Task<Void, Never>] = [:]

    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order"
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdateNotification, object: nil)
        MenuController.shared.updateUserActivity(with: .order)
    }
    
    
    
    // MARK: - Actions
    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "dismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
    }
    
    
    
    @IBAction func submitTapped1(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) {
            (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        
        let alertController = UIAlertController(title: "Confirm order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            self.uploadOrder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    
    
    // MARK: - Methods
    func uploadOrder() {
        let menuIDs = MenuController.shared.order.menuItems.map { $0.id }
        Task.init {
            do {
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuUDs: menuIDs)
                minutesToPrepareOrder = minutesToPrepare
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.shared.order.menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)
        configureCell(cell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let item = MenuController.shared.order.menuItems[indexPath.row]
        
        
        cell.itemName = item.name
        cell.price = item.price
        cell.image = nil
        
        imageLoadTask[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: item.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                   currentIndexPath == indexPath {
                    cell.image = image
                }
                imageLoadTask[indexPath] = nil
            }
        }
        
        
        
        }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
}
