//
//  SongCell.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import UIKit

class SongCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: SongCell.self)
    
    private var viewModel = SongCellViewModel()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "song-icon")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        label.numberOfLines = 1
        label.textColor = .systemGray
        return label
    }()
    
    private let songLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, artistLabel, songLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage, artistName: String, songName: String, poster: String) {
        imageView.image = image
        artistLabel.text = artistName
        songLabel.text = songName
        setupListeners()
        viewModel.downloadImage(poster: poster)
    }
    
    func display(image: UIImage) {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
            self?.imageView.image = image
        }
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    private func setupListeners() {
        viewModel.image.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.display(image: image)
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            // change here to 0.8- letter will get cut
            imageView.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.75)
        ])
    }
}
