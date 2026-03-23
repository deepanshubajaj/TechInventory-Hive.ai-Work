//
//  ViewController.swift
//  Hive
//
//  Created by Deepanshu Bajaj on 01/10/25.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var images: [ImageModel] = []
    var currentPage = 1
    var isLoading = false
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let headerView = HeaderView(
        title: "Hive",
        subtitle: "Browse photos • Tap to open"
    )
    
    private let bottomBar = UIView()
    private let bottomLabel = UILabel()
    private let scrollToTopButton = UIButton(type: .system)
    
    private let layout = UICollectionViewFlowLayout()
    private let spacing: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupHeaderAndBottomBar()
        setupCollectionView()
        setupLoader()
        fetchImages()
    }
    
    func setupLoader() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func setupHeaderAndBottomBar() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .systemBackground
        view.addSubview(bottomBar)
        
        // Top hairline separator
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        bottomBar.addSubview(separator)
        
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.text = "Keep scrolling for more"
        bottomLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        bottomLabel.textColor = .secondaryLabel
        bottomLabel.adjustsFontForContentSizeCategory = true
        bottomBar.addSubview(bottomLabel)
        
        scrollToTopButton.translatesAutoresizingMaskIntoConstraints = false
        scrollToTopButton.setTitle(nil, for: .normal)
        scrollToTopButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        scrollToTopButton.tintColor = .label
        scrollToTopButton.backgroundColor = .secondarySystemBackground
        scrollToTopButton.clipsToBounds = true
        scrollToTopButton.accessibilityLabel = "Scroll to top"
        scrollToTopButton.addTarget(self, action: #selector(scrollToTopTapped), for: .touchUpInside)
        bottomBar.addSubview(scrollToTopButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 92),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            
            separator.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            bottomLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            bottomLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            
            scrollToTopButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            scrollToTopButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            scrollToTopButton.leadingAnchor.constraint(greaterThanOrEqualTo: bottomLabel.trailingAnchor, constant: 12),
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 36),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        scrollToTopButton.layer.cornerRadius = 18
    }
    
    func setupCollectionView() {
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let columns: CGFloat = 3
        let totalSpacing = layout.sectionInset.left
        + layout.sectionInset.right
        + layout.minimumInteritemSpacing * (columns - 1)
        
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / columns)
        
        let newSize = CGSize(width: itemWidth, height: itemWidth + 30)
        if layout.itemSize != newSize {
            layout.itemSize = newSize
            layout.invalidateLayout()
        }
    }
    
    func fetchImages() {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        
        ImageService.fetchImages(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isLoading = false
                
                switch result {
                case .success(let newImages):
                    self?.images.append(contentsOf: newImages)
                    self?.collectionView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    @objc private func scrollToTopTapped() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}
        
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let model = images[indexPath.item]
        cell.configure(with: model)
        
        if indexPath.item == images.count - 1 {
            fetchImages()
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = images[indexPath.item].url
        guard let url = URL(string: urlString) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
}
