//
//  ListCustomCell.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 24.12.2025.
//

import UIKit
import Kingfisher

class ListCustomCell: UITableViewCell {
    
    static let identifier = "ListCustomCell"
    
    // MARK: - UI Elements
    private let restaurantImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restaurantImageView.kf.cancelDownloadTask() // Kingfisher görevini iptal et
        restaurantImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        distanceLabel.text = nil
    }
}

// MARK: - Configuration
extension ListCustomCell {
    func configure(title: String, description: String, imageUrl: String?, distance: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        distanceLabel.text = distance
        
        if let urlString = imageUrl, let url = URL(string: urlString) {
            restaurantImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            restaurantImageView.image = UIImage(systemName: "photo")
        }
    }
}

// MARK: - Setup Views
extension ListCustomCell {
    private func setupViews() {
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, distanceLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 7
        infoStack.alignment = .leading
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(restaurantImageView)
        contentView.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            restaurantImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            restaurantImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            restaurantImageView.widthAnchor.constraint(equalToConstant: 94),
            restaurantImageView.heightAnchor.constraint(equalToConstant: 80),
            
            infoStack.leadingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: 12),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoStack.centerYAnchor.constraint(equalTo: restaurantImageView.centerYAnchor),
            infoStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            infoStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
