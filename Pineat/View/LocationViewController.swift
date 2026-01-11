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
    
    private let vm: LocationViewModel
    
    init(vm: LocationViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    var selectedLocationFromList: Location?
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
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 15
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
        tf.placeholder = "Mekan Adı"
        tf.font = .systemFont(ofSize: 20, weight: .bold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Kısa bir açıklama ekle..."
        tv.font = .systemFont(ofSize: 14)
        tv.textColor = .lightGray
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = true
        return tv
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Konumu Kaydet", for: .normal)
        btn.backgroundColor = UIColor(red: 0.20, green: 0.67, blue: 0.45, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        setupKeyboardObservers()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndShowAnnotations()
        focusOnSelectedLocation()
    }
}

// MARK: - Actions
extension LocationViewController: UITextViewDelegate {
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        
        descriptionTextView.delegate = self

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        mapView.addGestureRecognizer(longPress)
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissEverything)))
        imagePickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImage)))
    }

    @objc private func saveButtonClicked() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let description = descriptionTextView.textColor == .lightGray ? "" : descriptionTextView.text
        
        Task {
            await vm.saveLocations(title: title, description: description ?? "",
                                   latitude: vm.chosenLatitude, longitude: vm.chosenLongitude,
                                   image: imagePickerView.image)
            hideInfoCard()
            view.endEditing(true)
            resetFields()
            fetchAndShowAnnotations()
        }
    }

    @objc private func dismissEverything() {
        view.endEditing(true)
        if (titleTextField.text?.isEmpty ?? true) && (descriptionTextView.textColor == .lightGray) {
            hideInfoCard()
        }
    }

    private func resetFields() {
        titleTextField.text = ""
        descriptionTextView.text = "Kısa bir açıklama ekle..."
        descriptionTextView.textColor = .lightGray
        imagePickerView.image = UIImage(systemName: "camera.circle.fill")
        imagePickerView.contentMode = .center
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
}

// MARK: - Keyboard Handling
extension LocationViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (kbSize.height - 100)
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - Setup Views
extension LocationViewController {
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(infoCard)
        
        infoCard.addSubview(imagePickerView)
        infoCard.addSubview(titleTextField)
        infoCard.addSubview(descriptionTextView)
        infoCard.addSubview(saveButton)
        
        infoCardBottomConstraint = infoCard.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            infoCardBottomConstraint!,
            infoCard.heightAnchor.constraint(equalToConstant: 200),
            
            imagePickerView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            imagePickerView.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            imagePickerView.widthAnchor.constraint(equalToConstant: 85),
            imagePickerView.heightAnchor.constraint(equalToConstant: 85),
            
            titleTextField.topAnchor.constraint(equalTo: imagePickerView.topAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: imagePickerView.trailingAnchor, constant: 15),
            titleTextField.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -15),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 45),

            saveButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

// MARK: - Map & PHPicker & Helper Logic
extension LocationViewController: MKMapViewDelegate, CLLocationManagerDelegate, PHPickerViewControllerDelegate {
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }

    private func fetchAndShowAnnotations() {
        Task {
            await vm.fetchLocations()
            let oldAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
            self.mapView.removeAnnotations(oldAnnotations)
            for loc in self.vm.locationArray {
                let pin = MKPointAnnotation()
                pin.title = loc.title
                pin.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                self.mapView.addAnnotation(pin)
            }
        }
    }

    @objc private func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let coordinate = mapView.convert(gestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            vm.chosenLatitude = coordinate.latitude
            vm.chosenLongitude = coordinate.longitude
            
            mapView.removeAnnotations(mapView.annotations.filter { $0.title == "Yeni Mekan" })
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = "Yeni Mekan"
            mapView.addAnnotation(pin)
            
            resetFields()
            showInfoCard()
        }
    }

    @objc private func didTapImage() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let img = image as? UIImage {
                DispatchQueue.main.async {
                    self?.imagePickerView.image = img
                    self?.imagePickerView.contentMode = .scaleAspectFill
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last, isFirstTime else { return }
        mapView.setRegion(MKCoordinateRegion(center: lastLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        isFirstTime = false
    }

    private func focusOnSelectedLocation() {
        if let target = selectedLocationFromList {
            let coordinate = CLLocationCoordinate2D(latitude: target.latitude, longitude: target.longitude)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
            isFirstTime = false
        }
    }

    private func showInfoCard() {
        infoCardBottomConstraint?.constant = -100
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) { self.view.layoutIfNeeded() }
    }

    private func hideInfoCard() {
        infoCardBottomConstraint?.constant = 500
        UIView.animate(withDuration: 0.4) { self.view.layoutIfNeeded() }
    }
}
