//
//  OrderConfirmationViewController.swift
//  OrderApp
//
//  Created by Max Klimakhovich on 16/08/2022.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    
    let minutesToPrepare: Int
    
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var orderProgressView: UIProgressView!
    
    
    
    init?(coder: NSCoder, minutesToPrepare: Int) {
        self.minutesToPrepare = minutesToPrepare
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTimeLabel.text = "Thank you for your order! Your wait time is approximately \(minutesToPrepare) minutes."
        updateProgressView()
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        orderProgressView.progress = 0
    }
    

    func updateProgressView() {
        orderProgressView.progress = 0

        let orderProgress = Progress(totalUnitCount: Int64(minutesToPrepare * 60))
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            guard orderProgress.isFinished == false else {
                timer.invalidate()
                print("Order finished")
                return
            }
            
            orderProgress.completedUnitCount += 1
                                    
            if self.minutesToPrepare*60 - Int(orderProgress.completedUnitCount) == (10*60) {
                print("The order will be ready in 10 minutes")
                
                let alert = UIAlertController(title: "Order", message: "Order will be ready in 10 minutes", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.orderProgressView.setProgress(Float(orderProgress.fractionCompleted), animated: true)
        }
    }
}
