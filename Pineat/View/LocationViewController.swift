//
//  MapViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import MapKit
import CoreLocation
import PhotosUI

class LocationViewController: UIViewController {
    
    // MARK: - Properties
    var selectedLocationFromList: Location?
    private let vm = LocationViewModel()
    private let locationManager = CLLocationManager()
    private var isFirstTime = true
    private var infoCardBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        return map
    }()
    
    private let infoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var imagePickerView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "photo.badge.plus")
        iv.tintColor = .systemGray3
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.contentMode = .center
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Mekan Adı..."
        tf.font = .systemFont(ofSize: 18, weight: .bold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Kısa bir not ekle..."
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .secondaryLabel
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Konumu Kaydet", for: .normal)
        btn.backgroundColor = UIColor(red: 0.0, green: 0.45, blue: 0.74, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupLocationManager()
        setupGestures()
        setupKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndShowAnnotations()
        focusOnSelectedLocation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Map Logic & Annotations
extension LocationViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    private func fetchAndShowAnnotations() {
        Task {
            await vm.fetchAllLocations()
            DispatchQueue.main.async {
                let oldAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                self.mapView.removeAnnotations(oldAnnotations)
                
                for loc in self.vm.locationArray {
                    let pin = MKPointAnnotation()
                    pin.title = loc.title
                    pin.subtitle = loc.description
                    pin.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }

    private func focusOnSelectedLocation() {
        if let target = selectedLocationFromList {
            let coordinate = CLLocationCoordinate2D(latitude: target.latitude, longitude: target.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.isFirstTime = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        if isFirstTime {
            let region = MKCoordinateRegion(center: lastLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            isFirstTime = false
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title ?? "Hedef Konum"
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

// MARK: - Gestures & Actions
extension LocationViewController {
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            
            vm.chosenLatitude = coordinate.latitude
            vm.chosenLongitude = coordinate.longitude
            
            let tempPins = self.mapView.annotations.filter { $0.title == "Yeni Mekan" }
            mapView.removeAnnotations(tempPins)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Yeni Mekan"
            mapView.addAnnotation(annotation)
            
            resetFields()
            showInfoCard()
        }
    }

    @objc func saveButtonClicked() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        vm.saveLocations(title: title, description: descriptionTextField.text ?? "", latitude: vm.chosenLatitude, longitude: vm.chosenLongitude, image: imagePickerView.image)
        dismissEverything()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.fetchAndShowAnnotations() }
    }

    @objc func dismissEverything() {
        view.endEditing(true)
        hideInfoCard()
    }
    
    private func resetFields() {
        titleTextField.text = ""
        descriptionTextField.text = ""
        imagePickerView.image = UIImage(systemName: "photo.badge.plus")
        imagePickerView.contentMode = .center
    }
}

// MARK: - Image Picker Logic
extension LocationViewController: PHPickerViewControllerDelegate {
    @objc func didTapImage() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let selectedImage = image as? UIImage {
                DispatchQueue.main.async {
                    self?.imagePickerView.image = selectedImage
                    self?.imagePickerView.contentMode = .scaleAspectFill
                }
            }
        }
    }
}

// MARK: - Keyboard & Layout Setup
extension LocationViewController {
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 { self.view.frame.origin.y -= keyboardSize.height }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 { self.view.frame.origin.y = 0 }
    }

    private func showInfoCard() {
        infoCardBottomConstraint?.constant = -160
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideInfoCard() {
        infoCardBottomConstraint?.constant = 450
        UIView.animate(withDuration: 0.4) { self.view.layoutIfNeeded() }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }

    private func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissEverything))
        tap.cancelsTouchesInView = false
        mapView.addGestureRecognizer(tap)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imagePickerView.addGestureRecognizer(imageTap)
    }

    private func setupLayout() {
        view.addSubview(mapView)
        view.addSubview(infoCard)
        view.addSubview(saveButton)
        infoCard.addSubview(imagePickerView)
        infoCard.addSubview(titleTextField)
        infoCard.addSubview(descriptionTextField)
        
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        infoCardBottomConstraint = infoCard.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 450)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoCardBottomConstraint!,
            infoCard.heightAnchor.constraint(equalToConstant: 120),
            
            imagePickerView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 12),
            imagePickerView.centerYAnchor.constraint(equalTo: infoCard.centerYAnchor),
            imagePickerView.widthAnchor.constraint(equalToConstant: 90),
            imagePickerView.heightAnchor.constraint(equalToConstant: 90),
            
            titleTextField.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: imagePickerView.trailingAnchor, constant: 15),
            titleTextField.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -10),

            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 12),
            saveButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
