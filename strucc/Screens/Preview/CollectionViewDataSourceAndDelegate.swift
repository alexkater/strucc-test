//
//  CollectionViewDataSourceAndDelegate.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import UIKit

typealias SelectionCallback = ((Int) -> Void)

class CollectionViewDataSourceAndDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Variables:
    var items: [EditorCollectionCellViewModel]

    private var scrollVelocity: CGFloat = 0.0
    private var collectionViewCenter: CGFloat
    var selectedItem: Int = 0

    // MARK: - UI Items:
    private let collectionView: UICollectionView
    private let selectionFB = UISelectionFeedbackGenerator()
    private let selectionCallback: SelectionCallback
    private var spacing: CGFloat { (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0   }

    init(view: UIView, collectionView: UICollectionView, selectionCallback: @escaping SelectionCallback) {
        self.collectionView = collectionView
        self.selectionCallback = selectionCallback
        self.items = []
        collectionViewCenter = collectionView.bounds.width / 2
    }

    // MARK: - Delegate Functions:

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorCollectionViewCell.identifier, for: indexPath) as? EditorCollectionViewCell else { return UICollectionViewCell() }

        cell.setup(with: items[indexPath.row], index: indexPath.row)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        selectedItem = indexPath.item

        guard let layout: CollectionViewFlowLayout = collectionView.collectionViewLayout as? CollectionViewFlowLayout else { return }
        let x: CGFloat = CGFloat(selectedItem) * (CellConstants.normalWidth + layout.minimumInteritemSpacing)
        layout.ignoringBoundsChange = true
        collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        layout.ignoringBoundsChange = false
    }

    // MARK: - Supporting Functions:

    /// Called when cell is selected
    private func selectedCell(cell: EditorCollectionViewCell, index: Int) {
        selectionCallback(index)
    }

    // MARK: - Animation:

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let closestItem = (scrollView.contentOffset.x / (CellConstants.normalWidth + spacing)).rounded()
        let closestItemInt = Int(closestItem)
        guard closestItemInt != selectedItem else { return }
        selectedItem = closestItemInt
        selectionCallback(selectedItem)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollVelocity = velocity.x

        targetContentOffset.pointee = offset(forCenterX: scrollView.contentOffset.x) {
            selectedItem = $0
        }
    }

    // Calculate the offset to the center from the nearest cell
    func offset(forCenterX currentX: CGFloat, performAction: (Int) -> Void) -> CGPoint {

        let closerItem: (CGFloat) = (currentX / (CellConstants.normalWidth + spacing)).rounded()
        let closestItem = min(closerItem, (items.count.cgFloat - 1))
        performAction(Int(closestItem))
        return CGPoint(x: closestItem * (CellConstants.normalWidth + 24), y: 0.0)
    }
}
