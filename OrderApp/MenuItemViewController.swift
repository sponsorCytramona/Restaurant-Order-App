//
//  MenuItemViewController.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 08/08/2022.
//

import UIKit

@MainActor
class MenuItemViewController: UIViewController {
    // MARK: - Properties
    let menuItem: MenuItem
    
    // MARK: - Outlets
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailLable: UILabel!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    
    
    // MARK: - Lifecycle
    init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(with: menuItem)
        MenuController.shared.updateUserActivity(with: .menuItemDetail(menuItem))
    }
    
    
    
    // MARK: - Action
    @IBAction func addToOrderButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [], animations: {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        MenuController.shared.order.menuItems.append(menuItem)
    }
    
    
    
    // MARK: - Methods
    func updateUI(with menuItem: MenuItem) {
        nameLabel.text = menuItem.name.uppercased()
        priceLabel.text = menuItem.price.formatted(.currency(code: "usd"))
        detailLable.text = menuItem.detailText
        
        Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                foodImage.image = image
            }
        }
    }
}
