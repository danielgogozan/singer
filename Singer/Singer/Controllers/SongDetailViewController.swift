//
//  SongDetailViewController.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import UIKit
import AVKit

class SongDetailViewController: UIViewController {
    
    private var song: Song
    
    private var songPoster: UIImage
    
    private var songViewModel: SongViewModel
    
    // todo - add shadow
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private var artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private var songLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var downloadButton: UIButton = {
        let button =  createButton(title: "DOWNLOAD PREVIEW")
        button.addTarget(self, action: #selector(downloadSong(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var listenButton: UIButton = {
        let button = createButton(title: "LISTEN")
        button.isHidden = true
        button.addTarget(self, action: #selector(listen(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button =  createButton(title: "CANCEL")
        button.backgroundColor = UIColor(named: "my-black")
        button.layer.borderWidth = 1
        button.layer.borderColor = CGColor(red: 236, green: 22, blue: 114, alpha: 1)
        button.addTarget(self, action: #selector(cancelDownload(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var resumeButton: UIButton = {
        let button = createButton(title: "RESUME")
        button.addTarget(self, action: #selector(resumeDownload(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = createButton(title: "PAUSE")
        button.addTarget(self, action: #selector(pauseDownload(_:)), for: .touchUpInside)
        return button
    }()
    
    private var downloadProgress: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pauseButton, cancelButton])
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var isDownloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "my-black")
        addSubviews()
        setupViews()
        setupConstraints()
        setupListeners()
        songViewModel.checkDownloadDestination(songId: song.id)
    }
    
    init(song: Song, viewModel: SongViewModel, image: UIImage) {
        viewModel.refreshState()
        self.song = song
        self.songViewModel = viewModel
        self.songPoster = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        imageView.image = songPoster
        artistLabel.text = song.artist
        songLabel.text = song.name
    }
    
    func setupViewModel(viewModel: SongViewModel) {
        self.songViewModel = viewModel
    }
    
    func addSubviews() {
        view.addSubview(listenButton)
        view.addSubview(imageView)
        view.addSubview(songLabel)
        view.addSubview(artistLabel)
        view.addSubview(downloadButton)
        view.addSubview(downloadProgress)
        view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            songLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5),
            songLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            songLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            
            artistLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            artistLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            artistLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            downloadProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadProgress.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -15),
            
            downloadButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 100),
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            
            buttonsStackView.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 100),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            listenButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 100),
            listenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listenButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupListeners() {
        songViewModel.downloadProgress.bind { [weak self] progress in
            DispatchQueue.main.async {
                self?.downloadProgress.text = String(Int(progress * 100)) + "%"
            }
        }
        
        songViewModel.downloadState.bind { [weak self] state in
            guard let self = self else {
                return
            }
            switch state {
            case .downloading:
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = true
                    self.buttonsStackView.removeArrangedSubview(self.resumeButton)
                    self.buttonsStackView.insertArrangedSubview(self.pauseButton, at: 0)
                    self.downloadProgress.isHidden = false
                }
            case .paused:
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = false
                    self.buttonsStackView.removeArrangedSubview(self.pauseButton)
                    self.buttonsStackView.insertArrangedSubview(self.resumeButton, at: 0)
                }
            case .finished:
                DispatchQueue.main.async {
                    self.downloadButton.isHidden = true
                    self.buttonsStackView.isHidden = true
                    self.downloadProgress.isHidden = true
                    self.listenButton.isHidden = false
                }
            case .none:
                DispatchQueue.main.async {
                    self.buttonsStackView.isHidden = true
                    self.listenButton.isHidden = true
                    self.downloadProgress.isHidden = true
                    self.downloadButton.isHidden = false
                }
            }
        }
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "my-red")
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        // how to add edge insets
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return button
    }
    
    @objc func downloadSong(_ sender: UIButton) {
        downloadButton.isHidden = true
        isDownloading = true
        buttonsStackView.isHidden = false
        downloadProgress.isHidden = false
        downloadProgress.text = "0%"
        songViewModel.downloadSong(songId: song.id, preview: song.preview)
    }
    
    @objc func cancelDownload(_ sender: UIButton) {
        songViewModel.cancelDownload(songId: song.id)
    }
    
    @objc func pauseDownload(_ sender: UIButton) {
        songViewModel.pauseDownload(songId: song.id)
    }
    
    @objc func resumeDownload(_ sender: UIButton) {
        songViewModel.resumeDownload(songId: song.id)
    }
    
    @objc func listen(_ sender: UIButton) {
        if let url = songViewModel.downloadDestionation {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = AVPlayer(url: url)
            playerViewController.entersFullScreenWhenPlaybackBegins = true
            // resolves the navigation with the search controller problem
            navigationController?.pushViewController(playerViewController, animated: true)
            
            // does not work properly because of the search controller
            //present(playerViewController, animated: true)
        }
    }
}
