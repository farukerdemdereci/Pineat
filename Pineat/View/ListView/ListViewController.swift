//
//  ListViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import UIKit
import CoreLocation

class ListViewController: UIViewController {
    
    // MARK: - Properties
    private let vm = ListViewModel()
    private let locationManager = CLLocationManager()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ListCustomCell.self, forCellReuseIdentifier: ListCustomCell.identifier)
        return table
    }()
    
    private let emptyStateButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "Henüz bir mekan eklemedin.\nEklemek için buraya tıkla!"
        button.setTitle(title, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTopSafeAreaGradient()
        setupNavigationStyle()
        setupSearchController()
        setupLocationManager()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLocations()
    }
    
    // MARK: - Networking
    private func fetchLocations() {
        Task {
            await vm.fetchLocations()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                let isEmpty = self.vm.filteredArray.isEmpty
                self.tableView.isHidden = isEmpty
                self.emptyStateButton.isHidden = !isEmpty
            }
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC",
           let destinationVC = segue.destination as? LocationViewController,
           let location = sender as? Location {
            destinationVC.selectedLocationFromList = location
            
            if let sheet = destinationVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
            }
        }
    }
    
    @objc private func emptyStateTapped() {
        self.tabBarController?.selectedIndex = 1
    }
}

// MARK: - TableView Methods
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.filteredArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCustomCell.identifier, for: indexPath) as? ListCustomCell else { return UITableViewCell() }
        let location = vm.filteredArray[indexPath.row]
        
        var distanceText = ""
        if let userLoc = locationManager.location {
            let dest = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let meters = userLoc.distance(from: dest)
            distanceText = meters >= 1000 ? String(format: "%.1fkm", meters / 1000) : "\(Int(meters))m"
        }
        
        cell.configure(title: location.title, description: location.description, imageUrl: location.image_url, distance: distanceText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLocation = vm.filteredArray[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: selectedLocation)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = vm.filteredArray[indexPath.row]
            Task {
                await vm.deleteLocation(id: location.id)
                fetchLocations()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

// MARK: - Search & Location Delegates
extension ListViewController: UISearchResultsUpdating, CLLocationManagerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        vm.filterContentForSearchText(searchText)

        let isEmpty = vm.filteredArray.isEmpty
        tableView.isHidden = isEmpty
        emptyStateButton.isHidden = !isEmpty
        
        tableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UI Setup Extensions
extension ListViewController {
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(emptyStateButton)
        
        emptyStateButton.addTarget(self, action: #selector(emptyStateTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupNavigationStyle() {
        title = "Pineat"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTopSafeAreaGradient() {
        let topView = UIImageView(image: UIImage(named: "arkaplan"))
        topView.contentMode = .scaleAspectFill
        topView.clipsToBounds = true
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        view.sendSubviewToBack(topView)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        let colors = [
            UIColor(red: 0.55, green: 0.82, blue: 0.62, alpha: 1.0).cgColor,
            UIColor(red: 0.45, green: 0.72, blue: 0.52, alpha: 1.0).cgColor
        ]
        
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.opacity = 0.8
        
        DispatchQueue.main.async {
            gradient.frame = topView.bounds
            topView.layer.insertSublayer(gradient, at: 0)
        }
    }

    private func setupSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Mekan ara..."
        search.searchBar.searchTextField.backgroundColor = .white
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
