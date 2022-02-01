//
//  ViewController.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import UIKit

class MusicViewController: UIViewController {
    
    private let cellSpacing: CGFloat = 10
    private var cellSize: CGFloat?
    private let noColumns: CGFloat = 2
    private var timer: Timer = Timer()
    private let searchController = UISearchController()
    
    private var musicViewModel: MusicViewModel
    private var songViewModel: SongViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Music"
        setupListeners()
        initSearchController()
    }
    
    init(musicViewModel: MusicViewModel, songViewModel: SongViewModel) {
        self.musicViewModel = musicViewModel
        self.songViewModel = songViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setupListeners() {
        musicViewModel.music.bind { [weak self] music in
            print("Realoading data... with music \(music.count)")
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

extension MusicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.cellSize == nil,
           let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let space = layout.sectionInset.left + layout.sectionInset.right + (noColumns * cellSpacing - 1)
            self.cellSize = (view.frame.width - space) / noColumns
        }
        return CGSize(width: cellSize!, height: cellSize! + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        cellSpacing + 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image : UIImage?
        if let cell = collectionView.cellForItem(at: indexPath) as? SongCell {
            image = cell.getImage()
        }
        let vc = SongDetailViewController(song: musicViewModel.music.value[indexPath.item], viewModel: songViewModel, image: image ?? UIImage(named: "song-icon")!)
        self.navigationController?.pushViewController(vc, animated: true)
        searchController.searchBar.resignFirstResponder()
    }
    
    private func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}

// MARK: - Collection Data Source

extension MusicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        musicViewModel.music.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseIdentifier, for: indexPath) as? SongCell else {
            fatalError("Can't dequeue SongCell")
        }
        let song = musicViewModel.music.value[indexPath.item]
        cell.configure(image: UIImage(named: "song-icon")!, artistName: song.artist, songName: song.name, poster: song.poster)
        return cell
    }
}

// MARK: - Search Bar Delegate

extension MusicViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            if let query = searchController.searchBar.text, !query.isEmpty {
                self?.musicViewModel.getMusic(query: query)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.musicViewModel.getMusic()
    }
}
