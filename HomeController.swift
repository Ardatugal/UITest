import UIKit
import SwiftUI
import Photos

class HomeViewController: UIViewController {

    var collectionView: UICollectionView!
    var photoScanner: PhotoScanner!

    // Groups that have at least one photo (excluding empty ones)
    var nonEmptyGroups: [PhotoGroup] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Groups"

        setupCollectionView()
        loadGroups()
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: "GroupCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubview(collectionView)
    }

    func loadGroups() {
        // Get all groups with counts from photoScanner, filter out empty ones
        nonEmptyGroups = photoScanner.groupCounts.filter { $0.value > 0 }.map { $0.key }
        
        // Ensure 'other' is included if non-empty, and avoid duplicates
        if let otherCount = photoScanner.groupCounts[.other], otherCount > 0, !nonEmptyGroups.contains(.other) {
            nonEmptyGroups.append(.other)
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nonEmptyGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let group = nonEmptyGroups[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.configure(with: group, count: photoScanner.groupCounts[group] ?? 0)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = nonEmptyGroups[indexPath.item]
        let assets = photoScanner.assetsForGroup(group)

        let groupDetailView = GroupDetailView(group: group, assets: assets)
        let hostingVC = UIHostingController(rootView: groupDetailView)
        hostingVC.title = group.rawValue.capitalized
        navigationController?.pushViewController(hostingVC, animated: true)
    }
}
