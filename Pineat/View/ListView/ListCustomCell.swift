//
//  ListCustomCell.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 24.12.2025.
//

import Foundation
import UIKit
import Kingfisher

class ListCustomCell: UITableViewCell {
    
    static let identifier = "ListCustomCell"
    
    // MARK: - UI Elements
    private let restaurantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCell() {
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, distanceLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 7
        mainStack.alignment = .leading
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(restaurantImageView)
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            restaurantImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            restaurantImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            restaurantImageView.widthAnchor.constraint(equalToConstant: 94),
            restaurantImageView.heightAnchor.constraint(equalToConstant: 80),
            
            mainStack.leadingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: restaurantImageView.centerYAnchor),
            
            mainStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, description: String, imageUrl: String?, distance: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        distanceLabel.text = distance
        
        if let urlString = imageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
            restaurantImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            restaurantImageView.image = UIImage(systemName: "photo")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restaurantImageView.image = nil
    }
}
