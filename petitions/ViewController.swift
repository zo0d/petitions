//
//  ViewController.swift
//  petitions
//
//  Created by BJ on 2019-05-07.
//  Copyright © 2019 BJ. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var filterActive = false
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterActive ? filteredPetitions.count : petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition: Petition
        if (filterActive) {
            petition = filteredPetitions[indexPath.row]
        } else {
            petition = petitions[indexPath.row]
        }
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view.
    //
    //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
    //        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForFilter))
    //
    //        let urlString: String
    //
    //        if navigationController?.tabBarItem.tag == 0 {
    //            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
    //        } else {
    //            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
    //        }
    //
    //        //let urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
    //        DispatchQueue.global(qos: .userInitiated).async {
    //            [weak self] in
    //            if let url = URL(string: urlString) {
    //                if let data = try? Data(contentsOf: url) {
    //                    self?.parse(json: data)
    //                    return
    //                }
    //            }
    //
    //            self?.showError()
    //        }
    //    }
    
    //    func parse(json: Data) {
    //        let decoder = JSONDecoder()
    //
    //        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
    //            petitions = jsonPetitions.results
    //            filteredPetitions = petitions
    //            DispatchQueue.main.async {
    //                [weak self] in
    //                self?.tableView.reloadData()
    //            }
    //        }
    //    }
    
    //    func showError() {
    //        DispatchQueue.main.async {
    //            [weak self] in
    //            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
    //            ac.addAction(UIAlertAction(title: "Ok", style: .default))
    //            self?.present(ac, animated: true)
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForFilter))
        
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your internet connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "This information has been brought to you by We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    @objc func promptForFilter() {
        let ac = UIAlertController(title: "Enter filter", message: "", preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let filterString = ac?.textFields?[0].text else {return}
            DispatchQueue.global(qos: .userInitiated).async {
                [weak self] in
                self?.filterResults(filterString)
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func filterResults(_ filterString: String) {
        filteredPetitions.removeAll()
        for petition in petitions {
            if petition.title.contains(filterString) {
                filteredPetitions.append(petition)
            }
        }
        if filteredPetitions.count == 0 {
            filterActive = false
        } else {
            filterActive = true
        }
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
}

