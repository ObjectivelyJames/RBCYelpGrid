//
//  RootYelpViewController.swift
//  RBCYelpGrid
//
//  Created by James Larcombe on 2017-07-25.
//  Copyright © 2017 widgetco. All rights reserved.
//

import UIKit
import YelpAPI

enum AlphabeticSortType {
    case ascending
    case descending
}

class RootYelpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var businesses: UICollectionView!
    @IBOutlet weak var term: UISearchBar!
    @IBOutlet weak var searchPrompt: UILabel!
    
    var searching = false
    var businessesSet = [YLPBusiness]()
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchPrompt.isHidden = businessesSet.count > 0
        return businessesSet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardYelpCell", for: indexPath)
        if let yelpCell = cell as? StandardYelpCollectionViewCell {
            yelpCell.businessLabel.text = businessesSet[indexPath.item].name
            yelpCell.addressLabel.text = businessesSet[indexPath.item].location.address[0]
            yelpCell.businessImage.image = UIImage(named: "")
            asyncLoadImage(business: businessesSet[indexPath.item], imageView: yelpCell.businessImage)
            
        }
        return cell
    }
    
    func fetchItems() {
        activityIndicator.startAnimating()
        if !searching {
            searching = true
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let query = YLPQuery(location: "155 Wellington Street West, Toronto, Ontario")
            query.term = term.text
            query.limit = 10
            YLPClient.authorize(withAppId: appDelegate.clientId, secret: appDelegate.clientSecret).flatMap { client in
                client.search(withQuery: query)
                }.onSuccess { [weak self] search  in
                    if search.businesses.count > 0 {
                        self?.businessesSet = search.businesses
                    } else {
                        print("No businesses found")
                    }
                    DispatchQueue.main.async {
                        self?.searching = false
                        self?.businesses.reloadData()
                        self?.activityIndicator.stopAnimating()
                    }
                }.onFailure { [weak self]  error in
                    print("Search errored: \(error)")
                    DispatchQueue.main.async {
                        self?.searching = false
                        self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func sortBusinesses(sortOrientation:AlphabeticSortType) {
        switch sortOrientation {
        case .ascending:
            businessesSet.sort(by: { $0.name < $1.name })
        case .descending:
            businessesSet.sort(by: { $0.name > $1.name })
        }
        DispatchQueue.main.async {
            self.businesses.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BusinessDetailViewController,
            let cell = sender as? UICollectionViewCell {
            if let indexPath = businesses.indexPath(for: cell) {
                destination.business = businessesSet[indexPath.item]
            }
        }
    }

    @IBAction func ascending(_ sender: UIBarButtonItem) {
        sortBusinesses(sortOrientation: .ascending)
    }
    
    @IBAction func descending(_ sender: UIBarButtonItem) {
        sortBusinesses(sortOrientation: .descending)
    }
}

func asyncLoadImage(business:YLPBusiness,imageView:UIImageView){
    let downloadQueue = DispatchQueue(label: "com.widgetco.RBCYelpGrid.AsyncImageQueue")
    if let imageUrl = business.imageURL {
        downloadQueue.async(){
            do {
                let data = try Data.init(contentsOf: imageUrl)
                var image:UIImage?
                image = UIImage(data: data)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } catch {
                print("Error in image retreaval")
            }
        }
    }
}
