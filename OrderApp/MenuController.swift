//
//  MenuController.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 10/08/2022.
//

import Foundation
import UIKit

class MenuController {

    enum MenuCategoriesError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemsNotFound
        case orderRequestFailed
        case imageDataMissing
    }
    
    // MARK: – Properties
    let baseURL =  URL(string: "http://localhost:8080/")
    
    static let shared = MenuController()
    static let orderUpdateNotification = Notification.Name("MenuController.OrderUpdated")
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdateNotification, object: nil)
            userActivity.order = order
        }
    }
    
    var userActivity = NSUserActivity(activityType: "com.example.OrderApp.order")
    
    
    
    // MARK: – Methods
    func fetchCategories() async throws -> [String] {
        let categoriesURL = baseURL!.appendingPathComponent("categories")
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuCategoriesError.categoriesNotFound
        }
        
        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
        
        return categoriesResponse.categories
    }
    
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
        let baseMenuURL = baseURL!.appendingPathComponent("menu")
        var components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)
        components!.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components!.url!
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuCategoriesError.menuItemsNotFound
        }
        
        let decoder = JSONDecoder()
        let menuResponse = try decoder.decode(MenuResponse.self, from: data)
        
        return menuResponse.items
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuCategoriesError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else {
            throw MenuCategoriesError.imageDataMissing
        }
        
        return image
    }
    
    
    
    typealias MinutesToPrepare = Int
    
    func submitOrder(forMenuUDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL!.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let menuIdsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIdsDict)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuCategoriesError.orderRequestFailed
        }
        
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from: data)
        
        return orderResponse.prepTime
    }
    
    func updateUserActivity(with controller: StateRestorationController) {
        switch controller {
        case .menu(let category):
            userActivity.menuCategory = category
        case .menuItemDetail(let menuItem):
            userActivity.menuItem = menuItem
        case .order, .categories:
            break
        }
        userActivity.controllerIdentifier = controller.indentifier
        }
}
