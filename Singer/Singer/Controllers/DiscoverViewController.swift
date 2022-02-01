//
//  ChatViewController.swift
//  Singer
//
//  Created by Daniel Gogozan on 08.11.2021.
//

import UIKit
import AVKit

class DiscoverViewController: UIViewController {
    
    private var songViewModel: SongViewModel!
    
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
        label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        label.numberOfLines = 1
        label.textColor = .systemGray
        return label
    }()
    
    private let songLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
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
        stackView.spacing = -15
        return stackView
    }()
    
    private var song: Song?
    
    // how to change border color, text color
    // how to add edge insets
    private lazy var findButton: UIButton = {
        let button = UIButton()
        button.setTitle("Find song", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "my-black")
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = CGColor(red: 236, green: 22, blue: 114, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.addTarget(self, action: #selector(findSong(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "my-red")
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.addTarget(self, action: #selector(playSong(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [playButton, findButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 25
        return stackView
    }()
    
    override func loadView() {
        super.loadView()
        view.addSubview(stackView)
        view.addSubview(buttonsStackView)
        setupConstraints()
        setupListeners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Discover"
    }
    
    init(songViewModel: SongViewModel) {
        self.songViewModel = songViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }
    
    private func setupListeners() {
        songViewModel.discoveredSong.bind { [weak self] song in
            guard let self = self else {
                return
            }
            if let song = song {
                DispatchQueue.main.async {
                    UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve) {
                        self.artistLabel.text = song.artist
                        self.songLabel.text = song.name
                        self.playButton.isHidden = false
                        self.getImage(poster: song.poster, completion: { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.imageView.image = image
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func getImage(poster: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            if let url = URL(string: poster),
               let data = try? Data(contentsOf: url) {
                completion(UIImage(data: data))
                return
            }
        }
    }
    
    @objc func findSong(_ sender: UIButton) {
        playButton.isHidden = false
        songViewModel.getSong()
    }
    
    @objc func playSong(_ sender: UIButton) {
        if let url = songViewModel.downloadDestionation {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = AVPlayer(url: url)
            playerViewController.entersFullScreenWhenPlaybackBegins = true
            present(playerViewController, animated: true)
        }
    }
}
