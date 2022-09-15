//
//  MenuTableViewController.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 08/08/2022.
//

import UIKit

@MainActor
class MenuTableViewController: UITableViewController {
    // MARK: - Properties
    let category: String
    var menuItems = [MenuItem]()
    var imageLoadTask: [IndexPath: Task<Void, Never>] = [:]
    
    
    
    // MARK: - Lifecycle
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.capitalized
        
        MenuController.shared.updateUserActivity(with: .menu(category: category))
        
        Task.init {
            do {
                let menuItems = try await MenuController.shared.fetchMenuItems(forCategory: category)
                updateUI(with: menuItems)
            } catch {
                displayError(error, title: "Failed to fetch menu item for \(self.category)")
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel image fetching tasks if that are no longel needed.
        imageLoadTask.forEach { key, value in value.cancel() }
    }
    
    // MARK: - Actions
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: Any?) -> MenuItemViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell)   else {
            return nil
        }
        
        let menuItem = menuItems[indexPath.row]
        return MenuItemViewController(coder: coder, menuItem: menuItem)
    }
    
    
    // MARK: - Methods
    func updateUI(with menuItems: [MenuItem]) {
        self.menuItems = menuItems
        self.tableView.reloadData()
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configure(_ cell: UITableViewCell, forItem indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = menuItems[indexPath.row]
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
        imageLoadTask[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                   currentIndexPath == indexPath {
                    cell.image = image
                }
                imageLoadTask[indexPath] = nil
            }
        }
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath)
        configure(cell, forItem: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cancel the image fetching tasks if it's no longer needed.
        imageLoadTask[indexPath]?.cancel()
    }
}
