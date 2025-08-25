import UIKit
import SwiftUI
import Photos

class HomeViewController: UIViewController {

    var collectionView: UICollectionView!
    var photoScanner: PhotoScanner!

    // Groups that have at least one photo (excluding empty ones)
    var nonEmptyGroups: [PhotoGroup] = []

    // Optional: UI for showing scan progress (not required by original code)
    // let progressBar = UIProgressView(progressViewStyle: .default)
    // let progressLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Groups"

        photoScanner = PhotoScanner()

        setupCollectionView()
        setupScanningCallbacks()

        startScan()
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

    func setupScanningCallbacks() {
        photoScanner.onProgressUpdate = { [weak self] processed, total, groupCounts in
            guard let self = self else { return }

            // Update nonEmptyGroups as scan progresses
            self.nonEmptyGroups = groupCounts.filter { $0.value > 0 }.map { $0.key }
            
            // Ensure 'other' group is included if it has assets
            if let otherCount = groupCounts[.other], otherCount > 0, !self.nonEmptyGroups.contains(.other) {
                self.nonEmptyGroups.append(.other)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                // Optionally update progress UI here if you add it
            }
        }

        photoScanner.onScanComplete = {
            print("Scan complete!")
            // Optionally do something on completion
        }
    }

    func startScan() {
        photoScanner.startScan()
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

