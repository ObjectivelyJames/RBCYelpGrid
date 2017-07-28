//
//  BusinessDetailViewController.swift
//  RBCYelpGrid
//
//  Created by James Larcombe on 2017-07-27.
//  Copyright © 2017 widgetco. All rights reserved.
//

import UIKit
import YelpAPI



class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessAddress: UILabel!
    
    var business:YLPBusiness?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initiallyConfigureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewForBusiness()
    }

    func initiallyConfigureView() {
        businessImage.layer.cornerRadius = 240.0 / 2.0
    }
    
    func configureViewForBusiness() {
        if let business = business {
            businessName.text = business.name
            for address in business.location.address {
                businessAddress.text?.append("\(address)\n")
            }
            asyncLoadImage(business: business, imageView: businessImage)
        }
    }
}
